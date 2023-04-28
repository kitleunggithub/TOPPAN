--------------------------------------------------------
--  DDL for Package XXCONV_AR_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXCONV_AR_INVOICES_PKG" as
/*******************************************************************************
 * 
 * Module Name : RECEIVABLES
 * Package Name: XXCONV_AR_INVOICES_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-OCT-2020
 *
 * Purpose     : This program will upload AR Invoices.
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung   30-OCT-2020   Initial Release.
 *
 *******************************************************************************/

  procedure main (
    errbuf          out varchar2,
    retcode         out varchar2,
    p_file_path  in     varchar2,
    p_file_name  in     varchar2,
    p_request_id    in  number);

end xxconv_ar_invoices_pkg;


/
