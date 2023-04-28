/*************************************************************************

FILENAME        xxhr_employee_load.sql

DESCRIPTION     Updates employee information in Oracle Financials
                based on Lawson data.

BY              Jill Di Leva

REQUIREMENTS    John Parker

USAGE           sqlplus userid/password @FILENAME

CALLED BY		

NOTES

HISTORY

v1.0   Jill Di Leva		5/30/2002 		Created
       Included output report
v1.1   Jill Di Leva     10/23/2002
	   Expanded report to include SQL errors from XXHR_ERRORS
v1.2   Jill DiLeva   5/11/07
       Add "alter session" command to fix ORA-00600 error code.
       Fix per Max Van Riper
v1.3	Dash Kit
		TM Splite Instance
***************************************************************************/

--------------------------------------------------------------------------
-- SET ENVIRONMENT
--------------------------------------------------------------------------

define v_linesize = 150
define v_pagesize = 58
define v_term = 'off'
define v_wrap = 'off'

@$XXTM_TOP/sql/XXCM_REPORT_START

--------------------------------------------------------------------------
-- VARIABLES
--------------------------------------------------------------------------

define v_application = 'XXHR'
define v_module = 'XXHR_EMPLOYEE_LOAD'
define v_version = '1.3'

--------------------------------------------------------------------------
-- PARAMETERS
--------------------------------------------------------------------------

@$XXTM_TOP/sql/XXCM_REPORT_PARMS

-- REQUEST
select ltrim(fnd_global.conc_request_id) v_request from dual;

--------------------------------------------------------------------------
-- TITLE
--------------------------------------------------------------------------

select 'Employee Load' v_title1 from dual;

select '' v_title2 from dual;

@$XXTM_TOP/sql/XXCM_REPORT_TITLE

--------------------------------------------------------------------------
-- HEADER PAGE
--------------------------------------------------------------------------

@$XXTM_TOP/sql/XXCM_REPORT_HEADERS


--------------------------------------------------------------------------
-- MAIN REPORT
--------------------------------------------------------------------------

@$XXTM_TOP/sql/XXCM_REPORT_MAIN

----------------
-- Call stored procedure 
-- specs are defined in xxhr_emp_upload_spec.sql and xxhr_emp_upload.sql
----------------

-- per MVR
-- attempt to fix ORA-00600: internal error code, arguments: [opixrm-1],[InvalidHandle], error

alter session set session_cached_cursors=0;


begin
xxhr_emp_upload.process_employee;
end;
/

----------------
-- Output report of errors
----------------

col EMP_NUMBER head EMP_NBR for a7
col FIRST_NAME for a14
col LAST_NAME for a20
col MODULE_NAME head MODULE_ERR for a12
col MESSAGE for a75

--------------------------------------------------------------------
-- Following report grabs messages/error from 3 places...
-- Misc messages are stored in XXHR_EMPLOYEE_UPLOAD.  
-- Program SQL errors are inserted into XXHR_ERRORS.
-- Some procedures create errors based on PERSON_ID, some EMP_NUMBER
--------------------------------------------------------------------
select 
	emp_number, 
	first_name, 
	last_name, 
	start_date_active date_hired,
	term_date, 
	null module_name,
	message 
from 
	xxhr_employee_upload u
where 
	message is not null
	and message <> 'Employee terminated'
UNION
-- Where PERSON_ID is stored in ATTRIBUTE2 of the error table
select
    emp_number,
    u.first_name,
    u.last_name,
    u.start_date_active date_hired,
    u.term_date,
    e.module_name,
   character_replace(error_msg,10,32) message
from 
     xxhr_employee_upload u,
     per_people_f p,
     xxhr_errors e
where
     p.employee_number = u.emp_number
     and e.attribute2 = p.person_id
     and e.application = 'EMP_LOAD'
UNION
-- Where EMP_NUMBER is stored in ATTRIBUTE1 of the error table
select
    u.emp_number,
    u.first_name,
    u.last_name,
    u.start_date_active date_hired,
    u.term_date,
    e.module_name,
   character_replace(error_msg,10,32) message
from 
     xxhr_employee_upload u,
     xxhr_errors e
where
     e.attribute1 = u.emp_number
     and e.application = 'EMP_LOAD'
order by 1;

--------------------------------------------------------------------------
-- RESET ENVIRONMENT
--------------------------------------------------------------------------

@$XXTM_TOP/sql/XXCM_REPORT_CLOSE
