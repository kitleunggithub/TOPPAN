--DROP TABLE XXPO_LIST;

  CREATE TABLE "TABLEAUETL"."XXPO_LIST" 
   (	
    "ORG_ID" NUMBER,    
    "PO_HEADER_ID" NUMBER, 
	"PO_LINE_ID" NUMBER, 
	"PO_DIST_ID" NUMBER, 
	"VENDOR_ID" NUMBER, 
	"PROJECT_ID" NUMBER(15,0),
	"OPERATING_UNIT_NAME" VARCHAR2(240 BYTE),     
	"PO_NUMBER" VARCHAR2(20 BYTE), 
	"REVISION_NUM" NUMBER, 
	"ENABLED_FLAG" VARCHAR2(1 BYTE), 
	"ORDER_DATE" DATE, 
	"CURRENCY_CODE" VARCHAR2(15 BYTE), 
	"EXCHANGE_RATE" NUMBER, 
	"HEADER_STATUS" VARCHAR2(25 BYTE), 
	"APPROVAL_FLAG" VARCHAR2(1 BYTE), 
	"VENDOR_NAME" VARCHAR2(240 BYTE), 
	"VENDOR_TYPE" VARCHAR2(30 BYTE), 
    "LINE_NUM" NUMBER, 
	"LINE_UNIT_PRICE" NUMBER, 
	"LINE_DESC" VARCHAR2(240 BYTE), 
	"LINE_STATUS" VARCHAR2(25 BYTE), 
	"DIST_QTY" NUMBER, 
	"DIST_QTY_BILLED" NUMBER, 
	"CHARGE_ACC_SEG1" VARCHAR2(240 BYTE), 
	"CHARGE_ACC_SEG2" VARCHAR2(240 BYTE), 
	"CHARGE_ACC_SEG3" VARCHAR2(240 BYTE), 
	"CHARGE_ACC_SEG4" VARCHAR2(240 BYTE), 
	"CHARGE_ACC_SEG5" VARCHAR2(240 BYTE), 
	"CHARGE_ACC_SEG6" VARCHAR2(240 BYTE), 
	"DIST_ACC_SEG1" VARCHAR2(240 BYTE), 
	"DIST_ACC_SEG2" VARCHAR2(240 BYTE), 
	"DIST_ACC_SEG3" VARCHAR2(240 BYTE), 
	"DIST_ACC_SEG4" VARCHAR2(240 BYTE), 
	"DIST_ACC_SEG5" VARCHAR2(240 BYTE), 
	"DIST_ACC_SEG6" VARCHAR2(240 BYTE), 
	"DIST_EXP_TYPE" VARCHAR2(30 BYTE), 
	"PROJECT_NUMBER" VARCHAR2(25 BYTE), 
	"PROJECT_NAME" VARCHAR2(250 BYTE), 
	"BUYER_NAME" VARCHAR2(240 BYTE), 
	"REQUESTOR_NAME" VARCHAR2(240 BYTE), 
	"REQUESTOR_EXP_SEG1" VARCHAR2(240 BYTE), 
	"REQUESTOR_EXP_SEG2" VARCHAR2(240 BYTE), 
	"REQUESTOR_EXP_SEG3" VARCHAR2(240 BYTE), 
	"REQUESTOR_EXP_SEG4" VARCHAR2(240 BYTE), 
	"REQUESTOR_EXP_SEG5" VARCHAR2(240 BYTE), 
	"REQUESTOR_EXP_SEG6" VARCHAR2(240 BYTE),
    CONSTRAINT "XXPO_LIST_PK" PRIMARY KEY ("ORG_ID", "PO_HEADER_ID", "PO_LINE_ID", "PO_DIST_ID")
   ) TABLESPACE "USERS";
   
CREATE OR REPLACE PUBLIC SYNONYM XXPO_LIST FOR TABLEAUETL.XXPO_LIST;
