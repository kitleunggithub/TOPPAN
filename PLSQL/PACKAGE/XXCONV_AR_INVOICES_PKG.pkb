--------------------------------------------------------
--  DDL for Package Body XXCONV_AR_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXCONV_AR_INVOICES_PKG" as
/*******************************************************************************
 * 
 * Module Name : RECEIVABLES
 * Package Name: XXCONV_AR_INVOICES_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-OCT-2020
 *
 * Purpose     : This program will upload AR Invoices.
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung   30-OCT-2020   Initial Release.
 *
 *******************************************************************************/

  e_abort       exception;

  c_appl_name   constant varchar2(50) := 'AR';
  c_resp_key    constant varchar2(50) := 'RECEIVABLES_MANAGER';
  c_program_name constant varchar2(50) := 'XXCONV_AR_INVOICES';

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

    --v_group_id   ap_invoices_interface.group_id%type;
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
            from xxconv_ar_invoices
            where request_id  = p_request_id;
        exception when others then
            xxconv_common_pkg.append_message(v_abort_msg, 'Request ID ('||p_request_id || ') not found in interface table');
            raise e_abort;
        end;
        c_request_id := p_request_id;
        xxconv_common_pkg.write_log('Re-Run Request ID = '||c_request_id);
    end if;

    --
    -- Set Status Flag to 'P'.
    --
    update xxconv_ar_invoices
    set    status_flag = 'P'
    where  request_id  = c_request_id;

    --
    -- Lookup Operating Unit ID.
    --
    merge into (select request_id,
                       operating_unit_name,
                       org_id,
                       --nvl(operating_unit_name,'HK1_OU') operating_unit_name_nvl --default HK1_OU
                       nvl(operating_unit_name,'HK_OU-TOPPAN MERRILL IFN LIMITED') operating_unit_name_nvl --default HK1_OU
                from   xxconv_ar_invoices
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
    for rec_arhd in (
                     select CUSTOMER_NAME,
                            invoice_num,
                            request_id,
                            RA_CUSTOMER_TRX_LINES_S.nextval  RA_CUSTOMER_TRX_LINES_ID
                     from   (
                             select distinct
                                    CUSTOMER_NAME,
                                    invoice_num,
                                    request_id
                             from   xxconv_ar_invoices
                             where  request_id   = c_request_id
                             and    invoice_num is not null
                             order by invoice_num,CUSTOMER_NAME
                            )
                    )
    loop

      update xxconv_ar_invoices xxar
      set    xxar.RA_CUSTOMER_TRX_LINES_ID  = rec_arhd.RA_CUSTOMER_TRX_LINES_ID
      where  xxar.invoice_num = rec_arhd.invoice_num
      and    xxar.CUSTOMER_NAME = rec_arhd.CUSTOMER_NAME
      and    xxar.request_id  = rec_arhd.request_id;

    end loop;

    --
    -- Commit Changes.
    --
    commit;

    --
    -- Validation.
    --
    for rec_arln in (
        select
            arln.rowid,
            arln.seq_num,
            arln.operating_unit_name,
            arln.org_id,
            decode(arln.org_id    , null, 'N', 'Y')  is_operating_unit_valid,
            arln.transaction_type,
            decode(rctta.name    , null, 'N', 'Y')  is_trans_type_valid,
            arln.line_number,
            arln.amount,
            arln.quantity,
            arln.invoice_currency_code,
            decode(fccy.currency_code, null, 'N', 'Y')  is_invoice_currency_valid,
            arln.exchange_rate,
            arln.exchange_rate_type,
            arln.exchange_date,
            conv.conversion_type,
            (case when arln.exchange_rate_type is not null and conv.conversion_type is null then 'N' else 'Y' end)  is_exchange_rate_type_valid    ,
            arln.customer_acc_num,
            decode(hca.account_number, null, 'N', 'Y') is_acc_exist,
            arln.payment_term,
            decode(rtt.name, null, 'N', 'Y')  is_payment_term_valid,
            arln.standard_memo_line,
            decode(memo.name, null, 'N', 'Y')  is_memo_valid,
            arln.country_code,
            decode(cnty.territory_code, null, 'N', 'Y')  is_country_valid,
            arln.SALESREP1,
            case when (arln.SALESREP1 is not null and sales1.resource_id is null) then 'N' else 'Y' end is_sales1_valid,    
            arln.SPLIT1,
            case when TRIM(replace(translate(arln.SPLIT1, '0123456789', ' '),'.','')) is null then 'Y' else 'N' end is_split1_valid,
            arln.salesrep2,
            case when (arln.SALESREP2 is not null and sales2.resource_id is null) then 'N' else 'Y' end is_sales2_valid,                            
            arln.SPLIT2,
            case when TRIM(replace(translate(arln.SPLIT2, '0123456789', ' '),'.','')) is null then 'Y' else 'N' end is_split2_valid,
            arln.SALESREP3,
            case when (arln.SALESREP3 is not null and sales3.resource_id is null) then 'N' else 'Y' end is_sales3_valid,                
            arln.SPLIT3,
            case when TRIM(replace(translate(arln.SPLIT3, '0123456789', ' '),'.','')) is null then 'Y' else 'N' end is_split3_valid,
            arln.TOTAL_COST,
            case when TRIM(replace(translate(arln.TOTAL_COST, '0123456789', ' '),'.','')) is null then 'Y' else 'N' end is_total_cost_valid,
            --arln.address_line_1,
            arln.site_number,
            decode(cust.orig_system_address_reference, null, 'N', 'Y')  is_site_valid
        from xxconv_ar_invoices  arln,
            hr_operating_units  hrou,
            ra_cust_trx_types_all rctta,
            fnd_currencies fccy,    
            gl_daily_conversion_types  conv,
            hz_cust_accounts hca,
            ra_terms_tl rtt,
            AR_MEMO_LINES_ALL_TL memo,
            fnd_territories_tl cnty,
                (
                    select ho.organization_id org_id, ho.NAME "Operating Unit", hp.PARTY_NUMBER, hp.PARTY_NAME,
                        hp.ORGANIZATION_NAME_PHONETIC, hca.account_number, hcas.attribute1 old_site_number,
                        hca.CUST_ACCOUNT_ID,hcas.ORIG_SYSTEM_REFERENCE orig_system_customer_reference,hcas.cust_acct_site_id,hcas.ORIG_SYSTEM_REFERENCE orig_system_address_reference, 
                        hca.customer_type,
                        (select name from ar.ra_terms_tl
                            where term_id = (select standard_terms
                            from AR.hz_customer_profiles
                            where site_use_id is null
                            and cust_account_id =  hca.cust_account_id)) payment_term,
                        hps.party_site_number, hl.country, hl.address1, hl.address2,
                        hl.address3, hl.address4, hl.city, hl.county, hl.state,
                        hl.province, hl.postal_code,
                        hcsu.site_use_code, 
                        hcsu.LOCATION,
                        hcsu.primary_flag,
                        hca.CREATION_DATE "Customer Account Creation Date", 
                        hca.LAST_UPDATE_DATE "Account Last Update Date",
                        hcas.CREATION_DATE "Site Creation Date",
                        hcas.LAST_UPDATE_DATE "Site Last Update Date"
                        --,hp.STATUS, hps.STATUS, hca.STATUS, hcas.STATUS, hcsu.STATUS
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
                       --AND hca.org_id=hcas.org_id
                       AND hps.location_id          = hl.location_id
                       and hcas.org_id = ho.ORGANIZATION_ID
                    and hp.STATUS = 'A'
                    and hps.STATUS = 'A'
                    and hca.STATUS = 'A'
                    and hcas.STATUS = 'A'
                    and hcsu.STATUS = 'A'    
                ) cust,
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
                ) sales3
        where arln.request_id = c_request_id
        --and hrou.short_code          (+) = upper(arln.operating_unit_name)
        and hrou.name                  (+) = upper(arln.operating_unit_name)
        and rctta.name                 (+) = arln.transaction_type
        and rctta.org_id               (+) = arln.org_id
        and fccy.currency_code         (+) = arln.invoice_currency_code
        and fccy.enabled_flag          (+) = 'Y'
        and conv.user_conversion_type  (+) = arln.exchange_rate_type
        and hca.account_number         (+) = arln.customer_acc_num
        and rtt.name                   (+) = arln.payment_term
        and memo.name                  (+) = arln.standard_memo_line
        and memo.org_id                (+) = arln.org_id
        and upper(cnty.territory_code  (+))= upper(arln.COUNTRY_CODE)
        --and cust.PARTY_NAME            (+) = arln.CUSTOMER_NAME
        and cust.account_number        (+) = arln.customer_acc_num        
        --and cust.country               (+) = arln.country_code
        --and cust.address1              (+) = arln.address_line_1
        and cust.old_site_number       (+) = arln.site_number
        and cust.org_id                (+) = arln.org_id
        and sales1.resource_name       (+) = arln.SALESREP1
        and sales2.resource_name       (+) = arln.SALESREP2
        and sales3.resource_name       (+) = arln.SALESREP3        
        )
    loop

        v_error_msg := null;

        -- Logic for TM
            if rec_arln.transaction_type not in ('TM CONV INV','TM CONV CM') then
                b_abort := true;
                v_text  := 'Invalid [Transaction Type] (VALUE= '||rec_arln.transaction_type||').';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            end if;

            if rec_arln.is_split1_valid = 'N' then
                b_abort := true;
                v_text  := 'Invalid [Split 1] (VALUE= '||rec_arln.split1||'), it must be number.';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            end if;

            if rec_arln.is_split2_valid = 'N' then
                b_abort := true;
                v_text  := 'Invalid [Split 2] (VALUE= '||rec_arln.split2||'), it must be number.';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            end if;

            if rec_arln.is_split3_valid = 'N' then
                b_abort := true;
                v_text  := 'Invalid [Split 3] (VALUE= '||rec_arln.split3||'), it must be number.';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            end if;

            if rec_arln.is_total_cost_valid = 'N' then
                b_abort := true;
                v_text  := 'Invalid [Total Cost] (VALUE= '||rec_arln.TOTAL_COST||'), it must be number.';
                xxconv_common_pkg.append_message(v_error_msg, v_text);
            end if;            

        -- Logic for TM

        if rec_arln.is_operating_unit_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Operating Unit] (VALUE= '||rec_arln.operating_unit_name||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        if rec_arln.is_trans_type_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Transaction Type] (VALUE= '||rec_arln.transaction_type||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        if rec_arln.line_number is null then
            b_abort := true;
            v_text  := '[Line Number] is missing.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        if rec_arln.amount is null then
            b_abort := true;
            v_text  := '[Amount] is missing.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        if rec_arln.quantity is null then
            b_abort := true;
            v_text  := '[Quantity] is missing.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;        

        if rec_arln.is_invoice_currency_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Invoice Currency] (VALUE= '||rec_arln.invoice_currency_code||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        if rec_arln.invoice_currency_code <> 'HKD' then
            if rec_arln.exchange_rate is null then
                b_abort := true;
                v_text  := '[Exchange Rate] Required only if currency is not HKD';
            end if;
            if rec_arln.exchange_rate_type is null then
                b_abort := true;
                v_text  := '[Exchange Rate Type] Required only if currency is not HKD';
            end if;
            if rec_arln.exchange_date is null then
                b_abort := true;
                v_text  := '[Exchange Rate Date] Required only if currency is not HKD';
            end if;            
        end if;

        if rec_arln.is_sales1_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Rep 1] (VALUE= '||rec_arln.salesrep1||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;            
        if rec_arln.is_sales2_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Rep 2] (VALUE= '||rec_arln.salesrep2||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;            
        if rec_arln.is_sales3_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Rep 3] (VALUE= '||rec_arln.salesrep3||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;    

        if rec_arln.is_split1_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Split 1] (VALUE= '||rec_arln.split1||'), it must be number.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;
        if rec_arln.is_split2_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Split 2] (VALUE= '||rec_arln.split2||'), it must be number.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;        
        if rec_arln.is_split3_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Sales Split 3] (VALUE= '||rec_arln.split3||'), it must be number.';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        if rec_arln.is_exchange_rate_type_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Exchange Rate Type] (VALUE= '||rec_arln.exchange_rate_type||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;        

        if rec_arln.is_acc_exist = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Customer Account Number] (VALUE= '||rec_arln.customer_acc_num||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;        

        if rec_arln.is_payment_term_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Payment Term] (VALUE= '||rec_arln.payment_term||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        if rec_arln.is_memo_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Standard Memo Line] (VALUE= '||rec_arln.standard_memo_line||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;
        /*
        if rec_arln.is_country_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Country Code] (VALUE= '||rec_arln.country_code||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;
        */
        if rec_arln.is_site_valid = 'N' then
            b_abort := true;
            v_text  := '[Customer Site] not found (Account Number = '||rec_arln.customer_acc_num||', Old Site Number = '||rec_arln.site_number||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        --
        -- Update Error Message.
        --
        if v_error_msg is not null then

            update xxconv_ar_invoices  arln
            set    arln.status_flag   = 'E',
                    arln.error_message = error_message||substr(decode(error_message, null, null, ' | ')||v_error_msg, 1, 1000)
            where  rowid              = rec_arln.rowid;

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
    -- Populate AR Invoices interface table.
    --
    INSERT INTO RA_INTERFACE_LINES_ALL(
    INTERFACE_LINE_ID,
    BATCH_SOURCE_NAME,--ra_batch_sources_all 
    SET_OF_BOOKS_ID,
    LINE_TYPE,
    CUST_TRX_TYPE_ID,--1001
    CUST_TRX_TYPE_NAME,
    TRX_NUMBER,
    TRX_DATE,
    GL_DATE,
    CURRENCY_CODE,
    CONVERSION_TYPE,
    CONVERSION_RATE,
    CONVERSION_DATE,
    TERM_ID,
    TERM_NAME,
    ORIG_SYSTEM_BILL_CUSTOMER_ID,
    ORIG_SYSTEM_BILL_CUSTOMER_REF,
    ORIG_SYSTEM_BILL_ADDRESS_ID,
    ORIG_SYSTEM_BILL_ADDRESS_REF,
    --ORIG_SYSTEM_SOLD_CUSTOMER_ID,
    --PAYING_CUSTOMER_ID,
    --PAYING_SITE_USE_ID,
    QUANTITY,
    AMOUNT,
    MEMO_LINE_ID,
    MEMO_LINE_NAME,
    LINE_NUMBER,
    DESCRIPTION,
    ORG_ID,
    INTERFACE_LINE_CONTEXT,
    INTERFACE_LINE_ATTRIBUTE8,
    INTERFACE_LINE_ATTRIBUTE9,
    INTERFACE_LINE_ATTRIBUTE10,
    INTERFACE_LINE_ATTRIBUTE11,
    INTERFACE_LINE_ATTRIBUTE12,
    INTERFACE_LINE_ATTRIBUTE13,
    INTERFACE_LINE_ATTRIBUTE14,
    INTERFACE_LINE_ATTRIBUTE15,
    INTERFACE_LINE_ATTRIBUTE5,
    INTERFACE_LINE_ATTRIBUTE6,    
    INTERFACE_LINE_ATTRIBUTE7
    )
    select
    RA_CUSTOMER_TRX_LINES_ID, --INTERFACE_LINE_ID
    'TM CONVERSION', --BATCH_SOURCE_NAME,--ra_batch_sources_all 
    hou.set_of_books_id, --SET_OF_BOOKS_ID
    'LINE', --LINE_TYPE
    rctta.CUST_TRX_TYPE_ID, --CUST_TRX_TYPE_ID,--1001
    rctta.name, --CUST_TRX_TYPE_NAME
    xxar.INVOICE_NUM, --TRX_NUMBER
    xxar.TRANSACTION_DATE, --TRX_DATE
    xxar.GL_DATE, --GL_DATE
    nvl(xxar.INVOICE_CURRENCY_CODE,'HKD'), --CURRENCY_CODE -- default HKD
    decode(nvl(xxar.INVOICE_CURRENCY_CODE,'HKD'),'HKD','User',xxar.EXCHANGE_RATE_TYPE), --CONVERSION_TYPE
    decode(nvl(xxar.INVOICE_CURRENCY_CODE,'HKD'),'HKD',1,xxar.EXCHANGE_RATE), --CONVERSION_RATE
    decode(nvl(xxar.INVOICE_CURRENCY_CODE,'HKD'),'HKD',null,xxar.EXCHANGE_DATE), --CONVERSION_DATE
    decode(xxar.transaction_type,'TM CONV CM',null,rt.term_id), --TERM_ID
    decode(xxar.transaction_type,'TM CONV CM',null,rt.name), --TERM_NAME
    cust.CUST_ACCOUNT_ID, --ORIG_SYSTEM_BILL_CUSTOMER_ID
    cust.ORIG_SYSTEM_CUSTOMER_REFERENCE, --ORIG_SYSTEM_BILL_CUSTOMER_REF
    cust.cust_acct_site_id, --ORIG_SYSTEM_BILL_ADDRESS_ID
    cust.ORIG_SYSTEM_ADDRESS_REFERENCE, --ORIG_SYSTEM_BILL_ADDRESS_REF
    --cust.CUST_ACCOUNT_ID, --ORIG_SYSTEM_SOLD_CUSTOMER_ID
    --cust.CUST_ACCOUNT_ID, --PAYING_CUSTOMER_ID
    --cust.cust_acct_site_id, --PAYING_SITE_USE_ID
    xxar.QUANTITY, --QUANTITY
    xxar.AMOUNT, --AMOUNT
    memol.memo_line_id, --MEMO LINE ID
    xxar.STANDARD_MEMO_LINE, --MEMO LINE
    xxar.LINE_NUMBER, --LINE_NUMBER
    xxar.LINE_DESCRIPTION, --DESCRIPTION
    xxar.org_id, --ORG_ID
    'TM CONVERSION', --INTERFACE_LINE_CONTEXT
    ORIG_TRX_NUMBER, --INTERFACE_LINE_ATTRIBUTE8
    ORIG_PROJECT_NUMBER,  --INTERFACE_LINE_ATTRIBUTE9
    sales1.resource_id,--SALESREP1,  --INTERFACE_LINE_ATTRIBUTE10
    SPLIT1,  --INTERFACE_LINE_ATTRIBUTE11
    sales2.resource_id,--SALESREP2,  --INTERFACE_LINE_ATTRIBUTE12
    SPLIT2,  --INTERFACE_LINE_ATTRIBUTE13
    sales3.resource_id,--SALESREP3,  --INTERFACE_LINE_ATTRIBUTE14
    SPLIT3,  --INTERFACE_LINE_ATTRIBUTE15
    PROJECT_NAME,  --INTERFACE_LINE_ATTRIBUTE5
    to_char(PROJECT_COMPLETION_DATE,'YYYY/MM/DD HH24:MI:SS'),  --INTERFACE_LINE_ATTRIBUTE6
    TOTAL_COST  --INTERFACE_LINE_ATTRIBUTE7
    from xxconv_ar_invoices xxar,
        hr_operating_units hou,
        ra_cust_trx_types_all rctta,
        ra_terms rt,
        AR_MEMO_LINES_ALL_TL memol,
        (
            select ho.organization_id org_id, ho.NAME "Operating Unit", hp.PARTY_NUMBER, hp.PARTY_NAME,
                hp.ORGANIZATION_NAME_PHONETIC, hca.account_number, hcas.attribute1 old_site_number, 
                hca.CUST_ACCOUNT_ID,hcas.ORIG_SYSTEM_REFERENCE orig_system_customer_reference,hcas.cust_acct_site_id,hcas.ORIG_SYSTEM_REFERENCE orig_system_address_reference, 
                hca.customer_type,
                (select name from ar.ra_terms_tl
                    where term_id = (select standard_terms
                    from AR.hz_customer_profiles
                    where site_use_id is null
                    and cust_account_id =  hca.cust_account_id)) payment_term,
                hps.party_site_number, hl.country, hl.address1, hl.address2,
                hl.address3, hl.address4, hl.city, hl.county, hl.state,
                hl.province, hl.postal_code,
                hcsu.site_use_code, 
                hcsu.LOCATION,
                hcsu.primary_flag,
                hca.CREATION_DATE "Customer Account Creation Date", 
                hca.LAST_UPDATE_DATE "Account Last Update Date",
                hcas.CREATION_DATE "Site Creation Date",
                hcas.LAST_UPDATE_DATE "Site Last Update Date"
                --,hp.STATUS, hps.STATUS, hca.STATUS, hcas.STATUS, hcsu.STATUS
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
               --AND hca.org_id=hcas.org_id
               AND hps.location_id          = hl.location_id
               and hcas.org_id = ho.ORGANIZATION_ID
            and hp.STATUS = 'A'
            and hps.STATUS = 'A'
            and hca.STATUS = 'A'
            and hcas.STATUS = 'A'
            and hcsu.STATUS = 'A'    
        ) cust,
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
        ) sales3        
    where xxar.operating_unit_name = hou.name (+)
    and xxar.transaction_type = rctta.name (+)
    and xxar.org_id = rctta.org_id (+)
    and xxar.payment_term = rt.name (+)
    and xxar.STANDARD_MEMO_LINE = memol.name (+)
    and xxar.org_id = memol.org_id (+)
--    and xxar.CUSTOMER_NAME = cust.PARTY_NAME (+)
    and xxar.customer_acc_num = cust.account_number (+)
--    and xxar.country_code = cust.country (+)
--    and xxar.address_line_1 = cust.address1 (+)
    and xxar.site_number = cust.old_site_number (+)
    AND xxar.org_id = cust.org_id (+)
    and xxar.salesrep1 = sales1.resource_name (+)
    and xxar.salesrep2 = sales2.resource_name (+)
    and xxar.salesrep3 = sales3.resource_name (+)
    and xxar.request_id = c_request_id;

    n_headers := sql%rowcount;

    INSERT INTO RA_INTERFACE_DISTRIBUTIONS_ALL
    (
     INTERFACE_LINE_ID
    ,ACCOUNT_CLASS
    ,AMOUNT
    --,CODE_COMBINATION_ID
    ,PERCENT
--    ,INTERFACE_LINE_CONTEXT
--    ,INTERFACE_LINE_ATTRIBUTE8
--    ,INTERFACE_LINE_ATTRIBUTE9
    ,ORG_ID
    )
    select  
    RA_CUSTOMER_TRX_LINES_ID, --INTERFACE_LINE_ID
    'REV', --ACCOUNT_CLASS
    xxar.amount,--AMOUNT
    --CODE_COMBINATION_ID
    100,--PERCENT
--    'TM CONVERSION', --INTERFACE_LINE_CONTEXT
--    ORIG_TRX_NUMBER, --INTERFACE_LINE_ATTRIBUTE8
--    ORIG_PROJECT_NUMBER,  --INTERFACE_LINE_ATTRIBUTE9
    xxar.ORG_ID
    from xxconv_ar_invoices xxar
    where request_id = c_request_id;

    --
    -- Commit changes.
    --
    commit;

    --
    -- Import AR Invoices.
    --
    if n_headers > 0 then

      --
      -- By OU ID.
      --
      for rec_btch in (
                       select distinct
                              --group_id,
                              org_id,
                              batch_source_id,
                              name batch_name
                       from   (
                               select arhd.group_id,
                                      arhd.org_id,
                                      rbsa.name,
                                      rbsa.batch_source_id,
                                      row_number()
                                        over (
                                              partition by RA_CUSTOMER_TRX_LINES_ID
                                              order by seq_num
                                             )  row_num
                               from   xxconv_ar_invoices  arhd, RA_BATCH_SOURCES_ALL rbsa
                               where  arhd.org_id = rbsa.org_id
                               and    arhd.request_id  = c_request_id
                               and    arhd.RA_CUSTOMER_TRX_LINES_ID is not null
                               and    rbsa.name = 'TM CONVERSION'
                               and    arhd.status_flag = 'P'
                              )
                       where  1=1
                       and    org_id   is not null
                       and    row_num   = 1
                       order by org_id
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
          -- Submit "Autoinvoice Master Program".
          --

          n_request_id := fnd_request.submit_request (
                            application => 'AR',
                            program     => 'RAXMTR',
                            description => null,
                            start_time  => null,
                            sub_request => false,
                            argument1   => '1',        -- Number of Instance
                            argument2   => rec_btch.org_id, -- Operating Unit
                            argument3   => rec_btch.batch_source_id,    -- batch source id
                            argument4   => rec_btch.batch_name,      -- Batch Source
                            argument5   => to_char(trunc(sysdate),'YYYY/MM/DD HH24:MI:SS'),              -- Default Date
                            argument6   => null,
                            argument7   => null,
                            argument8   => null,
                            argument9   => null,
                            argument10   => null,
                            argument11   => null,
                            argument12   => null,
                            argument13   => null,
                            argument14   => null,
                            argument15   => null,
                            argument16   => null,
                            argument17   => null,
                            argument18   => null,
                            argument19   => null,
                            argument20   => null,
                            argument21   => null,
                            argument22   => null,
                            argument23   => null,
                            argument24   => null,
                            argument25   => null,
                            argument26   => 'Y',                  -- Base Due Date on Trx
                            argument27   => null
                            );

          --
          -- Check if Concurrent Program successfully submitted.
          --
          if n_request_id = 0 then

            xxconv_common_pkg.append_message(v_abort_msg, 'Submission of Concurrent Request "Autoinvoice Master Program" was failed.');
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

            xxconv_common_pkg.append_message(v_abort_msg, 'Concurrent Request (ID: '||to_char(n_request_id)||') "Autoinvoice Master Program" failed.');

            raise e_abort;

          end if;

        end;

      end loop;

    end if;

    --
    -- Update the invoices was uploaded.
    --
    update xxconv_ar_invoices  
    set    status_flag = 'C'
    where  request_id  = c_request_id
    and    status_flag = 'P';

  exception
    when e_abort then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: AR Invoices failed. '||v_abort_msg, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: AR Invoices failed.');
      xxconv_common_pkg.write_log(v_abort_msg);
      xxconv_common_pkg.write_log('');
    when others then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: AR Invoices failed. '||sqlerrm, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: AR Invoices failed.');
      xxconv_common_pkg.write_log(sqlerrm);
      xxconv_common_pkg.write_log('');

  end main;

end xxconv_ar_invoices_pkg;

/
