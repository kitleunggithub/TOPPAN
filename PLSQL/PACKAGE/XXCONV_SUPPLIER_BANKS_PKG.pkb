--------------------------------------------------------
--  DDL for Package Body XXCONV_SUPPLIER_BANKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXCONV_SUPPLIER_BANKS_PKG" as
/*******************************************************************************
 *
 * Module Name : Payables
 * Package Name: XXCONV_SUPPLIER_BANKS_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-OCT-2020
 *
 * Purpose     : This program will upload Suppliers.
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung    30-OCT-2020   Initial Release.
 *
 *******************************************************************************/

  e_abort       exception;

  c_appl_name   constant varchar2(50) := 'SQLAP';
  --c_resp_key    constant varchar2(50) := 'PAYABLES_MANAGER';
  c_resp_key    constant varchar2(50) := 'XXAP_SETUP';
  c_program_name constant varchar2(50) := 'XXCONV_SUPPLIER_BANKS';

  c_newline     constant varchar2(1)  := fnd_global.newline;
  c_msg_length  constant number(15)   := 1000;
  c_errbuf_max  constant number(15)   := 240;
  c_request_id           number(15)   := fnd_global.conc_request_id;
  c_user_id     constant number(15)   := fnd_global.user_id;
  c_login_id    constant number(15)   := fnd_global.login_id;
  c_sysdate     constant date         := sysdate;

    PROCEDURE load_bank_accounts
    AS
        CURSOR cur_xxconv_supplier_banks
        IS
        select 'SUPPLIER_SITE' association_level, 
                hou.organization_id org_id,
                xxsupb.*
        from  xxconv_supplier_banks xxsupb,
              hr_operating_units  hrou,
              hr_organization_units hou
        where nvl(status_flag, 'N') = 'P'
        and xxsupb.request_id = c_request_id
        and (
                (
                    upper(xxsupb.operating_unit_name) is null
                    and hrou.short_code             in ('HK1_OU',
                                                        'HK2_OU'
                                                        )
                )
            or (
                upper(xxsupb.operating_unit_name)  = hrou.short_code
               )
            )                       
        and hrou.organization_id = hou.organization_id    
        order by priority asc, association_level asc;

        l_ext_bank_acct_rec             IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type;
        l_ext_bank_type_rec                 iby_ext_bankacct_pub.extbank_rec_type;
        l_ext_bank_branch_rec           iby_ext_bankacct_pub.extbankbranch_rec_type;

        cursor cur_supplier (p_segment1 VARCHAR2, p_vendor_name VARCHAR2)
        IS
        SELECT  *
        FROM    ap_suppliers
        WHERE   segment1 = p_segment1
        AND     vendor_name = p_vendor_name;

        cursor cur_bank (p_bank_number VARCHAR2, p_bank_name VARCHAR2)
        IS
        SELECT *
        FROM    iby_ext_banks_v
        WHERE   nvl(bank_number,'ZZ') = nvl(p_bank_number,'ZZ')
        AND     nvl(bank_name,'ZZ') = nvl(p_bank_name,'ZZ');

        cursor cur_bank_branch (p_bank_party_id NUMBER, p_branch_number VARCHAR2, p_bank_branch_name VARCHAR2)
        IS
        SELECT  *
        FROM    IBY_EXT_BANK_BRANCHES_V 
        WHERE   bank_party_id = p_bank_party_id 
        AND     nvl(branch_number,'ZZ') = nvl(p_branch_number,'ZZ')
        AND     nvl(bank_branch_name,'ZZ') = nvl(p_bank_branch_name,'ZZ');

        l_count NUMBER;
        p_count number;
        l_api_version NUMBER := 1.0;
        l_init_msg_list VARCHAR2(1) := FND_API.G_FALSE;
        l_commit VARCHAR2(1) := FND_API.G_FALSE;
        --x_bank_id          NUMBER;
        --x_branch_id          NUMBER;
        x_acct_id          NUMBER;
        x_assign_id NUMBER;
        x_joint_acct_owner_id NUMBER;
        x_return_status VARCHAR2(2000);
        x_msg_count NUMBER(5);
        x_msg_data VARCHAR2(4000);
        x_response IBY_FNDCPT_COMMON_PUB.Result_rec_type;

        l_rec      IBY_DISBURSEMENT_SETUP_PUB.PayeeContext_rec_type;
        l_assign   IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
        l_assign_id NUMBER;
        l_party_site_id NUMBER;
        l_supplier_site_id NUMBER;
    BEGIN

        FOR rec_bank IN cur_xxconv_supplier_banks LOOP

            --x_bank_id := null;
            --x_branch_id := null;
            x_acct_id := null;
            x_assign_id := null;
            x_joint_acct_owner_id := null;
            x_return_status := null;
            x_msg_count := null;
            x_msg_data := null;
            x_response := null;

            l_rec := null;
            l_assign := null;
            l_assign_id := null;
            l_party_site_id := null;
            l_supplier_site_id := null;

            l_ext_bank_acct_rec := null;
            l_ext_bank_type_rec := null;
            l_ext_bank_branch_rec := null;            

            xxconv_common_pkg.write_log( 'cur_xxconv_supplier_banks = '|| rec_bank.vendor_name || ' / ' || rec_bank.VENDOR_NUMBER );
            l_ext_bank_acct_rec.object_version_number := 1.0;
            l_ext_bank_acct_rec.acct_owner_party_id := null;

            for rec IN cur_supplier (rec_bank.VENDOR_NUMBER, rec_bank.VENDOR_NAME) LOOP
                l_ext_bank_acct_rec.acct_owner_party_id := rec.party_id;
            END LOOP;


            l_ext_bank_acct_rec.acct_type           := rec_bank.bank_account_type;
            l_ext_bank_acct_rec.bank_account_num    := rec_bank.bank_account_num;
            l_ext_bank_acct_rec.bank_account_name   := rec_bank.bank_account_name;            
            l_ext_bank_acct_rec.start_date          := rec_bank.start_date;
            l_ext_bank_acct_rec.end_date            := rec_bank.end_date;
            l_ext_bank_acct_rec.country_code        := rec_bank.country_code;
            l_ext_bank_acct_rec.currency := rec_bank.BANK_ACCOUNT_CURRENCY;
            l_ext_bank_acct_rec.foreign_payment_use_flag := rec_bank.allow_int_payments;
            --l_ext_bank_acct_rec.payment_factor_flag := rec_bank.payment_factor_flag;


            /*        
            FOR rec IN cur_bank(rec_bank.bank_number, rec_bank.bank_name) LOOP
                l_ext_bank_acct_rec.bank_id := rec.bank_party_id;
            END LOOP;
            */

            --CHECK THT BANK EXIST OR NOT by passing bank name
            begin
                SELECT bank_party_id
                INTO l_ext_bank_acct_rec.bank_id
                FROM iby_ext_banks_v
                WHERE UPPER (nvl(bank_name,'ZZZZ')) = UPPER (nvl(rec_bank.bank_name,'ZZZZ'))
                AND UPPER (nvl(bank_number,'ZZZZ')) = UPPER (nvl(rec_bank.bank_number,'ZZZZ'))
                AND home_country = rec_bank.country_code
                AND bank_institution_type = 'BANK';

                xxconv_common_pkg.write_log( 'SKIP calling IBY_EXT_BANKACCT_PUB.create_ext_bank() : ' || l_ext_bank_acct_rec.bank_id);
            exception when no_data_found then
                -- if bank not exists, create new
                l_ext_bank_type_rec.institution_type := 'BANK';
                l_ext_bank_type_rec.bank_name        := rec_bank.bank_name;
                if rec_bank.country_code = 'JP' then
                    l_ext_bank_type_rec.bank_alt_name := rec_bank.bank_name;
                end if;    
                l_ext_bank_type_rec.bank_number      := rec_bank.bank_number;
                l_ext_bank_type_rec.country_code     := rec_bank.country_code;

                x_msg_data := NULL;

                xxconv_common_pkg.write_log( ' calling IBY_EXT_BANKACCT_PUB.create_ext_bank() ' );

                iby_ext_bankacct_pub.create_ext_bank(p_api_version   => 1.0,
                                                     p_init_msg_list => fnd_api.g_false,
                                                     p_ext_bank_rec  => l_ext_bank_type_rec,
                                                     x_bank_id       => l_ext_bank_acct_rec.bank_id,
                                                     x_return_status => x_return_status,
                                                     x_msg_count     => x_msg_count,
                                                     x_msg_data      => x_msg_data,
                                                     x_response      => x_response);

                xxconv_common_pkg.write_log( 'IBY_EXT_BANKACCT_PUB.create_ext_bank > Result_Code  ' || x_response.Result_Code);
                xxconv_common_pkg.write_log( 'x_bank_id : ' || l_ext_bank_acct_rec.bank_id);

                IF x_msg_count = 1 THEN
                    xxconv_common_pkg.write_log( 'x_msg_data ' || x_msg_data);
                ELSIF x_msg_count > 1 THEN
                    p_count := 0;
                    LOOP
                        p_count := p_count + 1;
                        x_msg_data := fnd_msg_pub.get (fnd_msg_pub.g_next, fnd_api.g_false);
                        IF x_msg_data IS NULL THEN
                            EXIT;
                        END IF;
                        xxconv_common_pkg.write_log( 'Message' || p_count || ' ---' || x_msg_data);
                    END LOOP;
                END IF;

            end;

            /*
            FOR rec IN cur_bank_branch(l_ext_bank_acct_rec.bank_id, rec_bank.branch_number, rec_bank.branch_name) LOOP
                l_ext_bank_acct_rec.branch_id := rec.branch_party_id;
            END LOOP;
            */           

            begin
                --CHECK BRANCH OF THAT BANK OR NOT by passing branch number
                SELECT  branch_party_id
                INTO    l_ext_bank_acct_rec.branch_id
                FROM    IBY_EXT_BANK_BRANCHES_V 
                WHERE   bank_party_id = l_ext_bank_acct_rec.bank_id 
                AND     nvl(branch_number,'ZZZZ') = nvl(rec_bank.branch_number,'ZZZZ')
                AND     UPPER (nvl(bank_branch_name,'ZZZZ')) = UPPER (nvl(rec_bank.branch_name,'ZZZZ'));

                xxconv_common_pkg.write_log( 'SKIP calling IBY_EXT_BANKACCT_PUB.CREATE_EXT_BANK_BRANCH() : ' || l_ext_bank_acct_rec.branch_id);
            exception when no_data_found then

                l_ext_bank_branch_rec.bch_object_version_number := 1.0;
                l_ext_bank_branch_rec.branch_name := rec_bank.branch_name;
                if rec_bank.country_code = 'JP' then
                    l_ext_bank_branch_rec.alternate_branch_name := rec_bank.branch_name;
                end if;                
                l_ext_bank_branch_rec.branch_number := rec_bank.branch_number;
                l_ext_bank_branch_rec.bic := rec_bank.bic;
                l_ext_bank_branch_rec.branch_type :=rec_bank.branch_type;
                l_ext_bank_branch_rec.bank_party_id := l_ext_bank_acct_rec.bank_id;

                x_msg_data := NULL;

                xxconv_common_pkg.write_log( ' calling IBY_EXT_BANKACCT_PUB.CREATE_EXT_BANK_BRANCH() ' );

                IBY_EXT_BANKACCT_PUB.CREATE_EXT_BANK_BRANCH
                ( 
                    p_api_version                   => 1.0,
                    p_init_msg_list                  => fnd_api.g_true,
                    p_ext_bank_branch_rec            => l_ext_bank_branch_rec,
                    x_branch_id                      => l_ext_bank_acct_rec.branch_id,
                    x_return_status                => x_return_status,
                    x_msg_count                     => x_msg_count,
                    x_msg_data                       => x_msg_data,
                    x_response                        => x_response
                );

                xxconv_common_pkg.write_log( 'IBY_EXT_BANKACCT_PUB.CREATE_EXT_BANK_BRANCH > Result_Code  ' || x_response.Result_Code);
                xxconv_common_pkg.write_log( 'x_branch_id : ' || l_ext_bank_acct_rec.branch_id);

                IF x_msg_count = 1 THEN
                    xxconv_common_pkg.write_log( 'x_msg_data ' || x_msg_data);
                ELSIF x_msg_count > 1 THEN
                    p_count := 0;
                    LOOP
                        p_count := p_count + 1;
                        x_msg_data := fnd_msg_pub.get (fnd_msg_pub.g_next, fnd_api.g_false);
                        IF x_msg_data IS NULL THEN
                            EXIT;
                        END IF;
                        xxconv_common_pkg.write_log( 'Message' || p_count || ' ---' || x_msg_data);
                    END LOOP;
                END IF;

            end;

            l_count:=0;
            x_acct_id := null;
            xxconv_common_pkg.write_log( 'acct_owner_party_id   = '|| l_ext_bank_acct_rec.acct_owner_party_id  );
            xxconv_common_pkg.write_log( 'bank_id               = '|| l_ext_bank_acct_rec.bank_id  );
            xxconv_common_pkg.write_log( 'branch_id             = '|| l_ext_bank_acct_rec.branch_id  );
            xxconv_common_pkg.write_log( 'bank_account_num      = '|| l_ext_bank_acct_rec.bank_account_num );

            BEGIN
                select  ieba.ext_bank_account_id
                into    x_acct_id 
                from    iby_ext_bank_accounts ieba, IBY_ACCOUNT_OWNERS iao
                where   1=1
                and     ieba.bank_id        = l_ext_bank_acct_rec.bank_id 
                and     ieba.branch_id      = l_ext_bank_acct_rec.branch_id
                and     bank_account_num    = l_ext_bank_acct_rec.bank_account_num
                AND     ieba.ext_bank_account_id = iao.ext_bank_account_id 
                and     iao.account_owner_party_id = l_ext_bank_acct_rec.acct_owner_party_id;
            EXCEPTION WHEN OTHERS THEN
                null;
            END;

            BEGIN 
                select ass.vendor_site_id, ass.party_site_id
                into l_supplier_site_id, l_party_site_id
                from ap_suppliers a , 
                    --hz_party_sites p, 
                    ap_supplier_sites_all ass
                where   a.vendor_id = ass.vendor_id
                --and     p.party_id = a.party_id 
                --and     ass.party_site_id = p.party_site_id
                and     a.vendor_name = rec_bank.vendor_name
                and     a.segment1 = rec_bank.vendor_number
                --and     p.party_site_name = rec_bank.vendor_site_code
                and     ass.vendor_site_code = rec_bank.vendor_site_code
                and     ass.org_id = rec_bank.org_id;                            
            END;            

    --If Bank Account not existed, then create
            IF x_acct_id is not null then
                xxconv_common_pkg.write_log( ' SKIP calling IBY_EXT_BANKACCT_PUB.create_ext_bank_acct() x_acct_id : ' ||x_acct_id);
            ELSE
                BEGIN
                    select  ieba.ext_bank_account_id
                    into    x_acct_id 
                    from    iby_ext_bank_accounts ieba, IBY_ACCOUNT_OWNERS iao
                    where   1=1
                    and     ieba.bank_id        = l_ext_bank_acct_rec.bank_id 
                    and     ieba.branch_id      = l_ext_bank_acct_rec.branch_id
                    and     bank_account_num    = l_ext_bank_acct_rec.bank_account_num
                    AND     ieba.ext_bank_account_id = iao.ext_bank_account_id 
                    and     iao.account_owner_party_id <> l_ext_bank_acct_rec.acct_owner_party_id ;
                EXCEPTION WHEN OTHERS THEN
                    null;
                END;

                IF x_acct_id is not null then
                    xxconv_common_pkg.write_log( ' calling IBY_EXT_BANKACCT_PUB.add_joint_account_owner() ' );
                    IBY_EXT_BANKACCT_PUB.add_joint_account_owner
                        (
                            p_api_version           => 1.0,
                            p_init_msg_list         => fnd_api.g_true,
                            p_bank_account_id       => x_acct_id,
                            p_acct_owner_party_id   => l_ext_bank_acct_rec.acct_owner_party_id,
                            x_joint_acct_owner_id   => x_joint_acct_owner_id ,                        
                            x_return_status         => x_return_status, 
                            x_msg_count             => x_msg_count, 
                            x_msg_data              => x_msg_data, 
                            x_response              => x_response 
                        );
                ELSE
                    xxconv_common_pkg.write_log( ' calling IBY_EXT_BANKACCT_PUB.create_ext_bank_acct() ' );

                    IBY_EXT_BANKACCT_PUB.create_ext_bank_acct(
                        p_api_version       => l_api_version, 
                        p_init_msg_list     => l_init_msg_list, 
                        p_ext_bank_acct_rec => l_ext_bank_acct_rec, 
                        /*
                        p_association_level => 'SS',
                        p_supplier_site_id  => l_supplier_site_id,
                        p_party_site_id     => l_party_site_id,
                        p_org_id            => rec_bank.org_id,
                        p_org_type          => rec_bank.org_type,
                        */                        
                        x_acct_id           => x_acct_id, 
                        x_return_status     => x_return_status, 
                        x_msg_count         => x_msg_count, 
                        x_msg_data          => x_msg_data, 
                        x_response          => x_response 
                    );
                END IF;
                xxconv_common_pkg.write_log( 'IBY_EXT_BANKACCT_PUB.create_ext_bank_acct > Result_Code  ' || x_response.Result_Code);
                xxconv_common_pkg.write_log( 'x_acct_id : ' || x_acct_id);
                IF x_msg_count = 1 THEN
                    xxconv_common_pkg.write_log( 'x_msg_data ' || x_msg_data);
                ELSIF x_msg_count > 1 THEN
                    p_count := 0;
                    LOOP
                        p_count := p_count + 1;
                        x_msg_data := fnd_msg_pub.get (fnd_msg_pub.g_next, fnd_api.g_false);
                        IF x_msg_data IS NULL THEN
                            EXIT;
                        END IF;
                        xxconv_common_pkg.write_log( 'Message' || p_count || ' ---' || x_msg_data);
                    END LOOP;
                END IF; 
            END IF;
                --IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                    xxconv_common_pkg.write_log( 'IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment');

                    IF rec_bank.association_level = 'SUPPLIER' THEN
                        l_rec.Party_Site_id         := null;
                        l_rec.Supplier_Site_id      := null;
                        l_rec.Org_Id                := null;
                        l_rec.Org_Type              := null;
                        for rec IN cur_supplier (rec_bank.vendor_number,rec_bank.vendor_name) LOOP
                        l_rec.party_id              := rec.party_id;                        
                        end loop;
                    ELSIF rec_bank.association_level = 'SUPPLIER_SITE' THEN

                        l_rec.Party_Site_id         := l_party_site_id;
                        l_rec.Supplier_Site_id      := l_supplier_site_id;
                        l_rec.Org_Id                := rec_bank.org_id;
                        l_rec.Org_Type              := 'OPERATING_UNIT';
                    /*    
                    ELSIF rec_bank.association_level = 'ADDRESS_OU' THEN
                        l_rec.Party_Site_id         := p_party_site_id;
                        l_rec.Org_Id                := p_org_id;
                        l_rec.Org_Type              := 'OPERATING_UNIT';
                        l_rec.Supplier_Site_id      := NULL;
                    */
                    ELSIF rec_bank.association_level = 'ADDRESS_ONLY' THEN

                        BEGIN 
                            select distinct p.party_site_id
                            INTO l_party_site_id
                            from ap_suppliers a , hz_party_sites p,ap_supplier_sites_all ass
                            where   a.vendor_id = ass.vendor_id
                            and     ass.party_site_id = p.party_site_id
                            and     a.vendor_name = rec_bank.vendor_name
                            and     a.segment1 = rec_bank.vendor_number
                            and     ass.vendor_site_code = rec_bank.vendor_site_code
                            and     p.party_id = a.party_id ;
                        END;
                        l_rec.Party_Site_id         := l_party_site_id;
                        l_rec.Supplier_Site_id      := NULL;
                        l_rec.Org_Id                := NULL;
                        l_rec.Org_Type              := NULL;

                    END IF;
                    /*
                    l_rec.Party_Site_id                 := p_party_site_id;
                    l_rec.Supplier_Site_id              := p_supplier_site_id;
                    l_rec.Org_Id                        := p_org_id;
                    l_rec.Org_Type                      := p_org_type;
                    */

                    l_rec.Payment_Function              := 'PAYABLES_DISB';
                    l_rec.Party_Id                      := l_ext_bank_acct_rec.acct_owner_party_id;

                    xxconv_common_pkg.write_log( 'l_rec.Payment_Function   > ' ||l_rec.Payment_Function);
                    xxconv_common_pkg.write_log( 'l_rec.Party_Id           > ' ||l_rec.Party_Id);
                    xxconv_common_pkg.write_log( 'l_rec.Party_Site_id      > ' ||l_rec.Party_Site_id);
                    xxconv_common_pkg.write_log( 'rec_bank.vendor_site_code > ' || rec_bank.vendor_site_code);
                    xxconv_common_pkg.write_log( 'l_rec.Org_Id           > ' ||l_rec.Org_Id);
                    xxconv_common_pkg.write_log( 'l_rec.Org_Type      > ' ||l_rec.Org_Type);                    
                    xxconv_common_pkg.write_log( 'x_acct_id                > ' ||x_acct_id);


                    l_assign.Instrument.Instrument_Type := 'BANKACCOUNT';
                    l_assign.start_date                 := l_ext_bank_acct_rec.start_date;
                    l_assign.end_date                   := l_ext_bank_acct_rec.end_date;
                    l_assign.Instrument.Instrument_Id   := x_acct_id;
                    l_assign.priority                   := rec_bank.priority;

                    /* API call to assing the bank account to the Payee*/
                    IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment(
                        p_api_version        =>   l_api_version,
                        p_init_msg_list    	 =>   'F',
                        p_commit           	 =>   NULL,
                        x_return_status    	 =>   x_return_status,
                        x_msg_count        	 =>   x_msg_count,
                        x_msg_data         	 =>   x_msg_data,
                        p_payee            	 =>   l_rec,
                        p_assignment_attribs =>   l_assign,
                        x_assign_id        	 =>   l_assign_id,
                        x_response         	 =>   x_response);

                    xxconv_common_pkg.write_log( 'IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment > x_response.Result_Code ' || x_response.Result_Code);
                    xxconv_common_pkg.write_log( 'Result_Category : ' || x_response.Result_Category );
                    xxconv_common_pkg.write_log( 'Result_Message  : ' || x_response.Result_Message  );
                    /*
                    update xxconv_supplier_banks
                    set     status_flag = x_response.Result_Code
                    where   vendor_number = rec_bank.vendor_number
                    and     bank_account_num = rec_bank.bank_account_num
                    and     bank_account_name= rec_bank.bank_account_name
                    and     bank_number = rec_bank.bank_number
                    and     bank_name  = rec_bank.bank_name
                    and     branch_number = rec_bank.branch_number;
                    */
        END LOOP;

        commit;
    END load_bank_accounts;

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
            from xxconv_supplier_banks
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
    update xxconv_supplier_banks
    set    status_flag = 'P'
    where  request_id  = c_request_id;

    --
    -- Commit changes.
    --
    commit;

    --
    -- Validation.
    --

    xxconv_common_pkg.write_log('Data Conversion: Begin Validation.');

    for rec_bank in (
                    select xxsb.rowid  row_id,
                        xxsb.seq_num,
                        xxsb.vendor_name,
                        decode(vndr.vendor_id, null, 'N', 'Y')  is_vendor_exist,
                        xxsb.vendor_site_code,
                        decode(vnd_site.vendor_site_code, null, 'N', 'Y')  is_vendor_site_exist,
                        xxsb.country_code,
                        decode(cnty.territory_code, null, 'N', 'Y')  is_country_valid,
                        xxsb.branch_type,
                        decode(flv_bt.lookup_code, null, 'N', 'Y')  is_branch_type_valid,
                        xxsb.bic,
                        case when xxsb.bic is not null and not (length(xxsb.bic) = 8 or length(xxsb.bic) = 11) then
                            'N' 
                        else
                            'Y'
                        end is_bic_valid,
                        xxsb.bank_account_currency,
                        decode(cur.currency_code, null, 'N', 'Y')  is_cur_exist,
                        xxsb.bank_account_num,
                        decode(bank_num.bank_account_num, null, 'N', 'Y') is_bank_acc_number_exist,
                        xxsb.bank_account_name,
                        decode(bank_acc.bank_account_num, null, 'N', 'Y') is_bank_acc_name_exist,
                        xxsb.bank_account_type,
                        case when xxsb.bank_account_type is not null and bank_acc_type.lookup_code is null then 'N' else 'Y' end is_bank_acc_type_valid
                    from xxconv_supplier_banks xxsb,
                        (
                            select upper(vendor_name)  vendor_name, vendor_id,party_id
                            from   ap_suppliers  vndr
                            --where  nvl(vendor_type_lookup_code, 'XX') != 'EMPLOYEE'
                            --and    employee_id                        is null
                        )  vndr,
                        (
                            select upper(ap.vendor_name) vendor_name,ap.segment1,assa.vendor_site_code 
                            from ap_suppliers ap,ap_supplier_sites_all assa
                            where ap.vendor_id = assa.vendor_id
                            group by ap.vendor_name,ap.segment1,assa.vendor_site_code
                            having count(*) >=2 -- both ou must exists
                        ) vnd_site,
                        fnd_territories_tl      cnty,
                        (
                            select LOOKUP_CODE from FND_LOOKUP_VALUES
                            where LOOKUP_TYPE = 'BANK BRANCH TYPE'
                            and enabled_flag = 'Y'
                            and source_lang = 'US'
                        ) flv_bt,
                        FND_CURRENCIES cur,
                        (
                            select  distinct ap.vendor_name,ieb.bank_name,iebb.bank_branch_name,ieba.bank_account_name,ieba.bank_account_num--,ieba.ext_bank_account_id
                            from    iby_ext_banks_v ieb, IBY_EXT_BANK_BRANCHES_V iebb, iby_ext_bank_accounts ieba, IBY_ACCOUNT_OWNERS iao, ap_suppliers ap
                            where   1=1
                            and     ieba.bank_id        = ieb.bank_party_id 
                            and     ieba.branch_id      = iebb.branch_party_id
                            AND     ieba.ext_bank_account_id = iao.ext_bank_account_id 
                            and     iao.account_owner_party_id = ap.party_id
                        ) bank_num,
                        (
                            select  distinct ap.vendor_name,ieb.bank_name,iebb.bank_branch_name,ieba.bank_account_name,ieba.bank_account_num--,ieba.ext_bank_account_id
                            from    iby_ext_banks_v ieb, IBY_EXT_BANK_BRANCHES_V iebb, iby_ext_bank_accounts ieba, IBY_ACCOUNT_OWNERS iao, ap_suppliers ap
                            where   1=1
                            and     ieba.bank_id        = ieb.bank_party_id 
                            and     ieba.branch_id      = iebb.branch_party_id
                            AND     ieba.ext_bank_account_id = iao.ext_bank_account_id 
                            and     iao.account_owner_party_id = ap.party_id
                        ) bank_acc,
                        (
                            select LOOKUP_CODE 
                            from CE_LOOKUPS
                            WHERE lookup_type = 'BANK_ACCOUNT_TYPE'                        
                        ) bank_acc_type
                    where xxsb.request_id = c_request_id
                    and   vndr.vendor_name           (+) = upper(xxsb.vendor_name)
                    and   vnd_site.vendor_name       (+) = upper(xxsb.vendor_name)
                    and   vnd_site.vendor_site_code  (+) = xxsb.vendor_site_code
                    and   upper(cnty.territory_code  (+))= upper(xxsb.COUNTRY_CODE)
                    and   flv_bt.lookup_code         (+) = xxsb.branch_type
                    and   cur.CURRENCY_CODE          (+) = xxsb.bank_account_currency
                    and   bank_num.bank_name         (+) = xxsb.bank_name
                    and   bank_num.bank_branch_name  (+) = xxsb.branch_name
                    and   bank_num.vendor_name       (+) = xxsb.vendor_name
                    and   bank_num.bank_account_num  (+) = xxsb.bank_account_num                    
                    and   bank_acc.bank_name         (+) = xxsb.bank_name
                    and   bank_acc.bank_branch_name  (+) = xxsb.branch_name
                    and   bank_acc.vendor_name       (+) = xxsb.vendor_name
                    and   bank_acc.bank_account_name (+) = xxsb.bank_account_name                    
                    and   bank_acc_type.lookup_code  (+) = xxsb.bank_account_type                    
                    )
    loop

      v_error_msg := null;

      if rec_bank.vendor_name is null then

        b_abort := true;
        v_text  := '[Supplier Name] is missing.';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_bank.is_vendor_exist = 'N' then
        b_abort := true;
        v_text  := 'Invalid [Vendor] (VALUE= '||rec_bank.vendor_name||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);
      end if;      

      if rec_bank.vendor_site_code is null then

        b_abort := true;
        v_text  := '[Supplier Site Name] is missing.';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_bank.is_vendor_site_exist = 'N' then
        b_abort := true;
        v_text  := 'Invalid [Vendor Site Code] (VALUE= '||rec_bank.vendor_site_code||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);
      end if;      

      if rec_bank.is_country_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Country] (VALUE= '||rec_bank.country_code||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_bank.is_branch_type_valid = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Branch Type] (VALUE= '||rec_bank.branch_type||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;

      if rec_bank.is_bic_valid = 'N' then

        b_abort := true;
        v_text  := 'Length of [BIC] must be 8 or 11 (VALUE= '||rec_bank.bic||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);

      end if;      

      if rec_bank.is_cur_exist = 'N' then

        b_abort := true;
        v_text  := 'Invalid [Bank Currency] (VALUE= '||rec_bank.BANK_ACCOUNT_CURRENCY||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);
      end if;      

      if rec_bank.is_bank_acc_number_exist = 'Y' then
        b_abort := true;
        v_text  := '[Bank Account Number] (VALUE= '||rec_bank.bank_account_num||') already exists.';
        xxconv_common_pkg.append_message(v_error_msg, v_text);
      end if;  

      if rec_bank.is_bank_acc_name_exist = 'Y' then
        b_abort := true;
        v_text  := '[Bank Account Name] (VALUE= '||rec_bank.bank_account_name||') already exists.';
        xxconv_common_pkg.append_message(v_error_msg, v_text);
      end if;        

      if rec_bank.is_bank_acc_type_valid = 'N' then
        b_abort := true;
        v_text  := 'Invalid [Bank Account Type] (VALUE= '||rec_bank.bank_account_type||').';
        xxconv_common_pkg.append_message(v_error_msg, v_text);
      end if;              


      --
      -- Update Error Message.
      --
      if v_error_msg is not null then

        update xxconv_supplier_banks  site
        set    site.status_flag   = 'E',
               site.error_message = error_message||substr(decode(error_message, null, null, ' | ')||v_error_msg, 1, 1000)
        where  rowid              = rec_bank.row_id;

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

    load_bank_accounts;

    --
    -- Update the record was uploaded.
    --
    update xxconv_supplier_banks  
    set    status_flag = 'C'
    where  request_id  = c_request_id
    and    status_flag = 'P';

    commit;

  exception
    when e_abort then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: Supplier Banks failed. '||v_abort_msg, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: Suppliers failed.');
      xxconv_common_pkg.write_log(v_abort_msg);
      xxconv_common_pkg.write_log('');
    when others then
      rollback;
      retcode := '2';
      errbuf  := substr('Data Conversion: Supplier Banks failed. '||sqlerrm, 1, c_errbuf_max);
      xxconv_common_pkg.write_log('');
      xxconv_common_pkg.write_log('Data Conversion: Supplier Banks failed.');
      xxconv_common_pkg.write_log(sqlerrm);
      xxconv_common_pkg.write_log('');
  end main;

end xxconv_supplier_banks_pkg;


/
