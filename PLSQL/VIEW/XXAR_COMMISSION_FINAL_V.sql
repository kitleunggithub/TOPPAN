create or replace view XXAR_COMMISSION_FINAL_V
AS
select 
    sales_rpt.org_id ORG_ID,
    sales_rpt.customer_trx_id AR_CUSTOMER_TRX_ID,
    sales_rpt.project_id PROJECT_ID,
    sales_rpt.operating_unit OPERATING_UNIT_NAME,
    sales_rpt.project_number PROJECT_NUMBER,
    sales_rpt.project_name PROJECT_NAME,
    sales_rpt.gl_date GL_DATE,
    sales_rpt.invoice_number INVOICE_NUMBER,
    sales_rpt.product PRODUCT,
    sales_rpt.customer_name CUSTOMER_NAME,
    sales_rpt.invoice_date INVOICE_DATE,
    sales_rpt.invoice_due_date INVOICE_DUE_DATE,
    sales_rpt.receipt_date RECEIPT_DATE,
    sales_rpt.total_invoice_amount_hkd TOTAL_INVOICE_AMOUNT_HKD,
    sales_rpt.amount_applied_hkd AMOUNT_APPLIED_HKD,
    sales_rpt.fully_settled FULLY_SETTLED,
    sales_rpt.project_completion_date PROJECT_COMPLETION_DATE,
    sales_rpt.settled_180_yn SETTLED_OVER_180_YN,
    sales_rpt.total_revenue_hkd TOTAL_REVENUE_HKD,
    sales_rpt.interest INTEREST,
    sales_rpt.total_cost_hkd TOTAL_COST,
    sales_rpt.net_margin NET_MARGIN,
    sales_rpt.net_margin_p NET_MARGIN_P,
    sales_rpt.commission_rate COMMISSION_RATE,
    sales_rpt.entitlement_total ENTITLEMENT_TOTAL,
    sales_rpt.commission_total COMMISSION_TOTAL,
    sales_rep.sales_name SALES_NAME,
    sales_rep.sales_split SALES_SPLIT,
    (sales_rpt.ENTITLEMENT_TOTAL * sales_rep.sales_split)/100 SALES_ENTITLEMENT,
    (sales_rpt.COMMISSION_TOTAL * sales_rep.sales_split)/100 SALES_COMMISSION
from
(
    SELECT
        comm_rpt.*,
        nvl(TOTAL_REVENUE_HKD,0)-nvl(TOTAL_COST_HKD,0)-nvl(INTEREST,0) NET_MARGIN,
        round(decode(nvl(TOTAL_REVENUE_HKD,0),0,0,((nvl(TOTAL_REVENUE_HKD,0)-nvl(TOTAL_COST_HKD,0)-nvl(INTEREST,0))/nvl(TOTAL_REVENUE_HKD,0))*100),2) NET_MARGIN_P,
        fnd_com.value COMMISSION_RATE,
        (nvl(TOTAL_REVENUE_HKD,0) * fnd_com.value) / 100 ENTITLEMENT_TOTAL,
        case when FULLY_SETTLED = 'Y' and SETTLED_180_YN = 'N' then
            (nvl(TOTAL_REVENUE_HKD,0) * fnd_com.value) / 100 
        else
            0
        end COMMISSION_TOTAL
    from
    (
        SELECT
            ra.org_id,
            pppa.project_id,
            hou.name OPERATING_UNIT,
            nvl(pppa.segment1,'                              ') PROJECT_NUMBER,
            nvl(pppa.name,'                              ') PROJECT_NAME,
            ra.customer_trx_id,
            gd.gl_date,
            ra.trx_number INVOICE_NUMBER,
            amlv.name PRODUCT,
            hc.cust_account_id,
            hp.party_name CUSTOMER_NAME,
            ra.trx_date INVOICE_DATE,
            nvl(ra.term_due_date,aps.due_date) INVOICE_DUE_DATE,
            to_date(to_char(max_rcp.receipt_date,'DD-MON-YYYY'),'DD-MON-YYYY') RECEIPT_DATE, 
            sum(nvl(ral.revenue_amount,0)*nvl(ra.exchange_rate,1)) TOTAL_INVOICE_AMOUNT_HKD,
            nvl((select sum(pcdla.amount)
            from pa_expenditure_items_all peia
                ,PA_EXPENDITURES_ALL pea
                ,PA_EXPENDITURE_TYPES pet
                ,PA_COST_DISTRIBUTION_LINES_ALL pcdla
                ,PA_PROJECTS_ALL ppa
            where peia.expenditure_id = pea.expenditure_id
            and peia.expenditure_type = pet.expenditure_type
            and peia.expenditure_item_id = pcdla.expenditure_item_id
            and ppa.project_id = pcdla.project_id
            and ppa.org_id = pcdla.org_id
            and pet.expenditure_category = 'Internal'
            and ppa.project_id in (select interface_line_attribute6 from RA_CUSTOMER_TRX_LINES_ALL where customer_trx_id = ra.customer_trx_id)
            ),0) TOTAL_COST_HKD,
            ((nvl(aps.amount_applied,0)*nvl(ra.exchange_rate,1)) + (nvl(applied_trx.amount_applied,0)*nvl(ra.exchange_rate,1))) AMOUNT_APPLIED_HKD,
            decode(aps.status,'CL','Y','N') FULLY_SETTLED,
            xct.PROJECT_COMPLETE_DATE PROJECT_COMPLETION_DATE, 
            (case when (nvl(max_rcp.receipt_date,to_date('01-JAN-1990','DD-MON-YYYY')) - xct.PROJECT_COMPLETE_DATE > 180) then 'Y' else 'N' end) SETTLED_180_YN,
            sum(ral.revenue_amount*nvl(ra.exchange_rate,1)) TOTAL_REVENUE_HKD,
            --case when decode(aps.status,'CL','Y','N') = 'N' and (to_date('31-DEC-2020','DD-MON-YYYY') - nvl(ra.term_due_date,aps.due_date)) > 90 then
            --    sum(ral.revenue_amount*nvl(ra.exchange_rate,1)) * 0.01 * ((to_date('31-DEC-2020','DD-MON-YYYY') - nvl(ra.term_due_date,aps.due_date))/30)
            case when decode(aps.status,'CL','Y','N') = 'N' and ((select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE') - nvl(ra.term_due_date,aps.due_date)) > 90 then
                sum(nvl(ral.revenue_amount,0)*nvl(ra.exchange_rate,1)) * 0.01 * (((select trunc(date_value) from xxtm_tableau_params where params_name = 'CUTOFFDATE') - nvl(ra.term_due_date,aps.due_date))/30)    
            when decode(aps.status,'CL','Y','N') = 'Y' and nvl(max_rcp.receipt_date,to_date('01-JAN-1990','DD-MON-YYYY')) - nvl(ra.term_due_date,aps.due_date) > 90 then
                sum(ral.revenue_amount*nvl(ra.exchange_rate,1)) * 0.01 * ((nvl(max_rcp.receipt_date,to_date('01-JAN-1990','DD-MON-YYYY')) - nvl(ra.term_due_date,aps.due_date))/30)
            else
                0
            end INTEREST
        FROM ra_customer_trx_all ra,
             RA_CUSTOMER_TRX_LINES_ALL ral,
            (
            select * from RA_CUST_TRX_LINE_GL_DIST_ALL gld 
            WHERE gld.account_class = 'REC'
            AND gld.latest_rec_flag = 'Y'            
            ) gd,
            ar_payment_schedules_all aps,
            ra_cust_trx_types_all rt,
            hz_cust_accounts hc,
            hz_parties hp,
            hr_all_organization_units hou,
            PA_PROJECTS_ALL pppa,
            pa_projects_all ppa,
            xxtm.xxbs_customer_trx xct,
            AR_MEMO_LINES_ALL_VL amlv,             
            (
                select araa.applied_customer_trx_id customer_trx_id, max(acra.receipt_date) receipt_date
                 from AR_CASH_RECEIPTS_ALL acra,ar_receivable_applications_all araa
                 where acra.cash_receipt_id = araa.cash_receipt_id
                 and araa.applied_customer_trx_id is not null
                group by araa.applied_customer_trx_id
            ) max_rcp,
            (
            select ra2.previous_customer_trx_id, (aps2.amount_applied*-1) amount_applied
            from ra_customer_trx_all ra2,
                ar_payment_schedules_all aps2
            where ra2.customer_trx_id = aps2.customer_trx_id 
            and ra2.previous_customer_trx_id is not null
            ) applied_trx
        WHERE ppa.project_id = ral.interface_line_attribute6
            AND pppa.project_id (+)= ra.interface_header_attribute2
            AND xct.customer_trx_id (+) = ra.interface_header_attribute3
            AND xct.primary_product_type_id = amlv.memo_line_id
            AND ra.customer_trx_id = ral.customer_trx_id
            AND ra.customer_trx_id = gd.customer_trx_id
            AND ra.customer_trx_id = aps.customer_trx_id
            AND ra.org_id = aps.org_id
            AND ra.customer_trx_id = applied_trx.previous_customer_trx_id (+)
            AND ra.customer_trx_id = max_rcp.customer_trx_id (+)
            AND ra.org_id = hou.organization_id
            AND ra.customer_trx_id = aps.customer_trx_id
            --AND ra.complete_flag = 'Y'
            AND ra.cust_trx_type_id = rt.cust_trx_type_id
            AND ra.bill_to_customer_id = hc.cust_account_id
            AND hc.status = 'A'
            AND hp.party_id = hc.party_id
            AND ra.interface_header_context = 'XXBS BILLING INVOICES'
            AND rt.name like 'TM FINANCIAL%'
            --AND ra.PREVIOUS_CUSTOMER_TRX_ID is null -- show credit memo at Tableau
        group by ra.org_id,
            pppa.project_id,
            hou.name,
            pppa.segment1,
            pppa.name,
            ra.customer_trx_id,
            gd.gl_date,
            ra.trx_number,
            amlv.name,
            hc.cust_account_id,
            hp.party_name,
            ra.trx_date,
            ra.term_due_date,
            aps.due_date,
            max_rcp.receipt_date, 
            aps.amount_applied,  
            applied_trx.amount_applied,
            aps.status,
            xct.PROJECT_COMPLETE_DATE,
            ra.exchange_rate
    ) comm_rpt,
    (
        select lookup_code low,meaning high,description value,enabled_flag,start_date_active,end_date_active from fnd_lookups 
        where lookup_type = 'XXAR_MARGIN_COMMISSION'
    ) fnd_com
    where decode(nvl(TOTAL_REVENUE_HKD,0),0,0,((nvl(TOTAL_REVENUE_HKD,0)-nvl(TOTAL_COST_HKD,0)-nvl(INTEREST,0))/nvl(TOTAL_REVENUE_HKD,0))*100) >= fnd_com.low
    and decode(nvl(TOTAL_REVENUE_HKD,0),0,0,((nvl(TOTAL_REVENUE_HKD,0)-nvl(TOTAL_COST_HKD,0)-nvl(INTEREST,0))/nvl(TOTAL_REVENUE_HKD,0))*100) < fnd_com.high
) sales_rpt,
(
select ra.customer_trx_id,
    jrd.resource_name sales_name,
    nvl(xrs.SPLIT_PERCENTAGE,0) sales_split
from ra_customer_trx_all ra, 
    xxbs_rep_splits xrs,
    JTF_RS_DEFRESOURCES_V jrd
where xrs.customer_trx_id = ra.interface_header_attribute3 
and xrs.salesrep_id = jrd.resource_id 
) sales_rep
where sales_rpt.customer_trx_id = sales_rep.customer_trx_id
--show offset invoice in Tableau
/*
and not exists (
    select distinct rall.customer_trx_id
    from ra_customer_trx_lines_all rall
    where (rall.customer_trx_id = sales_rep.customer_trx_id or rall.previous_customer_trx_id = sales_rep.customer_trx_id)
    and nvl(rall.previous_customer_trx_id,rall.customer_trx_id) in
    (
    select nvl(ral2.previous_customer_trx_id,ral2.customer_trx_id)
    from ra_customer_trx_lines_all ral2
    where 1=1 
    group by nvl(ral2.previous_customer_trx_id,ral2.customer_trx_id)
    having sum(ral2.revenue_amount) = 0
    )
)
*/
order by project_number asc, invoice_number asc
;
