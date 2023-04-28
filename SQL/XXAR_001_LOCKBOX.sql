/*************************************************************************

FILENAME        XXAR_001_LOCKBOX.sql

DESCRIPTION     Pre processing script run before Oracle's standard process
      Section 1:  Custom updates and validations
        Section 1.5: Redistribute cash
      Section 2:  Update receipt related info
      Section 3:  Create new output string
      Section 4:  Creates output report
      Section 5:  Spools out updated file

BY              Jill Di Leva

REQUIREMENTS    John Parker, Gayle Kojetin

USAGE           sqlplus userid/password @FILENAME

CALLED BY	$XXTM_TOP/bin/XXAR_LOCKBOX
      Script SQL Loads data file and then calls this SQL script

NOTES

HISTORY

v1.0   Jill Di Leva 12/01/2001 		Created
v1.1   Jill Di Leva 2/13/2002
   Before beginning main script, update invoice number to include
   leading zero's and dashes.
v1.2   Jill Di Leva 2/18/2002
   Added 'Output File Name' as parameter
v1.3   Jill Di Leva 2/22/2002
   Added item number to the comment field
v1.4  Jill Di Leva 2/10/2003
    Script is called from UNIX script $XXTM_TOP/bin/XXAR_LOCKBOX
    Request id is passed as a parameter not picked up from global variables
    Output report is now a delimeted file that spools out to bachdata
v1.5  Jill Di Leva 6/4/03
    Add Business Unit to audit report.  Based on receivable account of invoice
v1.6  Jill Di Leva 2/14/05
    Change temporary directory where output file is spooled (v_p1)
v1.7 Jill Di Leva 7/19/05
    Change temporary directory -- don't hard code $APPL_CUST -- different
    values for different instances
    Add "quit" at very end of script.  This returns control to the UNIX script.
    Without it, job log file was filling up with 'SQL>'
v1.8 Jill DiLeva 1/1/2014
    Changes to include attribute2 (transmission id) in output data file
    Necessary for imaging to link receipt to image
    Remove
Modfied 3/27/15 Deepak Kalra and Jill DiLeva
    1) Remove the condition that requires the invoice amount = remittance amount
    2) Remove the condition tha currency = USD
    3) Added Section 1.5 to attempt to redistribute dollars across invoices within a
    receipt when they don't come allocated correctly from the bank.
Modifed 8/20/15 Jill DiLeva
    Changes for R12
    Changes to make process work for all banks, countries and lockboxes
        Added lockbox parameter
        AR_CUSTOMERS instead of RA_CUSTOMERS
04/27/2017 akaplan - Q2C - Stop determining CM based on -1/-2 extension
10/17/2017 akaplan - Modification to trim off 0-padding of invoice number
                     from INTERNAL INTERCOMPANY lockbox entries
                   - Invoices labelled with -2 have - removed. Need to compensate
                   - Fix issues with revised invoices.
11/22/2017 akaplan - Fix issue when AR invoice exists, but Billing invoice does not
11/28/2018 akaplan - Enh Req 2229: Fixes for new BOA Lockbox
01/15/2019 akaplan - Enh Req 2249: Fixes for ACH Lockbox
***************************************************************************/

--------------------------------------------------------------------------
-- SET ENVIRONMENT
--------------------------------------------------------------------------

define v_linesize = 180
define v_pagesize = 58
define v_term = 'off'
define v_wrap = 'off'

@$XXTM_TOP/sql/XXCM_REPORT_START

--set echo on

--------------------------------------------------------------------------
-- VARIABLES
--------------------------------------------------------------------------

define v_application = 'XXAR'
define v_module = 'XXAR_001_LOCKBOX'
define v_version = '1.5'

--------------------------------------------------------------------------
-- PARAMETERS
--------------------------------------------------------------------------

@$XXTM_TOP/sql/XXCM_REPORT_PARMS

-- Data file name
DEFINE v_datafile='&2'

set serveroutput on size 1000000
set linesize 800

/*
declare
    v_org_id number;
begin
    select xxcm_common.Get_curr_operating_unit into v_org_id from dual;
    xxcm_common.write_log('Current Operating Unit:' || v_org_id);
end;
*/

-------------------------------------------------------
-------------------------------------------------------
-- SECTION 1
-- Invoice related updates and validations
-------------------------------------------------------
-------------------------------------------------------
set term on

DECLARE
   c_ar_match       CONSTANT VARCHAR2(100) := 'Match found in AR.';
   c_inv_closed_ar  CONSTANT VARCHAR2(100) := 'Invoice closed in AR';
   c_inv_no_revised CONSTANT VARCHAR2(100) := 'AR inv closed, no revised inv in Billing.';
   v_status_message          VARCHAR2(200);
   v_new_invoice             VARCHAR2(30);
   v_orig_invoice            VARCHAR2(30);
   v_exist_ar                VARCHAR2(1);
   v_complete_flag           VARCHAR2(1);
   v_amt_due_remaining 	     NUMBER(10,2);
   v_invoice_curr_code	     VARCHAR2(10);
   v_billing_trx_id 	        NUMBER;
   v_billing_type            VARCHAR2(10);
   v_billing_status          VARCHAR2(50);
   v_billing_rev_trx_id      NUMBER;
   v_billing_rev_trx_number  VARCHAR2(20);
   v_billing_rev_type	     VARCHAR2(10);
   v_billing_rev_status      VARCHAR2(50);
   v_inv_customer_nbr        VARCHAR2(30);
   v_inv_org_id              NUMBER;

   ----------------------------------------
   -- Invoices included in file
   -- Each row can include 3 separate invoice
   cursor inv_cur is
      select
         inv1.transmission_id, inv1.transmission_record_id,
         inv1.batch_name, inv1.item_number, inv1.overflow_sequence,
         '1' inv_position
       , trim(ltrim(inv1.invoice1,'0')) invoice
       , inv1.amount_applied1 amount_applied
      from
         xxar_payments_interface inv1
      where
         inv1.invoice1 is not null
         and record_type = 4
      UNION
      select
         inv2.transmission_id, inv2.transmission_record_id,
         inv2.batch_name, inv2.item_number, inv2.overflow_sequence,
         '2' inv_position
       , trim(ltrim(inv2.invoice2,'0')) invoice
       , inv2.amount_applied2 amount_applied
      from
         xxar_payments_interface inv2
      where
         inv2.invoice2 is not null
         and record_type = 4
      UNION
      select
         inv3.transmission_id,inv3.transmission_record_id,
         inv3.batch_name, inv3.item_number, inv3.overflow_sequence,
         '3' inv_position
       , trim(ltrim(inv3.invoice3,'0')) invoice
       , inv3.amount_applied3 amount_applied
      from
         xxar_payments_interface inv3
      where
         inv3.invoice3 is not null
         and record_type = 4
      order by batch_name, item_number;

PROCEDURE debug (p_message VARCHAR2) IS
BEGIN
NULL;
     xxcm_common.write_log(p_message);
--   xxcm_common.insert_debug_msg(p_process_name=>'LOCKBOX',p_message=>p_message);
END;
   -------------------------------------------------------------
   -- Procedure to get invoice related information from AR
   -------------------------------------------------------------
   PROCEDURE ar_info ( p_invoice_number        VARCHAR2
                     , p_amt_applied           NUMBER
                     , p_exist_ar          OUT VARCHAR2
                     , p_amt_due_remaining OUT NUMBER
                     , p_inv_customer_nbr  OUT VARCHAR2
                     , p_status_message    OUT VARCHAR2
                     ) is

      v_complete_flag      ra_customer_trx.complete_flag%TYPE;
      v_invoice_curr_code  ra_customer_trx.invoice_currency_code%TYPE;
   begin
      -- Find necessary AR info for invoice --
      SELECT 'Y'
           , trx.complete_flag
           , p.amount_due_remaining
           , trx.invoice_currency_code
           , r.customer_number
      INTO p_exist_ar
         , v_complete_flag
         , p_amt_due_remaining
         , v_invoice_curr_code
         , p_inv_customer_nbr
      FROM ra_customer_trx trx
             JOIN ar_customers r ON ( r.customer_id = trx.bill_to_customer_id )
        LEFT JOIN ar_payment_schedules p ON ( p.customer_trx_id = trx.customer_trx_id )
      WHERE trx.trx_number = p_invoice_number
        AND trx.org_id = v_inv_org_id;

      IF v_complete_flag = 'N' THEN
         p_status_message := 'Invoice must be completed.';
      ELSIF NVL(p_amt_applied,0) = 0 THEN
         p_status_message := 'Remittance Amount is $0';
      ELSIF p_amt_due_remaining = 0 THEN
         p_status_message := c_inv_closed_ar;
      ELSIF v_invoice_curr_code <> 'USD' THEN
         p_status_message := c_ar_match||' Warning: Invoice not USD.  Currency='||v_invoice_curr_code;
      ELSIF p_amt_due_remaining != p_amt_applied/100 THEN
         p_status_message := c_ar_match||' Warning: Amount mismatch. Due='||p_amt_due_remaining||', Applied='||p_amt_applied/100;
      ELSE
         p_status_message := c_ar_match;
      END IF;
debug('Inv#:'||p_invoice_number||'=>'||p_status_message);
   EXCEPTION
      -- Invoice doesn't exist in AR
      WHEN NO_DATA_FOUND THEN
         p_exist_ar := 'N';
         p_amt_due_remaining := 0;
         p_inv_customer_nbr := null;
      WHEN TOO_MANY_ROWS THEN
         p_exist_ar := 'D';
         p_amt_due_remaining := 0;
         p_inv_customer_nbr := null;
      WHEN OTHERS THEN
         xxcm_common.write_log('Error in AR_INFO sql' || SQLERRM);

   end ar_info;

   -------------------------------------------------------------
   -- Procedure to get invoice related information from Billing
   -------------------------------------------------------------
   /*BC
   PROCEDURE billing_info (p_invoice_number       VARCHAR2,
                           p_billing_trx_id   OUT NUMBER,
                           p_billing_type     OUT VARCHAR2,
                           p_billing_status   OUT VARCHAR2,
                           p_inv_customer_nbr OUT VARCHAR2) is

      v_trx_customer_id	number;
      v_profile_customer_id number;
   BEGIN
      SELECT
         trx.customer_trx_id, t.type, fnd.flex_value,
         r.customer_number,
         trx.bill_to_customer_id, p.customer_id
      INTO
         p_billing_trx_id, p_billing_type, p_billing_status,
         p_inv_customer_nbr,
         v_trx_customer_id, v_profile_customer_id
      FROM
         fnd_flex_values fnd,
         ar_customers r,
         ra_cust_trx_types t,
         xxbs_profiles p,
         xxbs_customer_trx trx
      WHERE 1=1
	   --trx.current_status_id = fnd.flex_value_id
        AND t.cust_trx_type_id = trx.cust_trx_type_id
        AND trx.bill_to_customer_id = r.customer_id
        AND p.profile_id = trx.profile_id
        --AND nvl(trx.orig_ar_trx_number, trx.ar_trx_number) = p_invoice_number;
		AND trx.ar_trx_number = p_invoice_number;

      -- This procedure is only used if invoice is not complete
      -- Only send the customer if is is different than the profile
      -- default customer.
      IF v_trx_customer_id = v_profile_customer_id THEN
         p_inv_customer_nbr := NULL;
      END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN     --invoice doesn't exist in billing
         p_billing_trx_id  := null;
         p_billing_type    := null;
         p_billing_status  := null;
         p_inv_customer_nbr:= null;
      WHEN TOO_MANY_ROWS THEN
         p_billing_trx_id  := null;
         p_billing_type    := null;
         p_billing_status  := 'D';
         p_inv_customer_nbr:= null;
      WHEN OTHERS THEN
         xxcm_common.write_log('Error in Billing_info XXAR BOA sql' || SQLERRM);

   end billing_info;
   */
   -------------------------------------------------------------------
   -- Procedure to get child invoice related information from Billing
   -- Assumes a credit memo is named '%-1' and rev inv named '%-2'
   -------------------------------------------------------------------
   /*BC
   PROCEDURE billing_rev_info ( p_invoice_number             VARCHAR2
                              , p_inv_applied                NUMBER
                              , p_billing_rev_trx_number OUT VARCHAR2
                              , p_status_message         OUT VARCHAR2
                              ) IS

       v_external_system        VARCHAR2(1);
       v_billing_rev_trx_number VARCHAR2(20);
       v_billing_rev_status     VARCHAR2(20);
       v_status_message         VARCHAR2(200);

       CURSOR nested_reversal_cur IS
          -- First customer_trx_id should be -2.  But if not, will still be included.
          SELECT rev.ar_trx_number
               --, xxcm_common.get_flex_value(rev.current_status_id) status
			     ,'Status' Status
          FROM xxbs_customer_trx orig
             JOIN xxbs_customer_trx  cm ON ( cm.parent_customer_trx_id = orig.customer_trx_id
                                         AND xxcm_common.get_trx_type(cm.cust_trx_type_id) = 'CM' )
             JOIN xxbs_customer_trx rev ON ( rev.parent_customer_trx_id = cm.customer_trx_id )
          WHERE orig.ar_trx_number = p_invoice_number
          ORDER BY rev.customer_trx_id DESC;

       CURSOR direct_reversal_cur IS
          SELECT rev.ar_trx_number
               --, xxcm_common.get_flex_value(rev.current_status_id) status
			   ,'Status' Status
          FROM xxbs_customer_trx orig
             JOIN xxbs_customer_trx rev ON ( rev.parent_customer_trx_id = orig.customer_trx_id
                                         AND xxcm_common.get_trx_type(rev.cust_trx_type_id) != 'CM' )
          WHERE orig.ar_trx_number = p_invoice_number;

   BEGIN
			  BEGIN
				 SELECT xxcm_common.get_dep_flex_value_field(xxcm_common.get_business_unit_by_prod_type(trx.primary_product_type_id)
															,'XXSP_SOURCE_SYSTEMS'
															, fs.foreign_system_user
															, 'AUTOBILL_FLAG', 'Y') external_system
				   INTO v_external_system
				 FROM xxbs_customer_trx trx
					JOIN xxcm_foreign_systems fs on ( fs.foreign_sys_number = trx.source_system)
				 WHERE trx.ar_trx_number = p_invoice_number
				 ;
			  EXCEPTION
				 WHEN NO_DATA_FOUND THEN
					-- If invoice not found, no revised invoice will be found
					p_status_message := c_inv_no_revised;
					RETURN;
			  END;

      xxcm_common.write_log('Checking Reversal for invoice:'||p_invoice_number);
      IF nvl(v_external_system,'N') = 'Y' THEN
			 -- External system linked directly via parent customer trx id
			 OPEN direct_reversal_cur;
			 FETCH direct_reversal_cur
			  INTO p_billing_rev_trx_number
				 , v_billing_rev_status;
			 CLOSE direct_reversal_cur;
      ELSE
			 -- Custom billing linked via CM - potential for multiple reversal records, but only uses first one
			 OPEN nested_reversal_cur;
			 FETCH nested_reversal_cur
			  INTO p_billing_rev_trx_number
				 , v_billing_rev_status;
			 CLOSE nested_reversal_cur;
      END IF;


      IF p_billing_rev_trx_number IS NULL THEN
				p_status_message := c_inv_no_revised;			

      ELSIF v_billing_rev_status = 'RECEIVED BY AR' THEN
				 ar_info(p_billing_rev_trx_number
						, p_inv_applied
						, v_exist_ar
						, v_amt_due_remaining
						, v_inv_customer_nbr
						, p_status_message
						);

				 IF p_status_message = c_inv_closed_ar THEN
				   billing_rev_info ( p_billing_rev_trx_number
									, p_inv_applied
									, v_billing_rev_trx_number
									, v_status_message
									);

						debug('In:'||p_billing_rev_trx_number||'/Out:'||v_billing_rev_trx_number||'=>'||v_status_message);
					   IF v_billing_rev_trx_number IS NOT NULL
					   THEN -- Final reversal found.  Assign back to caller
						  p_billing_rev_trx_number := v_billing_rev_trx_number;
						  p_status_message := v_status_message;
					   END IF;
				 END IF;
      ELSE
         v_status_message := 'in Billing, not in AR';
      END IF;
   EXCEPTION
      WHEN TOO_MANY_ROWS THEN
          -- insert error tracking record
          null;

   END billing_rev_info;
   */
   -------------------------------------------------------------
   -- Procedure to update XXAR_PAYMENTS_INTERFACE
   -- Update temp table will appropriate values
   -------------------------------------------------------------
   procedure update_xxar_table (p_transmission_id        number,
                                p_transmission_record_id number,
                                p_inv_position           number,
                                p_new_invoice            varchar2,
                                p_orig_invoice           varchar2,
                                p_status_message         varchar2,
                                p_inv_customer_nbr       varchar2,
                                p_amt_due_remaining      number) is
   begin
     if p_inv_position = 1 then
		   UPDATE xxar_payments_interface
		   SET
			   invoice1 = p_new_invoice,
			   invoice1_orig = p_orig_invoice,
			   status_message1 = substr(p_status_message,1,100),
			   customer_number1 = p_inv_customer_nbr,
			   amt_due_remaining1 = p_amt_due_remaining
		   WHERE transmission_record_id = p_transmission_record_id;

     ELSIF p_inv_position = 2 then
		   UPDATE xxar_payments_interface
		   SET
			   invoice2 = p_new_invoice,
			   invoice2_orig = p_orig_invoice,
			   status_message2 = substr(p_status_message,1,100),
			   customer_number2 = p_inv_customer_nbr,
			   amt_due_remaining2 = p_amt_due_remaining
		   WHERE transmission_record_id = p_transmission_record_id;

     elsif p_inv_position = 3 then
		   UPDATE xxar_payments_interface
		   SET
			   invoice3 = p_new_invoice,
			   invoice3_orig = p_orig_invoice,
			   status_message3 = substr(p_status_message,1,100),
			   customer_number3 = p_inv_customer_nbr,
			   amt_due_remaining3 = p_amt_due_remaining
		   WHERE
			 transmission_record_id = p_transmission_record_id;
			 --and transmission_id = inv.rec.transmission_id

     END IF;
     COMMIT;
   EXCEPTION WHEN OTHERS THEN
         xxcm_common.write_log (' Oracle Err in update xxar table' ||sqlerrm);
   END;  --update_xxar_table

---------------------------------------
-- Main program
---------------------------------------
begin
	xxcm_common.write_log('Main Program Start...');

   -- Lockbox is not always on record 2, so grab it from wherever it is
			SELECT l.org_id
			INTO v_inv_org_id
			FROM (	SELECT distinct first_value(lockbox_number IGNORE NULLS) OVER () lockbox_number
					FROM xxar_payments_interface) i
			JOIN ar_lockboxes_all l ON ( l.lockbox_number = ltrim(i.lockbox_number ,'0') );
	
	
	xxcm_common.write_log('Lockbox Org:'||v_inv_org_id);

   for inv_rec in inv_cur loop
		  v_status_message 		:= null;
		  v_new_invoice 		:= inv_rec.invoice;
		  v_orig_invoice 		:= null;
		  v_exist_ar 			:= null;
		  v_complete_flag 		:= null;
		  v_amt_due_remaining 	:= null;
		  v_invoice_curr_code 	:= null;
		  v_billing_trx_id 		:= null;
		  v_billing_type 		:= null;
		  v_billing_status 		:= null;
		  v_inv_customer_nbr	:= null;

		xxcm_common.write_log('Start first ar_info for invoice : '||inv_rec.invoice);
		  -- Get AR related info --
		  ar_info (inv_rec.invoice
				   , inv_rec.amount_applied
				   , v_exist_ar
				   , v_amt_due_remaining
				   , v_inv_customer_nbr
				   , v_status_message
				   );
			xxcm_common.write_log('End first ar_info for invoice : '||inv_rec.invoice);
		
      -- Bank removes "-" when customer ends invoice with -2.
      -- Replace - and try again.
      IF v_exist_ar = 'N'
        AND length(inv_rec.invoice) = 8
        AND substr(inv_rec.invoice,-1) = '2'
      THEN
				 v_billing_rev_trx_number := substr(inv_rec.invoice,1,7)||'-2';
				 ar_info( v_billing_rev_trx_number
						, inv_rec.amount_applied
						, v_exist_ar
						, v_amt_due_remaining
						, v_inv_customer_nbr
						, v_status_message
						);

				 IF v_status_message LIKE c_ar_match||'%'
				 THEN
					v_new_invoice := v_billing_rev_trx_number;
					v_orig_invoice := inv_rec.invoice;
					v_status_message := 'Revised-Inv Nbr Upd-'||v_status_message;
				 END IF;
      END IF;

      ----------------------------------------------------------
      -- Invoice exists in AR --
      if v_exist_ar = 'Y' then  /* 1 */
			 IF v_status_message = c_inv_closed_ar
			 THEN -- Amount due = 0.  Check for reversal.
				/*BC
				billing_rev_info ( inv_rec.invoice
								 , inv_rec.amount_applied
								 , v_billing_rev_trx_number
								 , v_status_message
								 );
				*/
				--BC set the OUT two para below from billing_rev_info instead:
				v_billing_rev_trx_number 	:= null;	 
				v_status_message 			:= c_inv_no_revised;
				
				IF v_status_message LIKE c_ar_match||'%'
				THEN
				   v_new_invoice := v_billing_rev_trx_number;
				   v_orig_invoice := inv_rec.invoice;
				   v_status_message := 'Revised-Inv Nbr Upd-'||v_status_message;
				ELSE
				   v_status_message := 'Revised Invoice-'||v_status_message;
				END IF; /* 2 */
			 END IF;
      -- Invoice doesn't exist in AR --
      ELSIF v_exist_ar = 'D' Then /* 1 */
			 v_status_message := 'Force Failure Dup Invoice in AR';
			 v_new_invoice := 'X' || inv_rec.invoice;
			 v_orig_invoice := inv_rec.invoice;
      ELSE

			 --------------------------------------------------------
			 -- Determine if invoice exists in Billing
			 /*BC
			 billing_info (inv_rec.invoice,v_billing_trx_id,
						   v_billing_type,v_billing_status, v_inv_customer_nbr);
			*/
			
			--BC set the OUT para below:
			         v_billing_trx_id  := null;
					 v_billing_type    := null;
					 v_billing_status  := null;
					 v_inv_customer_nbr:= null;
					 
			 IF v_billing_trx_id IS NULL THEN  /* 10 */
				v_status_message := 'Invoice not in Billing or AR';

			 ELSIF (v_billing_trx_id IS NULL AND v_billing_status = 'D') THEN
				v_status_message := 'Force Failure Invoice Dups exist in Billing or AR';
				v_new_invoice := 'X' || inv_rec.invoice;
				v_orig_invoice := inv_rec.invoice;

			 ELSE  /* 10 */
				v_status_message := 'Invoice in Billing but not in AR';
				v_new_invoice := 'X' || inv_rec.invoice;
				v_orig_invoice := inv_rec.invoice;
			 END IF;  /* 10 exists in billing */
      END IF;  /* 1 exists in AR */

       --dbms_output.put_line('Status Message : '||inv_rec.transmission_id||':' ||v_status_message);
      ----------------------------------------------------------
      -- Update XXAR_PAYMENTS_INTERFACE table
      update_xxar_table (inv_rec.transmission_id,
                         inv_rec.transmission_record_id,
                         inv_rec.inv_position,
                         v_new_invoice,
                         v_orig_invoice,
                         substr(v_status_message,1,100),
                         v_inv_customer_nbr,
                         v_amt_due_remaining);

   end loop;
	xxcm_common.write_log('Main Program End...');
EXCEPTION
   WHEN OTHERS THEN
      xxcm_common.write_log (' Oracle Err in SECTION 1:' ||dbms_utility.format_error_backtrace||sqlerrm);

end;
/

---------------------------------------------------------------
---------------------------------------------------------------
-- SECTION 1.5
-- Attempt to apply cash to invoices when there isn't a perfect match
--
-- If all the invoices have some money applied and receipt remit amt = total amt applied – do nothing.
-- We’ll let Oracle decide where to put the money
--
-- If   1) a receipt contains one or more invoice with 0 applied amount or
--      2) receipt remit amt = total amt applied
-- then redistribute money to invoices based on amount due remaining in AR.
-- Oracle requires that Receipt Remittance Amt = Sum of Amt applied to the Invoices.
-- If we run out of money, short (or leave at 0) the last invoice(s).
-- If we have extra money, add remaining to the first invoice.

---------------------------------------------------------------
---------------------------------------------------------------
declare

   cursor r is
     -- Receipts with an invoice with Remittance Amt = 0
     select i6.batch_name, i6.item_number, i6.remittance_amount,
            r.total_amt_due_remaining,
            r.total_amt_applied
     from xxar_payments_interface i6,
          (select batch_name, item_number,
                  sum(nvl(amt_due_remaining1*100,0)) +
                    sum(nvl(amt_due_remaining2*100,0)) +
                    sum(nvl(amt_due_remaining3*100,0)) total_amt_due_remaining,
                  sum(nvl(amount_applied1,0)) +
                    sum(nvl(amount_applied2,0)) +
                    sum(nvl(amount_applied3,0)) total_amt_applied
            from xxar_payments_interface
            where
            status_message1 like '%Remittance Amount is $0%'
               or status_message2 like '%Remittance Amount is $0%'
               or status_message3 like '%Remittance Amount is $0%'
            group by batch_name, item_number) r
     where i6.batch_name = r.batch_name
       and i6.item_number = r.item_number
       and i6.record_type = 6
     UNION
     -- Receipts where remittance amt <> total amt applied on invoices
     select i6.batch_name, i6.item_number, i6.remittance_amount,
            r.total_amt_due_remaining,
            r.total_amt_applied
     from xxar_payments_interface i6,
          (select batch_name, item_number,
                  sum(nvl(amt_due_remaining1*100,0)) +
                    sum(nvl(amt_due_remaining2*100,0)) +
                    sum(nvl(amt_due_remaining3*100,0)) total_amt_due_remaining,
                  sum(nvl(amount_applied1,0)) +
                    sum(nvl(amount_applied2,0)) +
                    sum(nvl(amount_applied3,0)) total_amt_applied
            from xxar_payments_interface
            where record_type = 4
            group by batch_name, item_number) r
     where i6.batch_name = r.batch_name
       and i6.item_number = r.item_number
       and i6.record_type = 6
       and i6.remittance_amount <> r.total_amt_applied
     order by 1, 2;

     -- the invoices
   cursor i (p_batch_name number, p_item_number number)  is
     select
        inv1.transmission_id, inv1.transmission_record_id,
        inv1.batch_name, inv1.item_number, inv1.overflow_sequence,
        '1' inv_position,
        inv1.invoice1 invoice, inv1.amount_applied1 amount_applied,
        inv1.amt_due_remaining1 amt_due_remaining,
        inv1.status_message1 status_message
     from
        xxar_payments_interface inv1
     where
            inv1.invoice1 is not null
        and record_type = 4
        and batch_name = p_batch_name
        and item_number = p_item_number
     UNION
     select
        inv2.transmission_id, inv2.transmission_record_id,
        inv2.batch_name, inv2.item_number, inv2.overflow_sequence,
        '2' inv_position,
        inv2.invoice2 invoice, inv2.amount_applied2 amount_applied,
        inv2.amt_due_remaining2 amt_due_remaining,
        inv2.status_message2 status_message
     from
        xxar_payments_interface inv2
     where
           inv2.invoice2 is not null
       and record_type = 4
       and batch_name = p_batch_name
       and item_number = p_item_number
     UNION
     select
        inv3.transmission_id,inv3.transmission_record_id,
        inv3.batch_name, inv3.item_number, inv3.overflow_sequence,
        '3' inv_position,
        inv3.invoice3 invoice, inv3.amount_applied3 amount_applied,
        inv3.amt_due_remaining3 amt_due_remaining,
        inv3.status_message3 status_message
     from
        xxar_payments_interface inv3
     where
           inv3.invoice3 is not null
       and record_type = 4
       and batch_name = p_batch_name
       and item_number = p_item_number
     order by batch_name, item_number;

   v_new_amount_applied number;
   v_running_total number;
   v_invoice_count number;
   v_extra_money number;
   v_status_message varchar2(250);

begin

   for r_rec in r loop

       dbms_output.put_line('-----------------------------------------------------------------------------');
       dbms_output.put_line ('Receipt....' || r_rec.batch_name || ' ' || r_rec.item_number);
       dbms_output.put_line (rpad('...Receipt Remit Amt:',31) || lpad(r_rec.remittance_amount/100,10));
       dbms_output.put_line (rpad('...Orig File Total Amt Applied:',31) || lpad(r_rec.total_amt_applied/100,10));
       dbms_output.put_line (rpad('...Total Amt Due Remaining:',31) || lpad(r_rec.total_amt_due_remaining/100,10));

       -- Redistribute cash based on amt due
       -- If remit amt is less than amt due - short the last invoice(s)
       -- If remit amt is more than amt due - add remaining on to 1st invoice so the totals match

       -- if we're going to have extra money that we need to apply the the first invoice
       if r_rec.total_amt_due_remaining < r_rec.remittance_amount then
           v_extra_money := r_rec.remittance_amount - r_rec.total_amt_due_remaining;
       else
           v_extra_money := 0;
       end if;

       v_running_total := r_rec.remittance_amount;
       v_invoice_count := 1;

       for i_rec in i (r_rec.batch_name, r_rec.item_number) loop

             if v_running_total >= i_rec.amt_due_remaining*100 then  --we're going to fully pay this invoice
                 if v_invoice_count = 1 then  -- if we have extra money, add it to the first invoice
                     v_new_amount_applied :=  i_rec.amt_due_remaining*100 + v_extra_money;
                     v_status_message := i_rec.status_message || ', amt due assigned to invoice';
                 else
                     v_new_amount_applied := i_rec.amt_due_remaining*100;
                     v_status_message := i_rec.status_message || ', amt due assigned to invoice';
                 end if;
             elsif  v_running_total > 0 then   --we're going to short this invoice
                 v_new_amount_applied := v_running_total;
                 v_status_message := i_rec.status_message || ', partial amt due assigned to invoice';
             elsif v_running_total = 0 then -- all of the money has been allocated
                 v_new_amount_applied := 0;
                 v_status_message := i_rec.status_message;
             end if;

              v_running_total := v_running_total - v_new_amount_applied;
              v_invoice_count := v_invoice_count + 1;

            dbms_output.put_line ('...Invoice ' || rpad(i_rec.invoice,10) || ' orig amount_applied: '  || lpad(i_rec.amount_applied/100,8) ||  ' amt due remaining: '  || lpad(i_rec.amt_due_remaining,8) || ' new amount_applied: ' || lpad(v_new_amount_applied/100,8));

             if i_rec.inv_position = 1 then
               update xxar_payments_interface set amount_applied1 = v_new_amount_applied, status_message1 = substr(v_status_message,1,100) where transmission_record_id = i_rec.transmission_record_id;
             elsif i_rec.inv_position = 2 then
               update xxar_payments_interface set amount_applied2 = v_new_amount_applied, status_message2 = substr(v_status_message,1,100) where transmission_record_id = i_rec.transmission_record_id;
             elsif i_rec.inv_position = 3 then
               update xxar_payments_interface set amount_applied3 = v_new_amount_applied, status_message3 = substr(v_status_message,1,100) where transmission_record_id = i_rec.transmission_record_id;
             end if;

       end loop;

   end loop;
   commit;

end;
/
---------------------------------------------------------------
---------------------------------------------------------------
-- SECTION 2
-- Update receipt related info -- comments and customer fields
---------------------------------------------------------------
---------------------------------------------------------------

declare

      -- A receipt can have any number of invoices.
      -- This section only looks at the first 9 invoices
      cursor rcpt_cur is

      select
         rt6.batch_name,
         rt6.item_number,
        -- 1st overflow record --
         nvl(rt4_1.invoice1_orig, rt4_1.invoice1) invoice1,
         to_char(rt4_1.amount_applied1/100)       amount_applied1,
         rt4_1.customer_number1                   customer_number1,
         nvl(rt4_1.invoice2_orig, rt4_1.invoice2) invoice2,
         to_char(rt4_1.amount_applied2/100)       amount_applied2,
         rt4_1.customer_number2                   customer_number2,
         nvl(rt4_1.invoice3_orig, rt4_1.invoice3) invoice3,
         to_char(rt4_1.amount_applied3/100)       amount_applied3,
         rt4_1.customer_number3    customer_number3,
         -- 2nd overflow record --
          nvl(rt4_2.invoice1_orig, rt4_2.invoice1) invoice4,
          to_char(rt4_2.amount_applied1/100)   amount_applied4,
         rt4_2.customer_number1    customer_number4,
          nvl(rt4_2.invoice2_orig, rt4_2.invoice2) invoice5,
          to_char(rt4_2.amount_applied2/100) 	amount_applied5,
         rt4_2.customer_number2 	customer_number5,
          nvl(rt4_2.invoice3_orig, rt4_2.invoice3) invoice6,
          to_char(rt4_2.amount_applied3/100) 	 amount_applied6,
         rt4_2.customer_number3 	 customer_number6,
         -- 3rd overflow record --
          nvl(rt4_3.invoice1_orig, rt4_3.invoice1) invoice7,
          to_char(rt4_3.amount_applied1/100) 	  amount_applied7,
         rt4_3.customer_number1 	   customer_number7,
          nvl(rt4_3.invoice2_orig, rt4_3.invoice2) invoice8,
               to_char(rt4_3.amount_applied2/100) 	  amount_applied8,
         rt4_3.customer_number2 	  customer_number8,
          nvl(rt4_3.invoice3_orig, rt4_3.invoice3) invoice9,
          to_char(rt4_3.amount_applied3/100) 	  amount_applied9,
         rt4_3.customer_number3 	  customer_number9
      from
        -- 3rd overflow record --
         (select * from xxar_payments_interface
           where overflow_sequence = 3 and record_type = 4) rt4_3,
        -- 2nd overflow record --
         (select * from xxar_payments_interface
           where overflow_sequence = 2 and record_type = 4) rt4_2,
        -- 1st overflow record --
         (select * from xxar_payments_interface
           where overflow_sequence = 1 and record_type = 4) rt4_1,
         xxar_payments_interface rt6 --the receipt header record
       where
         rt4_3.item_number(+) = rt6.item_number
         and rt4_3.batch_name(+) = rt6.batch_name
         and rt4_2.item_number(+) = rt6.item_number
         and rt4_2.batch_name(+) = rt6.batch_name
         and rt4_1.item_number(+) = rt6.item_number
         and rt4_1.batch_name(+) = rt6.batch_name
         and rt6.record_type = 6;

      v_comments            varchar2(340);
      v_customer_nbr        varchar2(20);
      v_lockbox             varchar2(20);

begin

  v_lockbox := '&&1';
  dbms_output.put_line ('Lockbox parameter:  ' || v_lockbox);

  for rcpt_rec in rcpt_cur loop
    v_comments := NULL;
    v_customer_nbr := NULL;

    -- Create comments field -- up to 9 invoices
    v_comments := lpad(to_char(rcpt_rec.item_number),3,'0') ||') ';
    v_comments := v_comments || rcpt_rec.invoice1  || ' | ' || rcpt_rec.amount_applied1;
    if rcpt_rec.invoice2 is not null then
      v_comments := v_comments || ' | ' || rcpt_rec.invoice2 || ' | ' || rcpt_rec.amount_applied2;
    end if;
    if rcpt_rec.invoice3 is not null then
      v_comments := v_comments || ' | ' || rcpt_rec.invoice3  || ' | ' || rcpt_rec.amount_applied3;
    end if;
    if rcpt_rec.invoice4 is not null then
      v_comments := v_comments || ' | ' || rcpt_rec.invoice4  || ' | ' || rcpt_rec.amount_applied4;
    end if;
    if rcpt_rec.invoice5 is not null then
      v_comments := v_comments || ' | ' || rcpt_rec.invoice5  || ' | ' || rcpt_rec.amount_applied5;
    end if;
    if rcpt_rec.invoice6 is not null then
      v_comments := v_comments || ' | ' || rcpt_rec.invoice6  || ' | ' || rcpt_rec.amount_applied6;
    end if;
    if rcpt_rec.invoice7 is not null then
      v_comments := v_comments || ' | ' || rcpt_rec.invoice7  || ' | ' || rcpt_rec.amount_applied7;
    end if;
    if rcpt_rec.invoice8 is not null then
      v_comments := v_comments || ' | ' || rcpt_rec.invoice8  || ' | ' || rcpt_rec.amount_applied8;
    end if;
    if rcpt_rec.invoice9 is not null then
      v_comments := v_comments || ' | ' || rcpt_rec.invoice9  || ' | ' || rcpt_rec.amount_applied9;
    end if;

    -- Assign the first invoice customer number found to the receipt header
    if rcpt_rec.customer_number1 is not null then
      v_customer_nbr := rcpt_rec.customer_number1;
    elsif v_customer_nbr is null and rcpt_rec.customer_number2 is not null then
      v_customer_nbr := rcpt_rec.customer_number2;
    elsif v_customer_nbr is null and rcpt_rec.customer_number3 is not null then
      v_customer_nbr := rcpt_rec.customer_number3;
    elsif v_customer_nbr is null and rcpt_rec.customer_number4 is not null then
      v_customer_nbr := rcpt_rec.customer_number4;
    elsif v_customer_nbr is null and rcpt_rec.customer_number5 is not null then
      v_customer_nbr := rcpt_rec.customer_number5;
    elsif v_customer_nbr is null and rcpt_rec.customer_number6 is not null then
      v_customer_nbr := rcpt_rec.customer_number6;
    elsif v_customer_nbr is null and rcpt_rec.customer_number7 is not null then
      v_customer_nbr := rcpt_rec.customer_number7;
    elsif v_customer_nbr is null and rcpt_rec.customer_number8 is not null then
      v_customer_nbr := rcpt_rec.customer_number8;
    elsif v_customer_nbr is null and rcpt_rec.customer_number9 is not null then
      v_customer_nbr := rcpt_rec.customer_number9;
    -- If no customers were found on the receipt, assign the default customer
     else
        select min(to_number(r.customer_number))
        into v_customer_nbr
        from ar_customers r
        where upper(r.customer_name) = 'DEFAULT CUSTOMER'
        and r.status = 'A';
    end if;

    -- Update table
    update
       xxar_payments_interface
    set
       comments = v_comments,
       rec_customer_number = v_customer_nbr
    where
          batch_name = rcpt_rec.batch_name
      and item_number =  rcpt_rec.item_number
      and record_type = 6;

    -- For HK and SG files, need to stip out the /1 at the end of the image reference
    -- (as of 8/2015, they don't use the image stuff but we'll still update this)
    if v_lockbox in ('BOA_HK','BOA_SG') then
        UPDATE xxar_payments_interface
            SET attribute2 =  substr(attribute2,1,instr(attribute2,'/') -1)
        WHERE record_type = '6'
          AND attribute2 is not null
          AND batch_name = rcpt_rec.batch_name
          AND item_number =  rcpt_rec.item_number;
    end if;

    commit;
  end loop;

  -- More HK and SG file differences (outside the loop)
  if v_lockbox in ('BOA_HK','BOA_SG') then
    update xxar_payments_interface
    set origination = (select bank_origination_number from ar_lockboxes where lockbox_number = substr(rtrim(ltrim(origination)),5,4))
    where record_type = 1;

    update xxar_payments_interface
    set lockbox_number = (
         select rtrim(ltrim(lockbox_number)) from xxar_payments_interface where record_type = 2)
    where record_type in (7,5,6,8);

    update xxar_payments_interface
    set deposit_date = (select min(deposit_date) from xxar_payments_interface where record_type = 7)
    where record_type in ( 1,5,6,8);
    commit;
  end if;

end;
/

-------------------------------------------------------
-------------------------------------------------------
-- SECTION 3
-- Update field that contains output string
-------------------------------------------------------
-------------------------------------------------------

declare
   cursor l_cur is
   select p.*, ltrim(first_value(lockbox_number IGNORE NULLS) OVER (),'0') master_lockbox_number
   from xxar_payments_interface p
    order by transmission_record_id
   for update of transmission_record_id;

   v_output          VARCHAR2(300);
   v_amt_applied1    VARCHAR2(20);
   v_amt_applied2    VARCHAR2(20);
   v_amt_applied3    VARCHAR2(20);
   v_att2            VARCHAR2(28);
   v_lockbox_number  VARCHAR2(7);
   v_lockbox         VARCHAR2(20);

begin

    -- Lockbox parameter
   v_lockbox := '&&1';

   for l_rec in l_cur loop
      -- Record Types
      ---- 1 Transmission Header
      ---- 2 Lockbox Header
      ---- 5 Batch Header
      ---- 6 Detail Record
      ---- 4 Overflow Record
      ---- 7 Batch Total Record
      ---- 8 Lockbox Total Record
      ---- 9 Trailer Record

      -- Lockbox number is only on record 2 -- cursor is sorted to pick up record 2 first, we'll use v_lockbox_number for other record types
      if v_lockbox_number IS NULL then
         v_lockbox_number := trim(l_rec.master_lockbox_number);
      end if;

      -- Consider negative amt applied, decode can't be included below
      select decode(sign(l_rec.amount_applied1),-1,
               '-' || lpad(to_char(abs(l_rec.amount_applied1)),9,'0'),
               lpad(to_char(l_rec.amount_applied1),10,'0'))
      into v_amt_applied1
      from dual;

      select decode(sign(l_rec.amount_applied2),-1,
               '-' || lpad(to_char(abs(l_rec.amount_applied2)),9,'0'),
               lpad(to_char(l_rec.amount_applied2),10,'0'))
      into v_amt_applied2
      from dual;

      select decode(sign(l_rec.amount_applied3),-1,
               '-' || lpad(to_char(abs(l_rec.amount_applied3)),9,'0'),
               lpad(to_char(l_rec.amount_applied3),10,'0'))
      into v_amt_applied3
      from dual;

      ------------------------------------------------------------------------------------------------------------------
      -- Create output string -- different formats based on record type
      -- not sure if all of the HK/SG vs US changes are necessary but we're going to go with it...
      if l_rec.record_type = 1 then
--           if v_lockbox in ('BOA_HK','BOA_SG') then
         v_output := '1' ||  rpad(l_rec.origination,10, ' ') || to_char(l_rec.deposit_date,'RRMMDD') ;
--           else
--              v_output := l_rec.input_string;
--           end if;

       ------------------------------------------------------
      elsif l_rec.record_type = 2 then
--           if v_lockbox in ('BOA_HK','BOA_SG') then
         v_output := '2' || rpad(v_lockbox_number,7, ' ') || rpad(l_rec.destination_account,12,' ');
--           else
--              v_output := l_rec.input_string;
--           end if;

      elsif l_rec.record_type = 4 then
         v_output :=
                    '4' ||
                    l_rec.batch_name ||
                    lpad(to_char(l_rec.item_number),3,'0') ||
                    '6'  ||
                    lpad(to_char(l_rec.overflow_sequence),2,'0') ||
                      nvl(l_rec.overflow_indicator,'0') ||
                    rpad(nvl(l_rec.invoice1,' '),14,' ')  ||
                    v_amt_applied1 ||
                    rpad(nvl(l_rec.invoice2,' '),14,' ')  ||
                    v_amt_applied2 ||
                    rpad(nvl(l_rec.invoice3,' '),14,' ')  ||
                    v_amt_applied3;

      ------------------------------------------------------
      elsif l_rec.record_type = 5 then
--            if v_lockbox in ('BOA_HK','BOA_SG') then
         v_output := '5' || l_rec.batch_name || rpad(v_lockbox_number,7, ' ') || to_char(l_rec.deposit_date,'RRMMDD') ;
--            else
--                v_output := l_rec.input_string;
--            end if;

        ------------------------------------------------------
      -- Remove MICR info, put customer in place of MICR, add comments, transmission id which will link back to image, lockbox number
      elsif l_rec.record_type = 6 then
         v_output :=
            '6' ||
            l_rec.batch_name ||
            lpad(to_char(l_rec.item_number),3,'0') ||
            lpad(to_char(l_rec.remittance_amount),10,'0') ||
            rpad(l_rec.rec_customer_number,8,' ') ||
            rpad(nvl(l_rec.account,' '),10,' ') ||
            lpad(nvl(l_rec.check_number,' '),8,'0') ||
            nvl(to_char(l_rec.receipt_date,'RRMMDD'), to_char(l_rec.deposit_date,'RRMMDD')) ||   --Asia banks don't send receipt date, default file deposit date
                rpad(nvl(l_rec.attribute2,' '),28,' ')||
                rpad(nvl(v_lockbox_number,' '),7,' ')||
            substr(l_rec.comments,1,240);

      ------------------------------------------------------
      elsif l_rec.record_type = 7 then
--            if v_lockbox in ('BOA_HK','BOA_SG') then
         v_output :=  '7' || l_rec.batch_name || rpad(v_lockbox_number,7, ' ') || to_char(l_rec.deposit_date,'RRMMDD') ||--deposit date
                      lpad(l_rec.batch_record_count,3, '0')|| lpad(l_rec.batch_amount,10, '0');
--            else
--               v_output := l_rec.input_string;
--            end if;

      ------------------------------------------------------
      elsif l_rec.record_type = 8 then
--            if v_lockbox in ('BOA_HK','BOA_SG') then
         v_output := '8' || rpad(v_lockbox_number,7, ' ') || to_char(l_rec.deposit_date,'RRMMDD') ||
                     lpad(l_rec.lockbox_record_count,4, '0')|| lpad(l_rec.lockbox_amount,10, '0');
--            else
--               v_output := l_rec.input_string;
--            end if;

      ------------------------------------------------------
      elsif l_rec.record_type = 9 then
--            if v_lockbox in ('BOA_HK','BOA_SG') then
         v_output := '9' || lpad(l_rec.transmission_record_count,6, '0');
--            else
--               v_output := l_rec.input_string;
--            end if;

      end if;

      -------------------------------------------------
      -- Update record with new output string
      update
        xxar_payments_interface
      set
        output_string = v_output
      where current of l_cur;

   end loop;
   commit;
end;
/

-------------------------------------------------------
-------------------------------------------------------
-- SECTION 4
-- Output report
-------------------------------------------------------
-------------------------------------------------------
-- output report is now an XML publisher report that is emailed to user

-------------------------------------------------------
-------------------------------------------------------
-- SECTION 5
-- Spool out updated data
-------------------------------------------------------
-------------------------------------------------------
set linesize 289
set pagesize 0
set term off
set echo off
set feedback off

spool &v_datafile

select
   rtrim(output_string)
from
   xxar_payments_interface
order by
   transmission_record_id;

spool off

set linesize 100
set pagesize 20
set term on
set echo on
set feedback on

--------------------------------------------------------------------------
-- RESET ENVIRONMENT
--------------------------------------------------------------------------

@$XXTM_TOP/sql/XXCM_REPORT_CLOSE

quit
