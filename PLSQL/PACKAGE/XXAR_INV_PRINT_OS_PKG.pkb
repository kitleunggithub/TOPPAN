--------------------------------------------------------
--  DDL for Package Body XXAR_INV_PRINT_OS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAR_INV_PRINT_OS_PKG" 
/*----------------------------------------------------------------------------------
-- Purpose: Extract all outstanding ar invoices to print invoice print out again and sftp to DSO site.
Maintenance History:
  Date:          Version             Name            Remarks
  -----------    ----------------    -------------   ------------------
  10-MAR-2021    1.0                 Billy	    	 Initial Version
----------------------------------------------------------------------------------*/
IS
PROCEDURE PRINT_OS_INVOICES (ERRBUF varchar2,RETCODE number,SFTP_USERID VARCHAR2,SFTP_SERVER VARCHAR2, DAYS_BEFORE_LAST_UPD_DATE NUMBER)
is
--Get all outstanding invoices.
cursor c_os_invoices is
						select a.ar_trx_number
						from   xxbs_customer_trx a
						where  1=1
						and    exists (select 1 from AR_PAYMENT_SCHEDULES_ALL b
									   where b.trx_number = a.ar_trx_number
									   and   b.status = 'OP')
						and (    exists (select 1 from xxbs_customer_trx_lines c where c.customer_trx_id = a.customer_trx_id and trunc(c.last_update_date) >= trunc(sysdate) - DAYS_BEFORE_LAST_UPD_DATE)
						     or  exists (select 1 from XXBS_REP_SPLITS         d where d.customer_trx_id = a.customer_trx_id and trunc(d.last_update_date) >= trunc(sysdate) - DAYS_BEFORE_LAST_UPD_DATE)
						     or  trunc(a.last_update_date) >= trunc(sysdate) - DAYS_BEFORE_LAST_UPD_DATE
							)
						order by 1;

ln_request_id     	NUMBER;
tmp_cnt 			NUMBER := 0;
BEGIN

	For r in c_os_invoices LOOP
			tmp_cnt := tmp_cnt + 1;

			fnd_file.put_line(fnd_file.log,'Processing AR_TRX_NUMBER : ' || r.ar_trx_number);

			--fnd_file.put_line (fnd_file.log,'Before submit Request XXAR_INV_PRINT_MAIN and it will further call XXAR_INV_PRINT generate invoice print out file.') ;

			ln_request_id := fnd_request.submit_request ('XXTM',                -- application
													  'XXAR_INV_PRINT_MAIN',		-- program short name
													  'Submitted By XXAR Print all Outstanding Invoices (DSO)', -- description
													  '',                   -- start time
													  FALSE,                -- sub request
													  R.AR_TRX_NUMBER		--Pass in AR Trx Number
													 );
			COMMIT;
			fnd_file.put_line (fnd_file.log,'Request ID submitted for XXAR_INV_PRINT_MAIN : '|| to_char(ln_request_id) || ' for AR TRX NUMBER : '|| r.ar_trx_number ) ;

	End Loop;

	If tmp_cnt = 0 Then
		fnd_file.put_line(fnd_file.log,'NO Outstanding AR Invoice found!');
	End If;
END;
END xxar_inv_print_os_pkg;

/
