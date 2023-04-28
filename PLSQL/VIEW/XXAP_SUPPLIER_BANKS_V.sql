--drop view XXAP_SUPPLIER_BANKS_V;

create view XXAP_SUPPLIER_BANKS_V
as
SELECT ss.org_id ORG_ID
     , eba.EXT_BANK_ACCOUNT_ID EXT_BANK_ACCOUNT_ID
     , eba.BANK_ID BANK_ID
     , eba.BRANCH_ID BRANCH_ID
     , sup.vendor_id VENDOR_ID
     , ss.vendor_site_id VENDOR_SITE_ID
     , ss.party_site_id PARTY_SITE_ID
     , hou.name OPERATING_UNIT_NAME
     , sup.segment1 VENDOR_NUMBER
     , sup.vendor_name VENDOR_NAME
     , ss.vendor_site_code VENDOR_SITE_CODE
     , piu.start_date BANK_ACC_START_DATE
     , piu.end_date BANK_ACC_END_DATE
     , piu.order_of_preference BANK_ACC_PRIORITY
     , eba.COUNTRY_CODE BANK_ACC_COUNTRY_CODE
     , eba.FOREIGN_PAYMENT_USE_FLAG ALLOW_INT_PAYMENTS
     , cbb.bank_name BANK_NAME
     , cbb.bank_name_alt BANK_ALT_NAME
     , cbb.bank_number BANK_NUMBER
     , cbb.bank_branch_name BRANCH_NAME
     , cbb.bank_branch_name_alt BRANCH_ALT_NAME
     , cbb.branch_number BRANCH_NUMBER
     , cbb.eft_swift_code BIC
     , cbb.bank_branch_type BRANCH_TYPE
     , eba.bank_account_num BANK_ACCOUNT_NUM
     , eba.BANK_ACCOUNT_NAME BANK_ACCOUNT_NAME
     , eba.currency_code BANK_ACCOUNT_CURRENCY
     , eba.bank_account_type BANK_ACCOUNT_TYPE
     , hp.party_name ACCOUNT_OWNERS
     , bao.primary_flag OWNER_PRIMARY_FLAG
     , bao.END_DATE OWNER_END_DATE
  FROM ap.ap_suppliers              sup
     , ap.ap_supplier_sites_all     ss
     , iby.iby_external_payees_all epa
--     , iby.iby_ext_party_pmt_mthds epm
     , iby.iby_pmt_instr_uses_all  piu
     , iby.iby_ext_bank_accounts   eba
     , apps.CE_BANKS_V             cb
     , apps.CE_BANK_BRANCHES_V     cbb
     , iby.iby_account_owners      bao
     , ar.hz_parties               hp
     , HR.hr_all_organization_units hou
 WHERE hou.organization_id = epa.org_id
   AND sup.vendor_id     = ss.vendor_id
   AND ss.org_id = epa.org_id   
   AND ss.vendor_site_id = epa.supplier_site_id
   AND epa.ext_payee_id  = piu.ext_pmt_party_id      
   AND piu.instrument_id = eba.ext_bank_account_id
   AND nvl(eba.bank_id,-1) = nvl(cb.bank_party_id (+),-1)   
   AND nvl(eba.branch_id,-1) = nvl(cbb.branch_party_id (+),-1)
   AND piu.instrument_id = bao.ext_bank_account_id
   AND bao.account_owner_party_id = hp.party_id
--   and epa.ext_payee_id = epm.ext_pmt_party_id (+)
   and (sup.END_DATE_ACTIVE is null or sup.END_DATE_ACTIVE > (select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE'))
   and (ss.INACTIVE_DATE is null or ss.INACTIVE_DATE > (select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE'))
   and (piu.end_date is null or piu.end_date > (select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE'))
   and (bao.END_DATE is null or bao.END_DATE > (select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE'))
   and (eba.END_DATE is null or eba.END_DATE > (select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE'))
   ;
