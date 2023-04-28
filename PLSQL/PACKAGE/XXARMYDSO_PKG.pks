--------------------------------------------------------
--  DDL for Package XXARMYDSO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXARMYDSO_PKG" AS
/*************************************************************
 * Package Name: CINVC0175_QOH
 *
 * Author : DASH
 * Date : 20-Feb-2021
 *
 * Purpose : Create Interface file foor MyDSO
 *
 * Change Log
 *
 * Name Date Remarks
 * ------------- ----------- ---------------------------------------------------
 * DASH          20-Feb-2021  Initial Release.
  *******************************************************************************/


    PROCEDURE generate_item    (ERRBUF OUT VARCHAR2,
                                RETCODE OUT VARCHAR2 ) ;

    PROCEDURE generate_client    (ERRBUF OUT VARCHAR2,
                                RETCODE OUT VARCHAR2 ) ;                

END XXARMYDSO_pkg;

/
