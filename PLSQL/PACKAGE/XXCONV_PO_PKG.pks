--------------------------------------------------------
--  DDL for Package XXCONV_PO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXCONV_PO_PKG" as
/*******************************************************************************
 *
 * Module Name : Payables
 * Package Name: XXCONV_PO_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-OCT-2020
 *
 * Purpose     : This program will upload AP Invoices.
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

end xxconv_po_pkg;


/
