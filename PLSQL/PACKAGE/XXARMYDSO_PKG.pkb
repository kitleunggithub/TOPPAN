--------------------------------------------------------
--  File created - Thursday-September-23-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body XXARMYDSO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXARMYDSO_PKG" AS
/*************************************************************
 * Package Name: CINVC0175_QOH
 *
 * Author : DASH
 * Date : 20-Feb-2021
 *
 * Purpose : Create Interface file foor MyDSO
 *
 * Change Log
 *
 * Name          Date        Version Remarks
 * ------------- ----------- ------- ---------------------------------------------------
 * DASH          20-Feb-2021 1.0     Initial Release.
 * DASH          23-Sep-2021 1.1     Bug Fix - AR_CONTACTS_V - some contact_id return more than one row
 * DASH          18-Aug-2022 1.2     Bug Fix - hz_contact_points - specific HZ_PARTIES
 ********************************************************************************/


    PROCEDURE generate_item    (ERRBUF OUT VARCHAR2,
                                RETCODE OUT VARCHAR2 ) 
    IS 

    cursor c_item_cursor is 
		select  '"' || (select customer_number from ar_customers where customer_id = arp.customer_id ) || '";"' ||
		 arp.amount_due_original  || '";"' ||
		 arp.amount_due_remaining  || '";"' ||
		 arp.invoice_currency_code  || '";"' ||
		 to_date(arp.due_date, 'DD-MON-YYYY')  || '";"' ||
		 to_date(arp.trx_date, 'DD-MON-YYYY')  || '";"' ||
		 (select name from ra_cust_trx_types_all where cust_trx_type_id =  arp.cust_trx_type_id)  || '";"' || 
		 arp.trx_number  || '";"' ||
		 xct.customer_order_number  || '";"' ||
         (select resource_name from jtf_rs_defresources_v where resource_id =  decode(rc.interface_header_context, 'TM CONVERSION', rc.interface_header_attribute10, 'XXBS BILLING INVOICES',  (select salesrep_id from xxbs_rep_splits where primary_flag ='Y' and customer_trx_id = xct.customer_trx_id) ))  || '";"' ||
		 arp.class  || '";"' ||
		 arp.payment_schedule_id  || '";"' ||
		 decode(rc.interface_header_context, 'XXBS BILLING INVOICES', (select description from fnd_user where user_id = xct.active_biller_id), null)    || '";"' || 
		 decode(rc.interface_header_context, 'XXBS BILLING INVOICES', to_date(xct.current_status_date, 'DD-MON-YYYY'))   || '";"' || 
		 decode(rc.interface_header_context, 'TM CONVERSION', rc.interface_header_attribute9, 'XXBS BILLING INVOICES', rc.interface_header_attribute1 )  || '";"' || 
		 decode(rc.interface_header_context, 'TM CONVERSION', rc.interface_header_attribute5, 'XXBS BILLING INVOICES', (select long_name from pa_projects where project_id =  rc.interface_header_attribute2))  || '";"' || 
		 decode(rc.interface_header_context, 'XXBS BILLING INVOICES', (select aml.name   from ar_memo_lines_all_tl aml , pa_projects_all pp where pp.attribute1 = aml.memo_line_id  and rc.interface_header_attribute1 = pp.segment1 (+) ) , null) || '";"' || 
         --Start DASH Kit Leung v1.1 - Bug Fix -AR_CONTACTS_V - some contact_id return more than one row
		 --decode(rc.interface_header_context, 'XXBS BILLING INVOICES', nvl(xct.attendee_email , (select email_address from ar_contacts_v where contact_id = xct.bill_to_contact_id)), null) || '"'  item_output
         decode(rc.interface_header_context, 'XXBS BILLING INVOICES', nvl(xct.attendee_email , (select rel_party.email_address
                                                                                                 from hz_contact_points      cont_point,
                                                                                                     hz_cust_account_roles  acct_role,
                                                                                                     hz_parties             rel_party,
                                                                                                     hz_relationships       rel,
                                                                                                     hz_cust_accounts       role_acct
                                                                                                 WHERE acct_role.party_id = rel.party_id
                                                                                                 AND acct_role.role_type = 'CONTACT'
                                                                                                 AND rel_party.party_id = rel.party_id
                                                                                                 AND cont_point.owner_table_id (+) = rel_party.party_id
                                                                                                 AND cont_point.contact_point_type (+) = 'EMAIL'
                                                                                                 AND (cont_point.application_id(+) = 222 OR cont_point.application_id(+) IS NULL)
																								 AND nvl(cont_point.owner_table_name (+),'HZ_PARTIES') = 'HZ_PARTIES' -- v1.2
                                                                                                 AND cont_point.primary_flag (+) = 'Y'
                                                                                                 AND cont_point.status(+) = 'A' 
                                                                                                 AND acct_role.cust_account_id = role_acct.cust_account_id
                                                                                                 AND role_acct.party_id = rel.object_id
                                                                                                 AND acct_role.cust_account_role_id = xct.bill_to_contact_id)), null) || '"'  item_output
         --End DASH Kit Leung v1.1
		from ar_payment_schedules_all arp
		, xxbs_customer_trx xct
		, ra_customer_trx_all rc 
		where status = 'OP'
		--and arp.customer_trx_id = xct.customer_trx_id(+)
		--and rc.customer_trx_id (+)= arp.customer_trx_id
        and arp.trx_number = xct.ar_trx_number(+) 
		and rc.customer_trx_id(+) = arp.customer_trx_id
		and arp.customer_id > 0
		;

	BEGIN
		fnd_file.PUT_LINE(APPS.FND_FILE.LOG,'start :'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
		fnd_file.PUT_LINE(APPS.FND_FILE.OUTPUT,'client_code;item_amount_initial_inc_tax;item_amount_remaining_inc_tax;item_currency;item_date_due;item_date_issue;item_erp_type;item_number;item_order_number;item_sales_manager;item_type;item_unique_key;item_field_perso1;item_field_perso2;item_field_perso3;item_field_perso4;item_field_perso5;item_field_perso6');

		    for c_item  in c_item_cursor loop
				fnd_file.PUT_LINE(APPS.FND_FILE.OUTPUT, REPLACE(c_item.item_output, chr(10), ''));
            end loop; 

	END generate_item;

    PROCEDURE generate_client    (ERRBUF OUT VARCHAR2,
                                RETCODE OUT VARCHAR2 ) 
    IS 

	v_party_id number;

    cursor c_client_cursor is 
		SELECT '"' ||  ac.customer_number  || '";"' || 
		 hp.party_name || '";"' ||
		hl.address1 || '";"' ||
		hl.address2 || '";"' ||
		hl.address3 || decode( hl.address3, null, null, decode( hl.address4, null, null, ', ' ) ) || hl.address4 || '";"' ||
		hl.state || decode( hl.state , null, null, decode( hl.state, null, null, ', ' )) || hl.province || '";"' ||
		hl.postal_code || '";"' ||
        hl.city || '";"' ||
		ftt.territory_short_name || '";"' ||
		decode(hca.attribute16, 'B', 1, 0) || '";"' ||
		(select resource_name from jtf_rs_defresources_v where resource_id = hca.attribute1) || '";"' ||
		hca.attribute14 || '";"' ||
		 replace((select distinct hcp.email_address
		  from apps.hz_cust_accounts  hhca
			 , apps.hz_relationships  rel
			 , apps.hz_contact_points hcp
			 , apps.hz_parties        sub
		 where hhca.party_id           = rel.object_id
		   and rel.subject_id         = sub.party_id
		   and rel.relationship_type  = 'CONTACT' 
		   and rel.directional_flag   = 'F'
		   and rel.party_id           = hcp.owner_table_id
		   and hcp.owner_table_name   = 'HZ_PARTIES'
		   and hcp.contact_point_type = 'EMAIL'
		   and hcp.status = 'A'
		   and hcp.primary_flag = 'Y'
		   and hhca.cust_account_id = hca.cust_account_id
		   and rownum = 1),  chr(10), '') || '";"' ||
		(select name from ra_terms rt where rt.term_id = hca.payment_term_id ) || '";"' ||
		hca.attribute13 || '";"' ||
		hcp.credit_hold || '";"' ||
		hca.attribute18 || '";"' ||
		hca.attribute11  || '"' client_output
		, hp.party_id
		, hps.last_update_date hps_lud
		, hl.last_update_date hl_lud
		, hcp.last_update_date hcp_lud
		FROM hz_parties hp
		,    hz_party_sites hps
		,    hz_cust_accounts hca
		,    ar_customers ac
		,    hz_customer_profiles hcp
		,    hz_locations hl
		,    fnd_territories_tl ftt
		WHERE hp.party_id = hps.party_id(+)
		AND hp.party_id = hca.party_id(+)       
		AND hp.party_id = hcp.party_id(+)
		AND hps.location_id = hl.location_id
		AND hl.country = ftt.territory_code
		and hca.cust_account_id = ac.customer_id
		AND hps.status = 'A'
		order by hp.party_id
		, hps.last_update_date desc
		, hl.last_update_date  desc
		, hcp.last_update_date desc
		;

	BEGIN
		fnd_file.PUT_LINE(APPS.FND_FILE.LOG,'start :'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
		fnd_file.PUT_LINE(APPS.FND_FILE.OUTPUT,'client_code;client_business_name;client_address_street_number;client_address_street;client_address_postbox;client_address_state;client_address_zip;client_address_city;client_address_country;client_blocked;client_commercial_lastname;client_credit_limit;client_email;client_payment_term;client_field_perso1;client_field_perso2;client_field_perso3;client_field_perso4');

		v_party_id := 0;

		    for c_client  in c_client_cursor loop
				if v_party_id != c_client.party_id then 
					fnd_file.PUT_LINE(APPS.FND_FILE.OUTPUT, REPLACE(c_client.client_output, chr(10), ''));
					v_party_id := c_client.party_id;
				end if;
            end loop; 

	END generate_client;                                  

END XXARMYDSO_pkg;

/
