create or replace PROCEDURE      XXAR_SUBMIT_LOCKBOX
        (p_user_name in varchar2,
        p_resp_name in varchar2,
        p_lockbox in varchar2,
        p_deposit_date in varchar2,
        p_data_file in varchar2)

IS
/*******************************************************************
 * Created 4/25/2016 by Jill DiLeva
 * procedure is called by XXAR_LOCKBOX ksh script
 *
 * 02/04/2019 akaplan Change "Submit Post-Batch" parameter to Y
 *******************************************************************/


   v_return_val         NUMBER;
   V_USER_ID            NUMBER;
   V_RESP_ID            NUMBER;
   V_RESP_APP_ID        NUMBER;
   v_org_id             NUMBER;
   v_transmission_name  VARCHAR2(50);
   v_control_file       VARCHAR2(50) := 'XXAR_001_LOCKBOX_2';
   v_trans_format_id    NUMBER;
   v_lockbox_id         NUMBER;

BEGIN

   dbms_output.put_line('User name: ' ||p_user_name );
   dbms_output.put_line('Responsibility: ' ||p_resp_name );
   dbms_output.put_line('Lockbox: ' ||p_lockbox );
   dbms_output.put_line('Deposit date: ' ||p_deposit_date );
   dbms_output.put_line('Data file: ' ||p_data_file );

   SELECT USER_ID
     INTO V_USER_ID
   FROM FND_USER WHERE USER_NAME =p_user_name;

   dbms_output.put_line('User Id: ' ||V_USER_ID );

   SELECT responsibility_id, responsibility_application_id
     INTO v_resp_id, v_resp_app_id
   FROM fnd_user_resp_groups
   WHERE USER_ID = v_user_id
     AND responsibility_id = (SELECT responsibility_id FROM fnd_responsibility_vl
                              WHERE responsibility_name = p_resp_name);

   dbms_output.put_line('Responsibility Id: ' || V_RESP_ID);
   dbms_output.put_line('Responsibility Application Id: ' || V_RESP_APP_ID);

   ---- lockbox specific stuff
   v_transmission_name := p_deposit_date || '_' || p_lockbox || '_' || to_char(sysdate,'HH24MISS');

   SELECT transmission_format_id
     INTO v_trans_format_id
   FROM ar_transmission_formats t
   WHERE t.format_name = decode(substr(p_lockbox,1,3),'USB','US BANK','BOA','BANK OF AMERICA',null);

   dbms_output.put_line('Transmission Format Id :' || v_trans_format_id);

   -- the org on the pre-processing job is determined by the responsibility but can't seem to pull it here
   -- pull it from the Lockbox set-up instead
   SELECT l.lockbox_id, org_id
     INTO v_lockbox_id, v_org_id
   FROM AR_LOCKBOXES_ALL l,
       (select min(ltrim(lockbox_number,'0')) lockbox_number from xxar_payments_interface) p
   WHERE l.lockbox_number =  p.lockbox_number;

   dbms_output.put_line('Org ID :' || v_org_id);
   dbms_output.put_line('Lockbox Id :' || v_lockbox_id);

   -- set necessary policy stuff...
   fnd_global.apps_initialize(V_USER_ID, V_RESP_ID, V_RESP_APP_ID);
   mo_global.set_policy_context('S',v_org_id);
   fnd_request.set_org_id(v_org_id);

   ---------------------------------------------------------------
   v_return_val := fnd_request.submit_request
                       ('AR',       -- Application short name
                        'ARLPLB',   -- program short name
                        NULL,       -- program name
                        NULL,       -- start date
                        FALSE,      -- sub-request
                        ---- the following are ARLPLB parameters ----
                        'Y',                 --1. new transmission
                        NULL ,               --2. transmission_id
                        NULL ,               --3. original request id
                        v_transmission_name, --4. transmission name
                        'Y',                 --5. submit import
                        p_data_file,         --6. datafile
                        v_control_file,      --7. control file
                        v_trans_format_id,   --8. transmission format id
                        'Y',                 --9. submit validation
                        'Y' ,                --10. pay unrelated invoices
                        v_lockbox_id ,       --11. lockbox ID
                        NULL ,               --12. gl date    to_date(p_deposit_date,'DD-MON-YYYY')
                        'R' ,                --13. report format
                        'Y',                 --14. complete batches only
                        'Y',                 --15. submit postbatch
                        'N',                 --16. alternate name search option
                        'N',                 --17. post partial amount or reject entire receipt
                        NULL ,               --18. USSGL transaction code
                        v_org_id,            --19. Organization Id
                        NULL,                --20. apply unearn discounts
                        1,                   --21. Number of instances
                        'L',                 --22. Source Type Flag
                        null                 --23. scoring model)
                       );

   dbms_output.put_line('Concurrent Request ID :' || v_return_val);
   COMMIT;

END XXAR_SUBMIT_LOCKBOX;
