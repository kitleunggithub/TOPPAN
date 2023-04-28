--------------------------------------------------------
--  DDL for Package XXTM_TABLEAU_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXTM_TABLEAU_BATCH_PKG" as
/*******************************************************************************
 *
 * Module Name : XXTM
 * Package Name: XXTM_TABLEAU_BATCH_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 28-APR-2021
 *
 * Purpose     : This program handle TABLEAU Batch Job.
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung    28-APR-2021   Initial Release.
 *
 *******************************************************************************/

    --
    -- Procedure to Submit Job.
    --
    procedure submit_job (
        errbuf          out varchar2,
        retcode         out varchar2,
        p_batch_id      in  number);   

end XXTM_TABLEAU_BATCH_PKG;


/
