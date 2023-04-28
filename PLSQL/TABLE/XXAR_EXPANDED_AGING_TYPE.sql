create or replace TYPE "XXAR_EXPANDED_AGING_TYPE" AS OBJECT
(
   customer_name VARCHAR2(400)
  ,customer_number VARCHAR2(400)
--Dash Kit Leung - 05-MAY-2021    
  ,org_id VARCHAR2(400)
  ,cust_account_id VARCHAR2(400)
  ,ar_customer_trx_id VARCHAR2(400)
  ,operating_unit_name VARCHAR2(400)
  ,credit_limit VARCHAR2(400)
  ,stock_code VARCHAR2(400)
  ,soe_yn VARCHAR2(400)
  ,gl_date VARCHAR2(400)
--END Dash Kit Leung - 05-MAY-2021    
  ,business_unit VARCHAR2(400)
  ,site VARCHAR2(400)
  ,legal_entity VARCHAR2(400)
  ,primary_product_type VARCHAR2(400)
--Dash Kit Leung - 05-MAY-2021      
--  ,sales_rep VARCHAR2(400)
  ,primary_salesrep VARCHAR2(400)
  ,primary_salesrep_split VARCHAR2(400)
  ,salesrep_2nd VARCHAR2(400)
  ,salesrep_2nd_split VARCHAR2(400)
  ,salesrep_3rd VARCHAR2(400)
  ,salesrep_3rd_split VARCHAR2(400)
  ,salesrep_4th VARCHAR2(400)
  ,salesrep_4th_split VARCHAR2(400)
  ,salesrep_5th VARCHAR2(400)
  ,salesrep_5th_split VARCHAR2(400)  
  ,active_biller VARCHAR2(400)
--END Dash Kit Leung - 05-MAY-2021    
  ,payment_terms VARCHAR2(400)
--Dash Kit Leung - 08-MAR-2021  
--  ,collection_status VARCHAR2(400)
--  ,collection_stage1_date VARCHAR2(400)
--  ,collection_stage2_date VARCHAR2(400)
--End Dash Kit Leung - 08-MAR-2021
  ,invoice_number VARCHAR2(400)
  ,invoice_type VARCHAR2(400)
  ,invoice_date VARCHAR2(400)
  ,due_date VARCHAR2(400)
--Dash Kit Leung - 08-MAR-2021  
--  ,description VARCHAR2(400)
  ,description VARCHAR2(400)
  ,exchange_rate VARCHAR2(400)
  ,functional_currency VARCHAR2(400)
  ,outstanding_amount VARCHAR2(400)
  ,bucket0 VARCHAR2(400)
  ,bucket1 VARCHAR2(400)
  ,bucket2 VARCHAR2(400)
  ,bucket3 VARCHAR2(400)
  ,bucket4 VARCHAR2(400)
  ,bucket5 VARCHAR2(400)
  ,bucket6 VARCHAR2(400)
  ,bucket7 VARCHAR2(400) --KIT
  ,invoiced_currency VARCHAR2(400)
  ,amount_in_invoice_currency VARCHAR2(400)
);