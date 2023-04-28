--------------------------------------------------------
--  DDL for Package XXFA_DTL_GBL_AST_LST_BIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXFA_DTL_GBL_AST_LST_BIP_PKG" 
AS
   P_BOOK_TYPE       VARCHAR2 (15);
   P_BOOK_TYPE_CODE  VARCHAR2 (200);
   P_PERIOD_NAME     VARCHAR2 (15);

   FUNCTION beforereport
      RETURN BOOLEAN;
END XXFA_DTL_GBL_AST_LST_BIP_PKG;

/
