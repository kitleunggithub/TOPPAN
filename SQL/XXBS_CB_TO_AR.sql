
variable ret_val number
WHENEVER SQLERROR EXIT FAILURE ROLLBACK;

-- PARAM: AR TRX NUMBER
col param_ar_trx_num new_value param_ar_trx_num noprint format a1 tru
select '&1' param_ar_trx_num from dual;

set serveroutput on size 1000000
set lines 132

declare

      cursor v_trx_cur(p_ar_trx_num in varchar2) is

       select
          trx.CUSTOMER_TRX_ID
		  ,trx.AR_TRX_NUMBER
       from
           XXBS_CUSTOMER_TRX trx,
          RA_CUST_TRX_TYPES_ALL ttyp
       where
          trx.cust_trx_type_id = ttyp.cust_trx_type_id
          and trx.current_status = 'Invoiced'
          --and trx.ORGANIZATION_ID = p_operating_unit
          and (p_ar_trx_num is null or trx.ar_trx_number = p_ar_trx_num)
		ORDER BY trx.current_status_date
       ;


   v_request_id number := -1;
   retval boolean := null;
   v_results VARCHAR2(1) ;
   v_error_occurred EXCEPTION;
   v_error_message varchar2(2000) := null;
   v_trx_count number(15) := 0;
   v_operating_unit number(15) := 0;
   v_line_count number(15) := 0;
   --v_dist_count number(15) := 0;
   --v_rep_count number(15) := 0;
   v_error_count number(15) := 0;
   v_skip_count number(15) := 0;
   v_send_count number(15) := 0;
   v_retcode    VARCHAR2(1);

-----------------------------------------------------------------------
-- MAIN
-----------------------------------------------------------------------
begin

   :ret_val := 0;

   --xxcm_common.put_line('*** BEGIN BILLING-AR INTERFACE LOAD ***');

   v_request_id := fnd_global.conc_request_id;

   ----------------------------------------------------------------------------------------
   --get current operating unit
   ----------------------------------------------------------------------------------------
   --v_operating_unit := xxcm_common.get_curr_operating_unit;

   v_error_count := 0;

   v_trx_count := 0;

   v_skip_count :=0;
   
   v_send_count :=0;
    ----------------------------------------------------------------------------------------
    --   fetch BILLING TRANSACTIONS with INVOICED status.
    ----------------------------------------------------------------------------------------
    for v_trx_rec in v_trx_cur('&param_ar_trx_num') loop
    begin


       --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'FOUND TRX NUMBER: '||v_trx_rec.ar_trx_number||' (trx id:'||v_trx_rec.customer_trx_id||')');

       XXBS_INVOICE_AR_PKG.send_cb_to_ar(p_customer_trx_id => v_trx_rec.CUSTOMER_TRX_ID,
                               p_return_status => v_results,
                               p_msg => v_error_message);
       --xxcm_common.put_line('v_results Trx: # '||v_results);								
       IF (v_results = 'S') THEN
            v_send_count := v_send_count + 1;
			xxcm_common.put_line('SEND Trx: # '||v_trx_rec.AR_TRX_NUMBER||' id '||v_trx_rec.CUSTOMER_TRX_ID||' TO AR INTERFACE ');
		        --dbms_output.put_line('SEND Trx: # '||v_trx_rec.AR_TRX_NUMBER||' id '||v_trx_rec.CUSTOMER_TRX_ID||' TO AR INTERFACE ');  
			commit;
	   ELSIF (v_results = 'W') THEN
            v_skip_count := v_skip_count + 1;
			xxcm_common.put_line('SKIP  Trx: # '||v_trx_rec.AR_TRX_NUMBER||' id '||v_trx_rec.CUSTOMER_TRX_ID||' REASON: '||v_error_message);
			--dbms_output.put_line('SKIP  Trx: # '||v_trx_rec.AR_TRX_NUMBER||' id '||v_trx_rec.CUSTOMER_TRX_ID||' REASON: '||v_error_message);  
			commit;
	   ELSE
			v_error_count := v_error_count + 1;
			xxcm_common.put_line('ERROR  Trx: # '||v_trx_rec.AR_TRX_NUMBER||' id '||v_trx_rec.CUSTOMER_TRX_ID||' ERROR: '||v_error_message);
			--dbms_output.put_line('ERROR  Trx: # '||v_trx_rec.AR_TRX_NUMBER||' id '||v_trx_rec.CUSTOMER_TRX_ID||' ERROR: '||v_error_message);  
			rollback;
       END IF;
	   
       v_trx_count := v_trx_count + 1;
                 
    end;

  end loop; -- trx

  IF (v_error_count > 0) THEN
    raise v_error_occurred;
  ELSE  
      xxcm_common.put_line('*** SUMMARY ***');
      xxcm_common.put_line('*** COMPLETED WITHOUT ERROR BILLING-AR TRY *** '||v_trx_count||' trx ');
	  xxcm_common.put_line('*** COMPLETED WITHOUT ERROR BILLING-AR SEND *** '||v_send_count||' trx ');
      xxcm_common.put_line('*** COMPLETED WITHOUT ERROR BILLING-AR SKIP *** '||v_skip_count||' trx ');
  
      /*      
	  dbms_output.put_line('*** SUMMARY ***');
      dbms_output.put_line('*** COMPLETED WITHOUT ERROR BILLING-AR TRY *** '||v_trx_count||' trx ');  
	  dbms_output.put_line('*** COMPLETED WITHOUT ERROR BILLING-AR SEND *** '||v_send_count||' trx ');
      dbms_output.put_line('*** COMPLETED WITHOUT ERROR BILLING-AR SKIP *** '||v_skip_count||' trx ');
      */  	  
  
  end IF;


EXCEPTION
   WHEN OTHERS THEN
        ROLLBACK; -- rollback all db transactions
         :ret_val := 1;
      --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  Error in MAIN: '||v_error_message||' '||SQLERRM);
        --xxcm_errors.log_error('CUSTOM BILLING',
        --                      'XXBS_BILL_TO_AUTOINVOICE',
        --                      'Error in MAIN: '||v_error_message||' '||SQLERRM, TRUE, v_request_id);  -- do a commit for error logging only.
        
        
		xxcm_common.put_line('*** SUMMARY ***');
		--xxcm_common.put_line(SUBSTR(SQLERRM, 1, 200) );
        xxcm_common.put_line('*** COMPLETED WITH ERROR BILLING-AR TRY *** '||v_trx_count||' trx ');
		xxcm_common.put_line('*** COMPLETED WITH ERROR BILLING-AR SEND *** '||v_send_count||' trx ');
        xxcm_common.put_line('*** COMPLETED WITH ERROR BILLING-AR SKIP *** '||v_skip_count||' trx ');
        xxcm_common.put_line('*** COMPLETED WITH ERROR BILLING-AR ERROR *** '||v_error_count||' trx ');
        /*
        dbms_output.put_line('*** SUMMARY ***');	  
        dbms_output.put_line('*** COMPLETED WITH ERROR BILLING-AR TRY *** '||v_trx_count||' trx ');
		dbms_output.put_line('*** COMPLETED WITH ERROR BILLING-AR SEND *** '||v_send_count||' trx ');
        dbms_output.put_line('*** COMPLETED WITH ERROR BILLING-AR SKIP *** '||v_skip_count||' trx ');
        dbms_output.put_line('*** COMPLETED WITH ERROR BILLING-AR ERROR *** '||v_error_count||' trx ');
        */
END;

/

exit :ret_val
