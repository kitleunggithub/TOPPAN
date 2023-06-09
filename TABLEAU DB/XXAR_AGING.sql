--drop table TABLEAUETL.XXAR_AGING

  CREATE TABLE "TABLEAUETL"."XXAR_AGING" 
   (
    "ORG_ID" NUMBER,
    "CUST_ACCOUNT_ID" NUMBER, 
    "AR_CUSTOMER_TRX_ID" NUMBER,
    "OPERATING_UNIT_NAME" VARCHAR2(240 BYTE), 
    "CUSTOMER_NAME" VARCHAR2(360 BYTE), 
	"CUSTOMER_NUMBER" VARCHAR2(30 BYTE),
    "CREDIT_LIMIT" NUMBER, 
    "STOCK_CODE" VARCHAR2(240 BYTE), 
    "SOE_YN" VARCHAR2(50 BYTE), 
    "PRODUCT_LINE" VARCHAR2(240 BYTE), 
    "SITE" VARCHAR2(240 BYTE), 
    "LEGAL_ENTITY" VARCHAR2(240 BYTE), 
    "PRIMARY_PRODUCT_TYPE" VARCHAR2(50 BYTE), 
    "PRIMARY_SALESREP" VARCHAR2(360 BYTE), 
    "PRIMARY_SALESREP_SPLIT" NUMBER, 
    "SALESREP_2ND" VARCHAR2(360 BYTE), 
    "SALESREP_2ND_SPLIT" NUMBER, 
    "SALESREP_3RD" VARCHAR2(360 BYTE), 
    "SALESREP_3RD_SPLIT" NUMBER ,
    "SALESREP_4TH" VARCHAR2(360 BYTE), 
    "SALESREP_4TH_SPLIT" NUMBER ,
    "SALESREP_5TH" VARCHAR2(360 BYTE), 
    "SALESREP_5TH_SPLIT" NUMBER ,    
    "ACTIVE_BILLER" VARCHAR2(240 BYTE), 
    "PAYMENT_TERMS" VARCHAR2(15 BYTE) ,
    "INVOICE_NUMBER" VARCHAR2(50 BYTE) ,
    "INVOICE_TYPE" VARCHAR2(20 BYTE) ,
    "INVOICE_DATE" DATE ,
    "DUE_DATE" DATE ,
    "GL_DATE" DATE ,
    "BILL_TRX_DESC" VARCHAR2(300 BYTE) ,
    "EXCHANGE_RATE" NUMBER ,
    "FUNC_CURRENCY" VARCHAR2(15 BYTE) ,
    "AMOUNT_DUE" NUMBER ,
    "CURRENT_DUE" NUMBER ,
    "PAST_DUE30" NUMBER ,
    "PAST_DUE60" NUMBER ,
    "PAST_DUE90" NUMBER ,
    "PAST_DUE120" NUMBER ,
    "PAST_DUE180" NUMBER ,
    "PAST_DUE360" NUMBER ,
    "PAST_DUEOVER361" NUMBER ,
    "INVOICE_CURRENCY" VARCHAR2(15 BYTE) ,
    "AMOUNT_IN_INVOICE_CURRENCY" NUMBER
   ) TABLESPACE "USERS";

CREATE OR REPLACE PUBLIC SYNONYM XXAR_AGING FOR TABLEAUETL.XXAR_AGING;


select * from XXAR_AGING;