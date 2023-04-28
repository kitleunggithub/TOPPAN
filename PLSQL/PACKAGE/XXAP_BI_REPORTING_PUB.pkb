--------------------------------------------------------
--  DDL for Package Body XXAP_BI_REPORTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAP_BI_REPORTING_PUB" 
IS
/********************************************************************************
**       		MERRILL CORPORATION - R12 12.2.4
**
**			MERRILL TECHNOLOGIES INDIA PRIVATE LIMITED
************************************************************************************
**
**    File - xxap_bi_reporting_pub.pks
**
************************************************************************************
**
**  DESCRIPTION
**
**    Package Specification - This Package is used to list the Outstanding Transacton for US_USB_Corporate_Card.
**
**
**  MODIFIED BY
**
**    Senthil Nathan  02-APR-2019      Initial draft Version
**
**********************************************************************************
**
**********************************************************************************
**  REVISION HISTORY:
**
**  Version      Author                  Date          Description
**  ---------    ---------------------   -----------   --------------------------------
**	  1.0        xxxx					 DD-MON-YYYY   Initial Development
**    1.1        SenthilNathan       	 02-APR-2019   CR Enhancement - CR#2350
**    1.2        Nagaraj S       	     24-APR-2020   CR Enhancement - CR#2739
*****************************************************************************************/

FUNCTION get_sup_id (p_person_id IN NUMBER)
   RETURN NUMBER IS
         v_sup   NUMBER;
  CURSOR sup_cur  IS
      SELECT DISTINCT pa.supervisor_id
        FROM per_assignments_f pa
           , per_people_f f
      WHERE f.person_id = pa.person_id
      AND f.person_id =  p_person_id
      AND    ( ( TRUNC(f.effective_start_date) <= TRUNC(SYSDATE)
            AND TRUNC( f.effective_end_date)  >=  TRUNC(SYSDATE)
            AND person_type_id = 6)
       OR (person_type_id = 9
             AND TRUNC(f.effective_start_date ) <=  TRUNC(SYSDATE)
             AND TRUNC(f.effective_end_date)  >=  TRUNC(SYSDATE)));

        BEGIN
           OPEN sup_cur;
           FETCH  sup_cur INTO v_sup;
           CLOSE sup_cur;

      RETURN v_sup;

   END get_sup_id;

/************************************************************************/
PROCEDURE  xxap_boa_cc_outstanding
                           ( p_retcode       OUT NUMBER
                            ,p_errbuf        OUT VARCHAR2
                            ,p_card          IN  NUMBER
                            ,p_posted_from_date   IN  VARCHAR2
                            ,p_posted_to_date     IN  VARCHAR2
                            ,p_employee    IN  NUMBER
                            ,p_manager     IN  NUMBER
                            )
  IS
  l_query                VARCHAR2(32767);
  l_select               VARCHAR2(8000);
  l_where                VARCHAR2(8000);
  l_group_by             VARCHAR2(4000);
  l_order_by             VARCHAR2(4000);
  qryCtx                 DBMS_XMLGEN.ctxHandle;
  result                 CLOB;

BEGIN
   pl('-- Begin XXAP BOA CC Report (xxap_bi_reporting_pub.xxap_boa_cc_outstanding)--');
   pl('Input Parameters:  ');
   pl('    Card Program        = ' || p_card);
   pl('    Posted Date From    = ' || p_posted_from_date);
   pl('    Posted Date To      = ' || p_posted_to_date);
   pl('    Employee            = ' || p_employee);
   pl('    Manager             = ' || p_manager);

    -- Build the report xml

      l_select := '
       SELECT
         cp.card_program_name card_program_name,
         perf.full_name employee_full_name,
         perf.employee_num employee_num,
         icc.chname chname,
         icc.masked_cc_number,
         to_char(cct.transaction_date, ''MON-YY'') period_name,
         cct.transaction_date transaction_date,
         cct.posted_date,
         to_char(NVL (cct.billed_date, cct.posted_date),''DD-MON-YYYY'') billed_date,
         SUBSTR(xxcm_common.get_org_name(cct.org_id),1,5) org_name,
         cct.billed_amount billed_amount,
         cct.transaction_amount transaction_amount,
         cct.posted_currency_code,
         cct.billed_currency_code,
         NVL(cct.mis_industry_code,sic_code) sic_code,
         f1.meaning sic_code_desc,
         gl.segment1 le,
         gl.segment2 pl,
         gl.segment3 st,
         gl.segment4 cc,
         f1.attribute1 ac,
         gl.segment6 ic,
         (SELECT distinct full_name
         FROM per_all_people_f
         WHERE person_id = (xxap_bi_reporting_pub.get_sup_id (perf.employee_id) )
          AND
           TRUNC(SYSDATE) BETWEEN TRUNC(effective_start_date) AND TRUNC(effective_end_Date)
            AND rownum < 2
          ) manager_full_name,
         ( SELECT
            ( CASE WHEN perf.effective_end_date > sysdate THEN ''Active Manager''
                   ELSE ''Inactive Manager''
                   END ) manager_status
         FROM per_all_people_f perf
         WHERE  person_type_id = ''6''
           AND person_id = (xxap_bi_reporting_pub.get_sup_id (perf.employee_id) )
		   AND rownum < 2
		 ) manager_status,
          (CASE
             WHEN cct.validate_code != ''Y''
             THEN
                vc.DISPLAYED_FIELD
             WHEN ac.card_id IS NULL
             THEN
                          ''Missing Card Record''
             WHEN ac.employee_id IS NULL
             THEN
                ''Unassigned Card''
             WHEN erh.report_header_id IS NULL
             THEN
                DECODE (NVL (cct.category, ''BUSINESS''), ''DISPUTED'', ''Disputed'', ''Unused'')
             ELSE
                --alc.displayed_field
               NVL(AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode (erh.source, erh.workflow_approved_flag, erh.report_header_id), ''Unused'')
          END) status,
         cct.merchant_name1 merchant_name1,
         cct.trx_id TRX_ID,
         erh.reject_code reject_code,
         perf.employee_id person_id
 FROM    ap_credit_card_trxns_ALL cct,
         ap_cards_all ac,
         ap_card_programs_all cp,
         iby_creditcard icc,
         ap_expense_report_headers_ALL erh,
         per_employees_x perf,
         ap_lookup_codes alc,
         gl_code_combinations gl,
         fnd_lookup_values_vl f1,
         ap_lookup_codes vc ';

  l_where :=  ' WHERE erh.report_header_id(+) = cct.report_header_id
                AND (erh.report_header_id is NULL
                 OR  ( erh.report_header_id is NOT NULL
                   AND  (( AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode (erh.source, erh.workflow_approved_flag, erh.report_header_id) NOT IN (''PAID'', ''INVOICED'')
                         )
                          OR ( AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode (erh.source, erh.workflow_approved_flag, erh.report_header_id) IN (''INVOICED'') AND reject_code IS NOT NULL)
                         OR (workflow_approved_flag IS NULL
                            ))))
         AND  ac.card_program_id(+) = cct.card_program_id
         AND card_program_name like ''%BOA%''
         AND ac.card_id(+) = cct.card_id
         AND ac.card_reference_id = icc.instrid(+)
         AND NVL(validate_code, ''N'') = ''Y''
         AND cp.card_program_id(+) = cct.card_program_id
         AND ac.employee_id = perf.employee_id(+)
         AND gl.code_combination_id(+) = perf.default_code_combination_id
         AND f1.lookup_type(+) = ''BOABANK_MCC''
         AND f1.lookup_code(+) = cct.mis_industry_code
         AND f1.enabled_flag(+) = ''Y''
         AND MERCHANT_name1 not like ''%Corporate%''
         AND SYSDATE BETWEEN NVL(f1.start_date_active, SYSDATE -1) AND NVL(f1.end_date_active, SYSDATE + 1)
         AND alc.lookup_type(+) = ''EXPENSE REPORT STATUS''
         AND alc.lookup_code(+) = AP_WEB_OA_ACTIVE_PKG.GetReportStatusCode (erh.source, erh.workflow_approved_flag, erh.report_header_id)
         AND vc.lookup_type(+) = ''OIE_CC_VALIDATION_ERROR''
		 AND  NVL(ACCTA.category, ''BUSINESS'') NOT IN (''MATCHED'', ''CREDIT'')
         AND vc.lookup_code(+) = cct.validate_code
         AND trunc(transaction_date) > ''01-JAN-18''
         and cct.org_id = cp.org_id ';

    IF (p_card IS NOT NULL) THEN
      l_where := l_where ||' AND cct.card_program_id = :P_CARD  ';
    END IF;

    IF (p_employee IS NOT NULL) THEN
      l_where := l_where ||' AND   perf.employee_id = :P_EMPLOYEE ';
    END IF;

    IF (p_manager IS NOT NULL) THEN
      l_where := l_where ||' AND  xxcm_common.get_sup_id (perf.employee_id)  = :P_MANAGER  ' ;
   END IF;
    IF (p_posted_to_date IS NOT NULL) THEN
      l_where := l_where ||' AND cct.posted_date >= TO_DATE(:P_POSTED_FROM_DATE,''YYYY/MM/DD HH24:MI:SS'')';
    END IF;

    IF (p_posted_from_date IS NOT NULL) THEN
      l_where := l_where ||' AND cct.posted_date <= TO_DATE(:P_POSTED_TO_DATE,''YYYY/MM/DD HH24:MI:SS'')';
    END IF;

--   l_order_by := ' ORDER BY perf.full_name';
   l_query := l_select || l_where ; --|| l_order_by;

    pl(l_query,'N');
    qryCtx := DBMS_XMLGEN.newContext(l_query);

    /*  Set the bind variables  */
    pl('Set Bind Variables');

    IF (p_card IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_CARD', p_card);
    END IF;

   IF ( p_posted_from_date IS NOT NULL) THEN
      dbms_xmlgen.setbindvalue(qryCtx, 'P_POSTED_FROM_DATE', p_posted_from_date);
   END IF;

   IF (p_posted_to_date IS NOT NULL) THEN
      dbms_xmlgen.setbindvalue(qryCtx, 'P_POSTED_TO_DATE', p_posted_to_date);
   END IF;

   IF (p_employee IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_EMPLOYEE', p_employee);
   END IF;

   IF (p_manager IS NOT NULL) THEN
      dbms_xmlgen.setbindvalue(qryCtx, 'P_MANAGER', p_manager);
   END IF;

  /* Sets the name of the element enclosing the entire result */
  pl('dbms_xmlgen.setrowsettag');
  dbms_xmlgen.setrowsettag(qryCtx, 'XXAP_BOA_CC_OUTSTANDING');

  /* Sets the name of the element enclosing each row of the result */
  pl('dbms_xmlgen.setrowtag');
  --dbms_xmlgen.setrowtag(qryCtx,'');

  /* Set the null handling option - Leave out the tags for null values */
  pl('dbms_xmlgen.setnullhandling');
  dbms_xmlgen.setnullhandling(qryCtx, 0);

  /*  Generate the XML data to the result  */
  pl('dbms_xmlgen.get_xml');
  result := DBMS_XMLGEN.getXML(qryCtx);

  /*  Closes a given context and releases all resources associated
  with it, including the SQL cursor and bind and define buffers */
  dbms_xmlgen.closecontext(qryctx);


  /*  Call procedure to write the xml output to the bi report */
  write_xml_output(result);
  pl('END xxap_bi_reporting_pub.xxap_boa_cc_outstanding');

 EXCEPTION
    WHEN OTHERS THEN
      p_retcode := sqlcode;
      p_errbuf  := sqlerrm;
      pl('Return Code = ' || p_retcode || ' ERROR: ' || p_errbuf);
      RAISE ;
END xxap_boa_cc_outstanding;

/*  v1.1 START */

/************************************************************************/

PROCEDURE  xxap_us_cc_outstanding ( p_retcode       	OUT NUMBER
								   ,p_errbuf        	OUT VARCHAR2
								   ,p_card          	IN  NUMBER
								   ,p_posted_from_date  IN  VARCHAR2
								   ,p_posted_to_date    IN  VARCHAR2
								   ,p_employee    		IN  NUMBER
								   ,p_manager     		IN  NUMBER
								   )
  IS

  l_query                VARCHAR2(32767);
  l_select               VARCHAR2(8000);
  l_where                VARCHAR2(8000);
  l_group_by             VARCHAR2(4000);
  l_order_by             VARCHAR2(4000);
  qryCtx                 DBMS_XMLGEN.ctxHandle;
  RESULT                 CLOB;

BEGIN
   pl('-- Begin XXAP US CC Report (xxap_bi_reporting_pub.xxap_us_cc_outstanding)--');
   pl('Input Parameters:  ');
   pl('    Card Program        = ' || p_card);
   pl('    Posted Date From    = ' || p_posted_from_date);
   pl('    Posted Date To      = ' || p_posted_to_date);
   pl('    Employee            = ' || p_employee);
   pl('    Manager             = ' || p_manager);

    -- Build the report xml

      l_select := '
       SELECT ACPA.card_program_name 												CARD_PROGRAM_NAME,
              PEX.full_name 														EMPLOYEE_FULL_NAME,
              PEX.employee_num 														EMPLOYEE_NUM,
              ICC.chname 															CHNAME,
              ICC.masked_cc_number													MASKED_CC_NUMBER,
              TO_CHAR(ACCTA.transaction_date, ''MON-YY'') 							PERIOD_NAME,
              ACCTA.transaction_date 												TRANSACTION_DATE,
              ACCTA.posted_date														POSTED_DATE,
              TO_CHAR(NVL (ACCTA.billed_date, ACCTA.posted_date),''DD-MON-YYYY'') 	BILLED_DATE,
              SUBSTR(XXCM_COMMON.GET_ORG_NAME(ACCTA.org_id),1,5) 					ORG_NAME,
              ACCTA.billed_amount 													BILLED_AMOUNT,
              ACCTA.transaction_amount 												TRANSACTION_AMOUNT,
              ACCTA.posted_currency_code											POSTED_CURRENCY_CODE,
              ACCTA.billed_currency_code 											BILLED_CURRENCY_CODE,
              NVL(ACCTA.mis_industry_code,sic_code) 								SIC_CODE,
              FLVV.meaning 															SIC_CODE_DESC,
              GLCC.segment1															LE,
              GLCC.segment2															PL,
              GLCC.segment3															ST,
              GLCC.segment4															CC,
              FLVV.attribute1 														AC,
              GLCC.segment6 														IC,
              (SELECT DISTINCT full_name
                 FROM per_all_people_f
                WHERE person_id = (XXAP_BI_REPORTING_PUB.GET_SUP_ID(PEX.employee_id))
                  AND TRUNC(SYSDATE) BETWEEN TRUNC(effective_start_date)
										 AND TRUNC(effective_end_Date)
                  AND ROWNUM < 2) 													MANAGER_FULL_NAME,
              (SELECT
              (CASE WHEN PERF.effective_end_date > SYSDATE THEN ''Active Manager''
                    ELSE ''Inactive Manager''
                     END ) manager_status
                FROM per_all_people_f PERF
               WHERE person_type_id = ''6''
                 AND person_id = (XXAP_BI_REPORTING_PUB.GET_SUP_ID(PEX.employee_id))
		         AND ROWNUM < 2) 													MANAGER_STATUS,
              (CASE
               WHEN ACCTA.validate_code != ''Y''
               THEN VC.DISPLAYED_FIELD
               WHEN ACA.card_id IS NULL
               THEN ''Missing Card Record''
               WHEN ACA.employee_id IS NULL
               THEN ''Unassigned Card''
               WHEN AERH.report_header_id IS NULL
               THEN DECODE(NVL(ACCTA.category, ''BUSINESS''), ''DISPUTED'', ''Disputed'', ''Unused'')
               ELSE NVL(AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(AERH.source, AERH.workflow_approved_flag, AERH.report_header_id), ''Unused'')
               END) 																STATUS,
              ACCTA.merchant_name1													MERCHANT_NAME1,
              ACCTA.trx_id 															TRX_ID,
              AERH.reject_code 														REJECT_CODE,
              PEX.employee_id 														PERSON_ID
         FROM ap_credit_card_trxns_all ACCTA,
		      ap_cards_all ACA,
		      ap_card_programs_all ACPA,
		      ap_expense_report_headers AERH,
		      iby_creditcard ICC,
		      ap_lookup_codes ALC,
		      ap_lookup_codes VC,
		      fnd_lookup_values_vl FLVV,
		      per_employees_x PEX,
		      gl_code_combinations GLCC ';

  l_where :=  ' WHERE 1=1
				  AND ACCTA.card_program_id(+) = ACA.card_program_id
				  AND ACCTA.card_program_id = ACPA.card_program_id(+)
                  AND ACA.card_id = ACCTA.card_id(+)
				  AND AERH.report_header_id(+) = ACCTA.report_header_id
				  AND (AERH.report_header_id IS NULL
				   OR (AERH.report_header_id IS NOT NULL
				  AND ((AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(AERH.source, AERH.workflow_approved_flag, AERH.report_header_id) NOT IN (''PAID'', ''INVOICED''))
				   OR (AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(AERH.source, AERH.workflow_approved_flag, AERH.report_header_id) IN (''INVOICED'')
				  AND AERH.reject_code IS NOT NULL)
				   OR (AERH.workflow_approved_flag IS NULL))))
                  AND ACA.card_reference_id = ICC.instrid(+)
				  AND ACA.employee_id = PEX.employee_id(+)
				  AND GLCC.code_combination_id = PEX.default_code_combination_id
				  AND FLVV.lookup_code(+) = ACCTA.sic_code
				  AND VC.lookup_code(+) = ACCTA.validate_code
				  AND NVL(ACCTA.validate_code, ''N'') = ''Y''
				  AND FLVV.enabled_flag(+) = ''Y''
				  AND ACPA.card_program_name LIKE ''%USB%''
				  AND FLVV.lookup_type(+) = ''USBANK_MCC''
				  AND ACCTA.merchant_name1 NOT LIKE ''%Corporate%''
				  AND SYSDATE BETWEEN NVL(FLVV.start_date_active, SYSDATE - 1)
								  AND NVL(FLVV.end_date_active, SYSDATE + 1)
				  AND ALC.lookup_type(+) = ''EXPENSE REPORT STATUS''
				  AND ALC.lookup_code(+) = AP_WEB_OA_ACTIVE_PKG.GETREPORTSTATUSCODE(AERH.source, AERH.workflow_approved_flag, AERH.report_header_id)
				  AND VC.lookup_type(+) = ''OIE_CC_VALIDATION_ERROR''
				  AND  NVL(ACCTA.category, ''BUSINESS'') NOT IN (''MATCHED'', ''CREDIT'')
				  AND TRUNC(transaction_date) > ''01-JAN-18''
				  AND ACCTA.org_id = ACPA.org_id';

    IF (p_card IS NOT NULL) THEN
      l_where := l_where ||' AND ACCTA.card_program_id = :P_CARD  ';
    END IF;

    IF (p_employee IS NOT NULL) THEN
      l_where := l_where ||' AND PEX.employee_id = :P_EMPLOYEE ';
    END IF;

    IF (p_manager IS NOT NULL) THEN
      l_where := l_where ||' AND XXCM_COMMON.GET_SUP_ID(PEX.employee_id) = :P_MANAGER  ' ;
   END IF;

    IF (p_posted_to_date IS NOT NULL) THEN
      l_where := l_where ||' AND ACCTA.posted_date >= TO_DATE(:P_POSTED_FROM_DATE,''YYYY/MM/DD HH24:MI:SS'')';
    END IF;

    IF (p_posted_from_date IS NOT NULL) THEN
      l_where := l_where ||' AND ACCTA.posted_date <= TO_DATE(:P_POSTED_TO_DATE,''YYYY/MM/DD HH24:MI:SS'')';
    END IF;

   l_query := l_select || l_where ;

    pl(l_query,'N');

    qryCtx := DBMS_XMLGEN.newContext(l_query);

    /*  Set the bind variables  */

    pl('Set Bind Variables');

    IF (p_card IS NOT NULL) THEN
       DBMS_XMLGEN.SETBINDVALUE(qryCtx, 'P_CARD', p_card);
    END IF;

   IF ( p_posted_from_date IS NOT NULL) THEN
      DBMS_XMLGEN.SETBINDVALUE(qryCtx, 'P_POSTED_FROM_DATE', p_posted_from_date);
   END IF;

   IF (p_posted_to_date IS NOT NULL) THEN
      DBMS_XMLGEN.SETBINDVALUE(qryCtx, 'P_POSTED_TO_DATE', p_posted_to_date);
   END IF;

   IF (p_employee IS NOT NULL) THEN
       DBMS_XMLGEN.SETBINDVALUE(qryCtx, 'P_EMPLOYEE', p_employee);
   END IF;

   IF (p_manager IS NOT NULL) THEN
      DBMS_XMLGEN.SETBINDVALUE(qryCtx, 'P_MANAGER', p_manager);
   END IF;

  /* Sets the name of the element enclosing the entire result */

  pl('dbms_xmlgen.setrowsettag');
  DBMS_XMLGEN.SETROWSETTAG(qryCtx, 'XXAP_US_CC_OUTSTANDING');

  /* Sets the name of the element enclosing each row of the result */

  pl('dbms_xmlgen.setrowtag');

  /* Set the null handling option - Leave out the tags for null values */

  pl('dbms_xmlgen.setnullhandling');
  DBMS_XMLGEN.SETNULLHANDLING(qryCtx, 0);

  /*  Generate the XML data to the result  */

  pl('dbms_xmlgen.get_xml');
  RESULT := DBMS_XMLGEN.GETXML(qryCtx);

  /*  Closes a given context and releases all resources associated
  with it, including the SQL cursor and bind and define buffers */

  DBMS_XMLGEN.CLOSECONTEXT(qryctx);

  /*  Call procedure to write the xml output to the bi report */

  WRITE_XML_OUTPUT(result);

  PL('END XXAP_BI_REPORTING_PUB.XXAP_US_CC_OUTSTANDING');

 EXCEPTION
      WHEN OTHERS THEN

      p_retcode := SQLCODE;
      p_errbuf  := SQLERRM;

      PL('Return Code = ' || p_retcode || ' ERROR: ' || p_errbuf);

      RAISE ;

END xxap_us_cc_outstanding;

/*  v1.1 END */

/****************************************************************/
 PROCEDURE xxap_dist_var_rep ( p_retcode      OUT NUMBER
                             ,p_errbuf       OUT VARCHAR2
                            )
 IS
  l_query                VARCHAR2(32767);
  l_select               VARCHAR2(8000);
  l_where                VARCHAR2(8000);
  l_group_by             VARCHAR2(4000);
  l_order_by             VARCHAR2(4000);
  qryCtx                 DBMS_XMLGEN.ctxHandle;
  result                 CLOB;

BEGIN
   pl('-- Begin XXAP Dist Var Report (xxap_bi_reporting_pub.xxap_dist_var_rep)--');
   l_query := 'SELECT ''Missing Lines'' Note,
       invoice_id,
       xxcm_common.get_org_name (org_id) OU,
       vendor_name,
       s.segment1 supplier_number,
       invoice_num,
       invoice_amount,
       invoice_date
  FROM apps.ap_invoices_all i, apps.ap_suppliers s
 WHERE     invoice_id NOT IN (SELECT invoice_id FROM ap_invoice_lines_all) --OU, inv num, supplier, number name , invoice amt ,
       AND cancelled_Date IS NULL
       AND s.vendor_id = i.vendor_id
UNION
SELECT ''Missing Dist'' Note,
       invoice_id,
       xxcm_common.get_org_name (org_id) OU,
       vendor_name,
       s.segment1 supplier_number,
       invoice_num,
       invoice_amount,
       invoice_date
  FROM apps.ap_invoices_all i, apps.ap_suppliers s
 WHERE invoice_id NOT IN
          (SELECT invoice_id FROM ap_invoice_distributions_all)
       AND cancelled_Date IS NULL
       AND s.vendor_id = i.vendor_id
UNION
SELECT ''Dist Var Amount'' Note,
       v.invoice_id,
       xxcm_common.get_org_name (v.org_id) OU,
       vendor_name,
       s.segment1 supplier_number,
       v.invoice_num,
       v.invoice_amount,
       v.invoice_date
  FROM (  SELECT DISTINCT xxcm_common.get_org_name (i.org_id) OU,
                          i.invoice_id,
                          invoice_amount invoice_amount,
                          SUM (d.amount) dist_amt
            FROM ap_invoices_all i, ap_invoice_distributions_all d
           WHERE i.invoice_id = d.invoice_id
                 AND payment_status_flag IN (''N'', ''P'')
        GROUP BY i.invoice_id, i.org_id, invoice_amount) t,
       ap_invoices_all v,
       ap_suppliers s
 WHERE (t.invoice_amount
        - NVL (ap_prepay_utils_pkg.get_prepaid_amount (v.invoice_id), 0)) !=
          dist_amt
       AND v.invoice_id = t.invoice_id
       AND cancelled_Date IS NULL
       AND s.vendor_id = v.vendor_id';

  pl(l_query,'N');
    qryCtx := DBMS_XMLGEN.newContext(l_query);


  /* Sets the name of the element enclosing the entire result */
  pl('dbms_xmlgen.setrowsettag');

  dbms_xmlgen.setrowsettag(qryCtx, 'XXAP_DIST_VAR_REP');
  /* Sets the name of the element enclosing each row of the result */
  pl('dbms_xmlgen.setrowtag');
  dbms_xmlgen.setrowtag(qryCtx,'XXAP_DIST_VAR_REP');

  /* Set the null handling option - Leave out the tags for null values */
  pl('dbms_xmlgen.setnullhandling');
  dbms_xmlgen.setnullhandling(qryCtx, 0);

  /*  Generate the XML data to the result  */
  pl('dbms_xmlgen.get_xml');
  result := DBMS_XMLGEN.getXML(qryCtx);

  /*  Closes a given context and releases all resources associated
  with it, including the SQL cursor and bind and define buffers */
  dbms_xmlgen.closecontext(qryctx);

--BC 20210216 handle no data found for the SQL case
fnd_file.put_line(fnd_file.log,'dbms_lob.getlength(result) : '||nvl(dbms_lob.getlength(result),0));
  If  nvl(dbms_lob.getlength(result),0)  = 0 Then 
      pl('Original XML SQL result no data!');
      qryCtx := DBMS_XMLGEN.newContext('select ''No Data Found!'' Note, to_number(null) Invoice_ID,to_char(null) OU,to_char(null) Vendor_Name,to_char(null) Supplier_Number,to_Char(null) Invoice_Num,to_number(null) Invoice_Amount,to_date(null) Invoice_Date from dual');
      dbms_xmlgen.setrowsettag(qryCtx, 'XXAP_DIST_VAR_REP');
      --dbms_xmlgen.setrowtag(qryCtx,'XXAP_DIST_VAR_REP');
	  dbms_xmlgen.setnullhandling(qryCtx, 0);
	  result := DBMS_XMLGEN.getXML(qryCtx);
      dbms_xmlgen.closecontext(qryctx);
  else 
	 pl('Original XML SQL result has data!');
  End If ;
 --BC 20210216 handle no data found for the SQL case 

  /*  Call procedure to write the xml output to the bi report */
  write_xml_output(result);
  pl('END xxap_bi_reporting_pub.ixxap_dist_var_rep');

 EXCEPTION
    WHEN OTHERS THEN
      p_retcode := sqlcode;
      p_errbuf  := sqlerrm;
      pl('Return Code = ' || p_retcode || ' ERROR: ' || p_errbuf);
      RAISE ;
END xxap_dist_var_rep;


/****************************************************************/
 PROCEDURE pl( p_str IN VARCHAR2
             , p_show_time IN VARCHAR2 DEFAULT 'Y')
 IS
    l_str   VARCHAR2(32000) := p_str;
    l_time  VARCHAR2(30) := TO_CHAR(sysdate, 'DD-MON-YY');
 BEGIN
    LOOP
       EXIT WHEN l_str IS NULL;
       IF p_show_time = 'Y' then
          fnd_file.put_line(fnd_file.log, l_time ||': '||substr( l_str, 1, 230 ));
       ELSE
          fnd_file.put_line(fnd_file.log, substr( l_str, 1, 250 ));
       END IF;
       l_str := substr( l_str, 251 );
    END LOOP;
 END pl;

/****************************************************************/
 PROCEDURE write_xml_output(p_xml_clob IN CLOB)
 IS

  l_clob_size   NUMBER;
  l_offset      NUMBER;
  l_chunk_size  INTEGER;
  l_chunk       VARCHAR2(32767);

 BEGIN

    /* get length of internal lob and open the destination file */
    l_clob_size := dbms_lob.getlength(p_xml_clob);
  pl('CLOB size xxap_boa_cc_outstanding'|| l_clob_size);

    IF (l_clob_size = 0) THEN

      return;

    end if;

    l_offset     := 1;
    l_chunk_size := 3000;

    /*  parse the clob and write the output */

    WHILE (l_clob_size > 0) LOOP

      l_chunk := dbms_lob.substr (p_xml_clob, l_chunk_size, l_offset);

      fnd_file.put(which => fnd_file.output,
                   buff  => l_chunk);

      l_clob_size := l_clob_size - l_chunk_size;
      l_offset    := l_offset + l_chunk_size;

    END LOOP;

    fnd_file.new_line(fnd_file.output,1);

  exception
    when others then
        fnd_file.put_line(fnd_file.LOG,'EXCEPTION: OTHERS process_clob');
        fnd_file.put_line(fnd_file.LOG,sqlcode);
        fnd_file.put_line(fnd_file.LOG,sqlerrm);
        raise;
 END write_xml_output;

END xxap_bi_reporting_pub;

/
