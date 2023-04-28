--------------------------------------------------------
--  DDL for Package Body XXFA_DTL_GBL_AST_LST_BIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXFA_DTL_GBL_AST_LST_BIP_PKG" 
AS
 FUNCTION beforereport
 RETURN BOOLEAN
 IS
 l_period VARCHAr2(15) := NULL;
 BEGIN
 --fnd_file.put_line(fnd_file.log,'Before Report Trigger Calling...!');
 select to_char(sysdate,'MON-YY')
 INTO l_period
 from dual ;

/* Commeneted by Nagaraj S on 16-Feb-2020 for CR2658 Modifications to Asset Listing Report */
/*
 IF l_period = P_PERIOD_NAME
 THEN
 fnd_file.put_line(fnd_file.log,'No period-end rate would be available before '||P_PERIOD_NAME);
 fnd_file.put_line(fnd_file.output,'No period-end rate would be available before '||P_PERIOD_NAME);
 RETURN FALSE;
 ELSE
 RETURN TRUE;
 END IF; */

  RETURN TRUE;

 END beforereport;
END XXFA_DTL_GBL_AST_LST_BIP_PKG;

/
