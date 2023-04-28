--------------------------------------------------------
--  DDL for Package Body XXHR_EMP_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXHR_EMP_UPLOAD" is

/********************************************************************************************
   File Name 	    : 	xxhr_emp_upload.txt

   Description	    :	Uploads the Employee Data from Lawson system to Oracle

   Author	    :	Gopal Potluri

   Creation_date    :	08-AUG-01


   CHANGE HISTORY


   Author	Last Modified Date 	Description


   GVP		09-AUG-01		Added UPDATE_EMP_VENDOR , UPDATE_EMP_FND_USER
					procedures

   GVP		10-AUG-01		Added CHECK_ORA_EMPLOYEE, UPDATE_EMP_SALESREP,
					GET_ADDRESS procedures

   GVP		16-AUG-01		Added CHECK_ORA_EMP_STATUS function and
					CREATE_EMPLOYEE procedure

   GVP		29-AUG-01		Added UPDATE_EMPLOYEE, TERMINATE_EMPLOYEE procedures

   GVP		30-AUG-01		Added TERMINATE_EMP_VENDOR , TERMINATE_EMP_FND_USER,
					TERMINATE_EMP_SALESREP procedures

   GVP		31-AUG-01		PROCESS_EMPLOYEE Procedure

   GVP		05-SEP-01		Added PROCESS_EMPLOYEE , TERMINATE_EMP_SALESREP_PROJ
				        procedures

   GVP		13-SEP-01		Added Default Values for JOB and SET OF BOOKS

   JMD		14-JAN-02		Removed logic to update PER_PEOPLE_F email address
					from Lawson value.  (easy way - just delete from create
					and update api's)

   JMD		31-FEB-02		1. Deleted most commented out code. Too hard to find
					anything with them all there.  Original in
					c:\orant\bin\Crossbow\xxhr_emp_upload-with_comments.txt
					2. Changed status logic in main program - status based on term date only
					3. Added better exception on check_ora_emp_status to isolate rehires.

   JMD      29-MAY-02  1.  If employee is assigned to a direct cost center (9th char of
                    hm_acct_unit = 1), reassign to corresponding indirect cost center.
					2.  Remove date criteria in CHECK_ORA_EMPLOYEE. Causes problem for future
					hired employees

  JMD   23-OCT-02  Added better error trapping.  Different procedures/functions
	           insert different messages into XXHR_ERRORS.

  JMD   01-JAN-03  Excluded employees with a status of NH.  They only have
                   partial data so it causes problems.
  JMD   08-OCT-03  With ver 8 of Lawson, COUNTRY is now longer a field.
                   Change to COUNTRY_CODE
  JMD   06-FEB-04  Trimmed spaces off of Lawson fields in main cursor

  JMD   04-MAR-04  Added REHIRE_EMP procedure.
                   Changed PROCESS_EMPLOYEE procedure logic to include REHIRE_EMP
                   Add section in update_employee to update employee's location. (was only
                   being done as part of add_employee)
  JMD   07-JUL-04  Modified main select from Lawson.  Link to HRC_PROCESS_LEVEL_MAPPING
  				   to determine which employees to interface
  JMD   02-DEC-05  Change ADDRESS_TYPE from 'JP_C' to 'CUR'  (Necessary for 11.5.10 upgrade)

  JMD   13-JUN-06  Exceptions for employees in company 9 employees - part of process_employee proc
			       Emp number = 2-xxxxx not 9-xxxxx
			       Send work location address, not home address
			       If gl company = 2940, send 2000
				   *** Assuming that employee number is unique across Lawson companies

				   alter table xxhr_employee_upload
				   add company number

				   alter table xxhr_employee_upload
				   add process_level varchar2(5)

				   alter table xxhr_employee_upload
				   add set_of_books_name varchar2(50);

				   alter table hrc_process_level_mapping
				   add oracle_sob varchar2(50)

				   update hrc_process_level_mapping
				   set oracle_sob = 'MERRILL CORPORATION'
				   where company = 1
				   and mrl_emp_interface_flag = 'Y'

				   update hrc_process_level_mapping
				   set oracle_sob = 'MERRILL CANADA'
				   where company = 9
				   and mrl_emp_interface_flag = 'Y'

  JMD  02-FEB-07   Changes to insert_employee procedure.  Pull custom process level mapping
  	   			   data from HRCPLMAP instead of HRC_PROCESS_LEVEL_MAPPING

  JMD  06-APR-07   1.  Trim spaces from location address fields.  Caused problems with Canadian
  	   			   emp/vendor site addresses.  Requries one-time update statement to fix existing records.
				   2.  Store the Lawson to Oracle location code mapping in an attribute/flex field
				   instead of a custom table.  Requries on-time update script to update DFF's
				   for existing location codes. (HR_LOCATIONS.ATTRIBUTE1)
				   3.  Interface India employees to AP.  Assign appropriate address style (IN_GLB)
				   Employee number prefix = 2

  JLO  30-MAY-07   Modified email address from lawason to use @merrillcorp.com

  JLO  12-JUN-07   Added logic to update email address for any existing FND_USER record associated with employee

  JLO  15-NOV-07   Add address formatting logic for Galway employees (Ireland)

  JMD  31-JUL-08   Remove logic to override direct cost center assignment with corresponding
  	   			   in-direct cost center.  The default acct comb on the employee in Oracle should match
				   their assignment in Lawson.

Note....there were updates made between 7/31/08 and 11/21/10 there are not documented here

  JMD  21-NOV-10 Add call to create_person_address api within update_employee procedure
                Employees don't all have addresses when they are first entered into Lawson

  JMD 01-MAY-11
       1)  Changes for Hong Kong and Singapore (address style and organization)
       2)  Performance improvements:
             a) Rewrite of update_emp procedure.
             b) Change to insert_employee - only process active emps and those termed since 1/1/2009 -- we don't have to go back 10 years
             c) Change to process_employee - include everything we need to update_employee in xeu_cur cursor
             and pass to update_employee  saves all of the select into's
       3)  Only update job_id if 11i job_id is null or "DEFAULT"

JMD 10/28/11
 Populated KNOWN_AS field

 alter table xxhr_employee_upload
  add KNOWN_AS varchar2(30);

JMD 3/15/13
Bug fix - employee assignment information not updating correcting if they move countries.
Changes to update_employee procedure -- update address style before calling update_address api

JLO 03/26/2014 Modify logic to terminate employee in Oracle without 90 day delay, but set Final Processing Date in Oracle to
               term date + 90

JMD 8/6/2014
Changes to interface IFN employees from Lawson -- need Chinese address style

JLO 11/11/2014 Modify to set address to uppercase to match Supplier address formatting standard (iExpense)
JLO 12/17/2014 Modified logic for capturing international addresses to set to uppercase

JMD 7/1/15 -- Changes and enhancement for R12 upgrade
1) Updates for Chart of Accounts changes
2) Update employee job code assignment
3) Update employee grade assignment
3) Fix for rehires within 90 days of their term date

JMD 2/9/2016
In Lawson, the CEO's supervisor is himself.  If supervisor is self, send null
Send home addresses for Canada employees

JMD 7/26/2016
Enh 1536 If not specified, default address style to <country_code>_GLB
                As new countries are added, we'll change seeded address style to match format,
                not change this procedure to match what Oracle has.
Enh 1596 Re-term employee after manually reactiviated (either via XXHR_EMP_REHIRE or forms)
            Or ignore employee if "keep active until" date has not passed
Enh 1621 Change to logic of which pay grade we send from Lawson to R12.
            1) exception user field, 2) employee pay grade, 3)TBD if null

JMD 4/13/2017
Enh 1659 - grade overrides for approval will now be stored in R12, not Lawson
Clean-up and rewrite process to not use database link to Lawson.
Data will be loaded into XXHR_EMPLOYEE_UPLOAD via XXHR Employee Load - Step 1 Get Data

JMD 7/5/2017
Enh 1854 -- don't overrirde ass_attribute1 on assignment, they want to be able to manually maintain it for AME

JMD 11/8/2017
Enh 1935 -- issue with error updates on XXHR_EMPLOYEE_UPLOAD
            need to update where "emp_number = v_emp_number" -- not to old employee number format with '-'

JMD  3/05/2018
Enh 1968 - do not add job titles in Oracle
Enh 1980 - create error if location code is not in value set

JMD 5/7/2018
Enh 2083 - re-term employee if manually rehired but aren't in Workday (or are included in file from Workday)

JMD 6/15/2018
Enh 2102 - if not US or UK...put the WD region/state in region_1

JMD 3/24/2019
Enh 2347, CR 212311
Changes for grade - 2 new grade fields (non-job related and job related)
Changes for HK file

JMD 7/29/2019
Enh 2588
Add H prefix to employee number based on locations in value set.

KIT 9/11/2020
TM Split Instance
**********************************************************************************************/

        errbuf   varchar2(200) :=  ' ';
        retcode   varchar2(200) := ' ';

    -----------------------------------------------------------------------------------------------
	-- Formats the address depending on the country
	Procedure get_address(p_country in varchar2, p_state in varchar2,
			      p_zipcode in varchar2, p_address_style out varchar2,
			      p_region_1 out varchar2, p_region_2 out varchar2,
			      p_region_3 out varchar2, p_countryout out varchar2,
			      p_stateout out varchar2, p_zipcodeout out varchar2
			     ) is

        v_err_num	number;         -- Holds the error number associated with SQL Statement
		v_err_msg	varchar2(100);  -- Holds the error message associated with SQL Statement

	Begin
		-- if country is USA, format the address according to US address style
		if upper(substr(ltrim(rtrim(p_country)),1,2)) = 'US'  then

			p_address_style := 'US_GLB';
       		p_region_1 := NULL;
			p_region_2 := ltrim(rtrim(p_state));
			p_region_3 := NULL;
			p_countryout  := 'US';
			p_zipcodeout  := substr(ltrim(rtrim(p_zipcode)),1,5);
			p_stateout  := NULL;

		-- if country is UK, format the address according to UK address style
		elsif upper(substr(ltrim(rtrim(p_country)),1,2)) = 'UK'
		    or upper(substr(ltrim(rtrim(p_country)),1,2)) = 'GB' then

			p_address_style := 'GB';
			p_region_1 := 'WTY';
			--p_region_1 := ltrim(rtrim(p_state));
			p_region_2 := NULL;
			p_region_3 := NULL;
			p_countryout  := 'GB';
			p_zipcodeout  := ltrim(rtrim(p_zipcode));
			p_stateout := NULL;

        -- for all other countries, assign the address style of <Country_Code>_GLB
        -- if the seeded format doesn't work with what we have - it will error
        -- as of 7/26/2016 -- the approach is to fix the address style, not rearrange how/what we're sending
        -- 6/15/2018 -- if not US or UK...put the WD region/state in region_1
        else
            p_address_style := ltrim(rtrim(p_country)) || '_GLB';
            p_region_1 := p_state;
            p_region_2 := NULL;
            p_region_3 := NULL;
            p_countryout := p_country;
            p_zipcodeout  := ltrim(rtrim(p_zipcode));
            p_stateout := NULL;


			-- Check whether county exists in fnd_common_lookups table. If county is not existing
			-- in fnd_common_lookups table set p_region_1 to NULL.
			Begin

				select distinct lookup_code
				into   p_region_1
				from   fnd_common_lookups
				where  upper(lookup_code) = upper(p_region_1)
				or     upper(meaning) 	= upper(p_region_1)
				and    lookup_type = 'GB_COUNTY';

			Exception
				when no_data_found then
					p_region_1 := NULL;
                when others then
                v_err_num := SQLCODE;
                v_err_msg := substr(SQLERRM,1,100);
                insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
                values (1, 'EMP_LOAD', 'Get Address',
                   100, v_err_num, v_err_msg, sysdate, -1, sysdate, -1, -1);
			End;

		end if;

	End get_address;   -- End of get_address procedure

---------------------------------------------------------------------------------------------------------
-- This process checks whether the employee is existing in Oracle or not

	Procedure check_ora_employee(p_emp_number varchar2, p_person_id out number,
					     p_bussiness_grp_id  out number) is

        v_err_num	number;         -- Holds the error number associated with SQL Statement
		v_err_msg	varchar2(100);  -- Holds the error message associated with SQL Statement

	Begin

		p_person_id := NULL;
		p_bussiness_grp_id := NULL;

		-- get the person_id and business_group_id related to the employee
		select distinct person_id , business_group_id
		into   p_person_id, p_bussiness_grp_id
		from   per_people_f
        where  employee_number = ltrim(rtrim(p_emp_number));
		--where  employee_number = substr(ltrim(rtrim(p_emp_number)),2);

		Exception
		     when no_data_found then
			p_person_id := NULL;
			p_bussiness_grp_id := NULL;
        when others then
                v_err_num := SQLCODE;
                v_err_msg := substr(SQLERRM,1,100);
                insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   attribute1,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
                values (1, 'EMP_LOAD', 'ORA Emp',
                   100, v_err_num, v_err_msg,
                   p_emp_number,
                   sysdate, -1, sysdate, -1, -1);

	End check_ora_employee; -- end of Check_ora_employee procedure

	-- This process checks whether the employee is active or not. If the employee is active
	-- function returns TRUE else FALSE
	function check_ora_emp_status(p_person_id number, p_bus_grp_id number) return boolean is

		v_person_id		per_people_f.person_id%type;
		v_active		boolean;
		v_assign_cnt		number;
		v_service_cnt		number;

        v_err_num	number;         -- Holds the error number associated with SQL Statement
		v_err_msg	varchar2(100);  -- Holds the error message associated with SQL Statement

	Begin

		v_person_id := NULL;

		-- Get the person_id with the passed person_id and business group id
		select person_id
		into   v_person_id
		from   per_people_f ppf,
		       per_person_types ppt
		where  ppf.person_id = p_person_id
		  and  ppf.business_group_id = p_bus_grp_id
		  and  ppt.person_type_id = ppf.person_type_id
		  and  ppf.business_group_id = ppt.business_group_id
		  and  ppt.system_person_type = 'EMP'
		  and  to_date(to_char(sysdate, 'DD-MON-YYYY'), 'DD-MON-YYYY') between
		       to_date(to_char(ppf.effective_start_date, 'DD-MON-YYYY'), 'DD-MON-YYYY')
		  and  to_date(to_char(ppf.effective_end_date, 'DD-MON-YYYY'), 'DD-MON-YYYY');


		-- if the person_id is not null then check whether the person is having active service
		-- records and active assignment records. If the person is having active service and assignment
		-- records then consider the person as active, otherwise consider the person as inactive
		if v_person_id is not null then

			-- Check whether the person is having active service records
			select count(*)
			into   v_service_cnt
			from   per_periods_of_service pps
			where  pps.person_id = p_person_id
			and    pps.business_group_id = p_bus_grp_id
			and    ( pps.actual_termination_date is null
				 or
				 to_date(to_char(pps.actual_termination_date, 'DD-MON-YYYY'), 'DD-MON-YYYY')
				 >= to_date(to_char(sysdate, 'DD-MON-YYYY'), 'DD-MON-YYYY')
			       )
			and    ( pps.final_process_date is null
				 or
				 to_date(to_char(pps.final_process_date, 'DD-MON-YYYY'), 'DD-MON-YYYY')
				 >= to_date(to_char(sysdate, 'DD-MON-YYYY'), 'DD-MON-YYYY')
			       );

			if v_service_cnt = 0 then
				v_active := FALSE;
			else
				v_active := TRUE;
			end if;


			if v_active  = TRUE then

				-- Check whether the person is having active assignment records
				select count(*)
				into   v_assign_cnt
				from   per_assignments_f paf,
				       per_assignment_status_types past
				where  paf.person_id = p_person_id
          			  and  paf.business_group_id = p_bus_grp_id
				  and  to_date(to_char(sysdate, 'DD-MON-YYYY'), 'DD-MON-YYYY') between
				       to_date(to_char(paf.effective_start_date, 'DD-MON-YYYY'), 'DD-MON-YYYY')
				       and to_date(to_char(paf.effective_end_date, 'DD-MON-YYYY'), 'DD-MON-YYYY')
				  and  paf.assignment_status_type_id = past.assignment_status_type_id
				  and  past.per_system_status = 'ACTIVE_ASSIGN';

				if v_assign_cnt >= 1 then
					v_active := TRUE;
				else
					v_active := FALSE;
				end if;

			end if;
		end if;

		return v_active;

	Exception

	   when no_data_found then
			-- Rehire situation
			v_active := false;
			return v_active;
        when others then
                v_err_num := SQLCODE;
                v_err_msg := substr(SQLERRM,1,100);
                insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   attribute2,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
                values (1, 'EMP_LOAD', 'ORA status',
                   100, v_err_num, v_err_msg,
                   to_char(p_person_id),
                   sysdate, -1, sysdate, -1, -1);

	End check_ora_emp_status;  -- End of check_ora_emp_status function

        -- This process checks to see if an FND_USER records associated with the specified employee exists
        -- Added 06/12/07
        Procedure check_fnd_user( p_employee_id  IN number
                                , p_user_id     OUT fnd_user.user_id%type
                                , p_user_name   OUT fnd_user.user_name%type) is
           v_err_num	number;         -- Holds the error number associated with SQL Statement
	   v_err_msg	varchar2(100);  -- Holds the error message associated with SQL Statement
       v_employee_number varchar2(25);

        begin
           select user_id, user_name
           into p_user_id, p_user_name
           from fnd_user
           where
            (end_date is null or end_date > sysdate)
            and employee_id = p_employee_id;

        Exception
           when no_data_found then
              p_user_id := NULL;
              p_user_name := NULL;
           when too_many_rows then

              select min(employee_number)
              into v_employee_number
              from per_people_f
              where person_id = p_employee_id;

              v_err_num := SQLCODE;
              v_err_msg := 'Employee is associated with more than one FND User';
              insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   attribute1,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
              values (1, 'EMP_LOAD', 'FND User',
                   100, v_err_num, v_err_msg,
                   v_employee_number,
                   sysdate, -1, sysdate, -1, -1);

           when others then
              v_err_num := SQLCODE;
              v_err_msg := substr(SQLERRM,1,100);
              insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   attribute1,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
              values (1, 'EMP_LOAD', 'FND User',
                   100, v_err_num, v_err_msg,
                   to_char(p_employee_id),
                   sysdate, -1, sysdate, -1, -1);
        End check_fnd_user; -- End of check_fnd_user procedure

	--
	--
	-- This process creates employees in HR Schema
	Procedure create_employee(p_job_id number,p_emp_number varchar2,p_start_date_active date, p_last_name varchar2,
				  p_first_name varchar2, p_mi varchar2, p_known_as varchar2, p_sex varchar2,
				  p_street1 varchar2, p_street2 varchar2, p_city varchar2,
				  p_state varchar2, p_zipcode varchar2, p_country varchar2, p_email varchar2,
				  p_locat_code varchar2, p_default_expense_acct varchar2,
				  p_set_of_books_name varchar2,
                  p_grade varchar2, p_job_code varchar2,
                  p_grade_non_job number,
                  p_grade_job number) is

		v_emp_number			per_people_f.employee_number%type;
		v_bus_grp_id			number;
		v_person_id			number;
		v_assignment_id			number;
		v_per_object_version_number	number;
		v_asg_object_version_number	number;
		v_per_effective_start_date	date;
		v_per_effective_end_date	date;
		v_full_name			per_people_f.full_name%type;
		v_per_comment_id		number;
		v_assignment_sequence		number;
		v_assignment_number		varchar2(45);
		v_name_combination_warning	boolean;
		v_assign_payroll_warning	boolean;
		v_address_id			number;
		v_add_object_version_number	number;
		v_address_style			per_addresses.style%type;
		v_region_1			per_addresses.region_1%type;
		v_region_2			per_addresses.region_2%type;
		v_region_3			per_addresses.region_3%type;
		v_orig_hire_warning		boolean;
		v_countryout    		per_addresses.country%type;
		v_stateout			per_addresses.region_2%type;
		v_zipcodeout			per_addresses.postal_code%type;
		v_flag				varchar2(2);
		v_set_of_books_id		gl_sets_of_books.set_of_books_id%type;
		v_location_id			hr_locations.location_id%type;
		v_job_id			per_jobs.job_id%type;
		v_default_expense_acct		number;
		v_organization_id		number;
        v_grade_id number;

        v_err_num	number;         -- Holds the error number associated with SQL Statement
		v_err_msg	varchar2(100);  -- Holds the error message associated with SQL Statement

	Begin

		v_job_id := p_job_id;
		v_location_id := NULL;
		v_set_of_books_id := NULL;
        v_default_expense_acct := NULL;
		v_organization_id := NULL;

      	v_emp_number := p_emp_number;
		v_bus_grp_id := 0;

			v_flag := 'JY';   -- This varibale is used for showing appropriate message
					  -- in exception handling. JY means job found

			-- get the set of books Id
			v_flag := 'SN';   -- This varibale is used for showing appropriate message
					  -- in exception handling. SN means set of books not found

               select ledger_id
               into   v_set_of_books_id
               from gl_ledgers
               where name = p_set_of_books_name;

			v_flag := 'SY';   -- This varibale is used for showing appropriate message
					  -- in exception handling. SY means set of books found


			v_flag := 'ON';   -- This variable is used for showing appropriate message
					  -- in exception handling. ON means Organization Id not found

            -- 09-Nov-2020 - Start TM Split Instance - After Split, only HK CORP
           -- Find Expenditure Org ID - new mapping for R12
           /*
           select o.organization_id   -- ,lv.lookup_code , lv.meaning
           into v_organization_id
           from
                hr_all_organization_units o,
                fnd_lookup_values lv
            where
                lv.meaning = o.name
                and lv.lookup_type = 'LE_EXPORG'
                and substr(p_default_expense_acct,1,3) = lv.lookup_code;
            */

            select organization_id
            into v_organization_id 
            from hr_all_organization_units 
            where name = 'CORP-HONG KONG';            
            -- 09-Nov-2020 - End TM Split Instance - After Split, only HK CORP

			v_flag := 'OY';   -- This variable is used for showing appropriate message
					  -- in exception handling. OY means Organization Id found.

			-- get the employee assignment location

			v_flag := 'LN';   -- This varibale is used for showing appropriate message
					  -- in exception handling. LN means location not found

			-- 4/2007 Lawson to Oracle location code mapping value stored in HR_LOCATIONS
			select min(location_id)
			into v_location_id
			from hr_locations hl
			where hl.attribute1 = ltrim(rtrim(p_locat_code))
                    and (inactive_date is null or inactive_date > sysdate);

			v_flag := 'LY';   -- This varibale is used for showing appropriate message
					  -- in exception handling. LY means location found

			-- get the default expense account
			v_flag := 'AN';

			select code_combination_id
			into   v_default_expense_acct
			from   xxhr_code_combinations_v
		        where  default_account = p_default_expense_acct;

			v_flag := 'AY';

            --------------------------------------------------------------------------------------
            -- Job is required -- if p_job_id is null, set to DEFAULT job and create error
             if v_job_id is null then
                    select job_id
                    into   v_job_id
                    from   per_jobs
                    where  upper(name) = 'DEFAULT';

                    update xxhr_employee_upload
                    set  message = 'Job does not exist in Oracle: ' || (select upper(job_description) from xxhr_employee_upload where emp_number = v_emp_number)
                    where  emp_number = v_emp_number;
                    commit;
             end if;

			-- Use hr_employee_api.create_employee API to insert employee data
			-- into per_people_f, per_addresses, per_assignments_f tables

		hr_employee_api.create_employee(p_hire_date => p_start_date_active,
  						p_business_group_id => v_bus_grp_id,
				        p_last_name => ltrim(rtrim(p_last_name)),
						p_first_name => ltrim(rtrim(p_first_name)),
  						p_middle_names => ltrim(rtrim(p_mi)),
                        p_known_as => ltrim(rtrim(p_known_as)),
				        p_sex => nvl(ltrim(rtrim(p_sex)), NULL),
					    p_email_address =>  p_email,
						p_employee_number => v_emp_number,
						p_person_id => v_person_id,
						p_expense_check_send_to_addres=> 'H',
						p_assignment_id => v_assignment_id,
						p_per_object_version_number => v_per_object_version_number,
						p_asg_object_version_number => v_asg_object_version_number,
						p_per_effective_start_date => v_per_effective_start_date,
						p_per_effective_end_date   => v_per_effective_end_date,
						p_full_name => v_full_name,
						p_per_comment_id => v_per_comment_id,
						p_assignment_sequence => v_assignment_sequence,
						p_assignment_number =>   v_assignment_number,
						p_name_combination_warning => v_name_combination_warning,
						p_assign_payroll_warning => v_assign_payroll_warning,
	 					p_orig_hire_warning => v_orig_hire_warning,
	 					p_attribute1 => to_char(p_grade_non_job)--,
                        --p_attribute2 => to_char(p_grade_job)
				               );


                -- get the id of the employee's grade
                begin
                    select max(grade_id) into v_grade_id
                    from per_grades where name = rtrim(p_grade);
                exception when others then null;
                end;

               -- Find the id associated with the DEFAULT grade (if emp doesn't have a grade)
               if v_grade_id is null then
                   begin
                        select grade_id
                        into   v_grade_id
                        from   per_grades
                        where  upper(name) = 'TBD';
                   exception when others then null;
                   end;
               end if;

		-- updating the assignment record with location_id, set_of_books_id, job_id for the employee
		update per_assignments_f
		set    location_id = v_location_id,
                       set_of_books_id = v_set_of_books_id,
                       job_id = nvl(job_id,v_job_id),
                       --grade_id = v_grade_id, -- TM Spite Instance
                       organization_id = v_organization_id,
                       default_code_comb_id = v_default_expense_acct --,
                       --ass_attribute1 = p_job_code  --> 7/5/17 don't overrirde attribute1 on assignment, they still use it
		where  assignment_id = v_assignment_id;
                COMMIT;

		-- get the address format for the employee
		get_address(p_country , p_state, p_zipcode, v_address_style,
			      v_region_1, v_region_2, v_region_3, v_countryout, v_stateout, v_zipcodeout);

		-- Creates address record for employee in HR
		hr_person_address_api.create_person_address(p_effective_date => p_start_date_active,
							    p_person_id => v_person_id,
							    p_primary_flag => 'Y',
							    p_style => v_address_style,
							    p_date_from	=> p_start_date_active,
							    --p_address_type => 'CUR',
							    p_address_line1 => p_street1,
							    p_address_line2 => p_street2,
							    p_town_or_city => p_city,
							    p_region_1 => v_region_1,
							    p_region_2 => v_region_2,
							    p_region_3 => v_region_3,
							    p_postal_code => v_zipcodeout,
							    p_country => v_countryout,
							    p_address_id => v_address_id,
							    p_object_version_number => v_add_object_version_number
							   );

		commit;

	Exception
		when no_data_found then

		      if v_flag = 'JN' then

			  -- dbms_output.put_line('Job Id was not existing for DEFAULT Job');
			   update xxhr_employee_upload
			   set    message = 'There is no JOB with the name DEFAULT'
			   where  emp_number = v_emp_number;

		      elsif v_flag = 'ON' then

			   update xxhr_employee_upload
			   set    message = 'There is no exp org set-up in LE_EXPORG for LE ' || substr(p_default_expense_acct,1,3)
			   where  emp_number = v_emp_number;

              elsif v_flag = 'LN' then

                update xxhr_employee_upload
                set  message = 'Location code ' || rtrim(p_locat_code) || ' does not exist in mapping table.'
                where  emp_number = v_emp_number;

  			   Begin

				-- get the default expense account
				v_flag := 'AN';
				select code_combination_id
				into   v_default_expense_acct
				from   xxhr_code_combinations_v
		        	where  default_account = p_default_expense_acct;
				v_flag := 'AY';

                --------------------------------------------------------------------------------------
                -- Job is required -- if p_job_id is null, set to DEFAULT job and create error
                 if v_job_id is null then
                        select job_id
                        into   v_job_id
                        from   per_jobs
                        where  upper(name) = 'DEFAULT';

                        update xxhr_employee_upload
                        set  message = 'Job does not exist in Oracle: ' || (select upper(job_description) from xxhr_employee_upload where emp_number = v_emp_number)
                        where  emp_number = v_emp_number;
                        commit;
                 end if;

				-- Use hr_employee_api.create_employee API to insert employee data
				-- into per_people_f, per_addresses, per_assignments_f tables
				hr_employee_api.create_employee(p_hire_date => p_start_date_active,
  							        p_business_group_id => v_bus_grp_id,
				        			p_last_name => ltrim(rtrim(p_last_name)),
								p_first_name => ltrim(rtrim(p_first_name)),
                                p_known_as => ltrim(rtrim(p_known_as)),
  								p_middle_names => ltrim(rtrim(p_mi)),
				        			p_sex => nvl(ltrim(rtrim(p_sex)), NULL),
					        	p_email_address =>  p_email,
								p_employee_number => v_emp_number,
								p_person_id => v_person_id,
								p_expense_check_send_to_addres => 'H',
								p_assignment_id => v_assignment_id,
								p_per_object_version_number => v_per_object_version_number,
								p_asg_object_version_number => v_asg_object_version_number,
								p_per_effective_start_date => v_per_effective_start_date,
								p_per_effective_end_date   => v_per_effective_end_date,
								p_full_name => v_full_name,
								p_per_comment_id => v_per_comment_id,
								p_assignment_sequence => v_assignment_sequence,
								p_assignment_number =>   v_assignment_number,
								p_name_combination_warning => v_name_combination_warning,
								p_assign_payroll_warning => v_assign_payroll_warning,
	 							p_orig_hire_warning => v_orig_hire_warning,
	 							p_attribute1 => to_char(p_grade_non_job)--,
                                --p_attribute2 => to_char(p_grade_job)
				               		       );


				-- updating the assignment record with location_id, set_of_books_id, job_id for the employee
				update per_assignments_f
				set    location_id = null,
                       		       set_of_books_id = v_set_of_books_id,
                       		       job_id = nvl(job_id,v_job_id),
                                   --ass_attribute1 = p_job_code,  --> 7/5/17 don't overrirde attribute1 on assignment, they still use it
				                   organization_id = v_organization_id,
                                   default_code_comb_id = v_default_expense_acct
				where  assignment_id = v_assignment_id;

				-- get the address format for the employee
				get_address(p_country , p_state, p_zipcode, v_address_style,
			      		    v_region_1, v_region_2, v_region_3, v_countryout, v_stateout, v_zipcodeout);

				-- Creates address record for employee in HR
				hr_person_address_api.create_person_address(p_effective_date => p_start_date_active,
							    p_person_id => v_person_id,
							    p_primary_flag => 'Y',
							    p_style => v_address_style,
							    p_date_from	=> p_start_date_active,
							    --p_address_type => 'CUR',
							    p_address_line1 => p_street1,
							    p_address_line2 => p_street2,
							    p_town_or_city => p_city,
							    p_region_1 => v_region_1,
							    p_region_2 => v_region_2,
							    p_region_3 => v_region_3,
							    p_postal_code => v_zipcodeout,
							    p_country => v_countryout,
							    p_address_id => v_address_id,
							    p_object_version_number => v_add_object_version_number
							   );

			     Exception

				 when no_data_found then

				     if v_flag = 'AN' then

                             --------------------------------------------------------------------------------------
                            -- Job is required -- if p_job_id is null, set to DEFAULT job and create error
                             if v_job_id is null then
                                    select job_id
                                    into   v_job_id
                                    from   per_jobs
                                    where  upper(name) = 'DEFAULT';

                                    update xxhr_employee_upload
                                    set  message = 'Job does not exist in Oracle: ' || (select upper(job_description) from xxhr_employee_upload where emp_number = v_emp_number)
                                    where  emp_number = v_emp_number;
                                    commit;
                             end if;

					-- Use hr_employee_api.create_employee API to insert employee data
					-- into per_people_f, per_addresses, per_assignments_f tables
					hr_employee_api.create_employee(p_hire_date => p_start_date_active,
  							        p_business_group_id => v_bus_grp_id,
				        			p_last_name => ltrim(rtrim(p_last_name)),
								p_first_name => ltrim(rtrim(p_first_name)),
  								p_middle_names => ltrim(rtrim(p_mi)),
                                p_known_as => ltrim(rtrim(p_known_as)),
				        			p_sex => nvl(ltrim(rtrim(p_sex)), NULL),
					        		p_email_address =>  p_email,
								p_employee_number => v_emp_number,
								p_person_id => v_person_id,
								p_expense_check_send_to_addres => 'H',
								p_assignment_id => v_assignment_id,
								p_per_object_version_number => v_per_object_version_number,
								p_asg_object_version_number => v_asg_object_version_number,
								p_per_effective_start_date => v_per_effective_start_date,
								p_per_effective_end_date   => v_per_effective_end_date,
								p_full_name => v_full_name,
								p_per_comment_id => v_per_comment_id,
								p_assignment_sequence => v_assignment_sequence,
								p_assignment_number =>   v_assignment_number,
								p_name_combination_warning => v_name_combination_warning,
								p_assign_payroll_warning => v_assign_payroll_warning,
	 							p_orig_hire_warning => v_orig_hire_warning,
	 							p_attribute1 => to_char(p_grade_non_job)--,
                                --p_attribute2 => to_char(p_grade_job)
				               		       );

					-- updating the assignment record with location_id, set_of_books_id,
					-- job_id for the employee
					update per_assignments_f
					set    location_id = null,
                       		       	       set_of_books_id = v_set_of_books_id,
                       		       	       job_id = nvl(job_id,v_job_id),
                                           --ass_attribute1 = p_job_code, --> 7/5/17 don't overrirde attribute1 on assignment, they still use it
                                               organization_id = v_organization_id,
                                               default_code_comb_id = null
				        where  assignment_id = v_assignment_id;

				        -- get the address format for the employee

				         get_address(p_country , p_state, p_zipcode, v_address_style,
			      		        v_region_1, v_region_2, v_region_3, v_countryout, v_stateout, v_zipcodeout);

					-- Creates address record for employee in HR
					hr_person_address_api.create_person_address(p_effective_date => p_start_date_active,
							    p_person_id => v_person_id,
							    p_primary_flag => 'Y',
							    p_style => v_address_style,
							    p_date_from	=> p_start_date_active,
							    --p_address_type => 'CUR',
							    p_address_line1 => p_street1,
							    p_address_line2 => p_street2,
							    p_town_or_city => p_city,
							    p_region_1 => v_region_1,
							    p_region_2 => v_region_2,
							    p_region_3 => v_region_3,
							    p_postal_code => v_zipcodeout,
							    p_country => v_countryout,
							    p_address_id => v_address_id,
							    p_object_version_number => v_add_object_version_number
							   );

                    update xxhr_employee_upload u
                    set    message = 'Account combination ' || u.default_expense_acct|| ' does not exist'
                    where  emp_number = v_emp_number;

				end if;
			 End;

            elsif v_flag = 'SN' then

			  update xxhr_employee_upload
			  set    message = 'There is no SET OF BOOKS associated with MERRILL CORPORATION.'
			  where  emp_number = v_emp_number;

		      elsif v_flag = 'AN' then


			  	-- Use hr_employee_api.create_employee API to insert employee data
				-- into per_people_f, per_addresses, per_assignments_f tables
				hr_employee_api.create_employee(p_hire_date => p_start_date_active,
  							        p_business_group_id => v_bus_grp_id,
				        			p_last_name => ltrim(rtrim(p_last_name)),
								p_first_name => ltrim(rtrim(p_first_name)),
  								p_middle_names => ltrim(rtrim(p_mi)),
                                p_known_as => ltrim(rtrim(p_known_as)),
				        			p_sex => nvl(ltrim(rtrim(p_sex)), NULL),
					        		p_email_address =>  p_email,
								p_employee_number => v_emp_number,
								p_person_id => v_person_id,
								p_expense_check_send_to_addres => 'H',
								p_assignment_id => v_assignment_id,
								p_per_object_version_number => v_per_object_version_number,
								p_asg_object_version_number => v_asg_object_version_number,
								p_per_effective_start_date => v_per_effective_start_date,
								p_per_effective_end_date   => v_per_effective_end_date,
								p_full_name => v_full_name,
								p_per_comment_id => v_per_comment_id,
								p_assignment_sequence => v_assignment_sequence,
								p_assignment_number =>   v_assignment_number,
								p_name_combination_warning => v_name_combination_warning,
								p_assign_payroll_warning => v_assign_payroll_warning,
	 							p_orig_hire_warning => v_orig_hire_warning,
	 							p_attribute1 => to_char(p_grade_non_job)--,
                                --p_attribute2 => to_char(p_grade_job)
				               		       );

				-- updating the assignment record with location_id, set_of_books_id,
                                -- job_id for the employee

				update per_assignments_f
				set    location_id = v_location_id,
                       		       set_of_books_id = v_set_of_books_id,
                       		       job_id = nvl(job_id,v_job_id),
                                   --ass_attribute1 = p_job_code,  --> 7/5/17 don't overrirde attribute1 on assignment, they still use it
				       organization_id = v_organization_id,
                                       default_code_comb_id = null
				where  assignment_id = v_assignment_id;
              COMMIT;

				-- get the address format for the employee

				get_address(p_country , p_state, p_zipcode, v_address_style,
			      		    v_region_1, v_region_2, v_region_3, v_countryout, v_stateout, v_zipcodeout);

				-- Creates address record for employee in HR
				hr_person_address_api.create_person_address(p_effective_date => p_start_date_active,
							    p_person_id => v_person_id,
							    p_primary_flag => 'Y',
							    p_style => v_address_style,
							    p_date_from	=> p_start_date_active,
							    --p_address_type => 'CUR',
							    p_address_line1 => p_street1,
							    p_address_line2 => p_street2,
							    p_town_or_city => p_city,
							    p_region_1 => v_region_1,
							    p_region_2 => v_region_2,
							    p_region_3 => v_region_3,
							    p_postal_code => v_zipcodeout,
							    p_country => v_countryout,
							    p_address_id => v_address_id,
							    p_object_version_number => v_add_object_version_number
							   );

                    update xxhr_employee_upload u
                    set    message = 'Account combination ' || u.default_expense_acct|| ' does not exist'
                    where  emp_number = v_emp_number;

              end if;

		      commit;

	  when others then
                v_err_num := SQLCODE;
                v_err_msg := substr(SQLERRM,1,100);
                insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   attribute1,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
                values (1, 'EMP_LOAD', 'Create Emp',
                   100, v_err_num, v_err_msg,
                   p_emp_number,
                   sysdate, -1, sysdate, -1, -1);

	End create_employee;


	--
	-- This process updates the employee information and employee address information with new info
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
                  p_grade_job number) is

        v_term_date                     date;
	v_emp_number		    	per_people_f.employee_number%type;
	v_per_object_version_number 	per_people_f.object_version_number%type;
	v_effective_start_date	    	date;
	v_effective_end_date	    	date;
	v_full_name		    	per_people_f.full_name%type;
	v_first_name		    	per_people_f.first_name%type;
	v_comment_id		    	number;
	v_name_combination_warning  	boolean;
	v_assign_payroll_warning    	boolean;
	v_addr_object_version_number	per_addresses.object_version_number%type;
        v_address_style			per_addresses.style%type;
	v_region_1			per_addresses.region_1%type;
	v_region_2			per_addresses.region_2%type;
	v_region_3			per_addresses.region_3%type;
	v_orig_hire_warning		boolean;
	v_countryout    		per_addresses.country%type;
	v_stateout			per_addresses.region_2%type;
	v_zipcodeout			per_addresses.postal_code%type;
	v_address_id			number;
    v_job_id                        number;
	v_flag				char(2);
    v_default_expense_acct		number;
    v_organization_id number;
    v_cur_last_name   per_people_f.last_name%type;
    v_cur_first_name   per_people_f.first_name%type;
    v_cur_middle_names   per_people_f.middle_names%type;
    v_cur_email_address   per_people_f.email_address%type;
    v_cur_known_as per_people_f.known_as%type;
    v_cur_sex   per_people_f.sex%type;
     v_set_of_books_id number;
     v_default_job_id   per_assignments_f.job_id%type;
     v_grade_id     per_assignments_f.grade_id%type;
     v_cur_job_id   per_assignments_f.job_id%type;
     v_cur_grade_id     per_assignments_f.grade_id%type;
     v_cur_organization_id  per_assignments_f.organization_id%type;
     v_cur_set_of_books_id      per_assignments_f.set_of_books_id%type;
     v_cur_default_code_comb_id     per_assignments_f.default_code_comb_id%type;
     v_cur_grade_non_job number;
     v_cur_grade_job number;

    v_err_num	number;         -- Holds the error number associated with SQL Statement
	v_err_msg	varchar2(100);  -- Holds the error message associated with SQL Statement
    v_location_id			hr_locations.location_id%type;
    v_error_marker varchar2(10);

    v_start_date_active date;


	Begin
                v_job_id := p_job_id;
                v_term_date := p_term_date;
                v_per_object_version_number := p_per_object_version_number;
                v_emp_number := p_emp_number;
                v_default_expense_acct := p_code_combination_id;
                v_address_id := p_address_id;
                v_addr_object_version_number := p_addr_object_version_number;
                v_location_id := null;

        v_error_marker := 'A';

           -- Find Expenditure Org ID - new mapping for R12
           -- in the "create_employee" procedure, there is a nice (but odd) chain for setting messages/errors...not in update, not sure why...
           begin
                -- 09-Nov-2020 - Start TM Split Instance - After Split, only HK CORP
                /*
               select o.organization_id   -- ,lv.lookup_code , lv.meaning
               into v_organization_id
               from
                    hr_all_organization_units o,
                    fnd_lookup_values lv
                where
                    lv.meaning = o.name
                    and lv.lookup_type = 'LE_EXPORG'
                    and substr(p_default_expense_acct,1,3) = lv.lookup_code;

                */
                select organization_id
                into v_organization_id 
                from hr_all_organization_units 
                where name = 'CORP-HONG KONG';            
                -- 09-Nov-2020 - End TM Split Instance - After Split, only HK CORP                
            exception when others then
                 update xxhr_employee_upload
                 set    message = 'Unable to set exp org for ' ||  substr(p_default_expense_acct,1,3) || '. Check set-up in LE_EXPORG'
                 where  emp_number = p_emp_number;
             end;

        v_error_marker := 'B';

        -- Get the current values from PER_PEOPLE_F
        select --person_id, business_group_id,
                  p.object_version_number, p.employee_number,
                  p.last_name, p.first_name, p.middle_names, p.known_as, p.email_address, p.sex,
                  p.attribute1, p.attribute2, start_date
        into   v_per_object_version_number , v_emp_number,
                v_cur_last_name, v_cur_first_name, v_cur_middle_names, v_cur_known_as, v_cur_email_address, v_cur_sex,
                v_cur_grade_non_job, v_cur_grade_job , v_start_date_active
        from   per_people_f p
        where  p.person_id = p_person_id
            and    p.business_group_id =  p_business_group_id
            and    trunc(sysdate) between trunc(p.effective_start_date) and trunc(p.effective_end_date);

        v_error_marker := 'C1';

        ----- Employee Update ----

        if p_start_date_active <> v_start_date_active then
            declare
                v_warn_ee   VARCHAR2 (32767);
            begin
                HR_CHANGE_START_DATE_API.UPDATE_START_DATE (
                    P_PERSON_ID        => p_person_id,
                    P_OLD_START_DATE   => v_start_date_active,
                    P_NEW_START_DATE   => p_start_date_active,
                    P_UPDATE_TYPE      => 'E', -- E for Employee Record
                    P_WARN_EE          => v_warn_ee
                    );

                commit;
            end;

            -- Get the current values from PER_PEOPLE_F
            select --person_id, business_group_id,
                      p.object_version_number, p.employee_number,
                      p.last_name, p.first_name, p.middle_names, p.known_as, p.email_address, p.sex,
                      p.attribute1, p.attribute2, start_date
            into   v_per_object_version_number , v_emp_number,
                    v_cur_last_name, v_cur_first_name, v_cur_middle_names, v_cur_known_as, v_cur_email_address, v_cur_sex,
                    v_cur_grade_non_job, v_cur_grade_job , v_start_date_active
            from   per_people_f p
            where  p.person_id = p_person_id
                and    p.business_group_id =  p_business_group_id
                and    trunc(sysdate) between trunc(p.effective_start_date) and trunc(p.effective_end_date);                            
        end if;

        v_error_marker := 'C2';
        -- Only call update_person api if we need to ....it is slow
        if nvl(v_cur_last_name,'x') <> ltrim(rtrim(p_lastname))
           OR nvl(v_cur_first_name,'x') <> ltrim(rtrim(p_firstname))
           OR nvl(v_cur_middle_names,'x') <> ltrim(rtrim(p_mi))
           OR nvl(v_cur_known_as,'x') <> nvl(ltrim(rtrim(p_known_as)),'x')
           OR nvl(v_cur_email_address,'x') <> ltrim(rtrim(p_email))
           OR nvl(v_cur_grade_non_job,0) <> ltrim(rtrim(p_grade_non_job))
           OR nvl(v_cur_grade_job,0) <> ltrim(rtrim(p_grade_job))
           --OR nvl(v_emp_number,'x') <> ltrim(rtrim(p_emp_number))
        then

        --v_emp_number := p_emp_number;

		hr_person_api.update_person(p_effective_date => sysdate,
					    p_datetrack_update_mode => 'CORRECTION',
					    p_person_id => p_person_id,
					    p_object_version_number => v_per_object_version_number,
					    p_last_name => ltrim(rtrim(p_lastname)),
					    p_email_address => p_email,
					    p_employee_number => v_emp_number,
					    p_first_name => ltrim(rtrim(p_firstname)),
					    p_middle_names => ltrim(rtrim(p_mi)),
                        p_known_as => ltrim(rtrim(p_known_as)),
					    p_sex => ltrim(rtrim(p_sex)),
					    p_effective_start_date => v_effective_start_date,
					    p_effective_end_date => v_effective_end_date,
					    p_full_name => v_full_name,
					    p_comment_id => v_comment_id,
					    p_name_combination_warning => v_name_combination_warning,
					    p_assign_payroll_warning => v_assign_payroll_warning,
					    p_orig_hire_warning => v_orig_hire_warning,
					    p_attribute1 => to_char(p_grade_non_job)--,
                        --p_attribute2 => to_char(p_grade_job)
					   );

        end if;  --no differences, don't call update_employee api


        v_error_marker := 'D';
        --------------------------------------------------------------------------------------------------------
        ---- Update or create address ----
		get_address(p_country, p_state, p_zipcode, v_address_style, v_region_1, v_region_2,
			    v_region_3, v_countryout, v_stateout, v_zipcodeout);

        if v_address_id <> 0 then

                -- different updates for employees changing their country codes --
                -- api doesn't allow us to change their address style
                -- but the "region" fields store state, county, provinces -- but are validated per country code
                -- if changing address styles, update region and address styles separately
                if p_current_ora_country <> p_country then

		                    hr_person_address_api.update_person_address(p_effective_date => p_start_date_active,
							    p_address_id => v_address_id,
							    p_object_version_number => v_addr_object_version_number,
							    p_date_from => p_start_date_active,
							    p_address_line1 => p_street1,
							    p_address_line2 => p_street2,
							    p_town_or_city => p_city,
							--    p_region_1 => v_region_1,
							--    p_region_2 => v_region_2,
						    --    p_region_3 => v_region_3,
							--    p_postal_code => v_zipcodeout,
							    p_country => v_countryout);

                            update per_addresses
                            set    style = v_address_style,
                                    region_1 = v_region_1,
                                    region_2 = v_region_2,
                                    region_3 = v_region_3,
                                    postal_code = v_zipcodeout
                            where  address_id = v_address_id
                            and    object_version_number = v_addr_object_version_number;

                else

                            hr_person_address_api.update_person_address(p_effective_date => p_start_date_active,
                                p_address_id => v_address_id,
                                p_object_version_number => v_addr_object_version_number,
                                p_date_from => p_start_date_active,
                                --p_address_type => 'CUR',
                                p_address_line1 => p_street1,
                                p_address_line2 => p_street2,
                                p_town_or_city => p_city,
                                p_region_1 => v_region_1,
                                p_region_2 => v_region_2,
                                p_region_3 => v_region_3,
                                p_postal_code => v_zipcodeout,
                                p_country => v_countryout);
                end if;

        else -- if emp doesn't have an address -- we'll create it here
                hr_person_address_api.create_person_address(p_effective_date => p_start_date_active,
                                p_person_id => p_person_id,
                                p_primary_flag => 'Y',
                                p_style => v_address_style,
                                p_date_from    => p_start_date_active,
                                --p_address_type => 'CUR',
                                p_address_line1 => p_street1,
                                p_address_line2 => p_street2,
                                p_town_or_city => p_city,
                                p_region_1 => v_region_1,
                                p_region_2 => v_region_2,
                                p_region_3 => v_region_3,
                                p_postal_code => v_zipcodeout,
                                p_country => v_countryout,
                                p_address_id => v_address_id,
                                p_object_version_number => v_addr_object_version_number
                               );

        end if;

		commit;

        v_error_marker := 'E';
               -- Set of books (never changes -- but we might need to override if they manually set them up incorrectly
               select ledger_id --set_of_books_id
               into   v_set_of_books_id
               from   gl_ledgers
               where  name = p_set_of_books_name;

        v_error_marker := 'G';
                -- get the id of the employee's grade
                begin
                    select max(grade_id) into v_grade_id
                    from per_grades where name = rtrim(p_grade);
                exception when others then null;
                end;

        v_error_marker := 'H';
               -- Find the id associated with the DEFAULT grade (if emp doesn't have a grade)
               if v_grade_id is null then
                   begin
                        select grade_id
                        into   v_grade_id
                        from   per_grades
                        where  upper(name) = 'TBD';
                   exception when others then null;
                   end;
               end if;

                -- Update job_id (not part of API)
                -- if p_job_id is null it means that Workday job doesn't exist in Oracle.
                -- for update, leave the employee at their old, valid job
                if p_job_id is not null then
                        update per_assignments_f
                        set job_id = p_job_id
                        where person_id = p_person_id and trunc(sysdate) between trunc(effective_start_date) and trunc(effective_end_date)
                              and v_term_date is NULL;
                else
                        update xxhr_employee_upload
                        set  message = 'Job does not exist in Oracle: ' || (select upper(job_description) from xxhr_employee_upload where emp_number = v_emp_number)
                        where  emp_number = v_emp_number;
                end if;

                -- Update fields that aren't included in API
                -- employees could have muptile assignment records -- we want to keep them all in synch
                update per_assignments_f
                set  --grade_id = v_grade_id, -- TM Split Instance 
                      organization_id = nvl(v_organization_id, organization_id)
                      , set_of_books_id = v_set_of_books_id
                      ,last_update_date = sysdate
                      ,last_updated_by = -1
                where person_id = p_person_id and trunc(sysdate) between trunc(effective_start_date) and trunc(effective_end_date)
                      and v_term_date is NULL ;

        v_error_marker := 'J';
                if v_default_expense_acct is not null then
                    update per_assignments_f
                    set    default_code_comb_id = v_default_expense_acct
                             ,last_update_date = sysdate
                             ,last_updated_by = -1
                    where  person_id = p_person_id;
                else
                    update xxhr_employee_upload u
                    set    message = 'Account combination ' || u.default_expense_acct|| ' does not exist'
                    where  emp_number = v_emp_number;
                end if;

        v_error_marker := 'K';
            ---- Location ----
            select min(location_id)
            into v_location_id
            from hr_locations hl
            where hl.attribute1 = ltrim(rtrim(p_locat_code))
                    and (inactive_date is null or inactive_date > sysdate);

		    if v_location_id is not null then
                --- updates ALL emp's assignment records
		        update per_assignments_f
			    set location_id = v_location_id
	            where person_id = p_person_id;
            else
                update xxhr_employee_upload
                set  message = 'Location code ' || rtrim(p_locat_code) || ' does not exist in mapping table.'
                where  emp_number = v_emp_number;
            end if;

    commit;

    -----------------------------------------------------------------------------------------
    exception when others then
                v_err_num := SQLCODE;
                v_err_msg := substr(SQLERRM,1,100);
                insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   attribute1,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
                values (1, 'EMP_LOAD', v_error_marker,
                   100, v_err_num, v_err_msg,
                   to_char(p_person_id),
                   sysdate, -1, sysdate, -1, -1);

	End update_employee;

	-- This process updates the FND_USER record associated with an employee to assure they have the same email address
        Procedure update_fnd_user ( p_user_name      IN fnd_user.user_name%type
                                  , p_employee_id    IN number
                                  , p_email_address  IN varchar2) is
           v_err_num	number;         -- Holds the error number associated with SQL Statement
	   v_err_msg	varchar2(100);  -- Holds the error message associated with SQL Statement
        Begin
           -- Update the FND_USER email address to match the employee email address
           fnd_user_pkg.updateuser( x_user_name => p_user_name
                                  , x_owner     => NULL
                                  , x_email_address => p_email_address);
        Exception
           when others then
                v_err_num := SQLCODE;
                v_err_msg := substr(SQLERRM,1,100);
                insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   attribute2,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
                values (1, 'EMP_LOAD', 'Upd FndUsr',
                   100, v_err_num, v_err_msg,
                   p_employee_id,
                   sysdate, -1, sysdate, -1, -1);
        End update_fnd_user;

	--
	-- This process terminates the employee identified by person_id effective
        -- from p_effective_date

	Procedure terminate_employee(p_effective_date date, p_person_id number) is
	v_period_of_service_id 		number;
	v_object_version_number		number;
	v_last_standard_process_date 	date;
	v_supervisor_warning		boolean;
	v_event_warning			boolean;
	v_interview_warning		boolean;
	v_review_warning		boolean;
	v_recruiter_warning		boolean;
	v_asg_future_changes_warning	boolean;
	v_entries_changed_warning	varchar2(50);
	v_pay_proposal_warning		boolean;
	v_leaving_reason		varchar2(20);
	v_assignment_id			number;
	v_org_now_no_manager_warning	boolean;
	v_final_process_date		date;
	v_object_version_number1	number;
	v_dod_warning			boolean;
    v_max_effective_start  date;
    v_term_date date;

    v_err_num	number;         -- Holds the error number associated with SQL Statement
	v_err_msg	varchar2(100);  -- Holds the error message associated with SQL Statement

	Begin

		v_last_standard_process_date := NULL;

		-- get the period_of_service_id and object_version_number
                -- associated with the person

		select period_of_service_id, max(object_version_number)
		into   v_period_of_service_id, v_object_version_number
		from   per_periods_of_service
		where  person_id = p_person_id
		and    actual_termination_date is null
		and    last_standard_process_date is null
		group by period_of_service_id;


       -- most of the time, setting Oracle term date = Lawson term date
       -- but - if they had to manaully re-hire in Oracle, we need to reset the
       -- term date to be the next day.  Oracle doesn't allow overlap
       select max(effective_start_date)
       into v_max_effective_start
       from per_people_f
       where person_id = p_person_id;

       if p_effective_date <= v_max_effective_start then
          v_term_date := v_max_effective_start + 1;
       else
         v_term_date := p_effective_date;
       end if;


		-- terminate the employee using hr_ex_employee_api

		hr_ex_employee_api.actual_termination_emp
		(p_effective_date => p_effective_date,
		 p_period_of_service_id => v_period_of_service_id,
		 p_object_version_number => v_object_version_number,
		 p_actual_termination_date => v_term_date,
		 p_last_standard_process_date => v_last_standard_process_date,
		 p_supervisor_warning => v_supervisor_warning,
		 p_event_warning => v_event_warning,
		 p_interview_warning => v_interview_warning,
		 p_review_warning => v_review_warning,
		 p_recruiter_warning => v_recruiter_warning,
		 p_asg_future_changes_warning => v_asg_future_changes_warning,
		 p_entries_changed_warning => v_entries_changed_warning,
		 p_pay_proposal_warning => v_pay_proposal_warning,
		 p_dod_warning => v_dod_warning
		);

		--v_final_process_date := p_effective_date + 90;
        v_final_process_date := v_term_date + 90;

		hr_ex_employee_api.final_process_emp(p_period_of_service_id => v_period_of_service_id,
						     p_object_version_number => v_object_version_number,
						     p_final_process_date => v_final_process_date,
						     p_org_now_no_manager_warning => v_org_now_no_manager_warning,
						     p_asg_future_changes_warning => v_asg_future_changes_warning,
						     p_entries_changed_warning => v_entries_changed_warning
						    );

		hr_ex_employee_api.update_term_details_emp(
                               p_effective_date => v_term_date,   ----p_effective_date,
							   p_period_of_service_id => v_period_of_service_id,
							   p_object_version_number => v_object_version_number
							  );

	Exception
		when no_data_found then
			NULL;
        when others then
                v_err_num := SQLCODE;
                v_err_msg := substr(SQLERRM,1,100);
                insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   attribute2,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
                values (1, 'EMP_LOAD', 'Term Emp',
                   100, v_err_num, v_err_msg,
                   to_char(p_person_id),
                   sysdate, -1, sysdate, -1, -1);


	End terminate_employee;

	--
	--
	-- This process will set the fnd_user record to 'INACTIVE' when the associated employee terminates


	procedure terminate_emp_fnd_user(p_person_id number, p_effective_date date) is

	v_user_id 	fnd_user.user_id%type;

    v_err_num	number;         -- Holds the error number associated with SQL Statement
	v_err_msg	varchar2(100);  -- Holds the error message associated with SQL Statement

	Begin

		-- get the Oracle user_id and email_address related to the employee

		select user_id
		into   v_user_id
            	from   fnd_user
		where  employee_id = p_person_id
		and    nvl(end_date , to_date('31-DEC-4712', 'DD-MON-YYYY'))
		       > to_date(to_char(sysdate, 'DD-MON-YYYY'), 'DD-MON-YYYY');


		if v_user_id is not null then

			--  Inactivate the fnd_user record associated with employee by setting the
			--  end date to terminate date of the employee

			update fnd_user
			set    end_date = p_effective_date
			where  user_id  = v_user_id;
		end if;

		-- save the transaction
		commit;

	Exception

		when no_data_found then

			--dbms_output.put_line(' No Fnd_user associated with this employee.'||to_char(p_person_id));
		----	fnd_file.put_line(fnd_file.LOG,' No Fnd_user associated with this employee.'||to_char(p_person_id));
            -- that's ok -- most employees don't have FND_USER accounts.  we don't have to log it
            null;

        when others then
                v_err_num := SQLCODE;
                v_err_msg := substr(SQLERRM,1,100);
                insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   attribute1,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
                values (1, 'EMP_LOAD', 'Term FND',
                   100, v_err_num, v_err_msg,
                   to_char(p_person_id),
                   sysdate, -1, sysdate, -1, -1);

	End terminate_emp_fnd_user;

    -----------------------------------------------------------------------------
	-- Procedure to rehire an employee
	-- added 3/2004
	procedure rehire_emp(p_emp_number varchar2,p_job_id number,p_person_id number, p_business_group_id number, p_hire_date date,
			  			 p_set_of_books_name varchar2, p_country varchar2) is

	  v_emp_number		    	per_people_f.employee_number%type;
	  v_per_object_version_number 	per_people_f.object_version_number%type;
      v_err_num	number;
	  v_err_msg	varchar2(100);

	  v_assignment_id number;
      v_asg_object_version_number number;
      v_per_effective_date_date date;
      v_per_effective_end_date date;
      v_assignment_sequence number;
      v_assignment_number varchar2(100);
      v_assign_payroll_warning boolean;

      v_term_date date;
      v_period_of_service_id  number;
      v_pos_object_version_number number;
      v_final_process_date        date;
      v_org_now_no_manager_warning    boolean;
      v_asg_future_changes_warning    boolean;
      v_entries_changed_warning    varchar2(50);
      v_max_effective_start date;
      v_hire_date date;

      v_job_id number := NULL;
      v_set_of_books_id number := NULL;
	  v_organization_id number := NULL;

	begin

		select p.object_version_number, p.employee_number, p.effective_start_date-1
            , s.period_of_service_id, s.object_version_number,  s.final_process_date
		into   v_per_object_version_number , v_emp_number,  v_term_date,
            v_period_of_service_id,  v_pos_object_version_number, v_final_process_date
		from   per_people_f p,
                  per_periods_of_service s
        where  p.person_id = p_person_id
		and    p.business_group_id = p_business_group_id
        and p.person_id = s.person_id
        and p.effective_start_date = s.actual_termination_date +1  --find the most recent service record
        and to_date(to_char(sysdate, 'DD-MON-YYYY'), 'DD-MON-YYYY')
		        between to_date(to_char(p.effective_start_date, 'DD-MON-YYYY'),'DD-MON-YYYY')
		        and   to_date(to_char(p.effective_end_date, 'DD-MON-YYYY'), 'DD-MON-YYYY');

        -- when an employee is termed, we set their final_process_date = term_date +90
        -- rehire api fails if we try to rehire them before final_process_date
        -- update final_process_date if within 90 days -- it happens a lot...
        if v_term_date <= v_final_process_date then
          v_final_process_date := v_term_date + 1;

            hr_ex_employee_api.final_process_emp(p_period_of_service_id => v_period_of_service_id,
                             p_object_version_number => v_pos_object_version_number,
                             p_final_process_date => v_final_process_date,
                             p_org_now_no_manager_warning => v_org_now_no_manager_warning,
                             p_asg_future_changes_warning => v_asg_future_changes_warning,
                             p_entries_changed_warning => v_entries_changed_warning
                            );
       end if;

       -- in most rehire cases, the date_hired in Lawson is the most recent hire date
       -- however, in rare cases of term reversal situations -- the hire date is not updated
       -- Oracle needs a new hire date.  We'll update what was passed from Lawson
       -- if we need to...override hire date...
       select max(effective_start_date)
       into v_max_effective_start
       from per_people_f
       where person_id = p_person_id;

       if p_hire_date <= v_max_effective_start then
          v_hire_date := v_max_effective_start + 1;
       else
         v_hire_date := p_hire_date;
       end if;

        -------------------------------------------------------------------------------------------
	    -- for some reason, section won't compile unless all the values are included
	    hr_employee_api.re_hire_ex_employee(
						  p_validate => FALSE,
						  p_hire_date => v_hire_date,
					      p_person_id => p_person_id,
					      p_per_object_version_number => v_per_object_version_number,
						  p_person_type_id => 6,
						  p_rehire_reason => null,
                          p_assignment_id => v_assignment_id,
                          p_asg_object_version_number => v_asg_object_version_number,
                          p_per_effective_start_date => v_per_effective_date_date,
                          p_per_effective_end_date => v_per_effective_end_date,
                          p_assignment_sequence => v_assignment_sequence,
                          p_assignment_number  => v_assignment_number,
                          p_assign_payroll_warning => v_assign_payroll_warning
						  );

                        v_job_id := p_job_id;

                        commit;

			select set_of_books_id
			into   v_set_of_books_id
			from   gl_sets_of_books
			where  name = p_set_of_books_name;

           begin
                -- 09-Nov-2020 - Start TM Split Instance - After Split, only HK CORP
               /*     
               select o.organization_id --,lv.lookup_code , lv.meaning
               into v_organization_id
               from
                    hr_all_organization_units o,
                    fnd_lookup_values lv,
                    xxhr_employee_upload e
                where
                    lv.meaning = o.name
                    and lv.lookup_type = 'LE_EXPORG'
                    and substr(e.default_expense_acct,1,3) = lv.lookup_code
                    and e.emp_number = p_emp_number;
                */
                select organization_id
                into v_organization_id 
                from hr_all_organization_units 
                where name = 'CORP-HONG KONG';            
                -- 09-Nov-2020 - End TM Split Instance - After Split, only HK CORP
            exception when others then
                 update xxhr_employee_upload
                 set    message = 'Unable to set exp org for.  Check set-up in LE_EXPORG'
                 where  emp_number = p_emp_number;
             end;


		-- Reset for all of the employee's assignment records, don't care about history
		update per_assignments_f
		set    set_of_books_id = v_set_of_books_id,
                       organization_id = nvl(v_organization_id,organization_id),
                       last_update_date = sysdate,
                       last_updated_by = -1
                where  person_id = p_person_id;
		commit;

	exception
        when others then
                v_err_num := SQLCODE;
                v_err_msg := substr(SQLERRM,1,100);
                insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   attribute1,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
                values (1, 'EMP_LOAD', 'Rehire Emp',
                   100, v_err_num, v_err_msg,
                   to_char(p_person_id),
                   sysdate, -1, sysdate, -1, -1);

	end rehire_emp;

	--
	-- Main program
	--
	--
	-- Process the Employee record(s) that are available in XXHR_EMPLOYEE_UPLOAD table

	Procedure process_employee is
	v_person_id 	    number;
        v_bus_group      varchar(30);
        v_empl_number     varchar(100);
        v_user_id           fnd_user.user_id%type;
        v_user_name         fnd_user.user_name%type;
	v_business_group_id number;
        v_active 	    boolean;
	v_err_num	number := 0;         -- Holds the error number associated with SQL Statement
	v_err_msg	varchar2(100) := null;  -- Holds the error message associated with SQL Statement


        cursor legal_entity is

                            select u.emp_number, p.cur_legal_entity, u.legal_entity
                            from
                            (select distinct p.employee_number, gl.segment1 cur_legal_entity
                                    from
                                            gl_code_combinations gl,
                                            per_assignments_f a,
                                            per_people_f p
                                where
                                        a.default_code_comb_id = gl.code_combination_id
                                        and sysdate between a.effective_start_date and a.effective_end_date
                                        and a.person_id = p.person_id
                                        and sysdate between p.effective_start_date and p.effective_end_date) p,
                               xxhr_employee_upload u
                               where
                                    u.emp_number = p.employee_number(+)
                                    ;

		Cursor xeu_cur is


            select p.object_version_number per_object_version_number,
                      cc.code_combination_id,
                      nvl(a.address_id,0) address_id,
                      a.country current_ora_country,
                      nvl(a.object_version_number,0) addr_object_version_number,
                      l.address_line_2 loc_address_line_1,
                      l.address_line_3 loc_address_line_2,
                      l.town_or_city loc_town_or_city,
                      l.country loc_country,
                      nvl(l.region_2,l.region_1) loc_state,
                      l.postal_code loc_postal_code,
                      xeu.*
                      , (select grade_id from per_grades where name = xeu.grade) grade_id
               from   hr_locations l,
                      xxhr_employee_upload xeu,
                      per_people_f p,
                      xxhr_code_combinations_v cc,
                      per_addresses a
           where      l.location_code <> 'MRL CAN-ALBERTA'
                      --and l.location_code not like 'TM%' -- 09-Nov-2020 TM Split Instance, defualt location use MRI
                      ---not sure why, but CAN002 is assigned to 2 CA locations which causes duplicate data.
                      -- we only need to use the HR_LOCATIONS addresses for the HK files so we'll just exclude the dup
                      and xeu.location_code = l.attribute1(+)
                      and XEU.EMP_NUMBER = p.employee_number(+)
                      and sysdate between p.effective_start_date(+) and p.effective_end_date(+)
                      and XEU.DEFAULT_EXPENSE_ACCT = cc.default_account(+)
                      and p.person_id = a.person_id(+)
                      and a.primary_flag(+) = 'Y'
                      and sysdate between a.date_from(+) and nvl(a.date_to(+),sysdate+1)
                      and xeu.message is null ---not in ('No legal entity assignment, can not create employee.', 'Unable to find Ledger assignment, can not process employee.')
                      ;

        cursor ignore_cur is

        select distinct p.employee_number, p.person_id, a.assignment_id, a.ass_attribute2, u.emp_number
        from xxhr_employee_upload u, per_people_f p, per_assignments_f a
        where
            p.employee_number = u.emp_number(+)
            and u.emp_number is not null   --> this cursor is only if the employee that we're ignoing/re-terming exists in Workday/Workday file
            and a.person_id = p.person_id
            and trunc(sysdate) between trunc(a.effective_start_date) and trunc(a.effective_end_date)
            and trunc(sysdate) between trunc(p.effective_start_date) and trunc(p.effective_end_date)
            and a.ass_attribute2 is not null;

        cursor re_term_cur is
        --this cursor is only if the employee that we're ignoing/re-terming does NOT exist in Workday/Workday file

        select distinct p.employee_number, p.person_id,  a.ass_attribute2, u.emp_number, p.effective_start_date
        from xxhr_employee_upload u, per_people_f p, per_assignments_f a
        where
            p.employee_number = u.emp_number(+)
            and u.emp_number is null   -->
            and a.person_id = p.person_id
            and trunc(sysdate) between trunc(a.effective_start_date) and trunc(a.effective_end_date)
            and trunc(sysdate) between trunc(p.effective_start_date) and trunc(p.effective_end_date)
            and a.ass_attribute2 is not null;

		cursor xeu_ppf_cur is

			select  ppf.person_id emp_id, ppfa.person_id supervisor_id, xeu.emp_number
   			from    xxhr_employee_upload xeu,
          			per_people_f ppf,
          			per_people_f ppfa
			where   ppf.employee_number = xeu.emp_number
     			and  ppfa.employee_number(+) = ltrim(rtrim(xeu.supervisor));

		cursor fnd_ppf_cur is

			select  ppf.person_id, fu.email_address
			from    per_people_f ppf,
				fnd_user fu
			where   -- ltrim(rtrim(ppf.email_address)) is null
			        fu.employee_id = ppf.person_id
			and     ltrim(rtrim(fu.email_address)) is not null;

		v_street1 xxhr_employee_upload.street1%TYPE;
		v_street2 xxhr_employee_upload.street2%TYPE;
		v_city xxhr_employee_upload.city%TYPE;
		v_state xxhr_employee_upload.state%TYPE;
	    v_zip_code xxhr_employee_upload.zip_code%TYPE;
		v_country xxhr_employee_upload.country%TYPE;
        v_grade varchar2(20);
        v_ledger_name varchar2(100);
        v_grade_non_job number;
        v_grade_job number;

	Begin

        fnd_file.put_line (fnd_file.log, 'Start Process_Employee');

        -- delete any errors from previous run
        delete from xxhr_errors where application = 'EMP_LOAD';
        commit;

        -- Not sure why, but Italy address comes across with STREET1 null and STREET2 populated
        -- This is not how it appears in Workday....just update now....
        update xxhr_employee_upload
        set street1 = street2
        where street1 is null;

        update xxhr_employee_upload
        set message = 'No Legal First Name provided.  Can not process employee'
        where first_name is null;

        update xxhr_employee_upload
        set message = 'No Legal Last Name provided.  Can not process employee'
        where last_name is null;

        -- we only want to populate "Known As" if different from their first name
        update xxhr_employee_upload
        set known_as = null
        where known_as = first_name;

        -- If HK, add "H" to employee number.
        -- Will not be include in emp/sup number in file - but that's how it'll be in Oracle
        update xxhr_employee_upload
        set emp_number = 'H' || emp_number
        where location_code in (SELECT ffv.flex_value
                                FROM fnd_flex_value_sets ffvs, fnd_flex_values_vl ffv
                                WHERE ffvs.flex_value_set_name = 'XXHR_H_EMPLOYEE_NUMBERS'
                                AND ffvs.flex_value_set_id=ffv.flex_value_set_id)
            and emp_number not like 'H%';

        update xxhr_employee_upload
        set supervisor = 'H' || supervisor
        where location_code in (SELECT ffv.flex_value
                                FROM fnd_flex_value_sets ffvs, fnd_flex_values_vl ffv
                                WHERE ffvs.flex_value_set_name = 'XXHR_H_EMPLOYEE_NUMBERS'
                                AND ffvs.flex_value_set_id=ffv.flex_value_set_id)
            and supervisor not like 'H%';

        -- HK is sending inconsistent data for the country columns
        -- We need the 2 char abreviation for the grade override section
        -- pull country from location code -- we'll ignore what they send for country, location code is important part
        update xxhr_employee_upload u
        set country = (select country from hr_locations l
                       where attribute1 = u.location_code);
        commit;

        -- 3/5/18 not calling XXCM_JOB_PROC anymore so we need to update the JOB_ID on our tracking table
        -- if Workday job doesn't exist in Oracle, JOB_ID will be null on tracking table
        -- some of the job desc contains a carriage return (exist on both XXHR_EMPLOYEE_UPLOAD and PER_JOBS - but not consisitant)
        -- strip carriage retrun from both so we find matches
        UPDATE xxhr_employee_upload e
        SET job_id = (select min(job_id)
                from per_jobs j
                --where upper(j.name) = rtrim(ltrim(upper(e.job_description)))
                where upper(replace(j.name,chr(13),'')) = upper(replace(e.job_description,chr(13),''))
                and sysdate between date_from and nvl(date_to, sysdate+1))
        WHERE rtrim(ltrim(job_description)) is NOT NULL;

        commit;

        -- Assign Ledger based on Legal Entity sent
        -- if Workday didn't sent us a Legal Entity, we're not going to be able to assign a Ledger -- so we can't create or update employee
        -- If no LE on load file, update field with employee's current LE.  (this is how terminated employees will appear)
        -- otherwise error and employee will be ignored for rest of process

        for legal_entity_rec in legal_entity loop
            if legal_entity_rec.legal_entity is not null OR legal_entity_rec.cur_legal_entity is not null then

                        begin
                            select g.ledger_name
                            into v_ledger_name
                            FROM
                                    GL_LEDGER_LE_V g,
                                    apps.gl_legal_entities_bsvs a,
                                    apps.XLE_ENTITY_PROFILES b
                            WHERE
                                    b.name = g.legal_entity_name
                                    and a.legal_entity_id = b.legal_entity_id
                                    AND (a.end_date is null or a.end_date > sysdate)
                                     AND a.flex_segment_value = nvl(legal_entity_rec.legal_entity, legal_entity_rec.cur_legal_entity);

                            update xxhr_employee_upload
                            set set_of_books_name = v_ledger_name
                            where emp_number =  legal_entity_rec.emp_number;

                        exception when others then
                                 update xxhr_employee_upload set message = 'Unable to find Ledger assignment, can not process employee.'
                                 where emp_number = legal_entity_rec.emp_number;
                        end;

            else  --no Oracle LE or Le from Workday
                        update xxhr_employee_upload set message = 'No legal entity assignment, can not create employee.'
                        where emp_number = legal_entity_rec.emp_number;

            end if;

        end loop;   --legal_entity
        commit;

        -- string together accounting segments
        update xxhr_employee_upload
        set default_expense_acct = legal_entity ||'-'|| product_line ||'-'|| site ||'-'|| cost_center ||'-'||'999999-000';
        commit;

        -- if the employee has been rehired with XXHR_EMP_REHIRE, per_assignments_f.ass_attribute2 is set to the date that they should remain active until.
        -- don't update employee in R12 until date has passed -- then delete record from xxhr_employee_upload
        -- after date has passed, clear value on per_assignments_f and let the rest of the program re-term employee
        ---- this only works if the employee's record extst in Workday
        for ignore_rec in ignore_cur loop
            begin
            if to_date(ignore_rec.ass_attribute2,'DD-MON-YY') >= trunc(sysdate) then
                delete from xxhr_employee_upload where emp_number = ignore_rec.employee_number;
            else
                update per_assignments_f
                set ass_attribute2 = null
                where assignment_id = ignore_rec.assignment_id;
             end if;
            exception when others then null;
            end;
        end loop;
        commit;

        -- if employee does not exist in Worday -- but was rehired with XXHR_EMP_REHIRE, this section will re-term them after the specified end date passes
        for re_term_rec in re_term_cur loop
            begin
            if trunc(sysdate) > to_date(re_term_rec.ass_attribute2,'DD-MON-YY')  then

                terminate_employee(trunc(re_term_rec.effective_start_date)+1, re_term_rec.person_id);

                update per_assignments_f
                set ass_attribute2 = null
                where person_id = re_term_rec.person_id
                        and ass_attribute2 = re_term_rec.ass_attribute2;

             end if;
            exception when others then null;
            end;
        end loop;
        commit;

             /****  Job code ****/
             -- 09-Nov-2020 - TM Split Instance
             /*
            BEGIN
             -- 3/5/18 - do not create new jobs as part of this process, error and they'll manually set-up
             --- xxcm_approval_gd_pkg.xxcm_job_proc (errbuf ,retcode);
             -- still call procedure to create grades associated with valid jobs
              xxcm_approval_gd_pkg.xxcm_valid_grades_proc(errbuf ,retcode);
            EXCEPTION WHEN OTHERS THEN
              dbms_output.put_line('Error in job code update');
            END;
            */


		for xeu_rec in xeu_cur loop
		    Begin

                -- If address was blank on input file, use adderss associated with Location Code
                if xeu_rec.street1 is null then
                  v_street1 := xeu_rec.loc_address_line_1;
                  v_street2 := xeu_rec.loc_address_line_2;
                  v_city := xeu_rec.loc_town_or_city;
                  v_state := xeu_rec.loc_state;
                  v_zip_code := xeu_rec.loc_postal_code;
                  v_country := xeu_rec.loc_country;
                else
                 -- if work country = US or CA, pulling home address from HCM, otherwise pulling location address
                  v_street1 := xeu_rec.street1;
                  v_street2 := xeu_rec.street2;
                  v_city := xeu_rec.city;
                  v_state := xeu_rec.state;
                  v_zip_code := xeu_rec.zip_code;
                  v_country := xeu_rec.country;
                end if;

			-- check if the person already exists in Oracle. If so the person_id and
			-- business_group_id of the person in Oracle will be written into v_person_id
			-- and v_business_group_i
			check_ora_employee(xeu_rec.emp_number, v_person_id, v_business_group_id);

           -- Override grade
           -- Lookup XXHR_APPRV_OVERRIDE_GRADES contains Countries/Grades that we want to override
           -- 09-Nov-2020 - Start TM Split Instance
           /*
           begin

                select
                    tag,   -- 7/31/19 use tag.  Oracle requires that MEANING is unique but we want CN, SG, and HK to go to HKAA, etc. grades
                    to_char(g.grade_id),
                    to_char(g.grade_id)
                into v_grade,
                     v_grade_non_job, --PER_PEOPLE_F.ATTRIBUTE1
                     v_grade_job
                from
                    per_grades g,
                    fnd_lookup_values v
                where
                    --v.meaning = g.name --old join when using meaning
                    v.tag = g.name
                    and lookup_type = 'XXHR_APPRV_OVERRIDE_GRADES'
                    and sysdate between start_date_active and nvl(end_date_active,sysdate+1)
                    and substr(lookup_code,1,2) = xeu_rec.country
                    and substr(meaning,3,length(meaning)-2) = xeu_rec.grade;

           exception when no_data_found then
               v_grade := xeu_rec.grade;
               v_grade_non_job := xeu_rec.grade_id; --PER_PEOPLE_F.ATTRIBUTE1
               v_grade_job := xeu_rec.grade_id;
           end;

           -- Lookup XXHR_APPRV_OVERRIDE_EMPLOYEES contains the employees and override grades
           -- ATTRIBUTE1 = Discretionary Grade --> populate employee Grade (on assignment)
           -- ATTRIBUTE2 = Non-Job Related Grade --> populate PER_PEOPLE_F.ATTRIBUTE1
           -- ATTRIBUTE3 = Job Related Grade --> populate PER_PEOPLE_F.ATTRIBUTE2
           begin

                select g.name,    --v.attribute1,  The API wants the Grade Name
                       v.attribute2,   -- the API wants the Grade ID for the Attribute columns
                       v.attribute3
                into v_grade,
                     v_grade_non_job,
                     v_grade_job
                from
                    per_grades g,
                    fnd_lookup_values v
                where
                    sysdate between g.date_from and nvl(g.date_to,sysdate+1)
                    and g.grade_id = to_number(v.attribute1)
                    and lookup_type = 'XXHR_APPRV_OVERRIDE_EMPLOYEES'
                    and sysdate between start_date_active and nvl(end_date_active,sysdate+1)
                    and lookup_code = xeu_rec.emp_number;

           exception when no_data_found then
               --v_grade := xeu_rec.grade; --> don't override what we populated by Grade/Country rule if no employee rule exists
               --v_grade_non_job := xeu_rec.grade_id;
               --v_grade_job := xeu_rec.grade_id;
               null;
           end;
           */
            v_grade := xeu_rec.grade;
            v_grade_non_job := xeu_rec.grade_id; --PER_PEOPLE_F.ATTRIBUTE1
            v_grade_job := xeu_rec.grade_id;
            -- 09-Nov-2020 - end TM Split Instance           

            begin
                select name 
                into v_grade
                from per_grades
                where name = v_grade
                --and xeu_rec.start_date_active >= date_from
                ;
            exception when others then
                update xxhr_employee_upload 
                set message = 'Unable to find Grade "'||v_grade||'".'
                where emp_number = xeu_rec.emp_number;

                CONTINUE;            
            end;

			-- If the employee exists in Oracle, check if the employee is active in Oracle
			if v_person_id is not null and v_business_group_id is not null then

				v_active:= check_ora_emp_status(v_person_id, v_business_group_id);

                    -----------------------------------------------------------------
                    -- Rehires --
					-- Inactive in Oracle, Active in Lawson, no term date
					if v_active = FALSE and xeu_rec.term_status = 'A' and xeu_rec.term_date is null then

					   rehire_emp(xeu_rec.emp_number,xeu_rec.job_id,v_person_id, v_business_group_id, xeu_rec.start_date_active,
					   			 xeu_rec.set_of_books_name, xeu_rec.country);

					   update xxhr_employee_upload
					   set    message = 'Employee was rehired'
					   where  emp_number = xeu_rec.emp_number;

					end if;

					------------------------------------------------------------------
					-- Update Employee --
					-- Considered Active is term date is null or within 90 days
					-- Don't worry about Lawson status
					-- Rehires still need to be updated
					--if nvl(xeu_rec.term_date, sysdate) >= (sysdate - 90) then -- JLO 3/26/14 remove processing delay
					if nvl(xeu_rec.term_date, sysdate) >= sysdate then

					-- The new status is also active. so update the employee info in Oracle
			             	-- with the new info

					    update_employee(xeu_rec.term_date,xeu_rec.emp_number,xeu_rec.job_id,v_person_id, v_business_group_id, xeu_rec.start_date_active,
							    xeu_rec.last_name,
					  		    xeu_rec.first_name,
                                xeu_rec.mi,
                                xeu_rec.known_as,
                                xeu_rec.sex,
			  				    v_street1, v_street2, v_city,
		 					    v_state, v_zip_code, v_country,
							    xeu_rec.default_expense_acct,
							    xeu_rec.email,
								xeu_rec.location_code,
                                xeu_rec.per_object_version_number,
                                xeu_rec.code_combination_id,
                                xeu_rec.address_id,
                                xeu_rec.set_of_books_name,
                                xeu_rec.addr_object_version_number,
                                xeu_rec.current_ora_country,
                                v_grade,
                                xeu_rec.job_code,
                                v_grade_non_job,
                                v_grade_job
                                );

                        -- Determine if FND_USER associated with employee exists, if so, update FND_USER person data
                        check_fnd_user(v_person_id, v_user_id, v_user_name);

                        if v_user_id is not null then
                            update_fnd_user(v_user_name, v_person_id, xeu_rec.email);
                        end if;

                        update xxhr_employee_upload
                        set message = message||'|Employee Updated'
                        where emp_number = xeu_rec.emp_number;                        
					--------------------------------------------------------------------
					-- Term Employee --
					-- Considered Termed if term date is 90 ago
					--elsif xeu_rec.term_date < sysdate - 90 then  -- JLO 3/26/14 remove processing delay
					elsif xeu_rec.term_date < sysdate then

				   		 -- the new status is Terminated. so terminate the employee in Oracle
					     terminate_employee(trunc(xeu_rec.term_date), v_person_id);

						 update xxhr_employee_upload
						 set message = 'Employee terminated'
						 where emp_number = xeu_rec.emp_number;

				         -- terminate employee fnd user
					     terminate_emp_fnd_user(v_person_id, trunc(xeu_rec.term_date));

					end if; -- update or term emp

			else -- person doesn't exist in Oracle

				--- if the person is not existing in Oracle and status is active,
				--- create a employee record in Oracle
				if xeu_rec.term_status = 'A'  then

				      create_employee(xeu_rec.job_id,xeu_rec.emp_number, xeu_rec.start_date_active, xeu_rec.last_name,
   				              xeu_rec.first_name, xeu_rec.mi, xeu_rec.known_as, xeu_rec.sex,
		 				      v_street1, v_street2, v_city,
		 				      v_state, v_zip_code, v_country, xeu_rec.email,
						      xeu_rec.location_code, xeu_rec.default_expense_acct,
							   xeu_rec.set_of_books_name,
                              v_grade, xeu_rec.job_code,
                              v_grade_non_job,
                              v_grade_job);

                        update xxhr_employee_upload
                        set message = message||'|Employee Created'
                        where emp_number = xeu_rec.emp_number;
				end if;

			end if; ---person does/doesn't exist in Oracle
			-- end if;

		   Exception

			when others then
			      update xxhr_employee_upload
			      set    message = 'Error for employee number:'||xeu_rec.emp_number
			      where  emp_number = xeu_rec.emp_number;

               --Also add record to errors table
                v_err_num := SQLCODE;
                v_err_msg := substr(SQLERRM,1,100);
                insert into xxhr_errors (error_id, application,
                   module_name, request_id, error_number, error_msg,
                   attribute1,
                   creation_date, created_by, last_update_date,
                   last_update_by, last_update_login)
                values (1, 'EMP_LOAD', 'Other',
                   100, v_err_num, v_err_msg,
                   xeu_rec.emp_number,
                   sysdate, -1, sysdate, -1, -1);

		   End;
		end loop;

		-- save the data
		commit;

		--- populating supervisor id in assignment record
		for xeu_ppf_rec in xeu_ppf_cur loop

			-- update the assignment record with supervisor data
            -- 2/9/16 change -- update to null if they report to themselves (CEO should be only one)
             IF  xeu_ppf_rec.emp_id = xeu_ppf_rec.supervisor_id then
                    update per_assignments_f
                    set    supervisor_id = null
                    where  person_id = xeu_ppf_rec.emp_id;
             ELSIF xeu_ppf_rec.supervisor_id IS NOT NULL THEN
			        update per_assignments_f
		            set    supervisor_id = xeu_ppf_rec.supervisor_id
			        where  person_id = xeu_ppf_rec.emp_id;
             END IF;

		end loop;

		commit;

        Exception
                when others then  
                    null;
                    v_err_num := SQLCODE;
                    v_err_msg := substr(SQLERRM,1,100);
                    insert into xxhr_errors (error_id, application,
                        module_name, request_id, error_number, error_msg,
                        creation_date, created_by, last_update_date,
                        last_update_by, last_update_login)
                    values (1, 'EMP_LOAD', 'process_employee',
                        100, v_err_num, v_err_msg, sysdate, -1, sysdate, -1, -1);

                    dbms_output.put_line('Error code ' || SQLCODE || ': ' || SQLERRM);

       End process_employee;

End xxhr_Emp_upload;   --- End of Package


/
