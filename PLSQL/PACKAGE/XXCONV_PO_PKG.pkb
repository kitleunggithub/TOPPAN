--------------------------------------------------------
--  DDL for Package Body XXCONV_PO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXCONV_PO_PKG" AS
/*******************************************************************************
 *
 * Module Name : Purchasing
 * Package Name: XXCONV_PO_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-OCT-2020
 *
 * Purpose     : This program will upload AP Invoices.
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung   30-OCT-2020   Initial Release.
 *
 *******************************************************************************/

      e_abort EXCEPTION;
    c_appl_name     CONSTANT VARCHAR2(50) := 'PO';
    --c_resp_key      CONSTANT VARCHAR2(50) := 'PURCHASING_SUPER_USER';
    c_resp_key      CONSTANT VARCHAR2(50) := 'XXPO_SETUP';
    c_program_name  CONSTANT VARCHAR2(50) := 'XXCONV_PO';
    c_newline       CONSTANT VARCHAR2(1) := fnd_global.newline;
    c_msg_length    CONSTANT NUMBER(15) := 1000;
    c_errbuf_max    CONSTANT NUMBER(15) := 240;
    c_request_id    NUMBER(15) := fnd_global.conc_request_id;
    c_user_id       CONSTANT NUMBER(15) := fnd_global.user_id;
    c_login_id      CONSTANT NUMBER(15) := fnd_global.login_id;
    c_sysdate       CONSTANT DATE := sysdate;
  --c_gl_date     constant date         := to_date('31-AUG-2020','DD-MON-YYYY');

    PROCEDURE main (
        errbuf        OUT  VARCHAR2,
        retcode       OUT  VARCHAR2,
        p_file_path   IN   VARCHAR2,
        p_file_name   IN   VARCHAR2,
        p_request_id  IN   NUMBER
    ) IS

        b_abort      BOOLEAN;
        v_abort_msg  VARCHAR2(1000);
        v_error_msg  VARCHAR2(1000);
        v_text       VARCHAR2(1000);
        n_batch_id   NUMBER;
        n_headers    NUMBER;
        n_ccid       NUMBER;
    BEGIN

    --
    -- Initialize
    --
            errbuf := NULL;
        retcode := '0';
        b_abort := false;
        v_abort_msg := NULL;

    --
    -- Application Initialize
    --

        xxconv_common_pkg.apps_init(c_user_id, c_resp_key, c_appl_name);
        IF nvl(p_request_id, 0) = 0 THEN
        --
        -- Call SQL Loader to Upload Data to Staging Table
        --
            DECLARE
                n_request_id  NUMBER;
                v_dev_status  VARCHAR2(30);
            BEGIN
                n_request_id := xxconv_common_pkg.upload_data(c_request_id, c_program_name, p_file_path, p_file_name);
                IF n_request_id = 0 THEN
                    xxconv_common_pkg.append_message(v_abort_msg, 'Submission of Concurrent Request "Data Conversion: '
                                                                  || c_program_name
                                                                  || ' (SQL*Loader)" was failed.');
                    xxconv_common_pkg.append_message(v_abort_msg, fnd_message.get);
                    RAISE e_abort;
                END IF;

                v_dev_status := xxconv_common_pkg.wait_request(n_request_id);
                IF NOT ( v_dev_status = 'COMPLETE' ) THEN
                    xxconv_common_pkg.append_message(v_abort_msg, 'Concurrent Request (ID: '
                                                                  || to_char(n_request_id)
                                                                  || ') "Data Conversion: '
                                                                  || c_program_name
                                                                  || ' (SQL*Loader)" failed.');

                    RAISE e_abort;
                END IF;

            END;
        ELSE
            BEGIN
                SELECT DISTINCT request_id
                INTO c_request_id
                FROM xxconv_po
                WHERE request_id = p_request_id;
            EXCEPTION
                WHEN OTHERS THEN
                    xxconv_common_pkg.append_message(v_abort_msg, 'Request ID ('
                                                                  || p_request_id
                                                                  || ') not found in interface table');
                    RAISE e_abort;
            END;

            c_request_id := p_request_id;
            xxconv_common_pkg.write_log('Re-Run Request ID = ' || c_request_id);
        END IF;

    --
    -- Get Batch ID
    --
        SELECT ap_batches_s.NEXTVAL
        INTO n_batch_id
        FROM dual;

    --
    -- Set Status Flag to 'P'.
    --
        UPDATE xxconv_po
        SET status_flag = 'P',
            batch_id = n_batch_id
        WHERE request_id = c_request_id;

    --
    -- Lookup Operating Unit ID.
    --
            MERGE INTO ( SELECT
                      request_id,
                      operating_unit_name,
                      org_id,
                      nvl(operating_unit_name, 'HK_OU-TOPPAN MERRILL IFN LIMITED') operating_unit_name_nvl --default HK1_OU
                                  FROM
                      xxconv_po
                  WHERE
                      request_id = c_request_id
                  )
        pohd
        USING (
                  SELECT
                      *
                  FROM
                      hr_operating_units hrou2
              )
        hrou2 ON ( pohd.operating_unit_name_nvl = hrou2.name )
        WHEN MATCHED THEN UPDATE
        SET pohd.org_id = hrou2.organization_id,
            pohd.operating_unit_name = hrou2.name;

    --
    -- Assign Interface ID.
    --
            FOR rec_pohd IN (
            SELECT
                po_num,
                request_id,
                po_headers_interface_s.NEXTVAL interface_header_id
            FROM
                (
                    SELECT DISTINCT
                        po_num,
                        request_id
                    FROM
                        xxconv_po
                    WHERE
                            request_id = c_request_id
                        AND po_num IS NOT NULL
                    ORDER BY
                        po_num
                )
        ) LOOP
            UPDATE xxconv_po
            SET
                interface_header_id = rec_pohd.interface_header_id
            WHERE
                    po_num = rec_pohd.po_num
                AND request_id = rec_pohd.request_id;

        END LOOP;

        FOR rec_poln IN (
            SELECT
                interface_header_id,
                line_num,
                request_id,
                po_lines_interface_s.NEXTVAL interface_line_id
            FROM
                (
                    SELECT DISTINCT
                        interface_header_id,
                        line_num,
                        request_id
                    FROM
                        xxconv_po
                    WHERE
                            request_id = c_request_id
                        AND interface_header_id IS NOT NULL
                    ORDER BY
                        interface_header_id,
                        line_num
                )
        ) LOOP
            UPDATE xxconv_po
            SET
                interface_line_id = rec_poln.interface_line_id
            WHERE
                    interface_header_id = rec_poln.interface_header_id
                AND request_id = rec_poln.request_id
                AND ( ( line_num = rec_poln.line_num )
                      OR ( line_num IS NULL
                           AND rec_poln.line_num IS NULL ) );

        END LOOP;

        FOR rec_podt IN (
            SELECT
                ROWID row_id
            FROM
                xxconv_po
            WHERE
                    request_id = c_request_id
                AND interface_header_id IS NOT NULL
                AND interface_line_id IS NOT NULL
            ORDER BY
                interface_header_id,
                interface_line_id
        ) LOOP
            UPDATE xxconv_po
            SET
                interface_distribution_id = po_distributions_interface_s.NEXTVAL
            WHERE
                ROWID = rec_podt.row_id;

        END LOOP;

        UPDATE XXCONV_PO
        SET line_type = '2 WAY AMOUNT - TM'
        WHERE line_type in ('2 WAY AMOUNT - MRL','2 WAY AMOUNT – TM')
        AND request_id = c_request_id;

        UPDATE XXCONV_PO
        SET line_type = '3 WAY QUANTITY'
        WHERE line_type in ('2 WAY QUANTITY')
        AND request_id = c_request_id;        

        UPDATE XXCONV_PO
        SET line_type = '3 WAY AMOUNT - TM'
        WHERE line_type in ('2 WAY AMOUNT - TM')
        AND request_id = c_request_id;

        UPDATE XXCONV_PO
        SET category = trim(category)
        WHERE request_id = c_request_id;        

    --
    -- Commit Changes.
    --
            COMMIT;

    --
    -- Validation.
    --
            FOR rec_poln IN (
            SELECT
                poln.row_id,
                poln.seq_num,
                poln.operating_unit_name,
                poln.org_id,
                decode(poln.org_id, NULL, 'N', 'Y')                     is_operating_unit_valid,
                poln.inventory_organization_id,
                poln.po_date,
                poln.po_num,
                decode(pohd.segment1, NULL, 'N', 'Y')                     is_po_num_exist,
                (
                    CASE
                        WHEN TRIM(poln.po_num) IS NOT NULL
                             AND TRIM(translate(poln.po_num, '0123456789', ' ')) IS NULL THEN
                            'Y'
                        ELSE
                            'N'
                    END
                )                                                         is_po_num_valid,
                poln.po_type,
                poln.vendor_name,
                poln.vendor_id,
                poln.party_id,
                decode(poln.vendor_id, NULL, 'N', 'Y')                    is_vendor_valid,
                poln.vendor_site_code,
                poln.vendor_site_id,
                (
                    CASE
                        WHEN poln.vendor_id IS NOT NULL
                             AND poln.vendor_site_code IS NOT NULL
                             AND poln.vendor_site_id IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_vendor_site_valid,
                poln.vendor_contact,
                decode(cntt.person_last_name, NULL, NULL, cntt.person_last_name
                                                          || ' '
                                                          || cntt.person_first_name)                                 contact_name,
                (
                    CASE
                        WHEN poln.vendor_site_id IS NOT NULL
                             AND poln.vendor_contact IS NOT NULL
                             AND cntt.contact_name IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_vendor_contact_valid,
                poln.ship_to_location,
                ship.location_id                                          ship_to_location_id,
                (
                    CASE
                        WHEN poln.ship_to_location IS NOT NULL
                             AND ship.location_id IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_ship_to_location_valid,
                poln.bill_to_location,
                bill.location_id                                          bill_to_location_id,
                (
                    CASE
                        WHEN poln.bill_to_location IS NOT NULL
                             AND bill.location_id IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_bill_to_location_valid,
                poln.agent_name,
                agnt.agent_id,
                decode(agnt.agent_id, NULL, 'N', 'Y')                     is_agent_valid,
                poln.comments,
                poln.currency_code,
                decode(fccy.currency_code, NULL, 'N', 'Y')                is_currency_valid,
                poln.rate_type,
                conv.conversion_type,
                (
                    CASE
                        WHEN poln.rate_type IS NOT NULL
                             AND conv.conversion_type IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_rate_type_valid,
                poln.rate_date,
                poln.rate,
                poln.payment_terms,
                term.term_id,
                (
                    CASE
                        WHEN poln.payment_terms IS NOT NULL
                             AND term.term_id IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_payment_terms_valid,
                poln.line_num,
                poln.line_type,
                (
                    CASE
                        WHEN plt.line_type_id IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_line_type_valid,
                poln.item_segment1,
                poln.item_segment2,
                poln.item_segment3,
                item.inventory_item_id,
                (
                    CASE
                        WHEN poln.item_segment1
                             || poln.item_segment2
                             || poln.item_segment3 IS NOT NULL
                             AND item.inventory_item_id IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_item_valid,
                poln.category,
                icat.category_id,
                (
                    CASE
                        WHEN poln.category IS NOT NULL
                             AND icat.category_id IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_category_valid,
                poln.item_description,
                poln.vendor_product_num,
                poln.line_ship_to_location,
                lshp.location_id                                          line_ship_to_location_id,
                (
                    CASE
                        WHEN poln.line_ship_to_location IS NOT NULL
                             AND lshp.location_id IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_line_ship_to_location_valid,
                poln.unit_of_measure,
                muom.uom_code,
                (
                    CASE
                        WHEN poln.unit_of_measure IS NOT NULL
                             AND muom.uom_code IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_unit_of_measure_valid,
                poln.line_unit_of_measure,
                lmuom.uom_code line_uom_code,
                (
                    CASE
                        WHEN poln.line_unit_of_measure IS NOT NULL
                             AND lmuom.uom_code IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_line_unit_of_measure_valid,      
                poln.RECEIPT_DAYS_EXCEPTION_CODE,
                poln.QTY_RCV_EXCEPTION_CODE,
                poln.ENFORCE_SHIP_TO_LOCATION_CODE,          
                poln.routing_name,
                (
                    CASE
                        WHEN poln.routing_name IS NOT NULL AND fnd_route.routing_name IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_route_valid,                      
                poln.quantity,
                poln.unit_price,
                item.mrp_planning_code,
                poln.promised_date,
                poln.need_by_date,
                poln.destination_type_code,
                (
                    CASE
                        WHEN upper(poln.destination_type_code) IN ( 'EXPENSE', 'INVENTORY' ) THEN
                            'Y'
                        ELSE
                            'N'
                    END
                )                                                         is_destination_type_valid,
                poln.requestor,
                (
                    CASE
                        WHEN poln.requestor is not null and ppf.full_name IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_requestor_valid,  
                poln.deliver_to,
                (
                    CASE
                        WHEN poln.deliver_to is not null and deliver_to.location_code IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_deliver_to_valid,                  
                poln.charge_account,
                chrg.code_combination_id                                  charge_account_id,
                decode(chrg.code_combination_id, NULL, 'N', 'Y')          is_charge_account_valid,
                poln.budget_account,
                bdgt.code_combination_id                                  budget_account_id,
                (
                    CASE
                        WHEN poln.budget_account IS NOT NULL
                             AND bdgt.code_combination_id IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_budget_account_valid,
                poln.project_number,
                poln.task_number,
                (
                    CASE
                        WHEN project.project_number IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_project_task_valid,         
                (
                    CASE
                        WHEN project_org.project_number IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_project_org_valid,                                      
                poln.expenditure_type,
                (
                    CASE
                        WHEN pet.expenditure_type IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_exp_type_valid,  
                poln.org,
                (
                    CASE
                        WHEN exp_org.name IS NULL THEN
                            'N'
                        ELSE
                            'Y'
                    END
                )                                                         is_exp_org_valid,          
                poln.expenditure_item_date,
                poln.header_row_num,
                poln.line_row_num
            FROM
                (
                    SELECT
                        poln.*,
                        site.vendor_site_id,
                        site.party_site_id
                    FROM
                        (
                            SELECT
                                poln.rowid              row_id,
                                poln.seq_num,
                                poln.operating_unit_name,
                                hrou.organization_id    org_id,
                                parm.inventory_organization_id,
                                poln.po_date,
                                poln.po_num,
                                poln.po_type,
                                poln.vendor_name,
                                vndr.vendor_id,
                                vndr.party_id,
                                poln.vendor_site_code,
                                poln.vendor_contact,
                                poln.ship_to_location,
                                poln.bill_to_location,
                                poln.agent_name,
                                poln.comments,
                                poln.currency_code,
                                poln.rate_type,
                                poln.rate_date,
                                poln.rate,
                                poln.payment_terms,
                                poln.line_num,
                                poln.item_segment1,
                                poln.item_segment2,
                                poln.item_segment3,
                                poln.category,
                                poln.item_description,
                                poln.vendor_product_num,
                                poln.line_ship_to_location,
                                poln.unit_of_measure,
                                poln.line_unit_of_measure,
                                poln.quantity,
                                poln.unit_price,
                                poln.promised_date,
                                poln.need_by_date,
                                poln.destination_type_code,
                                poln.charge_account,
                                poln.budget_account,
                                poln.line_type,
                                poln.RECEIPT_DAYS_EXCEPTION_CODE,
                                poln.QTY_RCV_EXCEPTION_CODE,
                                poln.ENFORCE_SHIP_TO_LOCATION_CODE,
                                poln.routing_name,
                                poln.requestor,
                                poln.deliver_to,
                                poln.project_number,
                                poln.task_number,
                                poln.expenditure_type,
                                poln.org,
                                poln.expenditure_item_date,
                                poln.request_id,
                                ROW_NUMBER()
                                OVER(PARTITION BY poln.request_id,
                                                  poln.po_num
                                     ORDER BY poln.seq_num
                                )                       header_row_num,
                                ROW_NUMBER()
                                OVER(PARTITION BY poln.request_id,
                                                  poln.po_num,
                                                  poln.line_num
                                     ORDER BY poln.seq_num
                                )                       line_row_num
                            FROM
                                xxconv_po                     poln,
                                hr_operating_units            hrou,
                                financials_system_params_all  parm,
                                (
                                    SELECT
                                        upper(vendor_name) vendor_name,
                                        vendor_id,
                                        party_id
                                    FROM
                                        ap_suppliers vndr
                                    --WHERE nvl(vendor_type_lookup_code, 'XX') != 'EMPLOYEE'
                                    --    AND employee_id IS NULL
                                )                             vndr
                            WHERE
                                    upper(hrou.name(+)) = upper(poln.operating_unit_name)
                                AND parm.set_of_books_id (+) = hrou.set_of_books_id
                                AND parm.org_id (+) = hrou.organization_id
                                AND vndr.vendor_name (+) = upper(poln.vendor_name)
                        )                      poln,
                        ap_supplier_sites_all  site
                    WHERE
                            site.vendor_id (+) = poln.vendor_id
                        AND site.vendor_site_code (+) = poln.vendor_site_code
                        AND site.org_id (+) = poln.org_id
                )                          poln,
                po_headers_all             pohd,
                (
                    SELECT
                        org_party_site_id,
                        contact_name,
                        person_last_name,
                        person_first_name,
                        ROW_NUMBER()
                        OVER(PARTITION BY org_party_site_id,
                                          contact_name
                             ORDER BY seq_num
                        ) row_num
                    FROM
                        (
                            SELECT
                                1                             seq_num,
                                apsc.org_party_site_id,
                                prty.person_last_name,
                                prty.person_first_name,
                                prty.person_last_name
                                || ' '
                                || prty.person_first_name      contact_name
                            FROM
                                ap_supplier_contacts  apsc,
                                hz_parties            prty
                            WHERE
                                    prty.party_id = apsc.per_party_id
                                AND prty.status = 'A'
                            UNION ALL
                            SELECT
                                2                             seq_num,
                                apsc.org_party_site_id,
                                prty.person_last_name,
                                prty.person_first_name,
                                prty.person_last_name
                                || ','
                                || prty.person_first_name      contact_name
                            FROM
                                ap_supplier_contacts  apsc,
                                hz_parties            prty
                            WHERE
                                    prty.party_id = apsc.per_party_id
                                AND prty.status = 'A'
                            UNION ALL
                            SELECT
                                3                        seq_num,
                                apsc.org_party_site_id,
                                prty.person_last_name,
                                prty.person_first_name,
                                prty.person_last_name    contact_name
                            FROM
                                ap_supplier_contacts  apsc,
                                hz_parties            prty
                            WHERE
                                    prty.party_id = apsc.per_party_id
                                AND prty.status = 'A'
                                AND prty.person_first_name IS NULL
                        )
                )                          cntt,
                (
                    SELECT
                        location_code,
                        location_id,
                        ship_to_site_flag,
                        bill_to_site_flag
                    FROM
                        hr_locations
                    WHERE
                        ( inactive_date IS NULL
                          OR inactive_date > sysdate )
                )                          ship,
                (
                    SELECT
                        location_code,
                        location_id,
                        ship_to_site_flag,
                        bill_to_site_flag
                    FROM
                        hr_locations
                    WHERE
                        ( inactive_date IS NULL
                          OR inactive_date > sysdate )
                )                          bill,
                (
                            /*
                             select agent_name,
                                    agent_id
                             from   po_agents_v
                             where  sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate)
                            */
                                                    SELECT
                        a.agent_name,
                        a.agent_id
                    FROM
                        po_agents_v    a,
                        per_people_v7  b
                    WHERE
                        sysdate BETWEEN nvl(a.start_date_active, sysdate) AND nvl(a.end_date_active, sysdate)
                        AND nvl(b.d_termination_date, sysdate) >= sysdate
                        AND a.agent_name = b.full_name
                )                          agnt,
                fnd_currencies             fccy,
                gl_daily_conversion_types  conv,
                ap_terms                   term,
                mtl_system_items_b         item,
                (
                    SELECT
                        category_concat_segs,
                        category_id
                    FROM
                        mtl_categories_v
                    WHERE
                            structure_name = 'Item Categories'
                        AND enabled_flag = 'Y'
                        AND nvl(disable_date, sysdate + 1) > sysdate
                )                          icat,
                (
                    SELECT
                        location_code,location_id,ship_to_site_flag,bill_to_site_flag
                    FROM
                        hr_locations
                    WHERE inactive_date IS NULL
                        OR inactive_date > sysdate
                )                          lshp,
                (
                    SELECT
                        unit_of_measure, uom_code
                    FROM
                        mtl_units_of_measure_vl
                    WHERE disable_date IS NULL
                        OR disable_date > sysdate
                )                          lmuom,
                (
                    SELECT
                        unit_of_measure, uom_code
                    FROM
                        mtl_units_of_measure_vl
                    WHERE disable_date IS NULL
                        OR disable_date > sysdate
                )                          muom,
                (
                    SELECT
                        concatenated_segments,
                        code_combination_id
                    FROM
                        gl_code_combinations_kfv
                    WHERE
                            detail_budgeting_allowed = 'Y'
                        AND enabled_flag = 'Y'
                        AND sysdate BETWEEN nvl(start_date_active, sysdate) AND nvl(end_date_active, sysdate)
                )                          chrg,
                (
                    SELECT
                        concatenated_segments,
                        code_combination_id
                    FROM
                        gl_code_combinations_kfv
                    WHERE
                            detail_budgeting_allowed = 'Y'
                        AND enabled_flag = 'Y'
                        AND sysdate BETWEEN nvl(start_date_active, sysdate) AND nvl(end_date_active, sysdate)
                )                          bdgt,
                (
                    SELECT
                        line_type,
                        line_type_id
                    FROM
                        po_line_types
                    WHERE
                        inactive_date IS NULL
                        OR inactive_date > sysdate
                )          plt,
                (
                    SELECT j.meaning routing_name
                    FROM apps.fnd_lookup_types_vl i, apps.fnd_lookup_values j
                    where i.lookup_type = j.lookup_type
                    and i.lookup_type = 'RCV_ROUTING_HEADERS'
                ) fnd_route,
                (
                    SELECT DISTINCT FULL_NAME FROM PER_ALL_PEOPLE_F
                    WHERE effective_end_date = '31-Dec-4712'
                ) ppf,
                (
                    SELECT
                        org_id,location_code,location_id,ship_to_site_flag,bill_to_site_flag
                    FROM
                        hr_locations hl,
                        FINANCIALS_SYSTEM_PARAMS_ALL fspa
                    WHERE (nvl(hl.inventory_organization_id,fspa.inventory_organization_id) = fspa.inventory_organization_id)
                    AND (inactive_date IS NULL OR inactive_date > sysdate)                
                ) deliver_to,
                (
                    SELECT
                        pra.org_id, pra.segment1 project_number, pra.project_id,
                        pt.task_id, pt.task_number
                    FROM
                        pa_projects_all  pra,
                        pa_tasks         pt
                    WHERE
                            pra.project_id = pt.project_id
                        AND pra.template_flag = 'N'
                        AND pra.enabled_flag = 'Y'
                ) project,
                (
                    SELECT
                        pra.org_id, pra.segment1 project_number, pra.project_id,hou.name project_org_name,
                        pt.task_id, pt.task_number
                    FROM
                        pa_projects_all  pra,
                        pa_tasks         pt,
                        hr_organization_units hou
                    WHERE pra.project_id = pt.project_id
                    AND pra.carrying_out_organization_id = hou.organization_id
                    AND pra.template_flag = 'N'
                    AND pra.enabled_flag = 'Y'
                ) project_org,                
                (
                select expenditure_type from pa_expenditure_types where end_date_active is null
                ) pet,
                (
                SELECT hrorg.organization_id , hrorg.business_group_id , hrorg.name , hrorg.date_from , hrorg.date_to ,org_id 
                from hr_organization_units hrorg, pa_all_organizations paorg 
                WHERE paorg.organization_id = hrorg.organization_id 
                and paorg.pa_org_use_type = 'EXPENDITURES' 
                and paorg.inactive_date is NULL                 
                ) exp_org
            WHERE
                    poln.request_id = c_request_id
                AND pohd.segment1 (+) = poln.po_num
                AND pohd.type_lookup_code (+) = 'STANDARD'
                AND pohd.org_id (+) = poln.org_id
                AND cntt.org_party_site_id (+) = poln.party_site_id
                AND cntt.contact_name (+) = poln.vendor_contact
                --AND ship.location_code (+) = poln.ship_to_location
                AND ship.location_code (+) = decode(poln.operating_unit_name,'HK_OU-TOPPAN MERRILL IFN LIMITED',poln.ship_to_location,replace(poln.ship_to_location,'MRL ','TM '))
                AND ship.ship_to_site_flag (+) = 'Y'
                --AND bill.location_code (+) = poln.bill_to_location
                AND bill.location_code (+) = decode(poln.operating_unit_name,'HK_OU-TOPPAN MERRILL IFN LIMITED',poln.bill_to_location,replace(poln.bill_to_location,'MRL ','TM '))
                AND bill.bill_to_site_flag (+) = 'Y'
                AND agnt.agent_name (+) = poln.agent_name
                AND fccy.currency_code (+) = poln.currency_code
                AND fccy.enabled_flag (+) = 'Y'
                AND conv.user_conversion_type (+) = poln.rate_type
                AND upper(term.name(+)) = upper(poln.payment_terms)
                AND term.enabled_flag (+) = 'Y'
                AND item.organization_id (+) = poln.inventory_organization_id
                AND item.segment1 (+) = poln.item_segment1
                AND item.segment2 (+) = poln.item_segment2
                AND item.segment3 (+) = decode(poln.item_segment3, NULL, NULL, lpad(poln.item_segment3, 6, '0'))
                AND icat.category_concat_segs (+) = poln.category
                --AND lshp.location_code (+) = poln.line_ship_to_location
                AND lshp.location_code (+) = decode(poln.operating_unit_name,'HK_OU-TOPPAN MERRILL IFN LIMITED',poln.line_ship_to_location,replace(poln.line_ship_to_location,'MRL ','TM '))
                AND lshp.ship_to_site_flag (+) = 'Y'
                AND upper(muom.unit_of_measure(+)) = upper(poln.unit_of_measure)
                AND upper(lmuom.unit_of_measure(+)) = upper(poln.unit_of_measure)
                AND chrg.concatenated_segments (+) = poln.charge_account
                AND bdgt.concatenated_segments (+) = poln.budget_account
                AND upper(plt.line_type(+)) = upper(poln.line_type) 
                AND fnd_route.routing_name(+) = poln.routing_name
                AND ppf.full_name (+) = poln.requestor
                AND deliver_to.location_code (+) = decode(poln.operating_unit_name,'HK_OU-TOPPAN MERRILL IFN LIMITED',poln.deliver_to,replace(poln.deliver_to,'MRL ','TM '))
                AND deliver_to.org_id (+) = poln.org_id
                AND project.project_number (+) = poln.project_number
                AND project.task_number (+) = poln.task_number
                AND project.org_id (+) = poln.org_id
                AND project_org.project_number (+) = poln.project_number
                AND project_org.task_number (+) = poln.task_number
                AND project_org.project_org_name (+) = poln.org
                AND pet.expenditure_type (+) = poln.expenditure_type
                AND exp_org.name (+) = poln.org
                AND exp_org.org_id (+) = poln.org_id

        ) LOOP
            v_error_msg := NULL;

      --
      -- PO Headers
      --
                  IF rec_poln.header_row_num = 1 THEN
                IF rec_poln.is_operating_unit_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Operating Unit] (VALUE= '
                              || rec_poln.operating_unit_name
                              || ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.is_po_num_exist = 'Y' THEN
                    b_abort := true;
                    v_text := '[PO Number] (VALUE= '
                              || rec_poln.po_num
                              || ') already exists.';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;
                /*
                IF rec_poln.is_po_num_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [PO Number] (VALUE= '
                              || rec_poln.po_num
                              || '). Valid characters are 0-9.';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;
                */
                IF rec_poln.po_type <> 'STANDARD' THEN
                    b_abort := true;
                    v_text := 'the program only handle Standard PO';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.is_vendor_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Vendor] (VALUE= '|| rec_poln.vendor_name|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.is_vendor_site_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Vendor Site] (VALUE= '|| rec_poln.vendor_site_code|| ') [Vendor] (VALUE= '|| rec_poln.vendor_name|| ').';

                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.is_vendor_contact_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Vendor Contact] (VALUE= '|| rec_poln.vendor_contact|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                ELSE
                    IF rec_poln.contact_name IS NOT NULL THEN
                        UPDATE xxconv_po poln
                        SET
                            poln.vendor_contact_name = rec_poln.contact_name
                        WHERE
                            ROWID = rec_poln.row_id;

                    END IF;
                END IF;

                IF rec_poln.is_ship_to_location_valid = 'N' THEN
                    b_abort := true;
                    --v_text := 'Invalid [Ship To Location] (VALUE= '|| rec_poln.ship_to_location|| ').';
                    v_text := 'Invalid [Ship To Location] (VALUE= '|| case when rec_poln.operating_unit_name = 'HK_OU-TOPPAN MERRILL IFN LIMITED' then rec_poln.ship_to_location else replace(rec_poln.ship_to_location,'MRL ','TM ') end|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.is_bill_to_location_valid = 'N' THEN
                    b_abort := true;
                    --v_text := 'Invalid [Bill To Location] (VALUE= '|| rec_poln.bill_to_location|| ').';
                    v_text := 'Invalid [Bill To Location] (VALUE= '|| case when rec_poln.operating_unit_name = 'HK_OU-TOPPAN MERRILL IFN LIMITED' then rec_poln.bill_to_location else replace(rec_poln.bill_to_location,'MRL ','TM ') end|| ').';                    
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.is_agent_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Buyer] (VALUE= '|| rec_poln.agent_name|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.is_currency_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Currency] (VALUE= '|| rec_poln.currency_code|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.is_rate_type_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Rate Type] (VALUE= '|| rec_poln.rate_type|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                ELSE
                    IF rec_poln.rate_type IS NOT NULL THEN
                        IF rec_poln.rate_date IS NULL THEN
                            b_abort := true;
                            v_text := '[Rate Date] is required.';
                            xxconv_common_pkg.append_message(v_error_msg, v_text);
                        END IF;

                        IF rec_poln.rate IS NULL THEN
                            b_abort := true;
                            v_text := '[Rate] is required.';
                            xxconv_common_pkg.append_message(v_error_msg, v_text);
                        END IF;

                    END IF;
                END IF;

                IF rec_poln.is_payment_terms_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Payment Terms] (VALUE= '|| rec_poln.payment_terms|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.is_line_type_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Line Type] (VALUE= '|| rec_poln.line_type|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;                

            END IF;

      --
      -- PO Lines
      --
                  IF rec_poln.line_row_num = 1 THEN
                IF rec_poln.is_item_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Item] (VALUE= '
                              || rec_poln.item_segment1
                              || '.'
                              || rec_poln.item_segment2
                              || '.'
                              || lpad(rec_poln.item_segment3, 6, '0')
                              || ').';

                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF
                    rec_poln.inventory_item_id IS NOT NULL
                    AND rec_poln.mrp_planning_code <> 6
                THEN -- 6 is unplanned item
                                IF
                        rec_poln.promised_date IS NULL
                        AND rec_poln.need_by_date IS NULL
                    THEN
                        b_abort := true;
                        v_text := '[Promise Date] or [Need By Date] is required for Planned Item (VALUE= '
                                  || rec_poln.item_segment1
                                  || '.'
                                  || rec_poln.item_segment2
                                  || '.'
                                  || lpad(rec_poln.item_segment3, 6, '0')
                                  || ').';

                        xxconv_common_pkg.append_message(v_error_msg, v_text);
                    END IF;

                END IF;

                IF rec_poln.is_category_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Category] (VALUE= ' || rec_poln.category|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.is_line_ship_to_location_valid = 'N' THEN
                    b_abort := true;
                    --v_text := 'Invalid [Line: Ship To Location] (VALUE= '|| rec_poln.line_ship_to_location|| ').';
                    v_text := 'Invalid [Line: Ship To Location] (VALUE= '|| case when rec_poln.operating_unit_name = 'HK_OU-TOPPAN MERRILL IFN LIMITED' then rec_poln.line_ship_to_location else replace(rec_poln.line_ship_to_location,'MRL ','TM ') end|| ').';                    
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.is_line_unit_of_measure_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Line: Unit of Measure] (VALUE= '|| rec_poln.line_unit_of_measure|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;                

                IF rec_poln.item_segment2 IS NULL THEN
                    IF rec_poln.is_unit_of_measure_valid = 'N' THEN
                        b_abort := true;
                        v_text := 'Invalid [Unit of Measure] (VALUE= '|| rec_poln.unit_of_measure|| ').';
                        xxconv_common_pkg.append_message(v_error_msg, v_text);
                    END IF;

                    IF rec_poln.unit_of_measure IS NULL THEN
                        b_abort := true;
                        v_text := '[Unit of Measure] is required for NON-ITEM PO.';
                        xxconv_common_pkg.append_message(v_error_msg, v_text);
                    END IF;

                    IF rec_poln.category IS NULL THEN
                        b_abort := true;
                        v_text := '[Item Category] is required for NON-ITEM PO.';
                        xxconv_common_pkg.append_message(v_error_msg, v_text);
                    END IF;

                    IF upper(rec_poln.destination_type_code) <> 'EXPENSE' THEN
                        b_abort := true;
                        v_text := '[Destination Type Code] must be "EXPENSE" for NON-ITEM PO.';
                        xxconv_common_pkg.append_message(v_error_msg, v_text);
                    END IF;

                    --lookup_type = 'RECEIVING CONTROL LEVEL'
                    IF upper(rec_poln.RECEIPT_DAYS_EXCEPTION_CODE) not in ('NONE','REJECT','WARNING') THEN
                        b_abort := true;
                        v_text := '[Receipt Days Exception Code] must be "NONE" or "REJECT" or "WARNING".';
                        xxconv_common_pkg.append_message(v_error_msg, v_text);
                    END IF;
                    IF upper(rec_poln.QTY_RCV_EXCEPTION_CODE) not in ('NONE','REJECT','WARNING') THEN
                        b_abort := true;
                        v_text := '[QTY Receive Exception Code] must be "NONE" or "REJECT" or "WARNING".';
                        xxconv_common_pkg.append_message(v_error_msg, v_text);
                    END IF;
                    IF upper(rec_poln.ENFORCE_SHIP_TO_LOCATION_CODE) not in ('NONE','REJECT','WARNING') THEN
                        b_abort := true;
                        v_text := '[Enforce Ship to Location Code] must be "NONE" or "REJECT" or "WARNING".';
                        xxconv_common_pkg.append_message(v_error_msg, v_text);
                    END IF;  

                    IF rec_poln.is_route_valid = 'N' THEN
                        b_abort := true;
                        v_text := 'Invalid [Rounting Name] (VALUE= '|| rec_poln.routing_name|| ').';
                        xxconv_common_pkg.append_message(v_error_msg, v_text);
                    END IF;                    

                END IF;

            END IF;

      --
      -- PO Distributions
      --
            IF rec_poln.is_destination_type_valid = 'N' THEN
                b_abort := true;
                v_text := 'Invalid [Destination Type] (VALUE= '|| rec_poln.destination_type_code|| ').';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            END IF;

            IF rec_poln.is_requestor_valid = 'N' THEN
                b_abort := true;
                v_text := 'Invalid [Requestor] (VALUE= '|| rec_poln.requestor|| ').';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            END IF;    

            IF rec_poln.is_deliver_to_valid = 'N' THEN
                b_abort := true;
                v_text := 'Invalid [Deliver To] (VALUE= '|| case when rec_poln.operating_unit_name = 'HK_OU-TOPPAN MERRILL IFN LIMITED' then rec_poln.deliver_to else replace(rec_poln.deliver_to,'MRL ','TM ') end|| ').';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            END IF;                

            IF rec_poln.is_charge_account_valid = 'N' THEN
                b_abort := true;
                v_text := 'Invalid [Charge Account] (VALUE= '|| rec_poln.charge_account|| ').';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            END IF;

            IF rec_poln.is_budget_account_valid = 'N' THEN
                b_abort := true;
                v_text := 'Invalid [Budget Account] (VALUE= '|| rec_poln.budget_account|| ').';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            END IF;

            IF rec_poln.project_number is not null THEN

                IF rec_poln.is_project_task_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Project Number and Task Number] (PROJECT VALUE= '|| rec_poln.project_number||', TASK VALUE= '|| rec_poln.task_number|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF; 

                IF rec_poln.is_project_task_valid = 'Y' and rec_poln.is_project_org_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Project Organization do not match with Project Data (PROJECT VALUE= '|| rec_poln.project_number||', TASK VALUE= '|| rec_poln.org|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);                
                END IF;


                IF rec_poln.task_number is null THEN
                    b_abort := true;
                    v_text := '[Task Number] is required for Project PO.';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;             

                IF rec_poln.expenditure_type is null THEN
                    b_abort := true;
                    v_text := '[Expenditure Type] is required for Project PO.';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.org is null THEN
                    b_abort := true;
                    v_text := '[Expenditure Org] is required for Project PO.';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;

                IF rec_poln.expenditure_item_date is null THEN
                    b_abort := true;
                    v_text := '[Expenditure Item Date] is required for Project PO.';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;                       

                IF rec_poln.is_exp_type_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Expenditure Type] (VALUE= '|| rec_poln.expenditure_type|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;             

                IF rec_poln.is_exp_org_valid = 'N' THEN
                    b_abort := true;
                    v_text := 'Invalid [Expenditure Org] (VALUE= '|| rec_poln.org|| ').';
                    xxconv_common_pkg.append_message(v_error_msg, v_text);
                END IF;
            END IF;
      --
      -- Update Error Message.
      --
                  IF v_error_msg IS NOT NULL THEN
                UPDATE xxconv_po poln
                SET
                    poln.status_flag = 'E',
                    poln.error_message = error_message
                                         || substr(decode(error_message, NULL, NULL, ' | ')
                                                   || v_error_msg, 1, 1000)
                WHERE
                    ROWID = rec_poln.row_id;

            END IF;

        END LOOP;

        xxconv_common_pkg.write_log('end validation loop');
    --
    -- Commit Changes.
    --
            COMMIT;

    --
    -- Abort if failed in Validation.
    --
        IF b_abort THEN
            RAISE e_abort;
        END IF;

/*
    For rec_ccid in (
                        select distinct charge_account gl_account from xxconv_po where request_id = c_request_id and status_flag = 'P' and charge_account is not null
                        union
                        select distinct budget_account gl_account from xxconv_po where request_id = c_request_id and status_flag = 'P' and budget_account is not null
                    )
    Loop
        n_ccid := xxconv_items_pkg.get_ccid(rec_ccid.gl_account,false); --create ccid
    end loop;
*/
    --
    -- Populate PO interface table.
    --
            INSERT INTO po_headers_interface (
            interface_header_id,
            batch_id,
            process_code,
            action,
            document_type_code,
            document_num,
            effective_date,
            org_id,
            vendor_name,
            vendor_site_code,
            vendor_contact,
            ship_to_location,
            bill_to_location,
            agent_name,
            comments,
            currency_code,
            rate_type,
            rate_date,
            rate,
            payment_terms,
            attribute1,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login
        )
            ( SELECT
                pohd.interface_header_id,
                pohd.batch_id,
                'PENDING'                                                   process_code,
                'ORIGINAL'                                                  action,
                pohd.po_type                                                document_type_code,
                pohd.po_num                                                 document_num,
                pohd.po_date                                                effective_date,
                pohd.org_id,
                nvl(vndr.vendor_name, pohd.vendor_name)          vendor_name,
                pohd.vendor_site_code,
                nvl(pohd.vendor_contact_name, pohd.vendor_contact)          vendor_contact,
                --pohd.ship_to_location,
                decode(pohd.operating_unit_name,'HK_OU-TOPPAN MERRILL IFN LIMITED',pohd.ship_to_location,replace(pohd.ship_to_location,'MRL ','TM ')) ship_to_location,
                --pohd.bill_to_location,
                decode(pohd.operating_unit_name,'HK_OU-TOPPAN MERRILL IFN LIMITED',pohd.bill_to_location,replace(pohd.bill_to_location,'MRL ','TM ')) bill_to_location,
                pohd.agent_name,
                pohd.comments,
                pohd.currency_code,
                (case when pohd.rate_type is not null then 'User' else pohd.rate_type end) rate_type,
                pohd.rate_date,
                pohd.rate,
                term.name,
                'NON-JOB', --attrubite1
                            c_sysdate                                                   creation_date,
                c_user_id                                                   created_by,
                c_sysdate                                                   last_update_date,
                c_user_id                                                   last_updated_by,
                c_login_id                                                  last_update_login
            FROM
                (
                    SELECT
                        pohd.*,
                        ROW_NUMBER()
                        OVER(PARTITION BY interface_header_id
                             ORDER BY seq_num
                        ) row_num
                    FROM
                        xxconv_po pohd
                    WHERE
                            pohd.request_id = c_request_id
                        AND pohd.interface_header_id IS NOT NULL
                        AND NOT EXISTS (
                            SELECT
                                'x'
                            FROM
                                xxconv_po xxpo
                            WHERE
                                    xxpo.request_id = pohd.request_id
                                AND xxpo.interface_header_id = pohd.interface_header_id
                                AND nvl(xxpo.status_flag, 'X') != 'P'
                        )
                )         pohd,
                (
                    SELECT
                        upper(vendor_name) upper_vendor_name,
                        vendor_name
                    FROM
                        ap_suppliers
                    --WHERE nvl(vendor_type_lookup_code, 'XX') != 'EMPLOYEE'
                        --AND employee_id IS NULL
                )         vndr,
                ap_terms  term
            WHERE
                    pohd.row_num = 1
                AND vndr.upper_vendor_name (+) = upper(pohd.vendor_name)
                AND upper(term.name(+)) = upper(pohd.payment_terms)
            );

        n_headers := SQL%rowcount;
        INSERT INTO po_lines_interface (
            interface_header_id,
            interface_line_id,
            line_num,
            shipment_num,
            line_type_id,
            line_type,
            item,
            category,
            item_description,
            vendor_product_num,
            uom_code,
     --unit_of_measure,
                 quantity,
            unit_price,
--     ship_to_organization_code,
            ship_to_location,
            need_by_date,
            promised_date,
            --receive_close_tolerance, -- assigne the value by setup
            --invoice_close_tolerance, -- assigne the value by setup    
--     organization_id,
                 list_price_per_unit,
            days_early_receipt_allowed,
            days_late_receipt_allowed,
            receipt_days_exception_code,
            qty_rcv_tolerance,
            qty_rcv_exception_code,
            allow_substitute_receipts_flag,
            enforce_ship_to_location_code,
            receiving_routing,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login
        )
            ( SELECT
                interface_header_id,
                interface_line_id,
                line_num,
                shipment_num                            shipment_num,
                line_type_id,
                line_type,
                decode(item_segment1
                       || item_segment2
                       || item_segment3, NULL, NULL, item_segment1
                                                     || '.'
                                                     || item_segment2
                                                     || '.'
                                                     || lpad(item_segment3, 6, '0'))          item,
                category,
                item_description,
                vendor_product_num,
                uom_code,--unit_of_measure,
                            quantity,
                unit_price,
--            line_ship_to_org_code  ship_to_organization_code,
                --line_ship_to_location                   ship_to_location,
                decode(operating_unit_name,'HK_OU-TOPPAN MERRILL IFN LIMITED',line_ship_to_location,replace(line_ship_to_location,'MRL ','TM ')) ship_to_location,
                need_by_date,
                promised_date,
                --receive_close_tolerance, -- assigne the value by setup
                --invoice_close_tolerance, -- assigne the value by setup
--            org_id      organization_id,
                            list_price_per_unit,
                days_early_receipt_allowed,
                days_late_receipt_allowed,
                receipt_days_exception_code,
                qty_rcv_tolerance,
                qty_rcv_exception_code,
                allow_substitute_receipts_flag,
                enforce_ship_to_location_code,
                routing_name,
                c_sysdate                               creation_date,
                c_user_id                               created_by,
                c_sysdate                               last_update_date,
                c_user_id                               last_updated_by,
                c_login_id                              last_update_login
            FROM
                (
                    SELECT
                        pohd.*,
                        muom.uom_code,
                        plt.line_type_id,
                        ROW_NUMBER()
                        OVER(PARTITION BY interface_header_id,
                                          interface_line_id
                             ORDER BY seq_num
                        ) row_num
                    FROM
                        xxconv_po  pohd,
                        (
                            SELECT
                                unit_of_measure,
                                uom_code
                            FROM
                                mtl_units_of_measure_vl
                            WHERE
                                disable_date IS NULL
                                OR disable_date > sysdate
                        )          muom,
                        (
                            SELECT
                                *
                            FROM
                                mtl_system_items_kfv
                            WHERE
                                organization_id = 102
                        )          msi,
                        (
                            SELECT
                                line_type,
                                line_type_id
                            FROM
                                po_line_types
                            WHERE
                                inactive_date IS NULL
                                OR inactive_date > sysdate
                        )          plt
                    WHERE
                            pohd.request_id = c_request_id
                        AND upper(pohd.unit_of_measure) = upper(muom.unit_of_measure(+))
                        AND upper(pohd.line_type) = upper(plt.line_type(+))
                        AND pohd.item_segment1
                            || '.'
                            || pohd.item_segment2
                            || '.'
                            || lpad(pohd.item_segment3, 6, '0') = msi.concatenated_segments (+)
                        AND pohd.interface_header_id IS NOT NULL
                        AND pohd.interface_line_id IS NOT NULL
                        AND NOT EXISTS (
                            SELECT
                                'x'
                            FROM
                                xxconv_po xxpo
                            WHERE
                                    xxpo.request_id = pohd.request_id
                                AND xxpo.interface_header_id = pohd.interface_header_id
                                AND nvl(xxpo.status_flag, 'X') != 'P'
                        )
                )
            WHERE
                row_num = 1
            );

        INSERT INTO po_distributions_interface (
            interface_header_id,
            interface_line_id,
            interface_distribution_id,
            quantity_ordered,
            destination_type_code,
--     destination_organization_id,
                 destination_context,
            charge_account_id,
            budget_account_id,
            deliver_to_location,
            deliver_to_person_full_name,
    --PROJECT_RELEATED_FLAG,
                project_accounting_context,
            project_id,
            project,
            task_id,
            task,
            expenditure_type,
            expenditure_organization_id,
            expenditure_organization,
            expenditure_item_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login
        )
            ( SELECT
                interface_header_id,
                interface_line_id,
                interface_distribution_id,
                DIST_QUANTITY_ORDERED                                                                  quantity_ordered,
                upper(destination_type_code)                                              destination_type_code,
--            org_id                 destination_organization_id,
                            upper(destination_type_code)                                              destination_context,
            --charge_account,
                            charge.
                code_combination_id                                                charge_account_id,
            --budget_account,
                            budget.code_combination_id                                                budget_account_id,
                --deliver_to,
                decode(pohd.operating_unit_name,'HK_OU-TOPPAN MERRILL IFN LIMITED',pohd.deliver_to,replace(pohd.deliver_to,'MRL ','TM ')) deliver_to,
                requestor,
            --decode(nvl(project_number,'XX'),'XX','N','Y') PROJECT_RELEATED_FLAG,
                            decode(nvl(project.project_number, 'XX'), 'XX', NULL, 'Yes')                  project_accounting_context,
                project.project_id,
                project.project_number,
                project.task_id,
                project.task_number,
                expenditure_type,
                hou.organization_id,
                org,
                expenditure_item_date,
                c_sysdate                                                                 creation_date,
                c_user_id                                                                 created_by,
                c_sysdate                                                                 last_update_date,
                c_user_id                                                                 last_updated_by,
                c_login_id                                                                last_update_login
            FROM
                xxconv_po  pohd,
                (
                    SELECT
                        concatenated_segments,
                        code_combination_id
                    FROM
                        gl_code_combinations_kfv
                    WHERE
                            detail_budgeting_allowed = 'Y'
                        AND enabled_flag = 'Y'
                        AND sysdate BETWEEN nvl(start_date_active, sysdate) AND nvl(end_date_active, sysdate)
                )          charge,
                (
                    SELECT
                        concatenated_segments,
                        code_combination_id
                    FROM
                        gl_code_combinations_kfv
                    WHERE
                            detail_budgeting_allowed = 'Y'
                        AND enabled_flag = 'Y'
                        AND sysdate BETWEEN nvl(start_date_active, sysdate) AND nvl(end_date_active, sysdate)
                )          budget,
                (
                    SELECT
                        pra.org_id,
                        pra.segment1 project_number,
                        pra.project_id,
                        pt.task_id,
                        pt.task_number
                    FROM
                        pa_projects_all  pra,
                        pa_tasks         pt
                    WHERE
                            pra.project_id = pt.project_id
                        AND pra.template_flag = 'N'
                        AND pra.enabled_flag = 'Y'
                )          project,
                (
                    SELECT
                        *
                    FROM
                        hr_all_organization_units
                    WHERE
                        type = 'SITE'
                )          hou
            WHERE
                    pohd.request_id = c_request_id
                AND pohd.interface_header_id IS NOT NULL
                AND pohd.interface_line_id IS NOT NULL
                AND pohd.interface_distribution_id IS NOT NULL
                AND pohd.charge_account = charge.concatenated_segments (+)
                AND pohd.charge_account = budget.concatenated_segments (+)
                AND pohd.project_number = project.project_number (+)
                AND pohd.task_number = project.task_number (+)
                AND pohd.org_id = project.org_id (+)
                AND pohd.org = hou.name (+)
                AND NOT EXISTS (
                    SELECT
                        'x'
                    FROM
                        xxconv_po xxpo
                    WHERE
                            xxpo.request_id = pohd.request_id
                        AND xxpo.interface_header_id = pohd.interface_header_id
                        AND nvl(xxpo.status_flag, 'X') != 'P'
                )
            );

    --
    -- Commit changes.
    --
            COMMIT;

    --
    -- Import PO.
    --
            IF n_headers > 0 THEN

      --
      -- By Batch ID and OU ID.
      --
                  FOR rec_btch IN (
                SELECT DISTINCT
                    batch_id,
                    org_id
                FROM
                    (
                        SELECT
                            batch_id,
                            org_id,
                            ROW_NUMBER()
                            OVER(PARTITION BY interface_header_id
                                 ORDER BY seq_num
                            ) row_num
                        FROM
                            xxconv_po pohd
                        WHERE
                                pohd.request_id = c_request_id
                            AND pohd.interface_header_id IS NOT NULL
                            AND NOT EXISTS (
                                SELECT
                                    'x'
                                FROM
                                    xxconv_po xxpo
                                WHERE
                                        xxpo.request_id = pohd.request_id
                                    AND xxpo.interface_header_id = pohd.interface_header_id
                                    AND nvl(xxpo.status_flag, 'X') != 'P'
                            )
                    )
                WHERE
                    batch_id IS NOT NULL
                    AND org_id IS NOT NULL
                    AND row_num = 1
                ORDER BY
                    batch_id,
                    org_id
            ) LOOP
                DECLARE
                    n_request_id  NUMBER(15);
                    b_success     BOOLEAN;
                    v_phase       VARCHAR2(30);
                    v_status      VARCHAR2(30);
                    v_dev_phase   VARCHAR2(30);
                    v_dev_status  VARCHAR2(30);
                    v_message     VARCHAR2(240);
                BEGIN

          --
          -- Set OU ID. in request.
          --
          fnd_request.set_org_id(org_id => rec_btch.org_id);

          --
          -- Submit "Import Standard Purchase Orders".
          --
          n_request_id := fnd_request.submit_request(
                            application => 'PO', program => 'POXPOPDOI',
                            description => NULL,
                            start_time => NULL,
                            sub_request => false,
                            argument1 => NULL,              -- Default Buyer
                            argument2 => 'STANDARD',        -- Document Type
                            argument3 => NULL,              -- Document SubType
                            argument4 => 'N',               -- Create or Update Items
                            argument5 => NULL,              -- Create Sourcing Rules
                            argument6 => 'APPROVED',        -- Approval Status
                            argument7 => NULL,              -- Release Generation Method
                            argument8 => rec_btch.batch_id, -- Batch ID
                            argument15 => 'N',               -- Group Lines
                            argument16 => '5000',            -- Batch Size
                            argument17 => 'N');              -- Gather Stats

          --
          -- Check if Concurrent Program successfully submitted.
          --
            IF n_request_id = 0 THEN
                xxconv_common_pkg.append_message(v_abort_msg,'Submission of Concurrent Request "Import Standard Purchase Orders" was failed.');
                xxconv_common_pkg.append_message(v_abort_msg, fnd_message.get);
                RAISE e_abort;
            END IF;

            --
            -- Commit to let Concurrent Manager to process the Request.
            --
            COMMIT;

          --
          -- Waits for request completion.
          --
          b_success := fnd_concurrent.wait_for_request(request_id => n_request_id, 
                                            INTERVAL => 1,
                                            max_wait => 0,
                                            phase => v_phase,
                                            status => v_status,
                                            dev_phase => v_dev_phase,
                                            dev_status => v_dev_status,
                                            message => v_message);

                    IF NOT (
                        v_dev_phase = 'COMPLETE'
                        AND v_dev_status = 'NORMAL'
                    ) THEN
                        xxconv_common_pkg.append_message(v_abort_msg, 'Concurrent Request (ID: '
                                                                      || to_char(n_request_id)
                                                                      || ') "Import Standard Purchase Orders" failed.');
                        RAISE e_abort;
                    END IF;

                END;
            END LOOP;
        END IF;

        --
        -- Update the PO was uploaded.
        --
        update xxconv_po  
        set    status_flag = 'C'
        where  request_id  = c_request_id
        and    status_flag = 'P';

    EXCEPTION
        WHEN e_abort THEN
            ROLLBACK;
            retcode := '2';
            errbuf := substr('Data Conversion: PO failed. ' || v_abort_msg, 1, c_errbuf_max);
            xxconv_common_pkg.write_log('');
            xxconv_common_pkg.write_log('Data Conversion: PO failed.');
            xxconv_common_pkg.write_log(v_abort_msg);
            xxconv_common_pkg.write_log('');
        WHEN OTHERS THEN
            ROLLBACK;
            retcode := '2';
            errbuf := substr('Data Conversion: PO failed. ' || sqlerrm, 1, c_errbuf_max);
            xxconv_common_pkg.write_log('');
            xxconv_common_pkg.write_log('Data Conversion: PO failed.');
            xxconv_common_pkg.write_log(sqlerrm);
            xxconv_common_pkg.write_log('');
    END main;

END xxconv_po_pkg;

/
