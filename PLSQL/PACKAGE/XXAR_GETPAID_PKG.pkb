--------------------------------------------------------
--  DDL for Package Body XXAR_GETPAID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAR_GETPAID_PKG" IS

---------------------------------------------------------------------------------------------
-- Package: XXAR_GETPAID_PKG
-- Purpose:
--
-- Change History
-- Author         Date        Description
-- Don Matuszak   01/09/08     Created
-- Ari Kaplan     01/07/14     SP Issue 798: Use bind variables for dynamic cursors.
-- akaplan        10/21/15     Fix get_parent - restrict id checking to appropriate tables--
-- akaplan        04/07/16     Enh Req 1489: Fix issue with exchange rate.
--                               Blow up if oracle error (including NOT FOUND and TOO_MANY_ROWS)
---------------------------------------------------------------------------------------------
    SUBTYPE lkup_key IS VARCHAR2(100);
    SUBTYPE lkup_type IS VARCHAR2(30);
    TYPE lkup_list_tab IS TABLE OF VARCHAR2(1000) INDEX BY lkup_key;
    TYPE lkup_tab      IS TABLE OF lkup_list_tab INDEX BY lkup_type;
    t_lookup lkup_tab;

  ---------------------------------------------------------------------------------------------
  -- Function: set_pkg_variable
  -- Purpose: Returns FALSE if an error occurs during the function call.
  --
  -- Parameters: p_variable - Actual name of the variable (Required).
  --             p_status - Used as a flag Y/N for the p_variable parm. (Required).
  --             p_sqlerrm - Returns an error if one exists. (Optional).
  ---------------------------------------------------------------------------------------------
  FUNCTION set_pkg_variable(p_variable     IN VARCHAR2
                           ,p_status       IN VARCHAR2
                           ,p_sqlerrm     OUT VARCHAR2)
    RETURN BOOLEAN IS

    lv_result BOOLEAN := TRUE;

  BEGIN
    IF (p_variable = 'pkg_v_debug') THEN
      pkg_v_debug := p_status;
    END IF;

    RETURN(lv_result);

  EXCEPTION
    WHEN OTHERS THEN
      p_sqlerrm := INSTR(SQLERRM,1,60);
      RETURN FALSE;

  END set_pkg_variable;

  -----------------------------------------------------------------------------------------
  -- Function:fnd_lastpayment_date
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_lastpayment_date(p_cust_account_id       IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE)
    RETURN AR_TRX_BAL_SUMMARY.LAST_PAYMENT_DATE%TYPE IS

    lv_last_payment_date AR_TRX_BAL_SUMMARY.LAST_PAYMENT_DATE%TYPE;

  BEGIN

    SELECT MAX(receipt_date)
      INTO lv_last_payment_date
      FROM ar_payment_schedules_all apsa
          ,ar_cash_receipts_all acra
     WHERE apsa.customer_id = p_cust_account_id
       AND acra.pay_from_customer = apsa.customer_id
       AND acra.cash_receipt_id = apsa.cash_receipt_id;

    RETURN(lv_last_payment_date);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      /* Returning value to detect issue with function call. */
      RETURN(TO_DATE('31-DEC-9999','DD-MON-YYYY'));

  END fnc_lastpayment_date;


  -----------------------------------------------------------------------------------------
  -- Function:fnc_lastpayment_amt
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_lastpayment_amt(p_cust_account_id       IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE)
    RETURN AR_TRX_BAL_SUMMARY.LAST_PAYMENT_AMOUNT%TYPE IS

    lv_last_payment_amt AR_TRX_BAL_SUMMARY.LAST_PAYMENT_AMOUNT%TYPE := 0;

  BEGIN

    SELECT acra.amount
      INTO lv_last_payment_amt
      FROM ar_payment_schedules_all apsa
          ,ar_cash_receipts_all acra
     WHERE apsa.customer_id = p_cust_account_id
       AND acra.pay_from_customer = apsa.customer_id
       AND acra.cash_receipt_id = apsa.cash_receipt_id
       AND acra.cash_receipt_id = (SELECT MAX(acra.cash_receipt_id)
                                     FROM ar_payment_schedules_all apsa
                                         ,ar_cash_receipts_all acra
                                    WHERE apsa.customer_id = p_cust_account_id
                                      AND acra.pay_from_customer = apsa.customer_id
                                      AND acra.cash_receipt_id = apsa.cash_receipt_id
                                      AND acra.receipt_date = (SELECT MAX(receipt_date)
                                                                 FROM ar_payment_schedules_all apsa
                                                                     ,ar_cash_receipts_all acra
                                                                WHERE apsa.customer_id = p_cust_account_id
                                                                  AND acra.pay_from_customer = apsa.customer_id
                                                                AND acra.cash_receipt_id = apsa.cash_receipt_id));

    RETURN(lv_last_payment_amt);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      /* Returning value to detect issue with function call. */
      RETURN(TO_NUMBER('-1'));

  END fnc_lastpayment_amt;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_credit_limit_dt
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_credit_limit_dt(p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE)
    RETURN DATE IS

    lv_credit_limit_dt HZ_CUST_PROFILE_AMTS.CREATION_DATE%TYPE;

  BEGIN

    SELECT hcpa.creation_date
      INTO lv_credit_limit_dt
      FROM hz_customer_profiles hcp
          ,hz_cust_profile_amts hcpa
          ,hz_cust_site_uses_all hcsua
          ,hz_cust_acct_sites_all hcasa
          ,hz_cust_accounts hcust
     WHERE hcp.cust_account_id = p_cust_account_id
       AND hcpa.cust_account_profile_id = hcp.cust_account_profile_id
       AND hcp.site_use_id = hcsua.site_use_id
       AND hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
       AND hcust.cust_account_id = hcasa.cust_account_id;

    RETURN(lv_credit_limit_dt);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      /* Returning value to detect issue with function call. */
      RETURN(TO_DATE('31-DEC-9999','DD-MON-YYYY'));

  END fnc_credit_limit_dt;


  -----------------------------------------------------------------------------------------
  -- Function:fnc_cust_payment_terms
  -- Purpose: Returns the numeric value associated with the payment terms that are tied to the customer (not site level).
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_cust_payment_terms(p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE)
    RETURN NUMBER IS

    lv_terms  NUMBER := 0;

    CURSOR c_terms (lv_cust_acct_id HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) IS
      SELECT DECODE(rtt.name, 'IMMEDIATE', 30, rtl.due_days) due_days
        FROM hz_cust_accounts hca
            ,hz_customer_profiles hcp
            ,ra_terms_b rtb
            ,ra_terms_tl rtt
            ,ra_terms_lines rtl
       WHERE hca.cust_account_id = lv_cust_acct_id
         AND hcp.party_id = hca.party_id
         AND hcp.cust_account_id = hca.cust_account_id
         /* Do not get the payment terms at the site level */
         AND hcp.site_use_id IS NULL
         AND rtb.term_id(+) = hcp.standard_terms
         AND rtt.term_id(+) = rtb.term_id
         AND rtl.term_id(+) = rtb.term_id;

  BEGIN

    OPEN c_terms(p_cust_account_id);
    FETCH c_terms INTO lv_terms;

    /* Default the terms to 30 (Immediate) if the payment terms for the customer profile have not been set. */
    IF c_terms%NOTFOUND THEN
      lv_terms := 30;
    END IF;
    CLOSE c_terms;

    RETURN(lv_terms);

  EXCEPTION

    WHEN OTHERS THEN
      RETURN(0);

  END fnc_cust_payment_terms;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_trx_payment_terms
  -- Purpose: Returns the numeric value associated with the payment terms that are tied to transaction.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_trx_payment_terms(p_customer_trx_id IN RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE)
    RETURN NUMBER IS

    lv_terms  NUMBER := 0;


  BEGIN

    SELECT DECODE(rtt.name,'IMMEDIATE', 30, rtl.due_days)
      INTO lv_terms
      FROM ra_customer_trx_all rcta
          ,ra_terms_b rtb
          ,ra_terms_tl rtt
          ,ra_terms_lines rtl
     WHERE rcta.customer_trx_id = p_customer_trx_id
       AND rtb.term_id(+) = rcta.term_id
       AND rtt.term_id(+) = rtb.term_id
       AND rtl.term_id(+) = rtb.term_id;

    RETURN(lv_terms);

  EXCEPTION

    WHEN OTHERS THEN
      RETURN(0);

  END fnc_trx_payment_terms;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_getpaid_group_id
  -- Purpose:
  --
  -- Variables:
  --
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_getpaid_group_id (p_customer_id IN AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_ID%TYPE)
    RETURN VARCHAR2 IS

    lv_string     VARCHAR2(100);
    lv_segment1   GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
    lv_segment3   GL_CODE_COMBINATIONS.SEGMENT3%TYPE;
    lv_org_id     RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE;
    lv_attribute2 FND_FLEX_VALUES.ATTRIBUTE2%TYPE;


  BEGIN
    SELECT DISTINCT(gcc.segment1)
          ,gcc.segment3
          ,rcta.org_id
          ,ffv.attribute2
      INTO lv_segment1
          ,lv_segment3
          ,lv_org_id
          ,lv_attribute2
      FROM ar_payment_schedules_all apsa
          ,ra_customer_trx_all rcta
          ,ra_cust_trx_line_gl_dist_all dist
          ,gl_code_combinations gcc
          ,fnd_flex_values ffv
     WHERE apsa.customer_id = p_customer_id
       AND rcta.customer_trx_id = apsa.customer_trx_id
       AND rcta.customer_trx_id = dist.customer_trx_id
       AND dist.account_class = 'REC'
       AND dist.latest_rec_flag = 'Y'
       AND dist.code_combination_id = gcc.code_combination_id
       AND ffv.flex_value = gcc.segment3;

    lv_string := lv_segment1||'.'||lv_segment3||'.'||TO_CHAR(lv_org_id)||'.'||lv_attribute2;

    RETURN(lv_string);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(SQLERRM);

  END fnc_getpaid_group_id;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_source_name
  -- Purpose:
  --
  -- Variables:
  --
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_source_name (p_batch_source_id RA_CUSTOMER_TRX_ALL.BATCH_SOURCE_ID%TYPE
                           ,p_org_id          RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE)
    RETURN VARCHAR2 IS

    lv_src_name RA_BATCH_SOURCES.NAME%TYPE;
    v_key       lkup_key := p_batch_source_id ||':'|| p_org_id;
    v_type      lkup_type := 'SRC';
  BEGIN
    IF NOT t_lookup.exists(v_type) OR NOT t_lookup(v_type).exists(v_key) THEN
        SELECT name
          INTO t_lookup(v_type)(v_key)
        FROM ra_batch_sources_all rbs
        WHERE batch_source_id = p_batch_source_id
          AND org_id = p_org_id;
    END IF;

    lv_src_name := t_lookup(v_type)(v_key);

    RETURN(lv_src_name);


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(SQLERRM);

  END fnc_source_name;


  -----------------------------------------------------------------------------------------
  -- Function: fnc_invc_trx_dff
  -- Purpose: Used to retrieve the DFF field values:
  --            Application: Receivables
  --                  Title: Invoice Transaction Flexfield
  --                  Table: RA_CUSTOMER_TRX_ALL
  -- Variables:
  --
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_inv_trx_dff (p_cust_trx_id IN  RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE
                           ,p_source      IN  RA_BATCH_SOURCES.NAME%TYPE
                           ,p_column_name IN  FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE)
    RETURN VARCHAR2 IS

    lv_col_name   FND_DESCR_FLEX_COL_USAGE_VL.APPLICATION_COLUMN_NAME%TYPE;
    lv_return_val VARCHAR2(30);
    v_key         lkup_key := p_source||':'||p_column_name;
    v_type        lkup_type := 'INV_TRX_DFF';

    CURSOR c_dff_column(lv_source   RA_BATCH_SOURCES.NAME%TYPE
                       ,lv_column   FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE) IS
      SELECT dff_col.application_column_name
        FROM fnd_descr_flex_contexts_vl dff_context
            ,fnd_descr_flex_col_usage_vl dff_col
       WHERE dff_context.descriptive_flexfield_name = 'RA_INTERFACE_HEADER'
         AND dff_context.descriptive_flex_context_code = lv_source
         AND dff_col.descriptive_flexfield_name = dff_context.descriptive_flexfield_name
         AND dff_col.descriptive_flex_context_code = dff_context.descriptive_flex_context_code
         AND dff_col.end_user_column_name = lv_column;

  BEGIN

    IF NOT t_lookup.exists(v_type) OR NOT t_lookup(v_type).exists(v_key) THEN
       OPEN c_dff_column(p_source
                        ,p_column_name);
       FETCH c_dff_column INTO t_lookup(v_type)(v_key);
       CLOSE c_dff_column;
    END IF;

    lv_col_name := t_lookup(v_type)(v_key);

    IF lv_col_name IS NOT NULL THEN
      EXECUTE IMMEDIATE 'SELECT '||lv_col_name||
                        '  FROM ar.ra_customer_trx_all '||
                        ' WHERE customer_trx_id = :p_cust_trx_id'
       INTO lv_return_val
       USING p_cust_trx_id;

    END IF;


    RETURN(lv_return_val);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(SQLERRM);

  END fnc_inv_trx_dff;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_rcpt_app_dff
  -- Purpose: Used by the ARMAST file to retrieve the DFF field values.
  --
  -- Variables:
  --
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_rcpt_app_dff (p_cust_trx_id         IN  AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_TRX_ID%TYPE
                            ,p_payment_schedule_id IN  AR_PAYMENT_SCHEDULES_ALL.PAYMENT_SCHEDULE_ID%TYPE
                            ,p_column_name         IN  FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE)
    RETURN VARCHAR2 IS

    lv_source     VARCHAR2(30);
    lv_col_name   FND_DESCR_FLEX_COL_USAGE_VL.APPLICATION_COLUMN_NAME%TYPE;
    lv_return_val VARCHAR2(150);
    v_key         lkup_key := p_column_name;
    v_type        lkup_type := 'RCPT_APP_DFF';

    CURSOR c_dff_column(lv_source   VARCHAR2
                       ,lv_column   FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE) IS
      SELECT dff_col.application_column_name
        FROM fnd_descr_flex_contexts_vl dff_context
            ,fnd_descr_flex_col_usage_vl dff_col
       WHERE dff_context.descriptive_flexfield_name = 'AR_RECEIVABLE_APPLICATIONS'
         AND dff_context.descriptive_flex_context_code = lv_source
         AND dff_col.descriptive_flexfield_name = dff_context.descriptive_flexfield_name
         AND dff_col.descriptive_flex_context_code = dff_context.descriptive_flex_context_code
         AND dff_col.end_user_column_name = lv_column;

  BEGIN

    /* Set source value. */
    lv_source := 'Global Data Elements';

    IF NOT t_lookup.exists(v_type) OR NOT t_lookup(v_type).exists(v_key) THEN
       OPEN c_dff_column(lv_source
                        ,p_column_name);
       FETCH c_dff_column INTO t_lookup(v_type)(v_key);
       CLOSE c_dff_column;
    END IF;

    lv_col_name := t_lookup(v_type)(v_key);

    /* SQL stmt. retrieves the value based on the latest receipt since a trx. have be on multiple receipts
    ** and thus have multiple values for the field being retrieved. */
    IF lv_col_name IS NOT NULL THEN
      EXECUTE IMMEDIATE 'SELECT araa.'||lv_col_name||
                        '  FROM ar_receivable_applications_all araa '||
                        '      ,ar_cash_receipts_all acra '||
                        '     ,(SELECT MAX(acra.receipt_date) receipt_date '||
                        '             ,applied_payment_schedule_id '||
                        '         FROM ar.ar_receivable_applications_all araa '||
                        '             ,ar_cash_receipts_all acra '||
                        '        WHERE applied_customer_trx_id = :p_cust_trx_id'||
                        '          AND applied_payment_schedule_id = :p_payment_schedule_id'||
                        '          AND acra.cash_receipt_id = araa.cash_receipt_id '||
                        'GROUP BY applied_payment_schedule_id) maxdt '||
                        ' WHERE araa.applied_payment_schedule_id = maxdt.applied_payment_schedule_id '||
                        '   AND acra.cash_receipt_id = araa.cash_receipt_id '||
                        '   AND acra.receipt_date = maxdt.receipt_date '
          INTO lv_return_val
          USING p_cust_trx_id,p_payment_schedule_id;


    END IF;

    RETURN(lv_return_val);

  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      RETURN('TOO MANY ROWS');

    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(SQLERRM);

  END fnc_rcpt_app_dff;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_cust_info_dff
  -- Purpose: Used to retrieve the DFF field values:
  --            Application: Receivables
  --                  Title: Customer Information
  --                  Table: HZ_CUST_ACCOUNTS
  --
  -- Variables:
  --
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_cust_info_dff (p_cust_acct_id  IN  HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE
                             ,p_column_name   IN  FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE)
    RETURN VARCHAR2 IS

    lv_source     VARCHAR2(30);
    lv_col_name   FND_DESCR_FLEX_COL_USAGE_VL.APPLICATION_COLUMN_NAME%TYPE;
    lv_return_val VARCHAR2(30);
    v_key         lkup_key := p_column_name;
    v_type        lkup_type := 'CUST_INFO_DFF';

    CURSOR c_dff_column(lv_source   VARCHAR2
                       ,lv_column   FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE) IS
      SELECT dff_col.application_column_name
        FROM fnd_descr_flex_contexts_vl dff_context
            ,fnd_descr_flex_col_usage_vl dff_col
       WHERE dff_context.descriptive_flexfield_name = 'RA_CUSTOMERS_HZ'
         AND dff_context.descriptive_flex_context_code = lv_source
         AND dff_col.descriptive_flexfield_name = dff_context.descriptive_flexfield_name
         AND dff_col.descriptive_flex_context_code = dff_context.descriptive_flex_context_code
         AND dff_col.end_user_column_name = lv_column;

  BEGIN


    /* Set source value. */
    lv_source := 'Global Data Elements';

    IF NOT t_lookup.exists(v_type) OR NOT t_lookup(v_type).exists(v_key) THEN
       OPEN c_dff_column(lv_source
                        ,p_column_name);
       FETCH c_dff_column INTO t_lookup(v_type)(v_key);
       CLOSE c_dff_column;
    END IF;

    lv_col_name := t_lookup(v_type)(v_key);
    IF lv_col_name IS NOT NULL THEN
      EXECUTE IMMEDIATE 'SELECT '||lv_col_name||
                        '  FROM ar.hz_cust_accounts '||
                        ' WHERE cust_account_id = :p_cust_acct_id'
          INTO lv_return_val
          USING p_cust_acct_id;

    END IF;

    RETURN(lv_return_val);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(SQLERRM);

  END fnc_cust_info_dff;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_lasttrx_date
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_lasttrx_date(p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE)
    RETURN RA_CUSTOMER_TRX_ALL.TRX_DATE%TYPE IS

    lv_last_trx_date RA_CUSTOMER_TRX_ALL.TRX_DATE%TYPE;

    /* Using cursor since multiples could exist; didn't want to use DISTINCT function. */
    CURSOR c_trx_date (lv_cust_acct_id HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) IS
      SELECT apsa.trx_date
        FROM ar_payment_schedules_all apsa
       WHERE customer_id = lv_cust_acct_id
         AND class = 'INV'
         AND apsa.status = 'OP'
         AND apsa.due_date = (SELECT MAX(trx_date)
                                FROM ar_payment_schedules_all
                               WHERE customer_id = apsa.customer_id
                                 AND class = apsa.class
                                 AND status = apsa.status);

  BEGIN

    OPEN c_trx_date(p_cust_account_id);
    FETCH c_trx_date INTO lv_last_trx_date;

    IF c_trx_date%NOTFOUND THEN
      lv_last_trx_date := NULL;
    END IF;
    CLOSE c_trx_date;

    RETURN(lv_last_trx_date);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      /* Returning value to detect issue with function call. */
      RETURN(TO_DATE('31-DEC-9999','DD-MON-YYYY'));

  END fnc_lasttrx_date;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_base_conversion_rate
  -- Purpose:  Returns the conversion rate to US Dollars (base currency) based on SYSDATE.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_base_conversion_rate(p_from_currency IN GL_DAILY_RATES.FROM_CURRENCY%TYPE)
    RETURN NUMBER IS

    lv_conversion_rate GL_DAILY_RATES.CONVERSION_RATE%TYPE;
    v_key         lkup_key := p_from_currency;
    v_type        lkup_type := 'BASE_CONV_RATE';

  BEGIN

    IF NOT t_lookup.exists(v_type) OR NOT t_lookup(v_type).exists(v_key) THEN

       IF p_from_currency = 'USD' THEN
           t_lookup(v_type)(v_key) := 1;
       ELSE
          SELECT conversion_rate
            INTO t_lookup(v_type)(v_key)
            FROM gl_daily_rates
           WHERE from_currency = p_from_currency
             AND TO_CURRENCY = 'USD'
             AND conversion_type = xxcm_common.get_constant_value('XXGL_RATE_CONVERSION_TYPE')
             AND conversion_date = TRUNC(SYSDATE);
       END IF;

    END IF;

    lv_conversion_rate := t_lookup(v_type)(v_key);

    RETURN(lv_conversion_rate);

  EXCEPTION
    WHEN OTHERS THEN
       xxcm_common.write_log('Problem deriving exchange rate in xxar_getpaid_pkg.fnc_base_conversion_rate');
       raise_application_error(-20001, 'Problem deriving exchange rate in xxar_getpaid_pkg.fnc_base_conversion_rate');

  END fnc_base_conversion_rate;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_last_receipt_nbr
  -- Purpose:  Returns the last receipt (check) number per customer AND transaction (invoice).
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_last_receipt_nbr(p_cust_account_id IN AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_ID%TYPE
                               ,p_trx_number      IN AR_PAYMENT_SCHEDULES_ALL.TRX_NUMBER%TYPE)
    RETURN VARCHAR IS

    lv_receipt  AR_CASH_RECEIPTS_ALL.RECEIPT_NUMBER%TYPE;
    lv_dummy_dt DATE;

    CURSOR c_last_check(lv_cust_account_id AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_ID%TYPE
                       ,lv_trx_number      AR_PAYMENT_SCHEDULES_ALL.TRX_NUMBER%TYPE) IS
      SELECT acra.receipt_number
            ,MAX(acra.receipt_date)
        FROM ar_payment_schedules_all apsa
            ,ar_cash_receipts_all acra
            ,(SELECT apsa.customer_id
                    ,araa.cash_receipt_id
                FROM ar_payment_schedules_all apsa
                    ,ar_receivable_applications_all araa
               WHERE apsa.customer_id = lv_cust_account_id
                 AND apsa.trx_number = lv_trx_number
                 AND araa.applied_payment_schedule_id = apsa.payment_schedule_id) pay_id
       WHERE apsa.customer_id = pay_id.customer_id
         AND acra.cash_receipt_id = pay_id.cash_receipt_id
         AND apsa.cash_receipt_id = acra.cash_receipt_id
         AND apsa.class = 'PMT'
      GROUP BY acra.receipt_number
      ORDER BY MAX(acra.receipt_date) DESC;


  BEGIN

    OPEN c_last_check(p_cust_account_id
                     ,p_trx_number);
    FETCH c_last_check INTO lv_receipt
                           ,lv_dummy_dt;

    IF c_last_check%NOTFOUND THEN
      lv_receipt := NULL;
    END IF;
    CLOSE c_last_check;

    RETURN(lv_receipt);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_last_receipt_nbr;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_functional_conversion_rate
  -- Purpose:  Returns the conversion rate to US Dollars (functional rate) based on SYSDATE.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_functional_conversion_rate(p_org_id             IN RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE
                                         ,p_invc_currency_code IN RA_CUSTOMER_TRX_ALL.INVOICE_CURRENCY_CODE%TYPE)
    RETURN NUMBER IS

    lv_conversion_rate GL_DAILY_RATES.CONVERSION_RATE%TYPE;
    v_key              lkup_key := p_org_id||':'||p_invc_currency_code;
    v_type             lkup_type := 'FNCTN_CONV_RATE';
    v_currency_code    gl_ledgers.currency_code%TYPE;

  BEGIN

    IF NOT t_lookup.exists(v_type) OR NOT t_lookup(v_type).exists(v_key) THEN

          SELECT gsob.currency_code
            INTO v_currency_code
            FROM hr_operating_units hou
               ,gl_ledgers gsob
          WHERE hou.organization_id = p_org_id
            AND gsob.ledger_id = hou.set_of_books_id;

          IF p_invc_currency_code = v_currency_code
          THEN
             t_lookup(v_type)(v_key) := 1;
          ELSE
             SELECT gdr.conversion_rate
               INTO t_lookup(v_type)(v_key)
               FROM gl_daily_rates gdr
              WHERE from_currency = p_invc_currency_code
                AND to_currency = v_currency_code
                AND conversion_type = xxcm_common.get_constant_value('XXGL_RATE_CONVERSION_TYPE')
                AND conversion_date =  TRUNC(SYSDATE);

          END IF;
    END IF;

    lv_conversion_rate := t_lookup(v_type)(v_key);

    RETURN(lv_conversion_rate);

  EXCEPTION
    WHEN OTHERS THEN
      xxcm_common.write_log('Problem deriving exchange rate in xxar_getpaid_pkg.fnc_functional_conversion_rate');
      raise_application_error(-20001, 'Problem deriving exchange rate in xxar_getpaid_pkg.fnc_functional_conversion_rate');

  END fnc_functional_conversion_rate;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_get_parent
  -- Purpose:  Returns the parent customer number.  If the incoming value (child) is the parent
  --           the function will NOT return a value.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_get_parent (p_child IN HZ_PARTIES.PARTY_ID%TYPE) RETURN VARCHAR2 IS

    lv_parent  HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE;

  BEGIN

    SELECT hca.account_number
      INTO lv_parent
      FROM hz_parties hp
          ,hz_relationships hr
          ,hz_cust_accounts hca
     WHERE hp.party_id = p_child
       AND hr.relationship_code = 'PARENT_OF'
       AND hr.subject_table_name = 'HZ_PARTIES'
       AND hr.object_table_name = 'HZ_PARTIES'
       AND hr.object_type = 'ORGANIZATION'
       /* object_id = holding company (parent) */
       AND hr.object_id = hp.party_id
       AND hca.party_id = hr.subject_id
       /* comment out above and uncomment below to get all the children if passing in the parent */
       /* and hr.relationship_code = 'SUBSIDIARY_OF' */
       /* and hr.object_id = hp.party_id */;

    /* Not returning the parent if the child is the parent. */
    IF (p_child = lv_parent) THEN
      lv_parent := NULL;
    END IF;

    RETURN(lv_parent);


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_get_parent;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_get_org_id
  -- Purpose:  Returns the org_id for the customer based on the location information.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_get_org_id (p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE
                          ,p_location_id     IN HZ_LOCATIONS.LOCATION_ID%TYPE)
    RETURN NUMBER IS

    lv_org_id  HZ_CUST_ACCT_SITES_ALL.ORG_ID%TYPE;

  BEGIN

    SELECT acct_site.org_id
      INTO lv_org_id
      FROM hz_cust_accounts hca
          ,hz_parties hp
          ,hz_cust_acct_sites_all acct_site
          ,hz_party_sites party_site
          ,hz_locations hl
     WHERE hca.cust_account_id = p_cust_account_id
       and hl.location_id = p_location_id
       AND hp.party_id = hca.party_id
       AND acct_site.party_site_id = party_site.party_site_id
       AND hl.location_id = party_site.location_id;


    RETURN(lv_org_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_get_org_id;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_crdt_classificaton
  -- Purpose:  Returns the credit classificaton meaning at the customer header level NOT site.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_crdt_classification (p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE)
    RETURN VARCHAR2 IS

    lv_credit_class_meaning     FND_FLEX_VALUES_VL.DESCRIPTION%TYPE;


  BEGIN

    SELECT ffvv.description
      INTO lv_credit_class_meaning
      FROM fnd_flex_values_vl ffvv
          ,fnd_flex_value_sets ffvs
          ,(SELECT arpt_sql_func_util.get_lookup_meaning('AR_CMGT_CREDIT_CLASSIFICATION', hcp.CREDIT_CLASSIFICATION) credit_classification_meaning
              FROM hz_customer_profiles hcp
             WHERE hcp.cust_account_id = p_cust_account_id
               AND hcp.site_use_id IS NULL) ccm
     WHERE ffvs.flex_value_set_name = 'XXAR_GETPAID_ARCUST_SALESMN_FIELD'
       AND ffvs.flex_value_set_id = ffvv.flex_value_set_id
       AND ffvv.enabled_flag = 'Y'
       AND TRUNC(SYSDATE) BETWEEN TRUNC(ffvv.start_date_active) AND TRUNC(NVL(ffvv.end_date_active,SYSDATE))
       AND ffvv.flex_value = UPPER(ccm.credit_classification_meaning);

    RETURN(lv_credit_class_meaning);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_crdt_classification;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_contact_name
  -- Purpose:  Returns the either the first or last name of the contact at the header level.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_contact_name (p_party_id IN HZ_PARTIES.PARTY_ID%TYPE
                            ,p_fname    IN VARCHAR2) RETURN VARCHAR2 IS

    lv_fname  HZ_PERSON_PROFILES.PERSON_FIRST_NAME%TYPE;
    lv_lname  HZ_PERSON_PROFILES.PERSON_LAST_NAME%TYPE;

  BEGIN

    SELECT hpp.person_first_name
          ,hpp.person_last_name
      INTO lv_fname
          ,lv_lname
      FROM hz_parties hp
          ,hz_relationships hr
          ,hz_person_profiles hpp
     WHERE hp.party_id = p_party_id
       AND hr.relationship_code = 'CONTACT_OF'
       AND hr.object_id = hp.party_id
       AND hpp.party_id = hr.subject_id
       AND hr.direction_code = 'P'
       and ROWNUM = 1;

    IF (p_fname = 'Y') THEN
      RETURN(lv_fname);
    ELSE
      RETURN (lv_lname);
    END IF;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_contact_name;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_order_date
  -- Purpose:  Returns the order date associated billing transaction.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_order_date (p_ar_trx_number IN XXBS_CUSTOMER_TRX.AR_TRX_NUMBER%TYPE)
    RETURN DATE IS
   --BC 20210212 comment out this variable
    --lv_order_date XXCG_PROJECT_DATA.ORDER_DATE%TYPE;

  BEGIN
   --BC 20210212 comment out this function body
   /*
    SELECT TRUNC(xpd.order_date)
      INTO lv_order_date
      FROM xxbs_customer_trx xct
          ,xxbs_project_trx_matrix xptm
          ,xxcg_project_data xpd
     WHERE xct.ar_trx_number = p_ar_trx_number
       AND xptm.customer_trx_id = xct.customer_trx_id
       AND xpd.project_id = xptm.project_id;

      RETURN (lv_order_date);
    */
    return (NULL);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_order_date;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_applied_to
  -- Purpose:  Returns a Yes/No value if the applied to payment schedule id maps to the appropriate trx number.
  --           This function was created to resolve a performance fix on the ap_payment_schedules_all table when
  --           the ar_receivables_applications_all table was joined to it via the applied_payment_schedule_id field.
  --           That is the sole purpose of this function.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_applied_to (p_applied_id IN AR_RECEIVABLE_APPLICATIONS_ALL.APPLIED_PAYMENT_SCHEDULE_ID%TYPE
                          ,p_trx_number IN AR_PAYMENT_SCHEDULES_ALL.TRX_NUMBER%TYPE)
    RETURN VARCHAR2 IS

    lv_dummy  VARCHAR2(1);
    lv_return VARCHAR2(1) := 'N';

    CURSOR c_rec_exists (lv_applied    AR_RECEIVABLE_APPLICATIONS_ALL.APPLIED_PAYMENT_SCHEDULE_ID%TYPE
                        ,lv_trx_number  AR_PAYMENT_SCHEDULES_ALL.TRX_NUMBER%TYPE)  IS
     SELECT 'X'
       FROM ar_payment_schedules_all
      WHERE trx_number = lv_trx_number
        AND payment_schedule_id = lv_applied;

  BEGIN

    OPEN c_rec_exists(p_applied_id
                     ,p_trx_number);
    FETCH c_rec_exists INTO lv_dummy;

    IF c_rec_exists%FOUND THEN
      lv_return := 'Y';
    END IF;
    CLOSE c_rec_exists;

    RETURN(lv_return);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(lv_return);

  END fnc_applied_to;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_applied_trx_nbr
  -- Purpose:  Returns the applied to Transaction Number associated to the applied_customer_trx_id
  --           from the ar_receivable_application_all table.
  --
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_applied_trx_nbr (p_cust_trx_id IN AR_RECEIVABLE_APPLICATIONS_ALL.APPLIED_CUSTOMER_TRX_ID%TYPE)
    RETURN VARCHAR2 IS

    lv_trx_nbr RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE;
    lv_return  RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE := NULL;

    CURSOR c_trx_number (lv_cust_trx_id IN AR_RECEIVABLE_APPLICATIONS_ALL.APPLIED_CUSTOMER_TRX_ID%TYPE)  IS
      SELECT trx_number
        FROM ra_customer_trx_all
       WHERE customer_trx_id = lv_cust_trx_id;

  BEGIN

    OPEN c_trx_number(p_cust_trx_id);
    FETCH c_trx_number INTO lv_trx_nbr;

    IF c_trx_number%FOUND THEN
      lv_return := lv_trx_nbr;
    END IF;
    CLOSE c_trx_number;

    RETURN(lv_return);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(SQLERRM);

  END fnc_applied_trx_nbr;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_amt_due_remaining
  -- Purpose:
  --
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_amt_due_remaining (p_cust_acct_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE)
    RETURN NUMBER IS

    lv_amt  NUMBER := 0;

    CURSOR c_amt (lv_cust_acct_id HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE)  IS
--      SELECT SUM(inv_amt.amt + pmt_amt.amt)
--        FROM (SELECT SUM(amount_due_remaining) amt
--                FROM ar_payment_schedules_all apsa
--               WHERE customer_id = lv_cust_acct_id
--                 AND class = 'INV'
--                 AND apsa.status = 'OP') inv_amt
--            ,(SELECT SUM(amount_due_remaining) amt
--                FROM ar_payment_schedules_all apsa
--               WHERE customer_id = lv_cust_acct_id
--                 AND class = 'PMT'
--                 AND apsa.status = 'OP') pmt_amt;
      SELECT SUM(amount_due_remaining) amt
        FROM ar_payment_schedules_all apsa
       WHERE customer_id = lv_cust_acct_id
         AND class = 'INV'
         AND apsa.status = 'OP';


  BEGIN

    OPEN c_amt(p_cust_acct_id);
    FETCH c_amt INTO lv_amt;
    CLOSE c_amt;

    RETURN(lv_amt);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(SQLERRM);

  END fnc_amt_due_remaining;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_currency_code
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_currency_code(p_org_id IN RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE) RETURN VARCHAR2 IS

    lv_currency_code GL_LEDGERS.CURRENCY_CODE%TYPE;           --Added for R12 Upgrade
    v_key            lkup_key := p_org_id;
    v_type           lkup_type := 'CURR_CODE';

  BEGIN

    IF NOT t_lookup.exists(v_type) OR NOT t_lookup(v_type).exists(v_key) THEN
       SELECT gsob.currency_code
         INTO t_lookup(v_type)(v_key)
         FROM hr_operating_units hou
            ,gl_ledgers gsob       --Added for R12 Upgrade
        WHERE hou.organization_id = p_org_id
            AND gsob.ledger_id = hou.set_of_books_id --Added for R12 Upgrade
            ;
    END IF;

    lv_currency_code := t_lookup(v_type)(v_key);

    RETURN(lv_currency_code);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_currency_code;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_site_exists
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_site_exists(p_site IN XXAR_GETPAID_CUSTOMER_MAPPING.SITE_FROM%TYPE)
    RETURN BOOLEAN IS

    lv_return  BOOLEAN := FALSE;
    lv_dummy   VARCHAR2(1);
    v_key         lkup_key := p_site;
    v_type        lkup_type := 'SITE';

    CURSOR c_exists (lv_site XXAR_GETPAID_CUSTOMER_MAPPING.SITE_FROM%TYPE) IS
      SELECT 'X'
        FROM xxar_getpaid_customer_mapping
       WHERE lv_site BETWEEN site_from AND site_to;

  BEGIN

    IF NOT t_lookup.exists(v_type) OR NOT t_lookup(v_type).exists(v_key) THEN
       OPEN c_exists(p_site);
       FETCH c_exists INTO t_lookup(v_type)(v_key);
       CLOSE c_exists;
    END IF;

    lv_return := (t_lookup(v_type)(v_key) IS NOT NULL);

    RETURN(lv_return);


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(FALSE);

    WHEN OTHERS THEN
      RETURN(FALSE);

  END fnc_site_exists;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_remove_ascii_ext
  -- Purpose:  Converts a varchar variable to Hexidecimal and then back again to ASCII to
  --           strip off any ASCII extended characters.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_remove_ascii_ext(p_string VARCHAR2) RETURN VARCHAR2 IS

    lv_string_in   VARCHAR2(4000);
    lv_string_out  VARCHAR2(4000);


  BEGIN

    /* Assign string to local variable. */
    lv_string_in := p_string;

    SELECT  REPLACE(SYS_CONNECT_BY_PATH(CHR(TO_NUMBER(SUBSTR(a.hex,2 * level - 1,2),'xx')),','),',')
      INTO lv_string_out
      FROM (SELECT HEXTORAW(RAWTOHEX(lv_string_in)) hex
              FROM dual )a,
           (SELECT level lvl
              FROM dual
            CONNECT BY level < (SELECT MAX(LENGTH(a.hex)) / 2 + 1
                                  FROM (SELECT HEXTORAW(RAWTOHEX(lv_string_in)) hex
                                          FROM DUAL) a ))
     WHERE CONNECT_BY_ISLEAF = 1
    START WITH lvl = 1
    CONNECT BY hex = PRIOR hex
           AND lvl = PRIOR lvl + 1
           AND level < length(hex) / 2 + 1;

    RETURN(lv_string_out);

  EXCEPTION

    /* If the SELECT stmt. cannot handle the incoming string then send it right back. */
    WHEN OTHERS THEN
      RETURN(lv_string_in);

  END fnc_remove_ascii_ext;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_remove_special_chr
  -- Purpose: Removes all special characters from the incoming string and replaces it with the
  --          value in the p_replacment_chr field.
  -- Variables: p_string - string to be cleaned.
  --            p_replacement_chr - ASCII value.
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_remove_special_chr (p_string          IN VARCHAR2
                                  ,p_replacement_chr IN NUMBER) RETURN VARCHAR IS

    lv_ascii       NUMBER := 0;
    lv_ascii_max   NUMBER := 255; /* Total number of all ascii characters to loop through. */
    lv_ascii_found VARCHAR2(1);

    lv_text         VARCHAR2(1000);
    lv_updated_text VARCHAR2(1000);
    lv_errbuf       VARCHAR2(250);

    /* Cursor to detect if CHR value exists in text. */
    CURSOR c_string (lv_var   VARCHAR2
                  ,lv_ascii NUMBER) IS
      SELECT DECODE(INSTRB(lv_var, CHR(lv_ascii)),0,'N','Y')
        FROM dual;

  BEGIN

    /* Set local variable. */
    lv_text := p_string;

    IF (lv_text IS NOT NULL) THEN
      /* Loop through all the ASCII codes and remove those characters not valid for GetPaid. */
      WHILE (lv_ascii <= lv_ascii_max)
      LOOP

        OPEN c_string(lv_text
                     ,lv_ascii);
        FETCH c_string INTO lv_ascii_found;

        IF c_string%FOUND THEN
          IF (lv_ascii_found = 'Y') THEN
            IF (XXAR_GETPAID_PKG.fnc_special_chr(lv_ascii)) THEN
              XXAR_GETPAID_PKG.prc_remove_special_chr(lv_text
                                                     ,lv_ascii
                                                     ,p_replacement_chr
                                                     ,lv_updated_text
                                                     ,lv_errbuf);
              lv_text := lv_updated_text;
            END IF;
          END IF;
        END IF;

        IF c_string%ISOPEN THEN
          CLOSE c_string;
        END IF;

        /* Increment to the next ASCII character. */
        lv_ascii := lv_ascii + 1;

      END LOOP;
    END IF;

    RETURN (lv_text);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_remove_special_chr;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_translate
  -- Purpose:  Removes all special characters from the incoming string being passed in and
  --           returns that value back to the calling program.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_translate (p_varchar VARCHAR2) RETURN VARCHAR IS

    lv_return VARCHAR2(1000);

  BEGIN

    /* To see values, copy and paste into Toad.*/
    SELECT TRANSLATE(p_varchar,'�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�'
                             ,'S,s,z,Y,A,A,A,A,A,A,C,E,E,E,E,I,I,I,I,N,O,O,O,O,O,U,U,U,U,Y,a,a,a,a,a,a,c,e,e,e,e,i,i,i,i,n,o,o,o,o,o,u,u,u,u,y')
      INTO lv_return
      FROM dual;

    RETURN(lv_return);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_translate;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_special_chr
  -- Purpose: Determines if the ascii value being passed in is deemed a special character by the function.
  --
  -- Variables: p_ascii - ASCII value to search on.
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_special_chr(p_ascii IN NUMBER) RETURN BOOLEAN IS

   lv_return BOOLEAN := FALSE;

  BEGIN
    IF ((p_ascii BETWEEN 0 AND 31) OR
        (p_ascii BETWEEN 127 AND 255)
       ) THEN
       lv_return := TRUE;

       /* Debug */
       IF (pkg_v_debug = 'Y') THEN
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' Found Special Character: CHR('||p_ascii||')');
       END IF;
    END IF;

    RETURN(lv_return);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN(FALSE);

  END fnc_special_chr;


  -----------------------------------------------------------------------------------------
  -- Function: fnc_oac_balance
  -- Purpose: Returns the On Account Cash balance ONLY.  Used by the ARCUST file.
  --
  -- Variables: .
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_oac_balance(p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE)
    RETURN NUMBER IS


    lv_balance NUMBER := 0;
    lv_return  NUMBER := 0;

    CURSOR c_on_account (lv_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) IS
      SELECT SUM(ROUND(((araa.amount_applied * XXAR_GETPAID_PKG.fnc_base_conversion_rate(acra.currency_code))* -1),2)) balance    /* Multiplying by -1 to flip the sign on OAC */
        FROM hz_cust_accounts hca
            ,ar_payment_schedules_all apsa
            ,ar_cash_receipts_all acra
            ,ar_cash_receipt_history_all acrh
            ,ar_batches_all aba
            ,ce_bank_acct_uses_all abaa  --Added for R12 Upgrade
            ,ar_receivable_applications_all araa
            ,hr_all_organization_units haou
            ,ar_receipt_methods arm
           WHERE apsa.customer_id = lv_cust_account_id
             AND apsa.customer_id = hca.cust_account_id
             AND acra.cash_receipt_id = apsa.cash_receipt_id
             AND acrh.cash_receipt_id = acra.cash_receipt_id
             AND acrh.batch_id = aba.batch_id
             AND abaa.bank_acct_use_id = aba.remit_bank_acct_use_id      --Added for R12 Upgrade
             AND araa.cash_receipt_id = acra.cash_receipt_id
             AND haou.organization_id = acra.org_id
             AND acra.receipt_method_id = arm.receipt_method_id
             /* On Account designation */
             AND araa.status = 'ACC'
             AND araa.display = 'Y'
             AND NOT EXISTS (SELECT ffvv.description
                               FROM fnd_flex_values_vl ffvv
                                   ,fnd_flex_value_sets ffvs
                              WHERE ffvs.flex_value_set_name = 'XXAR_GETPAID_OP_UNITS_EXCLUDE'
                                AND ffvs.flex_value_set_id = ffvv.flex_value_set_id
                                AND ffvv.enabled_flag = 'Y'
                                AND TRUNC(SYSDATE) BETWEEN TRUNC(ffvv.start_date_active) AND TRUNC(NVL(ffvv.end_date_active,SYSDATE))
                              AND ffvv.description = apsa.org_id);

  BEGIN

    OPEN c_on_account(p_cust_account_id);
    FETCH c_on_account INTO lv_balance;

    IF c_on_account%FOUND THEN
      lv_return := lv_balance;
    END IF;
    CLOSE c_on_account;

    RETURN(lv_return);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN(0);

  END fnc_oac_balance;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_get_gp_group_id
  -- Purpose: Returns the GetPaid Group ID from the customer mapping table.
  --
  -- Variables: .
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_get_gp_group_id (p_org_id              IN HZ_CUST_ACCT_SITES_ALL.ORG_ID%TYPE
                               ,p_collection_status   IN VARCHAR2
                               ,p_managed_cust        IN VARCHAR2
                               ,p_large_cust          IN VARCHAR2
                               ,p_business            IN fnd_flex_values.attribute2%TYPE   --Added for R12 Upgrade COA changes
                               ,p_site                IN GL_CODE_COMBINATIONS.SEGMENT3%TYPE)
    RETURN XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE RESULT_CACHE IS

    lv_gp_group_id        XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE;
    lv_collection_type_id XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE;

  BEGIN

    XXAR_GETPAID_PKG.prc_derive_gp_breakout (p_org_id
                                            ,p_collection_status
                                            ,p_managed_cust
                                            ,p_large_cust
                                            ,p_business
                                            ,p_site
                                            ,lv_gp_group_id
                                            ,lv_collection_type_id);

    RETURN(lv_gp_group_id);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_get_gp_group_id;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_get_collection_type
  -- Purpose: Returns the GetPaid collection type from the customer mapping table.
  --
  -- Variables: .
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_get_collection_type (p_org_id              IN HZ_CUST_ACCT_SITES_ALL.ORG_ID%TYPE
                                   ,p_collection_status   IN VARCHAR2
                                   ,p_managed_cust        IN VARCHAR2
                                   ,p_large_cust          IN VARCHAR2
                                   ,p_business            IN fnd_flex_values.attribute2%TYPE     --Added for R12 Upgrade COA Changes
                                   ,p_site                IN GL_CODE_COMBINATIONS.SEGMENT3%TYPE)
    RETURN XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE RESULT_CACHE IS

    lv_gp_group_id        XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE;
    lv_collection_type_id XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE;

  BEGIN

    XXAR_GETPAID_PKG.prc_derive_gp_breakout (p_org_id
                                            ,p_collection_status
                                            ,p_managed_cust
                                            ,p_large_cust
                                            ,p_business
                                            ,p_site
                                            ,lv_gp_group_id
                                            ,lv_collection_type_id);

    RETURN(lv_collection_type_id);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_get_collection_type;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_get_collection_type (OVERLOAD)
  -- Purpose: Returns the GetPaid collection type from the customer mapping table.
  --
  -- Variables: .
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_get_collection_type (p_gp_group_id IN XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE)
    RETURN XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE IS

    lv_collection_type_id XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE;

  BEGIN

    SELECT DISTINCT(collection_type_id)
      INTO lv_collection_type_id
      FROM xxar_getpaid_customer_mapping
     WHERE gp_group_id = p_gp_group_id;

    RETURN(lv_collection_type_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_get_collection_type;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_get_file_destination
  -- Purpose:
  --
  -- Variables:
  --
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_get_file_destination RETURN VARCHAR2 IS

    lv_destination  FND_FLEX_VALUES_VL.DESCRIPTION%TYPE;

  BEGIN

    lv_destination := xxcm_common.get_db_constant('RPT_EXTRACT_DIR');

    /* Destination of the reports being generated by the separate file runs. */
/*    SELECT ffvv.description
      INTO lv_destination
      FROM fnd_flex_values_vl ffvv
          ,fnd_flex_value_sets ffvs
     WHERE ffvs.flex_value_set_name = 'XXCM_CONSTANTS'
       AND ffvs.flex_value_set_id = ffvv.flex_value_set_id
       AND ffvv.flex_value = 'BACHDATA_EXTRACTS'
       AND TRUNC(SYSDATE) BETWEEN TRUNC(ffvv.start_date_active) AND TRUNC(NVL(ffvv.end_date_active,SYSDATE));
*/
    RETURN(lv_destination);


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);

    WHEN OTHERS THEN
      RETURN(NULL);

  END fnc_get_file_destination;

  -----------------------------------------------------------------------------------------
  -- Procedure:prc_remove_special_chr
  -- Purpose: Removes the ascii character from the incoming text value.
  --
  -- Variables: p_string_in - Contains the data to needs to be cleaned of the ascii character.
  --            p_chr_ascii - ASCII value to search on.
  --            p_chr_replace - ASCII value to replace the p_chr_ascii with.
  --            p_string_out - Contains the "cleand" string back to the calling function.
  --            p_errbuf - Catches sql errors.
  -----------------------------------------------------------------------------------------
  PROCEDURE prc_remove_special_chr (p_string_in    IN VARCHAR2
                                   ,p_chr_ascii    IN NUMBER
                                   ,p_chr_replace  IN NUMBER
                                   ,p_string_out  OUT VARCHAR2
                                   ,p_errbuf      OUT VARCHAR2) IS

     lv_string_cleaned  VARCHAR2(4000);

   BEGIN

     IF (p_chr_replace IS NULL) THEN
       SELECT REPLACE(p_string_in, CHR(p_chr_ascii))
         INTO lv_string_cleaned
         FROM dual;
     ELSE
       SELECT REPLACE(p_string_in, CHR(p_chr_ascii), CHR(p_chr_replace))
         INTO lv_string_cleaned
         FROM dual;

     END IF;
     /* Checking for ascii extended characters since a replace may not remove them entirely. */
     p_string_out := XXAR_GETPAID_PKG.fnc_remove_ascii_ext(lv_string_cleaned);
     --p_string_out := lv_string_cleaned;

   EXCEPTION
     WHEN OTHERS THEN
       p_errbuf := SUBSTR(SQLERRM, 1, 250);

   END prc_remove_special_chr;


  -----------------------------------------------------------------------------------------
  -- Procedure:prc_derive_gp_breakout
  -- Purpose:  Derives the GetPaid breakout for the customer record by first looking to see if
  --           the initial site being passed in (with the incoming values) determine what the
  --           GP breakout is.  If not then the procedure loops through the Hyperion parent
  --           sites to find a site that matches to the xxar_getpaid_customer_mapping table.
  --
  -- Variables:
  -----------------------------------------------------------------------------------------
  PROCEDURE prc_derive_gp_breakout (p_org_id              IN HZ_CUST_ACCT_SITES_ALL.ORG_ID%TYPE
                                   ,p_collection_status   IN VARCHAR2
                                   ,p_managed_cust        IN VARCHAR2
                                   ,p_large_cust          IN VARCHAR2
                                   ,p_business            IN fnd_flex_values.attribute2%TYPE   --Added for R12 Upgrade COA Changes
                                   ,p_site                IN GL_CODE_COMBINATIONS.SEGMENT3%TYPE
                                   ,p_gp_group_id        OUT XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE
                                   ,p_collection_type_id OUT XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE) IS

    lv_search             BOOLEAN := TRUE;
    lv_gp_group_id        XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE;
    lv_collection_type_id XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE;
    lv_site               FND_FLEX_VALUES.FLEX_VALUE%TYPE;
    lv_counter            NUMBER := 0;

    /* Only look at the immediate parent and NOT immediately drill up to the root. */
    CURSOR c_hyperion_parent (lv_site VARCHAR2) IS
      SELECT ffv.flex_value
        FROM fnd_flex_values ffv
           ,(SELECT h.parent_flex_value
                  , v.flex_value site
                  , v.value_category flex_name
               FROM fnd_flex_values            v
                 join fnd_flex_value_norm_hierarchy h on ( h.flex_value_set_id = v.flex_value_set_id )
             WHERE v.value_category = 'XXGL_R12_SITE'
               AND v.flex_value BETWEEN h.child_flex_value_low
                                    AND h.child_flex_value_high
               AND flex_value = lv_site) a
       WHERE ffv.flex_value = a.parent_flex_value
         AND ffv.attribute2 = 'PRIMARY'
         AND ffv.value_category = a.flex_name;

  BEGIN

    /* Get GP group id based solely on incoming parameters. */
    XXAR_GETPAID_PKG.prc_get_gp_breakout (p_org_id
                                         ,p_collection_status
                                         ,p_managed_cust
                                         ,p_large_cust
                                         ,p_business
                                         ,p_site
                                         ,lv_gp_group_id
                                         ,lv_collection_type_id);

    p_gp_group_id        := lv_gp_group_id;
    p_collection_type_id := lv_collection_type_id;


    /* No GP group id based on initial values, so cycle through the Hyperion structure to find one.  If one not found then use DEFAULT as GP group id. */
    IF (lv_gp_group_id = 'DEFAULT') THEN

      /* Using variable to programatically update the site if needed to drill up the Hyperion structure. */
      lv_site := p_site;

      OPEN c_hyperion_parent(lv_site);
      FETCH c_hyperion_parent INTO lv_site;
      IF c_hyperion_parent%FOUND THEN
        LOOP
          lv_counter := lv_counter + 1;
          XXAR_GETPAID_PKG.prc_get_gp_breakout (p_org_id
                                               ,p_collection_status
                                               ,p_managed_cust
                                               ,p_large_cust
                                               ,p_business
                                               ,lv_site
                                               ,lv_gp_group_id
                                               ,lv_collection_type_id);

          IF (lv_gp_group_id = 'DEFAULT') THEN
            IF c_hyperion_parent%ISOPEN THEN
              CLOSE c_hyperion_parent;
            END IF;

            OPEN c_hyperion_parent(lv_site);
            FETCH c_hyperion_parent INTO lv_site;
            IF c_hyperion_parent%NOTFOUND THEN
              p_gp_group_id        := lv_gp_group_id;
              p_collection_type_id := lv_collection_type_id;
              EXIT;
            END IF;
            CLOSE c_hyperion_parent;
          ELSE
            p_gp_group_id        := lv_gp_group_id;
            p_collection_type_id := lv_collection_type_id;
            EXIT;
          END IF;

          -- Failsafe to prevent looping going out of control
          EXIT WHEN lv_counter > 15;
        END LOOP;
      END IF;
      CLOSE c_hyperion_parent;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END prc_derive_gp_breakout;

  -----------------------------------------------------------------------------------------
  -- Procedure:prc_get_gp_breakout
  -- Purpose:  Passes back the GetPaid Group ID and Collection Type ID from the custom
  --           mapping table based on the org_id from the customer record.
  -- Variables:
  -----------------------------------------------------------------------------------------
  PROCEDURE prc_get_gp_breakout (p_org_id              IN HZ_CUST_ACCT_SITES_ALL.ORG_ID%TYPE
                                ,p_collection_status   IN VARCHAR2
                                ,p_managed_cust        IN VARCHAR2
                                ,p_large_cust          IN VARCHAR2
                                ,p_business            IN fnd_flex_values.attribute2%TYPE      --Added for R12 Upgrade COA Changes
                                ,p_site                IN GL_CODE_COMBINATIONS.SEGMENT3%TYPE
                                ,p_gp_group_id        OUT XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE
                                ,p_collection_type_id OUT XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE) IS

    lv_gp_group_id      XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE;
    lv_collection_type  XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE;

   /* Reference cursor variable setup for Dynamic SQL */
    TYPE lv_data_ref IS REF CURSOR;
    lv_data_results  lv_data_ref;

    /* Dynamic SQL variables */
    lv_dyn_gp_group_id      XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE;
    lv_dyn_collection_type  XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE;

    --------------------------------------------------------------------------------------------------------
    -- Procedure: GP_DATA
    -- Purpose: Builds the WHERE clause and executes the dynamic SQL to retrieve GetPaid Group ID and Collection Type ID.
    --
    -- Variables: p_customer_nbr...p_product_vertical: <self explanatory>
    --            p_results - returns the outcome of the query to this variable, which is of type REF CURSOR.
    --------------------------------------------------------------------------------------------------------
    PROCEDURE gp_data(p_org_id            IN  HZ_CUST_ACCT_SITES_ALL.ORG_ID%TYPE
                     ,p_collection_status IN  VARCHAR2
                     ,p_managed_cust      IN  VARCHAR2
                     ,p_large_cust        IN  VARCHAR2
                     ,p_business          IN  fnd_flex_values.attribute2%TYPE       --Added for R12 Upgrade COA Changes
                     ,p_site              IN  GL_CODE_COMBINATIONS.SEGMENT3%TYPE
                     ,p_results        IN OUT lv_data_ref) IS

      lv_slct         VARCHAR2(10000);
      lv_mgd_where    VARCHAR2(3000);  /* Managed Customer */
      lv_lrg_where    VARCHAR2(3000);  /* Large Customer */
      lv_bus_where    VARCHAR2(3000);  /* Reporting Unit */
      lv_ste_where    VARCHAR2(3000);  /* Site */

      BEGIN

        IF (p_collection_status = 'REGULAR') THEN

          IF (p_managed_cust IS NOT NULL) THEN
            lv_mgd_where := ' AND managed_customer = '||''''||p_managed_cust||''''||' ';
          ELSE
            --lv_mgd_where := ' AND managed_customer IS NULL '||' ';
            lv_mgd_where := ' AND managed_customer = '||''''||'N'||''''||' ';
          END IF;

          IF (p_managed_cust = 'N') THEN
            IF (p_business NOT BETWEEN '2000' AND '5999') THEN
              IF (p_large_cust IS NOT NULL) THEN
                lv_lrg_where := ' AND large_customer = '||''''||p_large_cust||''''||' ';
              ELSE
                --lv_lrg_where := ' AND large_customer IS NULL '||' ';
                lv_lrg_where := ' AND large_customer =   '||''''||'N'||''''||' ';
              END IF;
            END IF;

            IF (p_business IS NOT NULL) THEN
              lv_bus_where := ' AND reporting_unit = '||''''||p_business||''''||' ';
            END IF;

            IF (p_site IS NOT NULL) THEN
              lv_ste_where := ' AND '||''''||p_site||''''||' BETWEEN site_from AND site_to ';
            END IF;
          END IF;
        ELSE
          /* Stage 1 customers. */
          lv_mgd_where := ' AND managed_customer = '||''''||'N'||''''||' ';
          lv_lrg_where := ' AND large_customer =   '||''''||'N'||''''||' ';
          lv_bus_where := ' AND reporting_unit =   '||''''||'ALL'||''''||' ';

        END IF;

        lv_slct := 'SELECT gp_group_id '||
                         ',collection_type_id '||
                     'FROM xxar_getpaid_customer_mapping '||
                     ' WHERE organization_id = '||p_org_id||' '||
                     lv_mgd_where||' '||
                     lv_lrg_where||' '||
                     lv_bus_where||' '||
                     lv_ste_where;

        /* Debug: Displays the SELECT stmt. built to the View Output section of the concurrent request. */
        IF (pkg_v_debug = 'Y') THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  Dynamic SELECT stmt. = '||lv_slct);
        END IF;

      OPEN p_results FOR lv_slct;

    END gp_data;

  BEGIN

    /* Collection Type of "Stage 2" should not be processed by GetPaid but should be sent so business can correct status. */
    IF (p_collection_status = 'STAGE 2') THEN
      lv_gp_group_id     := 'DEFAULT';
      lv_collection_type := NULL;

      /* Debug */
      IF (pkg_v_debug = 'Y') THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'- Record set to DEFAULT due to Collection Type of STAGE 2.');
      END IF;

    ELSE
      /* Dynamic SQL procedure */
      gp_data(p_org_id
             ,p_collection_status
             ,p_managed_cust
             ,p_large_cust
             ,p_business
             ,p_site
             ,lv_data_results);

      FETCH lv_data_results INTO lv_dyn_gp_group_id
                                ,lv_dyn_collection_type;

      /* No Data Found, return 'DEFAULT' on group id */
      lv_gp_group_id      := NVL(lv_dyn_gp_group_id,'DEFAULT');
      lv_collection_type  := lv_dyn_collection_type;

    END IF;

    p_gp_group_id        := lv_gp_group_id;
    p_collection_type_id := lv_collection_type;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END prc_get_gp_breakout;

  -----------------------------------------------------------------------------------------
  -- Procedure:prc_get_party_data
  -- Purpose:  Passes back the party data (name, address, city, state, zip) based on the
  --           customer number and site use being passed in.
  -- Variables:
  -----------------------------------------------------------------------------------------
  PROCEDURE prc_get_party_data (p_cust_account_id  IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE
                               ,p_site_use_id      IN HZ_CUST_SITE_USES_ALL.SITE_USE_ID%TYPE
                               ,p_party_name      OUT HZ_PARTIES.PARTY_NAME%TYPE
                               ,p_address1        OUT HZ_LOCATIONS.ADDRESS1%TYPE
                               ,p_address2        OUT HZ_LOCATIONS.ADDRESS2%TYPE
                               ,p_city            OUT HZ_LOCATIONS.CITY%TYPE
                               ,p_state           OUT HZ_LOCATIONS.STATE%TYPE
                               ,p_postal_code     OUT HZ_LOCATIONS.POSTAL_CODE%TYPE) IS

    lv_party_id    HZ_PARTIES.PARTY_ID%TYPE;
    lv_party_name  HZ_PARTIES.PARTY_NAME%TYPE;
    lv_address1    HZ_LOCATIONS.ADDRESS1%TYPE;
    lv_address2    HZ_LOCATIONS.ADDRESS2%TYPE;
    lv_city        HZ_LOCATIONS.CITY%TYPE;
    lv_state       HZ_LOCATIONS.STATE%TYPE;
    lv_postal_code HZ_LOCATIONS.POSTAL_CODE%TYPE;
    lv_country     HZ_LOCATIONS.COUNTRY%TYPE;

    CURSOR c_party_name (lv_cust_account_id HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) IS
      SELECT hp.party_id
            ,hp.party_name
        FROM hz_cust_accounts hca
            ,hz_parties hp
       WHERE hca.party_id = hp.party_id
         AND hca.cust_account_id = lv_cust_account_id;

    CURSOR c_party_addr (lv_site_use_id HZ_CUST_SITE_USES_ALL.SITE_USE_ID%TYPE) IS
      SELECT hl.address1
            ,hl.address2
            ,hl.city
            ,hl.postal_code
            ,hl.state
            ,hl.country
        FROM hz_cust_site_uses_all siteu
            ,hz_cust_acct_sites_all sitea
            ,hz_party_sites hps
            ,hz_locations hl
       WHERE siteu.site_use_id = lv_site_use_id
         AND sitea.cust_acct_site_id = siteu.cust_acct_site_id
         AND hps.party_site_id = sitea.party_site_id
         AND hl.location_id = hps.location_id;

  BEGIN

    /* Party Name and Number */
    OPEN c_party_name(p_cust_account_id);
    FETCH c_party_name INTO lv_party_id
                           ,lv_party_name;

    IF c_party_name%FOUND THEN
      p_party_name := lv_party_name;
    END IF;
    CLOSE c_party_name;

    /* Party Address */
    OPEN c_party_addr(p_site_use_id);
    FETCH c_party_addr INTO lv_address1
                           ,lv_address2
                           ,lv_city
                           ,lv_postal_code
                           ,lv_state
                           ,lv_country;

    IF c_party_addr%FOUND THEN
      p_address1    := lv_address1;
      p_address2    := lv_address2;
      p_city        := lv_city;
      p_state       := lv_state;
      p_postal_code := lv_postal_code;
    END IF;
    CLOSE c_party_addr;


  EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END prc_get_party_data;


  -----------------------------------------------------------------------------------------
  -- Procedure:prc_breakout_values
  -- Purpose:  Returns the breakout group values to be passed into the prc_get_breakout_cust.
  --
  -- Variables:
  -----------------------------------------------------------------------------------------
  PROCEDURE prc_breakout_values (p_data            IN OUT breakout_tbl
                                ,p_cust_account_id IN     HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) IS

    x_rec NUMBER := 0;

    /* Perform a grouping on all of a given customers transactions that are in an open status (OP).  The list
    ** will be used to determine the breakout customer record.
    */
    CURSOR c_cust_breakout_grp (lv_cust_account_id HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) IS
    SELECT rcta.org_id
          ,XXAR_GETPAID_PKG.fnc_inv_trx_dff(apsa.customer_trx_id, 'Global Data Elements', 'IN COLLECTIONS STATUS') trx_type
          ,XXAR_GETPAID_PKG.fnc_cust_info_dff(apsa.customer_id, 'MANAGED CUSTOMER') managed_cust
          ,XXAR_GETPAID_PKG.fnc_cust_info_dff(apsa.customer_id, 'LARGE LEGAL CUSTOMER') large_cust
          ,xxcm_common.get_business_unit(gcc.segment2) business    --Added for R12 Upgrade COA Changes
          ,gcc.segment3 site
          ,SUM(0) dummy
      FROM ar_payment_schedules_all apsa
          ,ra_customer_trx_all rcta
          ,ra_cust_trx_line_gl_dist_all dist
          ,gl_code_combinations gcc
     WHERE apsa.customer_trx_id = rcta.customer_trx_id
       AND apsa.customer_id = lv_cust_account_id
       AND apsa.status = 'OP'
       AND rcta.customer_trx_id = dist.customer_trx_id
       AND gcc.code_combination_id = dist.code_combination_id
       AND rcta.org_id NOT IN (1793, 997) /* exclude BRL,INR operating units */
    GROUP BY rcta.org_id
            ,XXAR_GETPAID_PKG.fnc_inv_trx_dff(apsa.customer_trx_id, 'Global Data Elements', 'IN COLLECTIONS STATUS')
            ,XXAR_GETPAID_PKG.fnc_cust_info_dff(apsa.customer_id, 'MANAGED CUSTOMER')
            ,XXAR_GETPAID_PKG.fnc_cust_info_dff(apsa.customer_id, 'LARGE LEGAL CUSTOMER')
            ,xxcm_common.get_business_unit(gcc.segment2)    --Added for R12 Upgrade COA Changes
            ,gcc.segment3;


  BEGIN

    OPEN c_cust_breakout_grp(p_cust_account_id);
    x_rec := 1;
    LOOP
      FETCH c_cust_breakout_grp INTO p_data(x_rec).org_id
                                    ,p_data(x_rec).collection_status
                                    ,p_data(x_rec).managed_customer
                                    ,p_data(x_rec).large_customer
                                    ,p_data(x_rec).business
                                    ,p_data(x_rec).site
                                    ,p_data(x_rec).dummy;
        EXIT WHEN c_cust_breakout_grp%NOTFOUND;

      x_rec := x_rec + 1; --increment counter

    END LOOP;
    CLOSE c_cust_breakout_grp;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END prc_breakout_values;

END xxar_getpaid_pkg;

/
