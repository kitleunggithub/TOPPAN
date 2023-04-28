--------------------------------------------------------
--  DDL for Package Body XXBS_INVOICE_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXBS_INVOICE_WF_PKG" IS
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
                              ) IS
        v_item_type  VARCHAR2(1000):='XXBSINV';
        v_item_key   VARCHAR2(1000):='';
        v_process    VARCHAR2(1000) := 'XXBSNOTFPROC';--Process must be defined as runnable process.
        l_trx_number VARCHAR2(4000);

        BEGIN

        SELECT XXBS_INVOICE_WF_S.NEXTVAL INTO v_item_key FROM dual;

        /*To successfully trigger a workflow, we need to perform the following task
        1) Create the process
        2) Set attribute values
        3) Start the process
        4) commit.
        */

        /*1) Call create process API. This will create a instance of the currently saved workflow definition.
        item_key and item_type is used to uniquely identify the workflow definition in database.Item key is the
        unique key of the instance of a particular workflow deifnition(identified by item_type).*/
        wf_engine.createprocess(itemtype => v_item_type,
                                itemkey  => v_item_key,
                                process  => v_process);
        -------2) Set attribute values
        wf_engine.SetItemAttrText(itemtype => v_item_type,
                                  itemkey  => v_item_key,
                                  aname    => 'BILLER_NAME',
                                  avalue   => p_biller_name);

        l_trx_number := REPLACE(p_trx_number,'|',CHR(10)||CHR(13));


        wf_engine.SetItemAttrText(itemtype => v_item_type,
                                  itemkey  => v_item_key,
                                  aname    => 'TRX_NUMBER',
                                  avalue   => l_trx_number); 
        wf_engine.SetItemAttrText(itemtype => v_item_type,
                                  itemkey  => v_item_key,
                                  aname    => 'RECEIVE_ROLE',
                                  avalue   => p_receive_role);                           

        --3) Start the process
        wf_engine.startprocess(v_item_type, v_item_key);                                                                                  
        --4) Commit;
        COMMIT; 

		p_return_status:= 'S';
		p_msg:= NULL;    

    EXCEPTION WHEN OTHERS THEN
      --raise_application_error(-20001,'Error in initiating the workflow1 '||SQLERRM);
      p_return_status:= 'F';
      p_msg:='ERROR: ' || DBMS_UTILITY.FORMAT_ERROR_STACK;      
    END START_WORKFLOW;       

END XXBS_INVOICE_WF_PKG;


/
