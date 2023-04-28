col v_day new_value v_day noprint format a1 tru
select sysdate v_day from dual;

col v_instance new_value v_instance noprint format a1 tru
select substr(global_name,1,instr(global_name,'.',1,1)-1) v_instance
from global_name;

col v_line new_value v_line noprint format a1 tru
select lpad('-',&v_linesize,'-') v_line from dual;

col v_request new_value v_request noprint format a1 tru

col v_spoolfile new_value v_spoolfile noprint format a1 tru

col v_spoolpath new_value v_spoolpath noprint format a1 tru

col v_step new_value v_step noprint format a1 tru

col v_time new_value v_time noprint format a1 tru
select to_char(sysdate,'HH:MI:SS') v_time from dual;

col v_title1 new_value v_title1 noprint format a1 tru

col v_title2 new_value v_title2 noprint format a1 tru

col v_p1  new_value v_p1  noprint format a1 tru
col v_p2  new_value v_p2  noprint format a1 tru
col v_p3  new_value v_p3  noprint format a1 tru
col v_p4  new_value v_p4  noprint format a1 tru
col v_p5  new_value v_p5  noprint format a1 tru
col v_p6  new_value v_p6  noprint format a1 tru
col v_p7  new_value v_p7  noprint format a1 tru
col v_p8  new_value v_p8  noprint format a1 tru
col v_p9  new_value v_p9  noprint format a1 tru
col v_p10 new_value v_p10 noprint format a1 tru
col v_p11 new_value v_p11 noprint format a1 tru
col v_p12 new_value v_p12 noprint format a1 tru
col v_p13 new_value v_p13 noprint format a1 tru
col v_p14 new_value v_p14 noprint format a1 tru
col v_p15 new_value v_p15 noprint format a1 tru
col v_p16 new_value v_p16 noprint format a1 tru
col v_p17 new_value v_p17 noprint format a1 tru
col v_p18 new_value v_p18 noprint format a1 tru
col v_p19 new_value v_p19 noprint format a1 tru
col v_p20 new_value v_p20 noprint format a1 tru
col v_p21 new_value v_p21 noprint format a1 tru
col v_p22 new_value v_p22 noprint format a1 tru
col v_p23 new_value v_p23 noprint format a1 tru
col v_p24 new_value v_p24 noprint format a1 tru
col v_p25 new_value v_p25 noprint format a1 tru
