CREATE OR REPLACE VIEW XXAR_CUSTOMER_MASTER_V
AS
select hcas.org_id ORG_ID,
hca.cust_account_id CUST_ACCOUNT_ID,
hcas.cust_acct_site_id CUST_ACCT_SITE_ID,
hcsu.site_use_id SITE_USE_ID,
hp.party_id PARTY_ID,
hcas.party_site_id PARTY_SITE_ID,
nvl(contact.person_profile_id,-1) PERSON_PROFILE_ID,
nvl(contact.party_id,-1) PERSON_PARTY_ID,
nvl(contact.email_contact_point_id,-1) EMAIL_CONTACT_POINT_ID,
nvl(contact.phone_contact_point_id,-1) PHONE_CONTACT_POINT_ID,
ho.NAME "OPERATING_UNIT_NAME",
hp.PARTY_NAME CUSTOMER_NAME,
hp.ORGANIZATION_NAME_PHONETIC NAME_PRONUNCIATION, 
hca.account_number ACCOUNT_NUMBER, 
ct_lookup.meaning ACCOUNT_TYPE,
hcpc.NAME PROFILE_CLASS,
(select name from ar.ra_terms_tl where term_id = hcp.standard_terms) payment_term,
    (SELECT RESOURCE_NAME FROM JTF_RS_DEFRESOURCES_V WHERE RESOURCE_ID = hca.attribute1) PRIMARY_SALESREP,
    hca.attribute2 PRIMARY_SALESREP_SPLIT,
    (SELECT RESOURCE_NAME FROM JTF_RS_DEFRESOURCES_V WHERE RESOURCE_ID = hca.attribute3) SALESREP_2ND,
    hca.attribute4 SALESREP_2ND_SPLIT, 
    (SELECT RESOURCE_NAME FROM JTF_RS_DEFRESOURCES_V WHERE RESOURCE_ID = hca.attribute5) SALESREP_3RD,
    hca.attribute6 SALESREP_3RD_SPLIT,
    (SELECT RESOURCE_NAME FROM JTF_RS_DEFRESOURCES_V WHERE RESOURCE_ID = hca.attribute7) SALESREP_4TH,
    hca.attribute8 SALESREP_4TH_SPLIT,
    (SELECT RESOURCE_NAME FROM JTF_RS_DEFRESOURCES_V WHERE RESOURCE_ID = hca.attribute9) SALESREP_5TH,
    hca.attribute10 SALESREP_5TH_SPLIT,
    hca.attribute11 STOCK_CODE,
    to_date(hca.attribute12,'YYYY/MM/DD HH24:MI:SS') CUSTOMER_SINCE,
    hca.attribute13 CREDIT_RATING,
    to_number(hca.attribute14) CREDIT_LIMIT,
    to_number(hca.attribute15) CREDIT_PERIOD,
    hca.attribute16 STATUS,
    hca.attribute17 REMARK,
    hca.attribute19 SOE_YN,
    hps.party_site_number SITE_NUMBER,
    hl.country COUNTRY_CODE, hl.address1 ADDRESS_LINE_1, hl.address2 ADDRESS_LINE_2,
    hl.address3 ADDRESS_LINE_3, hl.address4 ADDRESS_LINE_4, hl.city CITY, hl.county COUNTY, hl.state STATE,
    hl.province PROVINCE, hl.postal_code POSTAL_CODE,
    hcsu.site_use_code PURPOSE, 
    hcsu.location LOCATION,
    hcsu.primary_flag PRIMARY_FLAG,
    contact.person_first_name CONTACT_FIRST_NAME,
    contact.person_middle_name CONTACT_MIDDLE_NAME,
    contact.person_last_name CONTACT_LAST_NAME, 
    contact.job_title CONTACT_JOB_TITLE,
    contact.contact_number CONTACT_NUMBER,
    contact.email_address EMAIL,
    contact.email_primary_flag EMAIL_PRIMARY_FLAG,
    contact.phone_country_code TEL_COUNTRY_CODE,
    contact.phone_area_code TEL_AREA_CODE,
    contact.phone_number TEL_PHONE_NUMBER,
    contact.phone_primary_flag TEL_PRIMARY_FLAG
from
       hz_parties              hp
     , hz_party_sites          hps
     , hz_customer_profiles    hcp
     , hz_cust_profile_classes hcpc     
     , hz_cust_accounts        hca
     , hz_cust_acct_sites_all     hcas
     , hz_cust_site_uses_all      hcsu
     , hz_locations           hl
     , HR_ALL_ORGANIZATION_UNITS     ho
     , (select * from ar_lookups where lookup_type = 'CUSTOMER_TYPE') ct_lookup
     , (SELECT 
            hcar.cust_account_id,
            hcar.cust_acct_site_id,
            hpp.person_profile_id,
            hpp.party_id,
            hcp_phone.contact_point_id phone_contact_point_id,
            hcp_email.contact_point_id email_contact_point_id,            
            hpp.person_first_name,
            hpp.person_middle_name,
            hpp.person_last_name, 
            hoc.job_title,
            hoc.contact_number,
            hcp_email.email_address,
            hcp_email.primary_flag email_primary_flag,
            hcp_phone.phone_country_code,
            hcp_phone.phone_area_code,
            hcp_phone.phone_number,
            hcp_phone.primary_flag phone_primary_flag
    FROM hz_parties hp,
            hz_parties rel_hp,
            hz_person_profiles hpp,
            hz_relationships hr,
            hz_org_contacts hoc,
            hz_cust_account_roles hcar,
            hz_contact_points hcp_email,
            hz_contact_points hcp_phone
     WHERE hoc.party_relationship_id = hr.relationship_id
        AND hr.subject_id             = hp.party_id
        AND rel_hp.party_id           = hr.party_id
        AND hp.party_id               = hpp.party_id(+)
        --AND hpp.content_source_type(+) = user_entered
        AND hpp.effective_end_date IS NULL
        AND rel_hp.party_id           = hcar.party_id(+)
        AND hoc.party_relationship_id = hr.relationship_id
        AND hr.subject_table_name     = 'HZ_PARTIES'
        AND hr.subject_type           = 'PERSON'
        AND hr.relationship_code      = 'CONTACT_OF'
        AND hcp_email.owner_table_id(+) = hcar.party_id
        AND hcp_email.contact_point_type(+) = 'EMAIL'
        AND nvl(hcp_email.owner_table_name (+),'HZ_PARTIES') = 'HZ_PARTIES'
        AND (hcp_email.application_id(+) = 222 or hcp_email.application_id(+) is null)
        --AND hcp_email.primary_flag(+) = 'Y'
        AND hcp_email.status(+) = 'A'   
        AND hcp_phone.owner_table_id(+) = hcar.party_id
        AND hcp_phone.contact_point_type(+) = 'PHONE'
        AND nvl(hcp_phone.owner_table_name (+),'HZ_PARTIES') = 'HZ_PARTIES'
		AND (hcp_phone.application_id(+) = 222 or hcp_phone.application_id(+) is null)
        --AND hcp_phone.primary_flag(+) = 'Y'
        AND hcp_phone.status(+) = 'A'
        AND rel_hp.status = 'A'
        AND hr.status = 'A'
        AND hoc.status = 'A'
        AND hcar.status = 'A'
        --AND hcar.cust_account_id      = vl_cust_account_id
        --AND hcar.cust_acct_site_id    = vl_acct_site_id
       ) contact
where hp.party_id              = hca.party_id
   AND hp.party_id              = hps.party_id
   AND hcp.profile_class_id     = hcpc.profile_class_id(+)   
   AND hcp.cust_account_id      = hca.cust_account_id
   AND hca.cust_account_id      = hcas.cust_account_id
   AND hcas.party_site_id       = hps.party_site_id
   AND hcsu.cust_acct_site_id   = hcas.cust_acct_site_id
   AND hcsu.site_use_code       = 'BILL_TO'  -- or 'SHIP_TO'
   AND hca.cust_account_id      = contact.cust_account_id (+)
   AND hcas.cust_acct_site_id   = contact.cust_acct_site_id (+)
   --AND hca.org_id=hcas.org_id
   AND hps.location_id          = hl.location_id
   and hcas.org_id = ho.ORGANIZATION_ID
   and hca.customer_type = ct_lookup.lookup_code
and hp.STATUS = 'A'
and hps.STATUS = 'A'
and hca.STATUS = 'A'
and hcas.STATUS = 'A'
and hcsu.STATUS = 'A'
and hcp.site_use_id is null
order by account_number,operating_unit_name;
