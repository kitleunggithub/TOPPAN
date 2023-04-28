--------------------------------------------------------
--  DDL for Package Body XXBS_TRX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXBS_TRX_PUB" as

/*******************************************************************************
 *
 * Module Name : Custom Billing
 * Package Name: XXBS_TRX_PUB
 *
 * Author      : DASH Kit Leung
 * Date        : 07-JAN-2020
 *
 * Purpose     : Custom Billing Transaction API
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung   07-JAN-2020   Initial Release.
 *
 *******************************************************************************/
    --Global constants to be used in error messages
    G_PKG_NAME      CONSTANT VARCHAR2(30) := 'XXBS_TRX_PUB';
    G_USER_ID       CONSTANT NUMBER := FND_GLOBAL.user_id;
    G_LOGIN_ID      CONSTANT NUMBER := FND_GLOBAL.login_id;

    PROCEDURE insert_bs_trx_hdr
    ( p_bs_hdr_rec             IN OUT NOCOPY XXBS_CUSTOMER_TRX%ROWTYPE
    )
    IS
    BEGIN
        p_bs_hdr_rec.CUSTOMER_TRX_ID               := XXBS_CUSTOMER_TRX_S.nextval;

        if p_bs_hdr_rec.AR_TRX_NUMBER is null then
            p_bs_hdr_rec.AR_TRX_NUMBER                 := XXBS_AR_TRX_NUMBER_S.nextval;
        end if;

        p_bs_hdr_rec.CREATED_BY                    := G_USER_ID;   
        p_bs_hdr_rec.CREATION_DATE                 := SYSDATE;        
        p_bs_hdr_rec.LAST_UPDATED_BY               := G_USER_ID;    
        p_bs_hdr_rec.LAST_UPDATE_DATE              := SYSDATE;
        p_bs_hdr_rec.LAST_UPDATE_LOGIN             := G_LOGIN_ID;
        p_bs_hdr_rec.INVOICE_FOOT_BOTTOM           := 'NOTES:'||CHR(10)||'1.  This is a computer generated invoice.  No signature is required.';

        insert into XXBS_CUSTOMER_TRX values p_bs_hdr_rec;
    EXCEPTION WHEN OTHERS THEN
        raise_application_error(-20001,G_PKG_NAME||'.INSERT_BS_TRX_HDR Error: '||SQLCODE||' - '||SQLERRM);    
    END insert_bs_trx_hdr;

    PROCEDURE insert_salesrep
    ( p_salerep_rec             IN OUT NOCOPY XXBS_REP_SPLITS%ROWTYPE
    )
    IS
    BEGIN
        p_salerep_rec.REP_SPLIT_ID                  := XXBS_REP_SPLITS_S.nextval;
        p_salerep_rec.CREATED_BY                    := G_USER_ID;   
        p_salerep_rec.CREATION_DATE                 := SYSDATE;        
        p_salerep_rec.LAST_UPDATED_BY               := G_USER_ID;    
        p_salerep_rec.LAST_UPDATE_DATE              := SYSDATE;
        p_salerep_rec.LAST_UPDATE_LOGIN             := G_LOGIN_ID; 

        insert into XXBS_REP_SPLITS values p_salerep_rec;
    EXCEPTION WHEN OTHERS THEN
        raise_application_error(-20001,G_PKG_NAME||'.INSERT_SALESREP Error: '||SQLCODE||' - '||SQLERRM);    
    END insert_salesrep;

    PROCEDURE create_bs_trx
    ( p_api_version_number      IN  NUMBER 
     ,p_commit                  IN  VARCHAR2    := FND_API.G_FALSE
     ,p_msg                    OUT  NOCOPY VARCHAR2
     ,p_return_status          OUT  NOCOPY VARCHAR2 
     ,p_bs_hdr_in               IN  bs_hdr_in_rec_type
     ,p_bs_hdr_out             OUT  NOCOPY  bs_hdr_out_rec_type
     ,p_salerep_in              IN  salerep_in_tbl_type
     ,p_salerep_out            OUT  NOCOPY  salerep_out_tbl_type
    )
    IS
        l_bs_hdr_rec        XXBS_CUSTOMER_TRX%ROWTYPE;
        l_salerep_rec       XXBS_REP_SPLITS%ROWTYPE;
        i                   NUMBER    := 0; --counter
    BEGIN
        SAVEPOINT create_bs_trx_pub;

        l_bs_hdr_rec := null;

        if p_bs_hdr_in.ORG_ID is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'ORG_ID is required';
        end if;

        if p_bs_hdr_in.ORIGINAL_PROJECT_ID is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'ORIGINAL_PROJECT_ID is required';
        end if;

        if p_bs_hdr_in.PERIOD_NAME is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'PERIOD_NAME is required';
        end if;

        if p_bs_hdr_in.TRX_DATE is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'TRX_DATE is required';
        end if;

        if p_bs_hdr_in.PRIMARY_PROJECT_ORG_ID is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'PRIMARY_PROJECT_ORG_ID is required';
        end if;

        if p_bs_hdr_in.PRIMARY_PRODUCT_TYPE_ID is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'PRIMARY_PRODUCT_TYPE_ID is required';
        end if;

        if p_bs_hdr_in.CURRENT_STATUS is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'CURRENT_STATUS is required';
        end if;

        if p_bs_hdr_in.OWNING_BILLER_ID is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'OWNING_BILLER_ID is required';
        end if;        

        if p_bs_hdr_in.ACTIVE_BILLER_ID is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'ACTIVE_BILLER_ID is required';
        end if;                

        if p_bs_hdr_in.BILL_TO_CUSTOMER_ID is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'BILL_TO_CUSTOMER_ID is required';
        end if;    

        if p_bs_hdr_in.BILL_TO_ADDRESS_ID is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'BILL_TO_ADDRESS_ID is required';
        end if;    

        if p_bs_hdr_in.INVOICE_ADDRESS_ID is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'INVOICE_ADDRESS_ID is required';
        end if;       

        if p_bs_hdr_in.TERM_ID is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'TERM_ID is required';
        end if;       

        if p_bs_hdr_in.ENTERED_CURRENCY_CODE is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'ENTERED_CURRENCY_CODE is required';
        end if;       

        if p_bs_hdr_in.EXCHANGE_DATE is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'EXCHANGE_DATE is required';
        end if;       

        if p_bs_hdr_in.EXCHANGE_RATE is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'EXCHANGE_RATE is required';
        end if;       

        if p_bs_hdr_in.EXCHANGE_RATE_TYPE is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'EXCHANGE_RATE_TYPE is required';
        end if;      

        if p_bs_hdr_in.INVOICE_CLASS is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'INVOICE_CLASS is required';
        end if;  

        if p_bs_hdr_in.INVOICE_STYLE_NAME is null then
            p_msg := case when p_msg is not null then p_msg||'| ' end ||'INVOICE_STYLE_NAME is required';
        end if;               

        if p_msg is not null then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: '||p_msg; 
            raise FND_API.G_EXC_ERROR;
        end if;

        l_bs_hdr_rec.AR_TRX_NUMBER  := p_bs_hdr_in.AR_TRX_NUMBER;

        begin
            select organization_id,set_of_books_id 
            into l_bs_hdr_rec.ORG_ID, l_bs_hdr_rec.SET_OF_BOOKS_ID
            from hr_operating_units
            where NVL(date_to,SYSDATE) >= SYSDATE
            and date_from <= SYSDATE
            and organization_id = p_bs_hdr_in.ORG_ID;        
        exception when others then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Invalid Operating Units';
            raise FND_API.G_EXC_ERROR;
        end;

        begin        
            select i.memo_line_id, j.attribute2
            into l_bs_hdr_rec.PRIMARY_PRODUCT_TYPE_ID,l_bs_hdr_rec.CUST_TRX_TYPE_ID
            from ar_memo_lines_all_tl i, ar_memo_lines_all_b j
            WHERE i.memo_line_id = j.memo_line_id 
            AND i.org_id = j.org_id 
            AND i.org_id = p_bs_hdr_in.ORG_ID
            AND i.memo_line_id = p_bs_hdr_in.PRIMARY_PRODUCT_TYPE_ID;        
        exception when others then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Invalid Primary Product Type';
            raise FND_API.G_EXC_ERROR;
        end;        

        if l_bs_hdr_rec.CUST_TRX_TYPE_ID is null then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Transaction Type is null (AR_MEMO_LINES_ALL_B.ATTRIBUTE2)';
            raise FND_API.G_EXC_ERROR;        
        end if;

        l_bs_hdr_rec.TRX_DATE               := p_bs_hdr_in.trx_date;
        l_bs_hdr_rec.DATE_RECEIVED          := p_bs_hdr_in.date_received;

        begin
            select gp.PERIOD_NAME 
            into l_bs_hdr_rec.period_name
            from gl_periods gp, gl_ledgers gl
            where gp.period_set_name = gl.period_set_name
            and gl.ledger_id = l_bs_hdr_rec.SET_OF_BOOKS_ID
            and gp.period_name = p_bs_hdr_in.period_name;
        exception when others then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Invalid Period Name';
            raise FND_API.G_EXC_ERROR;
        end;

        l_bs_hdr_rec.DESCRIPTION            := p_bs_hdr_in.description;
        l_bs_hdr_rec.COMMENTS               := p_bs_hdr_in.comments;

        begin
            select hcas.cust_acct_site_id
            into l_bs_hdr_rec.BILL_TO_ADDRESS_ID
            from hz_cust_accounts hca
                ,hz_cust_acct_sites_all     hcas
                ,hz_cust_site_uses_all      hcsu
            where hca.cust_account_id        = hcas.cust_account_id
            and hcsu.cust_acct_site_id   = hcas.cust_acct_site_id
            and hcsu.site_use_code         = 'BILL_TO'
            and hcas.org_id                = p_bs_hdr_in.org_id
            and hca.cust_account_id        = p_bs_hdr_in.bill_to_customer_id
            and hcas.cust_acct_site_id     = p_bs_hdr_in.bill_to_address_id;        
        exception when others then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Invalid Bill To Address';
            raise FND_API.G_EXC_ERROR;
        end;

        begin
            select cust_account_id
            into l_bs_hdr_rec.BILL_TO_CUSTOMER_ID
            from hz_cust_accounts_all
            where status = 'A'        
            and cust_account_id = p_bs_hdr_in.bill_to_customer_id;
        exception when others then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Invalid Customer Account';
            raise FND_API.G_EXC_ERROR;
        end;        

        --l_bs_hdr_rec.ATTENDEE               := p_bs_hdr_in.attendee;
        l_bs_hdr_rec.BILL_TO_CONTACT_ID     := p_bs_hdr_in.BILL_TO_CONTACT_ID;
        l_bs_hdr_rec.ATTENDEE_EMAIL         := p_bs_hdr_in.attendee_email;

        if p_bs_hdr_in.invoice_address_id is not null then
            begin        
                select hcas.cust_acct_site_id
                into l_bs_hdr_rec.INVOICE_ADDRESS_ID
                from hz_cust_accounts hca
                    ,hz_cust_acct_sites_all     hcas
                    ,hz_cust_site_uses_all      hcsu
                where hca.cust_account_id        = hcas.cust_account_id
                and hcsu.cust_acct_site_id   = hcas.cust_acct_site_id
                and hcsu.site_use_code         = 'BILL_TO'
                and hcas.org_id                = p_bs_hdr_in.org_id
                and hca.cust_account_id        = p_bs_hdr_in.bill_to_customer_id
                and hcas.cust_acct_site_id     = p_bs_hdr_in.invoice_address_id;
            exception when others then
                p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Invalid Invoice Address';
                raise FND_API.G_EXC_ERROR;
            end;
        end if;    

        l_bs_hdr_rec.ORDER_NUMBER  := p_bs_hdr_in.order_number;
        l_bs_hdr_rec.CUSTOMER_ORDER_NUMBER  := p_bs_hdr_in.customer_order_number;

        begin
            select distinct i.user_id
            into l_bs_hdr_rec.OWNING_BILLER_ID
            from fnd_user i, fnd_user_resp_groups_direct j,
            fnd_responsibility_tl k
            where i.user_id = j.user_id
            and j.responsibility_id = k.responsibility_id
            and k.responsibility_name like '%Biller%'
            and (i.End_Date is Null OR i.End_Date >= sysdate)
            and (j.End_Date is Null OR j.End_Date >= sysdate)
            and i.user_id = p_bs_hdr_in.owning_biller_id;
        exception when others then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Invalid Owning Biller';
            raise FND_API.G_EXC_ERROR;
        end;    

        begin
            select distinct i.user_id
            into l_bs_hdr_rec.ACTIVE_BILLER_ID
            from fnd_user i, fnd_user_resp_groups_direct j,
            fnd_responsibility_tl k
            where i.user_id = j.user_id
            and j.responsibility_id = k.responsibility_id
            and k.responsibility_name like '%Biller%'
            and (i.End_Date is Null OR i.End_Date >= sysdate)
            and (j.End_Date is Null OR j.End_Date >= sysdate)
            and i.user_id = p_bs_hdr_in.active_biller_id;
        exception when others then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Invalid Active Biller';
            raise FND_API.G_EXC_ERROR;
        end;

        l_bs_hdr_rec.CURRENT_STATUS_DATE := sysdate;

        begin        
            select term_id
            into l_bs_hdr_rec.TERM_ID
            from ra_terms
            WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
            and term_id = p_bs_hdr_in.term_id;

            select currency_code 
            into l_bs_hdr_rec.CURRENCY_CODE
            from gl_ledgers
            where ledger_id = l_bs_hdr_rec.SET_OF_BOOKS_ID;
        exception when others then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Invalid Payment Term';
            raise FND_API.G_EXC_ERROR;
        end;

        begin
            select currency_code
            into l_bs_hdr_rec.ENTERED_CURRENCY_CODE
            from fnd_currencies_vl
            where currency_code = p_bs_hdr_in.entered_currency_code;
        exception when others then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Entered Currency Code';
            raise FND_API.G_EXC_ERROR;
        end;        

            l_bs_hdr_rec.EXCHANGE_DATE := p_bs_hdr_in.exchange_date;
            l_bs_hdr_rec.EXCHANGE_RATE := p_bs_hdr_in.exchange_rate;


        l_bs_hdr_rec.EXCHANGE_RATE_TYPE := p_bs_hdr_in.exchange_rate_type;
        /*
        if l_bs_hdr_rec.EXCHANGE_RATE_TYPE <> 'User' then
        end if;
        */

        l_bs_hdr_rec.PROJECT_CATEGORY_ID  := p_bs_hdr_in.project_category_id;
        begin

            SELECT hrorg.organization_id
            INTO l_bs_hdr_rec.PRIMARY_PROJECT_ORG_ID
            from hr_organization_units hrorg, pa_all_organizations paorg 
            WHERE paorg.organization_id = hrorg.organization_id 
            and paorg.pa_org_use_type = 'EXPENDITURES' 
            and (paorg.inactive_date is NULL or paorg.inactive_date > sysdate)
            and (hrorg.date_to is NULL or hrorg.date_to > sysdate)
            and paorg.org_id = p_bs_hdr_in.org_id
            and paorg.organization_id = p_bs_hdr_in.primary_project_org_id;

            /*
            SELECT paorg.organization_id
            INTO l_bs_hdr_rec.PRIMARY_PROJECT_ORG_ID
            FROM xxpa_organizations_v paorg
            WHERE paorg.org_id = p_bs_hdr_in.org_id
            AND paorg.organization_id = p_bs_hdr_in.primary_project_org_id;
            */
        exception when others then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Invalid Project Carrying Out Organization';
            raise FND_API.G_EXC_ERROR;
        end;        

        begin        
            select ppa.project_id
            into l_bs_hdr_rec.ORIGINAL_PROJECT_ID
            from pa_projects_all ppa
            where ppa.org_id = l_bs_hdr_rec.ORG_ID
            and ppa.project_id = p_bs_hdr_in.original_project_id;
        exception when others then
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Invalid Project';
            raise FND_API.G_EXC_ERROR;
        end;                

        l_bs_hdr_rec.SOURCE_SYSTEM := p_bs_hdr_in.source_system;
        l_bs_hdr_rec.PROJECT_COMPLETE_DATE := p_bs_hdr_in.project_complete_date;
        l_bs_hdr_rec.COST_SUM_SEND_DATE := p_bs_hdr_in.cost_sum_send_date;
        l_bs_hdr_rec.MARGIN_REPORT_SEND_DATE  := p_bs_hdr_in.margin_report_send_date;
        l_bs_hdr_rec.BILL_REMARK := p_bs_hdr_in.bill_remark;

        /*
        if p_bs_hdr_in.invoice_class not in ('Normal', 'Parent', 'Child') then

        end if;
        */
        l_bs_hdr_rec.INVOICE_CLASS := p_bs_hdr_in.invoice_class;

        /*
        if p_bs_hdr_in.current_status not in ('Created') then

        end if;
        */
        l_bs_hdr_rec.CURRENT_STATUS := p_bs_hdr_in.current_status;

        l_bs_hdr_rec.INVOICE_STYLE_NAME := p_bs_hdr_in.invoice_style_name;

        -- billing header handling
        insert_bs_trx_hdr(l_bs_hdr_rec);

        -- billing header output
        p_bs_hdr_out.CUSTOMER_TRX_ID        := l_bs_hdr_rec.CUSTOMER_TRX_ID;
        p_bs_hdr_out.AR_TRX_NUMBER          := l_bs_hdr_rec.AR_TRX_NUMBER;
        p_bs_hdr_out.RETURN_STATUS          := 'S';

        -- salerep handling
        i := p_salerep_in.first;

        IF NOT p_salerep_in.exists(i)
        THEN
            p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: At Least One Salerep Information is required';
            raise FND_API.G_EXC_ERROR;        
        END IF;

        IF p_salerep_in.exists(i)
        THEN
            WHILE i IS NOT NULL LOOP
                l_salerep_rec := null;

                --l_salerep_rec.customer_trx_id :=p_salerep_in(i).customer_trx_id;
                l_salerep_rec.customer_trx_id := p_bs_hdr_out.CUSTOMER_TRX_ID;

                IF p_salerep_in(i).salesrep_id is null Then
                    p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: Salerep is required';
                    raise FND_API.G_EXC_ERROR;                        
                End IF;

                SELECT RESOURCE_ID
                INTO l_salerep_rec.salesrep_id
                FROM JTF_RS_DEFRESOURCES_V
                WHERE NVL(end_date_active,SYSDATE) >= SYSDATE
                AND RESOURCE_ID = p_salerep_in(i).salesrep_id
                ORDER BY resource_name;

                if i = p_salerep_in.first then
                    l_salerep_rec.primary_flag := 'Y';
                else
                    l_salerep_rec.primary_flag := 'N';
                end if;

                l_salerep_rec.split_percentage := p_salerep_in(i).split_percentage;

                insert_salesrep(l_salerep_rec);
                p_salerep_out(i).REP_SPLIT_ID           := l_salerep_rec.REP_SPLIT_ID;
                p_salerep_out(i).CUSTOMER_TRX_ID        := l_salerep_rec.CUSTOMER_TRX_ID;
                p_salerep_out(i).RETURN_STATUS          := 'S';

                i := p_salerep_in.next(i);
            END LOOP;
        END IF;

        IF FND_API.to_boolean( p_commit ) THEN
          COMMIT;
        END IF;

        p_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK to create_bs_trx_pub;
        p_return_status             := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK to create_bs_trx_pub;
        p_return_status             := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        ROLLBACK;
        --ROLLBACK to create_bs_trx_pub;            
        p_msg := G_PKG_NAME||'.CREATE_BS_TRX Error: '||SQLCODE||' - '||SQLERRM;
        p_return_status             := FND_API.G_RET_STS_ERROR;
        --p_bs_hdr_out.return_status  := FND_API.G_RET_STS_ERROR;
    END;    
end XXBS_TRX_PUB;

/
