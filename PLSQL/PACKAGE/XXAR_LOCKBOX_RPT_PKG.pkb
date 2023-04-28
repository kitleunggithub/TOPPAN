--------------------------------------------------------
--  DDL for Package Body XXAR_LOCKBOX_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAR_LOCKBOX_RPT_PKG" 
AS

PROCEDURE GENERATE_REPORT    (	--errbuf out varchar2
								--,retcode out number,
                                p_user_name in varchar2,
                                 p_resp_name in varchar2,
								LOCKBOX in VARCHAR2
								,EMAIL_ADDR in VARCHAR2
								,deposit_date in VARCHAR2)
IS
   ln_request_id     		NUMBER;

   lc_boolean1       BOOLEAN;

  lc_phase            VARCHAR2(50);
  lc_status           VARCHAR2(50);
  lc_dev_phase        VARCHAR2(50);
  lc_dev_status       VARCHAR2(50);

  l_req_return_status BOOLEAN;
  lc_message varchar2(100);

    V_USER_ID            NUMBER;
    V_RESP_ID            NUMBER;
    V_RESP_APP_ID        NUMBER;
    v_org_id             NUMBER;
    v_lockbox_id         NUMBER;

BEGIN

   SELECT USER_ID
     INTO V_USER_ID
   FROM FND_USER WHERE USER_NAME =p_user_name;

    SELECT responsibility_id, responsibility_application_id
     INTO v_resp_id, v_resp_app_id
    FROM fnd_user_resp_groups
    WHERE USER_ID = v_user_id
    AND responsibility_id = (SELECT responsibility_id FROM fnd_responsibility_vl
                              WHERE responsibility_name = p_resp_name);


    SELECT l.lockbox_id, org_id
     INTO v_lockbox_id, v_org_id
   FROM AR_LOCKBOXES_ALL l,
       (select min(ltrim(lockbox_number,'0')) lockbox_number from xxar_payments_interface) p
   WHERE l.lockbox_number =  p.lockbox_number;

   -- set necessary policy stuff...
   fnd_global.apps_initialize(V_USER_ID, V_RESP_ID, V_RESP_APP_ID);
   mo_global.set_policy_context('S',v_org_id);
   fnd_request.set_org_id(v_org_id);

fnd_file.put_line (fnd_file.log,'Before Add Layout XXAR_LOCKBOX_RPT.') ;
  --Set Layout
  lc_boolean1 := fnd_request.add_layout(
                            template_appl_name   => 'XXTM',
                            template_code        => 'XXAR_LOCKBOX_RPT',
                            template_language    => 'en', --Use language from template definition
                            template_territory   => '00', --Use territory from template definition
                            output_format        => 'EXCEL' --Use output format from template definition
                                    );
fnd_file.put_line (fnd_file.log,'Before submit Request XXAR_LOCKBOX_RPT to generate Data file.') ;
 ln_request_id := fnd_request.submit_request ('XXTM',                -- application
                                  'XXAR_LOCKBOX_RPT',-- program short name
                                  '',                   -- description
                                  '',                   -- start time
                                  FALSE,                -- sub request
								  LOCKBOX,
								  EMAIL_ADDR,
								  deposit_date
                                 );

   COMMIT;

	fnd_file.put_line (fnd_file.log,'Request ID ' || ln_request_id ) ;

   IF ln_request_id = 0    THEN
			fnd_file.put_line (fnd_file.log,'Concurrent request failed to submit!');
   END IF;

	IF ln_request_id > 0 THEN

		LOOP
			--
			--To make process execution to wait for 1st program to complete
			--
			 l_req_return_status :=
				fnd_concurrent.wait_for_request (request_id      => ln_request_id
												,INTERVAL        => 2
												,max_wait        => 60 --in seconds
												 -- out arguments
												,phase           => lc_phase
												,STATUS          => lc_status
												,dev_phase       => lc_dev_phase
												,dev_status      => lc_dev_status
												,message         => lc_message
												);
		  EXIT    WHEN UPPER (lc_phase) = 'COMPLETED' OR UPPER (lc_status) IN ('CANCELLED', 'ERROR', 'TERMINATED');
		END LOOP;

	END IF ;

END GENERATE_REPORT;

END XXAR_LOCKBOX_RPT_PKG;

/
