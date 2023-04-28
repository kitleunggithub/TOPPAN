--------------------------------------------------------
--  DDL for Package Body XXCONV_AP_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXCONV_AP_INVOICES_PKG" as
/*******************************************************************************
 *
 * Module Name : Payables
 * Package Name: XXCONV_AP_INVOICES_PKG
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

  e_abort       exception;

  c_appl_name   constant varchar2(50) := 'SQLAP';
  c_resp_key    constant varchar2(50) := 'PAYABLES_MANAGER';
  c_program_name constant varchar2(50) := 'XXCONV_AP_INVOICES';

  c_newline     constant varchar2(1)  := fnd_global.newline;
  c_errbuf_max  constant number(15)   := 240;
  c_request_id           number(15)   := fnd_global.conc_request_id;
  c_user_id     constant number(15)   := fnd_global.user_id;
  c_login_id    constant number(15)   := fnd_global.login_id;
  c_sysdate     constant date         := sysdate;

  procedure main (
    errbuf          out varchar2,
    retcode         out varchar2,
    p_file_path  in     varchar2,
    p_file_name  in     varchar2,
    p_request_id    in  number)
  is

    b_abort      boolean;
    v_abort_msg  varchar2(1000);
    v_error_msg  varchar2(1000);
    v_text       varchar2(1000);

    v_group_id   ap_invoices_interface.group_id%type;
    n_headers    number;

    n_ccid        number;

  begin

    --
    -- Initialize
    --
    errbuf  := null;
    retcode := '0';

    b_abort     := false;
    v_abort_msg := null;

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
            from xxconv_ap_invoices
            where request_id  = p_request_id;
        exception when others then
            xxconv_common_pkg.append_message(v_abort_msg, 'Request ID ('||p_request_id || ') not found in interface table');
            raise e_abort;
        end;
        c_request_id := p_request_id;
        xxconv_common_pkg.write_log('Re-Run Request ID = '||c_request_id);
    end if;

    --
    -- Get Group ID
    --
    -- v_group_id := to_char(ap_interface_groups_s.nextval);
    v_group_id := to_char(c_request_id);

    --
    -- Set Status Flag to 'P'.
    --
    update xxconv_ap_invoices
    set    status_flag = 'P',
           group_id    = v_group_id
    where  request_id  = c_request_id;

    --
    -- Lookup Operating Unit ID.
    --
    merge into (select request_id,
                       operating_unit_name,
                       org_id,
                       --nvl(operating_unit_name,'HK1_OU') operating_unit_name_nvl --default HK1_OU
                       nvl(operating_unit_name,'HK_OU-TOPPAN MERRILL IFN LIMITED') operating_unit_name_nvl --default HK1_OU
                from   xxconv_ap_invoices
                where  request_id = c_request_id)  aphd
    using (
                select * from hr_operating_units hrou2 
          )  hrou2
    on    (
               aphd.operating_unit_name_nvl = hrou2.name
          )
    when matched then
      update set aphd.org_id = hrou2.organization_id,
                 aphd.operating_unit_name = hrou2.name;

    --
    -- Assign Interface ID.
    --
    for rec_aphd in (
                     select VENDOR_NAME,
                            invoice_num,
                            request_id,
                            ap_invoices_interface_s.nextval  interface_header_id
                     from   (
                             select distinct
                                    VENDOR_NAME, --difference supplier allow same invoice number
                                    invoice_num,
                                    request_id
                             from   xxconv_ap_invoices
                             where  request_id   = c_request_id
                             and    invoice_num is not null
                             order by invoice_num,VENDOR_NAME
                            )
                    )
    loop

      update xxconv_ap_invoices xxap
      set    xxap.invoice_id  = rec_aphd.interface_header_id
      where  xxap.invoice_num = rec_aphd.invoice_num
      and    xxap.VENDOR_NAME = rec_aphd.VENDOR_NAME --difference supplier allow same invoice number
      and    xxap.request_id  = rec_aphd.request_id;

    end loop;

    for rec_apln in (
                     select rowid  row_id
                     from   xxconv_ap_invoices
                     where  request_id  = c_request_id
                     and    invoice_id is not null
                     order by invoice_id, line_number, seq_num
                    )
    loop

      update xxconv_ap_invoices
      set    invoice_line_id = ap_invoice_lines_interface_s.nextval
      where  rowid = rec_apln.row_id;

    end loop;

    --
    -- Commit Changes.
    --
    commit;

    --
    -- Validation.
    --
    for rec_apln in (
                     select apln.row_id,
                            apln.seq_num,
                            apln.operating_unit_name,
                            apln.org_id,
                            decode(apln.org_id    , null, 'N', 'Y')  is_operating_unit_valid,
                            apln.invoice_num,
                            decode(aphd.invoice_id, null, 'N', 'Y')  is_invoice_num_exist,
                            apln.invoice_date,
                            apln.vendor_name,
                            apln.vendor_id,
                            apln.party_id,
                            decode(apln.vendor_id , null, 'N', 'Y')  is_vendor_valid,
                            apln.vendor_site_code,
                            site.vendor_site_id,
                            (case when apln.vendor_id is not null and site.vendor_site_id is null then 'N' else 'Y' end)  is_vendor_site_valid,
                            apln.invoice_amount,
                            apln.invoice_currency_code,
                            decode(fccy.currency_code, null, 'N', 'Y')  is_invoice_currency_valid,
                            apln.exchange_rate,
                            apln.exchange_rate_type,
                            conv.conversion_type,
                            (case when apln.exchange_rate_type is not null and conv.conversion_type is null then 'N' else 'Y' end)  is_exchange_rate_type_valid,
                            apln.exchange_date,
                            apln.terms_name,
                            term.term_id,
                            decode(term.term_id, null, 'N', 'Y')  is_terms_name_valid,
                            apln.terms_date,
                            apln.description,
                            apln.payment_method_code,
                            (case when apln.payment_method_code   is not null and mthd.payment_method_code is null then 'N' else 'Y' end)  is_payment_method_valid,
                            apln.pay_group_lookup_code,
                            (case when apln.pay_group_lookup_code is not null and payg.lookup_code is null then 'N' else 'Y' end)  is_pay_group_valid,
                            apln.line_number,
                            apln.line_amount,
                            apln.line_description,
                            apln.accounting_date,
                            apln.distribution_account,
                            dstb.code_combination_id  distribution_account_id,
                            decode(dstb.code_combination_id, null, 'N', 'Y')  is_distribution_account_valid,
                            apln.request_id,
                            apln.header_row_num
                     from   (
                             select apln.rowid  row_id,
                                    apln.seq_num,
                                    apln.operating_unit_name,
                                    hrou.organization_id  org_id,
                                    apln.invoice_num,
                                    apln.invoice_date,
                                    apln.vendor_name,
                                    vndr.vendor_id,
                                    vndr.party_id,
                                    apln.vendor_site_code,
                                    apln.invoice_amount,
                                    apln.invoice_currency_code,
                                    apln.exchange_rate,
                                    apln.exchange_rate_type,
                                    apln.exchange_date,
                                    apln.terms_name,
                                    apln.terms_date,
                                    apln.description,
                                    apln.payment_method_code,
                                    apln.pay_group_lookup_code,
                                    apln.line_number,
                                    apln.line_amount,
                                    apln.line_description,
                                    apln.accounting_date,
                                    apln.distribution_account,
                                    apln.request_id,
                                    row_number()
                                      over (
                                            partition by apln.request_id, apln.invoice_num
                                            order by apln.seq_num
                                           )  header_row_num
                             from   xxconv_ap_invoices  apln,
                                    hr_operating_units  hrou,
                                    (
                                     select upper(vendor_name)  vendor_name,
                                            vendor_id,
                                            party_id
                                     from   ap_suppliers  vndr
                                     --where  nvl(vendor_type_lookup_code, 'XX') != 'EMPLOYEE'
                                     --and    employee_id                        is null
                                    )  vndr
                             where  hrou.name  (+) = upper(apln.operating_unit_name)
                             and    vndr.vendor_name (+) = upper(apln.vendor_name)
                            )  apln,
                            ap_invoices_all            aphd,
                            ap_supplier_sites_all      site,
                            fnd_currencies             fccy,
                            gl_daily_conversion_types  conv,
                            ap_terms                   term,
                            --ap_lookup_codes            mthd,
                            (
                                SELECT
                                    pm.payment_method_name,
                                    pm.payment_method_code,
                                    pm.description,
                                    pm.inactive_date,
                                    l.meaning status,
                                    l.lookup_code status_code,
                                    pm.payment_method_code pm_code
                                FROM
                                    fnd_lookups l,
                                    iby_payment_methods_vl pm
                                WHERE l.lookup_type = 'IBY_ACTIVE_STATUS'
                                AND l.lookup_code = DECODE(pm.inactive_date,NULL,'Y','N')
                                AND INACTIVE_DATE IS NULL
                            ) mthd,
                            --po_lookup_codes            payg,
                            (select lookup_code from FND_LOOKUP_VALUES where LOOKUP_TYPE = 'PAY GROUP' and language = 'US') payg,
                            (
                             select concatenated_segments,
                                    code_combination_id
                             from   gl_code_combinations_kfv
                             where  detail_budgeting_allowed = 'Y'
                             and    enabled_flag             = 'Y'
                             and    sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate)
                            )  dstb
                     where  apln.request_id                = c_request_id
                     and    aphd.vendor_id             (+) = apln.vendor_id
                     and    aphd.invoice_num           (+) = apln.invoice_num
                     and    aphd.org_id                (+) = apln.org_id
                     and    site.vendor_id             (+) = apln.vendor_id
                     and    site.vendor_site_code      (+) = apln.vendor_site_code
                     and    site.org_id                (+) = apln.org_id
                     and    fccy.currency_code         (+) = apln.invoice_currency_code
                     and    fccy.enabled_flag          (+) = 'Y'
                     and    conv.user_conversion_type  (+) = apln.exchange_rate_type
                     and    term.name                  (+) = apln.terms_name
                     and    term.enabled_flag          (+) = 'Y'
                     --and    mthd.lookup_type           (+) = 'PAYMENT METHOD'
                     --and    mthd.enabled_flag          (+) = 'Y'
                     and    mthd.payment_method_code   (+) = apln.payment_method_code
                     --and    payg.lookup_type           (+) = 'PAY GROUP'
                     --and    payg.enabled_flag          (+) = 'Y'
                     and    payg.lookup_code           (+) = apln.pay_group_lookup_code
                     and    dstb.concatenated_segments (+) = apln.distribution_account
                    )
    loop

      v_error_msg := null;

        --Logic for TM

        if substr(rec_apln.distribution_account,18,6) <> '240003' then
          b_abort := true;
          v_text  := '[Distribution Account] Account Segment must be "240003" (VALUE= '||rec_apln.distribution_account||').';
          xxconv_common_pkg.append_message(v_error_msg, v_text);       
        end if;

        if rec_apln.invoice_amount <> rec_apln.line_amount then
          b_abort := true;
          v_text  := '[Line Amount] not equal to [Invoice Amount].';
          xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;        
        --end Logic for TM

      --
      -- AP Invoice Headers
      --

      if rec_apln.header_row_num = 1 then

        if rec_apln.is_operating_unit_valid = 'N' then

          b_abort := true;
          v_text  := 'Invalid [Operating Unit] (VALUE= '||rec_apln.operating_unit_name||').';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

        if rec_apln.invoice_num is null then

          b_abort := true;
          v_text  := '[Invoice Number] is missing.';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

        if rec_apln.is_invoice_num_exist = 'Y' then

          b_abort := true;
          v_text  := '[Invoice Number] (VALUE= '||rec_apln.invoice_num||') already exists.';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

        if rec_apln.invoice_date is null then

          b_abort := true;
          v_text  := '[Invoice Date] is missing.';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

        if rec_apln.is_vendor_valid = 'N' then

          b_abort := true;
          v_text  := 'Invalid [Vendor] (VALUE= '||rec_apln.vendor_name||').';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

        if rec_apln.is_vendor_site_valid = 'N' then

          b_abort := true;
          v_text  := 'Invalid [Vendor Site] (VALUE= '||rec_apln.vendor_site_code||') [Vendor='||rec_apln.vendor_name||',OU='||rec_apln.operating_unit_name||'].';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

        if rec_apln.invoice_amount is null then

          b_abort := true;
          v_text  := '[Invoice Amount] is missing.';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

        if rec_apln.is_invoice_currency_valid = 'N' then

          b_abort := true;
          v_text  := 'Invalid [Currency] (VALUE= '||rec_apln.invoice_currency_code||').';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

        if rec_apln.is_exchange_rate_type_valid = 'N' then

          b_abort := true;
          v_text  := 'Invalid [Exchange Rate Type] (VALUE= '||rec_apln.exchange_rate_type||').';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        else

          if rec_apln.exchange_rate_type is not null then

            if rec_apln.exchange_date is null then

              b_abort := true;
              v_text  := '[Exchange Rate Date] is missing.';
              xxconv_common_pkg.append_message(v_error_msg, v_text);

            end if;

            if rec_apln.exchange_rate is null then

              b_abort := true;
              v_text  := '[Exchange Rate] is missing.';
              xxconv_common_pkg.append_message(v_error_msg, v_text);

            end if;

          end if;

        end if;

        if rec_apln.is_terms_name_valid = 'N' then

          b_abort := true;
          v_text  := 'Invalid [Payment Terms] (VALUE= '||rec_apln.terms_name||').';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

        if rec_apln.terms_date is null then

          b_abort := true;
          v_text  := '[Payment Terms Date] is missing.';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

        if rec_apln.is_payment_method_valid = 'N' then

          b_abort := true;
          v_text  := 'Invalid [Payment Method] (VALUE= '||rec_apln.payment_method_code||').';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

        if rec_apln.is_pay_group_valid = 'N' then

          b_abort := true;
          v_text  := 'Invalid [Pay Group] (VALUE= '||rec_apln.pay_group_lookup_code||').';
          xxconv_common_pkg.append_message(v_error_msg, v_text);

        end if;

      end if;

      --
      -- AP Invoice Lines
      --
      if rec_apln.line_number is null then

        b_abort := true;
        v_text  := '[Line Number] is missing.';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_apln.line_amount is null then

        b_abort := true;
        v_text  := '[Line Amount] is missing.';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_apln.accounting_date is null then

        b_abort := true;
        v_text  := '[GL Date] is missing.';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_apln.is_distribution_account_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Distribution Account] (VALUE= '||rec_apln.distribution_account||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
      end if;

      --
      -- Update Error Message.
      --
      if v_error_msg is not null then

        update xxconv_ap_invoices  apln
        set    apln.status_flag   = 'E',
               apln.error_message = error_message||substr(decode(error_message, null, null, ' | ')||v_error_msg, 1, 1000)
        where  rowid              = rec_apln.row_id;

      end if;


    end loop;

    --
    -- Commit Changes.
    --
    commit;

    /*
    For rec_ccid in (
                        select distinct distribution_account gl_account from xxconv_ap_invoices where request_id = c_request_id and status_flag = 'P' and distribution_account is not null
                    )
    Loop
        n_ccid := xxconv_items_pkg.get_ccid(rec_ccid.gl_account,false); -- create ccid
    end loop;
    */

    --
    -- Abort if failed in Validation.
    --
    if b_abort then

      raise e_abort;

    end if;

--
-- Abort after Validation.
--
-- return;
--

    --
    -- Populate AP Invoices interface table.
    --
    insert into ap_invoices_interface
    (
     invoice_id,
     invoice_num,
     invoice_type_lookup_code,
     invoice_date,
     vendor_name,
     vendor_site_code,
     invoice_amount,
     invoice_currency_code,
     exchange_rate,
     exchange_rate_type,
     exchange_date,
     terms_name,
     description,
     last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     --attribute_category,
     payment_method_code,
     pay_group_lookup_code,
     source,
     group_id,
     gl_date,
     org_id
    )
    (
     select aphd.invoice_id,
            aphd.invoice_num,
            (
             case
               when aphd.invoice_amount < 0
                 then 'CREDIT'
               else 'STANDARD'
             end
            )  invoice_type_lookup_code,
            aphd.invoice_date,
            nvl(vndr.vendor_name, aphd.vendor_name)  vendor_name,
            aphd.vendor_site_code,
            aphd.invoice_amount,
            nvl(aphd.invoice_currency_code,'HKD'), -- default HKD
            decode(nvl(aphd.invoice_currency_code,'HKD'), 'HKD', to_number(null), aphd.exchange_rate     )  exchange_rate,
            decode(nvl(aphd.invoice_currency_code,'HKD'), 'HKD', null           , aphd.exchange_rate_type)  exchange_rate_type,
            decode(nvl(aphd.invoice_currency_code,'HKD'), 'HKD', to_date(null)  , aphd.exchange_date     )  exchange_date,
            nvl(aphd.terms_name,'30 Days'),
            aphd.description,
            c_sysdate   last_update_date,
            c_user_id   last_updated_by,
            c_login_id  last_update_login,
            c_sysdate   creation_date,
            c_user_id   created_by,
            --decode(aphd.org_id, 123, aphd.org_id)  attribute_category,
            aphd.payment_method_code,
            nvl(aphd.pay_group_lookup_code,'HONG KONG'), --default HONG KONG
            'MANUAL INVOICE ENTRY'  source,
            aphd.group_id,
            aphd.accounting_date    gl_date,
            aphd.org_id
     from   (
             select invoice_id,
                    invoice_num,
                    invoice_date,
                    vendor_name,
                    vendor_site_code,
                    invoice_amount,
                    invoice_currency_code,
                    exchange_rate,
                    exchange_rate_type,
                    exchange_date,
                    terms_name,
                    terms_date,
                    description,
                    payment_method_code,
                    pay_group_lookup_code,
                    group_id,
                    accounting_date,
                    org_id,
                    row_number()
                      over (
                            partition by invoice_id
                            order by seq_num
                           )  row_num
             from   xxconv_ap_invoices  aphd
             where  aphd.request_id  = c_request_id
             and    aphd.invoice_id is not null
             and    not exists (
                                select 'x'
                                from   xxconv_ap_invoices  xxhd
                                where  xxhd.request_id             = aphd.request_id
                                and    xxhd.invoice_id             = aphd.invoice_id
                                and    nvl(xxhd.status_flag, 'X') != 'P'
                               )
            )  aphd,
            (
             select upper(vendor_name)  upper_vendor_name,
                    vendor_name
             from   ap_suppliers
             --where  nvl(vendor_type_lookup_code, 'XX') != 'EMPLOYEE'
             --and    employee_id                        is null
            )  vndr
     where  aphd.row_num               = 1
     and    vndr.upper_vendor_name (+) = upper(aphd.vendor_name)
    );

    n_headers := sql%rowcount;

    insert into ap_invoice_lines_interface
    (
     invoice_id,
     invoice_line_id,
     line_number,
     line_type_lookup_code,
     amount,
     accounting_date,
     description,
     dist_code_concatenated,
     last_updated_by,
     last_update_date,
     last_update_login,
     created_by,
     creation_date,
     org_id
    )
    (
     select invoice_id,
            invoice_line_id,
            line_number,
            'ITEM'                line_type_lookup_code,
            line_amount           amount,
            accounting_date,
            line_description      description,
            distribution_account  dist_code_concatenated,
            c_user_id             last_updated_by,
            c_sysdate             last_update_date,
            c_login_id            last_update_login,
            c_user_id             created_by,
            c_sysdate             creation_date,
            org_id
     from   xxconv_ap_invoices  aphd
     where  aphd.request_id  = c_request_id
     and    aphd.invoice_id is not null
     and    not exists (
                        select 'x'
                        from   xxconv_ap_invoices  xxhd
                        where  xxhd.request_id             = aphd.request_id
                        and    xxhd.invoice_id             = aphd.invoice_id
                        and    nvl(xxhd.status_flag, 'X') != 'P'
                       )
    );

    --
    -- Commit changes.
    --
    commit;

    --
    -- Import AP Invoices.
    --
    if n_headers > 0 then

      --
      -- By Group ID and OU ID.
      --
      for rec_btch in (
                       select distinct
                              group_id,
                              org_id
                       from   (
                               select group_id,
                                      org_id,
                                      row_number()
                                        over (
                                              partition by invoice_id
                                              order by seq_num
                                             )  row_num
                               from   xxconv_ap_invoices  aphd
                               where  aphd.request_id  = c_request_id
                               and    aphd.invoice_id is not null
                               and    not exists (
                                                  select 'x'
                                                  from   xxconv_ap_invoices  xxhd
                                                  where  xxhd.request_id             = aphd.request_id
                                                  and    xxhd.invoice_id             = aphd.invoice_id
                                                  and    nvl(xxhd.status_flag, 'X') != 'P'
                                                 )
                              )
                       where  group_id is not null
                       and    org_id   is not null
                       and    row_num   = 1
                       order by group_id, org_id
                      )
      loop

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
          fnd_request.set_org_id(org_id => rec_btch.org_id);

          --
          -- Submit "Payables Open Interface Import".
          --
          n_request_id := fnd_request.submit_request (
                            application => 'SQLAP',
                            program     => 'APXIIMPT',
                            description => null,
                            start_time  => null,
                            sub_request => false,
                            argument1   => rec_btch.org_id,        -- Operating Unit
                            argument2   => 'MANUAL INVOICE ENTRY', -- Source
                            argument3   => rec_btch.group_id,      -- Group
                            argument4   => 'Data Conversion', -- Batch Name
                            argument5   => null,                   -- Hold Name
                            argument6   => null,                   -- Hold Reason
                            argument7   => null,                   -- GL Date
                            argument8   => 'N',                    -- Purge
                            argument9   => 'N',                    -- Trace Switch
                            argument10  => 'N',                    -- Debug Switch
                            argument11  => 'N',                    -- Summarize Report for Audit report
                            argument12  => '1000',                 -- Commit Batch Size
                            argument13  => to_char(c_user_id),     -- User ID
                            argument14  => to_char(c_login_id));   -- Login ID

          --
          -- Check if Concurrent Program successfully submitted.
          --
          if n_request_id = 0 then

            xxconv_common_pkg.append_message(v_abort_msg, 'Submission of Concurrent Request "Payables Open Interface Import" was failed.');
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

          if not (v_dev_phase = 'COMPLETE' and v_dev_status = 'NORMAL') then

            xxconv_common_pkg.append_message(v_abort_msg, 'Concurrent Request (ID: '||to_char(n_request_id)||') "Payables Open Interface Import" failed.');

            raise e_abort;

          end if;

        end;

      end loop;

    end if;

    --
    -- Update the invoices was uploaded.
    --
    update xxconv_ap_invoices  
    set    status_flag = 'C'
    where  request_id  = c_request_id
    and    status_flag = 'P';

    commit;
  exception
    when e_abort then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: AP Invoices failed. '||v_abort_msg, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: AP Invoices failed.');
      xxconv_common_pkg.write_log(v_abort_msg);
      xxconv_common_pkg.write_log('');
    when others then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: AP Invoices failed. '||sqlerrm, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: AP Invoices failed.');
      xxconv_common_pkg.write_log(sqlerrm);
      xxconv_common_pkg.write_log('');

  end main;

end xxconv_ap_invoices_pkg;



/
