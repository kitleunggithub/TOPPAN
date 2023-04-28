--------------------------------------------------------
--  File created - Wednesday-July-14-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body XXIBY_PAYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXIBY_PAYMENT_PKG" 
IS

/*******************************************************************************
 *
 * Module Name : Payables
 * Package Name: XXIBY_PAYMENT_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-JUN-2020
 *
 * Purpose     : Customization for validation and transfer of payment file 
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung   30-JUN-2021   Initial Release.
 *
 *******************************************************************************/
 
    G_PROGRAM_NAME CONSTANT VARCHAR2(100) := 'XXIBY_PAYMENT_PKG';
    G_REQUEST_ID CONSTANT NUMBER(20)   := fnd_global.conc_request_id;
    G_DELIMITER  CONSTANT VARCHAR2(2)  :='|';
    G_STYLESHEET CONSTANT XMLTYPE := xmltype.createxml(
                                        '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                                            <xsl:template match="node()|@*">
                                               <xsl:copy>
                                                  <xsl:apply-templates select="node()|@*"/>
                                               </xsl:copy>
                                            </xsl:template>
                                        </xsl:stylesheet>');
    
    PROCEDURE VALIDATE_PAYMENT
        ( p_payment_id                   IN VARCHAR2
        , p_error_code                   OUT NUMBER
        , p_error_msg                    OUT VARCHAR2        
        )
    IS
  
    BEGIN
    
        --fnd_file.put_line(FND_FILE.LOG,p_payment_id);

        FOR rec IN (SELECT ipa.payment_method_code 
                        ,ipa.payee_party_id
                        ,ipa.external_bank_account_id
                        ,nvl(ieba.bank_account_name,asa.vendor_name) payee_name
                        ,translate(nvl(ieba.bank_account_name,asa.vendor_name),'!@$%&*()_+{}|:"<>?-\'',./','X') translate_payee_name
                        ,ieba.bank_account_name
                        ,asa.vendor_name
                        ,ipa.ext_bank_branch_party_id
                        ,substr(cbb.branch_number,1,3) bank_code
                        ,substr(cbb.branch_number,4,6) branch_code
                        ,ieba.bank_account_num
                        ,ieba.country_code bank_country_code
                        ,ipa.PARTY_SITE_ID
                        ,ipa.SUPPLIER_SITE_ID
                        ,DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.address_line1,assa.address_line1) address_line1
                        ,DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.address_line2,assa.address_line2) address_line2
                        ,DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.address_line3,assa.address_line3) address_line3
                        ,DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',null,assa.address_line4) address_line4
                        ,DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.town_or_city,assa.city) city
                        ,DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',null,NVL(assa.state, assa.province)) state
                        ,DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.country,assa.country) country
                        ,DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.postal_code,assa.zip) postal_code
                        ,ipa.payment_currency_code
                        ,cbb.eft_swift_code BIC
                        ,asa.attribute2 payment_purpose
                        ,iia.bic interme_bic 
                    FROM iby_payments_all ipa
                        ,hz_parties hp
                        ,per_addresses padd                        
                        ,iby_ext_bank_accounts ieba
                        ,(SELECT row_number() OVER(PARTITION BY bank_acct_id ORDER BY intermediary_acct_id) row_num,intermediary_acct_id,bank_acct_id,bic FROM iby_intermediary_accts) iia
                        ,ce_bank_branches_v cbb
                        ,ap_suppliers asa
                        ,ap_supplier_sites_all assa
                    WHERE ipa.org_id = FND_PROFILE.VALUE('ORG_ID')
                    and ipa.payment_id = p_payment_id 
                    and ipa.payee_party_id = hp.party_id
                    and hp.party_id = padd.party_id (+)
                    AND ipa.external_bank_account_id = ieba.ext_bank_account_id (+)
                    AND ipa.external_bank_account_id = iia.bank_acct_id (+)
                    AND iia.row_num (+) = 1                    
                    AND ipa.ext_bank_branch_party_id = cbb.branch_party_id (+)
                    AND ipa.payee_supplier_id = asa.vendor_id
                    AND ipa.supplier_site_id = assa.vendor_site_id
                   )
        LOOP
            --validate rule for all payment type
            if rec.payee_name is null then
                p_error_code := 2;
                p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Payee Bank Account Name cannot be null.';
            end if;            
            
            if rec.payee_name != rec.translate_payee_name then
                p_error_code := 2;
                p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Payee Bank Account Name cannot have special characters.';
            end if;
            
            --validate rule for all payment type ACH, PP and TT payment
            if rec.payment_method_code IN ('HSBC_ACH','HSBC_PP','HSBC_TT') then
                --check the payment account number is numeric 
                if NOT (TRIM(translate(rec.bank_account_num, '0123456789', ' ')) IS NULL) then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Account Number must be numeric.';
                end if;
                
                --check the payment account number is not null 
                if rec.bank_account_num is null or trim(rec.bank_account_num) = '' then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Account Number must not be null.';
                end if;
            end if;
            
            --validate rule for ACH only
            if rec.payment_method_code = 'HSBC_ACH' then

                if rec.branch_code is null or trim(rec.branch_code) = '' then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Branch Number must not be null.';
                end if;

                if NOT (TRIM(translate(rec.branch_code, '0123456789', ' ')) IS NULL) then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Branch Number must be numeric.';
                end if;
                
                if length(rec.bank_account_num) < 6 or length(rec.bank_account_num) > 9 then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Bank Account Number must be 6 to 9 digits.';
                end if;
                
                if rec.bank_country_code <> 'HK' then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Creditor Bank Account must be in HK.';
                end if;

                if rec.bank_code is null or trim(rec.bank_code) = '' then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Creditor Bank Code must not be null.';
                end if;

                if NOT (TRIM(translate(rec.bank_code, '0123456789', ' ')) IS NULL) then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Creditor Bank Code must be numeric.';
                end if;

                if rec.payment_currency_code <> 'HKD' then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'ACH payment currency must be in HKD. Please void payment and validate the invoice.';
                end if;
            end if;
            
            --validate rule for TT only
            if rec.payment_method_code = 'HSBC_TT' then
                if --rec.country in ('CN','MY','PH','IN') 
                    rec.bank_country_code in ('BD','CN','IN','ID','MY','MU','PH','LK','VN')
                then
                    
                    if rec.payment_purpose is null then
                        p_error_code := 2;
                        p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Payment Purpose cannot be null for a payment paid to Country BD, CN, IN, ID, MY, MU, PH, LK and VN.';
                    end if;                    
                    
                    if substr(rec.payment_purpose,1,1) = '/' 
                        or substr(rec.payment_purpose,36,1) = '/' 
                        or substr(rec.payment_purpose,71,1) = '/'
                    then
                        p_error_code := 2;
                        p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Please DON''T use stroke "/" at position 1, 36 and 71 of Payment Purpose';
                    end if;                                            
                end if;

                if rec.payment_currency_code in ('TWD','MYR','IDR') then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'TT payment currency must not be in TWD, MYR or IDR.';
                end if;    
                
                if rec.bic is null or trim(rec.bic) = '' then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'BIC code is mandatory.';
                end if;                
            end if;

            --validate rule for PP only
            if rec.payment_method_code = 'HSBC_PP' then
                if rec.bic is null or trim(rec.bic) = '' then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'BIC code is mandatory.';
                end if;    
            end if;
            
            --validate rule for ICO only
            if rec.payment_method_code = 'HSBC_ICO' then
                if rec.payment_currency_code not in ('HKD','USD') then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'ICO payment currency must be in HKD or USD. Please void payment and validate the invoice.';
                end if;
                
                if length(trim(rec.address_line1||' '||rec.address_line2)) > 70 then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Address line 1 and line 2 together must not exceed 70 characters.';
                end if;
                
                if length(trim(rec.address_line3||' '||rec.address_line4)) > 35 then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Address line 3 and address line 4 together must not exceed 35 characters.';
                end if;                

                if length(rec.city) > 35 then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'City must not exceed 35 characters.';
                end if;
                
                if length(rec.postal_code) > 16 then
                    p_error_code := 2;
                    p_error_msg := case when p_error_msg is not null then p_error_msg||G_DELIMITER end || 'Postal Code must not exceed 16 characters.';
                end if;                
            end if;
        END LOOP;
    EXCEPTION    
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001,G_PROGRAM_NAME||'.VALIDATE_PAYMENT - Validate Payment Error');        
    END VALIDATE_PAYMENT;

    PROCEDURE GEN_VALIDATE_XML
        ( p_payment_batch_id                   IN VARCHAR2
        , p_payment_method_code                IN VARCHAR2
        )
    IS
    
        l_formatxml_data XMLTYPE;
        l_xml_data XMLTYPE;
    
        CURSOR rec_cur IS    
        select xmlelement("XXIBY_PAYMENT_VALIDATION",
                 xmlelement("P_PAYMENT_BATCH_ID",p_payment_batch_id)
                 , xmlelement("P_PAYMENT_METHOD_CODE",p_payment_method_code)
                   , xmlagg(xmlelement("G_REPORT_HDR",         
                       xmlelement("PAYMENT_BATCH_ID",aca.attribute1)
                     , xmlelement("PAYMENT_METHOD_CODE",ipa.payment_method_code)
                       , xmlagg(xmlelement("G_REPORT_LINE",
                           xmlelement("PARTY_ID",ipa.payee_party_id)
                         , xmlelement("PAYMENT_DATE",to_char(ipa.payment_date,'DD-MON-YYYY'))
                         , xmlelement("PAYMENT_PROCESS_REQUEST",ipa.payment_process_request_name)
                         , xmlelement("PAYMENT_CODE",case when p_payment_method_code = 'HSBC_ACH' and ipa.employee_payment_flag = 'Y' then 'O03' when p_payment_method_code = 'HSBC_ACH' and ipa.employee_payment_flag = 'N' then 'O02' else null end)
                         , xmlelement("PAYMENT_DOCUMENT_NUMBER",nvl(ipa.paper_document_number,ipa.payment_reference_number))
                         , xmlelement("PAYEE_NAME",asa.vendor_name)
                         , xmlelement("PAYEE_BANK_COUNTRY",ieba.country_code)
                         , xmlelement("PAYEE_BANK_ACCOUNT_NAME",ieba.bank_account_name)
                         , xmlelement("PAYEE_BANK_CODE",substr(cbb.branch_number,1,3))
                         , xmlelement("PAYEE_BIC_CODE",cbb.eft_swift_code)
                         , xmlelement("PAYEE_BANK_BRANCH_CODE",substr(cbb.branch_number,4,6))
                         , xmlelement("PAYEE_BANK_ACCOUNT_NUM",ieba.bank_account_num)
                         , xmlelement("PAYMENT_CURRENCY",ipa.payment_currency_code)
                         , xmlelement("PAYMENT_AMOUNT",ipa.payment_amount)
                         , xmlelement("PAYMENT_PURPOSE",case when p_payment_method_code = 'HSBC_TT' then asa.attribute2 else null end)
                         , xmlelement("PAYEE_ADDRESS_LINE_1_2",substr(trim(DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.address_line1,assa.address_line1)||' '||DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.address_line2,assa.address_line2)),1,70))
                         , xmlelement("PAYEE_ADDRESS_LINE_3_4",substr(trim(DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.address_line3,assa.address_line3)||' '||DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',null,assa.address_line4)),1,35))
                         , xmlelement("PAYEE_CITY",substr(DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.town_or_city,assa.city),1,35))
                         , xmlelement("PAYEE_STATE",DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',null,NVL(assa.state, assa.province)))
                         , xmlelement("PAYEE_POSTAL_CODE",substr(DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.postal_code,assa.zip),1,16))
                         , xmlelement("PAYEE_COUNTRY",DECODE(asa.vendor_type_lookup_code,'EMPLOYEE',padd.country,assa.country))
                         , xmlelement("BANK_CHARGE_BEARER",nvl(asa.attribute3,'DEBT'))
                         , xmlelement("INTERMEDIATE_BANK_BIC_CODE",iia.bic)
                         , xmlelement("REMIT_EMAIL",(select email_address
                                                    from ar.hz_contact_points
                                                    where contact_point_type = 'EMAIL'
                                                    and owner_table_name = 'HZ_PARTY_SITES'
                                                    and status = 'A'
                                                    and owner_table_id = assa.party_site_id))                         
                         , xmlelement("VALIDATION_MESSAGE",aca.attribute2)
            ))))) as xml_data
        FROM iby_payments_all ipa
            ,ap_checks_all aca
            ,hz_parties hp
            ,per_addresses padd
            ,iby_ext_bank_accounts ieba
            ,(SELECT row_number() OVER(PARTITION BY bank_acct_id ORDER BY intermediary_acct_id) row_num,intermediary_acct_id,bank_acct_id,bic FROM iby_intermediary_accts) iia
            ,ce_bank_branches_v cbb
            ,ap_suppliers asa
            ,ap_supplier_sites_all assa
        WHERE ipa.payment_id = aca.payment_id
        AND ipa.payee_party_id = hp.party_id
        AND hp.party_id = padd.party_id (+)
        AND ipa.external_bank_account_id = ieba.ext_bank_account_id (+)
        AND ipa.external_bank_account_id = iia.bank_acct_id (+)
        AND iia.row_num (+) = 1                    
        AND ipa.ext_bank_branch_party_id = cbb.branch_party_id (+)
        AND ipa.payee_supplier_id = asa.vendor_id
        AND ipa.supplier_site_id = assa.vendor_site_id
        AND ipa.org_id = FND_PROFILE.VALUE('ORG_ID')
        AND aca.attribute1 = p_payment_batch_id
        AND ipa.payment_method_code = p_payment_method_code
        GROUP BY aca.attribute1, ipa.payment_method_code;
    BEGIN    
         OPEN rec_cur;
         FETCH rec_cur INTO l_xml_data;
         CLOSE rec_cur;
         
         l_formatxml_data := l_xml_data.transform(G_STYLESHEET);
         
         xxcm_bi_reporting_pub.write_xml_output(l_formatxml_data.getClobVal());
    EXCEPTION    
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001,G_PROGRAM_NAME||'.GEN_VALIDATE_XML - Generate Validate XML Data Error');                 
    END GEN_VALIDATE_XML;


    PROCEDURE VALIDATION_MAIN
        ( p_errbuf                  OUT VARCHAR2
        , p_retcode                 OUT NUMBER
        , p_payment_method              IN VARCHAR2
        , p_payment_date                IN VARCHAR2
        , p_payment_process_request     IN VARCHAR2
        , p_specific_payment            IN VARCHAR2
        )
    IS
        l_error_code    varchar2(100);
        l_error_msg     varchar2(4000);  
        l_xml_data      XMLTYPE;
        
        e_input_para_error EXCEPTION;
    BEGIN
        fnd_file.put_line(FND_FILE.LOG,'P_PAYMENT_METHOD = ' || p_payment_method);
        fnd_file.put_line(FND_FILE.LOG,'P_PAYMENT_DATE = ' || p_payment_date);
        fnd_file.put_line(FND_FILE.LOG,'P_PAYMENT_PROCESS_REQUEST = ' || p_payment_process_request);
        fnd_file.put_line(FND_FILE.LOG,'P_SPECIFIC_PAYMENT = ' || p_specific_payment);

        IF (p_payment_method = 'HSBC_ACH' and p_specific_payment IS NULL) THEN
            p_errbuf := '(Invaild Input Parameter) For ACH Payment, ACH Specific Payment must Input.';
            RAISE e_input_para_error;
        END IF;    

        fnd_file.put_line(FND_FILE.LOG,'');
        fnd_file.put_line(FND_FILE.LOG,'Start Process Payment Validation.');        
        FOR rec IN (select ipa.payment_id,ipa.payment_process_request_name,ipa.payment_method_code 
                    from iby_payments_all ipa, AP_CHECKS_ALL aca
                    where ipa.payment_id = aca.payment_id
                    and ipa.payment_status in ('ISSUED','FORMATTED')
                    and ipa.process_type not in ('MANUAL')
                    and aca.attribute3 is null
                    and ipa.payment_method_code = p_payment_method
                    and (ipa.payment_date = to_date(p_payment_date,'YYYY/MM/DD HH24:MI:SS') or p_payment_date is null)
                    and (ipa.payment_service_request_id = p_payment_process_request or p_payment_process_request is null)
                    and (ipa.employee_payment_flag = DECODE(p_specific_payment,'Employees','Y','External Vendors','N') or p_specific_payment is null
                    )
                    )
        LOOP
            l_error_code := null;
            l_error_msg := null;       

            --fnd_file.put_line(FND_FILE.LOG,rec.payment_id);
            
            VALIDATE_PAYMENT(rec.payment_id,l_error_code,l_error_msg);

            fnd_file.put_line(FND_FILE.LOG,'');
            fnd_file.put_line(FND_FILE.LOG,'Payment ID ==> '||rec.payment_id);
            fnd_file.put_line(FND_FILE.LOG,'Payment Process Request Name ==> '||rec.payment_process_request_name);
            fnd_file.put_line(FND_FILE.LOG,'Payment Method ==> '||rec.payment_method_code);
            fnd_file.put_line(FND_FILE.LOG,'Validation Message ==> '|| l_error_msg);
            
            UPDATE ap_checks_all
            SET attribute1 = G_REQUEST_ID
                ,attribute2 = substr(l_error_msg,1,150)
            WHERE payment_id = rec.payment_id;
        END LOOP;
        fnd_file.put_line(FND_FILE.LOG,'');
        fnd_file.put_line(FND_FILE.LOG,'End Process Payment Validation.');        
        
        fnd_file.put_line(FND_FILE.LOG,'');
        fnd_file.put_line(FND_FILE.LOG,'Start Generate XML Data.');        
        
        GEN_VALIDATE_XML(G_REQUEST_ID,p_payment_method);

        fnd_file.put_line(FND_FILE.LOG,'');
        fnd_file.put_line(FND_FILE.LOG,'End Generate XML Data.');
        
        COMMIT;
    EXCEPTION 
        WHEN e_input_para_error THEN
            p_retcode := 2;
            ROLLBACK;    
        WHEN OTHERS THEN
            p_retcode := 2;
            p_errbuf := 'Program Process Error. Please contact your sysadmin.';
            FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
            ROLLBACK;        
    END VALIDATION_MAIN;

    PROCEDURE GEN_PAYMENT_XML_INS
        ( p_payment_instruction_id  IN NUMBER
        , p_xml_data                OUT XMLTYPE
        )
    IS
    BEGIN
        select instruction into p_xml_data 
        from iby_xml_fd_ins_1_0_v 
        where payment_instruction_id = p_payment_instruction_id;
    EXCEPTION 
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001,G_PROGRAM_NAME||'.GEN_PAYMENT_XML_INS - Generate Instruction XML Data Error');
    END GEN_PAYMENT_XML_INS;

    PROCEDURE GEN_PAYMENT_XML_PMT
        ( p_payment_id  IN NUMBER
        , p_xml_data    IN OUT XMLTYPE
        )
    IS
    BEGIN
        SELECT APPENDCHILDXML(p_xml_data,'/OutboundPaymentInstruction', payment) 
        INTO p_xml_data
        FROM iby_xml_fd_pmt_1_0_v 
        WHERE payment_id = p_payment_id;
    EXCEPTION 
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001,G_PROGRAM_NAME||'.GEN_PAYMENT_XML_PMT - Generate Payment XML Data Error');        
    END GEN_PAYMENT_XML_PMT;        

    PROCEDURE TRANSFER_MAIN
        ( p_errbuf                  OUT VARCHAR2
        , p_retcode                 OUT NUMBER
        , p_rerun                   IN VARCHAR2
        , p_payment_batch_id        IN VARCHAR2
        , p_payment_transfer_id     IN VARCHAR2
        , p_value_day               IN VARCHAR2
        )
    IS
        e_validate_error EXCEPTION;
        e_input_para_error EXCEPTION;
        e_gen_data_error EXCEPTION;
        
        l_creation_date VARCHAR2(20);        
        l_value_day VARCHAR2(11);
        
        l_xml_data XMLTYPE;
        l_formatXML XMLTYPE;
        l_layout_result BOOLEAN;
        l_valid BOOLEAN := TRUE;
        l_template VARCHAR2(250);
        
        l_cnt NUMBER;

    BEGIN

        fnd_file.put_line(FND_FILE.LOG,'P_RERUN = ' || p_rerun);
        fnd_file.put_line(FND_FILE.LOG,'P_PAYMENT_BATCH_ID = ' || p_payment_batch_id);
        fnd_file.put_line(FND_FILE.LOG,'P_PAYMENT_TRANSFER_ID = ' || p_payment_transfer_id);
        fnd_file.put_line(FND_FILE.LOG,'P_VALUE_DAY = ' || p_value_day);

        IF (p_rerun = 'NO' and p_payment_batch_id IS NULL) OR (p_rerun = 'YES' and p_payment_transfer_id IS NULL) THEN
            p_errbuf := '(Invaild Input Parameter) Either Payment Batch ID or Payment Transfer ID must Input.';
            RAISE e_input_para_error;
        END IF;    

        l_xml_data := null;
        
        l_value_day := to_char(to_date(p_value_day,'YYYY/MM/DD HH24:MI:SS'),'YYYY-MM-DD');

        SELECT to_char(sysdate,'yyyy-mm-dd"T"hh24:mi:ss')
        INTO l_creation_date
        FROM dual;
        
        CEP_STANDARD.init_security;
        
        -- generate standard raw xml data
        BEGIN
            FOR rec IN (SELECT ipa.payment_instruction_id
                                ,ipa.payment_id 
                                ,ipa.payment_process_request_name
                                ,ipa.payment_method_code
                                ,ipa.payment_amount
                        FROM IBY_PAYMENTS_ALL ipa
                            , AP_CHECKS_ALL aca
                        WHERE ipa.payment_id = aca.payment_id
                        AND ipa.payment_status in ('ISSUED','FORMATTED')
                        AND ipa.process_type not in ('MANUAL')
                        AND ( (p_rerun = 'NO' and aca.attribute1 = p_payment_batch_id) or (p_rerun = 'YES' and aca.attribute3 = p_payment_transfer_id) ) 
                        )
            LOOP
    
                VALIDATE_PAYMENT(rec.payment_id,p_retcode,p_errbuf);
                
                If p_retcode = 2 THEN
                    l_valid := FALSE;
                    fnd_file.put_line(FND_FILE.LOG,'Payment Validation Fail.');
                    fnd_file.put_line(FND_FILE.LOG,'Payment ID ==> '||rec.payment_id);
                    fnd_file.put_line(FND_FILE.LOG,'Payment Process Request Name ==> '||rec.payment_process_request_name);
                    fnd_file.put_line(FND_FILE.LOG,'Payment Method ==> '||rec.payment_method_code);
                    fnd_file.put_line(FND_FILE.LOG,'Validation Message ==> '|| p_errbuf);
                END IF;
                
                -- generate instruction xml data
                IF l_xml_data is NULL THEN
                    
                    GEN_PAYMENT_XML_INS(rec.payment_instruction_id,l_xml_data);
                    
                    -- remove the payment xml data
                    SELECT DELETEXML(l_xml_data,'/OutboundPaymentInstruction/OutboundPayment') 
                    INTO l_xml_data 
                    FROM dual;
                    
                    -- xml publisher template mapping
                    IF rec.payment_method_code = 'HSBC_ACH' THEN
                        l_template := 'XXIBY_PAYMENT_TRANSFER_ACH';
                    ELSIF rec.payment_method_code = 'HSBC_ICO' THEN
                        l_template := 'XXIBY_PAYMENT_TRANSFER_ICO';
                    ELSIF rec.payment_method_code = 'HSBC_PP' THEN
                        l_template := 'XXIBY_PAYMENT_TRANSFER_PP';
                    ELSIF rec.payment_method_code = 'HSBC_TT' THEN
                        l_template := 'XXIBY_PAYMENT_TRANSFER_TT';                    
                    END IF;
                END IF;
                
                -- generate payment xml data
                GEN_PAYMENT_XML_PMT(rec.payment_id,l_xml_data);
            END LOOP;
        EXCEPTION WHEN OTHERS THEN
            RAISE e_gen_data_error;
        END;
        
        IF NOT(l_valid) THEN
            RAISE e_validate_error;
        END IF;
        
        -- xml data transformation - instruction level
        SELECT updatexml( l_xml_data
                        , '/OutboundPaymentInstruction/PaymentInstructionInfo/InstructionCreationDate'
                        , '<InstructionCreationDate>'||l_creation_date||'</InstructionCreationDate>' )
        INTO l_xml_data
        FROM dual;
        
        -- xml data transformation - payment level
        -- update new payee information
        FND_FILE.PUT_LINE(FND_FILE.LOG,'');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Transform Payment XML Data.');
        l_cnt := 0;
        FOR rec_xml IN (
            SELECT to_char(xml_data.rn) AS idx
                 , xml_data.employeepaymentflag
                 , xml_data.paymentdocumentnumber
                 , xml_data.payeepartyinternalid
                 , xml_data.payeename AS old_payee_name
                 , asa.vendor_name AS new_payee_name
                 , xml_data.payeeattribute2 as old_payment_purpose
                 , asa.attribute2 as new_payment_purpose
                 , xml_data.payeeattribute3 as old_bearer_code
                 , asa.attribute3 as new_bearer_code
                 , xml_data.payeeaddressinternalid
                 , xml_data.payeeaddressline1
                 , xml_data.payeeaddressline2
                 , xml_data.payeeaddressline3
                 , xml_data.payeeaddressline4
                 , xml_data.payeeaddresscity
                 , xml_data.payeeaddresscounty
                 , xml_data.payeeaddressstate
                 , xml_data.payeeaddresscountry
                 , xml_data.payeeaddresspostalcode                
                 , xml_data.payeebankaccountinternalid
                 , xml_data.payeebankbranchinternalid
                 , xml_data.payeebankintermeaccountid
                 , xml_data.payeebankbranchnumber old_branch_number
                 , cbb.branch_number new_branch_number
                 , xml_data.payeebankaccountnumber old_bank_account_num
                 , ieba.bank_account_num new_bank_account_num
                 , xml_data.payeebankbic old_bic
                 , cbb.eft_swift_code new_bic
                 , xml_data.payeebankaccountname old_bank_account_name
                 , ieba.bank_account_name new_bank_account_name
                 , xml_data.payeebankcountry old_bank_country_code
                 , ieba.country_code new_bank_country_code
                 , xml_data.payeebankintermebic old_interme_bic
                 , iia.bic new_interme_bic
            FROM XMLTABLE('/OutboundPaymentInstruction/OutboundPayment' 
                          PASSING l_xml_data
                          COLUMNS rn FOR ORDINALITY
                                , employeepaymentflag VARCHAR2(10) PATH 'PaymentSourceInfo/EmployeePaymentFlag'
                                , paymentdocumentnumber VARCHAR2(300) PATH 'PaymentNumber/CheckNumber'
                                , payeepartyinternalid NUMBER PATH 'Payee/PartyInternalID'
                                , payeename VARCHAR2(300) PATH 'Payee/Name'
                                , payeeattribute2 VARCHAR2(300) PATH 'Payee/SupplierDescriptiveFlexField/Attribute2'
                                , payeeattribute3 VARCHAR2(300) PATH 'Payee/SupplierDescriptiveFlexField/Attribute3'
                                , payeeaddressinternalid NUMBER PATH 'Payee/Address/AddressInternalID'
                                , payeeaddressline1 VARCHAR2(300) PATH 'Payee/Address/AddressLine1'
                                , payeeaddressline2 VARCHAR2(300) PATH 'Payee/Address/AddressLine2'
                                , payeeaddressline3 VARCHAR2(300) PATH 'Payee/Address/AddressLine3'
                                , payeeaddressline4 VARCHAR2(300) PATH 'Payee/Address/AddressLine4'
                                , payeeaddresscity VARCHAR2(300) PATH 'Payee/Address/City'
                                , payeeaddresscounty VARCHAR2(300) PATH 'Payee/Address/County'
                                , payeeaddressstate VARCHAR2(300) PATH 'Payee/Address/State'
                                , payeeaddresscountry VARCHAR2(300) PATH 'Payee/Address/Country'
                                , payeeaddresspostalcode VARCHAR2(300) PATH 'Payee/Address/PostalCode'
                                , payeebankaccountinternalid NUMBER PATH 'PayeeBankAccount/BankAccountInternalID'
                                , payeebankbranchinternalid NUMBER PATH 'PayeeBankAccount/BranchInternalID'
                                , payeebankintermeaccountid NUMBER PATH 'PayeeBankAccount/IntermediaryBankAccount1/IntermediaryAccountID'
                                , payeebankbranchnumber VARCHAR2(300) PATH 'PayeeBankAccount/BranchNumber'
                                , payeebankaccountnumber VARCHAR2(300) PATH 'PayeeBankAccount/BankAccountNumber'
                                , payeebankbic VARCHAR2(300) PATH 'PayeeBankAccount/SwiftCode'
                                , payeebankaccountname VARCHAR2(300) PATH 'PayeeBankAccount/BankAccountName'
                                , payeebankcountry VARCHAR2(300) PATH 'PayeeBankAccount/BankAddress/Country'
                                , payeebankintermebic VARCHAR2(300) PATH 'PayeeBankAccount/IntermediaryBankAccount1/SwiftCode'
                        ) xml_data
                 ,hz_parties hp
                 ,ap_suppliers asa
                 ,iby_ext_bank_accounts ieba 
                 ,ce_bank_branches_v cbb
                 ,iby_intermediary_accts iia
            WHERE xml_data.payeepartyinternalid = hp.party_id
            AND hp.party_id = asa.party_id
            AND xml_data.payeebankaccountinternalid = ieba.ext_bank_account_id (+) 
            AND xml_data.payeebankbranchinternalid = cbb.branch_party_id (+) 
            AND xml_data.payeebankintermeaccountid = iia.intermediary_acct_id (+)
        )
        LOOP
            
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Document Number ==>'||rec_xml.paymentdocumentnumber);
            
            -- update value date
            --<PaymentDate>2021-06-17</PaymentDate>
            SELECT updatexml( l_xml_data
                            , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/PaymentDate'
                            , '<PaymentDate>'||l_value_day||'</PaymentDate>' )
            INTO l_xml_data
            FROM dual;

            -- update payee information
            -- handle null value update
            /*
            SELECT updatexml( l_xml_data
                            , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/Name/text()'
                            , rec_xml.new_payee_name )
            INTO l_xml_data
            FROM dual;
            */
           
            IF nvl(rec_xml.old_payee_name,'***') <> nvl(rec_xml.new_payee_name,'***') THEN
                SELECT updatexml( l_xml_data
                                , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/Name'
                                , '<Name>'||rec_xml.new_payee_name||'</Name>' )
                INTO l_xml_data
                FROM dual;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Payee Name: '||rec_xml.old_payee_name||' ==> '||rec_xml.new_payee_name);
            END IF;

            IF nvl(rec_xml.old_payment_purpose,'***') <> nvl(rec_xml.new_payment_purpose,'***') THEN
                SELECT updatexml( l_xml_data
                                , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/SupplierDescriptiveFlexField/Attribute2'
                                , '<Attribute2>'||rec_xml.new_payment_purpose||'</Attribute2>' )
                INTO l_xml_data
                FROM dual;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Payment Purpose: '||rec_xml.old_payment_purpose||' ==> '||rec_xml.new_payment_purpose);
            END IF;

            IF nvl(rec_xml.old_bearer_code,'***') <> nvl(rec_xml.new_bearer_code,'***') THEN
                SELECT updatexml( l_xml_data
                                , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/SupplierDescriptiveFlexField/Attribute3'
                                , '<Attribute3>'||rec_xml.new_bearer_code||'</Attribute3>' )
                INTO l_xml_data
                FROM dual;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Bearer Code: '||rec_xml.old_bearer_code||' ==> '||rec_xml.new_bearer_code);
            END IF;
            
            --update payee address information
            DECLARE
                l_payeeaddressline1 VARCHAR2(300);
                l_payeeaddressline2 VARCHAR2(300);
                l_payeeaddressline3 VARCHAR2(300);
                l_payeeaddressline4 VARCHAR2(300);
                l_payeeaddresscity VARCHAR2(300);
                --l_payeeaddresscounty VARCHAR2(300);
                l_payeeaddressstate VARCHAR2(300);
                l_payeeaddresscountry VARCHAR2(300);
                l_payeeaddresspostalcode VARCHAR2(300);
            BEGIN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Employee Payment Flag ==>'||rec_xml.employeepaymentflag);
                IF rec_xml.employeepaymentflag = 'Y' THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Payee Party Internal ID ==>'||rec_xml.payeepartyinternalid);
                    select address_line1,address_line2,address_line3,country,postal_code,town_or_city 
                    into l_payeeaddressline1,l_payeeaddressline2,l_payeeaddressline3,l_payeeaddresscountry,l_payeeaddresspostalcode,l_payeeaddresscity
                    from per_addresses
                    where party_id = rec_xml.payeepartyinternalid
                    and primary_flag = 'Y';
                ELSE
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Payee Address Internal ID ==>'||rec_xml.payeeaddressinternalid);
                    select address_line1,address_line2,address_line3,address_line4,city,NVL(state, province) state,zip,country
                    into l_payeeaddressline1,l_payeeaddressline2,l_payeeaddressline3,l_payeeaddressline4,l_payeeaddresscity,l_payeeaddressstate,l_payeeaddresspostalcode,l_payeeaddresscountry
                    from ap_supplier_sites_all
                    where vendor_site_id = rec_xml.payeeaddressinternalid;
                END IF;    

                IF nvl(rec_xml.payeeaddressline1,'***') <> nvl(l_payeeaddressline1,'***') THEN
                    SELECT updatexml( l_xml_data
                                    , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/Address/AddressLine1'
                                    , '<AddressLine1>'||l_payeeaddressline1||'</AddressLine1>')
                    INTO l_xml_data
                    FROM dual;
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Address Line 1: '||rec_xml.payeeaddressline1||' ==> '||l_payeeaddressline1);
                END IF;

                IF nvl(rec_xml.payeeaddressline2,'***') <> nvl(l_payeeaddressline2,'***') THEN                
                    SELECT updatexml( l_xml_data
                                    , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/Address/AddressLine2'
                                    , '<AddressLine2>'||l_payeeaddressline2||'</AddressLine2>')
                    INTO l_xml_data
                    FROM dual;
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Address Line 2: '||rec_xml.payeeaddressline2||' ==> '||l_payeeaddressline2);
                END IF;
                
                IF nvl(rec_xml.payeeaddressline3,'***') <> nvl(l_payeeaddressline3,'***') THEN            
                    SELECT updatexml( l_xml_data
                                    , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/Address/AddressLine3'
                                    , '<AddressLine3>'||l_payeeaddressline3||'</AddressLine3>' )
                    INTO l_xml_data
                    FROM dual;
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Address Line 3: '||rec_xml.payeeaddressline3||' ==> '||l_payeeaddressline3);
                END IF;
                
                IF nvl(rec_xml.payeeaddressline4,'***') <> nvl(l_payeeaddressline4,'***') THEN                
                    SELECT updatexml( l_xml_data
                                    , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/Address/AddressLine4'
                                    , '<AddressLine4>'||l_payeeaddressline4||'</AddressLine4>' )
                    INTO l_xml_data
                    FROM dual;                
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Address Line 4: '||rec_xml.payeeaddressline4||' ==> '||l_payeeaddressline4);
                END IF;
                
                IF nvl(rec_xml.payeeaddresscity,'***') <> nvl(l_payeeaddresscity,'***') THEN                
                    SELECT updatexml( l_xml_data
                                    , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/Address/City'
                                    , '<City>'||l_payeeaddresscity||'</City>' )
                    INTO l_xml_data
                    FROM dual;                
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'City: '||rec_xml.payeeaddresscity||' ==> '||l_payeeaddresscity);
                END IF;

                --Standard Logic ==> NVL(payee.payee_state, payee.payee_province)
                IF nvl(rec_xml.payeeaddressstate,'***') <> nvl(l_payeeaddressstate,'***') THEN                
                    SELECT updatexml( l_xml_data
                                    , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/Address/State'
                                    , '<State>'||l_payeeaddressstate||'</State>' )
                    INTO l_xml_data
                    FROM dual;                
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'State: '||rec_xml.payeeaddressstate||' ==> '||l_payeeaddressstate);
                END IF;

                IF nvl(rec_xml.payeeaddresspostalcode,'***') <> nvl(l_payeeaddresspostalcode,'***') THEN
                    SELECT updatexml( l_xml_data
                                    , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/Address/PostalCode'
                                    , '<PostalCode>'||l_payeeaddresspostalcode||'</PostalCode>' )
                    INTO l_xml_data
                    FROM dual;                
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Postal Code: '||rec_xml.payeeaddresspostalcode||' ==> '||l_payeeaddresspostalcode);
                END IF;

                IF nvl(rec_xml.payeeaddresscountry,'***') <> nvl(l_payeeaddresscountry,'***') THEN
                    SELECT updatexml( l_xml_data
                                    , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/Payee/Address/Country'
                                    , '<Country>'||l_payeeaddresscountry||'</Country>' )
                    INTO l_xml_data
                    FROM dual;    
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Country: '||rec_xml.payeeaddresscountry||' ==> '||l_payeeaddresscountry);
                END IF;
                
                --update branch information
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Payee Btanch Internal ID ==>'||rec_xml.payeebankbranchinternalid);
                IF rec_xml.payeebankbranchinternalid IS NOT NULL THEN
                    IF nvl(rec_xml.old_branch_number,'***') <> nvl(rec_xml.new_branch_number,'***') THEN                    
                        SELECT updatexml( l_xml_data
                                        , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/PayeeBankAccount/BranchNumber'
                                        , '<BranchNumber>'||rec_xml.new_branch_number||'</BranchNumber>' )
                        INTO l_xml_data
                        FROM dual;    
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bank Branch Number: '||rec_xml.old_branch_number||' ==> '||rec_xml.new_branch_number);
                    END IF;

                    IF nvl(rec_xml.old_bic,'***') <> nvl(rec_xml.new_bic,'***') THEN                    
                        SELECT updatexml( l_xml_data
                                        , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/PayeeBankAccount/SwiftCode'
                                        , '<SwiftCode>'||rec_xml.new_bic||'</SwiftCode>' )
                        INTO l_xml_data
                        FROM dual;                    
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bank BIC: '||rec_xml.old_bic||' ==> '||rec_xml.new_bic);
                    END IF;
                END IF;

                --update bank account information
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Payee Bank Account ID ==>'||rec_xml.payeebankaccountinternalid);
                IF rec_xml.payeebankaccountinternalid IS NOT NULL THEN
                    /*
                    SELECT updatexml( l_xml_data
                                    , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/PayeeBankAccount/BankAccountNumber'
                                    , '<BankAccountNumber>'||rec_xml.new_bank_account_num||'</BankAccountNumber>' )
                    INTO l_xml_data
                    FROM dual;                    
                    */
                    IF nvl(rec_xml.old_bank_account_name,'***') <> nvl(rec_xml.new_bank_account_name,'***') THEN
                        SELECT updatexml( l_xml_data
                                        , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/PayeeBankAccount/BankAccountName'
                                        , '<BankAccountName>'||rec_xml.new_bank_account_name||'</BankAccountName>' )
                        INTO l_xml_data
                        FROM dual;
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bank Account Name: '||rec_xml.old_bank_account_name||' ==> '||rec_xml.new_bank_account_name);
                    END IF;
        
                    IF nvl(rec_xml.old_bank_country_code,'***') <> nvl(rec_xml.new_bank_country_code,'***') THEN
                        SELECT updatexml( l_xml_data
                                        , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/PayeeBankAccount/BankAddress/Country'
                                        , '<Country>'||rec_xml.new_bank_country_code||'</Country>' )
                        INTO l_xml_data
                        FROM dual;                    
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bank Country Code: '||rec_xml.old_bank_country_code||' ==> '||rec_xml.new_bank_country_code);
                    END IF;
                END IF;
                
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Payee Intermedate Bank Internal ID ==>'||rec_xml.payeebankintermeaccountid);
                --update intermedeate bank account1 information
                /*
                IF rec_xml.payeebankintermeaccountid IS NOT NULL THEN
                    SELECT updatexml( l_xml_data
                                    , '/OutboundPaymentInstruction/OutboundPayment['||rec_xml.idx||']/PayeeBankAccount/IntermediaryBankAccount1/SwiftCode'
                                    , '<SwiftCode>'||rec_xml.new_interme_bic||'</SwiftCode>' )
                    INTO l_xml_data
                    FROM dual;                    
                END IF;
                */
                FND_FILE.PUT_LINE(FND_FILE.LOG,'');
                
                l_cnt := l_cnt + 1;
            END;
        END LOOP;
        FND_FILE.PUT_LINE(FND_FILE.LOG,'End Transform Payment XML Data.');
        
        l_formatXML := l_xml_data.transform(G_STYLESHEET);
        
        --SFTP the xml file to HSBC, only the xml file contain payment record
        if l_cnt > 0 then
            l_layout_result := xxcm_bi_reporting_pub.apply_printer('HSBCNet_SFTP',1);
        end if;
        
        l_layout_result := xxcm_bi_reporting_pub.apply_template(l_template);
        --l_layout_result := xxcm_bi_reporting_pub.apply_template('XXIBY_PAYMENT_TRANSFER_TT');
        
        xxcm_bi_reporting_pub.write_xml_output(l_formatXML.getClobVal());
        
        UPDATE ap_checks_all aca
        SET aca.attribute3 = G_REQUEST_ID
        WHERE ( (p_rerun = 'NO' and aca.attribute1 = p_payment_batch_id) or (p_rerun = 'YES' and aca.attribute3 = p_payment_transfer_id) );
        
        COMMIT;
    EXCEPTION 
        WHEN e_input_para_error THEN
            p_retcode := 2;
            ROLLBACK;
        WHEN e_validate_error THEN
            p_retcode := 2;
            p_errbuf := 'Payment Validation Fail. Please check the payment record.';
            ROLLBACK;
        WHEN e_gen_data_error THEN
            p_retcode := 2;
            p_errbuf := 'Generate XML Data Error. Please contact your sysadmin.';
            FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
            ROLLBACK;            
        WHEN OTHERS THEN
            p_retcode := 2;
            p_errbuf := 'Program Process Error. Please contact your sysadmin.';
            FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
            ROLLBACK;
    END TRANSFER_MAIN;
   
END XXIBY_PAYMENT_PKG;

/
