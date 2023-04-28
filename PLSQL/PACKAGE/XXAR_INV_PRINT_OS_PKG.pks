--------------------------------------------------------
--  DDL for Package XXAR_INV_PRINT_OS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAR_INV_PRINT_OS_PKG" 
/*----------------------------------------------------------------------------------
-- Purpose: Extract all outstanding ar invoices to print invoice print out again and sftp to DSO site.
Maintenance History:
  Date:          Version             Name            Remarks
  -----------    ----------------    -------------   ------------------
  10-MAR-2021    1.0                 Billy	    	 Initial Version
----------------------------------------------------------------------------------*/
IS
PROCEDURE PRINT_OS_INVOICES (ERRBUF varchar2,RETCODE number,SFTP_USERID VARCHAR2,SFTP_SERVER VARCHAR2,DAYS_BEFORE_LAST_UPD_DATE NUMBER);
END xxar_inv_print_os_pkg;

/
