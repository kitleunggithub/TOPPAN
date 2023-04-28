--------------------------------------------------------
--  DDL for Package Body XXTM_TABLEAU_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXTM_TABLEAU_BATCH_PKG" as
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
        p_batch_id      in  number)
    IS
        n_request_id    NUMBER;
        v_resp_id 	    NUMBER;
        v_appl_id    	NUMBER;
        v_usr_id        NUMBER;
        d_cutoff        DATE;
    BEGIN

        select trunc(date_value) 
        into d_cutoff 
        from xxtm_tableau_params 
        where params_name = 'CUTOFFDATE';

        fnd_file.put_line (fnd_file.log, 'CUTOFF Date = '||to_char(d_cutoff,'DD-MON-YYYY'));     

        for rec_job in  (
                            select * from xxtm_tableau_exec_ctl
                            where batch_id = p_batch_id
                            order by seq
                        )
        loop

            if nvl(rec_job.exec_cycle,'D') = 'D' or 
            (nvl(rec_job.exec_cycle,'D') = 'M' and to_number(to_char(d_cutoff,'DD')) = rec_job.exec_day) then
                n_request_id := fnd_request.submit_request (
                                application => rec_job.application,
                                program     => rec_job.program,
                                description => rec_job.description,
                                start_time  => null,
                                sub_request => false,
                                argument1   => nvl(rec_job.p1,CHR(0)),
                                argument2   => nvl(rec_job.p2,CHR(0)),
                                argument3   => nvl(rec_job.p3,CHR(0)),
                                argument4   => nvl(rec_job.p4,CHR(0)),
                                argument5   => nvl(rec_job.p5,CHR(0)),
                                argument6   => nvl(rec_job.p6,CHR(0)),
                                argument7   => nvl(rec_job.p7,CHR(0)),
                                argument8   => nvl(rec_job.p8,CHR(0)),
                                argument9   => nvl(rec_job.p9,CHR(0)),
                                argument10  => nvl(rec_job.p10,CHR(0))
                                );

                COMMIT;

                fnd_file.put_line (fnd_file.output, 'Concurrent Program '||rec_job.program|| ' Submitted');

                -- wait concurrent job
                if nvl(rec_job.wait,'Y') = 'Y' then
                    declare

                        b_success     boolean;
                        v_phase       varchar2(30);
                        v_status      varchar2(30);
                        v_dev_phase   varchar2(30);
                        v_dev_status  varchar2(30);
                        v_message     varchar2(240);

                    begin
                        --
                        -- Waits for request completion.
                        --
                        b_success := fnd_concurrent.wait_for_request (
                                        request_id => n_request_id,
                                        interval   => 1,
                                        max_wait   => 0,
                                        phase      => v_phase,
                                        status     => v_status,
                                        dev_phase  => v_dev_phase,
                                        dev_status => v_dev_status,
                                        message    => v_message);

                        dbms_output.put_line('Concurrent Program Wait Completed.'||n_request_id);                            
						
                        if not (v_dev_phase = 'COMPLETE' and v_dev_status = 'NORMAL') then
                            retcode := '2';  -- 0 - Normal 1 - Warning 2 - Error
                            errbuf := 'Batch Running Error, Please check the child job';
                        end if;						
						
                        fnd_file.put_line (fnd_file.output, 'Concurrent Program '||rec_job.program|| ' Completed (request_id = '||n_request_id||+' , status = '||v_dev_phase||','||v_dev_status||')');                        
                    exception when others then
                        fnd_file.put_line (fnd_file.output, 'Concurrent Program '||rec_job.program|| ' No Wait (request_id = '||n_request_id||')');
                    end;
                else
                    fnd_file.put_line (fnd_file.output, 'Call API fnd_concurrent.wait_for_request Error');
                end if; -- wait job        
            end if;    
        end loop;

        update xxtm_tableau_params
        set date_value = trunc(sysdate)
        where params_name = 'CUTOFFDATE';


    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        retcode := '2';
        errbuf  := 'ERROR: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || DBMS_UTILITY.FORMAT_ERROR_STACK;
        fnd_file.put_line (fnd_file.log, errbuf);  
    END submit_job;    

end XXTM_TABLEAU_BATCH_PKG;


/
