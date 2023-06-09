--DROP TABLE XXAR_CUSTOMER_MASTER;

  CREATE TABLE "TABLEAUETL"."XXAR_CUSTOMER_MASTER" 
   ("ORG_ID" NUMBER(15,0), 
	"CUST_ACCOUNT_ID" NUMBER(15,0) , 
	"CUST_ACCT_SITE_ID" NUMBER(15,0) , 
	"SITE_USE_ID" NUMBER(15,0) , 
	"PARTY_ID" NUMBER(15,0) , 
	"PARTY_SITE_ID" NUMBER(15,0) , 
	"PERSON_PROFILE_ID" NUMBER(15,0), 
	"PERSON_PARTY_ID" NUMBER(15,0), 
	"EMAIL_CONTACT_POINT_ID" NUMBER(15,0), 
	"PHONE_CONTACT_POINT_ID" NUMBER(15,0), 
	"OPERATING_UNIT_NAME" VARCHAR2(240 BYTE) , 
	"CUSTOMER_NAME" VARCHAR2(360 BYTE) , 
	"NAME_PRONUNCIATION" VARCHAR2(320 BYTE), 
	"ACCOUNT_NUMBER" VARCHAR2(30 BYTE) , 
	"ACCOUNT_TYPE" VARCHAR2(80 BYTE) , 
	"PROFILE_CLASS" VARCHAR2(30 BYTE), 
	"PAYMENT_TERM" VARCHAR2(20 BYTE), 
	"PRIMARY_SALESREP" VARCHAR2(360 BYTE), 
	"PRIMARY_SALESREP_SPLIT" NUMBER, 
	"SALESREP_2ND" VARCHAR2(360 BYTE), 
	"SALESREP_2ND_SPLIT" NUMBER, 
	"SALESREP_3RD" VARCHAR2(360 BYTE), 
	"SALESREP_3RD_SPLIT" NUMBER, 
	"SALESREP_4TH" VARCHAR2(360 BYTE), 
	"SALESREP_4TH_SPLIT" NUMBER, 
	"SALESREP_5TH" VARCHAR2(360 BYTE), 
	"SALESREP_5TH_SPLIT" NUMBER, 
	"STOCK_CODE" VARCHAR2(150 BYTE), 
	"CUSTOMER_SINCE" DATE, 
	"CREDIT_RATING" VARCHAR2(150 BYTE), 
	"CREDIT_LIMIT" NUMBER, 
	"CREDIT_PERIOD" NUMBER, 
	"STATUS" VARCHAR2(150 BYTE), 
	"REMARK" VARCHAR2(150 BYTE), 
	"SOE_YN" VARCHAR2(150 BYTE), 
	"SITE_NUMBER" VARCHAR2(30 BYTE) , 
	"COUNTRY_CODE" VARCHAR2(60 BYTE) , 
	"ADDRESS_LINE_1" VARCHAR2(240 BYTE) , 
	"ADDRESS_LINE_2" VARCHAR2(240 BYTE), 
	"ADDRESS_LINE_3" VARCHAR2(240 BYTE), 
	"ADDRESS_LINE_4" VARCHAR2(240 BYTE), 
	"CITY" VARCHAR2(60 BYTE), 
	"COUNTY" VARCHAR2(60 BYTE), 
	"STATE" VARCHAR2(60 BYTE), 
	"PROVINCE" VARCHAR2(60 BYTE), 
	"POSTAL_CODE" VARCHAR2(60 BYTE), 
	"PURPOSE" VARCHAR2(30 BYTE) , 
	"LOCATION" VARCHAR2(40 BYTE) , 
	"PRIMARY_FLAG" VARCHAR2(1 BYTE) , 
	"CONTACT_FIRST_NAME" VARCHAR2(150 BYTE), 
	"CONTACT_MIDDLE_NAME" VARCHAR2(60 BYTE), 
	"CONTACT_LAST_NAME" VARCHAR2(150 BYTE), 
	"CONTACT_JOB_TITLE" VARCHAR2(100 BYTE), 
	"CONTACT_NUMBER" VARCHAR2(30 BYTE), 
	"EMAIL" VARCHAR2(2000 BYTE), 
	"EMAIL_PRIMARY_FLAG" VARCHAR2(1 BYTE), 
	"TEL_COUNTRY_CODE" VARCHAR2(10 BYTE), 
	"TEL_AREA_CODE" VARCHAR2(10 BYTE), 
	"TEL_PHONE_NUMBER" VARCHAR2(40 BYTE), 
	"TEL_PRIMARY_FLAG" VARCHAR2(1 BYTE),
    constraint XXAR_CUSTOMER_MASTER_PK primary key("ORG_ID","CUST_ACCOUNT_ID","CUST_ACCT_SITE_ID","SITE_USE_ID","PARTY_ID","PARTY_SITE_ID","PERSON_PROFILE_ID","PERSON_PARTY_ID","EMAIL_CONTACT_POINT_ID","PHONE_CONTACT_POINT_ID")
   ) TABLESPACE "USERS";

CREATE OR REPLACE PUBLIC SYNONYM XXAR_CUSTOMER_MASTER FOR TABLEAUETL.XXAR_CUSTOMER_MASTER;
