--------------------------------------------------------
--  DDL for Package Body XXCONV_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXCONV_COMMON_PKG" as
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
    G_FILE_PATH     CONSTANT    VARCHAR2(100):=  '/home/applprd/dash/inbound';
    c_msg_length    constant    number(15)   := 1000;

    --
    -- Function to get file path.
    --
    FUNCTION get_file_path RETURN VARCHAR2 
    IS
    BEGIN
      RETURN G_FILE_PATH;
    END get_file_path;    

    --
    -- Procedure to append Message.
    --
    procedure append_message (
        p_message    in out varchar2,
        p_text       in     varchar2,
        p_separator  in     varchar2 default ' | ')
    is
    begin

        if p_message is null then
            p_message := substr(p_text, 1, c_msg_length);
        else
            p_message := substr(p_message || p_separator || p_text, 1, c_msg_length);
        end if;

    end append_message;

    --
    -- Procedure to write Line to Log file.
    --
    procedure write_log (
        p_text  in varchar2)
    is
    begin
        fnd_file.put_line (fnd_file.log, p_text);
        --dbms_output.put_line(p_text);
    end write_log;

    --
    -- Procedure to write Line to Output file.
    --
    procedure write_output (
        p_text  in varchar2)
    is
    begin
        fnd_file.put_line (fnd_file.output, p_text);
    end write_output;

    --
    -- Application Initialize
    --
    procedure apps_init ( p_user_id in number,
                        p_resp_key in varchar2,
                        p_appl_name in varchar2)
    is
    begin
        write_log('Data Conversion: Begin Application Initialize.');
        for rec_resp in (
                         select resp.application_id,
                                resp.responsibility_id
                         from   fnd_application     appl,
                                fnd_responsibility  resp
                         where  appl.application_short_name = p_appl_name
                         and    resp.application_id         = appl.application_id
                         and    resp.responsibility_key     = p_resp_key
                        )
        loop

            fnd_global.apps_initialize (
                user_id      => p_user_id,
                resp_id      => rec_resp.responsibility_id,
                resp_appl_id => rec_resp.application_id);

            MO_GLOBAL.INIT(p_appl_name);
        end loop;
        write_log('Data Conversion: End Application Initialize.');
    end;

    -- Call SQL Loader to Upload Data to Staging Table
    FUNCTION upload_data (  p_request_id in number,
                            p_program_name in varchar2,
                            p_file_path  in     varchar2,
                            p_file_name  in     varchar2) 
    RETURN NUMBER
    IS
    BEGIN
        write_log('Data Conversion: Begin Submit SQL LOADER.');
        declare
            n_request_id  number(15);
        begin

            --
            -- Submit Concurrent Request to upload data file.
            --
            n_request_id := fnd_request.submit_request (
                            application => 'XXTM',
                            program     => 'XXCONV_UPLOAD',
                            description => null,
                            start_time  => null,
                            sub_request => false,
                            argument1   => p_request_id,
                            argument2   => p_program_name,
                            argument3   => p_file_path,
                            argument4   => p_file_name);

            --
            -- Check if Concurrent Program successfully submitted.
            --
            if n_request_id = 0 then
                --append_message(v_abort_msg, 'Submission of Concurrent Request "Data Conversion: Suppliers (SQL*Loader)" was failed.');
                --append_message(v_abort_msg, fnd_message.get);
                return n_request_id;
            end if;

            --
            -- Commit to let Concurrent Manager to process the Request.
            --
            commit;

            return n_request_id;
        end;

    end;    

    -- wait concurrent request
    FUNCTION wait_request (p_request_id in number) 
    RETURN VARCHAR2
    IS
    BEGIN
        write_log('Data Conversion: Begin Wait Request.');
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
                            request_id => p_request_id,
                            interval   => 1,
                            max_wait   => 0,
                            phase      => v_phase,
                            status     => v_status,
                            dev_phase  => v_dev_phase,
                            dev_status => v_dev_status,
                            message    => v_message);

            if not (v_dev_phase = 'COMPLETE' and v_dev_status = 'NORMAL') then
                --append_message(v_abort_msg, 'Concurrent Request (ID: '||to_char(n_request_id)||') "HKBN Conversion: Suppliers (SQL*Loader)" failed.');
                return v_dev_phase||v_dev_status;
            end if;

            write_log('Data Conversion: End Wait Request.');
            return v_dev_phase;
        end;

    end;


    -- a function used to get gl ccid
    -- if there is no ccid, the function will call api to return new ccid
    FUNCTION get_ccid(p_conc_segs   IN  VARCHAR2,
                    p_valid       IN BOOLEAN
                    ) RETURN NUMBER
    IS
        l_valid_combination BOOLEAN;
        l_cr_combination    BOOLEAN;
        l_ccid       GL_CODE_COMBINATIONS_KFV.code_combination_id%TYPE;
        l_structure_num FND_ID_FLEX_STRUCTURES.ID_FLEX_NUM%TYPE;
        l_conc_segs GL_CODE_COMBINATIONS_KFV.CONCATENATED_SEGMENTS%TYPE;
        p_error_msg1                 VARCHAR2(1000);
        p_error_msg2                 VARCHAR2(1000);
    BEGIN
        l_conc_segs := p_conc_segs;

        BEGIN
            SELECT id_flex_num
            INTO l_structure_num
            FROM apps.fnd_id_flex_structures
            WHERE id_flex_code        = 'GL#'
            AND id_flex_structure_code='R12_ACCOUNTING_FLEXFIELD';
        EXCEPTION WHEN OTHERS THEN
            l_structure_num:=NULL;
        END;

        ---------------Check if CCID exits with the above Concatenated Segments---------------
        BEGIN
            SELECT code_combination_id
            INTO l_ccid
            FROM apps.gl_code_combinations_kfv
            WHERE concatenated_segments = l_conc_segs;
        EXCEPTION WHEN OTHERS THEN
            l_ccid:=-1;
        END;

        IF l_ccid <> -1 THEN
            ------------------------The CCID is Available----------------------
            null;
            --DBMS_OUTPUT.PUT_LINE('COMBINATION_ID= ' ||l_ccid);
        ELSE
            --DBMS_OUTPUT.PUT_LINE('This is a New Combination. Validation Starts....');
            ------------Validate the New Combination--------------------------
            l_valid_combination := APPS.FND_FLEX_KEYVAL.VALIDATE_SEGS
                                 (
                                  operation => 'CHECK_COMBINATION',
                                  appl_short_name => 'SQLGL',
                                  key_flex_code => 'GL#',
                                  structure_number => L_STRUCTURE_NUM,
                                  concat_segments => L_CONC_SEGS
                                  );

            p_error_msg1 := FND_FLEX_KEYVAL.ERROR_MESSAGE;

            IF l_valid_combination then
                IF not p_valid then
                  --DBMS_OUTPUT.PUT_LINE('Validation Successful! Creating the Combination...');
                  -------------------Create the New CCID--------------------------
                  L_CR_COMBINATION := APPS.FND_FLEX_KEYVAL.VALIDATE_SEGS
                                      (
                                      operation => 'CREATE_COMBINATION',
                                      appl_short_name => 'SQLGL',
                                      key_flex_code => 'GL#',
                                      structure_number => L_STRUCTURE_NUM,
                                      concat_segments => L_CONC_SEGS );
                      p_error_msg2 := FND_FLEX_KEYVAL.ERROR_MESSAGE;

                  IF l_cr_combination THEN
                    -------------------Fetch the New CCID--------------------------
                    SELECT code_combination_id
                      INTO l_ccid
                      FROM apps.gl_code_combinations_kfv
                    WHERE concatenated_segments = l_conc_segs;
                    --DBMS_OUTPUT.PUT_LINE('NEW COMBINATION_ID = ' || l_ccid);
                    write_log('NEW COMBINATION_ID = ' || l_ccid);
                  ELSE
                    -------------Error in creating a combination-----------------
                    --DBMS_OUTPUT.PUT_LINE('Error in creating the combination: '||p_error_msg2);
                    write_log('Error in creating the combination: '||p_error_msg2);
                    l_ccid := 0;
                  END IF;
                ELSE
                    l_ccid := 1;
                END IF;    
            ELSE
                --------The segments in the account string are not defined in gl value set----------
                --DBMS_OUTPUT.PUT_LINE('Error in validating the combination: '||p_error_msg1);
                write_log('Error in creating the combination: '||p_error_msg1);
                l_ccid := 0;
            END IF;
        END IF;

        --DBMS_OUTPUT.PUT_LINE('l_ccid '||nvl(l_ccid,0));
        return nvl(l_ccid,0);
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE||' '||SQLERRM);
        write_log('get_ccid error');
        write_log(SQLCODE||' '||SQLERRM);
        write_log(p_error_msg1);
        write_log(p_error_msg2);    
    END get_ccid;

end xxconv_common_pkg;

/
