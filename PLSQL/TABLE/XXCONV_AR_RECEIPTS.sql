CREATE TABLE APPS.XXCONV_AR_RECEIPTS
(
 SEQ_NUM                    NUMBER,
 OPERATING_UNIT_NAME        VARCHAR2(50 CHAR),
 CUSTOMER_NAME              VARCHAR2(360 CHAR),
 ACCOUNT_NUMBER             VARCHAR2(20 CHAR),
 REMIT_BANK_NAME            VARCHAR2(80 CHAR),
 REMIT_BRANCH_NAME	        VARCHAR2(80 CHAR),
 REMIT_BANK_ACCOUNT_NAME    VARCHAR2(100 CHAR),
 REMIT_BANK_ACCOUNT_NUM     VARCHAR2(100 CHAR),
 RECEIPT_METHOD_NAME        VARCHAR2(100 CHAR), 
 RECEIPT_NUMBER             VARCHAR2(100 CHAR), 
 RECEIPT_DATE               DATE,
 GL_DATE                    DATE,
 RECEIPT_EXCHANGE_RATE      NUMBER,
 RECEIPT_EXCHANGE_DATE      DATE,
 RECEIPT_EXCHANGE_RATE_TYPE VARCHAR2(30 CHAR),
 RECEIPT_CURRENCY_CODE      VARCHAR2(15 CHAR),
 AMOUNT                     NUMBER,
 CREATION_DATE              DATE,
 REQUEST_ID                 NUMBER,
 STATUS_FLAG                VARCHAR2(1 CHAR)    DEFAULT 'N',
 ERROR_MESSAGE              VARCHAR2(1000 CHAR),
 ORG_ID                     NUMBER 
) tablespace apps_ts_interface;

create or replace public synonym xxconv_ar_receipts for apps.xxconv_ar_receipts;

create index apps.xxconv_ar_receipts_n1 on apps.xxconv_ar_receipts (request_id)
tablespace apps_ts_interface;


