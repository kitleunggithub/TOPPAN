drop table TABLEAUETL.XXGL_ACCOUNT_ANALYSIS;

  CREATE TABLE "TABLEAUETL"."XXGL_ACCOUNT_ANALYSIS" 
   (	"LEDGER_ID" NUMBER(15,0), 
	"JE_BATCH_ID" NUMBER(15,0), 
	"JE_HEADER_ID" NUMBER(15,0), 
	"VENDOR_CUSTOMER_ID" NUMBER, 
	"CODE_COMBINATION_ID" NUMBER(15,0), 
	"LEDGER" VARCHAR2(30 BYTE), 
	"JE_BATCH_NAME" VARCHAR2(100 BYTE), 
	"JE_JOURNAL_NAME" VARCHAR2(100 BYTE), 
	"SOURCE" VARCHAR2(240 BYTE), 
	"JE_CATEGORY_NAME" VARCHAR2(30 BYTE), 
	"CURRENCY_CODE" VARCHAR2(15 BYTE), 
	"PERIOD_NAME" VARCHAR2(15 BYTE), 
	"ACCOUNTING_DATE" DATE, 
	"AE_HEADER_ID" NUMBER, 
	"VENDOR_CUSTOMER_NUMBER" VARCHAR2(30 BYTE), 
	"VENDOR_CUSTOMER_NAME" VARCHAR2(240 BYTE), 
	"TRANSACTION_NUMBER" VARCHAR2(240 BYTE), 
	"AE_LINE_NUM" NUMBER, 
	"JE_LINE_NUM" NUMBER(15,0), 
	"JE_LINE_DESCRIPTION" VARCHAR2(2036 BYTE), 
	"ACCOUNTING_CLASS_CODE" VARCHAR2(30 BYTE), 
	"LEGAL_ENTITY" VARCHAR2(240 BYTE), 
	"PRODUCT_LINE" VARCHAR2(240 BYTE), 
	"SITE" VARCHAR2(240 BYTE), 
	"COST_CENTER" VARCHAR2(240 BYTE), 
	"ACCOUNT" VARCHAR2(240 BYTE), 
	"INTERCOMPANY" VARCHAR2(240 BYTE), 
	"ENTERED_DR" NUMBER, 
	"ENTERED_CR" NUMBER, 
	"ACCOUNTED_DR" NUMBER, 
	"ACCOUNTED_CR" NUMBER,
    CONSTRAINT "XXGL_ACCOUNT_ANALYSIS_PK" PRIMARY KEY ("LEDGER_ID", "JE_BATCH_ID", "JE_HEADER_ID", "JE_LINE_NUM", "AE_HEADER_ID", "AE_LINE_NUM")
   ) TABLESPACE "USERS" ;

CREATE OR REPLACE PUBLIC SYNONYM XXGL_ACCOUNT_ANALYSIS FOR TABLEAUETL.XXGL_ACCOUNT_ANALYSIS;
