--drop table xxpa_cost;

  CREATE TABLE "TABLEAUETL"."XXPA_COST" 
   (	
    "ORG_ID" NUMBER(15,0), 
	"PROJECT_ID" NUMBER(15,0), 
	"VENDOR_ID" NUMBER, 
	"OPERATING_UNIT_NAME" VARCHAR2(240 BYTE), 
	"EXPENDITURE_ITEM_ID" NUMBER(15,0), 
	"PROJECT_NUMBER" VARCHAR2(25 BYTE), 
	"EXPENDITURE_ORG" VARCHAR2(240 BYTE), 
	"EXPENDITURE_CATEGORY" VARCHAR2(30 BYTE), 
	"EXPENDITURE_TYPE" VARCHAR2(30 BYTE), 
	"EXPENDITURE_ITEM_DATE" DATE, 
	"VENDOR_NAME" VARCHAR2(240 BYTE), 
	"QUANTITY" NUMBER, 
	"UOM" VARCHAR2(80 BYTE), 
	"BURDEN_COST" NUMBER, 
	"PROJECT_BURDENED_COST" NUMBER, 
	"EXPENDITURE_COMMENT" VARCHAR2(240 BYTE),
    CONSTRAINT "XXPA_COST_PK" PRIMARY KEY ("ORG_ID", "PROJECT_ID", "EXPENDITURE_ITEM_ID")
   ) TABLESPACE "USERS";

CREATE OR REPLACE PUBLIC SYNONYM XXPA_COST FOR TABLEAUETL.XXPA_COST;
