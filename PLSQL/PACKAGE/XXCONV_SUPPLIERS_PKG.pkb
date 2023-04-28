--------------------------------------------------------
--  DDL for Package Body XXCONV_SUPPLIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXCONV_SUPPLIERS_PKG" as
/*******************************************************************************
 *
 * Module Name : Payables
 * Package Name: XXCONV_SUPPLIERS_PKG
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

  e_abort       exception;

  c_appl_name   constant varchar2(50) := 'SQLAP';
  --c_resp_key    constant varchar2(50) := 'PAYABLES_MANAGER';
  c_resp_key    constant varchar2(50) := 'XXAP_SETUP';
  c_program_name constant varchar2(50) := 'XXCONV_SUPPLIERS';

  c_newline     constant varchar2(1)  := fnd_global.newline;
  c_msg_length  constant number(15)   := 1000;
  c_errbuf_max  constant number(15)   := 240;
  c_request_id           number(15)   := fnd_global.conc_request_id;
  c_user_id     constant number(15)   := fnd_global.user_id;
  c_login_id    constant number(15)   := fnd_global.login_id;
  c_sysdate     constant date         := sysdate;

    function get_ou_segment1 (p_org_code in varchar2)
    return varchar2 is
        v_segment1 varchar2(200);
    begin
        --
        -- Lookup Operating Unit Segment1.
        --    
        select gcc.segment1
        into v_segment1 
        from financials_system_params_all fspa, hr_operating_units hou, GL_CODE_COMBINATIONS_KFV gcc
        where fspa.org_id = hou.organization_id
        and fspa.accts_pay_code_combination_id = gcc.code_combination_id
        and hou.short_code = p_org_code;

        return v_segment1;
    end;

  procedure main (
    errbuf          out varchar2,
    retcode         out varchar2,
    p_file_path     in  varchar2,
    p_file_name     in  varchar2,
    p_request_id    in  number,    
    p_batch_yn      in  varchar2)
  is

    b_abort      boolean;
    v_abort_msg  varchar2(1000);
    v_error_msg  varchar2(1000);
    v_text       varchar2(1000);

    v_segment1_ou1 varchar2(255);
    v_segment1_ou2 varchar2(255);    

    n_suppliers  number;
    n_sites      number;

  begin

    --
    -- Initialize
    --
    errbuf  := null;
    retcode := '0';

    b_abort     := false;
    v_abort_msg := null;

    xxconv_common_pkg.write_log('Concurrent Request ID = '||c_request_id);

    --
    -- Application Initialize
    --

    XXCONV_COMMON_PKG.APPS_INIT(c_user_id,c_resp_key,c_appl_name);

    if nvl(p_request_id,0) = 0 then
        --
        -- Call SQL Loader to Upload Data to Staging Table
        --
        declare
            n_request_id number;
            v_dev_status varchar2(30);
        begin    
            n_request_id := XXCONV_COMMON_PKG.UPLOAD_DATA(c_request_id,c_program_name,p_file_path,p_file_name);
            if n_request_id = 0 then
                xxconv_common_pkg.append_message(v_abort_msg, 'Submission of Concurrent Request "Data Conversion: '||c_program_name||' (SQL*Loader)" was failed.');
                xxconv_common_pkg.append_message(v_abort_msg, fnd_message.get);
                raise e_abort;
            end if;

            v_dev_status := XXCONV_COMMON_PKG.WAIT_REQUEST(n_request_id);
            if not (v_dev_status = 'COMPLETE') then
                xxconv_common_pkg.append_message(v_abort_msg, 'Concurrent Request (ID: '||to_char(n_request_id)||') "Data Conversion: '||c_program_name||' (SQL*Loader)" failed.');
                raise e_abort;
            end if;            
        end;
    else
        begin
            select distinct request_id
            into c_request_id
            from xxconv_suppliers
            where request_id  = p_request_id;
        exception when others then
            xxconv_common_pkg.append_message(v_abort_msg, 'Request ID ('||c_request_id || ') not found in interface table');
            raise e_abort;
        end;
        c_request_id := p_request_id;
        xxconv_common_pkg.write_log('Re-Run Request ID = '||c_request_id);
    end if;

    --
    -- Set Status Flag to 'P'.
    --
    update xxconv_suppliers
    set    status_flag = 'P'
    where  request_id  = c_request_id;

    --
    -- Lookup Operating Unit ID.
    --
    merge into xxconv_suppliers  supr
    using (
           select supr.request_id,
                  supr.operating_unit_name,
                  hrou.organization_id
           from   (
                   select distinct
                          request_id,
                          operating_unit_name
                   from   xxconv_suppliers
                   where  request_id = c_request_id
                  )  supr,
                  hr_operating_units  hrou
           where  hrou.short_code = upper(supr.operating_unit_name)
          )  hrou
    on    (
               supr.request_id          = hrou.request_id
           and supr.operating_unit_name = hrou.operating_unit_name
          )
    when matched then
      update set supr.org_id = hrou.organization_id;

    --
    -- Lookup Vendor ID and Party ID when related Supplier already exists.
    --
    merge into xxconv_suppliers  supr
    using (
           select supr.request_id,
                  supr.vendor_name,
                  vndr.vendor_id,
                  vndr.party_id
           from   (
                   select distinct
                          request_id,
                          upper(vendor_name)  vendor_name
                   from   xxconv_suppliers
                   where  request_id = c_request_id
                  )  supr,
                  ap_suppliers  vndr
           where  upper(vndr.vendor_name)                  = supr.vendor_name
           --and    nvl(vndr.vendor_type_lookup_code, 'XX') != 'EMPLOYEE'
           --and    vndr.employee_id                        is null
          )  vndr
    on    (
               supr.request_id         = vndr.request_id
           and upper(supr.vendor_name) = vndr.vendor_name
          )
    when matched then
      update set supr.vendor_id = vndr.vendor_id,
                 supr.party_id  = vndr.party_id;

    --
    -- Assign Interface ID.
    --
    for rec_supr in (
                     select vendor_name,
                            request_id,
                            ap_suppliers_int_s.nextval  vendor_interface_id
                     from   (
                             select distinct
                                    upper(vendor_name)  vendor_name,
                                    request_id
                             from   xxconv_suppliers
                             where  request_id   = c_request_id
                             and    vendor_name is not null
                             order by upper(vendor_name)
                            )
                    )
    loop

      update xxconv_suppliers
      set    vendor_interface_id = rec_supr.vendor_interface_id
      where  upper(vendor_name)  = rec_supr.vendor_name
      and    request_id          = rec_supr.request_id;

    end loop;

    for rec_site in (
                     select vendor_interface_id,
                            vendor_site_code,
                            request_id,
                            ap_supplier_sites_int_s.nextval  vendor_site_interface_id
                     from   (
                             select distinct
                                    vendor_interface_id,
                                    vendor_site_code,
                                    request_id
                             from   xxconv_suppliers
                             where  request_id           = c_request_id
                             and    vendor_interface_id is not null
                             and    vendor_site_code    is not null
                             order by vendor_interface_id, vendor_site_code
                            )
                    )
    loop

      update xxconv_suppliers
      set    vendor_site_interface_id = rec_site.vendor_site_interface_id
      where  vendor_interface_id      = rec_site.vendor_interface_id
      and    vendor_site_code         = rec_site.vendor_site_code
      and    request_id               = rec_site.request_id;

    end loop;

    --
    -- Commit changes.
    --
    commit;

    --
    -- Validation.
    --

    xxconv_common_pkg.write_log('Data Conversion: Begin Validation.');
    for rec_site in (
                     select supr.rowid  row_id,
                            supr.seq_num,
                            supr.OPERATING_UNIT_NAME,
                            decode(hrou.organization_id, null, 'N', 'Y')  is_operating_unit_valid,
                            supr.VENDOR_NUMBER,
                            supr.TCC_VENDOR_ID,
                            supr.VENDOR_NAME,
                            vndr.vendor_id,
                            decode(vndr.vendor_id, null, 'N', 'Y')  is_vendor_exist,                            
                            supr.ALTERNATE_VENDOR_NAME,
                            (case when supr.type = 'EMPLOYEE' and emp.employee_num is null then 'N' else 'Y' end)  is_employee_valid,
                            empsup.employee_id,
                            (case when supr.type = 'EMPLOYEE' and empsup.employee_id is not null then 'Y' else 'N' end)  is_employee_supplier_exist,                            
                            supr.TYPE,
                            (case when flv_type.lookup_code is null then 'N' else 'Y' end) is_vendor_type_valid,
                            supr.PAYMENT_METHOD,
                            (case when supr.payment_method is not null and mthd.payment_method_code is null then 'N' else 'Y' end)  is_payment_method_valid,
                            supr.INVOICE_CURRENCY,
                            decode(invcur.currency_code, null, 'N', 'Y')  is_invcur_exist,
                            supr.INVOICE_MATCH_OPTION,
                            supr.PAYMENT_CURRENCY,
                            decode(paycur.currency_code, null, 'N', 'Y')  is_paycur_exist,
                            supr.PAYMENT_PRIORITY,
                            supr.TERMS_NAME,
                            (case when supr.terms_name     is not null and term.term_id             is null then 'N' else 'Y' end)  is_terms_name_valid,                            
                            supr.TERMS_DATE_BASIS,
                            (case when flv_basis.lookup_code is null then 'N' else 'Y' end)  is_terms_basis_valid,    
                            supr.PAY_DATE_BASIS,
                            supr.PAY_GROUP,
                            (case when supr.pay_group is not null and flv_pg.lookup_code is null then 'N' else 'Y' end)  is_pay_group_valid,
                            supr.ALWAYS_TAKE_DISCOUNT,
                            supr.VENDOR_SITE_CODE,
                            supr.PURCHASING_SITE_FLAG,
                            supr.PAYMENT_SITE_FLAG,
                            supr.COUNTRY_CODE,
                            cnty.territory_code,
                            decode(cnty.territory_code, null, 'N', 'Y')  is_country_valid,                            
                            supr.ADDRESS_LINE1,
                            supr.ADDRESS_LINE2,
                            supr.ADDRESS_LINE3,
                            supr.ADDRESS_LINE4,
                            supr.CITY,
                            supr.PROVINCE,
                            supr.POSTAL_CODE,
                            supr.PHONE_AREA_CODE,
                            supr.PHONE,
                            supr.FAX_AREA_CODE,
                            supr.FAX,
                            supr.EMAIL,
                            supr.SITE_LIABILITY_ACCOUNT,
                            xxconv_suppliers_pkg.get_ou_segment1('HK1_OU')||substr(supr.SITE_LIABILITY_ACCOUNT,4) SITE_LIABILITY_ACCOUNT1,
                            acpy1.code_combination_id  accts_pay_account_id1,
                            (case when supr.SITE_LIABILITY_ACCOUNT is not null and acpy1.code_combination_id is null then 'N' else 'Y' end)  is_accts_pay_account_valid1,
                            xxconv_suppliers_pkg.get_ou_segment1('HK2_OU')||substr(supr.SITE_LIABILITY_ACCOUNT,4) SITE_LIABILITY_ACCOUNT2,
                            acpy2.code_combination_id  accts_pay_account_id2,
                            (case when supr.SITE_LIABILITY_ACCOUNT is not null and acpy2.code_combination_id is null then 'N' else 'Y' end)  is_accts_pay_account_valid2,                                                        
                            supr.SITE_PREPAYMENT_ACCOUNT,
                            xxconv_suppliers_pkg.get_ou_segment1('HK1_OU')||substr(supr.SITE_PREPAYMENT_ACCOUNT,4) SITE_PREPAYMENT_ACCOUNT1,
                            prpy1.code_combination_id  prepay_account_id1,
                            (case when supr.SITE_PREPAYMENT_ACCOUNT    is not null and prpy1.code_combination_id is null then 'N' else 'Y' end)  is_prepay_account_valid1,                            
                            xxconv_suppliers_pkg.get_ou_segment1('HK1_OU')||substr(supr.SITE_PREPAYMENT_ACCOUNT,4) SITE_PREPAYMENT_ACCOUNT2,
                            prpy2.code_combination_id  prepay_account_id2,
                            (case when supr.SITE_PREPAYMENT_ACCOUNT    is not null and prpy2.code_combination_id is null then 'N' else 'Y' end)  is_prepay_account_valid2,                            
                            supr.SITE_SHIP_TO_LOCATION,
                            lshp.location_id                                          site_ship_to_location_id,
                            (CASE WHEN supr.site_ship_to_location IS NOT NULL AND lshp.location_id IS NULL THEN 'N' ELSE 'Y' END ) is_site_ship_to_location_valid,                               
                            lshp2.location_id                                          site_ship_to_location_id2,
                            (CASE WHEN supr.site_ship_to_location IS NOT NULL AND lshp2.location_id IS NULL THEN 'N' ELSE 'Y' END ) is_site_ship_to_location_valid2,                               
                            supr.SITE_BILL_TO_LOCATION,
                            lbill.location_id                                          site_bill_to_location_id,
                            (CASE WHEN supr.site_bill_to_location IS NOT NULL AND lbill.location_id IS NULL THEN 'N' ELSE 'Y' END ) is_site_bill_to_location_valid,
                            lbill2.location_id                                         site_bill_to_location_id2,
                            (CASE WHEN supr.site_bill_to_location IS NOT NULL AND lbill2.location_id IS NULL THEN 'N' ELSE 'Y' END ) is_site_bill_to_location_valid2,
                            supr.SITE_PAYMENT_METHOD,
                            (case when supr.site_payment_method is not null and site_mthd.payment_method_code is null then 'N' else 'Y' end)  is_site_payment_method_valid,                            
                            supr.SITE_INVOICE_TOLERANCE,
                            aptt.tolerance_id service_tolerance_id,
                            (case when supr.SITE_INVOICE_TOLERANCE is not null and aptt.tolerance_id is null then 'N' else 'Y' end)  is_tolerance_name_valid,                            
                            supr.SITE_INVOICE_MATCH_OPTION,
                            supr.SITE_INVOICE_CURRENCY,
                            decode(siteinvcur.currency_code, null, 'N', 'Y')  is_site_invcur_exist,                            
                            supr.SITE_SERVICES_TOLERANCE,
                            sert.tolerance_id,
                            (case when supr.SITE_SERVICES_TOLERANCE is not null and sert.tolerance_id is null then 'N' else 'Y' end)  is_service_tolerance_valid,     
                            supr.SITE_PAYMENT_CURRENCY,
                            decode(sitepaycur.currency_code, null, 'N', 'Y')  is_site_paycur_exist,
                            supr.SITE_PAYMENT_PRIORITY,
                            supr.SITE_PAY_GROUP,
                            (case when supr.site_pay_group is not null and flv_spg.lookup_code is null then 'N' else 'Y' end)  is_site_pay_group_valid,
                            supr.SITE_TERMS_NAME,
                            supr.SITE_TERMS_DATE_BASIS,
                            (case when flv_site_basis.lookup_code is null then 'N' else 'Y' end)  is_site_terms_basis_valid,    
                            supr.SITE_PAY_DATE_BASIS,
                            supr.SITE_ALWAYS_TAKE_DISCOUNT,
                            supr.creation_date,
                            supr.request_id
                     from   xxconv_suppliers    supr,
                            hr_operating_units  hrou,
                            (
                             select upper(vendor_name)  vendor_name,
                                    vendor_id,
                                    party_id
                             from   ap_suppliers  vndr
                             --where  nvl(vendor_type_lookup_code, 'XX') != 'EMPLOYEE'
                             --and    employee_id                        is null
                            )  vndr,
                            ap_suppliers            vnd2,
                            ap_tolerance_templates  aptt,
                            ap_tolerance_templates  sert,
                            fnd_territories_tl      cnty,
                            (
                            SELECT apmthds.APPLICATION_ID, pmthds.Payment_Method_Name,pmthds.Payment_Method_Code,pmthds.inactive_date inactive_date,'N' primary_flag 
                            FROM IBY_APPLICABLE_PMT_MTHDS apmthds,IBY_PAYMENT_METHODS_VL pmthds
                            WHERE apmthds.payment_method_Code = pmthds.payment_method_code
                            AND apmthds.Payment_flow = 'DISBURSEMENTS'
                            AND NVL(pmthds.inactive_date,trunc(sysdate+1)) > trunc(sysdate)
                            AND apmthds.APPLICATION_ID = 200
                            AND (apmthds.applicable_type_code = 'PAYEE')
                            AND (apmthds.applicable_value_to is null)                            
                            ) mthd,
                            (
                            SELECT apmthds.APPLICATION_ID, pmthds.Payment_Method_Name,pmthds.Payment_Method_Code,pmthds.inactive_date inactive_date,'N' primary_flag 
                            FROM IBY_APPLICABLE_PMT_MTHDS apmthds,IBY_PAYMENT_METHODS_VL pmthds
                            WHERE apmthds.payment_method_Code = pmthds.payment_method_code
                            AND apmthds.Payment_flow = 'DISBURSEMENTS'
                            AND NVL(pmthds.inactive_date,trunc(sysdate+1)) > trunc(sysdate)
                            AND apmthds.APPLICATION_ID = 200
                            AND (apmthds.applicable_type_code = 'PAYEE')
                            AND (apmthds.applicable_value_to is null)                            
                            ) site_mthd,
                            ap_terms                term,
                            (
                             select concatenated_segments,
                                    code_combination_id
                             from   gl_code_combinations_kfv
                             where  detail_budgeting_allowed = 'Y'
                             and    enabled_flag             = 'Y'
                             and    sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate)
                            )  acpy1,
                            (
                             select concatenated_segments,
                                    code_combination_id
                             from   gl_code_combinations_kfv
                             where  detail_budgeting_allowed = 'Y'
                             and    enabled_flag             = 'Y'
                             and    sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate)
                            )  acpy2,                            
                            (
                             select concatenated_segments,
                                    code_combination_id
                             from   gl_code_combinations_kfv
                             where  detail_budgeting_allowed = 'Y'
                             and    enabled_flag             = 'Y'
                             and    sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate)
                            )  prpy1,
                            (
                             select concatenated_segments,
                                    code_combination_id
                             from   gl_code_combinations_kfv
                             where  detail_budgeting_allowed = 'Y'
                             and    enabled_flag             = 'Y'
                             and    sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate)
                            )  prpy2,                            
                            FND_CURRENCIES invcur,
                            FND_CURRENCIES paycur,
                            FND_CURRENCIES siteinvcur,
                            FND_CURRENCIES sitepaycur,                            
                            FND_LOOKUP_VALUES flv_basis,
                            FND_LOOKUP_VALUES flv_site_basis,
                            (
                            select lookup_code from FND_LOOKUP_VALUES where LOOKUP_TYPE = 'VENDOR TYPE' and language = 'US'
                            ) flv_type,
                            (
                            select lookup_code from FND_LOOKUP_VALUES where LOOKUP_TYPE = 'PAY GROUP' and language = 'US'
                            ) flv_pg,
                            (
                            select lookup_code from FND_LOOKUP_VALUES where LOOKUP_TYPE = 'PAY GROUP' and language = 'US'
                            ) flv_spg,
                            (
                                SELECT location_code,location_id,ship_to_site_flag,bill_to_site_flag
                                FROM hr_locations
                                WHERE (inactive_date IS NULL OR inactive_date > sysdate)
                                AND ship_to_site_flag = 'Y'
                            )                          lshp,
                            (
                                SELECT location_code,location_id,ship_to_site_flag,bill_to_site_flag
                                FROM hr_locations
                                WHERE (inactive_date IS NULL OR inactive_date > sysdate)
                                AND ship_to_site_flag = 'Y'
                            )                          lshp2,                            
                            (
                                SELECT location_code,location_id,ship_to_site_flag,bill_to_site_flag
                                FROM hr_locations
                                WHERE (inactive_date IS NULL OR inactive_date > sysdate)
                                AND bill_to_site_flag = 'Y'
                            )                          lbill,
                            (
                                SELECT location_code,location_id,ship_to_site_flag,bill_to_site_flag
                                FROM hr_locations
                                WHERE (inactive_date IS NULL OR inactive_date > sysdate)
                                AND bill_to_site_flag = 'Y'
                            )                          lbill2,                            
                            HR_EMPLOYEES_CURRENT_V emp,
                            (select vendor_id,vendor_name,employee_id from ap_suppliers where vendor_type_lookup_code = 'EMPLOYEE') empsup
                     where  supr.request_id                = c_request_id
                     and    hrou.short_code            (+) = upper(supr.operating_unit_name)
                     and    vndr.vendor_name           (+) = upper(supr.vendor_name)
                     and    vnd2.segment1              (+) = supr.VENDOR_NUMBER
                     and    aptt.tolerance_name        (+) = supr.SITE_INVOICE_TOLERANCE
                     and    sert.tolerance_name   (+) = supr.SITE_SERVICES_TOLERANCE
                     and    upper(cnty.territory_code  (+)) = upper(supr.COUNTRY_CODE)
                     and    cnty.language              (+) = 'US'
                     --and    mthd.lookup_type           (+) = 'PAYMENT METHOD'
                     --and    mthd.enabled_flag          (+) = 'Y'
                     and    mthd.payment_method_code   (+) = supr.PAYMENT_METHOD
                     --and    site_mthd.lookup_type      (+) = 'PAYMENT METHOD'
                     --and    site_mthd.enabled_flag     (+) = 'Y'
                     and    site_mthd.payment_method_code (+) = supr.SITE_PAYMENT_METHOD                     
                     and    term.name                  (+) = supr.terms_name
                     and    term.enabled_flag          (+) = 'Y'
                     and    acpy1.concatenated_segments (+) = xxconv_suppliers_pkg.get_ou_segment1('HK1_OU')||substr(supr.SITE_LIABILITY_ACCOUNT,4)
                     and    acpy2.concatenated_segments (+) = xxconv_suppliers_pkg.get_ou_segment1('HK2_OU')||substr(supr.SITE_LIABILITY_ACCOUNT,4)
                     and    prpy1.concatenated_segments (+) = xxconv_suppliers_pkg.get_ou_segment1('HK1_OU')||substr(supr.SITE_LIABILITY_ACCOUNT,4)
                     and    prpy2.concatenated_segments (+) = xxconv_suppliers_pkg.get_ou_segment1('HK2_OU')||substr(supr.SITE_LIABILITY_ACCOUNT,4)                     
                     and    invcur.CURRENCY_CODE       (+) = supr.invoice_currency
                     and    paycur.CURRENCY_CODE       (+) = supr.payment_currency
                     and    siteinvcur.CURRENCY_CODE       (+) = supr.site_invoice_currency
                     and    sitepaycur.CURRENCY_CODE       (+) = supr.site_payment_currency                     
                     and    flv_basis.lookup_code      (+) = supr.TERMS_DATE_BASIS
                     and    flv_basis.language      (+) = 'US'
                     and    flv_basis.lookup_type      (+) = 'TERMS DATE BASIS'
                     and    flv_site_basis.lookup_code      (+) = supr.SITE_TERMS_DATE_BASIS
                     and    flv_site_basis.language      (+) = 'US'
                     and    flv_site_basis.lookup_type      (+) = 'TERMS DATE BASIS'
                     and    upper(flv_type.lookup_code (+)) = upper(supr.type)
                     and    flv_pg.lookup_code (+) = supr.pay_group
                     and    flv_spg.lookup_code (+) = supr.site_pay_group
                     AND    lshp.location_code (+) = supr.site_ship_to_location
                     AND    lbill.location_code (+) = supr.site_bill_to_location
                     AND    lshp2.location_code (+) = replace(supr.site_ship_to_location,'MRL ','TM ')
                     AND    lbill2.location_code (+) = replace(supr.site_bill_to_location,'MRL ','TM ')
                     AND    emp.employee_num (+) = supr.ALTERNATE_VENDOR_NAME
                     AND    empsup.employee_id (+) = emp.employee_id 
                    )
    loop

      v_error_msg := null;

      if rec_site.vendor_name is null then

        b_abort := true;
        v_text  := '[Supplier Name] is missing.';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.vendor_site_code is null then

        b_abort := true;
        v_text  := '[Supplier Site Name] is missing.';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.is_vendor_type_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Vendor Type] (VALUE= '||rec_site.type||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;      

      if rec_site.is_employee_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Employee Number] (VALUE= '||rec_site.alternate_vendor_name||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;      

      if rec_site.is_employee_supplier_exist = 'Y' then

        b_abort := true;
        v_text  := 'This [Employee Number] (VALUE= '||rec_site.alternate_vendor_name ||') is already assigned to another supplier.';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;      


/*
      if rec_site.operating_unit_name is null then

        b_abort := true;
        v_text  := '[Operating Unit] is missing.';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.is_operating_unit_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Operating Unit] (VALUE= '||rec_site.operating_unit_name||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;
*/

      if rec_site.is_tolerance_name_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Invoice Tolerance] (VALUE= '||rec_site.SITE_INVOICE_TOLERANCE||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.is_service_tolerance_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Service Tolerance] (VALUE= '||rec_site.SITE_SERVICES_TOLERANCE||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;      
      if rec_site.type <> 'EMPLOYEE' then
          if rec_site.address_line1 is null then

            b_abort := true;
            v_text  := '[Address Line 1] is missing.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);

          end if;

          if rec_site.is_country_valid = 'N' then

            b_abort := true;
            v_text  := 'Invalid [Country] (VALUE= '||rec_site.country_code||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);

          end if;
      end if;  

      if rec_site.is_payment_method_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Payment Method] (VALUE= '||rec_site.payment_method||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.is_site_payment_method_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Site Payment Method] (VALUE= '||rec_site.site_payment_method||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;      

      if rec_site.is_pay_group_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Pay Group] (VALUE= '||rec_site.pay_group||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.is_site_pay_group_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Site Payment Method] (VALUE= '||rec_site.site_pay_group||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;


      if rec_site.invoice_match_option not in ('Purchase Order','Receipt') then

        b_abort := true;
        v_text  := '[Invoice Match Option] (VALUE= '||rec_site.invoice_match_option||') must be "Purchase Order" / "Receipt".';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.site_invoice_match_option not in ('Purchase Order','Receipt') then

        b_abort := true;
        v_text  := '[Site Invoice Match Option] (VALUE= '||rec_site.site_invoice_match_option||') must be "Purchase Order" / "Receipt".';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;      

      if rec_site.is_invcur_exist = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Invoice Currency] (VALUE= '||rec_site.invoice_currency||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.is_paycur_exist = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Payment Currency] (VALUE= '||rec_site.payment_currency||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;       

      if rec_site.is_site_invcur_exist = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Site Invoice Currency] (VALUE= '||rec_site.site_invoice_currency||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.is_site_paycur_exist = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Site Payment Currency] (VALUE= '||rec_site.site_payment_currency||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;             

      if rec_site.is_terms_name_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Payment Terms] (VALUE= '||rec_site.terms_name||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.pay_date_basis not in ('DISCOUNT','DUE') then
        b_abort := true;
        v_text  := '[Pay Date Basis] (VALUE= '||rec_site.pay_date_basis||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);
      end if;

      if rec_site.site_pay_date_basis not in ('DISCOUNT','DUE') then
        b_abort := true;
        v_text  := '[Site Pay Date Basis] (VALUE= '||rec_site.site_pay_date_basis||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);
      end if;

      if rec_site.is_terms_basis_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Terms Date Basis] (VALUE= '||rec_site.terms_date_basis||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.is_site_terms_basis_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Site Terms Date Basis] (VALUE= '||rec_site.site_terms_date_basis||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;      

        IF rec_site.is_site_ship_to_location_valid = 'N' THEN
            b_abort := true;
            v_text := 'Invalid [Site Ship To Location] (VALUE= '|| rec_site.site_ship_to_location|| ').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        END IF;      

        IF rec_site.is_site_ship_to_location_valid2 = 'N' THEN
            b_abort := true;
            v_text := 'Invalid [Site Ship To Location2] (VALUE= '|| replace(rec_site.site_ship_to_location,'MRL ','TM ')|| ').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        END IF;      

        IF rec_site.is_site_bill_to_location_valid = 'N' THEN
            b_abort := true;
            v_text := 'Invalid [Site Bill To Location] (VALUE= '|| rec_site.site_bill_to_location|| ').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        END IF;

        IF rec_site.is_site_bill_to_location_valid2 = 'N' THEN
            b_abort := true;
            v_text := 'Invalid [Site Bill To Location2] (VALUE= '|| replace(rec_site.site_bill_to_location,'MRL ','TM ')|| ').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        END IF;        

      if rec_site.is_accts_pay_account_valid1 = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Liability Account] (VALUE= '||rec_site.SITE_LIABILITY_ACCOUNT1||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.is_prepay_account_valid1 = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Prepayment Account] (VALUE= '||rec_site.SITE_PREPAYMENT_ACCOUNT1||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.is_accts_pay_account_valid2 = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Liability Account] (VALUE= '||rec_site.SITE_LIABILITY_ACCOUNT2||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_site.is_prepay_account_valid2 = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Prepayment Account] (VALUE= '||rec_site.SITE_PREPAYMENT_ACCOUNT2||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;      

      --
      -- Update Error Message.
      --
      if v_error_msg is not null then

        update xxconv_suppliers  site
        set    site.status_flag   = 'E',
               site.error_message = error_message||substr(decode(error_message, null, null, ' | ')||v_error_msg, 1, 1000)
        where  rowid              = rec_site.row_id;

      end if;

    end loop;

    --
    -- Commit Changes.
    --
    commit;

    xxconv_common_pkg.write_log('Data Conversion: End Validation.');

    --
    -- Abort if failed in Validation.
    --
    if b_abort and nvl(upper(p_batch_yn),'Y') = 'Y' then

      raise e_abort;

    end if;

--
-- Abort after Validation.
--
-- return;
--

    --
    -- Populate Supplier interface table.
    --
    insert into ap_suppliers_int
    (
        vendor_interface_id,
        SEGMENT1,
        ATTRIBUTE1,
        VENDOR_NAME,
        VENDOR_NAME_ALT,
        VENDOR_TYPE_LOOKUP_CODE,
        PAYMENT_METHOD_LOOKUP_CODE,
        INVOICE_CURRENCY_CODE,
        MATCH_OPTION,
        PAYMENT_CURRENCY_CODE,
        PAYMENT_PRIORITY,
        TERMS_NAME,
        TERMS_DATE_BASIS,
        PAY_DATE_BASIS_LOOKUP_CODE,
        PAY_GROUP_LOOKUP_CODE,
        ALWAYS_TAKE_DISC_FLAG,  
        employee_id,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by
    )
    (
     select vendor_interface_id,
            vendor_number,
            tcc_vendor_id,
            vendor_name,
            (case when type = 'EMPLOYEE' then null else alternate_vendor_name end) alternate_vendor_name,
            type,
            payment_method,
            invoice_currency,
            decode(invoice_match_option,'Purchase Order','P','Receipt','R'),
            payment_currency,
            payment_priority,
            terms_name,
            terms_date_basis,
            pay_date_basis,
            pay_group,
            always_take_discount,  
            (case when type = 'EMPLOYEE' then employee_id else null end) employee_id,
            c_sysdate,
            c_user_id,
            c_login_id,
            c_sysdate,
            c_user_id
     from   (
                select vendor_interface_id,
                    vendor_number,
                    tcc_vendor_id,
                    vendor_name,
                    alternate_vendor_name,
                    flv_type.lookup_code type,
                    payment_method,
                    invoice_currency,
                    invoice_match_option,
                    payment_currency,
                    payment_priority,
                    terms_name,
                    terms_date_basis,
                    pay_date_basis,
                    pay_group,
                    always_take_discount,
                    employee_id,
                    row_number()
                      over (
                            partition by vendor_interface_id
                            order by seq_num
                           )  row_num
                from   xxconv_suppliers  supr
                        ,HR_EMPLOYEES_CURRENT_V emp
                        ,(                            
                            select lookup_code from FND_LOOKUP_VALUES where LOOKUP_TYPE = 'VENDOR TYPE' and language = 'US'
                         ) flv_type
                where  request_id           = c_request_id
                and    vendor_interface_id is not null
                and    not exists (
                                    select 'x'
                                    from   xxconv_suppliers  xxsp
                                    where  xxsp.request_id          = supr.request_id
                                    and    xxsp.vendor_interface_id = supr.vendor_interface_id
                                    and    (
                                               nvl(xxsp.status_flag, 'X') != 'P'
                                            or xxsp.vendor_id             is not null
                                            )
                                  )
                and   supr.alternate_vendor_name = emp.employee_num (+)                  
                and   upper(supr.type) = upper(flv_type.lookup_code (+))
            )
     where  row_num = 1
    );

    n_suppliers := sql%rowcount;

    --
    -- Populate Supplier Site interface table.
    --
    insert into ap_supplier_sites_int
    (
        vendor_interface_id,
        vendor_id,
        vendor_site_interface_id,
        VENDOR_SITE_CODE,
        PURCHASING_SITE_FLAG,
        PAY_SITE_FLAG,
        --COUNTRY_OF_ORIGIN_CODE,
        COUNTRY,
        ADDRESS_LINE1,
        ADDRESS_LINE2,
        ADDRESS_LINE3,
        ADDRESS_LINE4,
        CITY,
        PROVINCE,
        ZIP,
        AREA_CODE,
        PHONE,
        FAX,
        FAX_AREA_CODE,
        EMAIL_ADDRESS,
        ACCTS_PAY_CODE_COMBINATION_ID,
        PREPAY_CODE_COMBINATION_ID,
        SHIP_TO_LOCATION_CODE,
        BILL_TO_LOCATION_CODE,
        PAYMENT_METHOD_LOOKUP_CODE,
        TOLERANCE_NAME,
        MATCH_OPTION,
        INVOICE_CURRENCY_CODE,
        SERVICES_TOLERANCE_NAME,
        PAYMENT_CURRENCY_CODE,
        PAYMENT_PRIORITY,
        PAY_GROUP_LOOKUP_CODE,
        TERMS_NAME,
        TERMS_DATE_BASIS,
        PAY_DATE_BASIS_LOOKUP_CODE,
        ALWAYS_TAKE_DISC_FLAG,
        org_id,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by
    )
    (
     select site.vendor_interface_id,
            site.vendor_id,
            site.vendor_site_interface_id,
            site.VENDOR_SITE_CODE,
            site.PURCHASING_SITE_FLAG,
            site.PAYMENT_SITE_FLAG,
            site.COUNTRY_CODE,
            site.ADDRESS_LINE1,
            site.ADDRESS_LINE2,
            site.ADDRESS_LINE3,
            site.ADDRESS_LINE4,
            site.CITY,
            site.PROVINCE,
            site.POSTAL_CODE,
            site.PHONE_AREA_CODE,
            site.PHONE,
            site.FAX,
            site.FAX_AREA_CODE,
            site.EMAIL,
            --site.SITE_LIABILITY_ACCOUNT,
            acpy.CODE_COMBINATION_ID,
            --site.SITE_PREPAYMENT_ACCOUNT,
            prpy.CODE_COMBINATION_ID,
            decode(hrou.org_code,'HK2_OU',replace(site.SITE_SHIP_TO_LOCATION,'MRL ','TM '),site.SITE_SHIP_TO_LOCATION) SITE_SHIP_TO_LOCATION,
            decode(hrou.org_code,'HK2_OU',replace(site.SITE_BILL_TO_LOCATION,'MRL ','TM '),site.SITE_BILL_TO_LOCATION) SITE_BILL_TO_LOCATION,
            site.SITE_PAYMENT_METHOD,
            site.SITE_INVOICE_TOLERANCE,
            decode(site.SITE_INVOICE_MATCH_OPTION,'Purchase Order','P','Receipt','R'),
            site.SITE_INVOICE_CURRENCY,
            site.SITE_SERVICES_TOLERANCE,
            site.SITE_PAYMENT_CURRENCY,
            site.SITE_PAYMENT_PRIORITY,
            site.SITE_PAY_GROUP,
            site.SITE_TERMS_NAME,
            site.SITE_TERMS_DATE_BASIS,
            site.SITE_PAY_DATE_BASIS,
            site.SITE_ALWAYS_TAKE_DISCOUNT,
            --site.org_id,
            hrou.organization_id,
            c_sysdate,
            c_user_id,
            c_login_id,
            c_sysdate,
            c_user_id
     from   (
             select site.org_id,
                    site.vendor_interface_id,
                    site.vendor_id,
                    site.vendor_site_interface_id,
                    site.VENDOR_SITE_CODE,
                    site.PURCHASING_SITE_FLAG,
                    site.PAYMENT_SITE_FLAG,
                    site.COUNTRY_CODE,
                    site.ADDRESS_LINE1,
                    site.ADDRESS_LINE2,
                    site.ADDRESS_LINE3,
                    site.ADDRESS_LINE4,
                    site.CITY,
                    site.PROVINCE,
                    site.POSTAL_CODE,
                    site.PHONE_AREA_CODE,
                    site.PHONE,
                    site.FAX_AREA_CODE,
                    site.FAX,
                    site.EMAIL,
                    site.SITE_LIABILITY_ACCOUNT,
                    site.SITE_PREPAYMENT_ACCOUNT,
                    site.SITE_SHIP_TO_LOCATION,
                    site.SITE_BILL_TO_LOCATION,
                    site.SITE_PAYMENT_METHOD,
                    site.SITE_INVOICE_TOLERANCE,
                    site.SITE_INVOICE_MATCH_OPTION,
                    site.SITE_INVOICE_CURRENCY,
                    site.SITE_SERVICES_TOLERANCE,
                    site.SITE_PAYMENT_CURRENCY,
                    site.SITE_PAYMENT_PRIORITY,
                    site.SITE_PAY_GROUP,
                    site.SITE_TERMS_NAME,
                    site.SITE_TERMS_DATE_BASIS,
                    site.SITE_PAY_DATE_BASIS,
                    site.SITE_ALWAYS_TAKE_DISCOUNT,
                    site.request_id,
                    row_number()
                      over (
                            partition by site.org_id,
                                         site.vendor_interface_id,
                                         site.vendor_site_interface_id
                            order by site.seq_num
                           )  row_num
             from   xxconv_suppliers    site,
                    fnd_territories_tl  cnty
             where  site.request_id                    = c_request_id
             and    site.status_flag                   = 'P'
             and    site.vendor_interface_id          is not null
             and    site.vendor_site_interface_id     is not null
             and    upper(cnty.territory_code     (+))  = upper(site.country_code)
             and    cnty.language                 (+)  = 'US'
             /*
             and    not exists (
                                select 'x'
                                from   xxconv_suppliers  xxsp
                                where  xxsp.request_id             = site.request_id
                                and    xxsp.vendor_interface_id    = site.vendor_interface_id
                                and    nvl(xxsp.status_flag, 'X') != 'P'
                               )
             */                  
            )  site,
            (
             select distinct
                    site.vendor_interface_id,
                    site.vendor_site_interface_id,
                    site.request_id,
                    hrou.organization_id,
                    hrou.short_code org_code
             from   xxconv_suppliers    site,
                    hr_operating_units  hrou
             where  site.vendor_interface_id      is not null
             and    site.vendor_site_interface_id is not null
             and    site.request_id               is not null
             and    site.request_id = c_request_id
             and    site.status_flag = 'P'
             and    (
                      (
                        upper(site.operating_unit_name) is null
                        and hrou.short_code             in (
                                                            'HK1_OU',
                                                            'HK2_OU'      
                                                           )
                        )
                     or (
                             upper(site.operating_unit_name)  = hrou.short_code
                        )
                    )
            )  hrou,
            gl_code_combinations_kfv  acpy,
            gl_code_combinations_kfv  prpy
     where  site.row_num                      = 1
     and    hrou.vendor_interface_id      (+) = site.vendor_interface_id
     and    hrou.vendor_site_interface_id (+) = site.vendor_site_interface_id
     --and    hrou.organization_id (+)          = site.org_id
     and    hrou.request_id               (+) = site.request_id
     --and    acpy.concatenated_segments    (+) = site.SITE_LIABILITY_ACCOUNT
     --and    prpy.concatenated_segments    (+) = site.SITE_PREPAYMENT_ACCOUNT
     and    acpy.concatenated_segments    (+) = xxconv_suppliers_pkg.get_ou_segment1(hrou.org_code)||substr(site.SITE_LIABILITY_ACCOUNT,4)
     and    prpy.concatenated_segments    (+) = xxconv_suppliers_pkg.get_ou_segment1(hrou.org_code)||substr(site.SITE_PREPAYMENT_ACCOUNT,4)     
    );

    n_sites := sql%rowcount;

    --
    -- Import Supplier.
    --
    if n_suppliers > 0 then

      declare

        n_request_id  number(15);

        b_success     boolean;
        v_phase       varchar2(30);
        v_status      varchar2(30);
        v_dev_phase   varchar2(30);
        v_dev_status  varchar2(30);
        v_message     varchar2(240);

      begin

        --
        -- Submit "Supplier Open Interface Import".
        --

        --
        -- Set OU ID. in request.
        --
        fnd_request.set_org_id(org_id => 81);

        n_request_id := fnd_request.submit_request (
                          application => 'SQLAP',
                          program     => 'APXSUIMP',
                          description => null,
                          start_time  => null,
                          sub_request => false,
                          argument1   => 'NEW',
                          argument2   => '1000',
                          argument3   => 'N',
                          argument4   => 'N',
                          argument5   => 'N');

        --
        -- Check if Concurrent Program successfully submitted.
        --
        if n_request_id = 0 then

          xxconv_common_pkg.append_message(v_abort_msg, 'Submission of Concurrent Request "Supplier Open Interface Import" was failed.');
          xxconv_common_pkg.append_message(v_abort_msg, fnd_message.get);

          raise e_abort;

        end if;

        --
        -- Commit to let Concurrent Manager to process the Request.
        --
        commit;

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
/*
        if not (v_dev_phase = 'COMPLETE' and v_dev_status = 'NORMAL') then

          xxconv_common_pkg.append_message(v_abort_msg, 'Concurrent Request (ID: '||to_char(n_request_id)||') "Supplier Open Interface Import" failed.');

          raise e_abort;

        end if;
*/
      end;

    end if;

    --
    -- Import Supplier Site.
    --
    if n_sites > 0 then

      --
      -- Import Supplier Site by batch of OU ID.
      --
      update ap_supplier_sites_int
      set    status               = 'PENDING'
      where  nvl(status, 'NEW')   = 'NEW'
      and    vendor_interface_id in (
                                     select vndr.vendor_interface_id
                                     from   xxconv_suppliers  vndr
                                     where  vndr.request_id = c_request_id
                                    );

      --
      -- Commit changes.
      --
      commit;

      for rec_site in (
                        SELECT hr.organization_id org_id, 
                            hr.NAME organization_name
                        FROM hr_operating_units hr
                        WHERE mo_global.check_access(hr.organization_id) = 'Y'
                        ORDER BY org_id
                      )
      loop

        --
        -- Import Supplier Site by batch of OU ID.
        --
        update ap_supplier_sites_int
        set    status               = 'NEW'
        where  org_id               = rec_site.org_id
        and    vendor_interface_id in (
                                       select vndr.vendor_interface_id
                                       from   xxconv_suppliers  vndr
                                       where  vndr.request_id = c_request_id
                                      );

        declare

          n_request_id  number(15);

          b_success     boolean;
          v_phase       varchar2(30);
          v_status      varchar2(30);
          v_dev_phase   varchar2(30);
          v_dev_status  varchar2(30);
          v_message     varchar2(240);

        begin

          --
          -- Set OU ID. in request.
          --
          fnd_request.set_org_id(org_id => rec_site.org_id);

          --
          -- Submit "Supplier Sites Open Interface Import".
          --
          n_request_id := fnd_request.submit_request (
                            application => 'SQLAP',
                            program     => 'APXSSIMP',
                            description => null,
                            start_time  => null,
                            sub_request => false,
                            argument1   => to_char(rec_site.org_id),
                            argument2   => 'NEW',
                            argument3   => '1000',
                            argument4   => 'N',
                            argument5   => 'N',
                            argument6   => 'N');

          --
          -- Check if Concurrent Program successfully submitted.
          --
          if n_request_id = 0 then

            xxconv_common_pkg.append_message(v_abort_msg, 'Submission of Concurrent Request "Supplier Sites Open Interface Import" was failed.');
            xxconv_common_pkg.append_message(v_abort_msg, fnd_message.get);

            raise e_abort;

          end if;

          --
          -- Commit to let Concurrent Manager to process the Request.
          --
          commit;

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
/*
          if not (v_dev_phase = 'COMPLETE' and v_dev_status = 'NORMAL') then

            xxconv_common_pkg.append_message(v_abort_msg, 'Concurrent Request (ID: '||to_char(n_request_id)||') "Supplier Sites Open Interface Import" failed.');

            raise e_abort;

          end if;
*/
        end;

      end loop;

    end if;

    --
    -- Update the Supplier was uploaded.
    --
    update xxconv_suppliers  
    set    status_flag = 'C'
    where  request_id  = c_request_id
    and    status_flag = 'P';

    commit;

  exception
    when e_abort then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: Suppliers failed. '||v_abort_msg, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: Suppliers failed.');
      xxconv_common_pkg.write_log(v_abort_msg);
      xxconv_common_pkg.write_log('');
    when others then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: Suppliers failed. '||sqlerrm, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: Suppliers failed.');
      xxconv_common_pkg.write_log(sqlerrm);
      xxconv_common_pkg.write_log('');

  end main;

end xxconv_suppliers_pkg;


/
