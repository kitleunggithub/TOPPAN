--------------------------------------------------------
--  DDL for Package Body XXAR_INV_PRINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAR_INV_PRINT_PKG" 
IS
/*----------------------------------------------------------------------------------
-- Purpose: Generate BI Publisher Invoices
--
Maintenance History:
Date:          Version          Name            Remarks
-----------    ---------------- -------------   ------------------
01-MAR-2021    1.0              Billy	    	Initial Version.
10-MAR-2021	   1.1				Billy			Add the logic to handle for the calling from DSO Print Outstanding Invoices Program (xxar_inv_print_os_pkg.PRINT_OS_INVOICES)
												that need print all outstanding invoices and sftp invoice pdf files to DSO site.
23-APR-2021    1.2				Billy			Fix to get Bill To Address from hz tables rather than ar_addresses_v because some bill_to_address_id not found in that view									
----------------------------------------------------------------------------------*/

PROCEDURE GENERATE_INV_MAIN (errbuf varchar2,retcode number,P_AR_TRX_NUMBER IN VARCHAR2)
AS
	ln_request_id     NUMBER;
   lc_printer_name   VARCHAR2 (100);
   lc_boolean1       BOOLEAN;
   lc_boolean2       BOOLEAN;

	lb_wait_outcome				BOOLEAN;
  lc_phase            VARCHAR2(50);
  lc_status           VARCHAR2(50);
  lc_dev_phase        VARCHAR2(50);
  lc_dev_status       VARCHAR2(50);
  lc_errors       	VARCHAR2(3000);
  CONC_STATUS 		BOOLEAN;

  l_req_return_status BOOLEAN;
  lc_message varchar2(100);

  v_org_id number;

  exp_submit_err 	exception;
  exp_warn_and_err 	exception;
  ln_parent_request_id  number;
  ln_parent_progarm_id number;
  lv_parent_program_name   varchar2(500);
  ln_movefile_request_id   number;
  lv_sftp_userid            varchar2(100);
  lv_sftp_server			varchar2(100);
BEGIN

     --delete from xxar_inv_print_tmp ; --for testing stage use only

     select org_id
	 into 	v_org_id
	 from xxbs_customer_trx
	 where ar_trx_number = P_AR_TRX_NUMBER;

	 fnd_file.put_line(fnd_file.log,'P_AR_TRX_NUMBER : ' || P_AR_TRX_NUMBER);
	 fnd_file.put_line(fnd_file.log,'V_ORG_ID        : ' || to_char(V_ORG_ID));
	 fnd_request.set_org_id(v_org_id);

	fnd_file.put_line (fnd_file.log,'Before Add Layout XXAR_INV_PRINT.') ;
	--Set Layout
	  lc_boolean1 := fnd_request.add_layout(
								template_appl_name   => 'XXTM',
								template_code        => 'XXAR_INV_PRINT',
								template_language    => 'en', --Use language from template definition
								template_territory   => '00', --Use territory from template definition
								output_format        => 'PDF' --Use output format from template definition
										);
	fnd_file.put_line (fnd_file.log,'After Add Layout XXAR_INV_PRINT.') ;

	fnd_file.put_line (fnd_file.log,'Before submit Request XXAR_INV_PRINT to generate output invoice file.') ;
	 ln_request_id := fnd_request.submit_request ('XXTM',                -- application
												  'XXAR_INV_PRINT',		-- program short name
												  '',                   -- description
												  '',                   -- start time
												  FALSE,                -- sub request
												  P_AR_TRX_NUMBER		--Pass in AR Trx Number
												 );

   COMMIT;
   IF ln_request_id = 0 THEN
				FND_FILE.PUT_LINE(FND_FILE.LOG,'The XXAR_INV_PRINT request submitting has error!');
				--op_proc_errmsg := 'The XXAR_INV_PRINT request submitting has error!';
				--op_proc_status := '2';
				raise exp_submit_err;
    ELSE
			FND_FILE.PUT_LINE(FND_FILE.LOG,'The XXAR_INV_PRINT request submitting successful with Request ID : '||ln_request_id ||' and wait for its completion.');
					 lb_wait_outcome := fnd_concurrent.wait_for_request(request_id => ln_request_id,
																	INTERVAL   => 5,
																	max_wait   => 0,
																	phase      => lc_phase,
																	status     => lc_status,
																	dev_phase  => lc_dev_phase,
																	dev_status => lc_dev_status,
																	message    => lc_errors);
	END IF;

	IF upper(lc_dev_phase) = 'COMPLETE' AND upper(lc_dev_status) = 'NORMAL' THEN
			 FND_FILE.PUT_LINE(FND_FILE.LOG, 'XXAR_INV_PRINT request Job ID : '|| to_char(ln_request_id) ||' completed successfully.');

	ELSIF upper(lc_dev_status) = 'ERROR' THEN
			 lc_errors := 'XXAR_INV_PRINT request Job ID : '|| to_char(ln_request_id) ||' completed with error, please check Log.';
			 FND_FILE.PUT_LINE(FND_FILE.LOG,chr(10)||' Exception: ' || substr(lc_errors, 1, 200));
			 RAISE exp_warn_and_err;

	ELSIF upper(lc_dev_status) = 'WARNING' THEN
			 lc_errors := 'XXAR_INV_PRINT request Job ID : '|| to_char(ln_request_id) ||' completed with warning, please check Log.';
			 FND_FILE.PUT_LINE(FND_FILE.LOG,chr(10)||'Exception: ' || substr(lc_errors, 1, 200));
			 RAISE exp_warn_and_err;

	ELSE
			 lc_errors := 'XXAR_INV_PRINT request Job ID : '|| to_char(ln_request_id) ||' completed with unknown status '|| lc_dev_status;
			 FND_FILE.PUT_LINE(FND_FILE.LOG,' Exception: ' || substr(lc_errors, 1, 200));
			 --RAISE ex_prc_others;
    END IF;


        --V1.1 Start
		--V1.1 20210310 add logic to check if this program is called by DSO Print all Outstanding Invoices Programs (by checking its parent request ID)
		--If so , need to do the sftp steps to move print out files to destination site of DSO.
		fnd_file.put_line(fnd_file.log,'XXAR Invoice Print Main Process Concurrent Request ID is fnd_global.conc_request_id  : ' || to_char(fnd_global.conc_request_id));
		select parent_request_Id
		into   ln_parent_request_id
		from   fnd_concurrent_requests
		where  request_Id = fnd_global.conc_request_id;
		fnd_file.put_line(fnd_file.log,'This XXAR Invoice Print Main Process''s Parent Request ID is ln_parent_request_id : ' || to_char(ln_parent_request_id));

		If ln_parent_request_id <> -1 Then
		-- if ln_parent_request_id is -1, it is called from Custom Billing Print Button or self submitted.
				select concurrent_program_id
				into   ln_parent_progarm_id
				from   fnd_concurrent_requests
				where  request_Id = ln_parent_request_id;

				select concurrent_program_name
				into   lv_parent_program_name
				from   fnd_concurrent_programs_vl
				where  concurrent_program_id  = ln_parent_progarm_id;
		End If;

		If lv_parent_program_name = 'XXAR_INV_PRINT_OS' Then
				fnd_file.put_line(fnd_file.log,'This XXAR Invoice Print Main Process is called from XXAR Print Outstanding Invoices (DSO).  Need to do the SFTP step to move files to DSO.');

				IF upper(lc_dev_phase) = 'COMPLETE' AND upper(lc_dev_status) = 'NORMAL' THEN
				        --Only will move files when the invoice print job is successful.
						--Get the sftp user id and server for DSO
						select argument1,argument2
						into   lv_sftp_userid,lv_sftp_server
						from   fnd_concurrent_requests
						where  request_Id = ln_parent_request_id;

						fnd_file.put_line(fnd_file.log,'SFTP_USERID/SFTP_SERVER IS : '|| lv_sftp_userid||' / '|| lv_sftp_server);

						ln_movefile_request_id := fnd_request.submit_request ('XXTM',                -- application
																			  'XXAR_INV_MOVE_FILE',		-- program short name
																			  '',                   -- description
																			  '',                   -- start time
																			  FALSE,                -- sub request
																			  ln_request_id,            --Pass In request ID for printing the invoice pdf file.
																			  P_AR_TRX_NUMBER,		--Pass in AR Trx Number
																			  lv_sftp_userid,		--SFTP user id for DSO server
																			  lv_sftp_server		--SFTP server for DSO server
																			 );
						COMMIT;
				End If;
		Else
			--Not called from XXAR Print Outstanding Invoices (DSO), no need do sftp but need to do update back status to xxbs_customer_trx table
				--sync the invoice print request_id and completion status to xxbs_customer_trx table
				fnd_file.put_line(fnd_file.log,'This XXAR Invoice Print Main Process is not called from XXAR Print Outstanding Invoices (DSO).  No need to do the SFTP step to move files to DSO.');

				update xxbs_customer_trx
				set    print_request_id = ln_request_id,
						last_update_Date  = sysdate
				where  ar_trx_number = P_AR_TRX_NUMBER;
				fnd_file.put_line (fnd_file.log,'After update xxbs_customer_trx.') ;

					--House keep old data on table xxar_inv_print_tmp that aged over 30 days.
					delete from xxar_inv_print_tmp where trunc(creation_date) <= trunc(sysdate) - 30;
					fnd_file.put_line (fnd_file.log,'After delete from xxar_inv_print_tmp.') ;
		End If;
		--V1.1 end

EXCEPTION 	WHEN exp_submit_err THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,'GENERATE_INV_MAIN Cannot Submit Request XXAR_INV_PRINT !');

			--Update Parent Request ID to xxbx_customer_trx table for the AR_TRX_Number.
			update xxbs_customer_trx set print_request_id = FND_GLOBAL.CONC_REQUEST_ID, last_update_Date  = sysdate where  ar_trx_number = P_AR_TRX_NUMBER;
			CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error.');

			WHEN exp_warn_and_err THEN
			--XXAR_INV_PRINT completed with Error or Warning.
			FND_FILE.PUT_LINE(FND_FILE.LOG,' Child Request XXAR_INV_PRINT has warning or Error !');
			--Update Submmitted Child XXAR_INV_PRINT Request ID to xxbx_customer_trx table for the AR_TRX_Number.
			update xxbs_customer_trx set print_request_id = ln_request_id ,last_update_Date  = sysdate where  ar_trx_number = P_AR_TRX_NUMBER;

			WHEN OTHERS THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,'GENERATE_INV_MAIN Others Exception Err: '||SQLCODE||SQLERRM);

			--Update Parent Request ID to xxbx_customer_trx table for the AR_TRX_Number.
			update xxbs_customer_trx set print_request_id = FND_GLOBAL.CONC_REQUEST_ID,last_update_Date  = sysdate where  ar_trx_number = P_AR_TRX_NUMBER;
			CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error.');
END GENERATE_INV_MAIN;

PROCEDURE GENERATE_INV_DATA (P_AR_TRX_NUMBER IN VARCHAR2,P_REQUEST_ID IN NUMBER)
AS
cursor c_ar_trx is
select 	decode(nvl(trx.PRELIMINARY,'xx'),'Y','PRELIMINARY INVOICE','INVOICE') head_inv_type
		,trx.BILL_TO_CUSTOMER_ID
		,trx.BILL_TO_ADDRESS_ID
		,trx.BILL_TO_CONTACT_ID
		,trx.AR_TRX_NUMBER
		,trx.ENTERED_CURRENCY_CODE
		,trx.CUSTOMER_TRX_ID
		,trx.description
		,trx.trx_date
		--,trx.order_number
		,(select segment1 from PA_PROJECTS_ALL where project_id = trx.original_project_Id) project_number
		,trx.customer_order_number
		,trx.Date_Received
		,trx.Attendee
		,trx.Attendee_email
		,trx.term_id
		,trx.invoice_title
		,trx.invoice_style_name
		,trx.invoice_desc_one_line
		,trx.invoice_foot_top
		,trx.invoice_foot_bottom
		,trx.tax_amount
		,DISPLAY_LEVEL_1
		,DISPLAY_LEVEL_1_TOTAL
		,DISPLAY_LEVEL_2
		,DISPLAY_LEVEL_2_TOTAL
		,DISPLAY_LEVEL_3
		,DISPLAY_LEVEL_3_TOTAL
        --below is line info
        ,trx_line.customer_trx_LINE_Id,trx_line.line_type,trx_line.line_number
       ,trx_line.level_1,trx_line.level_2,trx_line.level_3
       ,trx_line.quantity_sell,trx_line.long_description,trx_line.unit_sell,trx_line.sell_amount
from  XXBS_CUSTOMER_TRX trx
      --,XXBS_CUSTOMER_TRX_LINES_test trx_line
	  ,XXBS_CUSTOMER_TRX_LINES trx_line
where trx_line.customer_trx_Id = trx.customer_trx_Id
and   trx.ar_trx_number = P_AR_TRX_NUMBER
order by trx_line.line_number ;

lv_bill_to_customer_name  	varchar2(1000);
lv_bill_to_addresses       	varchar2(2000);
lv_bill_to_contact			varchar2(500);
lv_bill_to_contact_email    varchar2(500);
lv_term						varchar2(100);
lv_curr_code   varchar2(20);
lv_curr_symbol varchar2(20);

lv_group_inv_line_by         varchar2(4000);
ln_inv_style_language        varchar2(100);
lv_trx_date_disp			 varchar2(100);
BEGIN


For r in c_ar_trx LOOP

		--Set the Trx date in English or Chinese by the invoice Style language
		select upper(language)
		into   ln_inv_style_language
		from   xxbs_invoice_styles
		where  invoice_style_name = r.invoice_style_name;

		IF ln_inv_style_language = 'ZH-HK' THEN
		  --lv_trx_date_disp := to_char(r.trx_date, 'dd-MON-YYYY', 'NLS_DATE_LANGUAGE = ''TRADITIONAL CHINESE''') ;
		  --20210308 want to show 2021年02月26日 for chinese.
			lv_trx_date_disp := to_char(r.trx_date,'YYYY')||'年' || to_char(r.trx_date, 'MM')||'月' ||to_char(r.trx_date,'DD')||'日' ;

		ELSE
			lv_trx_date_disp := to_char(r.trx_date,'DD-MON-YYYY') ;
		End If;



		--Get Bill to Customer Name
		select customer_name
		into   lv_bill_to_customer_name
		from   ar_customers
		where  customer_Id = r.BILL_TO_CUSTOMER_ID;

		--Get Bill To Address,get address line 1,2,3,4 only
		/*
		select Address1||
			   case when Address2 is not null then chr(10)||address2 end ||
			   case when Address3 is not null then chr(10)||address3 end ||
			   case when Address4 is not null then chr(10)||address4 end
			   --case when city is not null then chr(10)||city end
		into  lv_bill_to_addresses
		from  ar_addresses_v
		where address_id = r.BILL_TO_ADDRESS_ID;
		*/
		--20210423 fix v1.2

			 select hloc.Address1||
					case when hloc.Address2 is not null then chr(10)||hloc.address2 end ||
					case when hloc.Address3 is not null then chr(10)||hloc.address3 end ||
					case when hloc.Address4 is not null then chr(10)||hloc.address4 end
			 into   lv_bill_to_addresses
			 from   HZ_CUST_ACCT_SITES_all hacctsites
				   ,hz_party_sites hpsite
				   ,hz_locations   hloc
			 where hpsite.party_site_id         =  hacctsites.party_site_Id
			 and   hloc.location_Id             =  hpsite.location_Id
			 and   hacctsites.cust_acct_site_Id =  r.BILL_TO_ADDRESS_ID;

		--Get Bill to Contact Person and email
		If  (r.attendee is not null or r.attendee_email is not null) Then
				lv_bill_to_contact 			:= r.attendee ;
				lv_bill_to_contact_email	:= r.attendee_email;
		Else

				begin
					select last_name ||' '|| first_name,email_address
					into   lv_bill_to_contact, lv_bill_to_contact_email
					from   ar_contacts_V
					where contact_Id = r.BILL_TO_CONTACT_ID;
				exception when others then
					lv_bill_to_contact 			:= null ;
					lv_bill_to_contact_email	:= null ;
				end;
		End If;

		--Get currency and currency symnbol
		begin
			select currency_code,symbol
			into   lv_curr_code,lv_curr_symbol
			from   fnd_currencies
			where  currency_code = r.entered_currency_code;
		exception when others then
			lv_curr_code   := 'Not found';
			lv_curr_symbol := 'Not found';
		end;

		--Get Bill Term
		begin
			select name
			into   lv_term
			from   ra_terms
			where  term_id = r.term_id;
		exception when others then
			lv_term := 'Not found';
		end;

		--Get the invoice line group by leve_1,level_2,level_3 logic
		lv_group_inv_line_by := null;  --reset for each Inv line.
		If r.display_level_1 = 'Y' Then
			lv_group_inv_line_by := r.level_1;
		End If;

		If r.display_level_2 = 'Y' Then
			lv_group_inv_line_by := lv_group_inv_line_by|| case when r.level_2 is not null then chr(10)||r.level_2 end;
		End If;

		If r.display_level_3 = 'Y' Then
			lv_group_inv_line_by := lv_group_inv_line_by||case when r.level_3 is not null then chr(10)||r.level_3 end;
		End If;

		lv_group_inv_line_by := substr(lv_group_inv_line_by,1,4000);

		insert into xxar_inv_print_tmp
					(request_Id
					,hd_inv_type
					,BILL_TO_CUSTOMER,BILL_TO_ADDRESS,BILL_TO_CONTACT
					,customer_trx_id,invoice_num,invoice_curr_code,invoice_curr_symbol
					,header_desc,trx_date
					,project_number,customer_order_number
					,Date_Received
					,Invoice_SalesRep
					,Attendee_email
					,term
					,invoice_title
					,invoice_style_name
					,invoice_desc_one_line
					,invoice_foot_top
					,invoice_foot_bottom
					,tax_amount
					,Group_inv_line_by
					--below is line info
					,customer_trx_line_Id
					,line_type
					,line_number
					,level_1
					,level_2
					,level_3
					,quantity_sell
					,long_description
					,unit_sell
					,sell_amount
					,creation_date
					)
		VALUES
					(P_REQUEST_ID
					,r.head_inv_type
					--,r.BILL_TO_CUSTOMER_ID,r.BILL_TO_ADDRESS_ID,r.BILL_TO_CONTACT_ID
					,lv_bill_to_customer_name,lv_bill_to_addresses,lv_bill_to_contact
					,r.customer_trx_Id,r.ar_trx_number,lv_curr_code,lv_curr_symbol
					,r.description
					--,to_char(r.trx_date,'DD-MON-YYYY')
					,lv_trx_date_disp
					,r.project_number,r.customer_order_number
					,to_char(r.Date_Received,'DD-MON-YYYY')
					,xxar_inv_print_pkg.Get_INV_SALESREP(r.AR_TRX_NUMBER)
					,lv_bill_to_contact_email
					,lv_term
					,r.invoice_title
					,r.invoice_style_name
					,r.invoice_desc_one_line
					,r.invoice_foot_top
					,r.invoice_foot_bottom
					,r.tax_amount
					,lv_group_inv_line_by
					--below is line info
					,r.customer_trx_line_Id
					,upper(r.line_type)
					,r.line_number
					,r.level_1
					,r.level_2
					,r.level_3
					,r.quantity_sell
					,r.long_description
					,r.unit_sell
					,r.sell_amount
					,sysdate
					);
End Loop;

END GENERATE_INV_DATA;

FUNCTION GET_INV_SALESREP (P_AR_TRX_NUMBER IN VARCHAR2)
RETURN VARCHAR2
AS
ln_customer_trx_Id 	number;
lv_resource_name	varchar2(200);
lv_all_salesrep     varchar2(500);
BEGIN

		select customer_trx_id
		into   ln_customer_trx_Id
		from   xxbs_customer_trx
		where  ar_trx_number = P_AR_TRX_NUMBER ;

FOR R in (select salesrep_Id from XXBS_REP_SPLITS where customer_trx_id = ln_customer_trx_Id order by rep_split_id)
LOOP
		select resource_name
		into   lv_resource_name
		from   JTF_RS_DEFRESOURCES_V
		where  resource_id = R.salesrep_Id;

		lv_all_salesrep := case when lv_all_salesrep is null then lv_resource_name else lv_all_salesrep || '/ ' ||lv_resource_name END;

END LOOP;

		return lv_all_salesrep;

EXCEPTION WHEN OTHERS THEN
		Return 'Error in GET_INV_SALESREP';
END GET_INV_SALESREP;

END XXAR_INV_PRINT_PKG;

/
