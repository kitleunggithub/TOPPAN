/*************************************************************************

FILENAME	

DESCRIPTION 	

BY		John Parker

		The British Connection Ltd
		6444 Humboldt Avenue South
		Richfield  MN  55423

		Office/Fax: (612) 869 1312

REQUIREMENTS	

USAGE		sqlplus userid/password @FILENAME

CALLED BY	

NOTES		

HISTORY

9/7/95		John Parker	Created

*************************************************************************/

--------------------------------------------------------------------------
-- SET ENVIRONMENT
--------------------------------------------------------------------------

define v_linesize = 80
define v_pagesize = 58
define v_term = 'off'
define v_wrap = 'off'

@$XXTM_TOP/sql/xxcm_report_start

--------------------------------------------------------------------------
-- VARIABLES
--------------------------------------------------------------------------

define v_application = 'ARC'
define v_module = 'ARC'
define v_version = '1.0'

--------------------------------------------------------------------------
-- PARAMETERS
--------------------------------------------------------------------------

@$XXTM_TOP/sql/xxcm_report_parms

-- FROM DATE
select '01'||substr(add_months(sysdate,-1),3) v_p1 from dual;  
select nvl('&1','&v_p1') v_p1 from dual;

-- TO DATE
select last_day(add_months(sysdate,-1)) v_p2 from dual;
select nvl('&2','&v_p2') v_p2 from dual;

-- REQUEST
select ltrim(fnd_global.conc_request_id) v_request from dual;

--------------------------------------------------------------------------
-- TITLE
--------------------------------------------------------------------------

select '' v_title1 from dual;

select 'From &v_p1 To &v_p2' v_title2 from dual;

@$XXTM_TOP/sql/xxcm_report_title

--------------------------------------------------------------------------
-- HEADER PAGE
--------------------------------------------------------------------------

@$XXTM_TOP/sql/xxcm_report_header

prompt DESCRIPTION
prompt ------------

prompt 
prompt 
prompt
prompt

prompt PARAMETERS
prompt -----------

prompt
prompt 
prompt
prompt Sorted by 
prompt
prompt

prompt COLUMNS
prompt --------

prompt
prompt

--------------------------------------------------------------------------
-- MAIN REPORT
--------------------------------------------------------------------------

@$XXTM_TOP/sql/xxcm_report_main

--------------------------------------------------------------------------
-- RESET ENVIRONMENT
--------------------------------------------------------------------------

@$XXTM_TOP/sql/xxcm_report_close
