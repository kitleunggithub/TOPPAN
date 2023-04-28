--DROP TABLE XXTM.XXBS_CUST_TRX_LINES_WEBADI_STG;

CREATE TABLE XXTM.XXBS_CUST_TRX_LINES_WEBADI_STG
(
  ORG_ID                      NUMBER,
  OPERATING_UNIT              VARCHAR2(240 BYTE),
  CUSTOMER_TRX_ID             NUMBER,
  TRX_NUMBER                  VARCHAR2(20 BYTE),
  ORIG_CUSTOMER_TRX_ID        NUMBER,
  ORIG_TRX_NUMBER             VARCHAR2(20 BYTE), 
  LINE_NUMBER                 NUMBER,
  LEVEL_1                     VARCHAR2(4000 BYTE),
  LEVEL_2                     VARCHAR2(4000 BYTE),
  LEVEL_3                     VARCHAR2(4000 BYTE),
  PROJECT_ID                  NUMBER,
  PROJECT_ORG_ID              NUMBER,  
  PRODUCT_TYPE_ID             NUMBER,
  LINE_TYPE                   VARCHAR2(100 BYTE),
  LONG_DESCRIPTION            VARCHAR2(4000 BYTE),
  SELL_QTY                    NUMBER,
  UNIT_PRICE                  NUMBER,
  AMOUNT                      NUMBER,
  RUN_ID                      NUMBER,
  STATUS                      VARCHAR2(1 BYTE),
  ERROR_CODE                  VARCHAR2(30 BYTE),
  CREATED_BY                  NUMBER(15)        NOT NULL,
  CREATION_DATE               DATE              NOT NULL,
  LAST_UPDATED_BY             NUMBER(15)        NOT NULL,
  LAST_UPDATE_LOGIN           NUMBER(15),
  LAST_UPDATE_DATE            DATE              NOT NULL
);

CREATE INDEX XXTM.XXBS_CUST_TRX_LINES_WEBADI_STG_N1 ON XXTM.XXBS_CUST_TRX_LINES_WEBADI_STG
(RUN_ID);

CREATE PUBLIC SYNONYM XXBS_CUST_TRX_LINES_WEBADI_STG FOR XXTM.XXBS_CUST_TRX_LINES_WEBADI_STG;

CREATE SEQUENCE APPS.XXBS_WEBADI_RUN_ID_S;

BEGIN
    ad_dd.register_table ('XXTM', 'XXBS_CUST_TRX_LINES_WEBADI_STG', 'T');
    --ad_dd.delete_column( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'OPERATING_UNIT_ID');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'ORG_ID', 10, 'NUMBER', 22, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'OPERATING_UNIT', 20, 'VARCHAR2', 50, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'TRX_NUMBER', 30, 'VARCHAR2', 20, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'ORIG_TRX_NUMBER', 40, 'VARCHAR2', 20, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'LINE_NUMBER', 50, 'NUMBER', 22, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'LEVEL_1', 60, 'VARCHAR2', 4000, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'LEVEL_2', 70, 'VARCHAR2', 4000, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'LEVEL_3', 80, 'VARCHAR2', 4000, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'LINE_TYPE', 90, 'VARCHAR2', 100, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'LONG_DESCRIPTION', 100, 'VARCHAR2', 4000, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'SELL_QTY', 110, 'NUMBER', 22, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'UNIT_PRICE', 120, 'NUMBER', 22, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'AMOUNT', 130, 'NUMBER', 22, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'RUN_ID', 140, 'NUMBER', 22, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'STATUS', 150, 'VARCHAR2', 1, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'ERROR_CODE', 160, 'VARCHAR2', 30, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'CREATED_BY', 170, 'NUMBER', 22, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'CREATION_DATE', 180, 'DATE', 7, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'LAST_UPDATED_BY', 190, 'NUMBER', 22, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'LAST_UPDATE_LOGIN', 200, 'NUMBER', 22, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'LAST_UPDATE_DATE', 210, 'DATE', 7, 'N', 'N');

    commit;
END;

BEGIN
    ad_dd.delete_column( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'ORIG_TRX_NUMBER');
    ad_dd.delete_column( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'LONG_DESCRIPTION');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'ORIG_TRX_NUMBER', 40, 'VARCHAR2', 20, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXBS_CUST_TRX_LINES_WEBADI_STG', 'LONG_DESCRIPTION', 100, 'VARCHAR2', 4000, 'N', 'N');
    commit;
END;