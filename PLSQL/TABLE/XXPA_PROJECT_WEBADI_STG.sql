--DROP TABLE XXTM.XXPA_PROJECT_WEBADI_STG;

CREATE TABLE XXTM.XXPA_PROJECT_WEBADI_STG
(
  ORG_ID                      NUMBER,
  OPERATING_UNIT              VARCHAR2(240 BYTE),
  FOREIGN_SYSTEM              VARCHAR2(50 BYTE),
  PROJECT_NUM                 VARCHAR2(25 BYTE), 
  ORGANIZATION_NAME           VARCHAR2(240 BYTE),
  CARRYING_OUT_ORGANIZATION_ID NUMBER,
  PROJECT_NAME                VARCHAR2(300 BYTE),
  PRODUCT_TYPE                NUMBER,
  PROJECT_START_DATE          DATE,
  TRANSACTION_NUM             VARCHAR2(20 BYTE),
  RUN_ID                      NUMBER,
  STATUS                      VARCHAR2(1 BYTE),
  ERROR_CODE                  VARCHAR2(30 BYTE),
  CREATED_BY                  NUMBER(15)        NOT NULL,
  CREATION_DATE               DATE              NOT NULL,
  LAST_UPDATED_BY             NUMBER(15)        NOT NULL,
  LAST_UPDATE_LOGIN           NUMBER(15),
  LAST_UPDATE_DATE            DATE              NOT NULL
);


CREATE INDEX XXTM.XXPA_PROJECT_WEBADI_STG_N1 ON XXTM.XXPA_PROJECT_WEBADI_STG
(RUN_ID);

CREATE PUBLIC SYNONYM XXPA_PROJECT_WEBADI_STG FOR XXTM.XXPA_PROJECT_WEBADI_STG;

CREATE SEQUENCE APPS.XXPA_PROJECT_WEBADI_RUN_ID_S;

CREATE SEQUENCE APPS.XXPA_PROJECT_SEQ_S;

BEGIN

--    ad_dd.delete_table ('XXTM', 'XXPA_PROJECT_WEBADI_STG');
    ad_dd.register_table ('XXTM', 'XXPA_PROJECT_WEBADI_STG', 'T');
    --ad_dd.delete_column( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'OPERATING_UNIT_ID');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'ORG_ID', 10, 'NUMBER', 22, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'OPERATING_UNIT', 15, 'VARCHAR2', 50, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'FOREIGN_SYSTEM', 17, 'VARCHAR2', 50, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'PROJECT_NUM', 20, 'VARCHAR2', 25, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'ORGANIZATION_NAME', 30, 'VARCHAR2', 240, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'PROJECT_NAME', 40, 'VARCHAR2', 250, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'PRODUCT_TYPE', 50, 'NUMBER', 22, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'PROJECT_START_DATE', 60, 'DATE', 7, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'TRANSACTION_NUM', 70, 'VARCHAR2', 20, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'RUN_ID', 80, 'NUMBER', 22, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'STATUS', 90, 'VARCHAR2', 1, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'ERROR_CODE', 100, 'VARCHAR2', 30, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'CREATED_BY', 110, 'NUMBER', 22, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'CREATION_DATE', 120, 'DATE', 7, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'LAST_UPDATED_BY', 130, 'NUMBER', 22, 'N', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'LAST_UPDATE_LOGIN', 140, 'NUMBER', 22, 'Y', 'N');
    ad_dd.register_column ( 'XXTM',  'XXPA_PROJECT_WEBADI_STG', 'LAST_UPDATE_DATE', 150, 'DATE', 7, 'N', 'N');

    commit;
END;