--------------------------------------------------------
--  File created - Wednesday-July-14-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body XXCM_BI_REPORTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXCM_BI_REPORTING_PUB" 
IS
/******************************************************************************************************
* -- 10/20/2013 - Jill DiLeva
* -- New procedures
* ---- xxbs_trx_vat_reg
* ---- xxgl_chart_of_accts_rpt
* ---- xxgl_manual_je_rpt
* ---- xxpa_incorrect_cur_rpt
*
* -- 11/17/2013 - Jill DiLeva
* -- New procedures
* ---- xxar_open_commit_asia_acr
* ---- xxpa_cost_asia_acr
*
* -- 3/3/2014 Jill DiLeva
* -- New function... submit_request_burst
* 10/10/2014  akaplan   Add apply_template
* 09/25/2015  Fujistu   For R12 upgrade, ra_customer is replaced with hz_parties and hz_cust_accounts in xxar_gst_rpt.
*                       And Added exchange_rate and functional currency amount has been added in report output.
*                       For R12 upgrade, Added Intercompany Segment in Procedure -xxgl_manual_je_rpt.
*                  For R12 upgrade, COA Chnages are done for procedure xxgl_curr_trial_bal and new filed is added YTD_LED_CURR
*                  For R12 upgrade, ap_tax_codes_all is replaced with zx_rates_b  for procedure xxap_gst_rpt and query is retuned
*                  and in 11i the Invoice line amount was populating double and it is rectified in R12.
*                  For R12 upgrade, ar_vat_tax_all_b is replaced with zx_rates_b  for procedure xxar_gst_rpt
* 09/28/2015  lying     Remove reference to REVIEW late cost status
* 9/28/2015  Jill Dileva - updates to submit_burst_request for R12
* 3/14/2016  AM          - remediation issue for tax join in xxap and xxar
* 06/15/2016 akaplan    Enh Req 1544 - R12 Remediate xxap_gst_rpt procedure.
* 08/21/2017 akaplan    WorkDay - Remediate request_burst to call custom bursting program to allow XML documents to be bursted
* 02/14/2018 akaplan    Add function to return standard stylesheet, setup no_data_found
* 10/17/2018 akaplan    Add exec_parallel function
* 05/24/2019 akaplan    Enh Req 2465: Add Sales Analysis BIP for easier HK access
* 07/11/2019 akaplan    Enh Req 2584: Add postage elements to sales analysis
*                       Remove obsolete functions (xxgl_chart_of_accts_rpt, xxpa_cost_asia_acr)
* 12/02/2019 akaplan    Enh Req 2606: Add TV Identifier to sales_analysis report
*
************************************************************************************************************/

 PROCEDURE pl( p_str IN VARCHAR2
             , p_show_time IN VARCHAR2 DEFAULT 'Y')
 IS
    l_str   VARCHAR2(32000) := p_str;
    l_time  VARCHAR2(30) := TO_CHAR(sysdate, 'DD-MON-YY HH24:MI:SS');
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

 -- Dynamically change or assign template to XML created by Concurrent manager job.
 FUNCTION apply_template (p_template VARCHAR2) RETURN BOOLEAN IS
 PRAGMA AUTONOMOUS_TRANSACTION;
    oRetStat BOOLEAN;
    v_appl_short_name VARCHAR2(5) := 'XXTM';
    l_conc_req_id     NUMBER := fnd_global.conc_request_id;

    CURSOR layout_cur IS
       select application_short_name, default_output_type, default_language, default_territory
         from xdo_templates_b
        where template_code = p_template
          and application_short_name = v_appl_short_name;

    layout_rec layout_cur%ROWTYPE;
 BEGIN
    update fnd_conc_pp_actions
       set argument2 = p_template
         , argument5 = (select default_output_type
                        from xdo_templates_b
                        where template_code = p_template
                          and application_short_name = v_appl_short_name)
    where action_type = 6
      and concurrent_request_id = l_conc_req_id;


    IF SQL%ROWCOUNT = 1 THEN
       commit;
       xxcm_common.write_log('Overriding template with '||p_template||' successful');
       RETURN TRUE;
    ELSE

       OPEN layout_cur;
       FETCH layout_cur INTO layout_rec;
       CLOSE layout_cur;

       insert into fnd_conc_pp_actions
              (concurrent_request_id, action_type, status_s_flag
              , status_w_flag, status_f_flag
              , last_update_date, last_updated_by
              , creation_date   , last_update_login
              , created_by
              , completed, sequence
              , argument1
              , argument2
              , argument3
              , argument4
              , argument5
              , ops_instance)
            values
               (fnd_global.conc_request_id, 6, 'Y'
               , 'Y', 'Y'
               , sysdate, FND_GLOBAL.user_id
               , sysdate, fnd_global.login_id
               , FND_GLOBAL.user_id
               , 'N', 1
               , layout_rec.application_short_name
               , p_template
               , layout_rec.default_language
               , layout_rec.default_territory
               , layout_rec.default_output_type
               , fnd_conc_global.ops_inst_num);

       oRetStat := fnd_request.add_layout(v_appl_short_name
                                         ,p_template
                                         ,layout_rec.default_language
                                         ,layout_rec.default_territory
                                         ,layout_rec.default_output_type);
       IF oRetStat THEN
          commit;
          xxcm_common.write_log('Adding template with '||p_template||' successful');
          RETURN TRUE;
       ELSE
          rollback;
          xxcm_common.write_log('Attempt to override template with '||p_template||' failed');
          RETURN FALSE;
       END IF;
    END IF;
 END apply_template;

 -- Dynamically change or assign printer to XML created by Concurrent manager job.
 FUNCTION apply_printer (p_printer VARCHAR2, p_copies NUMBER) RETURN BOOLEAN IS
 PRAGMA AUTONOMOUS_TRANSACTION;
    --oRetStat BOOLEAN;
    l_conc_req_id     NUMBER := fnd_global.conc_request_id;

    CURSOR printer_cur IS
       select printer_name
         from fnd_printer
        where printer_name = p_printer;

    printer_rec printer_cur%ROWTYPE;
 BEGIN
    update fnd_conc_pp_actions
       set number_of_copies = p_copies
    where action_type = 1
      and concurrent_request_id = l_conc_req_id;

    IF SQL%ROWCOUNT = 1 THEN
       commit;
       xxcm_common.write_log('Overriding printer with no of copies '||p_copies||' successful');
       RETURN TRUE;
    ELSE

       OPEN printer_cur;
       FETCH printer_cur INTO printer_rec;
       CLOSE printer_cur;

       IF printer_rec.printer_name is not null THEN
           insert into fnd_conc_pp_actions
                  (concurrent_request_id, action_type, status_s_flag
                  , status_w_flag, status_f_flag
                  , last_update_date, last_updated_by
                  , creation_date   , last_update_login
                  , created_by
                  , arguments
                  , completed, number_of_copies, sequence
                  , ops_instance)
                values
                   (fnd_global.conc_request_id, 1, 'Y'
                   , 'N', 'N'
                   , sysdate, FND_GLOBAL.user_id
                   , sysdate, fnd_global.login_id
                   , FND_GLOBAL.user_id
                   , printer_rec.printer_name
                   , 'N', p_copies, 1
                   , fnd_conc_global.ops_inst_num);

            commit;
            xxcm_common.write_log('Adding printer '||p_printer||' with no of copies '||p_copies||' successful');
            RETURN TRUE;
       ELSE
            rollback;
            xxcm_common.write_log('Overriding printer '||p_printer||' with no of copies '||p_copies||' failed');
            RETURN FALSE;
       END IF;
    END IF;
 END apply_printer;

 FUNCTION formatXMLDate (p_date DATE) RETURN VARCHAR2 IS
 BEGIN
   IF p_date IS NOT NULL THEN
      RETURN to_char(p_date,'YYYY-MM-DD')
          ||'T'||to_char(p_date,'HH24:MI:SS');
   ELSE
      RETURN NULL;
   END IF;
 END formatXMLDate;

 -- Convert XML to CLOB
 PROCEDURE write_formatted_xml(p_xml IN XMLTYPE)
 IS
    formatXML XMLTYPE;
 BEGIN

    -- This transformation is required to prevent the line from exceeding UNIX line lengths.
    formatXML := p_xml.transform(get_stylesheet);
    write_xml_output(formatXML.getclobval());

 END write_formatted_xml; -- XMLTYPE

 PROCEDURE write_xml_output(p_xml_clob IN CLOB)
 IS

  l_clob_size   NUMBER;
  l_offset      NUMBER;
  l_chunk_size  INTEGER;
  l_chunk       VARCHAR2(32767);
  ctr number := 0;

 BEGIN

    /* get length of internal lob and open the destination file */
    l_clob_size := dbms_lob.getlength(p_xml_clob);

    IF (l_clob_size = 0) THEN

      return;

    end if;

    l_offset     := 1;
    l_chunk_size := 3000;

    /*  parse the clob and write the output */

    WHILE (l_clob_size > 0) LOOP

    ctr := ctr + 1;
      l_chunk := dbms_lob.substr (p_xml_clob, l_chunk_size, l_offset);

      fnd_file.put(fnd_file.output,
                   l_chunk);

      l_clob_size := l_clob_size - l_chunk_size;
      l_offset    := l_offset + l_chunk_size;

    END LOOP;

    fnd_file.new_line(fnd_file.output,1);

  exception
    when others then
        xxcm_common.write_log('EXCEPTION: OTHERS process_clob');
        xxcm_common.write_log(sqlcode);
        xxcm_common.write_log(sqlerrm);
        xxcm_common.write_log(dbms_utility.format_error_backtrace);
        raise;
 END write_xml_output;

 FUNCTION get_stylesheet RETURN XMLTYPE IS
    v_stylesheet XMLTYPE;
 BEGIN
    v_stylesheet := xmltype.createxml(
        '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
            <xsl:template match="node()|@*">
               <xsl:copy>
                  <xsl:apply-templates select="node()|@*"/>
               </xsl:copy>
            </xsl:template>
        </xsl:stylesheet>');

    RETURN v_stylesheet;
 END get_stylesheet;

 -- Fail procedure if no records were found
 PROCEDURE data_exists ( p_rowcount NUMBER ) IS
   bRetVal BOOLEAN;
 BEGIN
   xxcm_common.write_log(chr(10)||'Query generated '||nvl(p_rowcount,0)||' row(s)'||chr(10));
   IF nvl(p_rowcount,0) = 0 THEN
      bRetVal := fnd_concurrent.set_completion_status( status  => 'WARNING'
                                                     , message => 'No data found'
                                                     );
      RAISE NO_DATA_FOUND;
   END IF;
END data_exists;

 PROCEDURE xxar_gst_rpt (p_retcode       OUT NUMBER
                        ,p_errbuf        OUT VARCHAR2
                        ,p_trx_class     IN  VARCHAR2
                        ,p_gl_date_low   IN  VARCHAR2
                        ,p_gl_date_high  IN  VARCHAR2
                        ,p_trx_date_low  IN  VARCHAR2
                        ,p_trx_date_high IN  VARCHAR2
                        ,p_tax_code_low  IN  VARCHAR2
                        ,p_tax_code_high IN  VARCHAR2
                        ,p_currency_low  IN  VARCHAR2
                        ,p_currency_high IN  VARCHAR2
                        ,p_posted_status IN  VARCHAR2
                        ,p_org_id        IN  NUMBER)
IS

  l_query                VARCHAR2(32767);
  l_select               VARCHAR2(8000);
  l_where                VARCHAR2(8000);
  l_group_by             VARCHAR2(4000);
  l_order_by             VARCHAR2(4000);
  qryCtx                 DBMS_XMLGEN.ctxHandle;
  result                 CLOB;

BEGIN
   pl('-- Begin XXAR GST Report for HK/SG(xxcm_bi_reporting_pub.xxar_gst_rpt)--');
   pl('Input Parameters:  ');
   pl('    Transaction Class        = ' || p_trx_class);
   pl('    GL Date Low              = ' || p_gl_date_low);
   pl('    GL Date High             = ' || p_gl_date_high);
   pl('    Trx Date Low             = ' || p_trx_date_low);
   pl('    Trx Date High            = ' || p_trx_date_high);
   pl('    Tax Code Low             = ' || p_tax_code_low);
   pl('    Tax Code High            = ' || p_tax_code_high);
   pl('    Currency Code Low        = ' || p_currency_low);
   pl('    Currency Code High       = ' || p_currency_high);
   pl('    Posted Status            = ' || p_posted_status);
   pl('    Org ID                   = ' || p_org_id);

    -- Build the report xml

    --Added for R12 Upgrade

     l_select :=
     'SELECT rctta.name transaction_class
      ,    trx.trx_date
      ,    trx.trx_number
      ,    rc.party_name customer_name
      ,    trx.invoice_currency_code
      ,    SUM(trx_line.extended_amount) line_amt
      ,    SUM(tax_line.extended_amount) tax_amt
      ,    (SUM(trx_line.extended_amount) + SUM(tax_line.extended_amount)) total_inv_amt
       ,   substr(tax.tax_rate_code, 1,30)  tax_rate_code
      ,    dist.gl_date
      ,    trx.exchange_rate exchange_rate
      ,   ((SUM(trx_line.extended_amount) + SUM(tax_line.extended_amount)) * trx.exchange_rate) Functional_currency_amount
           FROM ra_cust_trx_types_all rctta
      ,    ra_customer_trx_all trx
      ,    ar_payment_schedules_all apsa
      ,    hz_parties  rc
      ,    hz_cust_accounts   cust_acct
      ,    ra_customer_trx_lines_all trx_line
      ,    ra_customer_trx_lines_all tax_line
      ,    zx_rates_b tax
      ,    ra_cust_trx_line_gl_dist_all dist
      ,    hz_parties hp
     ';

     l_where :=
     ' WHERE apsa.customer_trx_id = trx.customer_trx_id
       AND rctta.cust_trx_type_id = trx.cust_trx_type_id
       AND trx.org_id = :P_ORG_ID
       AND apsa.customer_id = cust_acct.cust_account_id
       AND cust_acct.party_id = rc.party_id
       AND (trx.customer_trx_id = trx_line.customer_trx_id
       AND trx_line.line_type = ''LINE'')
       AND (trx.customer_trx_id = tax_line.customer_trx_id
       AND tax_line.line_type = ''TAX''
       AND tax_line.vat_tax_id = tax.tax_rate_id)
       AND trx_line.customer_trx_line_id = tax_line.link_to_cust_trx_line_id
       AND hp.party_id = rc.party_id
       AND UPPER(hp.party_type) = ''ORGANIZATION''
       AND dist.customer_trx_id = trx.customer_trx_id
       AND dist.account_class = ''REC''
       AND dist.latest_rec_flag = ''Y''
       AND dist.account_set_flag = ''N''
    ';

    IF (p_currency_low IS NOT NULL) THEN
       l_where := l_where ||' AND trx.invoice_currency_code >= :P_CURRENCY_LOW';
    END IF;

    IF (p_currency_high IS NOT NULL) THEN
       l_where := l_where ||' AND trx.invoice_currency_code <= :P_CURRENCY_HIGH';
    END IF;

    IF (p_trx_date_low IS NOT NULL) THEN
      l_where := l_where ||' AND trx.trx_date >= TO_DATE(:P_TRX_DATE_LOW,''YYYY/MM/DD HH24:MI:SS'')';
    END IF;

    IF (p_trx_date_high IS NOT NULL) THEN
      l_where := l_where ||' AND trx.trx_date <= TO_DATE(:P_TRX_DATE_HIGH,''YYYY/MM/DD HH24:MI:SS'')';
    END IF;

    --l_where := l_where || ' AND tax.vat_tax_id = tax_line.vat_tax_id '; --Commented for R12 Upgrade

    l_where := l_where || ' AND tax.tax_rate_id = tax_line.vat_tax_id ';  --Added for R12 Upgrade

    IF (p_tax_code_low IS NOT NULL) THEN
      --l_where := l_where ||' AND tax.tax_code >= :P_TAX_CODE_LOW ';       --Commented for R12 Upgrade
        l_where := l_where ||' AND tax.tax_rate_code >= :P_TAX_CODE_LOW ';  --Added for R12 Upgrade
    END IF;

    IF (p_tax_code_high IS NOT NULL) THEN
      --l_where := l_where ||' AND tax.tax_code <= :P_TAX_CODE_HIGH ';      --Commented for R12 Upgrade
        l_where := l_where ||' AND tax.tax_rate_code <= :P_TAX_CODE_HIGH '; --Added for R12 Upgrade
    END IF;

    IF (p_posted_status = 'POSTED') THEN
        l_where := l_where || ' AND dist.gl_posted_date IS NOT NULL ';
    ELSIF (p_posted_status = 'UNPOSTED') THEN
        l_where := l_where || ' AND dist.gl_posted_date IS NULL ';
    END IF;

    IF (p_trx_class IS NOT NULL) THEN
      l_where := l_where ||' AND rctta.type = :P_TRX_CLASS';
    END IF;

    IF (p_gl_date_low IS NOT NULL) THEN
       l_where := l_where ||' AND dist.gl_date >= TO_DATE(:P_GL_DATE_LOW,''YYYY/MM/DD HH24:MI:SS'')';
    END IF;

    IF (p_gl_date_high IS NOT NULL) THEN
       l_where := l_where ||' AND dist.gl_date <= TO_DATE(:P_GL_DATE_HIGH,''YYYY/MM/DD HH24:MI:SS'')';
    END IF;


    --Added for R12 Upgrade

       l_group_by :=
      ' GROUP BY rctta.name
        ,trx.trx_date
        ,trx.trx_number
        ,rc.party_name
        ,trx.invoice_currency_code
        ,tax.tax_rate_code
        ,dist.gl_date
        ,trx.customer_trx_id
        ,rctta.type
        ,trx.exchange_rate
      ';

    l_order_by :=
      ' ORDER BY rctta.name
        ,tax.tax_rate_code
        ,trx.invoice_currency_code
        ,trx.trx_date
        ,trx.trx_number
        ,rc.party_name
        ,SUM(trx_line.extended_amount)
        ,SUM(tax_line.extended_amount)
        ,(SUM(trx_line.extended_amount) + SUM(tax_line.extended_amount))
        ,dist.gl_date
        ,trx.exchange_rate';

    l_query := l_select || l_where || l_group_by || l_order_by;

    pl(l_query,'N');
    qryCtx := DBMS_XMLGEN.newContext(l_query);

    /*  Set the bind variables  */
    pl('Set Bind Variables');
    dbms_xmlgen.setbindvalue(qryCtx, 'P_ORG_ID', p_org_id);

    IF (p_trx_class IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_TRX_CLASS', p_trx_class);
    END IF;

    IF (p_gl_date_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_GL_DATE_LOW', p_gl_date_low);
    END IF;

    IF (p_gl_date_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_GL_DATE_HIGH', p_gl_date_high);
    END IF;

    IF (p_trx_date_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_TRX_DATE_LOW', p_trx_date_low);
    END IF;

    IF (p_trx_date_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_TRX_DATE_HIGH', p_trx_date_high);
    END IF;

    IF (p_tax_code_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_TAX_CODE_LOW', p_tax_code_low);
    END IF;

    IF (p_tax_code_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_TAX_CODE_HIGH', p_tax_code_high);
    END IF;

    IF (p_currency_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_CURRENCY_LOW', p_currency_low);
    END IF;

    IF (p_currency_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_CURRENCY_HIGH', p_currency_high);
    END IF;

  /* Sets the name of the element enclosing the entire result */
  pl('dbms_xmlgen.setrowsettag');
  dbms_xmlgen.setrowsettag(qryCtx, 'XXAR_GST');

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

--  insert into xxcust_temp_clob_tab(result) values (result);

  /*  Call procedure to write the xml output to the bi report */
  write_xml_output(result);
  pl('END xxcm_bi_reporting_pub.xxar_gst_rpt');

 EXCEPTION
    WHEN OTHERS THEN
      p_retcode := sqlcode;
      p_errbuf  := sqlerrm;
      pl('Return Code = ' || p_retcode || ' ERROR: ' || p_errbuf);
      RAISE ;
 END xxar_gst_rpt;

 PROCEDURE xxap_gst_rpt (p_retcode       OUT NUMBER
                        ,p_errbuf        OUT VARCHAR2
                        ,p_invoice_type  IN  VARCHAR2
                        ,p_gl_date_low   IN  VARCHAR2
                        ,p_gl_date_high  IN  VARCHAR2
                        ,p_trx_date_low  IN  VARCHAR2
                        ,p_trx_date_high IN  VARCHAR2
                        ,p_tax_code_low  IN  VARCHAR2
                        ,p_tax_code_high IN  VARCHAR2
                        ,p_currency_low  IN  VARCHAR2
                        ,p_currency_high IN  VARCHAR2
                        ,p_posted_status IN  VARCHAR2
                        ,p_org_id        IN  NUMBER)
IS

  v_rowcount             NUMBER;
  l_query                VARCHAR2(32767);
  l_select               VARCHAR2(8000);
  l_where                VARCHAR2(8000);
  l_group_by             VARCHAR2(4000);
  l_order_by             VARCHAR2(4000);
  qryCtx                 DBMS_XMLGEN.ctxHandle;
  result                 CLOB;

BEGIN
   xxcm_common.write_log('-- Begin XXAP GST Report for HK/SG(xxcm_bi_reporting_pub.xxap_gst_rpt)--');
   xxcm_common.write_log('Input Parameters:  ');
   xxcm_common.write_log('    Invoice Type             = ' || p_invoice_type);
   xxcm_common.write_log('    GL Date Low              = ' || p_gl_date_low);
   xxcm_common.write_log('    GL Date High             = ' || p_gl_date_high);
   xxcm_common.write_log('    Trx Date Low             = ' || p_trx_date_low);
   xxcm_common.write_log('    Trx Date High            = ' || p_trx_date_high);
   xxcm_common.write_log('    Tax Code Low             = ' || p_tax_code_low);
   xxcm_common.write_log('    Tax Code High            = ' || p_tax_code_high);
   xxcm_common.write_log('    Currency Code Low        = ' || p_currency_low);
   xxcm_common.write_log('    Currency Code High       = ' || p_currency_high);
   xxcm_common.write_log('    Posted Status            = ' || p_posted_status);
   xxcm_common.write_log('    Org ID                   = ' || p_org_id);

   -- Build the report xml
   /**************************************************************************
   * NOTE: This query is flawed, but a decision was made to not remediate as *
   *       it is not causing an immediate problem.                           *
   *       Lines and Tax lines should be summed independently.               *
   *       As it is currently written, the line amount will be multipled by  *
   *       the number of tax lines                                           *
   *       IE: if there are two tax lines, the line amount will be doubled.  *
   ***************************************************************************/

   l_select := q'"
      select api.invoice_type_lookup_code invoice_type
           , api.invoice_date
           , api.invoice_num
           , s.vendor_name                 supplier_name
           , api.invoice_currency_code
           , SUM(apid.amount)              line_amt
           , nvl(DECODE(api.source, 'Manual Invoice Entry', api.total_tax_amount, SUM(nvl(apid_tax.amount,0))),0) tax_amt
           , SUM(apid.amount) + nvl(DECODE(api.source, 'Manual Invoice Entry', api.total_tax_amount, SUM(nvl(apid_tax.amount,0))),0) invoice_amt
           , NVL(api.amount_paid,0)        amt_pd
           , apid_tax.tax_rate_code        vat_code
           , api.gl_date
           , api.description
           , api.cancelled_date
      FROM ap_invoices_all api
         JOIN ap_invoice_lines_all apid ON ( apid.invoice_id = api.invoice_id
                                         AND apid.line_type_lookup_code != 'TAX')
         LEFT JOIN ap_invoice_lines_all apid_tax ON ( apid_tax.invoice_id = api.invoice_id
                                                  AND apid_tax.line_type_lookup_code = 'TAX'
                                                    )
         JOIN zx_rates_b aptc ON ( aptc.tax_rate_id = apid_tax.tax_rate_id )
         JOIN ap_suppliers s ON ( s.vendor_id = api.vendor_id )
      WHERE api.org_id = :P_ORG_ID
         AND exists (SELECT dist.invoice_id
                     FROM ap_invoice_distributions_all dist
                     WHERE dist.posted_flag = DECODE(:P_POSTED_STATUS,'Posted','Y','N')
                       AND apid.invoice_id= dist.invoice_id and apid.org_id = dist.org_id )"';

    IF (p_currency_low IS NOT NULL) THEN
       l_where := l_where ||chr(10)||' AND api.invoice_currency_code >= :P_CURRENCY_LOW ';
    END IF;

    IF (p_currency_high IS NOT NULL) THEN
       l_where := l_where ||chr(10)||' AND api.invoice_currency_code <= :P_CURRENCY_HIGH ';
    END IF;

    IF (p_trx_date_low IS NOT NULL) THEN
      l_where := l_where ||chr(10)||' AND api.invoice_date >= TO_DATE(:P_TRX_DATE_LOW,''YYYY/MM/DD HH24:MI:SS'') ';
    END IF;

    IF (p_trx_date_high IS NOT NULL) THEN
      l_where := l_where ||chr(10)||' AND api.invoice_date <= TO_DATE(:P_TRX_DATE_HIGH,''YYYY/MM/DD HH24:MI:SS'') ';
    END IF;

    IF (p_tax_code_low IS NOT NULL) THEN
      IF (p_tax_code_high IS NOT NULL) THEN
         l_where := l_where ||chr(10)||' AND DECODE(api.source, ''Manual Invoice Entry'', api.vat_code, aptc.name) >= :P_TAX_CODE_LOW ';
      END IF;
    END IF;

    IF (p_tax_code_high IS NOT NULL) THEN
      l_where := l_where ||chr(10)||' AND DECODE(api.source, ''Manual Invoice Entry'', api.vat_code, aptc.name) <= :P_TAX_CODE_HIGH ';
    END IF;

    IF (p_invoice_type IS NOT NULL) THEN
      l_where := l_where ||chr(10)||' AND api.invoice_type_lookup_code = :P_INVOICE_TYPE ';
    END IF;

    IF (p_gl_date_low IS NOT NULL) THEN
       l_where := l_where ||chr(10)||' AND api.gl_date >= TO_DATE(:P_GL_DATE_LOW,''YYYY/MM/DD HH24:MI:SS'') ';
    END IF;

    IF (p_gl_date_high IS NOT NULL) THEN
       l_where := l_where ||chr(10)||' AND api.gl_date <= TO_DATE(:P_GL_DATE_HIGH,''YYYY/MM/DD HH24:MI:SS'') ';
    END IF;

    l_group_by := chr(10)||' group by api.invoice_type_lookup_code
       , s.vendor_name
       , api.invoice_date
       , api.invoice_num
       , api.vendor_id
       , api.invoice_currency_code
       , api.source
       , apid_tax.tax_rate_code
       , api.total_tax_amount
       , api.amount_paid
       , api.gl_date
       , api.description
       , api.cancelled_date';

    l_order_by := chr(10)||
     ' order by api.invoice_type_lookup_code
       , apid_tax.tax_rate_code
       , api.invoice_currency_code
       , api.invoice_date
       , api.invoice_num ';

    l_query := l_select || l_where || l_group_by || l_order_by;

    xxcm_common.write_log(l_query,'N');
    qryCtx := DBMS_XMLGEN.newContext(l_query);

    /*  Set the bind variables  */
    xxcm_common.write_log('Set Bind Variables');
    dbms_xmlgen.setbindvalue(qryCtx, 'P_ORG_ID', p_org_id);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_POSTED_STATUS', p_posted_status);

    IF (p_invoice_type IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_INVOICE_TYPE', p_invoice_type);
    END IF;

    IF (p_gl_date_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_GL_DATE_LOW', p_gl_date_low);
    END IF;

    IF (p_gl_date_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_GL_DATE_HIGH', p_gl_date_high);
    END IF;

    IF (p_trx_date_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_TRX_DATE_LOW', p_trx_date_low);
    END IF;

    IF (p_trx_date_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_TRX_DATE_HIGH', p_trx_date_high);
    END IF;

    IF (p_tax_code_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_TAX_CODE_LOW', p_tax_code_low);
    END IF;

    IF (p_tax_code_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_TAX_CODE_HIGH', p_tax_code_high);
    END IF;

    IF (p_currency_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_CURRENCY_LOW', p_currency_low);
    END IF;

    IF (p_currency_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_CURRENCY_HIGH', p_currency_high);
    END IF;

  /* Sets the name of the element enclosing the entire result */
  xxcm_common.write_log('dbms_xmlgen.setrowsettag');
  dbms_xmlgen.setrowsettag(qryCtx, 'XXAP_GST');

  /* Sets the name of the element enclosing each row of the result */
  xxcm_common.write_log('dbms_xmlgen.setrowtag');
  --dbms_xmlgen.setrowtag(qryCtx,'');

  /* Set the null handling option - Leave out the tags for null values */
  xxcm_common.write_log('dbms_xmlgen.setnullhandling');
  dbms_xmlgen.setnullhandling(qryCtx, 0);

  /*  Generate the XML data to the result  */
  xxcm_common.write_log('dbms_xmlgen.get_xml');
  result := DBMS_XMLGEN.getXML(qryCtx);

  --  Determine number of rows generated by process
  v_rowcount := dbms_xmlgen.getNumRowsProcessed(qryctx);
  xxcm_common.write_log(chr(10)||'Query generated '||v_rowcount||' row(s)'||chr(10));


  /*  Closes a given context and releases all resources associated
  with it, including the SQL cursor and bind and define buffers */
  dbms_xmlgen.closecontext(qryctx);

--  insert into xxcust_temp_clob_tab(result) values (result);

  /*  Call procedure to write the xml output to the bi report */
  write_xml_output(result);
  xxcm_common.write_log('END xxcm_bi_reporting_pub.xxap_gst_rpt');

 EXCEPTION
    WHEN OTHERS THEN
      p_retcode := sqlcode;
      p_errbuf  := sqlerrm;
      xxcm_common.write_log('Return Code = ' || p_retcode || ' ERROR: ' || p_errbuf);
      RAISE ;
END xxap_gst_rpt;

PROCEDURE xxgl_curr_trial_bal (p_retcode       OUT NUMBER
                              ,p_errbuf        OUT VARCHAR2
                              ,p_period_name   IN  VARCHAR2
							  ,p_access_set_id IN  NUMBER
							  ,p_ledger_short_name   IN  VARCHAR2)
IS

  l_query                VARCHAR2(32767);
  l_select               VARCHAR2(8000);
  l_where                VARCHAR2(8000);
  l_group_by             VARCHAR2(4000);
  l_order_by             VARCHAR2(4000);
  qryCtx                 DBMS_XMLGEN.ctxHandle;
  result                 CLOB;

BEGIN
   pl('-- Begin XXGL Currency Trial Balance Report (xxcm_bi_reporting_pub.xxgl_curr_trial_bal)--');
   pl('Input Parameters:  ');
   pl('    Period Name              = ' || p_period_name);
   pl('    Ledger Short             = ' || p_ledger_short_name);

    -- Build the report xml
        l_query :=
            'SELECT gsob.short_name "SOB_SHORT_NAME",
                    gcc.segment1 "LE",
                    gcc.segment2 "PL",
                    gcc.segment3 "SITE",
                    gcc.segment4 "CC",
                    gcc.segment5 "ACCT",
                    gcc.segment6 "IC",
                    gb.currency_code "CURRENCY",
                    gb.period_name "PERIOD",
                    (nvl(gb.BEGIN_BALANCE_DR_beq,0) - nvl(gb.BEGIN_BALANCE_CR_beq,0) + nvl(gb.PERIOD_NET_DR_beq,0) - nvl(gb.PERIOD_NET_CR_beq,0)) "YTD_BALANCE_LEDGER_CURRENCY",
                    (nvl(gb.begin_balance_dr,0) - nvl(gb.begin_balance_cr,0) + nvl(gb.period_net_dr,0) - nvl(gb.period_net_cr,0)) "END_BALANCE"
             FROM gl_balances gb,
                  gl_code_combinations gcc,
                  gl_ledgers gsob
             WHERE gb.code_combination_id = gcc.code_combination_id
             AND   gb.ledger_id = gsob.ledger_id
             AND   gsob.chart_of_accounts_id = 50388 --#R12_ACCOUNTING_FLEXFIELD
             AND   gb.period_name = :P_PERIOD_NAME
             AND   gb.actual_flag = ''A''
             AND   gb.translated_flag = ''R''
             AND   gb.currency_code <> ''STAT''
             AND   (gb.ledger_id, gb.currency_code) NOT IN
                     (SELECT ledger_id, currency_code
                      FROM gl_ledgers )
             AND   (gb.begin_balance_dr-gb.begin_balance_cr+gb.period_net_dr-gb.period_net_cr) <> 0
			 AND   gsob.short_name = :P_LEDGER_SHORT_NAME
             --
             UNION
             --------------------------------
             -- Entered functional balances
             (
             SELECT SOB_SHORT_NAME,
                    LE,
                    PL,
                    SITE,
                    CC,
                    ACCT,
                    IC,
                    CURRENCY,
                    PERIOD,
                    YTD_BALANCE_LEDGER_CURRENCY,
                    SUM(END_BALANCE)
             FROM
             (--Functional Currency balance
              SELECT gsob.short_name "SOB_SHORT_NAME",
                     gcc.segment1 "LE",
                     gcc.segment2 "PL",
                     gcc.segment3 "SITE",
                     gcc.segment4 "CC",
                     gcc.segment5 "ACCT",
                     gcc.segment6 "IC",
                     gb.currency_code "CURRENCY",
                     gb.period_name "PERIOD",
                     NULL "YTD_BALANCE_LEDGER_CURRENCY",
                     (nvl(gb.begin_balance_dr,0) - nvl(gb.begin_balance_cr,0) + nvl(gb.period_net_dr,0) - nvl(gb.period_net_cr,0)) "END_BALANCE"
              FROM gl_balances gb,
                   gl_code_combinations gcc,
                   gl_ledgers gsob
              WHERE gb.code_combination_id = gcc.code_combination_id
              AND   gb.ledger_id = gsob.ledger_id
              AND   gsob.chart_of_accounts_id = 50388 --#R12_ACCOUNTING_FLEXFIELD
              AND   gb.period_name = :P_PERIOD_NAME
              AND   gb.actual_flag = ''A''
              AND   gb.translated_flag is null
              AND   gb.currency_code <> ''STAT''
              AND   (gb.ledger_id, gb.currency_code) in
                      (SELECT ledger_id, currency_code
                       FROM  gl_ledgers )
              AND   (gb.begin_balance_dr-gb.begin_balance_cr+gb.period_net_dr-gb.period_net_cr) <> 0
			  AND   gsob.short_name = :P_LEDGER_SHORT_NAME
              UNION
              -- Subtract Foreign Currency accounted amounts
              SELECT gsob.short_name "SOB_SHORT_NAME",
                     gcc.segment1 "LE",
                     gcc.segment2 "PL",
                     gcc.segment3 "SITE",
                     gcc.segment4 "CC",
                     gcc.segment5 "ACCT",
                     gcc.segment6 "IC",
                     gsob.currency_code "CURRENCY",
                     gb.period_name "PERIOD",
                     null "YTD_BALANCE_LEDGER_CURRENCY",
                     -1*(nvl(gb.begin_balance_dr_beq,0) - nvl(gb.begin_balance_cr_beq,0) + nvl(gb.period_net_dr_beq,0) - nvl(gb.period_net_cr_beq,0)) "END_BALANCE"
              FROM gl_balances gb,
                   gl_code_combinations gcc,
                   gl_ledgers gsob
              WHERE gb.code_combination_id = gcc.code_combination_id
              AND   gb.ledger_id = gsob.ledger_id
              AND   gsob.chart_of_accounts_id = 50388 --#R12_ACCOUNTING_FLEXFIELD
              AND   gb.period_name = :P_PERIOD_NAME
              AND   gb.actual_flag = ''A''
              AND   gb.translated_flag = ''R''
              AND   gb.currency_code <> ''STAT''
              AND   (gb.ledger_id, gb.currency_code) not in
                      (SELECT ledger_id, currency_code
                       FROM  gl_ledgers )
              AND   (gb.begin_balance_dr-gb.begin_balance_cr+gb.period_net_dr-gb.period_net_cr) <> 0
			  AND   gsob.short_name = :P_LEDGER_SHORT_NAME
             )
             GROUP BY SOB_SHORT_NAME,
                      LE,
                      PL,
                      SITE,
                      CC,
                      ACCT,
                      IC,
                      CURRENCY,
                      PERIOD,
                      YTD_BALANCE_LEDGER_CURRENCY
             HAVING SUM(END_BALANCE) <> 0
             )
             ORDER BY 1, 7, 2, 3, 4, 5, 6, 8';

    pl(l_query,'N');
    qryCtx := DBMS_XMLGEN.newContext(l_query);

    /*  Set the bind variables  */
    pl('Set Bind Variables');
    dbms_xmlgen.setbindvalue(qryCtx, 'P_PERIOD_NAME', p_period_name);
	dbms_xmlgen.setbindvalue(qryCtx, 'P_LEDGER_SHORT_NAME', p_ledger_short_name);

  /* Sets the name of the element enclosing the entire result */
  pl('dbms_xmlgen.setrowsettag');
  dbms_xmlgen.setrowsettag(qryCtx, 'XXGL_CURR_TRIAL_BAL');

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

--  insert into xxcust_temp_clob_tab(result) values (result);

  /*  Call procedure to write the xml output to the bi report */
  write_xml_output(result);
  pl('END xxcm_bi_reporting_pub.xxgl_curr_trial_bal');

 EXCEPTION
    WHEN OTHERS THEN
      p_retcode := sqlcode;
      p_errbuf  := sqlerrm;
      pl('Return Code = ' || p_retcode || ' ERROR: ' || p_errbuf);
      RAISE ;
END xxgl_curr_trial_bal;

PROCEDURE xxbs_man_draftrev_rpt(p_retcode       OUT NUMBER
                               ,p_errbuf        OUT VARCHAR2)
IS

  l_query                VARCHAR2(32767);
  l_select               VARCHAR2(8000);
  l_where                VARCHAR2(8000);
  l_group_by             VARCHAR2(4000);
  l_order_by             VARCHAR2(4000);
  qryCtx                 DBMS_XMLGEN.ctxHandle;
  result                 CLOB;

  v_operating_unit            number;

  --BC 20210115
  --v_late_cost_status_id           xxbs_customer_trx_lines.late_cost_status_id%type;
  --v_current_status_id           xxbs_customer_trx.current_status_id%type;
  --v_void_status_id           xxbs_customer_trx.current_status_id%type;
  --v_intercompany_status_id    xxbs_customer_trx.current_status_id%type;
  --v_dummy_status_id            xxbs_customer_trx.current_status_id%type;

  v_period1                     gl_periods.period_name%TYPE;
  v_period2                     gl_periods.period_name%TYPE;
  v_period3                     gl_periods.period_name%TYPE;
  v_period4                     gl_periods.period_name%TYPE;

BEGIN
--BC 20210115 
/*
   pl('-- Begin XXBS Manual Draft Revenue Projects List (xxcm_bi_reporting_pub.xxbs_man_draftrev_rpt)--');
   pl('Input Parameters:  ');

   --'GET OPERATING UNIT';
   select NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99)
   into v_operating_unit
   from dual;

   --'FIND INVOICE STATUS ID';
   select ffv.flex_value_id
   into   v_current_status_id
   from   fnd_flex_value_sets ffvs,
   fnd_flex_values ffv
   where  ffvs.flex_value_set_name = 'XXBS_EVENTS'
   and    ffv.flex_value_set_id = ffvs.flex_value_set_id
   and    ffv.attribute2 = 'STATUS'
   and    ffv.flex_value = 'RECEIVED BY AR';

   -- 'FIND VOID STATUS ID';
   select ffv.flex_value_id
   into   v_void_status_id
   from   fnd_flex_value_sets ffvs,
          fnd_flex_values ffv
   where  ffvs.flex_value_set_name = 'XXBS_EVENTS'
   and    ffv.flex_value_set_id = ffvs.flex_value_set_id
   and    ffv.attribute2 = 'STATUS'
   and    ffv.flex_value = 'VOID';


   --'FIND INTERCOMPANY STATUS ID';
   select ffv.flex_value_id
   into   v_intercompany_status_id
   from   fnd_flex_value_sets ffvs,
   fnd_flex_values ffv
   where  ffvs.flex_value_set_name = 'XXBS_EVENTS'
   and    ffv.flex_value_set_id = ffvs.flex_value_set_id
   and    ffv.attribute2 = 'STATUS'
   and    ffv.flex_value = 'INTERCOMPANY';

   --'FIND DUMMY STATUS ID';
   select ffv.flex_value_id
   into   v_dummy_status_id
   from   fnd_flex_value_sets ffvs,
   fnd_flex_values ffv
   where  ffvs.flex_value_set_name = 'XXBS_EVENTS'
   and    ffv.flex_value_set_id = ffvs.flex_value_set_id
   and    ffv.attribute2 = 'STATUS'
   and    ffv.flex_value = 'DUMMY';

   --'FIND LATE COST REVIEW STATUS';
   select ffv.flex_value_id
   into   v_late_cost_status_id
   from   fnd_flex_value_sets ffvs,
   fnd_flex_values ffv
   where  ffvs.flex_value_set_name = 'XXBS_LATE_COST_STATUSES'
   and    ffv.flex_value_set_id = ffvs.flex_value_set_id
   and    ffv.flex_value = 'REVIEW';

   -- Get periods to exclude
   SELECT TO_CHAR(sysdate,'MON-RR'), TO_CHAR(ADD_MONTHS(sysdate,-1),'MON-RR'), TO_CHAR(ADD_MONTHS(sysdate,-2),'MON-RR'),
          TO_CHAR(ADD_MONTHS(sysdate,-3),'MON-RR')
   INTO v_period1, v_period2, v_period3, v_period4
   FROM DUAL;


    -- Build the report xml
    l_query :=
        'SELECT DISTINCT
            xct.period_name
                ,       p.segment1   project_number
                ,       p.name
                ,       xct.ar_trx_number
         FROM pa_projects_all p,
              xxbs_customer_trx xct,
              xxbs_customer_trx_lines xctl,
              pa_project_statuses ps,
              pa_project_status_controls psc
         WHERE p.org_id = :P_OPERATING_UNIT
         AND xctl.project_id = p.project_id
         AND xct.current_status_id in
         (
           :P_CURRENT_STATUS_ID,
           :P_VOID_STATUS_ID,
           :P_DUMMY_STATUS_ID,
           :P_INTERCOMPANY_STATUS_ID
         )
         AND xct.period_name NOT IN (:P_PERIOD1, :P_PERIOD2, :P_PERIOD3, :P_PERIOD4)
         AND xctl.customer_trx_id = xct.customer_trx_id
         -- AND nvl(xctl.late_cost_status_id, -111111) != :P_LATE_COST_STATUS_ID
         AND nvl(xctl.pa_processed_flag, ''N'') in (''N'', ''I'')
         AND p.project_status_code = ps.project_status_code
         AND ps.status_type = ''PROJECT''
         AND ps.project_status_code = psc.project_status_code
         AND psc.action_code = ''GENERATE_REV''
         AND psc.enabled_flag = ''Y''
         ORDER BY 1, 2';

    pl(l_query,'N');
    qryCtx := DBMS_XMLGEN.newContext(l_query);

    ----  Set the bind variables  ----
    pl('Set Bind Variables');
    dbms_xmlgen.setbindvalue(qryCtx, 'P_PERIOD1', v_period1);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_PERIOD2', v_period2);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_PERIOD3', v_period3);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_PERIOD4', v_period4);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_OPERATING_UNIT', v_operating_unit);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_LATE_COST_STATUS_ID', v_late_cost_status_id);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_CURRENT_STATUS_ID', v_current_status_id);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_VOID_STATUS_ID', v_void_status_id);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_DUMMY_STATUS_ID', v_dummy_status_id);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_INTERCOMPANY_STATUS_ID', v_intercompany_status_id);

  ---- Sets the name of the element enclosing the entire result ----
  pl('dbms_xmlgen.setrowsettag');
  dbms_xmlgen.setrowsettag(qryCtx, 'XXBS_MAN_DRAFTREV');

  ---- Sets the name of the element enclosing each row of the result ----
  pl('dbms_xmlgen.setrowtag');
  --dbms_xmlgen.setrowtag(qryCtx,'');

  ---- Set the null handling option - Leave out the tags for null values ----
  pl('dbms_xmlgen.setnullhandling');
  dbms_xmlgen.setnullhandling(qryCtx, 0);

  ----  Generate the XML data to the result  ----
  pl('dbms_xmlgen.get_xml');
  result := DBMS_XMLGEN.getXML(qryCtx);

  ----  Closes a given context and releases all resources associated
  ----with it, including the SQL cursor and bind and define buffers ----
  dbms_xmlgen.closecontext(qryctx);

--  insert into xxcust_temp_clob_tab(result) values (result);

  ----  Call procedure to write the xml output to the bi report ----
  write_xml_output(result);
  pl('END xxcm_bi_reporting_pub.xxbs_man_draftrev_rpt');
*/
null;
 EXCEPTION
    WHEN OTHERS THEN
      p_retcode := sqlcode;
      p_errbuf  := sqlerrm;
      pl('Return Code = ' || p_retcode || ' ERROR: ' || p_errbuf);
      RAISE ;
END xxbs_man_draftrev_rpt;

--------------
PROCEDURE xxbs_trx_vat_reg (p_retcode       OUT NUMBER
                              ,p_errbuf        OUT VARCHAR2
                              ,p_fr_period_name   IN  VARCHAR2,
                              p_to_period_name   IN  VARCHAR2,
                              p_org_id        IN  NUMBER)
IS

  l_query                VARCHAR2(32767);
  l_select               VARCHAR2(8000);
  l_where                VARCHAR2(8000);
  l_group_by             VARCHAR2(4000);
  l_order_by             VARCHAR2(4000);
  qryCtx                 DBMS_XMLGEN.ctxHandle;
  result                 CLOB;

BEGIN
   pl('-- Begin XXBS Transaction Vat Reg Report (xxcm_bi_reporting_pub.xxbs_trx_vat_reg)--');
   pl('Input Parameters:  ');
   pl('    From Period Name         = ' || p_fr_period_name);
   pl('    To Period Name             = ' || p_to_period_name);
   pl('    Org Id                           = ' || p_org_id);

    -- Build the report xml
    l_query :=  'select TRX.AR_TRX_NUMBER "AR_TRX_NUMBER",' ||
                '       TRX.PERIOD_NAME "PERIOD_NAME",' ||
                '       TRX.DESCRIPTION "DESCRIPTION",' ||
                '       TRX.CURRENCY_CODE "CURRENCY_CODE",' ||
                '       TRX.ENTERED_CURRENCY_CODE "ENTERED_CURRENCY_CODE",' ||
                '       TRX.EXCHANGE_DATE "EXCHANGE_DATE",' ||
                '       TRX.EXCHANGE_RATE "EXCHANGE_RATE",' ||
                '       TRX.VAT_REG_NO "VAT_REG_NO",' ||
                '       TRX.VAT_REGISTERED "VAT_REGISTERED",' ||
                '       replace(TRX.INVOICE_FOOTER_BOTTOM,chr(10)) "INVOICE_FOOTER_BOTTOM",' ||
--                '       ''"'' || replace(TRX.INVOICE_FOOTER_BOTTOM,''"'') || ''"'' "INVOICE_FOOTER_BOTTOM",' ||
                '       TRX.INVOICE_STYLE_ID "INVOICE_STYLE_ID",' ||
                '       S.style_name "style_name"' ||
                '  from xxbs.xxbs_customer_trx TRX,' ||
                '       apps.xxbs_invoice_styles S ';

    -- Turns out the restriction was not giving them everything they wanted so removed it
    /*if p_org_id = 24 then
       l_where :=  ' WHERE ORGANIZATION_ID = :P_ORG_ID
                          AND INVOICE_FOOTER_BOTTOM like ''%Frankfurt%''
                          AND TO_DATE(TRX.PERIOD_NAME,''MON-RR'') between TO_DATE(:P_FR_PERIOD_NAME,''MON-RR'') and TO_DATE(:P_TO_PERIOD_NAME,''MON-RR'')';
    else */
       l_where :=   'WHERE ORGANIZATION_ID = :P_ORG_ID ' ||
                    '  AND TRX.invoice_style_id = S.style_id ' ||
                    '  AND TO_DATE(TRX.PERIOD_NAME,''MON-RR'') between TO_DATE(:P_FR_PERIOD_NAME,''MON-RR'') and TO_DATE(:P_TO_PERIOD_NAME,''MON-RR'')';
    /* end if; */

    l_query := l_query || l_where;


    pl(l_query,'N');
    qryCtx := DBMS_XMLGEN.newContext(l_query);

    /*  Set the bind variables  */
    pl('Set Bind Variables');
    dbms_xmlgen.setbindvalue(qryCtx, 'P_FR_PERIOD_NAME', p_fr_period_name);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_TO_PERIOD_NAME', p_to_period_name);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_ORG_ID', p_ORG_ID);

  /* Sets the name of the element enclosing the entire result */
  pl('dbms_xmlgen.setrowsettag');
  dbms_xmlgen.setrowsettag(qryCtx, 'XXBS_TRX_VAT_REG');

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

--  insert into xxcust_temp_clob_tab(result) values (result);

  /*  Call procedure to write the xml output to the bi report */
  write_xml_output(result);
  pl('END xxcm_bi_reporting_pub.xxbs_trx_vat_reg');

 EXCEPTION
    WHEN OTHERS THEN
      p_retcode := sqlcode;
      p_errbuf  := sqlerrm;
      pl('Return Code = ' || p_retcode || ' ERROR: ' || p_errbuf);
      RAISE ;
END xxbs_trx_vat_reg;

PROCEDURE xxpa_incorrect_cur_rpt (p_retcode OUT NUMBER
                              ,p_errbuf        OUT VARCHAR2
                              ,p_from_gl_date   IN  VARCHAR2
                              ,p_to_gl_date IN VARCHAR2)

IS

  l_query                VARCHAR2(32767);
  l_select               VARCHAR2(8000);
  l_where                VARCHAR2(8000);
  l_group_by             VARCHAR2(4000);
  l_order_by             VARCHAR2(4000);
  qryCtx                 DBMS_XMLGEN.ctxHandle;
  result                 CLOB;

BEGIN
   pl('-- Begi nXXPA Incorrect Currencies Report (xxcm_bi_reporting_pub.xxpa_incorrect_cur_rpt)--');
   pl('Input Parameters:  ');
   pl('    From GL Date         = ' || p_from_gl_date);
   pl('    To GL Date         = ' || p_to_gl_date);

    -- Build the report xml
               l_query :=  'SELECT
                          sob.short_name,
                           c.segment1,
                           c.segment2,
                           c.segment3,
                           c.segment4,
                           c.segment5,
                           c.segment6,
                           a.denom_currency_code,
                           a.acct_exchange_rate,
                           sum(a.denom_burdened_cost),
                           sum(a.acct_burdened_cost)
                       FROM apps.pa_cost_distribution_lines_all a ,
                           apps.gl_code_combinations c,
                           apps.pa_projects_all d,
                           apps.pa_expenditure_items_all e,
                           apps.pa_draft_invoice_details_all f,
                           apps.pa_draft_invoices_all g ,
                           apps.hr_operating_units ou,
                           apps.gl_ledgers sob,
                            (SELECT EXPENDITURE_ITEM_ID
                               FROM apps.pa_expenditure_items_all
                             WHERE cc_cross_charge_type = ''IC'') ic
                        WHERE a.expenditure_item_id = ic.expenditure_item_id
                            AND a.dr_code_combination_id = c.code_combination_id
                            AND a.project_id = d.project_id
                            AND a.expenditure_item_id = e.expenditure_item_id
                            AND a.expenditure_item_id = f.expenditure_item_id (+)
                            AND f.project_id = g.project_id (+)
                            AND f.draft_invoice_num = g.draft_invoice_num (+)
                            AND a.org_id = ou.organization_id
                            AND ou.set_of_books_id = sob.ledger_id
                            and  (a.gl_date >= TO_DATE(:P_FROM_GL_DATE,''YYYY/MM/DD HH24:MI:SS''))  --NEED TO ENTER PERIOD BEGIN DATE for current closing
                            and  (a.gl_date <= TO_DATE(:P_TO_GL_DATE,''YYYY/MM/DD HH24:MI:SS''))  --NEED TO ENTER PERIOD END DATE
                            and c.segment5 like ''13%''
                            and a.acct_exchange_rate is not null
                         group by
                            sob.short_name,
                            c.segment1,
                            c.segment2,
                            c.segment3,
                            c.segment4,
                            c.segment5,
                            c.segment6,
                            a.denom_currency_code,
                            a.acct_exchange_rate';

    pl(l_query,'N');
    qryCtx := DBMS_XMLGEN.newContext(l_query);

    /*  Set the bind variables  */
    pl('Set Bind Variables');
    dbms_xmlgen.setbindvalue(qryCtx, 'P_FROM_GL_DATE', p_from_gl_date);
    dbms_xmlgen.setbindvalue(qryCtx, 'P_TO_GL_DATE', p_to_gl_date);

  /* Sets the name of the element enclosing the entire result */
  pl('dbms_xmlgen.setrowsettag');
  dbms_xmlgen.setrowsettag(qryCtx, 'XXPA_INCORRECT_CUR_RPT');

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

--  insert into xxcust_temp_clob_tab(result) values (result);

  /*  Call procedure to write the xml output to the bi report */
  write_xml_output(result);
  pl('END xxcm_bi_reporting_pub.xxpa_incorrect_cur_rpt');

 EXCEPTION
    WHEN OTHERS THEN
      p_retcode := sqlcode;
      p_errbuf  := sqlerrm;
      pl('Return Code = ' || p_retcode || ' ERROR: ' || p_errbuf);
      RAISE ;
END xxpa_incorrect_cur_rpt;

PROCEDURE xxpa_open_commit_asia_acr (p_retcode       OUT NUMBER
                              ,p_errbuf        OUT VARCHAR2)
IS

  l_query                VARCHAR2(32767);
  l_select               VARCHAR2(8000);
  l_where                VARCHAR2(8000);
  l_group_by             VARCHAR2(4000);
  l_order_by             VARCHAR2(4000);
  qryCtx                 DBMS_XMLGEN.ctxHandle;
  result                 CLOB;

BEGIN
   pl('-- Begin XXPA Open Commitments for Asia Accrual (xxcm_bi_reporting_pub.xxpa_open_commit_asia_acr)--');

    -- Build the report xml
    l_query :=  'select
                        ppa.segment1 "PROJECT NUMBER" ,
                        pac.cmt_number "CMT NUMBER",
                        pac.description,
                        pac.expenditure_item_date "EXPENDITURE ITEM DT",
                        pac.cmt_line_number "CMT LINE NBR",
                        pac.cmt_creation_date "CMT CREATION DT",
                        pac.cmt_approved_date "CMT APPROVED DATE",
                        pac.cmt_buyer_name "CMT BUYER NAME",
                        pac.vendor_name "VENDOR NAME",
                        pac.expenditure_type "EXPENDITURE TYPE",
                        pac.unit_price "UNIT PRICE",
                        pac.quantity_ordered "QTY ORDERED",
                        pac.AMOUNT_ORDERED "AMOUNT ORDERED",
                        pac.amount_invoiced "AMOUNT INVOICED",
                        pac.AMOUNT_OUTSTANDING_INVOICE "AMOUNT OUTSTANDING INVOICE",
                        pac.denom_currency_code "DENOM CURRENCY CODE",
                        pac.acct_currency_code "ACCT CURRENCY CODE"
                    from apps.PA_COMMITMENT_TXNS pac,
                                apps.pa_projects_all ppa
                    where pac.project_id = ppa.project_id
                        and pac.transaction_source = ''ORACLE_PURCHASING''
                        and ppa.org_id in (2093, 2103)
                        and ppa.segment1 like ''025-%''
                        and pac.cmt_number not like ''1000''
                        order by cmt_number';

    pl(l_query,'N');
    qryCtx := DBMS_XMLGEN.newContext(l_query);

    /*  Set the bind variables  */
    pl('Set Bind Variables');

  /* Sets the name of the element enclosing the entire result */
  pl('dbms_xmlgen.setrowsettag');
  dbms_xmlgen.setrowsettag(qryCtx, 'XXPA_OPEN_COMMIT_ASIA_ACR');

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

--  insert into xxcust_temp_clob_tab(result) values (result);

  /*  Call procedure to write the xml output to the bi report */
  write_xml_output(result);
  pl('END xxcm_bi_reporting_pub.xxpa_open_commit_asia_acr');

 EXCEPTION
    WHEN OTHERS THEN
      p_retcode := sqlcode;
      p_errbuf  := sqlerrm;
      pl('Return Code = ' || p_retcode || ' ERROR: ' || p_errbuf);
      RAISE ;
END xxpa_open_commit_asia_acr;

PROCEDURE xxcm_sales_analysis (p_retcode     OUT NUMBER
                              ,p_errbuf      OUT VARCHAR2
                              ,p_from_period IN  VARCHAR2
                              ,p_to_period   IN  VARCHAR2
                              ,p_le          IN  VARCHAR2
                              ,p_bu          IN  VARCHAR2
                              ,p_site        IN  VARCHAR2
                              ,p_prod_line   IN  VARCHAR2
                              ,p_prod_vert   IN  VARCHAR2
                              ,p_cust_name   IN  VARCHAR2
                              ,p_ic_invoices IN  VARCHAR2)

IS
  l_query                VARCHAR2(32767);
  result                 XMLTYPE;
  formatResult           XMLTYPE;
  bLayoutResult          BOOLEAN;
--BC 20210115 comment out function build_query
/*
  FUNCTION build_query RETURN VARCHAR2 IS
      TYPE col_array IS VARRAY(46) OF VARCHAR2(30);
      cols                 col_array;
      colidx               PLS_INTEGER;

      v_columns            VARCHAR2(32000);
      v_query              VARCHAR2(32000);

      -- Map expenditure type to database column.  Control sorting of columns via hierarchy level
      CURSOR get_column_mapping IS
         select lower(dfv.database_column) col, dfv.expenditure_category exp,
               decode(atc.column_name, NULL, 'Y', 'N') column_missing
         from fnd_flex_value_sets fvs
           join fnd_flex_values ffv on ( ffv.flex_value_set_id = fvs.flex_value_set_id )
           join fnd_flex_values_dfv dfv on ( dfv.row_id = ffv.rowid )
           -- Only include columns if they are setup in table
           left join all_tab_columns atc on ( atc.table_name = 'XXCM_SALES_DATA_ALL'
                                      AND atc.column_name = upper(dfv.database_column)
                                       )
         where fvs.flex_value_set_name = 'XXCM_SALES_DATA_MAPPING'
           and ffv.enabled_flag = 'Y'
           and dfv.sort_order is not null
         order by to_number(dfv.sort_order)
      ;
   BEGIN
      -- Make sure to modify VARRAY size if more columns are added to the base insert
      cols := col_array(
           'period_ytd'
         , 'operating_unit'
         , 'ar_trx_number.quote'
         , 'project_number.quote'
         , 'legal_entity.quote'
         , 'business.quote'
         , 'site.quote'
         , 'site_name'
         , 'product_line.quote'
         , 'product_line_name'
         , 'primary_product_type'
         , 'product_vertical'
         , 'rep_number'
         , 'rep_name'
         , 'rep_business'
         , 'rep_site'
         , 'rep_percent_split'
         , 'customer_number'
         , 'customer_name'
         , 'base_currency'
         , 'entered_currency'
         , 'exchange_rate'
         , 'gl_period'
         , 'invoice_date.date'
         , 'revenue_job'
         , 'revenue_freight'
         , 'revenue_postage'
         , 'revenue_gross'
         , 'commissionable_revenue'
         , 'cost_total'
         , 'margin'
         , 'freight'
         , 'actual_freight'
         , 'tariff_freight'
         , 'freight_est_cost'
         , 'postage_est_cost'
         , 'estimated_cost'
         , 'source'
         , 'tv_indicator'
         );

      v_columns := NULL;
      FOR colidx IN 1 .. cols.count LOOP
         IF colidx != 1 THEN
            v_columns := v_columns || ',';
         END IF;
         v_columns := v_columns || ' xmlelement("'|| upper(cols(colidx)) || '",'
                                || regexp_replace(cols(colidx),'\..*') ||')
                                   ';
      END LOOP;

      -- Map Cost Values
      FOR rMap IN get_column_mapping LOOP
         IF rMap.column_missing = 'N' THEN
            v_columns := v_columns || ', xmlelement("'|| upper(rMap.col) || '",'
                                   || rMap.col ||')
                                   ';
         ELSE
            xxcm_common.write_log('Invalid column ['||rMap.col||'] setup in fnd_flex_value_set [XXCM_SALES_DATA_MAPPING]');
         END IF;
      END LOOP;

      v_query := q'"
 SELECT xmlelement("XXCM_SALES_ANALYSIS",
           xmlelement("INCLUDE_UNDERSCORE", 'YES')
         , xmlagg(xmlelement("G_REPORT","'
            ||v_columns||')))
 FROM xxcm_sales_data_all sd
 WHERE mo_global.check_access(org_id) = ''Y'''
      ;

      IF p_from_period IS NOT NULL THEN
        v_query := v_query || chr(10) || ' AND TO_DATE(GL_PERIOD,''MON-RR'') >= TO_DATE('''||p_from_period||''',''MON-RR'')';
      END IF;

      IF p_to_period IS NOT NULL THEN
         v_query := v_query || chr(10) || ' AND TO_DATE(GL_PERIOD,''MON-RR'') <= TO_DATE('''||p_to_period||''',''MON-RR'')';
      END IF;

      IF p_le != 'ALL' THEN
         v_query := v_query || chr(10) || ' AND legal_entity = '''||p_le||'''';
      END IF;

      IF p_bu != 'ALL' THEN
         v_query := v_query || chr(10) || ' AND business = '||p_bu;
      END IF;

      IF p_site != 'ALL' THEN
         v_query := v_query || chr(10) || ' AND site = '||p_site;
      END IF;

      IF p_prod_line != 'ALL' THEN
         v_query := v_query || chr(10) || ' AND product_line = '||p_prod_line;
      END IF;

      IF p_prod_vert != 'ALL' THEN
         v_query := v_query || chr(10) || ' AND product_vertical = '''||p_prod_vert||'''';
      END IF;

      IF p_cust_name IS NOT NULL THEN
         v_query := v_query || chr(10) || ' AND customer_name = '''||p_cust_name||'''';
      END IF;

      IF nvl(p_ic_invoices,'N') = 'N' THEN
         v_query := v_query || chr(10) || ' AND nvl(SOURCE,''x'') <> ''PA Internal Invoices''';
      END IF;

      xxcm_common.write_log(v_query, 'N');
      RETURN v_query;
   END build_query;
*/

BEGIN
--BC 20210115 comment out 
/*
  xxcm_common.write_log('-- Begin xxcm_sales_analysis --');
  xxcm_common.write_log('Input Parameters:  ');
  xxcm_common.write_log('    From Period         = ' || p_from_period);
  xxcm_common.write_log('    To Period           = ' || p_to_period);
  xxcm_common.write_log('    Legal Entity        = ' || p_le         );
  xxcm_common.write_log('    Bus Unit            = ' || p_bu         );
  xxcm_common.write_log('    Site                = ' || p_site       );
  xxcm_common.write_log('    Product Line        = ' || p_prod_line  );
  xxcm_common.write_log('    Product Vertical    = ' || p_prod_vert  );
  xxcm_common.write_log('    Customer            = ' || p_cust_name  );
  xxcm_common.write_log('    Internal Invoice    = ' || p_ic_invoices    );
*/

--BC 20210115 comment out
    -- Build the report xml
  --l_query :=  build_query;


--BC 20210115 comment out
  --execute immediate l_query INTO result;

/*     USING p_from_period , p_from_period
         , p_to_period   , p_to_period
         , p_le          , p_le
         , p_bu          , p_bu
         , p_site        , p_site
         , p_prod_line   , p_prod_line
         , p_prod_vert   , p_prod_vert
         , p_cust_name   , p_cust_name
         , p_ic_invoices;     */


--BC 20210115 comment out
  --bLayoutResult := xxcm_bi_reporting_pub.apply_template('XXCM_XSL_EXTRACT');

  -- This transformation is required to prevent the line from exceeding UNIX line lengths.
--  formatResult := result.transform(get_stylesheet);
  --BC 20210115 comment out
  --write_formatted_xml(result);

  --xxcm_common.write_log('END xxcm_bi_reporting_pub.xxcm_sales_analysis');
null;
EXCEPTION
   WHEN OTHERS THEN
      p_retcode := sqlcode;
      p_errbuf  := sqlerrm;
      xxcm_common.write_log('Return Code = ' || p_retcode || chr(10)||' ERROR: ' || p_errbuf||chr(10)
                          ||'['||dbms_utility.format_error_backtrace||']');
      RAISE ;
END xxcm_sales_analysis;

-----------------------------------------------------------------------------------------------
-- SUBMIT_REQUEST_BURST
-- Function "borrowed" from http://garethroberts.blogspot.com/2008/03/bi-publisher-ebs-bursting-101.html
-- Call this function to automatically burst/email  XML report instead of manually
-- submitting "XML Publisher Report Bursting Program"

-- 9/28/2015 -- parameter change in sumbit_request for R12
-----------------------------------------------------------------------------------------------
function submit_request_burst (p_request_id in number
                              , p_burst_type VARCHAR2 DEFAULT 'STD'
                              , p_location VARCHAR2 DEFAULT NULL
                              )
return boolean

is
  l_req_id number := 0;
  v_descr  fnd_concurrent_requests.description%TYPE;

  CURSOR conc_req_cur IS
     SELECT nvl(cr.description,cp.user_concurrent_program_name) description
     FROM fnd_concurrent_requests cr
       JOIN fnd_concurrent_programs_vl cp on ( cp.concurrent_program_id = cr.concurrent_program_id )
     WHERE cr.request_id = p_request_id;

begin

   CASE p_burst_type
      WHEN 'STD' THEN
        l_req_id := fnd_request.submit_request(
                                               'XDO',
                                               'XDOBURSTREP',
                                               null,
                                               null,
                                               FALSE,
                                               'Y',
                                               p_request_id,
                                               'N',
                                               CHR(0));

      ELSE
        OPEN conc_req_cur;
        FETCH conc_req_cur INTO v_descr;
        CLOSE conc_req_cur;

        l_req_id := fnd_request.submit_request(
                                               'XXCM',
                                               'XXCM_BURST_REQUEST',
                                               'Bursting '||v_descr,
                                               null,
                                               FALSE,
                                               p_request_id,
                                               p_burst_type,
                                               p_location,
                                               CHR(0));

   END CASE;


   if l_req_id > 0 then
      commit;
      return TRUE;
   elsif l_req_id = 0 then
      return FALSE;
   end if;

end submit_request_burst;

FUNCTION exec_parallel RETURN VARCHAR2
IS
   v_degree NUMBER;
BEGIN
   SELECT trunc(value / 2)
     INTO v_degree
   FROM v$parameter
   WHERE name = 'cpu_count';

   EXECUTE IMMEDIATE 'alter session set skip_unusable_indexes = TRUE';
   EXECUTE IMMEDIATE 'alter session force parallel ddl parallel '||v_degree;
   EXECUTE IMMEDIATE 'alter session force parallel dml parallel '||v_degree;
   EXECUTE IMMEDIATE 'alter session force parallel query parallel '||v_degree;
   xxcm_common.write_log('Degree of parallelism: '||v_degree);

   RETURN 'Y';
END exec_parallel;

END;

/
