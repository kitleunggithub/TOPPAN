DROP TABLE XXTM.XXHR_ERRORS CASCADE CONSTRAINTS;

CREATE TABLE XXTM.XXHR_ERRORS
(
  ERROR_ID            NUMBER(15)                NOT NULL,
  APPLICATION         VARCHAR2(20 BYTE)         NOT NULL,
  MODULE_NAME         VARCHAR2(20 BYTE)         NOT NULL,
  REQUEST_ID          NUMBER,
  REFERENCE_ID        VARCHAR2(30 BYTE),
  ERROR_NUMBER        NUMBER,
  ERROR_MSG           VARCHAR2(100 BYTE),
  ATTRIBUTE_CATEGORY  VARCHAR2(30 BYTE),
  ATTRIBUTE1          VARCHAR2(150 BYTE),
  ATTRIBUTE2          VARCHAR2(150 BYTE),
  ATTRIBUTE3          VARCHAR2(150 BYTE),
  ATTRIBUTE4          VARCHAR2(150 BYTE),
  ATTRIBUTE5          VARCHAR2(150 BYTE),
  CREATION_DATE       DATE                      NOT NULL,
  CREATED_BY          NUMBER(15)                NOT NULL,
  LAST_UPDATE_DATE    DATE                      NOT NULL,
  LAST_UPDATE_BY      NUMBER(15)                NOT NULL,
  LAST_UPDATE_LOGIN   NUMBER(15)
)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;

CREATE OR REPLACE PUBLIC SYNONYM XXHR_ERRORS FOR XXTM.XXHR_ERRORS;

GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE ON XXTM.XXHR_ERRORS TO APPS;