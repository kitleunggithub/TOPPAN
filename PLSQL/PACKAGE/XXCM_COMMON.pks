--------------------------------------------------------
--  DDL for Package XXCM_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXCM_COMMON" is
/*******************************************************
 * History:
 *
 * 04/30/13  AKAPLAN  Added function for formatting address
 *                    Cleanup functions for file management and accessing value sets.
 * 09/26/13  AKAPLAN  Add result_cache to get_flex_value_field function
 * 06/09/14  JZAMOW   Added insert_debug_msg to provide a common procedure
 * 8/1/2014  LKM      Add a get flex id function that checks if enabled
 * 08/12/14  AKAPLAN  Create function to get default country for operating unit.
 * 05/13/15  Fujitsu  For R12 Uprgade, ra_addresses.address_id
 *                     is replaced with hz_cust_acct_sites_all.cust_acct_site_id
 * 07/23/15  akaplan  R12 Upgrade functions:
 *                      get_business_unit, get_business_id, get_org_key
 * 02/26/16  TRINGHAND Added get_web_plsql_vals to retrieve values needed to
 *                     make different web calls.
 * 05/23/16  akaplan   Enh Req 133: Add get_utl_path for easier access to utl_file paths
 * 08/03/16  akaplan   Added PARALLEL_ENABLE for use in warehouse loads
 * 08/23/16  am        added cust_trx_type, cust_trx_type_name, sup email. Per Ari added
 *                     PARALLEL_ENABLE/RESULT_CACHE to get_flex_value_id,
 *                     get_web_plsql_value, get_utl_path
 * 12/02/16  akaplan   Add PARALLEL_ENABLE to get_business... functions
 * 01/05/17  akaplan   Add get_currency_precision
 * 03/17/17  akaplan   Add get_business_..._by_prod_type functions
 * 05/22/17  akaplan   Add PARALLEL_ENABLE to get_trx_type/name
 * 12/08/18  akaplan   Enh Req 2243: Add currency rounding function
 * 05/16/19  akaplan   Enh Req 2362: Add get_org_hq function
 *******************************************************/
   TYPE string_tbl IS TABLE OF VARCHAR2(32000) INDEX BY PLS_INTEGER;
   TYPE string_key_tbl IS TABLE OF VARCHAR2(32000) INDEX BY VARCHAR2(32000);

   FUNCTION get_flex_value_id(p_lookup varchar2, p_lookup_value varchar2) return number PARALLEL_ENABLE;
   FUNCTION get_constant_value(p_lookup varchar2) return varchar2 PARALLEL_ENABLE;
   FUNCTION get_flex_value_field(pLookup       VARCHAR2,
                                 pLookup_value VARCHAR2,
                                 pField        VARCHAR2 DEFAULT 'DESCRIPTION',
                                 pEnabledOnly  VARCHAR2 DEFAULT 'N')
       RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE;

   FUNCTION get_flex_value_field(p_value_id NUMBER, pField VARCHAR2)
       RETURN VARCHAR2 PARALLEL_ENABLE;

   FUNCTION get_flex_value(p_value_id in number) return varchar2 PARALLEL_ENABLE;
   FUNCTION flex_value_exists(p_lookup varchar2, p_lookup_value varchar2, p_enabled_only VARCHAR2 DEFAULT 'N' ) RETURN VARCHAR2;
   FUNCTION is_prod_db RETURN VARCHAR2;
   FUNCTION get_db RETURN VARCHAR2 RESULT_CACHE;
   FUNCTION get_db_constant(p_lookup varchar2) RETURN VARCHAR2;

   -- Functions based on flexfield dependencies
   FUNCTION get_dep_flex_value_field(pParent       VARCHAR2
                                    ,pLookup_set   VARCHAR2
                                    ,pLookup_value VARCHAR2
                                    ,pField        VARCHAR2 DEFAULT 'DESCRIPTION'
                                    ,pEnabledOnly  VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 RESULT_CACHE;

   FUNCTION get_db_flex_value_field(pLookup_set   VARCHAR2
                                   ,pLookup_value VARCHAR2
                                   ,pField        VARCHAR2 DEFAULT 'DESCRIPTION'
                                   ,pEnabledOnly  VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;

   FUNCTION dep_flex_value_exists(p_parent VARCHAR2
                                 ,p_lookup varchar2
                                 ,p_lookup_value varchar2
                                 ,p_enabled_only VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;


   FUNCTION sizeof( p_str in out varchar2 ) return number;
   --FUNCTION get_for_sys_email_address(p_foreign_sys_number varchar2, p_application varchar2, p_report_type varchar2) return varchar2;
   PROCEDURE write_log( p_str IN VARCHAR2, p_show_time IN VARCHAR2 DEFAULT 'Y');
   PROCEDURE put_line( p_str IN VARCHAR2
                     , p_show_time IN VARCHAR2 DEFAULT 'Y'
                     , p_type IN VARCHAR2 DEFAULT 'OUT');

   --Commented for R12 Upgrade
   /*FUNCTION format_address ( p_address_id ra_addresses.address_id%TYPE,
                             p_addr_type VARCHAR2 := 'STD' ) RETURN VARCHAR2;*/
   --Added for R12 Upgrade
   /*
   FUNCTION format_address ( p_address_id hz_cust_acct_sites_all.CUST_ACCT_SITE_ID%TYPE,
                             p_addr_type VARCHAR2 := 'STD' ) RETURN VARCHAR2;
   */

   FUNCTION get_addr_val ( p_addr_field IN VARCHAR2
                         , p_state IN VARCHAR2
                         , p_province IN VARCHAR2
                         , p_country IN VARCHAR2 )
   RETURN VARCHAR2;

   FUNCTION get_curr_operating_unit RETURN NUMBER;
   FUNCTION get_ou_print_ctry(p_operating_unit NUMBER DEFAULT xxcm_common.get_curr_operating_unit)
     RETURN VARCHAR2 RESULT_CACHE;

   PROCEDURE string2array (p_string VARCHAR2, p_delimiter VARCHAR2, p_out_array OUT string_tbl);
   PROCEDURE insert_debug_msg(p_process_name  VARCHAR2
                             ,p_message       VARCHAR2);

   FUNCTION get_flex_id(p_flex_value_set IN VARCHAR2
                       ,p_flex_value IN VARCHAR2
                       ,p_enabled_only IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;

   PROCEDURE init_moac;
   FUNCTION get_org_name (p_org_id hr_organization_units.organization_id%TYPE)
        RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE;
   FUNCTION get_user_name (p_user_id fnd_user.user_id%TYPE)
     RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE;

   -- Added for COA
   FUNCTION get_business_unit (p_product_line VARCHAR2)
      RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE;
   FUNCTION get_business_id (p_product_line VARCHAR2)
      RETURN NUMBER RESULT_CACHE PARALLEL_ENABLE;
   FUNCTION get_business_id_by_prod_type ( p_product_type VARCHAR2 )
      RETURN NUMBER RESULT_CACHE PARALLEL_ENABLE;
   FUNCTION get_business_unit_by_prod_type ( p_product_type VARCHAR2 )
      RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE;

   FUNCTION get_org_key (p_org_id hr_organization_units.organization_id%TYPE)
      RETURN VARCHAR2 RESULT_CACHE;

   ----------------------------------------------------------------------
   -- get_web_plsql_values
   --   Procedure that can be called to retrieve values needed to make
   --   web calls into the system like to email images, Final invoices URL,
   --   or exhange rate call.
   ----------------------------------------------------------------------
   PROCEDURE get_web_plsql_values (p_web_host       OUT VARCHAR2,
                                   p_web_port       OUT VARCHAR2,
                                   p_db_host        OUT VARCHAR2,
                                   p_web_plsql_port OUT VARCHAR2,
                                   p_web_plsql_path OUT VARCHAR2,
                                   p_web_plsql_url  OUT VARCHAR2);


   ----------------------------------------------------------------------
   -- get_web_plsql_value
   --   Function to call to retrieve a single value needed to make
   --   web call.
   ----------------------------------------------------------------------
   FUNCTION get_web_plsql_value (p_web_name VARCHAR2) RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE;
   FUNCTION get_utl_path ( p_directory VARCHAR2 )     RETURN VARCHAR2 RESULT_CACHE;
   FUNCTION get_trx_type_name (p_trx_type_id NUMBER) RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE;
   FUNCTION get_trx_type (p_trx_type_id NUMBER) RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE;
   FUNCTION  get_sup_id  (p_person_id IN NUMBER
                                           ) RETURN NUMBER;
   FUNCTION  get_sup_email  (p_person_id IN NUMBER
                                           ) RETURN VARCHAR2;
   FUNCTION  get_sup_email  (p_prep_person_id IN NUMBER,
                                            p_req_person_id  IN NUMBER,
                                            p_by_person_id IN NUMBER
                                           ) RETURN VARCHAR2;
   FUNCTION get_user_email (p_userid NUMBER DEFAULT fnd_global.user_id)
      RETURN VARCHAR2 RESULT_CACHE;
   FUNCTION get_currency_precision ( p_currency VARCHAR2 )
      RETURN NUMBER RESULT_CACHE PARALLEL_ENABLE;

   FUNCTION currency_round( p_amount NUMBER, p_precision NUMBER, p_rule VARCHAR2 )
     RETURN NUMBER;

  /*
   FUNCTION currency_round( p_amount NUMBER, p_currency VARCHAR2)
      RETURN NUMBER PARALLEL_ENABLE;
  */
   FUNCTION get_org_hq ( p_org_id NUMBER ) RETURN VARCHAR2;


end xxcm_common;

/
