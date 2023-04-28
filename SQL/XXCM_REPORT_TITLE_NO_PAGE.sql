select substr('&v_request',instr('&v_request','.')+1) v_request from dual;
ttitle left v_line skip 1 -
left 'Program ' v_module center 'Merrill Corporation' right v_day skip 1 -
left 'Version ' v_version center v_title1 right v_time skip 1 -
left 'Request ' v_request center v_title2 skip 1 -
left v_line skip 2
