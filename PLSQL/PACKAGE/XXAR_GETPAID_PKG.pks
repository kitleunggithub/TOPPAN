--------------------------------------------------------
--  DDL for Package XXAR_GETPAID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAR_GETPAID_PKG" IS

  pkg_v_debug   VARCHAR2(1);

  TYPE breakout_rec IS RECORD(
      org_id            RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE,
      collection_status VARCHAR2(30),
      managed_customer  VARCHAR2(30),
      large_customer    VARCHAR2(30),
      --business          --GL_CODE_COMBINATIONS.SEGMENT1%TYPE, --Commeneted for R12 Upgrade COA Changes
      business           fnd_flex_values.attribute2%TYPE,       --Added for R12 Upgrade COA Changes
      site              GL_CODE_COMBINATIONS.SEGMENT3%TYPE,
      dummy             NUMBER);

  TYPE breakout_tbl IS TABLE OF breakout_rec INDEX BY BINARY_INTEGER;

  TYPE breakout_ref IS REF CURSOR;

  ---------------------------------------------------------------------------------------------
  -- Function: set_pkg_variable
  -- Purpose: Returns FALSE if an error occurs during the function call.
  --
  -- Parameters: p_variable - Actual name of the variable (Required).
  --             p_status - Used as a flag Y/N for the p_variable parm. (Required).
  --             p_sqlerrm - Returns an error if one exists. (Optional).
  ---------------------------------------------------------------------------------------------
  FUNCTION set_pkg_variable(p_variable      IN VARCHAR2
                           ,p_status        IN VARCHAR2
                           ,p_sqlerrm      OUT VARCHAR2) RETURN BOOLEAN;

  -----------------------------------------------------------------------------------------
  -- Function:fnd_lastpayment_date
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_lastpayment_date(p_cust_account_id       IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) RETURN AR_TRX_BAL_SUMMARY.LAST_PAYMENT_DATE%TYPE;


  -----------------------------------------------------------------------------------------
  -- Function:fnc_lastpayment_amt
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_lastpayment_amt(p_cust_account_id       IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) RETURN AR_TRX_BAL_SUMMARY.LAST_PAYMENT_AMOUNT%TYPE;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_credit_limit_dt
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_credit_limit_dt(p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) RETURN DATE;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_cust_payment_terms
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_cust_payment_terms(p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) RETURN NUMBER;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_trx_payment_terms
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_trx_payment_terms(p_customer_trx_id IN RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE) RETURN NUMBER;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_getpaid_group_id
  -- Purpose:
  --
  -- Variables:
  --
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_getpaid_group_id (p_customer_id IN AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_ID%TYPE) RETURN VARCHAR2;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_source_name
  -- Purpose:
  --
  -- Variables:
  --
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_source_name (p_batch_source_id RA_CUSTOMER_TRX_ALL.BATCH_SOURCE_ID%TYPE
                           ,p_org_id          RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE) RETURN VARCHAR2;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_invc_trx_dff
  -- Purpose: Used by the ARMAST file to retrieve the DFF field values.
  --
  -- Variables:
  --
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_inv_trx_dff (p_cust_trx_id IN  RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE
                           ,p_source      IN  RA_BATCH_SOURCES.NAME%TYPE
                           ,p_column_name IN  FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE) RETURN VARCHAR2;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_rcpt_app_dff
  -- Purpose: Used by the ARMAST file to retrieve the DFF field values.
  --
  -- Variables:
  --
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_rcpt_app_dff (p_cust_trx_id         IN  AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_TRX_ID%TYPE
                            ,p_payment_schedule_id IN  AR_PAYMENT_SCHEDULES_ALL.PAYMENT_SCHEDULE_ID%TYPE
                            ,p_column_name         IN  FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE) RETURN VARCHAR2;

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
                             ,p_column_name   IN  FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE) RETURN VARCHAR2;

  -----------------------------------------------------------------------------------------
  -- Function:fnd_lasttrx_date
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_lasttrx_date(p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) RETURN RA_CUSTOMER_TRX_ALL.TRX_DATE%TYPE;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_base_conversion_rate
  -- Purpose:  Returns the conversion rate to US Dollars (base currency) based on SYSDATE.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_base_conversion_rate(p_from_currency IN GL_DAILY_RATES.FROM_CURRENCY%TYPE) RETURN NUMBER;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_last_receipt_nbr
  -- Purpose:  Returns the last receipt (check) number per customer.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_last_receipt_nbr(p_cust_account_id IN AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_ID%TYPE
                               ,p_trx_number      IN AR_PAYMENT_SCHEDULES_ALL.TRX_NUMBER%TYPE) RETURN VARCHAR;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_functional_conversion_rate
  -- Purpose:  Returns the conversion rate to US Dollars (functional rate) based on SYSDATE.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_functional_conversion_rate(p_org_id             IN RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE
                                         ,p_invc_currency_code IN RA_CUSTOMER_TRX_ALL.INVOICE_CURRENCY_CODE%TYPE) RETURN NUMBER;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_get_parent
  -- Purpose:  Returns the parent customer number.  If the incoming value (child) is the parent
  --           the function will NOT return a value.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_get_parent (p_child IN HZ_PARTIES.PARTY_ID%TYPE) RETURN VARCHAR2;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_get_org_id
  -- Purpose:  Returns the org_id for the customer based on the location information.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_get_org_id (p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE
                          ,p_location_id     IN HZ_LOCATIONS.LOCATION_ID%TYPE) RETURN NUMBER;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_crdt_classificaton
  -- Purpose:  Returns the credit classificaton meaning.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_crdt_classification (p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) RETURN VARCHAR2;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_contact_name
  -- Purpose:  Returns the either the first or last name of the contact at the header level.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_contact_name (p_party_id IN HZ_PARTIES.PARTY_ID%TYPE
                            ,p_fname    IN VARCHAR2) RETURN VARCHAR2;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_order_date
  -- Purpose:  Returns the order date associated billing transaction.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_order_date (p_ar_trx_number IN XXBS_CUSTOMER_TRX.AR_TRX_NUMBER%TYPE) RETURN DATE;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_applied_to
  -- Purpose:  Returns a Yes/No value if the applied to payment schedule id maps to the appropriate trx number.
  --           This function was created to resolve a performance fix on the ap_payment_schedules_all table when
  --           the ar_receivables_applications_all table was joined to it via the applied_payment_schedule_id field.
  --           That is the sole purpose of this function.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_applied_to (p_applied_id IN AR_RECEIVABLE_APPLICATIONS_ALL.APPLIED_PAYMENT_SCHEDULE_ID%TYPE
                          ,p_trx_number IN AR_PAYMENT_SCHEDULES_ALL.TRX_NUMBER%TYPE) RETURN VARCHAR2;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_applied_trx_nbr
  -- Purpose:  Returns the applied to Transaction Number associated to the applied_customer_trx_id
  --           from the ar_receivable_application_all table.
  --
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_applied_trx_nbr (p_cust_trx_id IN AR_RECEIVABLE_APPLICATIONS_ALL.APPLIED_CUSTOMER_TRX_ID%TYPE) RETURN VARCHAR2;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_amt_due_remaining
  -- Purpose:
  --
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_amt_due_remaining (p_cust_acct_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) RETURN NUMBER;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_currency_code
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_currency_code(p_org_id IN RA_CUSTOMER_TRX_ALL.ORG_ID%TYPE) RETURN VARCHAR2;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_site_exists
  -- Purpose:
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_site_exists(p_site IN XXAR_GETPAID_CUSTOMER_MAPPING.SITE_FROM%TYPE) RETURN BOOLEAN;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_remove_ascii_ext
  -- Purpose:  Converts a varchar variable to Hexidecimal and then back again to ASCII to
  --           strip off any ASCII extended characters.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_remove_ascii_ext(p_string VARCHAR2) RETURN VARCHAR2;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_remove_special_chr
  -- Purpose: Removes all special characters from the incoming string and replaces it with the
  --          value in the p_replacment_chr field.
  -- Variables: p_string - string to be cleaned.
  --            p_replacement_chr - ASCII value.
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_remove_special_chr (p_string          IN VARCHAR2
                                  ,p_replacement_chr IN NUMBER) RETURN VARCHAR;

  -----------------------------------------------------------------------------------------
  -- Function:fnc_translate
  -- Purpose:  Removes all special characters from the incoming string being passed in and
  --           returns that value back to the calling program.
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_translate (p_varchar VARCHAR2) RETURN VARCHAR;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_special_chr
  -- Purpose: Determines if the ascii value being passed in is deemed a special character by the function.
  --
  -- Variables: p_ascii - ASCII value to search on.
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_special_chr(p_ascii IN NUMBER) RETURN BOOLEAN;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_oac_balance
  -- Purpose: Returns the On Account Cash balance ONLY.  Used by the ARCUST file.
  --
  -- Variables:
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_oac_balance(p_cust_account_id IN HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE) RETURN NUMBER;

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
                               ,p_business            IN fnd_flex_values.attribute2%TYPE   --Added for R12 Upgrade COA Changes
                               ,p_site                IN GL_CODE_COMBINATIONS.SEGMENT3%TYPE)
      RETURN XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE RESULT_CACHE;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_get_gp_group_id
  -- Purpose: Returns the GetPaid collection type from the customer mapping table.
  --
  -- Variables: .
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_get_collection_type (p_org_id              IN HZ_CUST_ACCT_SITES_ALL.ORG_ID%TYPE
                                   ,p_collection_status   IN VARCHAR2
                                   ,p_managed_cust        IN VARCHAR2
                                   ,p_large_cust          IN VARCHAR2
                                   ,p_business            IN fnd_flex_values.attribute2%TYPE   --Added for R12 Upgrade COA Changes
                                   ,p_site                IN GL_CODE_COMBINATIONS.SEGMENT3%TYPE)
    RETURN XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE RESULT_CACHE;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_get_collection_type (OVERLOAD)
  -- Purpose: Returns the GetPaid collection type from the customer mapping table.
  --
  -- Variables: .
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_get_collection_type (p_gp_group_id IN XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE)
    RETURN XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE;

  -----------------------------------------------------------------------------------------
  -- Function: fnc_get_file_destination
  -- Purpose:
  --
  -- Variables:
  --
  -----------------------------------------------------------------------------------------
  FUNCTION fnc_get_file_destination RETURN VARCHAR2;

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
                                   ,p_errbuf      OUT VARCHAR2);

  -----------------------------------------------------------------------------------------
  -- Procedure:prc_derive_gp_breakout
  -- Purpose:  Derives the GetPaid breakout for the customer record by first looking to see if
  --           the initial site being passed in, with the incoming values, derives what the
  --           GP breakout is.  If not, then the procedure loops through the Hyperion parent
  --           sites to find a site that matches to the xxar_getpaid_customer_mapping table.
  --           If that fails then value is set to 'DEFAULT'.
  --
  -- Variables:
  -----------------------------------------------------------------------------------------
  PROCEDURE prc_derive_gp_breakout (p_org_id              IN HZ_CUST_ACCT_SITES_ALL.ORG_ID%TYPE
                                   ,p_collection_status   IN VARCHAR2
                                   ,p_managed_cust        IN VARCHAR2
                                   ,p_large_cust          IN VARCHAR2
                                    --,p_business            IN GL_CODE_COMBINATIONS.SEGMENT1%TYPE --Commented for R12 Upgrade COA Changes
                                   ,p_business            IN fnd_flex_values.attribute2%TYPE   --Added for R12 Upgrade COA Changes
                                   ,p_site                IN GL_CODE_COMBINATIONS.SEGMENT3%TYPE
                                   ,p_gp_group_id        OUT XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE
                                   ,p_collection_type_id OUT XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE);

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
                                 --,p_business            IN GL_CODE_COMBINATIONS.SEGMENT1%TYPE --Commented for R12 Upgrade COA Changes
                                ,p_business            IN fnd_flex_values.attribute2%TYPE   --Added for R12 Upgrade COA Changes
                                ,p_site                IN GL_CODE_COMBINATIONS.SEGMENT3%TYPE
                                ,p_gp_group_id        OUT XXAR_GETPAID_CUSTOMER_MAPPING.GP_GROUP_ID%TYPE
                                ,p_collection_type_id OUT XXAR_GETPAID_CUSTOMER_MAPPING.COLLECTION_TYPE_ID%TYPE);

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
                               ,p_postal_code     OUT HZ_LOCATIONS.POSTAL_CODE%TYPE);

  -----------------------------------------------------------------------------------------
  -- Procedure:prc_breakout_values
  -- Purpose:  Returns the breakout group values to be passed into the prc_get_breakout_cust.
  --
  -- Variables:
  -----------------------------------------------------------------------------------------
  PROCEDURE prc_breakout_values (p_data            IN OUT breakout_tbl
                                ,p_cust_account_id IN     HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE);

END xxar_getpaid_pkg;

/
