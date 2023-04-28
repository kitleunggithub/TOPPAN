--------------------------------------------------------
--  DDL for Package Body XXPA_PROJECT_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXPA_PROJECT_WEBADI_PKG" 
IS
    G_PROGRAM_NAME                  CONSTANT VARCHAR2(30) := 'XXPA_PROJECT_WEBADI_PKG';
    G_PROJECT_TEMPLATE_NAME         CONSTANT VARCHAR2(30) := 'T_EXTERNAL_BILLABLE';
    G_CUSTOMER_NAME                 CONSTANT VARCHAR2(30) := 'Default Customer';
    G_INVOICE_STYLE_NAME            CONSTANT VARCHAR2(50) := 'TOPPAN DET ENG INT HK';
    G_BILLER_NAME                   CONSTANT VARCHAR2(50) := 'SYSADMIN';
    G_TCC_FS                        CONSTANT VARCHAR2(50) := 'TCC HONG KONG';

  FUNCTION validate_data(p_run_id IN NUMBER) RETURN BOOLEAN
  IS
    b_all_valid     BOOLEAN := TRUE;
    b_valid         BOOLEAN := TRUE;
    n_chk_flag      NUMBER;
    v_error_message VARCHAR2(4000);

    CURSOR c_rec
    IS
      SELECT rowid, s.* 
        FROM XXPA_PROJECT_WEBADI_STG s
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

    update XXPA_PROJECT_WEBADI_STG
    set project_name = replace(replace(project_name,CHR(10),' '),CHR(13),'')
        ,project_num = replace(replace(project_num,CHR(10),''),CHR(13),'')
    WHERE run_id = p_run_id
    AND status = 'N';

    FOR l IN c_rec
    LOOP
        v_error_message :=null;
        n_chk_flag := null;
        b_valid := TRUE;
        --Check OU
        BEGIN
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
            --Project Number must be unique across all operating units
            BEGIN
                n_chk_flag := 0;
                SELECT 1 
                INTO   n_chk_flag
                FROM   pa_projects_all
                --WHERE  segment1 = l.foreign_system||'-'||l.project_num;
                WHERE  segment1 = l.project_num;

                if n_chk_flag = 1 then
                    b_valid := FALSE;
                    --v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Project Number ('||l.project_num||') with Foreign System ('||l.foreign_system||') must be unique across all operating units';
                    v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Project Number ('||l.project_num||') must be unique across all operating units';
                end if;
            EXCEPTION
            WHEN OTHERS THEN
                null;
            END;

            --check unique project number + project name
            --l.project_name||' ('||l.project_num||')';
            /*
            BEGIN
                n_chk_flag := 0;
                SELECT 1 
                INTO   n_chk_flag
                FROM   pa_projects_all
                WHERE  long_name = l.project_name||' ('||l.foreign_system||'-'||l.project_num||')';

                if n_chk_flag = 1 then
                    b_valid := FALSE;
                    v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Project Long Name ('||l.project_name||' ('||l.foreign_system||'-'||l.project_num||')'||') must be unique across all operating units';
                end if;
            EXCEPTION
            WHEN OTHERS THEN
                null;
            END;
            */

            IF lengthb(l.PROJECT_NAME) > 250 THEN
                b_valid := FALSE;
                v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Project Name can not more than 250 bytes.';                        
            END IF;     

            BEGIN
                SELECT hrorg.organization_id
                INTO l.CARRYING_OUT_ORGANIZATION_ID
                from hr_organization_units hrorg, pa_all_organizations paorg 
                WHERE paorg.organization_id = hrorg.organization_id 
                and paorg.pa_org_use_type = 'EXPENDITURES' 
                and (paorg.inactive_date is NULL or paorg.inactive_date > sysdate)
                and (hrorg.date_to is NULL or hrorg.date_to > sysdate)      
                and paorg.org_id = l.org_id
                and hrorg.name = l.organization_name;
            /*
                SELECT paorg.organization_id
                INTO l.CARRYING_OUT_ORGANIZATION_ID
                FROM xxpa_organizations_v paorg
                WHERE paorg.org_id = l.org_id
                AND paorg.name = l.organization_name;            
            */    
            EXCEPTION
            WHEN OTHERS THEN
                b_valid := FALSE;
                v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Invalid Project Organization ('||l.organization_name||')';
            END;

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

            DECLARE
                n_exists number := 0;
            BEGIN
                n_chk_flag := 0;

                select 1
                into n_chk_flag
                from ar_memo_lines_all_tl i, ar_memo_lines_all_b j
                WHERE i.memo_line_id = j.memo_line_id 
                AND i.org_id = j.org_id
                AND j.START_DATE <= SYSDATE
                AND (j.end_date > SYSDATE or j.end_date is null)
                AND i.org_id = l.org_id
                AND i.memo_line_id = l.product_type;

                --if the first three digits of project number = flex value "XXPA_PROJECT_NO_VALIDATE", then Product Type must be equal to value description
                SELECT count(*)
                into n_exists
                FROM fnd_flex_value_sets ffvs ,
                fnd_flex_values ffv ,
                fnd_flex_values_tl ffvt
                WHERE ffvs.flex_value_set_id = ffv.flex_value_set_id
                AND ffv.flex_value_id = ffvt.flex_value_id
                AND ffvt.language = USERENV('LANG')
                AND ffv.enabled_flag = 'Y'
                AND flex_value_set_name like 'XXPA_PROJECT_NO_VALIDATE'
                AND ffv.flex_value = substr(l.project_num,1,3);                

                IF n_exists >= 1 THEN                
                    SELECT 1
                    INTO n_chk_flag
                    FROM AR_MEMO_LINES_ALL_VL amlav,
                    (
                    SELECT 
                    ffv.flex_value,
                    ffvt.description
                    FROM fnd_flex_value_sets ffvs ,
                    fnd_flex_values ffv ,
                    fnd_flex_values_tl ffvt
                    WHERE ffvs.flex_value_set_id = ffv.flex_value_set_id
                    AND ffv.flex_value_id = ffvt.flex_value_id
                    AND ffvt.language = USERENV('LANG')
                    AND ffv.enabled_flag = 'Y'
                    AND flex_value_set_name like 'XXPA_PROJECT_NO_VALIDATE'
                    ) flex
                    WHERE amlav.ATTRIBUTE1 = 'Y' 
                    AND flex.description = amlav.name
                    AND flex.flex_value = substr(l.project_num,1,3)
                    AND amlav.org_id = l.org_id
                    AND amlav.memo_line_id = l.product_type;
                END IF;
            EXCEPTION
            WHEN OTHERS THEN
                b_valid := FALSE;
                v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Invalid Product Type.';
            END;            

            --029 is TCC Project, the transaction number will be generated
            --other than 029, user must input transaction number
            --IF l.FOREIGN_SYSTEM <> '029' and l.TRANSACTION_NUM is null THEN
            IF l.organization_name not like '%'||G_TCC_FS and l.TRANSACTION_NUM is null THEN
                b_valid := FALSE;
                v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Transaction Number is required for Non TCC Foreign System.';            
            END IF;

            IF l.organization_name not like '%'||G_TCC_FS and length(l.TRANSACTION_NUM) = 8 and substr(l.TRANSACTION_NUM,1,1) = '3' THEN
                b_valid := FALSE;
                v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Transaction Number can not start with 3 and The lenght can not equal to 8 for Non TCC Foreign System.';                        
            END IF;          

            BEGIN
                n_chk_flag := 0;

                select 1 
                into n_chk_flag            
                from xxbs_customer_trx
                WHERE ar_trx_number = l.transaction_num;

                if n_chk_flag = 1 then                
                    b_valid := FALSE;
                    v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Transaction Number ('||l.transaction_num||') already exists.';
                end if;
            EXCEPTION
            WHEN OTHERS THEN
                null;
            END;            

            BEGIN
                n_chk_flag := 0;

                select 1 
                into n_chk_flag            
                from ra_customer_trx_all
                WHERE trx_number = l.transaction_num
                AND org_id = l.org_id;

                if n_chk_flag = 1 then                
                    b_valid := FALSE;
                    v_error_message := case when v_error_message is not null then v_error_message||'| ' end || 'Transaction Number ('||l.transaction_num||') already exists in AR Invoice.';
                end if;
            EXCEPTION
            WHEN OTHERS THEN
                null;
            END;

        END IF;

       if not (b_valid) then
            b_all_valid := false;

            SELECT 'ERR' || XXTM_WEBADI_ERR_ID_S.nextval
            INTO l.error_code
            FROM dual;

            INSERT INTO XXTM_WEBADI_ERR VALUES (p_run_id,l.error_code, 'Validation Fail: '||v_error_message, G_PROGRAM_NAME,fnd_global.user_id,sysdate);
       end if;

        UPDATE XXPA_PROJECT_WEBADI_STG
        SET status = DECODE(l.error_code, NULL, 'V', 'E'),
         CARRYING_OUT_ORGANIZATION_ID = nvl(l.CARRYING_OUT_ORGANIZATION_ID,-1),
         FOREIGN_SYSTEM = nvl(l.FOREIGN_SYSTEM,-1),
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

    --Record Type Variables
    lr_project_in_rec              PA_PROJECT_PUB.PROJECT_IN_REC_TYPE;
    lr_project_out_rec            PA_PROJECT_PUB.PROJECT_OUT_REC_TYPE;
    lr_tasks_in_rec                PA_PROJECT_PUB.TASK_IN_REC_TYPE;
    lr_tasks_out_rec              PA_PROJECT_PUB.TASK_OUT_REC_TYPE;
    lr_project_customers_in_rec    PA_PROJECT_CUSTOMERS%ROWTYPE;

    --Table Type Variables
    lt_key_members_tbl            PA_PROJECT_PUB.PROJECT_ROLE_TBL_TYPE;
    lt_class_categories_tbl        PA_PROJECT_PUB.CLASS_CATEGORY_TBL_TYPE;
    l_task_in_tbl_type          pa_project_pub.task_in_tbl_type;
    l_task_out_tbl_type          pa_project_pub.task_out_tbl_type;

    CURSOR project_cur (P_TMP_PROJECT_ID NUMBER)
    IS
    SELECT *
    FROM pa_projects_all ppa
    WHERE ppa.project_id = P_TMP_PROJECT_ID;

    CURSOR task_cur (P_TMP_PROJECT_ID NUMBER)
    IS
    SELECT
    pt.*,
    (SELECT task_number FROM pa_tasks WHERE task_id = pt.parent_task_id) parent_task_number
    FROM pa_tasks pt
    WHERE pt.project_id = P_TMP_PROJECT_ID -->project id from project template
    ORDER BY pa_task_utils.sort_order_tree_walk (pt.parent_task_id,pt.task_number);

    CURSOR c_rec
    IS
    SELECT rowid, s.* 
    FROM XXPA_PROJECT_WEBADI_STG s
    WHERE run_id = p_run_id
    AND status = 'V';

  BEGIN
   --DBMS_OUTPUT.PUT_LINE('resp:'||fnd_global.resp_id);
   --DBMS_OUTPUT.PUT_LINE('resp:'||fnd_global.user_id);
   -- SET GLOBAL INFO
   PA_INTERFACE_UTILS_PUB.SET_GLOBAL_INFO
    (
    p_api_version_number   => 1.0,
    p_responsibility_id    => fnd_global.resp_id,
    p_user_id              => fnd_global.user_id,
    p_msg_count            => ln_msg_count,
    p_msg_data             => lc_msg_data,
    p_return_status        => lc_return_status
    );
    --DBMS_OUTPUT.PUT_LINE(lc_return_status);
    --DBMS_OUTPUT.PUT_LINE(lc_msg_data);

    FOR l IN c_rec
    LOOP
      BEGIN

        /*************************************************************************
         * Call Standard PA_PROJECT_PUB.CREATE_PROJECT
         *************************************************************************/
        --var init
        lr_project_in_rec := null;
        lr_project_out_rec := null;
        lr_tasks_in_rec := null;
        lr_tasks_out_rec := null;
        lr_project_customers_in_rec := null;

        l_count := null;
        lc_msg_data := null;
        lc_data := null;

        ln_msg_count := null;
        ln_msg_index_out := null;
        lc_return_status := NULL;

        --> lookup project template by operating unit
        select project_id
        into l_tmp_project_id
        from pa_projects_all
        where template_flag='Y'
        and enabled_flag='Y'
        and org_id = l.org_id
        and name like G_PROJECT_TEMPLATE_NAME||'%';

        --> Assigning Project Values
        FOR project_rec IN project_cur (l_tmp_project_id)
        LOOP
            lc_pm_product_code := l.foreign_system;

            lr_project_in_rec.created_from_project_id := l_tmp_project_id;
            l_debug := '1';
            lr_project_in_rec.pm_project_reference := SUBSTR (l.project_num, 1, 25);
            l_debug := '2';
            --lr_project_in_rec.pa_project_number := l.foreign_system||'-'||l.project_num;
            lr_project_in_rec.pa_project_number := l.project_num;
            l_debug := '3';
            lr_project_in_rec.project_name := TRIM(SUBSTRB(l.project_name, 1, 20))||'-'||XXPA_PROJECT_SEQ_S.nextval;
            l_debug := '4';
            lr_project_in_rec.long_name := ' ('||lr_project_in_rec.pa_project_number||')';
            lr_project_in_rec.long_name := trim(SUBSTRB(l.project_name,1,240 - LENGTHB(lr_project_in_rec.long_name)))||' ('||lr_project_in_rec.pa_project_number||')';
            l_debug := '5';
            lr_project_in_rec.description := l.project_name;
            l_debug := '6';
            lr_project_in_rec.carrying_out_organization_id := l.CARRYING_OUT_ORGANIZATION_ID;
            l_debug := '7';
            lr_project_in_rec.start_date := l.project_start_date;
            l_debug := '8';
            --handle a bug on check security => PA_PAXPREPR_INV_MTH_TOP_TASK
            lr_project_in_rec.enable_top_task_inv_mth_flag := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

            lr_project_in_rec.attribute1 := l.product_type;
            l_debug := '9';
            if l.transaction_num is null or trim(l.transaction_num) = '' then
                lr_project_in_rec.attribute6 := XXBS_AR_TRX_NUMBER_S.nextval;    
            else
                lr_project_in_rec.attribute6 := l.transaction_num;
            end if;    
            l_debug := '10';
            lr_project_in_rec.process_mode := 'ONLINE';
            lr_project_in_rec.project_status_code     := project_rec.project_status_code;    
            lr_project_in_rec.completion_date         := project_rec.completion_date;

        END LOOP;

        --> Assigning Customer Values
        --    lt_key_members_tbl.DELETE;
        --    lt_key_members_tbl (1).person_id := l_person_id;
        --    lt_key_members_tbl (1).project_role_type := l_project_role_type;
        --    lt_key_members_tbl (1).start_date := l_start_date; --ld_eff_from_date;
        --    lt_key_members_tbl (1).end_date := l_completion_date; --ld_eff_to_date;

        --> Assinging the Categories values
        --    lt_class_categories_tbl.DELETE;
        --    lt_class_categories_tbl (1).class_category := 'PROJECT COST CENTER';
        --    lt_class_categories_tbl (1).class_code := '2001';

        --> Getting Tasks from Project Template and Assinging Task values
        l_count := 1;
        l_task_in_tbl_type.DELETE;
        l_task_out_tbl_type.DELETE;

        FOR task_rec IN task_cur (l_tmp_project_id)
        LOOP
            l_task_in_tbl_type (l_count).pa_task_id := NULL;

            l_task_in_tbl_type (l_count).task_start_date              := l.project_start_date;
            l_task_in_tbl_type (l_count).carrying_out_organization_id := l.carrying_out_organization_id;       

            l_task_in_tbl_type (l_count).pm_task_reference            := task_rec.task_number;
            l_task_in_tbl_type (l_count).task_name                    := task_rec.task_name;
            l_task_in_tbl_type (l_count).pa_task_number               := task_rec.task_number;
            l_task_in_tbl_type (l_count).task_description             := task_rec.description;
            l_task_in_tbl_type (l_count).service_type_code            := task_rec.service_type_code;
            l_task_in_tbl_type (l_count).billable_flag                := task_rec.billable_flag;
            l_task_in_tbl_type (l_count).chargeable_flag              := task_rec.chargeable_flag;
            l_task_in_tbl_type (l_count).ready_to_bill_flag           := task_rec.ready_to_bill_flag;
            l_task_in_tbl_type (l_count).ready_to_distribute_flag     := task_rec.ready_to_distribute_flag;
            l_task_in_tbl_type (l_count).limit_to_txn_controls_flag   := task_rec.limit_to_txn_controls_flag;
            l_task_in_tbl_type (l_count).labor_bill_rate_org_id       := task_rec.labor_bill_rate_org_id;
            l_task_in_tbl_type (l_count).labor_std_bill_rate_schdl    := task_rec.labor_std_bill_rate_schdl;
            l_task_in_tbl_type (l_count).labor_schedule_fixed_date    := task_rec.labor_schedule_fixed_date;
            l_task_in_tbl_type (l_count).labor_schedule_discount      := task_rec.labor_schedule_discount;
            l_task_in_tbl_type (l_count).non_labor_bill_rate_org_id   := task_rec.non_labor_bill_rate_org_id;
            l_task_in_tbl_type (l_count).non_labor_std_bill_rate_schdl:= task_rec.non_labor_std_bill_rate_schdl;
            l_task_in_tbl_type (l_count).non_labor_schedule_fixed_date:= task_rec.non_labor_schedule_fixed_date;
            l_task_in_tbl_type (l_count).non_labor_schedule_discount  := task_rec.non_labor_schedule_discount;
            l_task_in_tbl_type (l_count).labor_cost_multiplier_name   := task_rec.labor_cost_multiplier_name;
            l_task_in_tbl_type (l_count).cost_ind_rate_sch_id         := task_rec.cost_ind_rate_sch_id;
            l_task_in_tbl_type (l_count).rev_ind_rate_sch_id          := task_rec.rev_ind_rate_sch_id;
            l_task_in_tbl_type (l_count).inv_ind_rate_sch_id          := task_rec.inv_ind_rate_sch_id;
            l_task_in_tbl_type (l_count).cost_ind_sch_fixed_date      := task_rec.cost_ind_sch_fixed_date;
            l_task_in_tbl_type (l_count).rev_ind_sch_fixed_date       := task_rec.rev_ind_sch_fixed_date;
            l_task_in_tbl_type (l_count).inv_ind_sch_fixed_date       := task_rec.inv_ind_sch_fixed_date;
            l_task_in_tbl_type (l_count).labor_sch_type               := task_rec.labor_sch_type;
            l_task_in_tbl_type (l_count).non_labor_sch_type           := task_rec.non_labor_sch_type;
            l_task_in_tbl_type (l_count).actual_start_date            := task_rec.actual_start_date;
            l_task_in_tbl_type (l_count).actual_finish_date           := task_rec.actual_finish_date;
            l_task_in_tbl_type (l_count).early_start_date             := task_rec.early_start_date;
            l_task_in_tbl_type (l_count).early_finish_date            := task_rec.early_finish_date;
            l_task_in_tbl_type (l_count).late_start_date              := task_rec.late_start_date;
            l_task_in_tbl_type (l_count).scheduled_start_date         := task_rec.scheduled_start_date;
            l_task_in_tbl_type (l_count).scheduled_finish_date        := task_rec.scheduled_finish_date;
            l_task_in_tbl_type (l_count).allow_cross_charge_flag      := task_rec.allow_cross_charge_flag;
            l_task_in_tbl_type (l_count).project_rate_date            := task_rec.project_rate_date;
            l_task_in_tbl_type (l_count).project_rate_type            := task_rec.project_rate_type;
            l_task_in_tbl_type (l_count).cc_process_labor_flag        := task_rec.cc_process_labor_flag;
            l_task_in_tbl_type (l_count).labor_tp_schedule_id         := task_rec.labor_tp_schedule_id;
            l_task_in_tbl_type (l_count).labor_tp_fixed_date          := task_rec.labor_tp_fixed_date;
            l_task_in_tbl_type (l_count).cc_process_nl_flag           := task_rec.cc_process_nl_flag;
            l_task_in_tbl_type (l_count).nl_tp_schedule_id            := task_rec.nl_tp_schedule_id;
            l_task_in_tbl_type (l_count).nl_tp_fixed_date             := task_rec.nl_tp_fixed_date;
            l_task_in_tbl_type (l_count).receive_project_invoice_flag := task_rec.receive_project_invoice_flag;
            l_task_in_tbl_type (l_count).attribute_category           := task_rec.attribute_category;
            l_task_in_tbl_type (l_count).attribute1                   := task_rec.attribute1;
            l_task_in_tbl_type (l_count).attribute2                   := task_rec.attribute2;
            l_task_in_tbl_type (l_count).attribute3                   := task_rec.attribute3;
            l_task_in_tbl_type (l_count).attribute4                   := task_rec.attribute4;
            l_task_in_tbl_type (l_count).attribute5                   := task_rec.attribute5;
            l_task_in_tbl_type (l_count).attribute6                   := task_rec.attribute6;
            l_task_in_tbl_type (l_count).attribute7                   := task_rec.attribute7;
            l_task_in_tbl_type (l_count).attribute8                   := task_rec.attribute8;
            l_task_in_tbl_type (l_count).attribute9                   := task_rec.attribute9;
            l_task_in_tbl_type (l_count).attribute10                  := task_rec.attribute10;
            l_task_in_tbl_type (l_count).job_bill_rate_schedule_id    := task_rec.job_bill_rate_schedule_id;

            l_count := l_count + 1;
        END LOOP;

        PA_PROJECT_PUB.INIT_PROJECT;

        PA_PROJECT_PUB.CREATE_PROJECT
        ( 
            ln_api_version_number,
            p_commit              => lc_commit,
            p_init_msg_list      => lc_init_msg_list,
            p_msg_count          => ln_msg_count,
            p_msg_data            => lc_msg_data,
            p_return_status      => lc_return_status,
            p_workflow_started    => lc_workflow_started,
            p_pm_product_code => lc_pm_product_code,
            p_project_in          => lr_project_in_rec,
            p_project_out        => lr_project_out_rec,
            p_key_members        => lt_key_members_tbl,
            p_class_categories    => lt_class_categories_tbl,
            p_tasks_in            => l_task_in_tbl_type,
            p_tasks_out          => l_task_out_tbl_type
        );

        IF lc_return_status != 'S' THEN
            DECLARE
              v_error_message VARCHAR2(4000);
            BEGIN            

                --DBMS_OUTPUT.PUT_LINE( 'An API_ERROR occurred');
                v_error_message := 'PA_PROJECT_PUB.CREATE_PROJECT API_ERROR: ';

                IF ln_msg_count >= 1
                THEN
                   --DBMS_OUTPUT.PUT_LINE('ln_msg_count when cntr >=1 : ' || ln_msg_count);

                   FOR i IN 1 .. ln_msg_count
                   LOOP
                      pa_interface_utils_pub.get_messages (
                         p_msg_data        => lc_msg_data,
                         p_encoded         => 'F',
                         p_msg_index       => i,
                         p_data            => lc_data,
                         p_msg_count       => ln_msg_count,
                         p_msg_index_out   => ln_msg_index_out);

                      --DBMS_OUTPUT.PUT_LINE('Error Message when API_ERROR: ' || lc_data);
                      v_error_message := v_error_message || lc_data;
                   END LOOP;
                END IF;

                ROLLBACK;

                SELECT 'ERR' || XXTM_WEBADI_ERR_ID_S.nextval
                INTO l.error_code
                FROM dual;

                INSERT INTO XXTM_WEBADI_ERR VALUES (p_run_id,l.error_code, v_error_message, G_PROGRAM_NAME||'1_'||l_debug,fnd_global.user_id,sysdate);
                UPDATE XXPA_PROJECT_WEBADI_STG 
                SET status = 'E',
                error_code = l.error_code 
                WHERE rowid = l.rowid;

                COMMIT;

                EXIT;
            END;    
        ELSE
            -- API Create Project not update DFF, so override it
            UPDATE PA_PROJECTS_ALL
            SET ATTRIBUTE1 = lr_project_in_rec.attribute1,
                ATTRIBUTE6 = lr_project_in_rec.attribute6
            WHERE project_id = lr_project_out_rec.pa_project_id;
            --lr_project_in_rec.attribute6 := l.transaction_num;
            /*
            DBMS_OUTPUT.put_line ( 'Successfully Created the Project and Task');
            DBMS_OUTPUT.put_line ( 'Project ID : ' || lr_project_out_rec.pa_project_id || '; Project Number : ' || lr_project_out_rec.pa_project_number);

            FOR I IN 1 .. l_task_in_tbl_type.COUNT
            LOOP
                DBMS_OUTPUT.put_line ('Task ID : ' || l_task_out_tbl_type (i).pa_task_id||'; Task Ref : ' || l_task_out_tbl_type (i).pm_task_reference);
            END LOOP;
            */

            -- create custom billing trx, after create project

            DECLARE
                ln_api_version_number           NUMBER := 1.0;
                lv_commit                       VARCHAR2 (1) := FND_API.G_FALSE;
                lv_return_status                VARCHAR2 (1) := NULL;
                lv_msg                          VARCHAR2 (4000);

                l_bs_hdr_in_rec_type            XXBS_TRX_PUB.bs_hdr_in_rec_type;
                l_bs_hdr_out_rec_type           XXBS_TRX_PUB.bs_hdr_out_rec_type;
                l_salerep_in_tbl_type           XXBS_TRX_PUB.salerep_in_tbl_type;
                l_salerep_out_tbl_type          XXBS_TRX_PUB.salerep_out_tbl_type;
            BEGIN

                select org_id
                    ,project_id
                    ,carrying_out_organization_id
                    ,attribute1 memo_line_id 
                into l_bs_hdr_in_rec_type.ORG_ID
                    , l_bs_hdr_in_rec_type.ORIGINAL_PROJECT_ID
                    , l_bs_hdr_in_rec_type.PRIMARY_PROJECT_ORG_ID
                    ,l_bs_hdr_in_rec_type.PRIMARY_PRODUCT_TYPE_ID
                from pa_projects_all
                --where project_id = 9021;
                where project_id = lr_project_out_rec.pa_project_id;

                l_debug := '11';

                select hca.cust_account_id
                    ,hcas.cust_acct_site_id
                    ,(select term_id from ar.ra_terms_tl
                        where term_id = (select standard_terms
                        from AR.hz_customer_profiles
                        where site_use_id is null
                        and cust_account_id =  hca.cust_account_id)) term_id
                    ,hca.attribute1 primary_salerep
                    ,hca.attribute2 primary_salesplit
                into l_bs_hdr_in_rec_type.BILL_TO_CUSTOMER_ID    
                    ,l_bs_hdr_in_rec_type.BILL_TO_ADDRESS_ID     
                    ,l_bs_hdr_in_rec_type.TERM_ID
                    ,l_salerep_in_tbl_type(1).SALESREP_ID
                    ,l_salerep_in_tbl_type(1).SPLIT_PERCENTAGE
                from hz_cust_accounts hca
                    ,hz_cust_acct_sites_all     hcas
                    ,hz_cust_site_uses_all      hcsu
                    ,hz_parties hp
                where hp.party_id              = hca.party_id
                and hca.cust_account_id        = hcas.cust_account_id
                and hcsu.cust_acct_site_id   = hcas.cust_acct_site_id
                and hcsu.site_use_code         = 'BILL_TO'
                and hcas.org_id                 = l_bs_hdr_in_rec_type.ORG_ID
                and hp.party_name              = G_CUSTOMER_NAME
                ;

                l_debug := '12';

                l_bs_hdr_in_rec_type.AR_TRX_NUMBER := lr_project_in_rec.attribute6;

                l_bs_hdr_in_rec_type.TRX_DATE := sysdate;  

                select PERIOD_NAME
                into l_bs_hdr_in_rec_type.PERIOD_NAME
                from gl_periods gp, gl_ledgers gl,hr_operating_units hou
                where gp.period_set_name = gl.period_set_name
                and gl.ledger_id = hou.set_of_books_id
                and hou.organization_id = l.org_id
                and gp.adjustment_period_flag = 'N'
                and gp.end_date = (select max(end_date)
                                    from GL_PERIOD_STATUSES_V gps,hr_operating_units hou2
                                    where gps.closing_status = 'O'
                                    and gps.application_id = 101
                                    and gps.ledger_id = hou2.set_of_books_id
                                    and hou2.organization_id =hou.organization_id)
                ;

                l_debug := '13';
                l_bs_hdr_in_rec_type.INVOICE_ADDRESS_ID := l_bs_hdr_in_rec_type.BILL_TO_ADDRESS_ID;

                select distinct i.user_id owning_biller_id
                    ,i.user_id active_biller_id
                into l_bs_hdr_in_rec_type.OWNING_BILLER_ID   
                    ,l_bs_hdr_in_rec_type.ACTIVE_BILLER_ID     
                from fnd_user i, fnd_user_resp_groups_direct j,
                fnd_responsibility_tl k
                where i.user_id = j.user_id
                and j.responsibility_id = k.responsibility_id
                and k.responsibility_name like '%Biller%'
                and (i.End_Date is Null OR i.End_Date >= sysdate)
                and (j.End_Date is Null OR j.End_Date >= sysdate)
                and i.USER_NAME = G_BILLER_NAME;                
                l_debug := '44';
                /*
                l_bs_hdr_in_rec_type.OWNING_BILLER_ID := 0;      
                l_bs_hdr_in_rec_type.ACTIVE_BILLER_ID := 0;       
                */                
                l_bs_hdr_in_rec_type.ENTERED_CURRENCY_CODE := 'HKD';
                l_bs_hdr_in_rec_type.EXCHANGE_DATE := sysdate;
                l_bs_hdr_in_rec_type.EXCHANGE_RATE := 1;         
                l_bs_hdr_in_rec_type.EXCHANGE_RATE_TYPE := 'User';    
                l_bs_hdr_in_rec_type.INVOICE_CLASS := 'N';
                l_bs_hdr_in_rec_type.CURRENT_STATUS := 'Created';        
                l_bs_hdr_in_rec_type.INVOICE_STYLE_NAME := G_INVOICE_STYLE_NAME;

                lv_return_status := null;
                lv_msg := null;
                l_debug := '88';
                XXBS_TRX_PUB.CREATE_BS_TRX
                (
                 p_api_version_number     => ln_api_version_number
                 ,p_commit                => lv_commit
                 ,p_msg                   => lv_msg
                 ,p_return_status         => lv_return_status
                 ,p_bs_hdr_in             => l_bs_hdr_in_rec_type
                 ,p_bs_hdr_out            => l_bs_hdr_out_rec_type
                 ,p_salerep_in            => l_salerep_in_tbl_type
                 ,p_salerep_out           => l_salerep_out_tbl_type
                );
                l_debug := lv_return_status||'99';
                /*
                dbms_output.put_line(l_bs_hdr_out_rec_type.CUSTOMER_TRX_ID);
                dbms_output.put_line(l_bs_hdr_out_rec_type.AR_TRX_NUMBER);
                dbms_output.put_line(l_bs_hdr_out_rec_type.RETURN_STATUS);
                dbms_output.put_line(lv_msg);
                */

                IF lv_return_status != 'S' THEN
                    DECLARE
                      v_error_message VARCHAR2(4000);
                    BEGIN            
                        v_error_message:= null;
                        --DBMS_OUTPUT.PUT_LINE( 'An API_ERROR occurred');
                        v_error_message := 'XXBS_TRX_PUB.CREATE_BS_TRX API_ERROR: ';
                        l_debug := '99.1';
                        v_error_message := v_error_message || substr(lv_msg,1,3500);
                        l_debug := '99.2';
                        ROLLBACK;

                        SELECT 'ERR' || XXTM_WEBADI_ERR_ID_S.nextval
                        INTO l.error_code
                        FROM dual;

                        INSERT INTO XXTM_WEBADI_ERR VALUES (p_run_id,l.error_code, v_error_message, G_PROGRAM_NAME||'2_'||l_debug,fnd_global.user_id,sysdate);

                        UPDATE XXPA_PROJECT_WEBADI_STG 
                        SET status = 'E',
                        error_code = l.error_code 
                        WHERE rowid = l.rowid;

                        COMMIT;

                        EXIT;
                    END;    
                END IF;                
            END;

            UPDATE XXPA_PROJECT_WEBADI_STG
            SET status = DECODE(l.error_code, NULL, 'C', 'E')
            WHERE rowid = l.rowid;        

            --COMMIT;

        END IF;

        /*************************************************************************
         * Call Standard per_qualifications_api.create_qualification
         *************************************************************************/
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

            INSERT INTO XXTM_WEBADI_ERR VALUES (p_run_id,l.error_code, v_error_message, G_PROGRAM_NAME||'_3_'||l_debug,fnd_global.user_id,sysdate);

            UPDATE XXPA_PROJECT_WEBADI_STG 
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

END XXPA_PROJECT_WEBADI_PKG;

/
