/*************************************************************************************
FILENAME:     XXAR_CM_REASONCODE.sql

DESCRIPTION:  This Report lists the reason codes for the credit memos.

REQUIREMENTS:

USAGE:        sqlplus userid/password @

CALLED BY:

HISTORY:

v1.0     Mythily Jadhav    01/17/2003    Created.
v2.0     Mythily jadhav    02/25/2003    Included the Invoices which have only Credit Memo's and no Revised Invoices.
v3.0     Don Matuszak      02/22/2010    CR# 5074: Removed the DELETE and INSERT into the XXCM_CM_REASONCODE table.  Dropped the table
                                         since it's only used by this extract.  Replaced the standard SPOOLing with the UTL_FILE
                                         package.  Updated the query to use the trx_type of 'CM' (credit memo) to link back to
                                         Billing.  Converted the entire CURSOR to a dynamic SQL procedure to avoid any performance
                                         issues and stream-line the WHERE clauses contained in the SQL logic.
v4.0     Fujitsu           09/29/2015    For R12 Upgrade,RA_ADDRESSES_ALL is replaced with HZ_PARTY_SITES,HZ_LOCATIONS,HZ_CUST_ACCT_SITES_ALL
                                         COA changes(XXGL_PRODUCT_LINE is replaced with XXGL_R12_PL),
                                         Business Unit is excluded from the logic.Changed the report output format from txt to csv.
                                         There was an issue while passing a specific Cutomer Number,in where clause customer number value
                               is not getting passed as character('1234') but as number(1234).This issue is resolved.
01/31/2017 akaplan   Enh Req 1730 - Fix salesrep name for R12
06/20/2017 akaplan   Enh Req XXX - Tune
v5.0     DASH Kit Leung    08/MAR/2021   TM Oracle Spin
/*************************************************************************************/
--------------------------------------------------------------------------
-- VARIABLES
--------------------------------------------------------------------------

define v_application = 'XXAR'
define v_module = 'XXAR_CM_REASONCODE'
define v_version = '5.0'
define v_linesize = 4000
define v_pagesize = 0

--------------------------------------------------------------------------
-- PARAMETERS
--------------------------------------------------------------------------
--@$XXCM_TOP/sql/XXCM_REPORT_PARMS
--@$XXTM_TOP/sql/XXCM_REPORT_PARMS

-- FROM GL DATE
DEFINE v_p1='&1'


-- TO GL DATE
DEFINE v_p2='&2'

-- LEGAL ENTITY
DEFINE v_p3='&3'

-- BUSINESS
DEFINE v_p4='&4'

-- CUSTOMER NUMBER
DEFINE v_p5='&5'

-- CUSTOMER NAME
DEFINE v_p6='&6'

-- PRODUCT VERTICAL
DEFINE v_p7='&7'

-- COUNTRY
DEFINE v_p8='&8'

-- REASON CODE
DEFINE v_p9='&9'

-- PERIOD_SET_NAME
DEFINE v_p10='&10'

-------------------------------------------------------------------------
-- MAIN
--------------------------------------------------------------------------

DECLARE

  /*** Spool File Variables ****/
  l_output     UTL_FILE.FILE_TYPE;
  l_raw_size   CONSTANT BINARY_INTEGER := 32767;
  l_outfile    VARCHAR2(40);

  lv_request          NUMBER;
  lv_user_id          NUMBER;
  lv_customer_number  HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE;
  lv_customer_name    HZ_PARTIES.PARTY_NAME%TYPE;
  lv_country          FND_TERRITORIES_VL.TERRITORY_CODE%TYPE;
  lv_legal_entity     FND_FLEX_VALUES.FLEX_VALUE%TYPE;
  lv_business         FND_FLEX_VALUES.FLEX_VALUE%TYPE;
  lv_period_start_dt  GL_PERIODS.START_DATE%TYPE;
  lv_period_end_dt    GL_PERIODS.END_DATE%TYPE;
  lv_reason_code      RA_CUSTOMER_TRX_ALL.REASON_CODE%TYPE;
  --lv_product_vertical FND_FLEX_VALUES.ATTRIBUTE1%TYPE;

  /* Reference cursor variable setup for Dynamic SQL */
  TYPE lv_data_ref IS REF CURSOR;
  lv_data_results  lv_data_ref;

  /* Dynamic SQL variables */
  lv_dyn_reason_code             RA_CUSTOMER_TRX_ALL.REASON_CODE%TYPE;
  lv_dyn_cm_invoice              RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE;
  lv_dyn_transaction_date        RA_CUSTOMER_TRX_ALL.TRX_DATE%TYPE;
  lv_dyn_cm_amount               AR_PAYMENT_SCHEDULES_ALL.AMOUNT_DUE_ORIGINAL%TYPE;
  lv_dyn_rev_amount              AR_PAYMENT_SCHEDULES_ALL.AMOUNT_DUE_ORIGINAL%TYPE;
  lv_dyn_net_credit              AR_PAYMENT_SCHEDULES_ALL.AMOUNT_DUE_ORIGINAL%TYPE;
  lv_dyn_gl_date                 AR_PAYMENT_SCHEDULES_ALL.GL_DATE%TYPE;
  lv_dyn_customer_number         HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE;
  lv_dyn_customer_name           HZ_PARTIES.PARTY_NAME%TYPE;
  lv_dyn_gl_account              VARCHAR2(250);
  --lv_dyn_system_date             AR_PAYMENT_SCHEDULES_ALL.CREATION_DATE%TYPE;
  lv_dyn_primary_product_type_id XXBS_CUSTOMER_TRX.PRIMARY_PRODUCT_TYPE_ID%TYPE;
  --lv_dyn_product_vertical        FND_FLEX_VALUES.ATTRIBUTE1%TYPE;
  lv_dyn_primary_salesrep        jtf_rs_resource_extns_tl.RESOURCE_NAME%TYPE;
  lv_dyn_legal_entity            GL_CODE_COMBINATIONS.SEGMENT5%TYPE;
  lv_dyn_business                GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
  lv_dyn_country                 FND_TERRITORIES_VL.TERRITORY_SHORT_NAME%TYPE;
  --lv_dyn_sar_comment             XXBS_TRX_SAR.SAR_COMMENT%TYPE;
  lv_dyn_entered_currency_code   XXBS_CUSTOMER_TRX.ENTERED_CURRENCY_CODE%TYPE;
  lv_dyn_invoice_type            RA_CUST_TRX_TYPES_ALL.NAME%TYPE;
  lv_dyn_gl_period               XXBS_CUSTOMER_TRX.PERIOD_NAME%TYPE;
  --lv_dyn_before_margin           XXBS_TRX_SAR.ORIG_COST%TYPE;
  --v_dyn_after_margin            XXBS_TRX_SAR.REV_COST%TYPE;

  /* Error variable */
  lv_conc_status      BOOLEAN;

  --------------------------------------------------------------------------------------------------------
  -- Procedure: CREDIT_MEMO_DATA
  -- Purpose: Builds the WHERE clause and executes the dynamic SQL to retrieve CM related data.
  --
  -- Variables: p_customer_nbr...p_product_vertical: <self explanatory>
  --            p_results - returns the outcome of the query to this variable, which is of type REF CURSOR.
  --------------------------------------------------------------------------------------------------------
  PROCEDURE credit_memo_data(p_customer_nbr      IN     HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE
                            ,p_customer_name     IN     HZ_PARTIES.PARTY_NAME%TYPE
                            ,p_country           IN     FND_TERRITORIES_VL.TERRITORY_CODE%TYPE
                            ,p_legal_entity      IN     FND_FLEX_VALUES.FLEX_VALUE%TYPE
                           -- ,p_business          IN     FND_FLEX_VALUES.FLEX_VALUE%TYPE
                            ,p_period_start_date IN     GL_PERIODS.START_DATE%TYPE
                            ,p_period_end_date   IN     GL_PERIODS.END_DATE%TYPE
                            ,p_reason_code       IN     RA_CUSTOMER_TRX_ALL.REASON_CODE%TYPE
                            --,p_product_vertical  IN     FND_FLEX_VALUES.ATTRIBUTE1%TYPE
                            ,p_results           IN OUT lv_data_ref) IS

    lv_slct        VARCHAR2(10000);
    lv_cm_where    VARCHAR2(3000);  /* Credit Memo */
    lv_rev_where   VARCHAR2(3000);  /* Revised Invc. */
    lv_ctry_where  VARCHAR2(1000);  /* fnd_territory */
    --lv_prod_where  VARCHAR2(3000);  /* Product Vertical */

    lv_period_start VARCHAR2(10);
    lv_period_end   VARCHAR2(10);

    BEGIN
      /* Builds the WHERE clause for the Dynamic SQL statement */
      IF (p_period_start_date IS NOT NULL) THEN
        lv_period_start := TO_CHAR(TO_DATE(p_period_start_date),'MM/DD/YYYY');
        lv_period_end   := TO_CHAR(TO_DATE(p_period_end_date),'MM/DD/YYYY');

        lv_cm_where := ' AND apsa.gl_date BETWEEN '||'TO_DATE('||''''||lv_period_start||''''||','||'''MM/DD/YYYY'''||')'||' '||
                       '                      AND '||'TO_DATE('||''''||lv_period_end||''''||','||'''MM/DD/YYYY'''||')'||' ';
      END IF;

      IF (p_reason_code IS NOT NULL) THEN
        lv_cm_where := lv_cm_where||' AND cm.reason_code = '||''''||p_reason_code||''''||' ';
      END IF;

      IF (p_customer_nbr IS NOT NULL) THEN
        lv_rev_where := ' AND hca.account_number = '||''''||p_customer_nbr||''''||' ';
      END IF;

      IF (p_customer_name IS NOT NULL) THEN
        lv_rev_where := lv_rev_where||' AND UPPER(hp.party_name) = '||''''||p_customer_name||''''||' ';
      END IF;

      IF (p_country IS NOT NULL) THEN
        lv_ctry_where := lv_ctry_where||' AND ftv.territory_code = '||''''||p_country||''''||' ';
      END IF;

      IF (p_legal_entity IS NOT NULL) THEN
        lv_rev_where := lv_rev_where||' AND gcc.segment1 = '||''''||p_legal_entity||''''||' ';
      END IF;

     --Commented for R12 Upgrade COA Changes
      --IF (p_business IS NOT NULL) THEN
       -- lv_rev_where := lv_rev_where||' AND gcc.segment1 = '||''''||p_business||''''||' ';
      --END IF;
	  
	  /*
      IF (p_product_vertical IS NOT NULL) THEN
        lv_prod_where := ' AND v.attribute1 = '||''''||p_product_vertical||''''||' ';
      END IF;
	  */
	  
      /*****************************************************************************************************
      * Cursor setup as such:
      *   a) Outer SELECT stmt. ties the outer-most inline view data to the Product Vertical
      *     b) Outer-most inline view (containing the join to the Revised Invoice and SAR info.)
      *        ties to the inner-most inline view data which contains the Credit Memo data.
      *       c) Inner-most inline view pulls the Credit Memo data from AR based on the parameters entered.
      /*****************************************************************************************************/

      lv_slct := 'SELECT a.reason_code,
            a.trx_number cm_invoice,
            a.trx_date transaction_date,
            a.amount_due_original cm_amount,
            SUM(NVL(revised_pay.amount_due_original,0)) rev_amount,
            (a.amount_due_original + SUM(NVL(revised_pay.amount_due_original,0))) net_credit,
            a.gl_date,
            hca.account_number customer_number,
            SUBSTRB(hp.party_name,1,50) customer_name,
            (gcc.segment1||''.''||gcc.segment2||''.''||gcc.segment3||''.''||gcc.segment4||''.''||gcc.segment5||''.''||gcc.segment6) gl_account,
            trx.primary_product_type_id,
            jrd.resource_name primary_salesrep,
            gcc.segment1 legal_entity,
            ftv.territory_short_name country,
            trx.entered_currency_code,
            a.name invoice_type,
            trx.period_name gl_period
     FROM ra_customer_trx_all revised_trx,
          ar_payment_schedules_all revised_pay,
          hz_parties hp,
          hz_cust_accounts hca,
          hz_locations hl,
          xxbs_customer_trx ptrx,
          xxbs_customer_trx trx,
          gl_code_combinations gcc,
          ra_cust_trx_line_gl_dist_all dist,
          JTF_RS_DEFRESOURCES_V jrd, 
          XXBS_REP_SPLITS xrs,
          hz_party_sites hps1,
          hz_locations hl1,
          hz_cust_acct_sites_all hcs1,
          (
              SELECT territory_code, territory_short_name
              FROM fnd_territories_tl ftv
              WHERE 1=1
	      '||lv_ctry_where||' 
          ) ftv
          ,(SELECT apsa.customer_trx_id
                 , apsa.customer_id
                 --, cm.reason_code
                , (select xta.approval_reason
                    --,xta.justification 
                    from XXBS_TRX_ACTIVITY xta
                    where xta.approval_action = ''Revise'' 
                    and xta.activity_type = ''Requested for approval''
                    and xta.trx_activity_id = (select max(trx_activity_id) 
                                                from xxbs_trx_activity xta2 
                                                where xta2.approval_action = ''Revise'' 
                                                and xta2.activity_type = ''Requested for approval'' 
                                                and xta.customer_trx_id = (select revised_customer_trx_id from xxbs_customer_trx where customer_trx_id = cm.INTERFACE_HEADER_ATTRIBUTE3)
                                              )
                  ) reason_code                    
                 , cm.trx_date
                 , cm.trx_number
                 , apsa.amount_due_original
                 , apsa.gl_date
                 , xxcm_common.get_trx_type_name(cm.cust_trx_type_id) name
            FROM ar_payment_schedules_all apsa,
                 ra_customer_trx_all cm
            WHERE apsa.customer_trx_id = cm.customer_trx_id
              AND xxcm_common.get_trx_type(cm.cust_trx_type_id) = ''CM'' 
              ) a
     WHERE dist.customer_trx_id = a.customer_trx_id
       AND dist.account_class = ''REC''
       AND dist.latest_rec_flag = ''Y''
       AND gcc.code_combination_id = dist.code_combination_id
       AND a.customer_id = trx.bill_to_customer_id
       AND a.trx_number = trx.ar_trx_number
       AND trx.revised_customer_trx_id = ptrx.customer_trx_id
       AND revised_trx.trx_number(+) = ptrx.ar_trx_number
       AND revised_pay.customer_trx_id(+) = revised_trx.customer_trx_id
       AND trx.bill_to_customer_id = hca.cust_account_id
       AND hca.party_id = hp.party_id
       AND xrs.customer_trx_id = trx.customer_trx_id
       AND xrs.primary_flag = ''Y''
       AND jrd.resource_id = xrs.salesrep_id
       AND hps1.location_id = hl1.location_id
       AND hps1.party_site_id = hcs1.party_site_id
       AND trx.bill_to_address_id = hcs1.cust_acct_site_id
       AND hl.location_id = hps1.location_id
       AND ftv.territory_code = hl.country
       '||lv_rev_where||  
     'GROUP BY a.reason_code,
              a.trx_number,
              a.trx_date,
              a.amount_due_original,
              a.gl_date,
              hca.account_number,
              hp.party_name,
              gcc.segment1,
              gcc.segment2,
              gcc.segment3,
              gcc.segment4,
              gcc.segment5,
              gcc.segment6,
              trx.primary_product_type_id,
              trx.period_name,
              jrd.resource_name,
              ftv.territory_short_name,
              trx.entered_currency_code,
              a.name';

      /* Displays the SELECT stmt. built in the View Output section of the concurrent request. Used for debugging. */
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Dynamic SELECT stmt. = '||lv_slct);

    OPEN p_results FOR lv_slct;

  END credit_memo_data;


BEGIN

  FND_FILE.PUT_LINE(FND_FILE.LOG,'v_p1 = '||'&v_p1');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'v_p2 = '||'&v_p2');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'v_p3 = '||'&v_p3');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'v_p4 = '||'&v_p4');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'v_p5 = '||'&v_p5');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'v_p6 = '||'&v_p6');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'v_p7 = '||'&v_p7');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'v_p8 = '||'&v_p8');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'v_p9 = '||'&v_p9');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'v_p10 = '||'&v_p10');
	
  /* REQUEST */
  SELECT LTRIM(FND_GLOBAL.CONC_REQUEST_ID)
    INTO lv_request
    FROM dual;

  /* USER ID */
  SELECT LTRIM(FND_GLOBAL.USER_ID)
    INTO lv_user_id
    FROM dual;

  /* From Period Start Date */
  SELECT start_date
    INTO lv_period_start_dt
    FROM gl_periods gp
   WHERE period_name = '&v_p1'
     AND UPPER(period_set_name) = '&v_p10';
  
  /* To Period End Date */
  SELECT end_date
    INTO lv_period_end_dt
    FROM gl_periods gp
   WHERE period_name = '&v_p2'
     AND UPPER(period_set_name) = '&v_p10';
  
  lv_customer_number := '&v_p5';

  /*
  IF (lv_customer_number = 0) THEN
    lv_customer_number := NULL;
  END IF;
  */

  lv_legal_entity     := '&v_p3';
  --lv_business         := '&v_p4'; Commented for R12 Upgrade COA Changes
  lv_customer_name    := '&v_p6';
  --lv_product_vertical := '&v_p7';
  lv_country          := '&v_p8';
  lv_reason_code      := '&v_p9';

  /* Output file setup */
  /*
  l_outfile := lv_request||'_cm_reasoncode';
  IF xxcm_common.is_prod_db = 'N' THEN
     l_outfile := l_outfile||'_'||xxcm_common.get_db;
  END IF;
  l_outfile := l_outfile ||'.csv';

  l_output := UTL_FILE.FOPEN(xxcm_common.get_db_constant('RPT_EXTRACT_DIR'), l_outfile, 'W', l_raw_size);

 --l_output := UTL_FILE.FOPEN('/u01/applmgr/fs2/EBSapps/appl/custom/12.0.0/loadfiles/hyperion', l_outfile, 'W', l_raw_size);
  */

  /********* Create pipe-delimited flat file **********/
  /* Header line */
  /*
  UTL_FILE.PUT(l_output,
              'PERIOD_NAME'              ||','||
              'GL_DATE'                  ||','||
              'TRX_NUMBER'               ||','||
              'TRX_DATE'                 ||','||
              'ORIGINAL_INVOICE_CURRENCY'||','||
              'TRX_TYPE'                 ||','||
              'CREDIT_AMOUNT'            ||','||
              'REVISED_AMOUNT'           ||','||
              'NET_CREDIT'               ||','||
              'BEFORE_MARGIN%'           ||','||
              'AFTER_MARGIN%'            ||','||
              'REASON_CODE'              ||','||
              'CUSTOMER_NUMBER'          ||','||
              'CUSTOMER_NAME'            ||','||
              'GL_ACCOUNT'               ||','||
              'PRIMARY_PRODUCT_TYPE'     ||','||
              'PRODUCT_VERTICAL'         ||','||
              'PRIMARY_SALESREP'         ||','||
              'LEGAL_ENTITY'             ||','||
              'COUNTRY'                  ||','||
              'SAR_COMMENTS'
              );
  UTL_FILE.NEW_LINE(l_output,1);
  */

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'PERIOD_NAME'||','||
					  'GL_DATE'                  ||','||
					  'TRX_NUMBER'               ||','||
					  'TRX_DATE'                 ||','||
					  'ORIGINAL_INVOICE_CURRENCY'||','||
					  'TRX_TYPE'                 ||','||
					  'CREDIT_AMOUNT'            ||','||
					  'REVISED_AMOUNT'           ||','||
					  'NET_CREDIT'               ||','||
					  'REASON_CODE'              ||','||
					  'CUSTOMER_NUMBER'          ||','||
					  'CUSTOMER_NAME'            ||','||
					  'GL_ACCOUNT'               ||','||
					  'PRIMARY_PRODUCT_TYPE'     ||','||
					  'PRIMARY_SALESREP'         ||','||
					  'LEGAL_ENTITY'             ||','||
					  'COUNTRY'
					  );

  /* Dynamic SQL procedure */
  credit_memo_data(lv_customer_number
                  ,lv_customer_name
                  ,lv_country
                  ,lv_legal_entity
              --,lv_business     --Commented for R12 Upgrade COA Changes
                  ,lv_period_start_dt
                  ,lv_period_end_dt
                  ,lv_reason_code
                  --,lv_product_vertical
                  ,lv_data_results);
  LOOP
    FETCH lv_data_results INTO lv_dyn_reason_code,
                               lv_dyn_cm_invoice,
                               lv_dyn_transaction_date,
                               lv_dyn_cm_amount,
                               lv_dyn_rev_amount,
                               lv_dyn_net_credit,
                               lv_dyn_gl_date,
                               lv_dyn_customer_number,
                               lv_dyn_customer_name,
                               lv_dyn_gl_account,
                               --lv_dyn_system_date,
                               lv_dyn_primary_product_type_id,
                               --lv_dyn_product_vertical,
                               lv_dyn_primary_salesrep,
                               lv_dyn_legal_entity,
                        --lv_dyn_business,    --Commented for R12 Upgrade COA Changes
                               lv_dyn_country,
                               --lv_dyn_sar_comment,
                               lv_dyn_entered_currency_code,
                               lv_dyn_invoice_type,
                               lv_dyn_gl_period--,
                               --lv_dyn_before_margin,
                               --lv_dyn_after_margin
							   ;

    EXIT WHEN lv_data_results%NOTFOUND;
	/*
    UTL_FILE.PUT(l_output,
                 lv_dyn_gl_period||','||
                 lv_dyn_gl_date||','||
                 lv_dyn_cm_invoice||','||
                 lv_dyn_transaction_date||','||
                 lv_dyn_entered_currency_code||','||
                 lv_dyn_invoice_type||','||'"'||
                 LTRIM(TO_CHAR(lv_dyn_cm_amount,'999G999G999G990D99'))||'"'||','||'"'||
                 LTRIM(TO_CHAR(lv_dyn_rev_amount,'999G999G999G990D99'))||'"'||','||'"'||
                 LTRIM(TO_CHAR(lv_dyn_net_credit,'999G999G999G990D99'))||'"'||','||
                 lv_dyn_before_margin||','||
                 lv_dyn_after_margin||','||
                 lv_dyn_reason_code||','||
                 lv_dyn_customer_number||','||'"'||
                 lv_dyn_customer_name||'"'||','||
                 lv_dyn_gl_account||','||
                 lv_dyn_primary_product_type_id||','||
                 lv_dyn_product_vertical||','||'"'||
                 lv_dyn_primary_salesrep||'"'||','||
                 lv_dyn_legal_entity||','||
                 lv_dyn_country||','||'"'||
                 lv_dyn_sar_comment||'"'
                 );
    UTL_FILE.NEW_LINE(l_output,1);

	*/
	--DBMS_OUTPUT.PUT_LINE(
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                 lv_dyn_gl_period||','||
                 lv_dyn_gl_date||','||
                 lv_dyn_cm_invoice||','||
                 lv_dyn_transaction_date||','||
                 lv_dyn_entered_currency_code||','||
                 lv_dyn_invoice_type||','||'"'||
                 LTRIM(TO_CHAR(lv_dyn_cm_amount,'999G999G999G990D99'))||'"'||','||'"'||
                 LTRIM(TO_CHAR(lv_dyn_rev_amount,'999G999G999G990D99'))||'"'||','||'"'||
                 LTRIM(TO_CHAR(lv_dyn_net_credit,'999G999G999G990D99'))||'"'||','||
                 lv_dyn_reason_code||','||
                 lv_dyn_customer_number||','||'"'||
                 lv_dyn_customer_name||'"'||','||
                 lv_dyn_gl_account||','||
                 lv_dyn_primary_product_type_id||','||'"'||
                 lv_dyn_primary_salesrep||'"'||','||
                 lv_dyn_legal_entity||','||
                 lv_dyn_country
                 );				 

  END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE(
    FND_FILE.PUT_LINE(FND_FILE.LOG,
    'SQLCODE: '||SQLCODE);

    --DBMS_OUTPUT.PUT_LINE(
    FND_FILE.PUT_LINE(FND_FILE.LOG,
    'SQLERRM: '||SQLERRM);
    /* Set concurrent program to ERROR status */
    lv_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',NULL);

END;
/
