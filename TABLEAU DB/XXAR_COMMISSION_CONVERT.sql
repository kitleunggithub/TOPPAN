  CREATE TABLE "TABLEAUETL"."XXAR_COMMISSION_CONVERT" 
   (	
    "ORG_ID" NUMBER(15,0), 
	"AR_CUSTOMER_TRX_ID" NUMBER(15,0), 
	"PROJECT_ID" NUMBER(15,0), 
	"OPERATING_UNIT_NAME" VARCHAR2(240 BYTE), 
	"PROJECT_NUMBER" VARCHAR2(30 BYTE), 
	"PROJECT_NAME" VARCHAR2(240 BYTE), 
	"GL_DATE" DATE, 
	"INVOICE_NUMBER" VARCHAR2(50 BYTE), 
	"PRODUCT" VARCHAR2(50 BYTE), 
	"CUSTOMER_NAME" VARCHAR2(360 BYTE), 
	"INVOICE_DATE" DATE, 
	"INVOICE_DUE_DATE" DATE, 
	"RECEIPT_DATE" DATE, 
	"TOTAL_INVOICE_AMOUNT_HKD" NUMBER, 
	"AMOUNT_APPLIED_HKD" NUMBER, 
	"FULLY_SETTLED" VARCHAR2(1 BYTE), 
	"PROJECT_COMPLETION_DATE" DATE, 
	"SETTLED_OVER_180_YN" CHAR(1 BYTE), 
	"TOTAL_REVENUE_HKD" NUMBER, 
	"INTEREST" NUMBER, 
	"TOTAL_COST" NUMBER, 
	"NET_MARGIN" NUMBER, 
	"NET_MARGIN_P" NUMBER, 
	"COMMISSION_RATE" NUMBER, 
	"ENTITLEMENT_TOTAL" NUMBER, 
	"COMMISSION_TOTAL" NUMBER, 
	"SALES_NAME" VARCHAR2(360 BYTE), 
	"SALES_SPLIT" NUMBER, 
	"SALES_ENTITLEMENT" NUMBER, 
	"SALES_COMMISSION" NUMBER
   ) TABLESPACE "USERS" ;

CREATE OR REPLACE PUBLIC SYNONYM XXAR_COMMISSION_CONVERT FOR TABLEAUETL.XXAR_COMMISSION_CONVERT;
