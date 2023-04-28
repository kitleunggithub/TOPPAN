--------------------------------------------------------
--  DDL for Package Body XXBS_CUST_TRX_LINES_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXBS_CUST_TRX_LINES_WEBADI_PKG" 
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

    G_PROGRAM_NAME                  CONSTANT VARCHAR2(30) := 'XXBS_CUST_TRX_LINES_WEBADI_PKG'; 

  FUNCTION get_orig_customer_trx_id (p_customer_trx_id IN NUMBER) RETURN NUMBER
  IS
    l_customer_trx_id number;
    l_revised_customer_trx_id number := -1;
  BEGIN  
    l_customer_trx_id := p_customer_trx_id;

    WHILE l_revised_customer_trx_id is not null 
    LOOP  
        select xct.revised_customer_trx_id 
        into l_revised_customer_trx_id
        from xxbs_customer_trx xct
        where xct.customer_trx_id = l_customer_trx_id;

        if l_revised_customer_trx_id is not null then        
            l_customer_trx_id := l_revised_customer_trx_id;
        end if;    
    END LOOP;

    --DBMS_OUTPUT.PUT_LINE(l_customer_trx_id); 
    RETURN l_customer_trx_id;
  END get_orig_customer_trx_id;

  FUNCTION validate_data(p_run_id IN NUMBER) RETURN BOOLEAN
  IS
    b_all_valid     BOOLEAN := TRUE;
    b_valid         BOOLEAN := TRUE;
    n_chk_flag      NUMBER;
    v_error_message VARCHAR2(4000);

    CURSOR c_rec
    IS
      SELECT rowid, s.* 
        FROM XXBS_CUST_TRX_LINES_WEBADI_STG s
       WHERE run_id = p_run_id
         AND status = 'N';

    PROCEDURE set_error(l_rec        IN OUT c_rec%rowtype, 
                        p_error_code IN     VARCHAR2)
    IS
    BEGIN
      b_valid := FALSE;
      l_rec.error_code := p_error_code;
    END;

  BEGIN
    b_all_valid := TRUE;
    b_valid := TRUE;

    FOR l IN c_rec
    LOOP
        v_error_message :=null;
        n_chk_flag := null;
        b_valid := TRUE;

        --Check OU
        BEGIN
            n_chk_flag := null;

            SELECT 1 
            INTO   n_chk_flag
            FROM   hr_operating_units
            WHERE  organization_id = l.org_id
            AND    name = l.operating_unit;
        EXCEPTION
        WHEN OTHERS THEN
            b_valid := FALSE;
            v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Invalid Operating Unit ('||l.operating_unit||')';
        END;

        IF b_valid THEN

            --trx number
            BEGIN
                n_chk_flag := null;

                select CUSTOMER_TRX_ID,ORIGINAL_PROJECT_ID,PRIMARY_PROJECT_ORG_ID,PRIMARY_PRODUCT_TYPE_ID
                into l.CUSTOMER_TRX_ID,l.PROJECT_ID,l.PROJECT_ORG_ID,l.PRODUCT_TYPE_ID
                from xxbs_customer_trx xct
                where xct.ar_trx_number = l.trx_number
                and xct.org_id = l.org_id
                and xct.current_status IN ('Created','Created RI','Out For Review')
                and xct.invoice_class IN ('N','P');
            EXCEPTION
            WHEN OTHERS THEN
                b_valid := FALSE;
                v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Trx Number ('||l.trx_number||') does not found [Status must be Created,Created RI,Out For Review].';
            END;

            --orig trx number
            --project id, primary product type will be retrieve from child transaction
            IF l.orig_trx_number is not null then
                BEGIN
                    n_chk_flag := null;

                    select CUSTOMER_TRX_ID,ORIGINAL_PROJECT_ID,PRIMARY_PROJECT_ORG_ID,PRIMARY_PRODUCT_TYPE_ID
                    into l.ORIG_CUSTOMER_TRX_ID,l.PROJECT_ID,l.PROJECT_ORG_ID,l.PRODUCT_TYPE_ID
                    from xxbs_customer_trx xct
                    where xct.ar_trx_number = l.orig_trx_number
                    and xct.org_id = l.org_id;
                EXCEPTION
                WHEN OTHERS THEN
                    b_valid := FALSE;
                    v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Original Trx Number ('||l.orig_trx_number||') does not found.';
                END;
            END IF;


            BEGIN
                -- check Integer
                if not (remainder(l.line_number,1) = 0) then
                    b_valid := FALSE;
                    v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Line Number must be Integer.';
                end if;

                -- check greater then zero
                if l.line_number <= 0 then
                    b_valid := FALSE;
                    v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Line Number must be greater than 0.';
                end if;

                -- check line number exists
                n_chk_flag := null;

                select distinct 1
                into n_chk_flag
                from xxbs_customer_trx xct
                    ,xxbs_customer_trx_lines xctl
                where xct.customer_trx_id = xctl.customer_trx_id
                and xct.org_id = l.org_id
                and xct.ar_trx_number = l.trx_number
                and nvl(xctl.orig_customer_trx_id,-1) = nvl((select customer_trx_id from xxbs_customer_trx org_xct where org_xct.ar_trx_number = l.orig_trx_number),-1)
                and xctl.line_number = l.line_number;

                if n_chk_flag = 1 then
                    b_valid := FALSE;
                    v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Line Number of Trx Number('||case when l.orig_trx_number is null then l.trx_number else l.orig_trx_number end||') already exists.';                
                end if;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                null;
            END;                

            -- check line type
            BEGIN
                n_chk_flag := null;

                SELECT 1
                INTO n_chk_flag
                FROM fnd_flex_value_sets ffvs,
                    fnd_flex_values ffv,
                    fnd_flex_values_tl ffvt
                WHERE ffvs.flex_value_set_id = ffv.flex_value_set_id
                AND ffv.flex_value_id = ffvt.flex_value_id
                AND ffvt.language = 'US'
                AND flex_value_set_name = 'XXBS_INVOICE_LINE_TYPE'
                AND ffv.enabled_flag = 'Y'
                AND ffv.flex_value = l.line_type;
            EXCEPTION
            WHEN OTHERS THEN
                b_valid := FALSE;
                v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Invalid Line Type ('||l.line_type||').';
            END;

/*
            BEGIN
                select lookup_code 
                into l.FOREIGN_SYSTEM            
                from FND_LOOKUP_VALUES
                WHERE lookup_type = 'PM_PRODUCT_CODE'
                AND lookup_code like '%HONG KONG'
                AND enabled_flag = 'Y' 
                AND NVL(end_date_active,SYSDATE) >= SYSDATE
                AND lookup_code = l.organization_name;
            EXCEPTION
            WHEN OTHERS THEN
                b_valid := FALSE;
                v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'PM_PRODUCT_CODE ('||l.organization_name||') does not found in Setup.';
            END;
*/                         
        END IF;

       if not (b_valid) then
            b_all_valid := false;

            SELECT 'ERR' || XXTM_WEBADI_ERR_ID_S.nextval
            INTO l.error_code
            FROM dual;

            INSERT INTO XXTM_WEBADI_ERR VALUES (p_run_id,l.error_code, 'Validation Fail: '||v_error_message, G_PROGRAM_NAME,fnd_global.user_id,sysdate);
       end if;

        UPDATE XXBS_CUST_TRX_LINES_WEBADI_STG
        SET status = DECODE(l.error_code, NULL, 'V', 'E'),
         CUSTOMER_TRX_ID = l.CUSTOMER_TRX_ID,
         ORIG_CUSTOMER_TRX_ID = l.ORIG_CUSTOMER_TRX_ID,
         PROJECT_ID = l.PROJECT_ID,
         PROJECT_ORG_ID = l.PROJECT_ORG_ID,
         PRODUCT_TYPE_ID = l.PRODUCT_TYPE_ID,
         AMOUNT = l.SELL_QTY * l.UNIT_PRICE,
         error_code = l.error_code
        WHERE rowid = l.rowid;

    END LOOP;

    COMMIT;

    RETURN b_all_valid;
  END validate_data;

  PROCEDURE process_data(p_run_id IN NUMBER)
  IS

    ln_api_version_number NUMBER := 1.0;
    ln_msg_count          NUMBER;
    ln_msg_index_out      NUMBER;
    lc_commit            VARCHAR2 (1) := 'F';
    lc_return_status      VARCHAR2 (1) := NULL;
    lc_init_msg_list      VARCHAR2 (1) := 'T';
    lc_msg_data          VARCHAR2 (4000);
    lc_data              VARCHAR2 (4000);

    lc_workflow_started  VARCHAR2 (1) := 'N';
    lc_pm_product_code    VARCHAR2 (50);

    l_tmp_project_id        NUMBER;

    l_project_seq           NUMBER;
    l_count NUMBER;

    l_debug     VARCHAR2 (100);

    CURSOR c_rec
    IS
    SELECT rowid, s.* 
    FROM XXBS_CUST_TRX_LINES_WEBADI_STG s
    WHERE run_id = p_run_id
    AND status = 'V';

    CURSOR c_trx_rec
    IS
    SELECT distinct s.customer_trx_id,error_code
    FROM XXBS_CUST_TRX_LINES_WEBADI_STG s
    WHERE run_id = p_run_id
    AND status = 'I';

  BEGIN
    -- insert line records
    FOR l IN c_rec
    LOOP
        BEGIN
            INSERT INTO XXBS_CUSTOMER_TRX_LINES 
            (CUSTOMER_TRX_LINE_ID,CUSTOMER_TRX_ID,ORIG_CUSTOMER_TRX_ID,
            ORIG_TRX_LINE_ID,PROJECT_ID,LINE_NUMBER,
            ORG_ID,PROJECT_ORG_ID,QUANTITY_SELL,
            UNIT_SELL,SELL_AMOUNT,PRODUCT_TYPE_ID,
            LONG_DESCRIPTION,CREATED_BY,CREATION_DATE,
            LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,
            AR_TRX_LINE_NUMBER,LINE_TYPE,STATUS,
            LEVEL_1,LEVEL_2,LEVEL_3) 
            values (XXBS_CUSTOMER_TRX_LINE_S.nextval,l.CUSTOMER_TRX_ID,l.ORIG_CUSTOMER_TRX_ID,
            null,l.PROJECT_ID,l.LINE_NUMBER,
            l.ORG_ID,l.PROJECT_ORG_ID,l.SELL_QTY,
            l.UNIT_PRICE,l.AMOUNT,l.PRODUCT_TYPE_ID,
            l.LONG_DESCRIPTION,FND_GLOBAL.user_id,SYSDATE,
            FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.login_id,
            null,l.LINE_TYPE,null,
            l.LEVEL_1,l.LEVEL_2,l.LEVEL_3); 

            UPDATE XXBS_CUST_TRX_LINES_WEBADI_STG
            SET status = DECODE(l.error_code, NULL, 'I', 'E')
            WHERE rowid = l.rowid;
      EXCEPTION WHEN OTHERS THEN
        ROLLBACK;

        DECLARE
            v_error_message VARCHAR2(4000);
        BEGIN
            v_error_message := fnd_message.get;

            IF v_error_message IS NULL THEN
                v_error_message := substr(sqlerrm,1,4000);
            END IF;

            SELECT 'ERR' || XXTM_WEBADI_ERR_ID_S.nextval
            INTO l.error_code
            FROM dual;

            INSERT INTO XXTM_WEBADI_ERR VALUES (p_run_id,l.error_code, v_error_message, G_PROGRAM_NAME,fnd_global.user_id,sysdate);

            UPDATE XXBS_CUST_TRX_LINES_WEBADI_STG
            SET status = 'E',
            error_code = l.error_code 
            WHERE rowid = l.rowid;

            COMMIT;

            EXIT;
        EXCEPTION WHEN OTHERS THEN
           NULL;
        END;

        RETURN;
      END;
    END LOOP;

    --update customer billing header total line amount
    FOR l IN c_trx_rec
    LOOP
        BEGIN
            UPDATE XXBS_CUSTOMER_TRX
            SET TOTAL_LINE_AMOUNT = (select sum(sell_amount) 
                                    from XXBS_CUSTOMER_TRX_LINES
                                    where customer_trx_id = l.customer_trx_id)
            WHERE customer_trx_id = l.customer_trx_id; 

            UPDATE XXBS_CUST_TRX_LINES_WEBADI_STG
            SET status = DECODE(l.error_code, NULL, 'C', 'E')
            WHERE customer_trx_id = l.customer_trx_id;
      EXCEPTION WHEN OTHERS THEN
        ROLLBACK;

        DECLARE
            v_error_message VARCHAR2(4000);
        BEGIN
            v_error_message := fnd_message.get;

            IF v_error_message IS NULL THEN
                v_error_message := substr(sqlerrm,1,4000);
            END IF;

            SELECT 'ERR' || XXTM_WEBADI_ERR_ID_S.nextval
            INTO l.error_code
            FROM dual;

            INSERT INTO XXTM_WEBADI_ERR VALUES (p_run_id,l.error_code, v_error_message, G_PROGRAM_NAME,fnd_global.user_id,sysdate);

            UPDATE XXBS_CUST_TRX_LINES_WEBADI_STG
            SET status = 'E',
            error_code = l.error_code 
            WHERE customer_trx_id = l.customer_trx_id;

            COMMIT;

            EXIT;
        EXCEPTION WHEN OTHERS THEN
           NULL;
        END;

        RETURN;
      END;
    END LOOP;


    COMMIT;

  END process_data;


  PROCEDURE import_data(p_run_id            IN NUMBER/*,
                        x_msg               OUT NOCOPY VARCHAR,
                        x_request_id        OUT NOCOPY NUMBER*/ )
  IS
    l_error         VARCHAR2 (500);
    v_exception EXCEPTION;
  BEGIN
    IF validate_data(p_run_id) THEN
      process_data(p_run_id);
    END IF;
  END import_data;

END XXBS_CUST_TRX_LINES_WEBADI_PKG;


/
