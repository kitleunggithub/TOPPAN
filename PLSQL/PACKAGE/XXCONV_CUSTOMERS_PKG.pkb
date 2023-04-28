--------------------------------------------------------
--  DDL for Package Body XXCONV_CUSTOMERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXCONV_CUSTOMERS_PKG" as
/*******************************************************************************
 *
 * Module Name : Receables
 * Package Name: XXCONV_CUSTOMERS_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-OCT-2020
 *
 * Purpose     : This program will upload Customers.
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung   30-OCT-2020   Initial Release.
 *
 *******************************************************************************/

  e_abort       exception;

  c_appl_name   constant varchar2(50) := 'AR';
  c_resp_key    constant varchar2(50) := 'RECEIVABLES_MANAGER';
  c_program_name constant varchar2(50) := 'XXCONV_CUSTOMERS';

  c_newline     constant varchar2(1)  := fnd_global.newline;
  c_msg_length  constant number(15)   := 1000;
  c_errbuf_max  constant number(15)   := 240;
  c_request_id           number(15)   := fnd_global.conc_request_id;
  c_user_id     constant number(15)   := fnd_global.user_id;
  c_login_id    constant number(15)   := fnd_global.login_id;
  c_sysdate     constant date         := sysdate;

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
            from xxconv_customers
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
    update xxconv_customers
    set    status_flag = 'P'
    where  request_id  = c_request_id;

    --
    -- Lookup Vendor ID and Party ID when related Supplier already exists.
    --
    /*
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
           and    nvl(vndr.vendor_type_lookup_code, 'XX') != 'EMPLOYEE'
           and    vndr.employee_id                        is null
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
    */

    --
    -- Assign ORIG_SYSTEM_CUSTOMER_REF.
    --
    update xxconv_customers
    set ORIG_SYSTEM_CUSTOMER_REF = 'DC'||ACCOUNT_NUMBER
    where ORIG_SYSTEM_CUSTOMER_REF is null;

    --
    -- Assign ORIG_SYSTEM_ADDRESS_REF.
    --
    FOR rec_site IN (
                      select xxcust.*,
                             xxconv_customer_addr_s.nextval nextval
                        from 
                        (
                            select 
                                distinct
                                request_id,
                                account_number cust_key,
                                country_code||'|'||address_line_1 addr_key
                            from xxconv_customers
                            where not (country_code is null
                                 and address_line_1 is null)
                            and request_id = c_request_id         
                            --and ORIG_SYSTEM_ADDRESS_REF is null
                            order by cust_key,addr_key            
                        ) xxcust
                    )
    LOOP

        UPDATE xxconv_customers
        SET ORIG_SYSTEM_ADDRESS_REF = 'A'||lpad(rec_site.nextval,5,'0')
        WHERE  account_number                    = rec_site.cust_key
        AND    country_code||'|'||address_line_1 = rec_site.addr_key
        AND    request_id                        = rec_site.request_id
        --AND    ORIG_SYSTEM_ADDRESS_REF is null
        ;

    END LOOP;                

    --
    -- Assign ORIG_SYSTEM_CONTACT_REF.
    --
    FOR rec_cont IN (
                      select xxcust.*,
                             xxconv_customer_contact_s.nextval nextval
                        from 
                        (
                            select 
                                distinct
                                request_id,
                                account_number cust_key,
                                country_code||'|'||address_line_1 addr_key,
                                contact_last_name||'|'||contact_middle_name||'|'||contact_first_name contact_key
                            from xxconv_customers
                            where not (country_code is null
                                        and address_line_1 is null)
                            and not (contact_last_name is null
                                        and contact_middle_name is null
                                        and contact_first_name is null)
                            and request_id = c_request_id
                            --and ORIG_SYSTEM_CONTACT_REF is null
                            order by cust_key,addr_key,contact_key            
                        ) xxcust
                    )
    LOOP

        UPDATE xxconv_customers
        SET ORIG_SYSTEM_CONTACT_REF = 'C'||lpad(rec_cont.nextval,5,'0')
        WHERE  account_number                    = rec_cont.cust_key
        AND    country_code||'|'||address_line_1 = rec_cont.addr_key
        AND    contact_last_name||'|'||contact_middle_name||'|'||contact_first_name = rec_cont.contact_key
        AND    request_id                        = rec_cont.request_id
        --AND    ORIG_SYSTEM_CONTACT_REF is null
        ;
    END LOOP;                

    --
    -- Assign ORIG_SYSTEM_TELEPHONE_REF.
    --
    FOR rec_cont IN (
                      select xxcust.*,
                             xxconv_customer_contact_s.nextval nextval
                        from 
                        (
                            select 
                                distinct
                                request_id,
                                account_number cust_key,
                                country_code||'|'||address_line_1 addr_key,
                                contact_last_name||'|'||contact_middle_name||'|'||contact_first_name contact_key,
                                tel_phone_number tel_key
                            from xxconv_customers
                            where not (country_code is null
                                        and address_line_1 is null)
                            and not (contact_last_name is null
                                        and contact_middle_name is null
                                        and contact_first_name is null)
                            and tel_phone_number is not null            
                            and request_id = c_request_id   
                            --and ORIG_SYSTEM_TELEPHONE_REF is null
                            order by cust_key,addr_key,contact_key,tel_key            
                        ) xxcust
                    )
    LOOP

        UPDATE xxconv_customers
        SET ORIG_SYSTEM_TELEPHONE_REF = 'P'||lpad(rec_cont.nextval,5,'0')
        WHERE  account_number                    = rec_cont.cust_key
        AND    country_code||'|'||address_line_1 = rec_cont.addr_key
        AND    contact_last_name||'|'||contact_middle_name||'|'||contact_first_name = rec_cont.contact_key
        AND    tel_phone_number                  = rec_cont.tel_key
        AND    request_id                        = rec_cont.request_id
        --AND    ORIG_SYSTEM_TELEPHONE_REF is null
        ;
    END LOOP;                

    --
    -- Assign ORIG_SYSTEM_EMAIL_REF.
    --
    FOR rec_cont IN (
                      select xxcust.*,
                             xxconv_customer_contact_s.nextval nextval
                        from 
                        (
                            select 
                                distinct
                                request_id,
                                account_number cust_key,
                                country_code||'|'||address_line_1 addr_key,
                                contact_last_name||'|'||contact_middle_name||'|'||contact_first_name contact_key,
                                email email_key
                            from xxconv_customers
                            where not (country_code is null
                                        and address_line_1 is null)
                            and not (contact_last_name is null
                                        and contact_middle_name is null
                                        and contact_first_name is null)
                            and email is not null            
                            and request_id = c_request_id
                            --and orig_system_email_ref is null
                            order by cust_key,addr_key,contact_key,email            
                        ) xxcust
                    )
    LOOP

        UPDATE xxconv_customers
        SET ORIG_SYSTEM_EMAIL_REF = 'E'||lpad(rec_cont.nextval,5,'0')
        WHERE  account_number                    = rec_cont.cust_key
        AND    country_code||'|'||address_line_1 = rec_cont.addr_key
        AND    contact_last_name||'|'||contact_middle_name||'|'||contact_first_name = rec_cont.contact_key
        AND    email                             = rec_cont.email_key
        AND    request_id                        = rec_cont.request_id
        --AND    ORIG_SYSTEM_EMAIL_REF is null
        ;
    END LOOP;                

    --
    -- Commit changes.
    --
    commit;

    --
    -- Validation.
    --

    xxconv_common_pkg.write_log('Data Conversion: Begin Validation.');

    for rec_cust in (
                        select cust.rowid,
                                cust.seq_num,
                                cust.OPERATING_UNIT_NAME,
                                decode(hrou.organization_id, null, 'N', 'Y')  is_operating_unit_valid,
                                cust.account_number,
                                decode(hca.account_number, null, 'N', 'Y')  is_acc_exist,
                                cust.account_type,
                                cust.customer_name,
                                decode(hcu.customer_name, null, 'N', 'Y')  is_cust_name_exist,
                                cust.profile_class,
                                decode(hcpc.name, null, 'N', 'Y')  is_profile_class_valid,    
                                cust.payment_term,
                                case when (cust.payment_term is not null and rt.name is null) then 'N' else 'Y' end is_payment_term_valid,        
                                cust.primary_sales_rep,
                                case when (cust.primary_sales_rep is not null and sales1.resource_id is null) then 'N' else 'Y' end is_sales1_valid,                
                                cust.primary_split,
                                case when TRIM(replace(translate(cust.primary_split, '0123456789', ' '),'.','')) is null then 'Y' else 'N' end is_sales1_split_valid,
                                cust.sales_rep2,
                                case when (cust.sales_rep2 is not null and sales2.resource_id is null) then 'N' else 'Y' end is_sales2_valid,                
                                cust.split2,
                                case when TRIM(replace(translate(cust.split2, '0123456789', ' '),'.','')) is null then 'Y' else 'N' end is_sales2_split_valid,
                                cust.sales_rep3,
                                case when (cust.sales_rep3 is not null and sales3.resource_id is null) then 'N' else 'Y' end is_sales3_valid,                
                                cust.split3,
                                case when TRIM(replace(translate(cust.split3, '0123456789', ' '),'.','')) is null then 'Y' else 'N' end is_sales3_split_valid,
                                cust.sales_rep4,
                                case when (cust.sales_rep4 is not null and sales4.resource_id is null) then 'N' else 'Y' end is_sales4_valid,                
                                cust.split4,
                                case when TRIM(replace(translate(cust.split4, '0123456789', ' '),'.','')) is null then 'Y' else 'N' end is_sales4_split_valid,
                                cust.sales_rep5,
                                case when (cust.sales_rep5 is not null and sales5.resource_id is null) then 'N' else 'Y' end is_sales5_valid,                
                                cust.split5,
                                case when TRIM(replace(translate(cust.split5, '0123456789', ' '),'.','')) is null then 'Y' else 'N' end is_sales5_split_valid,
                                cust.credit_rating,
                                case when (cust.credit_rating is not null and ffv_rating.flex_value is null) then 'N' else 'Y' end is_rating_valid,        
                                cust.status,
                                case when (cust.status is not null and flv_status.lookup_code is null) then 'N' else 'Y' end is_status_valid,                
                                cust.credit_limit,
                                case when TRIM(replace(translate(cust.credit_limit, '0123456789', ' '),'.','')) is null then 'Y' else 'N' end is_credit_limit_valid,      
                                cust.credit_period,
                                case when TRIM(translate(cust.credit_period, '0123456789', ' ')) is null then 'Y' else 'N' end is_credit_period_valid,     
                                cust.country_code,
                                decode(cnty.territory_code, null, 'N', 'Y')  is_country_valid,  
                                cust.address_line_1,
                                decode(cust_site.account_number, null, 'N', 'Y')  is_cust_site_exist,
                                cust.purpose,
                                cust.PRIMARY_FLAG,
                                decode(alv_site_use.meaning, null, 'N', 'Y') is_site_use_code_vaild,
                                cust.tel_country_code,
                                case when (cust.tel_country_code is not null and tel_cnty.phone_country_code is null) then 'N' else 'Y' end  is_tel_country_valid,
                                cust.CONTACT_FIRST_NAME,
                                cust.CONTACT_MIDDLE_NAME,
                                cust.CONTACT_LAST_NAME,
                                cust.CONTACT_JOB_TITLE,
                                cust.CONTACT_NUMBER,
                                cust.EMAIL,
                                cust.EMAIL_PRIMARY_FLAG,
                                cust.TEL_AREA_CODE,
                                cust.TEL_PHONE_NUMBER,
                                cust.TEL_PRIMARY_FLAG                                
                        from xxconv_customers cust,
                            hr_operating_units  hrou,
                            hz_cust_accounts hca,
                            (
                            select distinct hp.party_name customer_name
                            from hz_cust_accounts hca, hz_parties hp
                            where hp.party_id  = hca.party_id
                            ) hcu,
                            HZ_CUST_PROFILE_CLASSES hcpc,
                            RA_TERMS rt,
                            (
                            SELECT RESOURCE_NAME,RESOURCE_ID
                            FROM JTF_RS_DEFRESOURCES_V
                            WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
                            ORDER BY resource_name         
                            ) sales1,
                            (
                            SELECT RESOURCE_NAME,RESOURCE_ID
                            FROM JTF_RS_DEFRESOURCES_V
                            WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
                            ORDER BY resource_name         
                            ) sales2,
                            (
                            SELECT RESOURCE_NAME,RESOURCE_ID
                            FROM JTF_RS_DEFRESOURCES_V
                            WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
                            ORDER BY resource_name         
                            ) sales3,
                            (
                            SELECT RESOURCE_NAME,RESOURCE_ID
                            FROM JTF_RS_DEFRESOURCES_V
                            WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
                            ORDER BY resource_name         
                            ) sales4,
                            (
                            SELECT RESOURCE_NAME,RESOURCE_ID
                            FROM JTF_RS_DEFRESOURCES_V
                            WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
                            ORDER BY resource_name         
                            ) sales5,
                            (
                            SELECT ffv.flex_value, ffvt.description flex_description, ffv.enabled_flag
                            FROM fnd_flex_value_sets ffvs , fnd_flex_values ffv , fnd_flex_values_tl ffvt
                            WHERE ffvs.flex_value_set_id = ffv.flex_value_set_id
                            and ffv.flex_value_id = ffvt.flex_value_id
                            AND ffvt.language = 'US'
                            and ffv.enabled_flag = 'Y'
                            and flex_value_set_name = 'XXAR_CREDIT_RATING'
                            ) ffv_rating,
                            (
                            SELECT MEANING,LOOKUP_CODE 
                            FROM FND_LOOKUP_VALUES
                            WHERE lookup_type = 'ACCOUNT_STATUS' 
                            AND enabled_flag = 'Y' 
                            AND NVL(end_date_active,SYSDATE) >= SYSDATE
                            ) flv_status,
                            fnd_territories_tl cnty,
                            (select distinct phone_country_code from hz_phone_country_codes) tel_cnty,
                            (
                            select lookup_code,meaning from ar_lookups where lookup_type = 'SITE_USE_CODE' and enabled_flag = 'Y'
                            ) alv_site_use,
                            (
                                select distinct hca.account_number, hl.country, hl.address1
                                from
                                       ar.hz_parties              hp
                                     , ar.hz_party_sites          hps
                                     , ar.hz_cust_accounts        hca
                                     , ar.hz_cust_acct_sites_all     hcas
                                     , ar.hz_cust_site_uses_all      hcsu
                                     , ar.hz_locations           hl
                                     , HR.HR_ALL_ORGANIZATION_UNITS     ho
                                where hp.party_id              = hca.party_id
                                   AND hp.party_id              = hps.party_id
                                   AND hca.cust_account_id      = hcas.cust_account_id
                                   AND hcas.party_site_id       = hps.party_site_id
                                   AND hcsu.cust_acct_site_id   = hcas.cust_acct_site_id
                                   AND hcsu.site_use_code       = 'BILL_TO'  -- or 'SHIP_TO'
                                   AND hps.location_id          = hl.location_id
                                   and hcas.org_id = ho.ORGANIZATION_ID
                                and hp.STATUS = 'A'
                                and hps.STATUS = 'A'
                                and hca.STATUS = 'A'
                                and hcas.STATUS = 'A'
                                and hcsu.STATUS = 'A'                            
                            ) cust_site
                        where  cust.request_id                = c_request_id
                        and    hrou.short_code            (+) = upper(cust.operating_unit_name)
                        and    hca.account_number         (+) = cust.account_number
                        and    hcu.customer_name          (+) = cust.customer_name
                        and    hcpc.name                  (+) = cust.profile_class
                        and    upper(rt.name                    (+)) = upper(cust.payment_term)
                        and    sales1.resource_name       (+) = trim(cust.primary_sales_rep)
                        and    sales2.resource_name       (+) = trim(cust.sales_rep2)
                        and    sales3.resource_name       (+) = trim(cust.sales_rep3)
                        and    sales4.resource_name       (+) = trim(cust.sales_rep4)
                        and    sales5.resource_name       (+) = trim(cust.sales_rep5)
                        and    ffv_rating.flex_value      (+) = cust.credit_rating
                        and    flv_status.lookup_code     (+) = cust.status
                        and    upper(cnty.territory_code  (+))= upper(cust.COUNTRY_CODE)
                        and    tel_cnty.phone_country_code  (+)= cust.TEL_COUNTRY_CODE
                        and    alv_site_use.lookup_code       (+) = cust.purpose
                        and    cust_site.account_number       (+) = cust.account_number
                        and    cust_site.country       (+) = cust.COUNTRY_CODE
                        and    cust_site.address1       (+) = cust.ADDRESS_LINE_1
                    )
    loop

        v_error_msg := null;

        -- TM Logic
        if rec_cust.account_type not in ('External') then
            b_abort := true;
            v_text  := '[Account Type] (VALUE= '||rec_cust.account_type||') must be External.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);        
        end if;

        if rec_cust.purpose not in ('BILL_TO') then
            b_abort := true;
            v_text  := '[Purpose] (VALUE= '||rec_cust.purpose||') must be "BILL_TO".';
            xxconv_common_pkg.append_message(v_error_msg, v_text);        
        end if;
/*
        if rec_cust.PRIMARY_FLAG not in ('Y') then
            b_abort := true;
            v_text  := '[Primary Flag] (VALUE= '||rec_cust.primary_flag||') must be "Y".';
            xxconv_common_pkg.append_message(v_error_msg, v_text);        
        end if;
*/        
        -- end TM Logic
/*
        if rec_cust.is_acc_exist = 'Y' then
            b_abort := true;
            v_text  := '[Customer Account Number] (VALUE= '||rec_cust.account_number||') already exist.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;
*/

        if rec_cust.is_cust_site_exist = 'Y' then
            b_abort := true;
            v_text  := '[Country] (VALUE= '||rec_cust.country_code||') [Address Line 1] (VALUE= '||rec_cust.address_line_1||') customer site already exist.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        if rec_cust.account_type not in ('External','Internal') then
            b_abort := true;
            v_text  := '[Account Type] (VALUE= '||rec_cust.account_type||') must be Internal or External.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);        
        end if;
/*
        if rec_cust.is_cust_name_exist = 'Y' then
            b_abort := true;
            v_text  := '[Customer Name] (VALUE= '||rec_cust.customer_name||') already exist.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if; 
*/
        if rec_cust.is_profile_class_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Profile Class] (VALUE= '||rec_cust.profile_class||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;    

        if rec_cust.is_payment_term_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Payment Term] (VALUE= '||rec_cust.payment_term||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;            

        if rec_cust.is_sales1_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Rep 1] (VALUE= '||rec_cust.primary_sales_rep||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;            
        if rec_cust.is_sales2_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Rep 2] (VALUE= '||rec_cust.sales_rep2||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;            
        if rec_cust.is_sales3_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Rep 3] (VALUE= '||rec_cust.sales_rep3||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;            
        if rec_cust.is_sales4_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Rep 4] (VALUE= '||rec_cust.sales_rep4||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;            
        if rec_cust.is_sales5_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Rep 5] (VALUE= '||rec_cust.sales_rep5||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;            

        if rec_cust.is_sales1_split_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Split 1] (VALUE= '||rec_cust.primary_split||'), it must be number.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;
        if rec_cust.is_sales2_split_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Split 2] (VALUE= '||rec_cust.split2||'), it must be number.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;        
        if rec_cust.is_sales3_split_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Split 3] (VALUE= '||rec_cust.split3||'), it must be number.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;        
        if rec_cust.is_sales4_split_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Split 4] (VALUE= '||rec_cust.split4||'), it must be number.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;        
        if rec_cust.is_sales5_split_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Split 5] (VALUE= '||rec_cust.split5||'), it must be number.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;        

        if rec_cust.is_rating_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Credit Rating] (VALUE= '||rec_cust.credit_rating||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;    

        if rec_cust.is_status_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Status] (VALUE= '||rec_cust.status||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;    

        if rec_cust.is_credit_limit_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Credit Limit] (VALUE= '||rec_cust.credit_limit||'), it must be number.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;    

        if rec_cust.is_credit_period_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Credit Period] (VALUE= '||rec_cust.credit_period||'), it must be number.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if; 

        if rec_cust.address_line_1 is null then
            b_abort := true;
            v_text  := '[Address Line 1] missing.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if; 

        if rec_cust.is_country_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Country Code] (VALUE= '||rec_cust.country_code||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;    

        if rec_cust.is_site_use_code_vaild = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Purpose] (VALUE= '||rec_cust.purpose||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;    

        if rec_cust.is_tel_country_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Telephone Country Code] (VALUE= '||rec_cust.tel_country_code||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;            

        if not (rec_cust.CONTACT_FIRST_NAME is null and 
                rec_cust.CONTACT_MIDDLE_NAME is null and 
                rec_cust.CONTACT_LAST_NAME is null and 
                rec_cust.CONTACT_JOB_TITLE is null and 
                rec_cust.CONTACT_NUMBER is null) then

            if rec_cust.CONTACT_LAST_NAME is null then
                b_abort := true;
                v_text  := '[Contact Last Name] is required.';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            end if;
        end if;

/*
        if not (rec_cust.EMAIL is null and 
                rec_cust.EMAIL_PRIMARY_FLAG is null) then

            if rec_cust.EMAIL is null then
                b_abort := true;
                v_text  := '[Email] missing.';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            end if;
        end if;
*/
        if not (rec_cust.TEL_COUNTRY_CODE is null and 
                rec_cust.TEL_AREA_CODE is null and
                rec_cust.TEL_PHONE_NUMBER is null and
                rec_cust.TEL_AREA_CODE is null) then

            if rec_cust.TEL_PHONE_NUMBER is null then
                b_abort := true;
                v_text  := '[Telephone Number] missing.';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            end if;
        end if;





        --
        -- Update Error Message.
        --
        if v_error_msg is not null then

            update xxconv_customers cust
            set    cust.status_flag   = 'E',
                    cust.error_message = error_message||substr(decode(error_message, null, null, ' | ')||v_error_msg, 1, 1000)
            where  rowid              = rec_cust.rowid;

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
    if b_abort and upper(p_batch_yn) = 'Y' then

      raise e_abort;

    end if;

    --
    -- Populate Customer Profile table.
    --
    INSERT INTO ar.ra_customer_profiles_int_all
    (
        orig_system_customer_ref,
        insert_update_flag,
        customer_profile_class_name,
        STANDARD_TERM_NAME,
        credit_hold,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by,
        org_id
    )
    select distinct orig_system_customer_ref orig_system_customer_ref,
            'I' insert_update_flag,
            profile_class customer_profile_class_name,
            --payment_term STANDARD_TERM_NAME,
            rt.name STANDARD_TERM_NAME,
            'N' credit_hold,
            c_sysdate,
            c_user_id,
            c_login_id,
            c_sysdate,
            c_user_id,
            81 org_id        
    from xxconv_customers cust
        ,RA_TERMS rt
    where request_id = c_request_id
    and upper(cust.payment_term) = upper(rt.name                    (+))
    and orig_system_customer_ref not in
    (
        select ORIG_SYSTEM_REFERENCE from hz_cust_accounts  
    )
    ;

    --n_suppliers := sql%rowcount;

    --
    -- Populate Customer Site interface table.
    --
    insert into ar.ra_customers_interface_all
    (
        orig_system_customer_ref,
        orig_system_address_ref,
        customer_name,
        CUSTOMER_NAME_PHONETIC,
        customer_number,
        CUSTOMER_TYPE, --R for EXTERNAL, I for INTERNAL
        customer_attribute1,customer_attribute2,customer_attribute3,
        customer_attribute4,customer_attribute5,customer_attribute6,
        customer_attribute7,customer_attribute8,customer_attribute9,
        customer_attribute10,customer_attribute11,customer_attribute12,
        customer_attribute13,customer_attribute14,customer_attribute15,
        customer_attribute16,customer_attribute17,
        PARTY_NUMBER,
        ADDRESS_ATTRIBUTE1,
        country,
        address1,
        address2,
        address3,
        address4,
        city,
        county,
        state,
        province,
        postal_code,
        site_use_code,
        location,
        primary_site_use_flag,
        customer_status,
        insert_update_flag,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by,
        org_id
    )
    select distinct
        site.orig_system_customer_ref,           -- orig_system_customer_ref
        site.orig_system_customer_ref||'-'||hrou.organization_id||'-'||hrou.orig_system_address_ref orig_system_address_ref,-- orig_system_address_ref, must be the same that BILL_TO have
        site.CUSTOMER_NAME,             -- customer_name
        site.NAME_PRONUNCIATION,             -- name pronunciation
        site.ACCOUNT_NUMBER,            -- customer_number if automatic customer number is no
        DECODE(UPPER(ACCOUNT_TYPE),'EXTERNAL','R','INTERNAL','I'), -- Account Type
        site.sales1_id,site.PRIMARY_SPLIT,site.sales2_id,  -- attribute1,attribute2,attribute3
        site.SPLIT2,site.sales3_id,site.SPLIT3,         -- attribute4,attribute5,attribute6
        site.sales4_id,site.SPLIT4,site.sales5_id,         -- attribute7,attribute8,attribute9
        site.SPLIT5,site.STOCK_CODE,to_char(site.CUSTOMER_SINCE,'YYYY/MM/DD HH24:MI:SS'), -- attribute10,attribute11,attribute12
        site.CREDIT_RATING,site.CREDIT_LIMIT,site.CREDIT_PERIOD,              -- attribute13,attribute14,attribute15
        site.STATUS,REMARK,           -- attribute16,attribute17
        null party_number   ,                 -- Party Number/Registry ID
        site.SITE_NUMBER,
        site.COUNTRY_CODE,                     -- country
        site.ADDRESS_LINE_1,              -- address1
        site.ADDRESS_LINE_2,                     -- address2
        site.ADDRESS_LINE_3,                     -- address3
        site.ADDRESS_LINE_4,                     -- address4
        site.CITY,              -- city
        site.COUNTY,              -- county
        site.STATE,                     -- state
        site.PROVINCE,                     -- provice
        site.POSTAL_CODE,                  -- postal_code
        site.site_use_code,                -- SITE USE/Purpose
        NULL location,                     -- location if autositenumber is no
        site.PRIMARY_FLAG,             -- primary_site_use_flag
        'A' customer_staus,                      -- customer_staus
        'I' insert_update_flag,                      -- insert_update_flag
        c_sysdate,
        c_user_id,
        c_login_id,
        c_sysdate,
        c_user_id,
        hrou.organization_id                      -- org_id
    from 
        (
         select 
                row_number()
                  over (
                        partition by site.ORIG_SYSTEM_CUSTOMER_REF,
                                     site.ORIG_SYSTEM_ADDRESS_REF
                        order by site.seq_num
                       )  row_num,
                site.*,
                sales1.resource_id sales1_id,
                sales2.resource_id sales2_id,
                sales3.resource_id sales3_id,
                sales4.resource_id sales4_id,
                sales5.resource_id sales5_id,
                alv_site_use.lookup_code site_use_code
         from   xxconv_customers    site,
        (
        select lookup_code,meaning from ar_lookups where lookup_type = 'SITE_USE_CODE' and enabled_flag = 'Y'
        ) alv_site_use,         
         (
            SELECT RESOURCE_NAME,RESOURCE_ID
            FROM JTF_RS_DEFRESOURCES_V
            WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
            ORDER BY resource_name         
         ) sales1,
         (
            SELECT RESOURCE_NAME,RESOURCE_ID
            FROM JTF_RS_DEFRESOURCES_V
            WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
            ORDER BY resource_name         
         ) sales2,
         (
            SELECT RESOURCE_NAME,RESOURCE_ID
            FROM JTF_RS_DEFRESOURCES_V
            WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
            ORDER BY resource_name         
         ) sales3,
         (
            SELECT RESOURCE_NAME,RESOURCE_ID
            FROM JTF_RS_DEFRESOURCES_V
            WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
            ORDER BY resource_name         
         ) sales4,
         (
            SELECT RESOURCE_NAME,RESOURCE_ID
            FROM JTF_RS_DEFRESOURCES_V
            WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
            ORDER BY resource_name         
         ) sales5
         where trim(site.primary_sales_rep) = sales1.resource_name (+)
         and trim(site.sales_rep2) = sales2.resource_name (+)
         and trim(site.sales_rep3) = sales3.resource_name (+)
         and trim(site.sales_rep4) = sales4.resource_name (+)
         and trim(site.sales_rep5) = sales5.resource_name (+)
         and site.purpose = alv_site_use.lookup_code (+)
         and request_id = c_request_id
        ) site,
        (
         select distinct
                site.orig_system_customer_ref,           -- orig_system_customer_ref
                site.orig_system_address_ref orig_system_address_ref,-- orig_system_address_ref, must be the same that BILL_TO have
                site.request_id,
                hrou.organization_id,
                hrou.short_code org_code
         from   xxconv_customers    site,
                hr_operating_units  hrou
         where  1=1
         --and    site.ORIG_SYSTEM_CUSTOMER_REF      is not null
         --and    site.ORIG_SYSTEM_ADDRESS_REF is not null
         and    site.request_id = c_request_id
         --and    site.status_flag = 'P'
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
        ) hrou
    where site.orig_system_customer_ref = hrou.orig_system_customer_ref
    and site.orig_system_address_ref = hrou.orig_system_address_ref
    and site.request_id = hrou.request_id
    and site.row_num = 1
    ;

    --n_sites := sql%rowcount;

    --
    -- Populate Customer Contact and Telephone interface table.
    --

    insert into ar.ra_contact_phones_int_all
    (
     ORIG_SYSTEM_CONTACT_REF
    ,ORIG_SYSTEM_TELEPHONE_REF
    ,ORIG_SYSTEM_CUSTOMER_REF
    ,ORIG_SYSTEM_ADDRESS_REF
    ,INSERT_UPDATE_FLAG
    ,CONTACT_FIRST_NAME
    --,CONTACT_MIDDLE_NAME
    ,CONTACT_LAST_NAME
    --,CONTACT_TITLE
    ,CONTACT_JOB_TITLE
    ,CONTACT_POINT_TYPE
    ,PHONE_COUNTRY_CODE
    ,TELEPHONE
    ,TELEPHONE_TYPE
    ,TELEPHONE_AREA_CODE
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,creation_date
    ,created_by
    --,EMAIL_ADDRESS
    ,ORG_ID
    )
    select distinct
    cont.orig_system_customer_ref||'-'||hrou.organization_id||'-'||cont.orig_system_address_ref||'-'||cont.orig_system_contact_ref ORIG_SYSTEM_CONTACT_REF,         -- ORIG_SYSTEM_CONTACT_REF
    case when cont.orig_system_telephone_ref is not null then
        cont.orig_system_customer_ref||'-'||hrou.organization_id||'-'||cont.orig_system_address_ref||'-'||cont.orig_system_contact_ref||'-'||cont.orig_system_telephone_ref
    else null end ORIG_SYSTEM_TELEPHONE_REF,        -- ORIG_SYSTEM_TELEPHONE_REF Change it if the phone number is different    
    cont.orig_system_customer_ref,           -- orig_system_customer_ref
    cont.orig_system_customer_ref||'-'||hrou.organization_id||'-'||hrou.orig_system_address_ref orig_system_address_ref,-- orig_system_address_ref, must be the same that BILL_TO have
    'I' INSERT_UPDATE_FLAG,                -- INSERT_UPDATE_FLAG
    CONTACT_FIRST_NAME CONTACT_FIRST_NAME,         -- CONTACT_FIRST_NAME
    --CONTACT_MIDDLE_NAME CONTACT_MIDDLE_NAME, -- CONTACT_MIDDLE_NAME
    CONTACT_LAST_NAME CONTACT_LAST_NAME,        -- CONTACT_LAST_NAME
    --'MR.' CONTACT_TITLE,             -- CONTACT_TITLE must be exist in ar_lookups lookup_type = CONTACT_TITLE
    CONTACT_JOB_TITLE CONTACT_JOB_TITLE,         -- CONTACT_JOB_TITLE meaning must be exist in ar_lookups lookup_type = RESPONSIBILITY
    case when cont.orig_system_telephone_ref is not null then
    'PHONE' 
    else null end CONTACT_POINT_TYPE,    -- CONTACT_POINT_TYPE - PHONE/EMAIL
    case when cont.orig_system_telephone_ref is not null then 
    TEL_COUNTRY_CODE 
    else null end PHONE_COUNTRY_CODE, -- PHONE_COUNTRY_CODE
    case when cont.orig_system_telephone_ref is not null then 
    TEL_PHONE_NUMBER 
    else null end TELEPHONE,         -- TELEPHONE
    case when cont.orig_system_telephone_ref is not null then
    'GEN' 
    else null end TELEPHONE_TYPE,             -- TELEPHONE_TYPE be exist in ar_lookups lookup_type = PHONE_LINE_TYPE
    case when cont.orig_system_telephone_ref is not null then
    TEL_AREA_CODE 
    else null end TELEPHONE_AREA_CODE,             -- TELEPHONE_AREA_CODE
    c_sysdate,
    c_user_id,
    c_login_id,
    c_sysdate,
    c_user_id,
    hrou.organization_id                      -- org_id
    from 
        (
         select 
                row_number()
                  over (
                        partition by cont.ORIG_SYSTEM_CUSTOMER_REF,
                                     cont.ORIG_SYSTEM_ADDRESS_REF,
                                     cont.ORIG_SYSTEM_CONTACT_REF,
                                     cont.ORIG_SYSTEM_TELEPHONE_REF
                        order by cont.seq_num
                       )  row_num,             
                cont.*            
         from   xxconv_customers    cont 
        ) cont,
        (
         select distinct
                cont.orig_system_customer_ref,           -- orig_system_customer_ref
                cont.ORIG_SYSTEM_ADDRESS_REF,
                cont.ORIG_SYSTEM_CONTACT_REF,
                cont.ORIG_SYSTEM_TELEPHONE_REF,
                /*
                hrou.organization_id||'-'||cont.orig_system_address_ref orig_system_address_ref,-- orig_system_address_ref, must be the same that BILL_TO have
                hrou.organization_id||'-'||cont.orig_system_address_ref||'-'||cont.orig_system_contact_ref,-- orig_system_cont_ref
                hrou.organization_id||'-'||cont.orig_system_address_ref||'-'||cont.orig_system_contact_ref||cont.orig_system_telephone_ref,-- orig_system_cont_ref
                */
                cont.request_id,
                hrou.organization_id,
                hrou.short_code org_code
         from   xxconv_customers    cont,
                hr_operating_units  hrou
         where  1=1
         and    cont.request_id = c_request_id
         --and    cont.status_flag = 'P'
         and    (
                  (
                    upper(cont.operating_unit_name) is null
                    and hrou.short_code             in (
                                                        'HK1_OU',
                                                        'HK2_OU'      
                                                       )
                    )
                 or (
                         upper(cont.operating_unit_name)  = hrou.short_code
                    )
                )
        ) hrou
    where cont.orig_system_customer_ref = hrou.orig_system_customer_ref
    and cont.orig_system_address_ref = hrou.orig_system_address_ref
    and nvl(cont.ORIG_SYSTEM_TELEPHONE_REF,'XX') = nvl(hrou.ORIG_SYSTEM_TELEPHONE_REF,'XX')
    and cont.orig_system_contact_ref is not null
    and cont.row_num = 1;

    --
    -- Populate Customer Contact Email interface table.
    --

    insert into ar.ra_contact_phones_int_all
    (
     ORIG_SYSTEM_CONTACT_REF
    ,ORIG_SYSTEM_TELEPHONE_REF
    ,ORIG_SYSTEM_CUSTOMER_REF
    ,ORIG_SYSTEM_ADDRESS_REF
    ,INSERT_UPDATE_FLAG
    ,CONTACT_FIRST_NAME
    --,CONTACT_MIDDLE_NAME
    ,CONTACT_LAST_NAME
    --,CONTACT_TITLE
    ,CONTACT_JOB_TITLE
    ,CONTACT_POINT_TYPE
    ,EMAIL_ADDRESS
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,creation_date
    ,created_by
    ,ORG_ID
    )
    select distinct
    cont.orig_system_customer_ref||'-'||hrou.organization_id||'-'||cont.orig_system_address_ref||'-'||cont.orig_system_contact_ref ORIG_SYSTEM_CONTACT_REF,         -- ORIG_SYSTEM_CONTACT_REF
    cont.orig_system_customer_ref||'-'||hrou.organization_id||'-'||cont.orig_system_address_ref||'-'||cont.orig_system_contact_ref||'-'||cont.orig_system_email_ref,
    cont.orig_system_customer_ref,           -- orig_system_customer_ref
    cont.orig_system_customer_ref||'-'||hrou.organization_id||'-'||hrou.orig_system_address_ref orig_system_address_ref,-- orig_system_address_ref, must be the same that BILL_TO have
    'I' INSERT_UPDATE_FLAG,                -- INSERT_UPDATE_FLAG
    CONTACT_FIRST_NAME CONTACT_FIRST_NAME,         -- CONTACT_FIRST_NAME
    --CONTACT_MIDDLE_NAME CONTACT_MIDDLE_NAME, -- CONTACT_MIDDLE_NAME
    CONTACT_LAST_NAME CONTACT_LAST_NAME,        -- CONTACT_LAST_NAME
    --'MR.' CONTACT_TITLE,             -- CONTACT_TITLE must be exist in ar_lookups lookup_type = CONTACT_TITLE
    CONTACT_JOB_TITLE CONTACT_JOB_TITLE,         -- CONTACT_JOB_TITLE meaning must be exist in ar_lookups lookup_type = RESPONSIBILITY
    'EMAIL',
    EMAIL,
    c_sysdate,
    c_user_id,
    c_login_id,
    c_sysdate,
    c_user_id,
    hrou.organization_id                      -- org_id
    from 
        (
         select 
                row_number()
                  over (
                        partition by cont.ORIG_SYSTEM_CUSTOMER_REF,
                                     cont.ORIG_SYSTEM_ADDRESS_REF,
                                     cont.ORIG_SYSTEM_CONTACT_REF,
                                     cont.ORIG_SYSTEM_TELEPHONE_REF
                        order by cont.seq_num
                       )  row_num,             
                cont.*            
         from   xxconv_customers    cont 
        ) cont,
        (
         select distinct
                cont.orig_system_customer_ref,           -- orig_system_customer_ref
                cont.ORIG_SYSTEM_ADDRESS_REF,
                cont.ORIG_SYSTEM_CONTACT_REF,
                cont.ORIG_SYSTEM_TELEPHONE_REF,
                /*
                hrou.organization_id||'-'||cont.orig_system_address_ref orig_system_address_ref,-- orig_system_address_ref, must be the same that BILL_TO have
                hrou.organization_id||'-'||cont.orig_system_address_ref||'-'||cont.orig_system_contact_ref,-- orig_system_cont_ref
                hrou.organization_id||'-'||cont.orig_system_address_ref||'-'||cont.orig_system_contact_ref||cont.orig_system_telephone_ref,-- orig_system_cont_ref
                */
                cont.request_id,
                hrou.organization_id,
                hrou.short_code org_code
         from   xxconv_customers    cont,
                hr_operating_units  hrou
         where  1=1
         and    cont.request_id = c_request_id
         --and    cont.status_flag = 'P'
         and    (
                  (
                    upper(cont.operating_unit_name) is null
                    and hrou.short_code             in (
                                                        'HK1_OU',
                                                        'HK2_OU'      
                                                       )
                    )
                 or (
                         upper(cont.operating_unit_name)  = hrou.short_code
                    )
                )
        ) hrou
    where cont.orig_system_customer_ref = hrou.orig_system_customer_ref
    and cont.orig_system_address_ref = hrou.orig_system_address_ref
    and nvl(cont.ORIG_SYSTEM_TELEPHONE_REF,'XX') = nvl(hrou.ORIG_SYSTEM_TELEPHONE_REF,'XX')
    and cont.row_num = 1
    and cont.orig_system_email_ref is not null;

    --
    -- Commit Changes.
    --
    commit;

    --
    -- Import Customer.
    --
    --if n_suppliers > 0 then

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
        -- Submit "Customer Interface Import".
        --
        n_request_id := fnd_request.submit_request (
                          application => 'AR',
                          program     => 'RACUST',
                          description => null,
                          start_time  => null,
                          sub_request => false,
                          argument1   => 'N',
                          argument2   => null -- operating unit
                          );

        --
        -- Check if Concurrent Program successfully submitted.
        --
        if n_request_id = 0 then

          xxconv_common_pkg.append_message(v_abort_msg, 'Submission of Concurrent Request "Customer Interface Import" was failed.');
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

    --end if;

    --
    -- Update the Supplier was uploaded.
    --
    update xxconv_customers  
    set    status_flag = 'C'
    where  request_id  = c_request_id
    and    status_flag = 'P';

    commit;

  exception
    when e_abort then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: Customers failed. '||v_abort_msg, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: Customers failed.');
      xxconv_common_pkg.write_log(v_abort_msg);
      xxconv_common_pkg.write_log('');
    when others then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: Customers failed. '||sqlerrm, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: Customers failed.');
      xxconv_common_pkg.write_log(sqlerrm);
      xxconv_common_pkg.write_log('');

  end main;

end XXCONV_CUSTOMERS_PKG;



/
