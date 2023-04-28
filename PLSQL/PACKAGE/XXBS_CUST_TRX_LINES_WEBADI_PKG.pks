--------------------------------------------------------
--  DDL for Package XXBS_CUST_TRX_LINES_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXBS_CUST_TRX_LINES_WEBADI_PKG" 
IS
/************************************************************************
 * Package:     XXBS_CUST_TRX_LINES_WEBADI_PKG
 *
 * MODIFICATION HISTORY:
 * ver Name           Date          Description
 * === =============  ============  =====================================
 * 1.0 Kit Leung      2021-02-10    Created
 * 1.1 Kit Leung      2021-05-24    handle combine invoice case
 *
 ************************************************************************/

  FUNCTION get_orig_customer_trx_id (p_customer_trx_id IN NUMBER) RETURN NUMBER;

  PROCEDURE import_data(p_run_id            IN NUMBER/*,
                        x_msg               OUT NOCOPY VARCHAR,
                        x_request_id        OUT NOCOPY NUMBER*/ );

END XXBS_CUST_TRX_LINES_WEBADI_PKG;


/
