CREATE OR REPLACE VIEW XXGL_ACCOUNT_ANALYSIS_V
as
WITH xla AS
(SELECT /*+ materialize */ distinct 
        app.application_name         source
      , l.ledger_id                  ledger_id
      , line.code_combination_id     code_combination_id
      , l.name                       ledger
      , head.je_category_name
      , head.period_name
      , head.ae_header_id
      , head.accounting_date         accounting_date
      , line.gl_sl_link_id
      , line.party_id
      , line.currency_code
      , line.description             je_line_description
      , line.accounting_class_code
      , line.entered_dr
      , line.entered_cr
      , line.accounted_dr
      , line.accounted_cr
	  , line.ae_line_num								-- Added for CR#2733
      , et.transaction_number
      , et.source_id_int_1
      , cc.segment1             le
      , cc.segment2             pl
      , cc.segment3             site
      , cc.segment4             cc
      , cc.segment5             account
      , cc.segment6             ic
      -- Used for linking to other tables
      , xdl.source_distribution_id_num_1
      , xdl.source_distribution_type
      , xdl.applied_to_source_id_num_1
      , xdl.event_id
 FROM xla_ae_headers                 head
   JOIN xla_ae_lines                 line ON ( line.ae_header_id = head.ae_header_id )
   JOIN xla_events                     ev ON ( ev.event_id = head.event_id )
   -- VPN on table xla_transaction_entities (even though no ALL table available)
   JOIN xla.xla_transaction_entities       et ON ( et.entity_id = ev.entity_id
                                           AND et.application_id = head.application_id)
   JOIN xla_distribution_links        xdl ON ( xdl.ae_header_id = line.ae_header_id ) 
   JOIN gl_code_combinations           cc ON ( cc.code_combination_id = line.code_combination_id )
   JOIN gl_ledgers                      l ON ( l.ledger_id = head.ledger_id+0 )
   JOIN fnd_application_tl            app ON ( app.application_id = head.application_id
                                           AND app.language = 'US' )
 WHERE head.balance_type_code = 'A'
   AND (-- distribution line number matches
        -- OR No distribution line matches, then get first distribution line
        xdl.ae_line_num = line.ae_line_num
        OR
        (
         NOT EXISTS (select 1 from xla_distribution_links xdl2
                     where xdl2.ae_header_id = line.ae_header_id
                       AND xdl2.ae_line_num = line.ae_line_num)
         AND xdl.ae_line_num = (select min(ae_line_num) 
                                from xla_distribution_links xdl2
                                where xdl2.ae_header_id =line.ae_header_id )
        )
       )
   --AND to_date(head.period_name,'MON-YY') between to_date(:P_START_PERIOD,'MON-YY') and to_date(:P_END_PERIOD,'MON-YY')
   --AND l.ledger_id = :P_LEDGER_ID
   AND ( nvl(line.entered_dr,0) > 0
      OR nvl(line.entered_cr,0) > 0
      OR nvl(line.accounted_dr,0) > 0
      OR nvl(line.accounted_cr,0) > 0
       )
   	--AND cc.segment1 between substr(:P_MIN_FLEX,1,3) and substr(:P_MAX_FLEX,1,3)
	--AND cc.segment2 between substr(:P_MIN_FLEX,5,3) and substr(:P_MAX_FLEX,5,3)
	--AND cc.segment3 between substr(:P_MIN_FLEX,9,3) and substr(:P_MAX_FLEX,9,3)
	--AND cc.segment4 between substr(:P_MIN_FLEX,13,4) and substr(:P_MAX_FLEX,13,4)
	--AND cc.segment5 between substr(:P_MIN_FLEX,18,6) and substr(:P_MAX_FLEX,18,6)
	--AND cc.segment6 between substr(:P_MIN_FLEX,25,3) and substr(:P_MAX_FLEX,25,3)
)
--RECEIVABLES
SELECT
       xla.ledger_id LEDGER_ID
     , jeb.je_batch_id JE_BATCH_ID
     , jeh.je_header_id JE_HEADER_ID
     , cust.customer_id VENDOR_CUSTOMER_ID
     , xla.code_combination_id CODE_COMBINATION_ID       
     , xla.ledger     LEDGER
     , jeb.name                    JE_BATCH_NAME
     , jeh.name                    JE_JOURNAL_NAME
     , xla.source SOURCE
     , xla.je_category_name JE_CATEGORY_NAME
     , xla.currency_code CURRENCY_CODE
     , xla.period_name PERIOD_NAME
     , xla.accounting_date ACCOUNTING_DATE
     , xla.ae_header_id AE_HEADER_ID
     , cust.customer_number        VENDOR_CUSTOMER_NUMBER
     , cust.customer_name          VENDOR_CUSTOMER_NAME
     , xla.transaction_number TRANSACTION_NUMBER
	 , xla.ae_line_num AE_LINE_NUM										-- Added for CR#2733
     , jel.je_line_num JE_LINE_NUM
     , jel.description             JE_LINE_DESCRIPTION
     , xla.accounting_class_code ACCOUNTING_CLASS_CODE
     , xla.le LEGAL_ENTITY
     , xla.pl PRODUCT_LINE
     , xla.site SITE
     , xla.cc COST_CENTER
     , xla.account ACCOUNT
     , xla.ic INTERCOMPANY
     , xla.entered_dr ENTERED_DR
     , xla.entered_cr ENTERED_CR
     , xla.accounted_dr ACCOUNTED_DR
     , xla.accounted_cr ACCOUNTED_CR
FROM xla
   JOIN gl_import_references    gir ON ( gir.gl_sl_link_id = xla.gl_sl_link_id )
   JOIN gl_je_lines             jel ON ( gir.je_header_id = jel.je_header_id
                                     AND gir.je_line_num = jel.je_line_num )
   JOIN gl_je_headers           jeh ON ( jeh.je_header_id =jel.je_header_id )
   JOIN gl_je_batches           jeb ON ( jeb.je_batch_id = gir.je_batch_id )
   JOIN ra_cust_trx_line_gl_dist_all rctgdl ON ( rctgdl.cust_trx_line_gl_dist_id = xla.source_distribution_id_num_1 )
   LEFT JOIN ra_customer_trx_lines_all   rctl ON ( rctgdl.customer_trx_line_id = rctl.customer_trx_line_id )
   LEFT JOIN ra_customer_trx_all     rct ON ( rct.customer_trx_id = rctl.customer_trx_id )
   LEFT JOIN ar_customers           cust ON ( cust.customer_id = rct.bill_to_customer_id )
WHERE xla.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
  AND xla.source = 'Receivables'
  AND jeh.status = 'P'
UNION 
--PAYABLES
SELECT
       xla.ledger_id
     , jeb.je_batch_id JE_BATCH_ID
     , jeh.je_header_id JE_HEADER_ID
     , sup.vendor_id VENDOR_CUSTOMER_ID
     , xla.code_combination_id CODE_COMBINATION_ID       
     , xla.ledger
     , jeb.NAME                    je_batch_name
     , jeh.NAME                    je_journal_name
     , xla.source        source
     , xla.je_category_name
     , xla.currency_code
     , xla.period_name
     , xla.accounting_date
     , xla.ae_header_id
     , sup.segment1                cust_nbr
     , sup.vendor_name             cust_name
     , xla.transaction_number
	 , xla.ae_line_num											-- Added for CR#2733
     , jel.je_line_num
     , xla.je_line_description
     , xla.accounting_class_code
     , xla.le
     , xla.pl
     , xla.site
     , xla.cc
     , xla.account
     , xla.ic
     , xla.entered_dr
     , xla.entered_cr
     , xla.accounted_dr
     , xla.accounted_cr
FROM xla
   JOIN gl_import_references    gir ON ( gir.gl_sl_link_id = xla.gl_sl_link_id )
   JOIN gl_je_lines             jel ON ( gir.je_header_id = jel.je_header_id
                                     AND gir.je_line_num = jel.je_line_num )
   JOIN gl_je_headers           jeh ON ( jeh.je_header_id =jel.je_header_id )
   JOIN gl_je_batches           jeb ON ( jeb.je_batch_id = gir.je_batch_id )
   LEFT JOIN ap_invoices_all    aia ON ( aia.invoice_id = xla.applied_to_source_id_num_1 )
   LEFT JOIN ap_suppliers       sup on ( sup.vendor_id = aia.vendor_id )
WHERE xla.source = 'Payables'
  AND jeh.status = 'P'  
UNION 
-- misc receipts
SELECT
       xla.ledger_id
     , jeb.je_batch_id JE_BATCH_ID
     , jeh.je_header_id JE_HEADER_ID
     , null VENDOR_CUSTOMER_ID
     , xla.code_combination_id CODE_COMBINATION_ID              
     , xla.ledger
     , jeb.NAME                    je_batch_name
     , jeh.NAME                    je_journal_name
     , xla.source        source
     , xla.je_category_name
     , xla.currency_code
     , xla.period_name
     , xla.accounting_date
     , xla.ae_header_id
     , null                        cust_nbr
     , null                        cust_name
     , xla.transaction_number
	 , xla.ae_line_num														-- Added for CR#2733
     , jel.je_line_num
     , xla.je_line_description
     , xla.accounting_class_code
     , xla.le
     , xla.pl
     , xla.site
     , xla.cc
     , xla.account
     , xla.ic
     , xla.entered_dr
     , xla.entered_cr
     , xla.accounted_dr
     , xla.accounted_cr
FROM xla
   JOIN gl_import_references    gir ON ( gir.gl_sl_link_id = xla.gl_sl_link_id )
   JOIN gl_je_lines             jel ON ( gir.je_header_id = jel.je_header_id
                                     AND gir.je_line_num = jel.je_line_num )
   JOIN gl_je_headers           jeh ON ( jeh.je_header_id =jel.je_header_id )
   JOIN gl_je_batches           jeb ON ( jeb.je_batch_id = gir.je_batch_id )
WHERE xla.source = 'Receivables'
  AND xla.je_category_name IN ('Misc Receipts','Adjustment')
  AND jeh.status = 'P'
UNION 
-- GL
SELECT
       l.ledger_id
     , jeb.je_batch_id JE_BATCH_ID
     , jeh.je_header_id JE_HEADER_ID
     , null VENDOR_CUSTOMER_ID
     , jel.code_combination_id CODE_COMBINATION_ID              
     , l.name                      ledger
     , jeb.name                    je_batch_name
     , jeh.name                    je_journal_name
     , jeh.je_source               source
     , jeh.je_category             je_category_name
     , jeh.currency_code           currency_code
     , jeh.period_name             period_name
     , jeh.default_effective_date  accounting_date
     , -1                          ae_header_id
     , ''                          cust_nbr
     , ''                          cust_name
     , ''                          transaction_number
	 , -1						   ae_line_num								-- Added for CR#2733
     , jel.je_line_num             je_line_num
     , jel.description             je_line_description
     , ''                          accounting_class_code
     , cc.segment1                 LE
     , cc.segment2                 PL
     , cc.segment3                 SITE
     , cc.segment4                 CC
     , cc.segment5                 ACCOUNT
     , cc.segment6                 IC
     , jel.entered_dr              entered_dr
     , jel.entered_cr              entered_cr
     , jel.accounted_dr            accounted_dr
     , jel.accounted_cr            accounted_cr
FROM
        gl_je_headers        jeh
   JOIN gl_je_lines          jel ON  ( jel.je_header_id = jeh.je_header_id )
   JOIN gl_je_batches        jeb ON ( jeb.je_batch_id = jeh.je_batch_id )
   JOIN gl_code_combinations  cc ON ( cc.code_combination_id = jel.code_combination_id )
   JOIN gl_ledgers             l ON ( l.ledger_id = jeh.ledger_id )
WHERE (jeh.je_source NOT IN ('Payables','Receivables') -- Don't drive from this table
       OR
       (    jeh.je_source IN ('Payables','Receivables')
        AND jeh.reversed_je_header_id is not null 
       )
      )
  --AND jeh.ledger_id = :P_LEDGER_ID
  AND jeh.status = 'P'
  --AND to_date(jeh.period_name,'MON-YY') between to_date(:P_START_PERIOD,'MON-YY') and to_date(:P_END_PERIOD,'MON-YY')
  	--AND cc.segment1 between substr(:P_MIN_FLEX,1,3) and substr(:P_MAX_FLEX,1,3)
	--AND cc.segment2 between substr(:P_MIN_FLEX,5,3) and substr(:P_MAX_FLEX,5,3)
	--AND cc.segment3 between substr(:P_MIN_FLEX,9,3) and substr(:P_MAX_FLEX,9,3)
	--AND cc.segment4 between substr(:P_MIN_FLEX,13,4) and substr(:P_MAX_FLEX,13,4)
	--AND cc.segment5 between substr(:P_MIN_FLEX,18,6) and substr(:P_MAX_FLEX,18,6)
	--AND cc.segment6 between substr(:P_MIN_FLEX,25,3) and substr(:P_MAX_FLEX,25,3)
UNION								
--cash receipts
SELECT
       xla.ledger_id
     , jeb.je_batch_id JE_BATCH_ID
     , jeh.je_header_id JE_HEADER_ID
     , cust.customer_id VENDOR_CUSTOMER_ID
     , xla.code_combination_id CODE_COMBINATION_ID              
     , xla.ledger
     , jeb.name                    je_batch_name
     , jeh.name                    je_journal_name
     , xla.source
     , xla.je_category_name
     , xla.currency_code
     , xla.period_name
     , xla.accounting_date
     , xla.ae_header_id
     , cust.customer_number        cust_nbr
     , cust.customer_name          cust_name
     , xla.transaction_number
	 , xla.ae_line_num											-- Added for CR#2733
     , jel.je_line_num
     , xla.je_line_description
       ||xla.ae_header_id          je_line_description
     , xla.accounting_class_code
     , xla.le
     , xla.pl
     , xla.site
     , xla.cc
     , xla.account
     , xla.ic
     , xla.entered_dr              entered_dr
     , xla.entered_cr              entered_cr
     , xla.accounted_dr            accounted_dr
     , xla.accounted_cr            accounted_cr
FROM xla
   JOIN gl_import_references    gir ON ( gir.gl_sl_link_id = xla.gl_sl_link_id )
   JOIN gl_je_lines             jel ON ( gir.je_header_id = jel.je_header_id
                                     AND gir.je_line_num = jel.je_line_num )
   JOIN gl_je_headers           jeh ON ( jeh.je_header_id =jel.je_header_id )
   JOIN gl_je_batches           jeb ON ( jeb.je_batch_id = gir.je_batch_id )
   LEFT JOIN ar_customers           cust ON ( cust.customer_id = xla.party_id )
WHERE xla.source = 'Receivables'
  and xla.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
  AND xla.je_category_name = 'Receipts'
  AND jeh.status = 'P'
UNION
--20210128 add credit memo categories line
SELECT
       xla.ledger_id
     , jeb.je_batch_id JE_BATCH_ID
     , jeh.je_header_id JE_HEADER_ID
     , cust.customer_id VENDOR_CUSTOMER_ID
     , xla.code_combination_id CODE_COMBINATION_ID              
     , xla.ledger
     , jeb.name                    je_batch_name
     , jeh.name                    je_journal_name
     , xla.source
     , xla.je_category_name
     , xla.currency_code
     , xla.period_name
     , xla.accounting_date
     , xla.ae_header_id
     , cust.customer_number        cust_nbr
     , cust.customer_name          cust_name
     , xla.transaction_number
	 , xla.ae_line_num											-- Added for CR#2733
     , jel.je_line_num
     , xla.je_line_description
       ||xla.ae_header_id          je_line_description
     , xla.accounting_class_code
     , xla.le
     , xla.pl
     , xla.site
     , xla.cc
     , xla.account
     , xla.ic
     , xla.entered_dr              entered_dr
     , xla.entered_cr              entered_cr
     , xla.accounted_dr            accounted_dr
     , xla.accounted_cr            accounted_cr
FROM xla
   JOIN gl_import_references    gir ON ( gir.gl_sl_link_id = xla.gl_sl_link_id )
   JOIN gl_je_lines             jel ON ( gir.je_header_id = jel.je_header_id
                                     AND gir.je_line_num = jel.je_line_num )
   JOIN gl_je_headers           jeh ON ( jeh.je_header_id =jel.je_header_id )
   JOIN gl_je_batches           jeb ON ( jeb.je_batch_id = gir.je_batch_id )
   LEFT JOIN ar_customers           cust ON ( cust.customer_id = xla.party_id )
WHERE xla.source = 'Receivables'
  and xla.ACCOUNTING_CLASS_CODE = 'EXCHANGE_GAIN_LOSS'
  --and xla.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
  AND xla.je_category_name = 'Credit Memos'
  AND jeh.status = 'P'
ORDER BY period_name, ledger, source, je_category_name;
