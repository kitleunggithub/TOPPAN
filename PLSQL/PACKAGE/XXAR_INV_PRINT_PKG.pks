--------------------------------------------------------
--  DDL for Package XXAR_INV_PRINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAR_INV_PRINT_PKG" 
----------------------------------------------------------------------------------
-- Purpose: Generate BI Publisher AR Invoices

----------------------------------------------------------------------------------
IS
PROCEDURE Generate_inv_main (ERRBUF varchar2,RETCODE number,P_AR_TRX_NUMBER VARCHAR2);
PROCEDURE Generate_inv_data (P_AR_TRX_NUMBER IN VARCHAR2,P_REQUEST_ID IN NUMBER);
FUNCTION  Get_INV_SALESREP  (P_AR_TRX_NUMBER IN VARCHAR2) RETURN VARCHAR2;
END xxar_inv_print_pkg;

/
