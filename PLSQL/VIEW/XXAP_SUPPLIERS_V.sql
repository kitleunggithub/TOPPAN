-- retrieve
--drop view XXAP_SUPPLIERS_V;

create or replace view XXAP_SUPPLIERS_V
as
select 
    b.org_id ORG_ID,
    a.vendor_id VENDOR_ID,
    b.vendor_site_id VENDOR_SITE_ID,
    nvl(b.party_site_id,-1) PARTY_SITE_ID,
    c.NAME OPERATING_UNIT_NAME,
    a.SEGMENT1 VENDOR_NUMBER,
    a.attribute1 TCC_VENDOR_ID,
    a.attribute2 PAYMENT_PURPOSE,
    a.VENDOR_NAME VENDOR_NAME, 
    a.VENDOR_NAME_ALT ALTERNATE_VENDOR_NAME,
    a.VENDOR_TYPE_LOOKUP_CODE VENDOR_TYPE,
    (select j.payment_method_code
    from ap.ap_suppliers x,
    iby.iby_external_payees_all i, iby.iby_ext_party_pmt_mthds j
    where x.party_id = i.payee_party_id
    and i.ext_payee_id = j.ext_pmt_party_id
    and i.supplier_site_id is null
    and j.primary_flag = 'Y'
    and x.vendor_id = a.vendor_id) PAYMENT_METHOD,
    a.invoice_currency_code INVOICE_CURRENCY_CODE,
    decode(a.MATCH_OPTION, 'P','Purchase Order', 'R', 'Receipt') INVOICE_MATCH_OPTION,
    a.payment_currency_code PAYMENT_CURRENCY_CODE,
    a.payment_priority PAYMENT_PRIORITY,
    h.NAME TERMS_NAME,
    a.terms_date_basis TERMS_DATE_BASIS, 
    a.pay_date_basis_lookup_code PAY_DATE_BASIS,
    a.pay_group_lookup_code PAY_GROUP, 
    a.always_take_disc_flag ALWAYS_TAKE_DISCOUNT,
    (select email_address
     from ar.hz_contact_points
     where contact_point_type = 'EMAIL'
     and owner_table_name = 'HZ_PARTY_SITES'
     and status = 'A'
     and owner_table_id = b.party_site_id) REMIT_TO_EMAIL,
    b.vendor_site_code VENDOR_SITE_CODE,
    b.purchasing_site_flag PURCHASING_SITE_FLAG,
    b.pay_site_flag PAYMENT_SITE_FLAG,
    b.country COUNTRY_CODE,
    b.ADDRESS_LINE1 ADDRESS_LINE1,
    b.ADDRESS_LINE2 ADDRESS_LINE2,
    b.ADDRESS_LINE3 ADDRESS_LINE3,
    b.ADDRESS_LINE4 ADDRESS_LINE4,
    b.city CITY,
    b.province PROVINCE,
    b.zip POSTAL_CODE,
    b.area_code PHONE_AREA_CODE,
    b.phone PHONE,
    b.fax_area_code FAX_AREA_CODE,
    b.fax FAX, 
    b.email_address EMAIL,
    p.concatenated_segments SITE_LIABILITY_ACCOUNT,
    q.concatenated_segments SITE_PREPAYMENT_ACCOUNT,
    d.location_code SITE_SHIP_TO_LOCATION,
    e.location_code SITE_BILL_TO_LOCATION,
    j.payment_method_code SITE_PAYMENT_METHOD,
    f.TOLERANCE_NAME SITE_INVOICE_TOLERANCE,
    decode(b.MATCH_OPTION, 'P', 'Purchase Order','R', 'Receipt') SITE_INVOICE_MATCH_OPTION, 
    b.INVOICE_CURRENCY_CODE SITE_INVOICE_CURRENCY_CODE, 
    g.TOLERANCE_NAME SITE_SERVICES_TOLERANCE,
    b.payment_currency_code SITE_PAYMENT_CURRENCY,
    b.PAYMENT_PRIORITY SITE_PAYMENT_PRIORITY,
    b.pay_group_lookup_code SITE_PAY_GROUP,
    n.NAME SITE_TERMS_NAME,
    b.TERMS_DATE_BASIS SITE_TERMS_DATE_BASIS,
    b.PAY_DATE_BASIS_LOOKUP_CODE SITE_PAY_DATE_BASIS,
    b.ALWAYS_TAKE_DISC_FLAG SITE_ALWAYS_TAKE_DISCOUNT
from AP_SUPPLIERS a, 
    AP_SUPPLIER_SITES_ALL b,
    HR_ALL_ORGANIZATION_UNITS c, 
    HR_LOCATIONS_ALL d,
    HR_LOCATIONS_ALL e, 
    AP_TOLERANCE_TEMPLATES f,
    AP_TOLERANCE_TEMPLATES g, 
    AP_TERMS_TL h,
    iby_external_payees_all i, 
    iby_ext_party_pmt_mthds j,
    rcv_routing_headers m, 
    AP_TERMS_TL n,
    gl_code_combinations_kfv p, 
    gl_code_combinations_kfv q
where a.VENDOR_ID = b.VENDOR_ID
and c.ORGANIZATION_ID = b.org_id
and b.SHIP_TO_LOCATION_ID = d.location_id (+)
and b.BILL_TO_LOCATION_ID = e.location_id (+)
and b.TOLERANCE_ID = f.TOLERANCE_ID (+)
and b.SERVICES_TOLERANCE_ID = g.TOLERANCE_ID (+)
and a.TERMS_ID = h.TERM_ID
and b.TERMS_ID = n.TERM_ID
and b.vendor_site_id = i.supplier_site_id
and b.accts_pay_code_combination_id = p.code_combination_id
and b.prepay_code_combination_id = q.code_combination_id
and i.ext_payee_id = j.ext_pmt_party_id (+)
and a.receiving_routing_id = m.routing_header_id (+)
and b.pay_site_flag = 'Y'
and (a.END_DATE_ACTIVE is null or a.END_DATE_ACTIVE > (select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE'))
and (b.INACTIVE_DATE is null or b.INACTIVE_DATE > (select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE'))
and (j.INACTIVE_DATE is null or j.INACTIVE_DATE > (select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE'))
and j.primary_flag = 'Y'
and ( (i.inactive_date IS NULL) or (i.inactive_date > (select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE')))
order by a.SEGMENT1 ,c.NAME;
