--------------------------------------------------------
--  DDL for Table XXFA_BALANCES_REPORT_GT
--------------------------------------------------------

  CREATE TABLE "APPS"."XXFA_BALANCES_REPORT_GT" 
   (	"ASSET_ID" NUMBER(15,0), 
	"DISTRIBUTION_CCID" NUMBER(15,0), 
	"ADJUSTMENT_CCID" NUMBER(15,0), 
	"CATEGORY_BOOKS_ACCOUNT" VARCHAR2(25 BYTE), 
	"SOURCE_TYPE_CODE" VARCHAR2(15 BYTE), 
	"AMOUNT" NUMBER, 
	"COST_ACCOUNT" VARCHAR2(25 BYTE), 
	"COST_BEGIN_BALANCE" NUMBER, 
	"GROUP_ASSET_ID" NUMBER(15,0), 
	"BOOK_TYPE_CODE" VARCHAR2(15 BYTE)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "APPS_TS_TX_DATA" ;
