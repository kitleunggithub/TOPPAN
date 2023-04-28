spool off

set pages 0

select &1 v_step from dual;

select 
	path v_spoolpath 
from 
	cmc_spool
where
        instance = '&v_instance'
        and
        schema = '&v_application'
        and
        module = '&v_module'
        and
        step = &v_step
;

select 
	decode
	(
	&v_step,1,
	'&v_spoolpath'||'/'||'&v_request'||'.txt',
        '&v_spoolpath'||'/'||'&v_request'||'-'||ltrim('&v_step')||'.txt'
	) 
	v_spoolfile
from 
	dual
;

spool &v_spoolfile
