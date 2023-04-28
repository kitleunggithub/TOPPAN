--DROP VIEW XXAR_DAY_PAID_V;

CREATE OR REPLACE VIEW XXAR_DAY_PAID_V
AS
SELECT
      trx.org_id                              ORG_ID
    , cust.customer_id                        CUST_ACCOUNT_ID
    , trx.customer_trx_id                     AR_CUSTOMER_TRX_ID
    , app.receivable_application_id           RECEIVABLE_APPLICATION_ID
    , ppa.project_id                          PROJECT_ID
    , xxcm_common.get_org_name(trx.org_id)    OPERATING_UNIT_NAME
    , cust.CUSTOMER_NAME                      CUSTOMER_NAME
    , cust.CUSTOMER_NUMBER                    CUSTOMER_NUMBER
    ,'Business Unit'						  BUSINESS_UNIT
    --, xxcm_common.get_business_unit(glcc.segment2) business_unit
    , glcc.segment1                           LEGAL_ENTITY
    , xxcm_common.get_flex_value_field('XXGL_LEGAL_ENTITY', glcc.segment1) LEGAL_ENTITY_NAME
    , trx.trx_number                          INVOICE_NUMBER
    , trx.trx_date                            INVOICE_DATE
    , trx.invoice_currency_code               INVOICE_CURRENCY_CODE
    , typ.name                                INVOICE_TYPE
    , xxbs_trx_pkg.get_salesrep_by_trx(trx.org_id,trx.trx_number,1,1)    PRIMARY_SALESREP
    , xxbs_trx_pkg.get_salesrep_by_trx(trx.org_id,trx.trx_number,1,2)    PRIMARY_SALESREP_SPLIT
    , xxbs_trx_pkg.get_salesrep_by_trx(trx.org_id,trx.trx_number,999,1) OTHER_SALESREP_NAME
    , xxbs_trx_pkg.get_salesrep_by_trx(trx.org_id,trx.trx_number,999,2) OTHER_SALESREP_SPLIT
	, xxbs_trx_pkg.get_pri_product_type_name(xct.primary_product_type_id) PRIMARY_PRODUCT_TYPE
    , pay.amount_due_original                 ORIG_AMOUNT
    , app.amount_applied                      APPLIED_AMOUNT
    , pay.amount_due_remaining                OPEN_AMOUNT
    , app.acctd_amount_applied_to             FUNC_AMOUNT
    , l.currency_code                         FUNC_CURRENCY_CODE
    , app.apply_date                          APPLIED_DATE
    , cr.receipt_number                       RCPT_NUMBER                     
    , cr.receipt_date                         RCPT_DATE
    , cr.receipt_date - trx.trx_date          DAYS_PAID
    , (case when interface_header_context = 'TM CONVERSION' then trx.interface_header_attribute5 else ppa.name end) PROJECT_NAME
    , gd.gl_date                              INVOICE_GL_DATE
    , app.gl_date                             RECEIPT_GL_DATE
    , rcpt_bank.REMIT_BANK_NAME               RECEIPT_BANK_NAME
    , rcpt_bank.REMIT_BANK_ACCOUNT_NUM        RECEIPT_BANK_ACCOUNT_NUMBER
FROM ar_payment_schedules_all         pay
  JOIN ra_customer_trx_all            trx ON ( trx.customer_trx_id = pay.customer_trx_id )
  LEFT JOIN xxbs_customer_trx         xct ON ( trx.trx_number = xct.ar_trx_number and trx.org_id = xct.org_id )
  JOIN (
        -- Dash Kit Leung - 05-MAY-2021 - Enhancement - show applied and un-applied history in the report
        /*
        select distinct applied_customer_trx_id
             , cash_receipt_id
             , code_combination_id
             , amount_applied
             , acctd_amount_applied_to
             , trunc(min(apply_date) over (partition by applied_customer_trx_id, cash_receipt_id
                                                      , code_combination_id, amount_applied)) apply_date
        FROM ar_receivable_applications_all
        WHERE status IN ('APP','ACC')
          AND amount_applied > 0
       */
        select receivable_application_id
             , applied_customer_trx_id
             , cash_receipt_id
             , code_combination_id
             , amount_applied amount_applied
             , acctd_amount_applied_to acctd_amount_applied_to
             , trunc(apply_date) apply_date
             , gl_date gl_date
        FROM ar_receivable_applications_all
        WHERE status IN ('APP','ACC')                    
       ) app ON ( app.applied_customer_trx_id = trx.customer_trx_id )
  JOIN ar_cash_receipts_all            cr ON ( cr.cash_receipt_id = app.cash_receipt_id )
  JOIN ra_cust_trx_types_all          typ ON ( typ.cust_trx_type_id = trx.cust_trx_type_id AND typ.TYPE = 'INV' )
  LEFT JOIN pa_projects_all            ppa ON (ppa.project_id = trx.interface_header_attribute2)
  JOIN (select * from RA_CUST_TRX_LINE_GL_DIST_ALL gld WHERE gld.account_class = 'REC' AND gld.latest_rec_flag = 'Y') gd ON (trx.customer_trx_id = gd.customer_trx_id)  
  JOIN ar_customers              cust ON ( cust.customer_id = cr.pay_from_customer )
  JOIN gl_code_combinations      glcc ON ( glcc.code_combination_id = app.code_combination_id )
  JOIN gl_ledgers                   l ON ( l.ledger_id = cr.set_of_books_id )
  JOIN (SELECT 
            aba.bank_acct_use_id,
            cb.bank_name REMIT_BANK_NAME,
            abb.bank_branch_name REMIT_BRANCH_NAME,
            cba.bank_account_name REMIT_BANK_ACCOUNT_NAME,
            cba.bank_account_num REMIT_BANK_ACCOUNT_NUM
        FROM ce_bank_accounts cba, ce_bank_acct_uses_all aba, ce_banks_v cb, ce_bank_branches_v abb
        WHERE cba.bank_branch_id = abb.branch_party_id (+)
        AND cba.bank_id = cb.bank_party_id (+)
        AND aba.bank_account_id = cba.bank_account_id
        ) rcpt_bank ON ( cr.remit_bank_acct_use_id = rcpt_bank.bank_acct_use_id )
  /*
  LEFT JOIN (SELECT * FROM 
                ( 
                SELECT
                    org_id                                      org_id,
                    trx_number                                  trx_number,
                    to_number(interface_header_attribute10)     salesrep_id,
                    to_number(interface_header_attribute11)     sales_split
                FROM
                    ra_customer_trx
                WHERE
                    interface_header_context = 'TM CONVERSION'
                UNION ALL
                SELECT
                    xct.org_id,
                    xct.ar_trx_number       trx_number,
                    xrs.salesrep_id         salesrep_id,
                    xrs.split_percentage    sales_split
                FROM
                    xxbs_customer_trx  xct,
                    xxbs_rep_splits    xrs
                WHERE xct.customer_trx_id = xrs.customer_trx_id
                AND xrs.primary_flag = 'Y') rep
                JOIN jtf_rs_resource_extns_tl ext 
                on ( ext.resource_id = rep.salesrep_id )
               ) salesrep 
               ON ( salesrep.trx_number = trx.trx_number
                    and salesrep.org_id = trx.org_id)
  */                  
--WHERE cr.status = 'APP' -- Dash Kit Leung - 05-MAY-2021 - Enhancement - show applied and un-applied history in the report
ORDER BY cust.customer_name, glcc.segment1
;
