create or replace view XXPA_COST_V
as
select 
i.org_id ORG_ID
,j.project_id PROJECT_ID
,m.vendor_id VENDOR_ID
,k.name OPERATING_UNIT_NAME
,i.expenditure_item_id EXPENDITURE_ITEM_ID
,j.segment1 PROJECT_NUMBER
,l.name EXPENDITURE_ORG
,p.expenditure_category EXPENDITURE_CATEGORY
,i.expenditure_type EXPENDITURE_TYPE
,i.expenditure_item_date EXPENDITURE_ITEM_DATE
,m.vendor_name VENDOR_NAME
,i.quantity QUANTITY
,(select meaning from apps.fnd_lookup_values where lookup_type = 'UNIT' and lookup_code = p.unit_of_measure) UOM
,i.burden_cost BURDEN_COST
,i.project_burdened_cost PROJECT_BURDENED_COST
,n.expenditure_comment EXPENDITURE_COMMENT
from PA_EXPENDITURES_ALL h
    ,pa.pa_expenditure_items_all i
    ,pa.pa_projects_all j
    ,hr.hr_all_organization_units k
    ,hr.hr_all_organization_units l
    ,ap.ap_suppliers m
    ,pa.pa_expenditure_comments n
    ,pa.pa_expenditure_types p
where h.expenditure_id = i.expenditure_id 
and i.project_id = j.project_id
and i.vendor_id = m.vendor_id (+)
and i.expenditure_item_id = n.expenditure_item_id (+)
and i.org_id = k.organization_id
and nvl(i.override_to_organization_id,h.incurred_by_organization_id) = l.organization_id
and i.expenditure_type = p.expenditure_type
;
