--------------------------------------------------------
--  DDL for Package XXAR_LOCKBOX_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAR_LOCKBOX_RPT_PKG" 
AS
PROCEDURE GENERATE_REPORT     (p_user_name in varchar2,p_resp_name in varchar2,LOCKBOX in VARCHAR2,EMAIL_ADDR in VARCHAR2,deposit_date  in VARCHAR2);
END XXAR_LOCKBOX_RPT_PKG;

/
