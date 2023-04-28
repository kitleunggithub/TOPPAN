--------------------------------------------------------
--  DDL for Package XXHR_EMP_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXHR_EMP_UPLOAD" as

-- Modified 7/15/2015 Jill Dileva
-- Changes for R12 upgrade -- add p_grade to update_employee and create_employee

--JMD 4/13/2017
--Enh 1659 - grade overrides for approval will now be stored in R12, not Lawson
--Clean-up and rewrite process to not use database link to Lawson.
--Data will be loaded into XXHR_EMPLOYEE_UPLOAD via XXHR Employee Load - Step 1 Get Data

--JMD 2/22/19
--add v_grade_non_job and v_grade_job variables to update_employee and create_employee


	-- Creates New employees in Oracle. This process uses  hr_employee_api.create_employee and
	-- hr_person_address_api.create_person_address  procedures.
	Procedure create_employee(p_job_id number,p_emp_number varchar2,p_start_date_active date, p_last_name varchar2,
				  p_first_name varchar2, p_mi varchar2, p_known_as varchar2, p_sex varchar2,
				  p_street1 varchar2, p_street2 varchar2, p_city varchar2,
				  p_state varchar2, p_zipcode varchar2, p_country varchar2, p_email varchar2,
				  p_locat_code varchar2, p_default_expense_acct varchar2,
				  p_set_of_books_name varchar2,
                  p_grade varchar2, p_job_code varchar2,
                  p_grade_non_job number,
                  p_grade_job number);


	-- Updates the Employee /addreess information in Oracle. This process uses hr_person_api.update_person and
	-- hr_person_address_api.update_person_address procedures.

    Procedure update_employee(p_term_date  date,p_emp_number varchar2,p_job_id number,p_person_id number, p_business_group_id number,
                      p_start_date_active date, p_lastname varchar2,
                  p_firstname varchar2, p_mi varchar2, p_known_as varchar2, p_sex varchar2,
                  p_street1 varchar2, p_street2 varchar2, p_city varchar2,
                  p_state varchar2, p_zipcode varchar2, p_country varchar2,
                  p_default_expense_acct varchar2, p_email varchar2,
                  p_locat_code varchar2,
                  p_per_object_version_number number,
                  p_code_combination_id number,
                  p_address_id number,
                  p_set_of_books_name varchar2,
                  p_addr_object_version_number number,
                  p_current_ora_country varchar2,
                  p_grade varchar2,
                  p_job_code varchar2,
                  p_grade_non_job number,
                  p_grade_job number);

	-- Updates the Vendor name/ Vendor Site (Address) information related to the employee when there is a change
	-- in name and address information in Lawson system.

	--Procedure UPDATE_EMP_VENDOR(p_person_id number, p_street1 varchar2, p_street2 varchar2,
	--			      p_city varchar2, p_state varchar2, p_zipcode varchar2, p_country varchar2);

	--
	-- This process updates the salesrep's name when there is employee name change in the Lawson system

	-- Procedure UPDATE_EMP_SALESREP(p_emp_num varchar2, p_name varchar2);

	--
	-- This process updates the email information of the financial user related to the employee

	-- Procedure UPDATE_EMP_FND_USER(p_person_id number, p_email_address varchar2);

	-- This process terminates the employee 90 days after the employee termination date in Lawson system.
	-- This process uses hr_ex_employee_api.actual_termination_emp/final_process_emp/update_term_details_emp
	-- packaged procedures

	Procedure TERMINATE_EMPLOYEE(p_effective_date date, p_person_id number);

	--
	-- The process inactivates the vendor/vendor site associated with employee 90 days after their termination

	--Procedure TERMINATE_EMP_VENDOR(p_person_id number, p_effective_date date);

	--
	-- This process inactivates the salesrep associated with the employee 90 days after their termination

	--Procedure TERMINATE_EMP_SALESREP(p_emp_num varchar2, p_effective_date date);

	--
	-- This process closes the projects associated with salesrep 90 days after their term date

	--Procedure TERMINATE_EMP_SALESREP_PROJ(p_salesrep_id number, p_effective_date date);

	-- This process inactivates the financial user associated with employee  90 days after their termination date.
	-- The end_date will be set to termination date of the employee

	Procedure TERMINATE_EMP_FND_USER(p_person_id number, p_effective_date date);

	-- This process activates the employees by setting the termination date to null. The above case is possible only
	-- when the employee is rehired within 90 days of the termination date. If the employee is rehired after 90 days
	-- of termination date a new employee record will be created in Oracle

	--Procedure  ACTIVATE_EMPLOYEE;

	-- This process activates vendor/vendor sites associated with employee by setting end_date_active and
	-- inactive_date to null. This process activates the salesreps associated with employee by setting the
	-- end_date_active to null

	--Procedure ACTIVATE_EMP_VENDOR;

	--
	-- This process activates the salesreps associated with employee by setting the end_date_active to null

	--Procedure ACTIVATE_EMP_SALESREP;

	--
	-- This Process activates the projects associated with the salesrep

	--Procedure ACTIVATE_EMP_SALESREP_PROJ;

	--
	-- This process checks whether the employee is existing in Oracle or not

	Procedure CHECK_ORA_EMPLOYEE(p_emp_number varchar2, p_person_id out number,
				     p_bussiness_grp_id  out number);

	--
	-- The process checks the employee status in Oracle

	function CHECK_ORA_EMP_STATUS(p_person_id number, p_bus_grp_id number) return boolean;

	--
	-- Formats the address depending on the country

	Procedure get_address(p_country in varchar2, p_state in varchar2,
			      p_zipcode in varchar2, p_address_style out varchar2,
			      p_region_1 out varchar2, p_region_2 out varchar2,
			      p_region_3 out varchar2, p_countryout out varchar2,
			      p_stateout out varchar2, p_zipcodeout out varchar2);

	procedure rehire_emp(p_emp_number varchar2,p_job_id number,p_person_id number, p_business_group_id number,
        p_hire_date date, p_set_of_books_name varchar2, p_country varchar2);

	-- Processes the employee information that is available in XXHR_EMPLOYEE_UPLOAD table

	procedure process_employee;


End xxhr_Emp_upload;


/
