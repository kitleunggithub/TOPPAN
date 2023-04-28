/* TM Expense Reports Outstanding */
CREATE OR REPLACE VIEW XXAP_EXPENSE_REPORT_V
AS
SELECT
    rt.org_id,
    rt.expense_report_id EXPENSE_REPORT_ID,
    rh.report_header_id REPORT_HEADER_ID,
    rl.report_line_id REPORT_LINE_ID,
    nvl(rd.report_distribution_id,-1) REPORT_DISTRIBUTION_ID,
    pa.project_id PROJECT_ID,
    hou.name OPERATING_UNIT_NAME,
    rh.invoice_num REPORT_NUMBER,
    rh.report_submitted_date REPORT_SUBMITTED_DATE,
    aia.gl_date GL_DATE,
    rh.expense_status_code EXPENSE_STATUS_CODE,
    rh.receipts_status RECEIPTS_STATUS,
    rh.default_currency_code DEFAULT_CURRENCY_CODE,
    rh.total TOTAL,
    ee.full_name FULL_NAME,
    ee.employee_number EMPLOYEE_NUMBER,
    rh.description PURPOSE,
    rh.override_approver_name OVERRIDE_APPROVER_NAME,
    rt.report_type REPORT_TYPE,
    rl.distribution_line_number DISTRIBUTION_LINE_NUMBER,
    rl.item_description EXPENSE_TYPE,
    rl.start_expense_date START_EXPENSE_DATE,
    rl.end_expense_date END_EXPENSE_DATE,
    rl.receipt_currency_amount RECEIPT_CURRENCY_AMOUNT,
    rl.receipt_currency_code RECEIPT_CURRENCY_CODE,
    rl.receipt_conversion_rate RECEIPT_CONVERSION_RATE,
    rl.amount LINE_AMOUNT,
    rl.justification JUSTIFICATION,
    rl.merchant_name#1 MERCHANT_NAME#1,
    rd.amount DIST_AMOUNT,
    pa.segment1 PROJECT_NUMBER,
    ta.task_number TASK_NUMBER,
    gcc.concatenated_segments CONCATENATED_SEGMENTS,
    rl.itemization_parent_id ITEMIZATION_PARENT_ID
FROM
    HR_ALL_ORGANIZATION_UNITS HOU,
    ap.ap_expense_report_headers_all rh,
    ap.ap_expense_report_lines_all rl,
    ap.ap_exp_report_dists_all rd,
    ap.ap_expense_reports_all rt,
    hr.per_all_people_f ee,
    pa.pa_projects_all pa,
    pa.pa_tasks ta,
    apps.gl_code_combinations_kfv gcc,
    ap.ap_invoices_all aia
WHERE hou.organization_id = rh.org_id
  AND rh.report_header_id = rl.report_header_id
  AND rl.report_line_id = rd.report_line_id (+)
  AND rh.expense_report_id = rt.expense_report_id
  AND rh.employee_id = ee.person_id
  AND rh.INVOICE_NUM = aia.INVOICE_NUM (+)
  AND aia.INVOICE_TYPE_LOOKUP_CODE (+) = 'EXPENSE REPORT'
  AND aia.SOURCE(+) = 'SelfService'  
  AND ee.effective_end_date = '31-Dec-4712'
  AND ee.current_employee_flag = 'Y'
  AND rd.project_id = pa.project_id (+)
  AND rd.task_id = ta.task_id (+)
  AND rl.code_combination_id = gcc.code_combination_id (+)
  AND ((rl.itemization_parent_id <> -1) or (rl.itemization_parent_id is null))
  --AND ((rh.expense_status_code <> 'PAID') or (rh.expense_status_code is null))
                        -- WITHDRAWN
                        -- MGRAPPR
                        -- PAID
                        -- INVOICED
                        -- PENDMGR
  --and rh.invoice_num = 'TM13000'                      
ORDER BY rh.expense_status_code, rh.invoice_num, rl.distribution_line_number;
