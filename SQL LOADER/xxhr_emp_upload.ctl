-- modified 7/27/2017 for Workday HCM

LOAD DATA
REPLACE
INTO TABLE xxhr_employee_upload
FIELDS TERMINATED BY "|"
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
XEU_ID SEQUENCE(MAX,1),
last_name, 
first_name, 
mi, 
known_as,
emp_number, 
sex, 
street1, 
street2, 
city, 
state, 
zip_code, 
country, 
term_status, 
start_date_active, 
term_date, 
email, 
legal_entity,
product_line,
site,
cost_center,
--default_expense_acct, 
supervisor, 
location_code, 
--set_of_books_name,
grade, 
job_description,
--company, 
--set_of_books_name, 
--job_code, 
--job_code_grade,
created_by        CONSTANT 0,
creation_date     SYSDATE,
last_update_date  SYSDATE,
last_updated_by   CONSTANT 0,
last_update_login CONSTANT 0
)

