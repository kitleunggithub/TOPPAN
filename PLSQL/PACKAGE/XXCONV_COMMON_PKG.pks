--------------------------------------------------------
--  DDL for Package XXCONV_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXCONV_COMMON_PKG" as
/*******************************************************************************
 *
 * Module Name : Common
 * Package Name: XXCONV_COMMON_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-OCT-2020
 *
 * Purpose     : This program will upload Suppliers.
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung   30-OCT-2020   Initial Release.
 *
 *******************************************************************************/

    --
    -- Function to get file path.
    --
    FUNCTION get_file_path RETURN VARCHAR2;    

    procedure append_message (
        p_message    in out varchar2,
        p_text       in     varchar2,
        p_separator  in     varchar2 default ' | ');

    --
    -- Procedure to write Line to Log file.
    --
    procedure write_log (p_text  in varchar2);

    --
    -- Procedure to write Line to Output file.
    --
    procedure write_output (p_text  in varchar2);

    --
    -- Application Initialize
    --
    procedure apps_init ( p_user_id in number,
                        p_resp_key in varchar2,
                        p_appl_name in varchar2);

    -- Call SQL Loader to Upload Data to Staging Table
    FUNCTION upload_data (  p_request_id in number,
                            p_program_name in varchar2,
                            p_file_path  in     varchar2,
                            p_file_name  in     varchar2) 
    RETURN NUMBER;

    -- wait concurrent request
    FUNCTION wait_request (p_request_id in number) 
    RETURN VARCHAR2;

    -- a function used to get gl ccid
    -- if there is no ccid, the function will call api to return new ccid
    FUNCTION get_ccid(p_conc_segs   IN  VARCHAR2,
                    p_valid       IN BOOLEAN
                    ) RETURN NUMBER;

end xxconv_common_pkg;



/
