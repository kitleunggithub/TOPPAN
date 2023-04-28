--drop view XXAP_FUNDING_V;

CREATE VIEW XXAP_FUNDING_V
AS
     WITH banks AS
        ( SELECT ba.account_owner_org_id legal_entity_id
               , bb.bank_party_id bank_id
               , bb.bank_name
               , ba.bank_account_id
               , ba.bank_account_name
               , ba.bank_account_num
               , ba.currency_code
               , ppp_banks.payment_method
          FROM ce_bank_accounts ba
            JOIN ce_bank_branches_v     bb ON ( bb.branch_party_id = ba.bank_branch_id )
            JOIN ce_bank_acct_uses_all bau ON ( bau.bank_account_id = ba.bank_account_id )
            JOIN hr_operating_units     ou ON ( ou.organization_id = bau.org_id )
            JOIN gl_ledgers             gl ON ( gl.ledger_id = ou.set_of_books_id )
            -- list of bank values from flex values
            JOIN (SELECT banks.applicable_value_to bank_account_id
                       , pymt_methods.applicable_value_to payment_method
                  FROM iby_payment_profiles pp
                    JOIN iby_applicable_pmt_profs banks
                            ON ( banks.system_profile_code = pp.system_profile_code
                             AND banks.applicable_type_code = 'INTERNAL_BANK_ACCOUNT'
                               )
                    JOIN iby_applicable_pmt_profs pymt_methods
                            ON ( pymt_methods.system_profile_code = pp.system_profile_code
                             AND pymt_methods.applicable_type_code = 'PAYMENT_METHOD'
                                )
                   WHERE 1=1 --xxcm_common.flex_value_exists('XXAP_FUNDING_ACCOUNTS', pp.system_profile_code, 'Y') = 'Y'
				   AND nvl(pp.inactive_date, sysdate+1) > sysdate
                 ) ppp_banks on ( ppp_banks.bank_account_id = ba.bank_account_id )
          WHERE nvl(ba.end_date, sysdate+1) > sysdate
       )
     SELECT aia.INVOICE_ID INVOICE_ID
      , aia.PAYMENT_METHOD_CODE PAYMENT_METHOD_CODE
      , aia.LEGAL_ENTITY_ID
      , ep.name              LEGAL_ENTITY  /* 4 */
      , aia.ORG_ID ORG_ID
      , xxcm_common.get_org_name(aia.org_id) OPERATING_UNIT_NAME  /* 6 */
      , nvl( banks.bank_id, dflt_banks.bank_id)                     BANK_ID
      , nvl( banks.bank_name, dflt_banks.bank_name)                 BANK_NAME /* 7 */
      , nvl( banks.bank_account_id, dflt_banks.bank_account_id)     BANK_ACCT_ID
      , nvl( banks.bank_account_name, dflt_banks.bank_account_name) BANK_ACCT_NAME
      , nvl( banks.bank_account_num, dflt_banks.bank_account_num)   BANK_ACCT_NUM /* 9 */
      , s.vendor_id VENDOR_ID
      , s.vendor_name VENDOR_NAME                     /* 10 */
      , s.segment1          VENDOR_NUM
      , apsa.due_date SCHEDULED_PAYMENT_DATE /* 12 */
      , aia.INVOICE_NUM INVOICE_NUM                   /* 13 */
      , aia.invoice_date INVOICE_DATE
      , apsa.due_date INVOICE_DUE_DATE
      , (select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE') - apsa.due_date INVOICE_OVERDUE_DAY      
      , aia.INVOICE_CURRENCY_CODE INVOICE_CURRENCY_CODE
   -- , aia.INVOICE_AMOUNT																	-- Commented for CR#2059 V1.1
      , apsa.amount_remaining INVOICE_AMOUNT												-- Added for CR#2059 V1.1
   /* , ROUND(aia.INVOICE_AMOUNT
          * NVL ( rate.conversion_rate, 1),2)               converted_currency_amount */	-- Commented for CR#2059 V1.1
	  , ROUND(apsa.amount_remaining * NVL ( rate.conversion_rate, 1),2)               FUNC_AMOUNT		-- Added for CR#2059 V1.1
      , nvl(rate.conversion_rate,1)                         CONVERSION_RATE
      , fsp.currency_code                                   FUNC_CURRENCY_CODE
	  , aia.pay_group_lookup_code                           PAY_GROUP							-- Added for CR#2059 V1.2
      , s.vendor_type_lookup_code                           VENDOR_TYPE						-- Added for CR#2059 V1.2
  FROM ap_invoices_all aia
    JOIN ap_payment_schedules_all apsa ON ( apsa.invoice_id = aia.invoice_id )
    JOIN ap_suppliers                s ON ( s.vendor_id = aia.vendor_id )
    JOIN po_vendor_sites_all      povs ON ( povs.vendor_id      = aia.vendor_id
                                        AND povs.vendor_site_id = aia.vendor_site_id )
    JOIN po_vendors                pov ON ( pov.vendor_id = povs.vendor_id )
    JOIN (SELECT fsp.org_id, gls.currency_code
          FROM financials_system_params_all fsp,
             gl_ledgers gls
          WHERE fsp.set_of_books_id = gls.ledger_id
         )                         fsp ON ( fsp.org_id = aia.org_id )
    LEFT JOIN banks              banks ON ( banks.legal_entity_id = aia.legal_entity_id
                                        AND banks.payment_method  = aia.payment_method_code
                                        AND banks.currency_code   = aia.invoice_currency_code)
    JOIN banks              dflt_banks ON ( dflt_banks.legal_entity_id = aia.legal_entity_id
                                        AND dflt_banks.payment_method  = aia.payment_method_code
                                        AND dflt_banks.currency_code   = fsp.currency_code)
    JOIN xle_entity_profiles       ep ON ( ep.legal_entity_id = aia.legal_entity_id )
    LEFT JOIN (SELECT distinct to_currency, from_currency,
                 first_value(CONVERSION_RATE) over (partition by to_currency, from_currency
                                                    order by conversion_date desc, last_update_date desc) conversion_rate
               FROM GL_DAILY_RATES
               WHERE conversion_type = xxcm_common.get_constant_value('XXGL_RATE_CONVERSION_TYPE')
              )                   rate ON ( rate.to_currency = fsp.currency_code
                                        AND rate.from_currency = aia.invoice_currency_code
                                          )
 WHERE     1 = 1
  AND aia.invoice_id NOT IN
              (SELECT invoice_id
                 FROM ap_holds_all aph
                WHERE aia.invoice_id = aph.invoice_id
                  AND release_lookup_code IS NULL)
/*  AND NVL (pov.hold_all_payments_flag, 'N') = 'N' */
  AND aia.invoice_amount <> 0
  AND NVL (povs.hold_all_payments_flag, 'N') = 'N'
  AND NVL (aia.payment_status_flag, 'N') IN ('N', 'P') /* payment unpaid or partially paid */
  AND aia.cancelled_date IS NULL                       /* suppress cancelled invoices */
  AND EXISTS (SELECT 1
              FROM ap_invoice_lines_all ail
               JOIN ap_invoice_distributions_all aid on ( aid.invoice_id = ail.invoice_id
                                              AND aid.invoice_line_number = ail.line_number )
              WHERE ail.invoice_id = aia.invoice_id
                AND aid.match_status_flag = 'A'
             ) /* Invoice is validated */
  AND apsa.amount_remaining != 0																					-- Added for CR#2059 V1.2
 ORDER BY LEGAL_ENTITY,OPERATING_UNIT_NAME,bank_acct_num,vendor_name,SCHEDULED_PAYMENT_DATE,INVOICE_NUM
 ;
  