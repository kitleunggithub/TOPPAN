--------------------------------------------------------
--  DDL for Package XXCONV_SUPPLIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXCONV_SUPPLIERS_PKG" as
/*******************************************************************************
 *
 * Module Name : Payables
 * Package Name: XXCONV_SUPPLIERS_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-OCT-2020
 *
 * Purpose     : This program will upload Suppliers.
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung   18-FEB-2020   Initial Release.
 *
 *******************************************************************************/

    function get_ou_segment1 (p_org_code in varchar2)
    return varchar2;

  procedure main (
    errbuf          out varchar2,
    retcode         out varchar2,
    p_file_path  in     varchar2,
    p_file_name  in     varchar2,
    p_request_id    in  number,
    p_batch_yn  in     varchar2);

end xxconv_suppliers_pkg;


/
