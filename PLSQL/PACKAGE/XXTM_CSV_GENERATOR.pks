--------------------------------------------------------
--  DDL for Package XXTM_CSV_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXTM_CSV_GENERATOR" AS
/*******************************************************************************
 *
 * Module Name : XXTM
 * Package Name: XXTM_CSV_GENERATOR
 *
 * Author      : DASH Kit Leung
 * Date        : 28-APR-2021
 *
 * Purpose     : This program propuse to convert SQL to CSV
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung    28-APR-2021   Initial Release.
 *
 *******************************************************************************/
PROCEDURE generate (errbuf       OUT VARCHAR2,
                    retcode      OUT NUMBER,
                    p_dir        IN  VARCHAR2,
                    p_file       IN  VARCHAR2,
                    p_out_type   IN  VARCHAR2,
                    p_query      IN  VARCHAR2);

PROCEDURE generate_file (p_dir        IN  VARCHAR2,
                         p_file       IN  VARCHAR2,
                         p_query      IN  VARCHAR2);

PROCEDURE generate_file_rc (p_dir        IN  VARCHAR2,
                            p_file       IN  VARCHAR2,
                            p_refcursor  IN OUT SYS_REFCURSOR);

PROCEDURE output (p_query  IN  VARCHAR2);

PROCEDURE output_rc (p_refcursor  IN OUT SYS_REFCURSOR);

PROCEDURE set_separator (p_sep  IN  VARCHAR2);

PROCEDURE set_quotes (p_add_quotes  IN  BOOLEAN := TRUE,
                      p_quote_char  IN  VARCHAR2 := '"',
                      p_escape      IN  BOOLEAN := TRUE);

END XXTM_CSV_GENERATOR;


/
