create table apps.xxconv_ar_invoices
(
 seq_num                number,
 operating_unit_name    varchar2(240 CHAR),
 invoice_num            varchar2(50 CHAR),
 transaction_type		varchar2(20 CHAR),
 transaction_date           date,
 gl_date           date,
 invoice_currency_code  varchar2(15 CHAR),
 exchange_rate          number,
 exchange_rate_type     varchar2(30 CHAR),
 exchange_date          date,
 customer_name			varchar2(360 CHAR),
 customer_acc_num		varchar2(20 CHAR),
 site_number            VARCHAR2(20 CHAR),
 COUNTRY_CODE			varchar2(240 CHAR),
 ADDRESS_LINE_1			varchar2(240 CHAR),
 payment_term			varchar2(15 CHAR),
 orig_trx_number		varchar2(20 CHAR),
 orig_project_number	varchar2(20 CHAR),
 SALESREP1              varchar2(30 CHAR),
 SPLIT1                 NUMBER,
 SALESREP2              varchar2(30 CHAR),
 SPLIT2                 NUMBER,
 SALESREP3              varchar2(30 CHAR),
 SPLIT3                 NUMBER,
 PROJECT_NAME           varchar2(100 CHAR),
 PROJECT_COMPLETION_DATE DATE,
 TOTAL_COST             NUMBER, 
 line_number            number,
 line_description       varchar2(240 CHAR),
 quantity				number,
 unit_price				number,
 amount					number,
 standard_memo_line		varchar2(100 CHAR),
 creation_date          date,
 request_id             number,
 status_flag            varchar2(1)    default 'N',
 error_message          varchar2(1000 CHAR),
 org_id                 number,
 group_id               varchar2(80 CHAR),
 RA_CUSTOMER_TRX_LINES_ID number
) tablespace apps_ts_interface;

create or replace public synonym xxconv_ar_invoices for apps.xxconv_ar_invoices;

create index apps.xxconv_ar_invoices_n1 on apps.xxconv_ar_invoices
(request_id)
tablespace apps_ts_interface;


