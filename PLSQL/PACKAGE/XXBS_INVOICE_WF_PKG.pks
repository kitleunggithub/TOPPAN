--------------------------------------------------------
--  DDL for Package XXBS_INVOICE_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXBS_INVOICE_WF_PKG" IS
/************************************************************************
 * Package:     XXBS_INVOICE_WF_PKG

 * Purpose: Custom Billing Workflow 

 * MODIFICATION HISTORY:
 * ver Name           Date          Description
 * === =============  ============  =====================================
 * 1.0 Kit Leung      15-JUN-2021   Created
 *
 ************************************************************************/
    PROCEDURE START_WORKFLOW(p_biller_name          IN VARCHAR2
                                ,p_trx_number       IN VARCHAR2
                                ,p_receive_role     IN VARCHAR2
                                ,p_return_status    OUT VARCHAR2 
                                ,p_msg              OUT VARCHAR2                         
                              );
END XXBS_INVOICE_WF_PKG;


/
