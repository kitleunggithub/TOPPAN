CREATE OR REPLACE VIEW XXBS_TRX_STATUS_V
AS
select 
    ac.customer_id CUST_ACCOUNT_ID
    ,xct.customer_trx_id CUSTOMER_TRX_ID
    ,pxct.customer_trx_id PARENT_CUSTOMER_TRX_ID
    ,ppa.project_id PROJECT_ID
    ,sec_ac.customer_id SEC_CUST_ACCOUNT_ID
    ,xct.period_name PERIOD_NAME
    ,trxtype.name TRX_TYPE
    ,xct.current_status CURRENT_STATUS
    ,xct.current_status_date CURRENT_STATUS_DATE
    ,xct.ar_trx_number AR_TRX_NUMBER
    ,ppa.segment1 ORDER_NUMBER
    ,ppa.long_name PROJECT_NAME
    ,XXBS_TRX_PKG.get_pa_cost(xct.customer_trx_id,'External') PA_COST_EXT
    ,XXBS_TRX_PKG.get_pa_cost(xct.customer_trx_id,'Internal') PA_COST_INT
    ,xct.currency_code BASE_CURRENCY
    ,XXBS_TRX_PKG.get_base_sell(xct.customer_trx_id) BASE_SELL_AMOUNT
    ,xct.entered_currency_code ENTERED_CURRENCY
    ,XXBS_TRX_PKG.get_sub_sell(xct.customer_trx_id) ENTERED_SELL_AMOUNT
    ,XXBS_TRX_PKG.get_sell(xct.customer_trx_id, 'Line') STD_SELL_AMOUNT
    ,XXBS_TRX_PKG.get_sell(xct.customer_trx_id, 'Freight') FREIGHT_SELL_AMOUNT
    ,XXBS_TRX_PKG.get_sell(xct.customer_trx_id, 'Postage') POSTAGE_SELL_AMOUNT
    ,xct.tax_amount TAX_AMOUNT
    ,xct.exchange_rate EXCHANGE_RATE
    , gcc.segment1 AR_LEGAL_ENTITY
    , gcc.segment2 AR_PRODUCT_LINE
    , gcc.segment3 AR_SITE
    , xct.description DESCRIPTION
    , xct.trx_date TRX_DATE
    , xct.creation_date CREATION_DATE
    , pa_org.name PRIMARY_PROJECT_ORG
    , amlav.name PRIMARY_PRODUCT_TYPE
    , XXBS_TRX_PKG.get_salesrep(xct.customer_trx_id,1,1) PRIMARY_SALESREP
    , XXBS_TRX_PKG.get_salesrep(xct.customer_trx_id,1,2) "PRIMARY_SALESREP_SPLIT"
    , XXBS_TRX_PKG.get_salesrep(xct.customer_trx_id,2,1) "SALESREP_2ND"
    , XXBS_TRX_PKG.get_salesrep(xct.customer_trx_id,2,2) "SALESREP_2ND_SPLIT"
    , ac.customer_name CUSTOMER_NAME
    , ac.customer_number CUSTOMER_NUMBER
    , hl.address1 BILL_TO_ADDRESS
    , acv.PERSON_FULL_NAME CONTACT
    , acv.EMAIL_ADDRESS CONTACT_EMAIL
    ,xct.attendee OTHER_EMAIL
    ,xct.attendee_email OTHER_CONTACT_EMAIL
    , sec_ac.customer_name SECONDARY_CUSTOMER
    , sec_ac.customer_number SECONDARY_CUSTOMER_NUMBER
    ,xct.customer_order_number CUSTOMER_ORDER_NUMBER
    ,fu_active.description ACTIVE_BILLER
    ,fu_owning.description OWNING_BILLER
    , pxct.ar_trx_number PARENT_TRANSACTION_NUMBER
    ,rt.name CONTRACT_TERM
    ,xct.project_complete_date PROJECT_COMPLETE_DATE
    ,xct.cost_sum_send_date COST_SUM_SEND_DATE
    ,xct.bill_remark BILL_REMARK
    , xxbs_trx_pkg.get_attachment_yn(xct.customer_trx_id) ATTACHMENT
    ,xct.invoice_style_name INVOICE_STYLE_NAME
from xxbs_customer_trx xct
    ,xxbs_customer_trx pxct
    ,fnd_user fu_owning 
    ,fnd_user fu_active
    ,ra_cust_trx_types_all trxtype 
    ,pa_projects_all ppa
    ,hr_all_organization_units pa_org
    ,AR_MEMO_LINES_ALL_VL amlav
    ,gl_code_combinations_kfv gcc
    ,RA_TERMS_VL rt
    ,AR_CUSTOMERS ac
    ,AR_CUSTOMERS sec_ac    
    ,(  SELECT HCAR.CUST_ACCOUNT_ID,HCAS.CUST_ACCT_SITE_ID,HCAS.ORG_ID,HCAR.CUST_ACCOUNT_ROLE_ID
        ,HPP.PERSON_PROFILE_ID,HPP.PERSON_FIRST_NAME,HPP.PERSON_MIDDLE_NAME,HPP.PERSON_LAST_NAME, 
        HPP.PERSON_FIRST_NAME||' '||HPP.PERSON_MIDDLE_NAME||NVL2(HPP.PERSON_MIDDLE_NAME,' ','')||HPP.PERSON_LAST_NAME PERSON_FULL_NAME,
        HCP_EMAIL.EMAIL_ADDRESS,HCP_EMAIL.PRIMARY_FLAG EMAIL_PRIMARY_FLAG
        FROM HZ_PARTIES HP
        ,HZ_PARTIES REL_HP
        ,HZ_PERSON_PROFILES HPP
        ,HZ_RELATIONSHIPS HR
        ,HZ_CUST_ACCT_SITES_ALL HCAS
        ,HZ_CUST_ACCOUNT_ROLES HCAR
        ,HZ_CONTACT_POINTS HCP_EMAIL
        WHERE 1=1
        AND HR.SUBJECT_ID = HP.PARTY_ID
        AND REL_HP.PARTY_ID = HR.PARTY_ID
        AND HP.PARTY_ID = HPP.PARTY_ID(+)
        AND HPP.EFFECTIVE_END_DATE IS NULL
        AND REL_HP.PARTY_ID = HCAR.PARTY_ID(+)
        AND HR.SUBJECT_TABLE_NAME = 'HZ_PARTIES' 
        AND HR.SUBJECT_TYPE = 'PERSON'
        AND HR.RELATIONSHIP_CODE = 'CONTACT_OF' 
        AND HCP_EMAIL.OWNER_TABLE_ID(+) = HCAR.PARTY_ID
        AND HCP_EMAIL.CONTACT_POINT_TYPE(+) = 'EMAIL'
        AND HCP_EMAIL.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
        AND HCP_EMAIL.PRIMARY_FLAG(+) = 'Y'
        AND HCP_EMAIL.STATUS(+) = 'A'
        AND (HCP_EMAIL.APPLICATION_ID(+) = 222 OR HCP_EMAIL.APPLICATION_ID(+) IS NULL)
        AND HCAR.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID    
     ) acv
    ,HZ_CUST_ACCT_SITES_ALL hcasa
    ,HZ_PARTY_SITES hps
    ,HZ_LOCATIONS hl
where xct.parent_customer_trx_id = pxct.customer_trx_id (+)
and fu_owning.user_id = xct.owning_biller_id
and fu_active.user_id = xct.active_biller_id
and trxtype.cust_trx_type_id = xct.cust_trx_type_id
and xct.original_project_id = ppa.project_id
and ppa.carrying_out_organization_id = pa_org.organization_id
--and ppa.attribute1 = amlav.memo_line_id (+)
--and ppa.org_id = amlav.org_id (+)
and xct.primary_product_type_id = amlav.memo_line_id (+)
and amlav.gl_id_rev = gcc.code_combination_id (+)
and xct.org_id = amlav.org_id (+)
and xct.term_id = rt.term_id
and xct.bill_to_customer_id = ac.customer_id
and xct.sec_bill_to_customer_id = sec_ac.customer_id (+)
and xct.bill_to_contact_id = acv.cust_account_role_id (+)
and xct.bill_to_customer_id = acv.cust_account_id (+)
and hcasa.cust_acct_site_id = xct.bill_to_address_id
and hps.party_site_id = hcasa.party_site_id
and hps.location_id = hl.location_id
order by xct.ar_trx_number;