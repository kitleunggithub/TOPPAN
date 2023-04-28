--------------------------------------------------------
--  DDL for Package XXCONV_CUSTOMERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXCONV_CUSTOMERS_PKG" as
/*******************************************************************************
 *
 * Module Name : Receables
 * Package Name: XXCONV_CUSTOMERS_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-OCT-2020
 *
 * Purpose     : This program will upload Customers.
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung   18-FEB-2020   Initial Release.
 *
 *******************************************************************************/

  procedure main (
    errbuf          out varchar2,
    retcode         out varchar2,
    p_file_path  in     varchar2,
    p_file_name  in     varchar2,
    p_request_id    in  number,
    p_batch_yn  in     varchar2);

end xxconv_customers_pkg;


/
