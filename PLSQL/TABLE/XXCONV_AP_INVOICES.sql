create table apps.xxconv_ap_invoices
(
 seq_num                number,
 operating_unit_name    varchar2(240),
 invoice_num            varchar2(50),
 invoice_date           date,
 vendor_name            varchar2(240),
 vendor_site_code       varchar2(15),
 invoice_amount         number,
 invoice_currency_code  varchar2(15),
 exchange_rate          number,
 exchange_rate_type     varchar2(30),
 exchange_date          date,
 terms_name             varchar2(50),
 terms_date             date,
 description            varchar2(240),
 payment_method_code    varchar2(30),
 pay_group_lookup_code  varchar2(25),
 line_number            number,
 line_amount            number,
 line_description       varchar2(240),
 accounting_date        date,
 distribution_account   varchar2(43),
 creation_date          date,
 request_id             number,
 status_flag            varchar2(1)    default 'N',
 error_message          varchar2(1000),
 org_id                 number,
 group_id               varchar2(80),
 invoice_id             number,
 invoice_line_id        number
) tablespace apps_ts_interface;

create or replace public synonym xxconv_ap_invoices for apps.xxconv_ap_invoices;

create index apps.xxconv_ap_invoices_n1 on apps.xxconv_ap_invoices
(request_id)
tablespace apps_ts_interface;
