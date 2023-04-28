--------------------------------------------------------
--  DDL for Package Body XXCONV_AR_RECEIPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXCONV_AR_RECEIPTS_PKG" as
/*******************************************************************************
 *
 * Module Name : Payables
 * Package Name: XXCONV_AR_RECEIPTS_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-OCT-2020
 *
 * Purpose     : This program will upload AR Receipt.
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung    30-OCT-2020   Initial Release.
 *
 *******************************************************************************/

  e_abort       exception;

  c_appl_name   constant varchar2(50) := 'SQLAP';
  --c_resp_key    constant varchar2(50) := 'PAYABLES_MANAGER';
  c_resp_key    constant varchar2(50) := 'XXAR_SETUP';
  c_program_name constant varchar2(50) := 'XXCONV_AR_RECEIPTS';

  c_newline     constant varchar2(1)  := fnd_global.newline;
  c_msg_length  constant number(15)   := 1000;
  c_errbuf_max  constant number(15)   := 240;
  c_request_id           number(15)   := fnd_global.conc_request_id;
  c_user_id     constant number(15)   := fnd_global.user_id;
  c_login_id    constant number(15)   := fnd_global.login_id;
  c_sysdate     constant date         := sysdate;

    PROCEDURE load_ar_receipts 
    IS
        l_return_status VARCHAR2(1);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(4000);
        l_error_msg VARCHAR2(4000);
        l_cash_receipt_id NUMBER;
        l_org_id NUMBER;
        l_attribute_rec AR_RECEIPT_API_PUB.ATTRIBUTE_REC_TYPE;
        l_rec_mthd number;
        l_receipt_method_name varchar2(255);
        l_remittance_bank_account_id number;
        l_remittance_bank_account_num varchar2(255);
        l_remittance_bank_account_name varchar2(255);
        l_cust_acct_id                       NUMBER;
        l_customer_trx_id                  NUMBER;
        p_count number := 0;    
    BEGIN        

        for rec_rcp in (
                            select xxrcp.rowid,xxrcp.* from XXCONV_AR_RECEIPTS xxrcp
                            where request_id = c_request_id
                            and status_flag = 'P'
                            order by seq_num
                       )
        loop

            l_return_status             := null;
            l_msg_count                 := null;
            l_msg_data                  := null;
            l_cash_receipt_id           := null;
            l_org_id                    := null;
            l_attribute_rec             := null;
            l_rec_mthd                  := null;
            l_remittance_bank_account_id := null;
            l_receipt_method_name       := null;
            l_remittance_bank_account_name := null;
            l_remittance_bank_account_num := null;           
            l_cust_acct_id              := null;
            l_customer_trx_id           := null;
            p_count                     := 0;   
            l_error_msg                 := null;

            l_org_id := rec_rcp.org_id;
            -- 1) Set the applications context
            --mo_global.init('AR');
            mo_global.set_policy_context('S',l_org_id);
            --fnd_global.apps_initialize(1131, 50559, 222,0);

            SELECT hca.cust_account_id
            INTO l_cust_acct_id
            FROM hz_cust_accounts_all hca
                ,hz_parties  hp
            WHERE hp.party_id=hca.party_id
            AND  hca.account_number =rec_rcp.ACCOUNT_NUMBER
            AND hca.status = 'A'
            AND rownum = 1;

            select rm.receipt_method_id 
                    ,cba.bank_account_id
                    ,rm.name
                    ,cba.BANK_ACCOUNT_NAME
                    ,cba.BANK_ACCOUNT_NUM
            into l_rec_mthd
                , l_remittance_bank_account_id
                , l_receipt_method_name
                , l_remittance_bank_account_name
                , l_remittance_bank_account_num
            from AR_RECEIPT_METHOD_ACCOUNTS_ALL rma,
                ar_receipt_methods rm, 
                ce_bank_accounts cba,
                ce_bank_acct_uses_all ba
            where  rma.receipt_method_id = rm.receipt_method_id
            and rma.remit_bank_acct_use_id = ba.bank_acct_use_id
            and cba.bank_account_id = ba.bank_account_id
            and rm.name = rec_rcp.receipt_method_name
            --and cba.BANK_ACCOUNT_NAME = rec_rcp.REMIT_BANK_ACCOUNT_NAME
            and cba.BANK_ACCOUNT_NUM = rec_rcp.REMIT_BANK_ACCOUNT_NUM;

            xxconv_common_pkg.write_log('Begin AR_RECEIPT_API_PUB.CREATE_APPLY_ON_ACC:' || rec_rcp.receipt_number);

            AR_RECEIPT_API_PUB.CREATE_APPLY_ON_ACC
            ( p_api_version => 1.0,
             p_init_msg_list => FND_API.G_TRUE,
             p_commit => FND_API.G_FALSE,
             p_validation_level => FND_API.G_VALID_LEVEL_FULL,
             x_return_status => l_return_status,
             x_msg_count => l_msg_count,
             x_msg_data => l_msg_data,
             p_exchange_rate_type => case when rec_rcp.RECEIPT_CURRENCY_CODE = 'HKD' then null else 'User' end,
             p_exchange_rate      => case when rec_rcp.RECEIPT_CURRENCY_CODE = 'HKD' then null else rec_rcp.RECEIPT_EXCHANGE_RATE end,
             p_exchange_rate_date => case when rec_rcp.RECEIPT_CURRENCY_CODE = 'HKD' then null else rec_rcp.RECEIPT_EXCHANGE_DATE end,
             p_currency_code     => rec_rcp.RECEIPT_CURRENCY_CODE,
             p_amount => rec_rcp.amount,
             p_receipt_number => rec_rcp.receipt_number,
             p_receipt_date => rec_rcp.receipt_date,
             p_gl_date => rec_rcp.gl_date,
             --p_customer_number => 1007,
             p_customer_id => l_cust_acct_id,
             --p_receipt_method_id => l_rec_mthd,
             p_receipt_method_name => l_receipt_method_name,
             --p_remittance_bank_account_id => l_remittance_bank_account_id,
             p_remittance_bank_account_num => l_remittance_bank_account_num,
             p_remittance_bank_account_name => l_remittance_bank_account_name,
             p_org_id => l_org_id,
             p_cr_id => l_cash_receipt_id,
             p_attribute_rec => l_attribute_rec);

            -- 3) Review the API output
            xxconv_common_pkg.write_log('Status ' || l_return_status);
            xxconv_common_pkg.write_log('Message count ' || l_msg_count);
            xxconv_common_pkg.write_log('Cash Receipt Id ' || l_cash_receipt_id);

            if l_return_status <> 'S' then
                if l_msg_count = 1 Then
                   xxconv_common_pkg.write_log('l_msg_data '|| l_msg_data);
                   l_error_msg := l_msg_data;
                elsif l_msg_count > 1 Then
                   loop
                      p_count := p_count + 1;
                      l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
                      if l_msg_data is NULL Then
                         exit;
                      end if;
                      xxconv_common_pkg.write_log('Message ' || p_count ||'. '||l_msg_data);
                      l_error_msg := l_error_msg || ' ' ||l_msg_data;
                   end loop;
                end if;

                update xxconv_ar_receipts  xxrcp
                set    xxrcp.status_flag   = 'E',
                       xxrcp.error_message = error_message||substr(decode(error_message, null, null, ' | ')||l_error_msg, 1, 4000)
                where  rowid              = rec_rcp.rowid;            
            end if;

        end loop;




        commit;
    END load_ar_receipts;

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
            from xxconv_ar_receipts
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
    update xxconv_ar_receipts
    set    status_flag = 'P'
    where  request_id  = c_request_id;

    --
    -- Commit changes.
    --
    commit;

    --
    -- Lookup Operating Unit ID.
    --
    merge into xxconv_ar_receipts  xxrcp
    using (
           select xxrcp.request_id,
                  xxrcp.operating_unit_name,
                  hrou.organization_id
           from   (
                   select distinct
                          request_id,
                          operating_unit_name
                   from   xxconv_ar_receipts
                   where  request_id = c_request_id
                  )  xxrcp,
                  hr_operating_units  hrou
           where  hrou.name = upper(xxrcp.operating_unit_name)
          )  hrou
    on    (
               xxrcp.request_id          = hrou.request_id
           and xxrcp.operating_unit_name = hrou.operating_unit_name
          )
    when matched then
      update set xxrcp.org_id = hrou.organization_id;

    commit;  
    --
    -- Validation.
    --

    xxconv_common_pkg.write_log('Data Conversion: Begin Validation.');

    for rec_rcp in (
        select xxrcp.rowid,
                xxrcp.seq_num,
                xxrcp.OPERATING_UNIT_NAME,
                decode(hrou.organization_id, null, 'N', 'Y')  is_operating_unit_valid,
                xxrcp.account_number,
                decode(hca.account_number, null, 'N', 'Y')  is_acc_exist,
                xxrcp.receipt_method_name,
                xxrcp.REMIT_BANK_ACCOUNT_NAME,
                xxrcp.REMIT_BANK_ACCOUNT_NUM,
                decode(bank_acc.BANK_ACCOUNT_NUM, null, 'N', 'Y')  is_bank_acc_exist,
                xxrcp.receipt_currency_code,
                decode(fccy.currency_code, null, 'N', 'Y')  is_currency_valid
            from xxconv_ar_receipts xxrcp,
                hr_operating_units  hrou,
                hz_cust_accounts hca,
                (
                    select rm.receipt_method_id 
                            ,cba.bank_account_id
                            ,rm.name rcp_method
                            ,cba.BANK_ACCOUNT_NAME
                            ,cba.BANK_ACCOUNT_NUM
                            ,rma.start_date
                    from AR_RECEIPT_METHOD_ACCOUNTS_ALL rma,
                        ar_receipt_methods rm, 
                        ce_bank_accounts cba,
                        ce_bank_acct_uses_all ba
                    where  rma.receipt_method_id = rm.receipt_method_id
                    and rma.remit_bank_acct_use_id = ba.bank_acct_use_id
                    and cba.bank_account_id = ba.bank_account_id
                    --and rm.name = rec_rcp.receipt_method_name
                    --and cba.BANK_ACCOUNT_NAME = rec_rcp.REMIT_BANK_ACCOUNT_NAME
                    --and cba.BANK_ACCOUNT_NUM = rec_rcp.REMIT_BANK_ACCOUNT_NUM 
                ) bank_acc,
                fnd_currencies fccy
        where  xxrcp.request_id                = c_request_id
        and    hrou.name                  (+) = xxrcp.operating_unit_name
        and    hca.account_number         (+) = xxrcp.account_number
        --and    hcu.customer_name          (+) = cust.customer_name
        and    bank_acc.rcp_method        (+) = xxrcp.receipt_method_name
        and    bank_acc.BANK_ACCOUNT_NUM  (+) = xxrcp.remit_bank_account_num
        and    bank_acc.start_date        (+) <= xxrcp.receipt_date
        and    fccy.currency_code         (+) = xxrcp.receipt_currency_code
        )
    loop

      v_error_msg := null;

        if rec_rcp.is_operating_unit_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Operating Unit] (VALUE= '||rec_rcp.operating_unit_name||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        if rec_rcp.is_acc_exist = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Customer Account Number] (VALUE= '||rec_rcp.account_number||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        if rec_rcp.is_bank_acc_exist = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Bank Account] (VALUE= '||rec_rcp.remit_bank_account_num||') with [Receipt Method] (VALUE= '||rec_rcp.receipt_method_name||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;

        if rec_rcp.is_currency_valid = 'N' then
            b_abort := true;
            v_text  := 'Invalid [Currency Code] (VALUE= '||rec_rcp.receipt_currency_code||').';
            xxconv_common_pkg.append_message(v_error_msg, v_text);
        end if;        

      --
      -- Update Error Message.
      --
      if v_error_msg is not null then

        update xxconv_ar_receipts  xxrcp
        set    xxrcp.status_flag   = 'E',
               xxrcp.error_message = error_message||substr(decode(error_message, null, null, ' | ')||v_error_msg, 1, 1000)
        where  rowid              = rec_rcp.rowid;

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

    if b_abort then

      raise e_abort;

    end if;

    --
    -- Call Supplier Bank API.
    --

    load_ar_receipts;

    --
    -- Update the record was uploaded.
    --
    update xxconv_ar_receipts  
    set    status_flag = 'C'
    where  request_id  = c_request_id
    and    status_flag = 'P';

    commit;

  exception
    when e_abort then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: AR Receipts failed. '||v_abort_msg, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: AR Receipts failed.');
      xxconv_common_pkg.write_log(v_abort_msg);
      xxconv_common_pkg.write_log('');
    when others then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: AR Receipts failed. '||sqlerrm, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: AR Receipts failed.');
      xxconv_common_pkg.write_log(sqlerrm);
      xxconv_common_pkg.write_log('');
  end main;

end xxconv_ar_receipts_pkg;

/
