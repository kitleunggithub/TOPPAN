--------------------------------------------------------
--  DDL for Package Body XXCM_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXCM_COMMON" is
/*******************************************************
 * History:
 *
 * 4/30/13   AKAPLAN   Added function for formatting address
 *                     Cleanup functions for file management and accessing value sets.
 * 08/06/13  AKAPLAN   Add PROJ_ADDR type for formatting addresses
 * 09/26/13  AKAPLAN   Add ability to get flex field value based on dff name
 * 11/25/13  AKAPLAN   Add address3/4 to project addresses formatting
 * 06/09/14  JZAMOW    Added insert_debug_msg to provide a common procedure
 * 8/1/2014  LKM       Add a get flex id function that checks if enabled
 * 08/12/14  AKAPLAN   Enhance error message for address formatting.
 *                     Remove COUNTRY when issued from corresponding org unit
 * 01/28/15  JZAMOW    Bug fix needed for credit card project
 * 05/13/15  FUJITSU   For R12 Upgrade, RA_ADDRESSESS_ALL is replaced with
 *                     HZ_PARTY_SITES,HZ_CUST_ACCT_SITES_ALL,HZ_LOCATIONS
 * 05/18/15  AKAPLAN   Change how current_org determined
 *                     Add db specific functions (based on dependent flex values)
 * 02/26/16  TRINGHAND Added get_web_plsql_vals to retrieve values needed to
 *                     make different web calls.
 * 05/23/16  akaplan   Enh Req 133: Add get_utl_path for easier access to utl_file paths
 * 08/03/16  akaplan   Added PARALLEL_ENABLE for use in warehouse loads
 * 08/23/16  am        added cust_trx_type and cust_trx_type_name and sup email
 *                     Per Ari added
 *                     PARALLEL_ENABLE/RESULT_CACHE to get_flex_value_id,
 *                     get_web_plsql_value, get_utl_path
 * 09/23/16 - am       Updated get_sup_id and get_sup_email
 * 12/02/16   akaplan  Add PARALLEL_ENABLE to get_business... functions
 * 01/05/17  akaplan   Add get_currency_precision
 * 03/17/17  akaplan   Add get_business_..._by_prod_type functions
 * 05/22/17  akaplan   Add PARALLEL_ENABLE to get_trx_type/name
 * 11/08/17  akaplan   Add start/end date to determined whether flex is enabled
 * 08/08/18  akaplan   Remove merrill/mrll hard-coded references
 *                     Add function to get fnd_user email address
 * 12/08/18  akaplan   Enh Req 2243: Add currency rounding function
 * 12/14/18  akaplan   Change how db host is acquired
 * 05/16/19  akaplan   Enh Req 2362: Add get_org_hq function
 *******************************************************/
   g_process_id             NUMBER;

   -- Optimize access to constants.
   CURSOR flexval_row (p_set_name  VARCHAR2 DEFAULT NULL
                      , p_value    VARCHAR2 DEFAULT NULL
                      , p_value_id NUMBER   DEFAULT 0
                      , p_parent   VARCHAR2 DEFAULT NULL ) IS
      SELECT vl.row_id flex_rowid,
             vl.FLEX_VALUE_ID,
             vl.DESCRIPTION,
             vl.FLEX_VALUE,
             vl.FLEX_VALUE_MEANING,
             vl.PARENT_FLEX_VALUE_LOW,
             CASE WHEN vl.ENABLED_FLAG = 'Y'
                   AND sysdate BETWEEN nvl(vl.start_date_active,SYSDATE)
                                   AND nvl(vl.end_date_active,SYSDATE)
               THEN 'Y'
               ELSE 'N'
             END ENABLED_FLAG,
             vl.ATTRIBUTE1,
             vl.ATTRIBUTE2,
             vl.ATTRIBUTE3,
             vl.ATTRIBUTE4,
             vl.ATTRIBUTE5,
             vl.ATTRIBUTE6,
             vl.ATTRIBUTE7,
             vl.ATTRIBUTE8,
             vl.ATTRIBUTE9,
             vl.ATTRIBUTE10,
             vl.ATTRIBUTE11,
             vl.ATTRIBUTE12,
             vl.ATTRIBUTE13,
             vl.ATTRIBUTE14,
             vl.ATTRIBUTE15,
             vl.ATTRIBUTE16,
             vl.ATTRIBUTE17,
             vl.ATTRIBUTE18,
             vl.ATTRIBUTE19,
             vl.ATTRIBUTE20
      from fnd_flex_value_sets fvs
        join fnd_flex_values_vl vl on ( vl.flex_value_set_id = fvs.flex_value_set_id )
      where ((p_value_id > 0 AND vl.flex_value_id = p_value_id)
          or (p_value_id = 0
              AND fvs.flex_value_set_name = p_set_name
              AND vl.flex_value = p_value
              AND (p_parent IS NULL or vl.parent_flex_value_low = p_parent)
             )
            )
   ;

   TYPE FLEX_VAL_ROW_TBL IS TABLE OF flexval_row%ROWTYPE INDEX BY VARCHAR2(500);
   tFlexValRow FLEX_VAL_ROW_TBL;


   -- Determine once per session
   bConcReq BOOLEAN        := (fnd_global.conc_request_id > 0);

 -----------------------------------------
 -- write_conc_log
 --   This functions write to the concurrent job log file
 -----------------------------------------
PROCEDURE put_line( p_str IN VARCHAR2
                  , p_show_time IN VARCHAR2 DEFAULT 'Y'
                  , p_type IN VARCHAR2 DEFAULT 'OUT')
IS
   -- Max Line must <= size of subLine
   cMaxLen  NUMBER := 250;
   subLine  VARCHAR2(500);

   l_str   VARCHAR2(32767) := p_str;
   l_time  VARCHAR2(30)    := TO_CHAR(sysdate, 'DD-MON-YY HH24:MI:SS');
   endPos   NUMBER := 0;
   ctr NUMBER := 0;

   PROCEDURE write_text (p_text VARCHAR2) IS
   BEGIN
      IF xxcm_common.bConcReq THEN
         CASE put_line.p_type
            WHEN 'LOG' THEN fnd_file.put(fnd_file.log, p_text);
            WHEN 'OUT' THEN
               fnd_file.put(fnd_file.output, p_text);
               fnd_file.put(fnd_file.log, p_text);
         END CASE;
      ELSE
         dbms_output.put(p_text);
      END IF;
   END write_text;

   PROCEDURE write_text_eol (p_text VARCHAR2) IS
   BEGIN
      IF xxcm_common.bConcReq THEN
         CASE put_line.p_type
            WHEN 'LOG' THEN fnd_file.put_line(fnd_file.log, p_text);
            WHEN 'OUT' THEN
               fnd_file.put_line(fnd_file.output, p_text);
               fnd_file.put_line(fnd_file.log, p_text);
         END CASE;
      ELSE
         dbms_output.put_line(p_text);
      END IF;
   END write_text_eol;
BEGIN
   IF p_show_time = 'Y' THEN
      write_text(l_time || ':');
   END IF;
   WHILE l_str IS NOT NULL -- and ctr < 15
   LOOP
      ctr := ctr + 1;

      IF instr(substr(l_str,1,cMaxLen),chr(10)) > 0 THEN
         -- CR exists within first MaxLen characters
         endPos := instr(substr(l_str,1,cMaxLen),chr(10));
         subLine := rtrim(rtrim(substr(l_str,1,endPos-1)),chr(10));
      ELSE
         endPos := cMaxLen;
         subLine := rtrim(substr(l_str,1,cMaxLen));
      END IF;
      subLine := replace(subLine, chr(10));
      write_text_eol(rtrim(subLine));
      l_str := substr( l_str, endPos + 1 );
   END LOOP;
END put_line;

 -- Explicitly call
 PROCEDURE write_log( p_str IN VARCHAR2
              , p_show_time IN VARCHAR2 DEFAULT 'Y')
 IS
 BEGIN
    xxcm_common.put_line( p_str, p_show_time, 'LOG');
 END write_log;

   -- Get flex value by flex set and value
   FUNCTION get_flex_value_row(p_lookup VARCHAR2
                              , p_lookup_value VARCHAR2
                              , p_parent VARCHAR2 DEFAULT NULL)
     RETURN flexval_row%ROWTYPE RESULT_CACHE
   IS
     vKey  VARCHAR2(500) := p_lookup||'||'||p_lookup_value||'||'||p_parent||'.';
     rFlex flexval_row%ROWTYPE;
   BEGIN
      OPEN flexval_row( p_parent => p_parent
                      , p_set_name => p_lookup
                      , p_value => p_lookup_value);
      FETCH flexval_row INTO rFlex;
      CLOSE flexval_row;

      tFlexValRow(vKey) := rFlex;
      RETURN rFlex;
   EXCEPTION
      -- If any type of error, return empty record
      WHEN OTHERS THEN RETURN rFlex;
   END get_flex_value_row;

   -- Get flex value by id
   FUNCTION get_flex_value_row(p_value_id NUMBER)
     RETURN flexval_row%ROWTYPE IS
     vKey  VARCHAR2(500) := 'BYID:'||p_value_id;
     rFlex flexval_row%ROWTYPE;
   BEGIN
      IF tFlexValRow.exists(vKey) THEN
         rFlex := tFlexValRow(vKey);
      ELSE
         OPEN flexval_row(p_value_id => p_value_id);
         FETCH flexval_row INTO rFlex;
         CLOSE flexval_row;

         tFlexValRow(vKey) := rFlex;
      END IF;

      RETURN rFlex;
   EXCEPTION
      -- If any type of error, return empty record
      WHEN OTHERS THEN RETURN rFlex;
   END get_flex_value_row;

   FUNCTION map_flex_field (pFlexRow flexval_row%ROWTYPE, pField VARCHAR2)
     RETURN VARCHAR2 IS
     ret_val VARCHAR2(500);

     FUNCTION check_dfv RETURN VARCHAR2 IS
        flex_cur  SYS_REFCURSOR;
        flex_stmt VARCHAR2(1000);
        out_var   VARCHAR2(240);
     BEGIN
        flex_stmt := 'select '||pField||' from fnd_flex_values_dfv where row_id = :flex_rowid';
        OPEN flex_cur FOR flex_stmt USING pFlexRow.flex_rowid;
        FETCH flex_cur INTO out_var;
        CLOSE flex_cur;

        RETURN out_var;
     EXCEPTION
        WHEN OTHERS THEN
           RETURN 'FIELD NOT SETUP'||SQLERRM;
     END check_dfv;

   BEGIN
      ret_val :=
         CASE UPPER(pField)
            WHEN 'FLEX_VALUE_ID'       THEN to_char(pFlexRow.flex_value_id)
            WHEN 'DESCRIPTION'         THEN pFlexRow.description
            WHEN 'FLEX_VALUE'          THEN pFlexRow.flex_value
            WHEN 'FLEX_VALUE_MEANING'  THEN pFlexRow.flex_value_meaning
            WHEN 'ATTRIBUTE1'          THEN pFlexRow.attribute1
            WHEN 'ATTRIBUTE2'          THEN pFlexRow.attribute2
            WHEN 'ATTRIBUTE3'          THEN pFlexRow.attribute3
            WHEN 'ATTRIBUTE4'          THEN pFlexRow.attribute4
            WHEN 'ATTRIBUTE5'          THEN pFlexRow.attribute5
            WHEN 'ATTRIBUTE6'          THEN pFlexRow.attribute6
            WHEN 'ATTRIBUTE7'          THEN pFlexRow.attribute7
            WHEN 'ATTRIBUTE8'          THEN pFlexRow.attribute8
            WHEN 'ATTRIBUTE9'          THEN pFlexRow.attribute9
            WHEN 'ATTRIBUTE10'         THEN pFlexRow.attribute10
            WHEN 'ATTRIBUTE11'         THEN pFlexRow.attribute11
            WHEN 'ATTRIBUTE12'         THEN pFlexRow.attribute12
            WHEN 'ATTRIBUTE13'         THEN pFlexRow.attribute13
            WHEN 'ATTRIBUTE14'         THEN pFlexRow.attribute14
            WHEN 'ATTRIBUTE15'         THEN pFlexRow.attribute15
            WHEN 'ATTRIBUTE16'         THEN pFlexRow.attribute16
            WHEN 'ATTRIBUTE17'         THEN pFlexRow.attribute17
            WHEN 'ATTRIBUTE18'         THEN pFlexRow.attribute18
            WHEN 'ATTRIBUTE19'         THEN pFlexRow.attribute19
            WHEN 'ATTRIBUTE20'         THEN pFlexRow.attribute20
            ELSE check_dfv
         END;

         RETURN ret_val;
   END map_flex_field;

   FUNCTION get_dep_flex_value_field(pParent   VARCHAR2,
                                 pLookup_set   VARCHAR2,
                                 pLookup_value VARCHAR2,
                                 pField        VARCHAR2 DEFAULT 'DESCRIPTION',
                                 pEnabledOnly  VARCHAR2 DEFAULT 'N')
   RETURN VARCHAR2 RESULT_CACHE IS
      rFlex flexval_row%ROWTYPE;
   BEGIN
      rFlex := get_flex_value_row(pLookup_set, pLookup_value, pParent);

      -- If enabledonly set to Y, restrict returned values to enabled ones only
      IF pEnabledOnly = 'Y' AND rFlex.enabled_flag != 'Y' THEN
         RETURN NULL;
      END IF;

      RETURN map_flex_field(rFlex, pField);
   EXCEPTION
      WHEN OTHERS THEN RETURN NULL;
   END get_dep_flex_value_field;

   -- Determine DB for current instance
   FUNCTION get_db RETURN VARCHAR2 RESULT_CACHE IS
      v_instance VARCHAR2(10);
   BEGIN
      select upper(substr(global_name,1,instr(global_name,'.')-1))
      into v_instance
      from global_name;

      RETURN v_instance;
   END get_db;

   FUNCTION is_prod_db RETURN VARCHAR2 IS
   BEGIN
      IF upper(xxcm_common.get_flex_value_field('XXCM_INSTANCES', xxcm_common.get_db)) = 'PRODUCTION'
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END is_prod_db;

   -- Get flex value (db specific)
   FUNCTION get_db_flex_value_field(pLookup_set   VARCHAR2,
                                    pLookup_value VARCHAR2,
                                    pField        VARCHAR2 DEFAULT 'DESCRIPTION',
                                    pEnabledOnly  VARCHAR2 DEFAULT 'N')
   RETURN VARCHAR2 IS
      v_retval  VARCHAR2(500);
      v_db      VARCHAR2(10);
      v_prod_db BOOLEAN;
   BEGIN
      v_db := get_db;
      -- Hierarchy for evaluation for database values:
      --   1. production instance
      --   2. instance specific is enabled
      --   3. TEST is enabled
      ------- If allowing disabled fields
      --   4. instance specific NOT enabled
      --   5. TEST not enabled
      IF xxcm_common.is_prod_db = 'Y'
      THEN
         v_retval := get_dep_flex_value_field(v_db, pLookup_set, pLookup_value, pField, pEnabledOnly);
      ELSE
         IF dep_flex_value_exists(v_db, pLookup_set, pLookup_value, 'Y') = 'Y' THEN
            v_retval := get_dep_flex_value_field(v_db, pLookup_set, pLookup_value, pField, 'Y');
         ELSIF dep_flex_value_exists('TEST', pLookup_set, pLookup_value, 'Y') = 'Y' THEN
            v_retval := get_dep_flex_value_field('TEST', pLookup_set, pLookup_value, pField, 'Y');
         ELSIF pEnabledOnly = 'N' THEN
            IF dep_flex_value_exists(v_db, pLookup_set, pLookup_value, 'N') = 'Y' THEN
               v_retval := get_dep_flex_value_field(v_db, pLookup_set, pLookup_value, pField, 'N');
            ELSE
               v_retval := get_dep_flex_value_field('TEST', pLookup_set, pLookup_value, pField, 'N');
            END IF;
         END IF;
      END IF;

      RETURN v_retval;

   EXCEPTION
      WHEN OTHERS THEN RETURN NULL;
   END get_db_flex_value_field;

   ----------------------------------------------------------------------
   --get_constant_value
   --    this function looks up the value related to "p_lookup" (parameter)
   --  in the fnd flex value set "XXCM_DB_CONSTANTS".  This set is used
   --  to store constant or default values used by custom applications which are db specific.
   -----------------------------------------------------------------------
   function get_db_constant(p_lookup varchar2)
   return varchar2
   is
   begin
      RETURN get_db_flex_value_field('XXCM_DB_CONSTANTS', p_lookup, 'DESCRIPTION');
   end get_db_constant;

   FUNCTION get_flex_value_field(pLookup       VARCHAR2,
                                 pLookup_value VARCHAR2,
                                 pField        VARCHAR2 DEFAULT 'DESCRIPTION',
                                 pEnabledOnly  VARCHAR2 DEFAULT 'N')
   RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE IS
      rFlex flexval_row%ROWTYPE;
   BEGIN
      rFlex := get_flex_value_row(pLookup, pLookup_value);

      -- If enabledonly set to Y, restrict returned values to enabled ones only
      IF pEnabledOnly = 'Y' AND rFlex.enabled_flag != 'Y' THEN
         RETURN NULL;
      END IF;

      RETURN map_flex_field(rFlex, pField);
   EXCEPTION
      WHEN OTHERS THEN RETURN NULL;
   END get_flex_value_field;

   FUNCTION get_flex_value_field(p_value_id NUMBER, pField VARCHAR2)
   RETURN VARCHAR2 PARALLEL_ENABLE IS
      rFlex flexval_row%ROWTYPE;
   BEGIN
      rFlex := get_flex_value_row(p_value_id);

      RETURN map_flex_field(rFlex, pField);
   EXCEPTION
      WHEN OTHERS THEN RETURN NULL;
   END get_flex_value_field;

   --------------------------------------------------------
   --get_flex_value_id
   --   this function returns a fnd flex value id given the
   --     set (p_lookup) and value (p_lookup_value)
   --------------------------------------------------------
   function get_flex_value_id(p_lookup varchar2, p_lookup_value varchar2)
   return number PARALLEL_ENABLE
   is
   begin
      RETURN get_flex_value_field(p_lookup, p_lookup_value, 'FLEX_VALUE_ID');
   end get_flex_value_id;

   FUNCTION dep_flex_value_exists(p_parent VARCHAR2, p_lookup varchar2, p_lookup_value varchar2, p_enabled_only VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2
   IS
      v_flex_value_id NUMBER;
      ret_val         VARCHAR2(1);
   BEGIN
      v_flex_value_id := get_dep_flex_value_field(p_parent, p_lookup, p_lookup_value, 'FLEX_VALUE_ID', p_enabled_only);

      IF v_flex_value_id IS NOT NULL THEN
         ret_val := 'Y';
      ELSE
         ret_val := 'N';
      END IF;

      RETURN ret_val;
   END dep_flex_value_exists;

   FUNCTION flex_value_exists(p_lookup varchar2, p_lookup_value varchar2, p_enabled_only  VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2
   IS
      v_flex_value_id NUMBER;
      ret_val         VARCHAR2(1);
   BEGIN
      v_flex_value_id := get_flex_value_field(p_lookup, p_lookup_value, 'FLEX_VALUE_ID', p_enabled_only);

      IF v_flex_value_id IS NOT NULL THEN
         ret_val := 'Y';
      ELSE
         ret_val := 'N';
      END IF;

      RETURN ret_val;
   END flex_value_exists;

   ----------------------------------------------------------------------
   --get_constant_value
   --    this function looks up the value related to "p_lookup" (parameter)
   --  in the fnd flex value set "XXCM_CONSTANTS".  This set is used
   --  to store constant or default values used by custom applications.
   --  Modify to get constant once per session, and store in memory
   -----------------------------------------------------------------------
   function get_constant_value(p_lookup varchar2)
   return varchar2 PARALLEL_ENABLE
   is
   begin
      RETURN get_flex_value_field('XXCM_CONSTANTS', p_lookup, 'DESCRIPTION');
   end get_constant_value;

   ----------------------------------------------------------------------
   --get_flex_value
   --    this function looks up the value and desc related to "p_value_id" (flex_value_id)
   --  in the fnd flex value set "p_set_name".  Returns flex_value
   -----------------------------------------------------------------------

   function get_flex_value(p_value_id in number)
   return varchar2 PARALLEL_ENABLE
   is
   begin
      RETURN get_flex_value_field(p_value_id, 'FLEX_VALUE');
   end get_flex_value;

--returns the maximum size of a varchar2 variable

   function sizeof( p_str in out varchar2 ) return
   number
   as
      l_size number default 0;
      l_str  long default p_str;
   begin
      p_str := null;
      for i in 1 .. 32765 loop
         p_str := p_str || '*';
         l_size := i;
      end loop;
   exception
      when value_error then
         p_str := l_str;
         return l_size;
   end sizeof;

   ----------------------------------------------------------------------
   -- get_for_sys_email_address
   --   this function builds an email address string for the provided
   --   foreign system, application and report type
   ----------------------------------------------------------------------
-- 20201123 BC comment out function for compile first
/*
   function get_for_sys_email_address(p_foreign_sys_number varchar2, p_application varchar2, p_report_type varchar2)
   return varchar2
   is
     l_email_string        varchar2(2000);
     l_email_default       varchar2(2000) := xxcm_common.get_constant_value('CS_ANALYSIS_EMAIL');

     cursor c_addr IS
         select email
         from xxcm_for_sys_contacts
         where active = 'Y'
         and   foreign_sys_number = p_foreign_sys_number
         and   application = p_application
         and   report_type = p_report_type;

   begin
      l_email_string := null;

      for r_addr in c_addr loop
         l_email_string := l_email_string || r_addr.email || ',';
      end loop;

      IF l_email_string is not null THEN
         l_email_string  := substr(l_email_string, 1, length(l_email_string) - 1);
      --JLO 09/24/2007 Use default of Corp Systems Analysis if no contacts are found
      ELSE                                      --JLO 09/24/2007
         l_email_string  := l_email_default;    --JLO 09/24/2007
      END IF;

      return l_email_string;
   end get_for_sys_email_address;
*/
   -- Function to extract address format based on address style.
   --   Uses ADDR_STYLE based on country, but can be overridden by address_style parameter
   FUNCTION get_addr_format (  p_country        IN OUT VARCHAR2,
                               p_address_style VARCHAR2 := NULL)
   RETURN VARCHAR2 IS
      v_Select_Columns VARCHAR2(2000);

      CURSOR address_cur (p_in_country VARCHAR2, p_address_style VARCHAR2) IS
         select lvd.address_line_1, lvd.address_line_2, lvd.address_line_3, lvd.address_line_4,
                lvd.address_line_5, lvd.address_line_6, lvd.address_line_7, lvd.address_line_8
         from fnd_territories t
           join fnd_lookup_values lv on ( lookup_type = 'ADDRESS_STYLE'
                                        AND lookup_code = nvl(nvl(p_address_style, t.address_style),'POSTAL_ADDR_DEF')
                                        )
           join fnd_lookup_values_dfv lvd on ( lvd.row_id = lv.rowid )
         where t.territory_code = p_in_country;

      rAddr address_cur%ROWTYPE;

      PROCEDURE build_address (pAddress IN OUT VARCHAR2, pLine VARCHAR2, pFirst BOOLEAN := FALSE) IS
         vLine           VARCHAR2(1000) := pLine;
         addrCols        VARCHAR2(1000);
         v_dflt_ctry     VARCHAR2(50) := get_ou_print_ctry(xxcm_common.get_curr_operating_unit);
      BEGIN
         -- Remove COUNTRY_NAME if incoming country and operating unit country match
         IF p_country = v_dflt_ctry THEN
            vLine := replace(vLine,'<COUNTRY_NAME>');
         END IF;

         addrCols := regexp_replace(vLine,'<(.*?)>','''||addr."\1"||''');
         addrCols := trim('|' from trim('''' from addrCols));
         IF addrCols IS NOT NULL THEN
            IF pAddress IS NULL THEN
               pAddress := addrCols;
            ELSE
               pAddress := pAddress || chr(10) || '|| decode('||addrCols||',NULL,NULL,chr(10)||'||addrCols||')';
            END IF;
         END IF;
      END build_address;

   BEGIN
      OPEN address_cur(p_country, p_address_style);
      FETCH address_cur INTO rAddr;
      IF NOT address_cur%FOUND OR rAddr.address_line_1 IS NULL THEN
         CLOSE address_cur;
         p_country := 'US';
         OPEN address_cur('US','US');
         FETCH address_cur INTO rAddr;
         CLOSE address_cur;
      ELSE
         CLOSE address_cur;
      END IF;

      build_address(v_Select_Columns, rAddr.address_line_1);
      build_address(v_Select_Columns, rAddr.address_line_2);
      build_address(v_Select_Columns, rAddr.address_line_3);
      build_address(v_Select_Columns, rAddr.address_line_4);
      build_address(v_Select_Columns, rAddr.address_line_5);
      build_address(v_Select_Columns, rAddr.address_line_6);
      build_address(v_Select_Columns, rAddr.address_line_7);
      build_address(v_Select_Columns, rAddr.address_line_8);

      RETURN v_Select_Columns;
   END get_addr_format;

    ---Commented for R12 Upgrade
   --function format_address ( p_address_id ra_addresses.address_id%TYPE,
                            -- p_addr_type VARCHAR2 := 'STD')
   --added for R12 Upgrade
   --20201123 BC comment out for compile first
   /*
   FUNCTION format_address ( p_address_id hz_cust_acct_sites_all.cust_acct_site_id%TYPE
                           , p_addr_type VARCHAR2 := 'STD' )
      RETURN VARCHAR2
   IS

      INVALID_IDENTIFIER EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_IDENTIFIER, -00904);
      addrSelectCols    VARCHAR2(4000);
      formatted_address VARCHAR2(2000);
      v_table           VARCHAR2(1000);
      v_select          VARCHAR2(2000);

      v_country         varchar2(60);
      v_addr_style      fnd_territories.address_style%TYPE;
   BEGIN
      IF p_address_id IS NOT NULL THEN
         -- Collect information to determine address format
         IF p_addr_type = 'PROJ_ADDR' THEN
            -- Format project address
            select country_code
              into v_country
            from xxcg_project_addresses pa
            where project_address_id = p_address_id;

            v_country := nvl(v_country,'US');
            addrSelectCols := get_addr_format(v_country);

            -- Create Query
            v_table := '(select '
                    -- Suppress country_name if US.
                    || '  upper(nvl(t.territory_short_name, addr.country_code)) country_name '
                    -- Alias columns for naming consistency in outer select
                    || ', project_address_id address_id' || chr(10)
                    || ', address1'||chr(10)
                    || ', address2'||chr(10)
                    || ', address3'||chr(10)
                    || ', address4'||chr(10)
                    || ', city '||chr(10)
                    || ', state '||chr(10)
                    || ', decode('''||v_country||''',''US'',NULL,province) province '||chr(10)
                    || ', postal_code '||chr(10)
                    || ', decode('''||v_country||''',''US'',province, NULL) county '||chr(10)
                    || ', '''||v_country||''' country' || chr(10)
                    || ' from xxcg_project_addresses addr '
                    || '   left join fnd_territories_tl t on ( t.territory_code = upper(addr.country_code) ))';

         ELSE
            -- Format INVOICE address
            -- Commented for R12 Upgrade

           -- select ra.country, ra.address_style
           --   into v_country, v_addr_style
           -- from ra_addresses_all ra
           -- where ra.address_id = p_address_id;

            --Added for R12 Upgrade
            select loc.country, loc.address_style
              into v_country, v_addr_style
            from hz_party_sites party_site,
                 hz_cust_acct_sites_all acct_site,hz_locations loc
            where acct_site.party_site_id = party_site.party_site_id
              and loc.location_id = party_site.location_id
              and acct_site.cust_acct_site_id = p_address_id;

            addrSelectCols := get_addr_format(v_country, v_addr_style);
            -- NULL country_name for US to US mailings.  Rules TBD (ra.country_name = US and ra.org_id = 21)?
            IF p_addr_type = 'ALT' THEN

               --Commented for R12 Upgrade
               -- Format alternate language address from ra_addresses_all
               --v_table := '(select ra.address_id, dfv.*, upper(dfv.country) country_name '
               --        || ' from ra_addresses_all ra '
               --        || '   join hz_cust_acct_sites_all_dfv dfv on ( dfv.row_id = ra.row_id ))';

               v_table := '(select acct_site.cust_acct_site_id address_id, dfv.*, upper(dfv.country) country_name '
                       || ' from hz_party_sites party_site'
                       || '   join hz_cust_acct_sites_all acct_site on ( acct_site.party_site_id = party_site.party_site_id )'
                       || '   join hz_locations loc on ( loc.location_id = party_site.location_id )'
                       || '   join hz_cust_acct_sites_all_dfv dfv on ( dfv.row_id = acct_site.rowid ))';
            ELSE
               --Commented for R12 Upgrade
               -- Format standard address from ra_addresses_all
              -- v_table := '(select ra.*, upper(nvl(t.territory_short_name, ra.country)) country_name '
              --         || ' from ra_addresses_all ra '
              --         || '   left join fnd_territories_tl t on ( t.territory_code = upper(ra.country) )) ';

             --Added for R12 Upgrade
               v_table := '(select acct_site.cust_acct_site_id address_id
                                 , loc.*
                                 , upper(nvl(t.territory_short_name, loc.country)) country_name '
                       || ' from hz_party_sites party_site'
                       || '   join hz_cust_acct_sites_all acct_site on ( acct_site.party_site_id = party_site.party_site_id )'
                       || '   join hz_locations loc on ( loc.location_id = party_site.location_id )'
                       || '   left join fnd_territories_tl t on ( t.territory_code = upper(loc.country) ))';

            END IF;
         END IF; -- End gathering information to determine address format

         v_select := ' select '||addrSelectCols
                  || ' from '||v_table||' addr where address_id = :p_address_id';

         execute immediate v_select INTO formatted_address USING p_address_id;

         -- If address does NOT contain any word characters (a-z,0-9),
         --   then there is no address (other than hard-coded remnants of the format)
         IF regexp_instr(formatted_address,'\w') = 0 THEN
            formatted_address := NULL;
         END IF;
      ELSE
         formatted_address := NULL;
      END IF;

      RETURN formatted_address;

   EXCEPTION
      WHEN INVALID_IDENTIFIER THEN
         raise_application_error(-20904, 'BAD Address layout in AOL Lookup [ADDRESS_STYLE] for country['||v_country||']: Invalid column <'||regexp_replace(SQLERRM,'.*"\."(.*?)".*','\1')||'> setup  for ra_addresses');
      WHEN OTHERS THEN
         raise_application_error(-20000, 'BAD Address layout in AOL Lookup [ADDRESS_STYLE] for country['||v_country||'] and style['||v_addr_style||'] attempting to format address id=['||p_address_id||']'||SQLERRM
                                      ||chr(10)||'['||v_select||']');
   END format_address;
   */


/*
 builds the value of state/province/locality fields, dependent on country and address style. Conforms to Aria statement contact
 requirements.

  -- added for the Quote to Cash/Aria project as part of the hz_customer_svc API 3/1/2018 LKM
*/
   FUNCTION get_addr_val ( p_addr_field IN VARCHAR2
                         , p_state IN VARCHAR2
                         , p_province IN VARCHAR2
                         , p_country IN VARCHAR2 )
   RETURN VARCHAR2
   IS
      -- cursor to return the char position of the state and province fields in the country's address style specification
      CURSOR get_posn(p_country IN VARCHAR2) IS
      SELECT NVL(INSTR(lvd.address_line_1||
                       lvd.address_line_2||
                       lvd.address_line_3||
                       lvd.address_line_4||
                       lvd.address_line_5||
                       lvd.address_line_6||
                       lvd.address_line_7||
                       lvd.address_line_8, '<STATE>'),0) state_posn
          ,  NVL(INSTR(lvd.address_line_1||
                       lvd.address_line_2||
                       lvd.address_line_3||
                       lvd.address_line_4||
                       lvd.address_line_5||
                       lvd.address_line_6||
                       lvd.address_line_7||
                       lvd.address_line_8, '<PROVINCE>'),0) province_posn
          FROM fnd_territories t
             , fnd_lookup_values lv
             , fnd_lookup_values_dfv lvd
          WHERE t.territory_code = p_country
            AND lv.lookup_type = 'ADDRESS_STYLE'
            AND lv.lookup_code = NVL(t.address_style,'US')
            AND lvd.row_id = lv.ROWID;

            posn get_posn%ROWTYPE;
            v_return VARCHAR2(250) := NULL;

   BEGIN
      -- get the position of state and province in the style, if they exist
      OPEN get_posn(p_country);
      FETCH get_posn INTO posn;

      -- if state and province do not exist in style, or are not relevant for this country and or requested address field, return null
      IF NOT get_posn%FOUND OR ( posn.state_posn = 0 AND posn.province_posn = 0 ) OR
         UPPER(p_addr_field) NOT IN ('LOCALITY', 'STATE', 'PROVINCE') OR
       ( p_country <> 'AU' AND ((UPPER(p_addr_field) = 'STATE' AND posn.state_posn = 0 ) OR (UPPER(p_addr_field) = 'PROVINCE' AND posn.province_posn = 0 ))) OR
       ( p_country IN ('US', 'CA', 'AU') AND UPPER(p_addr_field) = 'LOCALITY' ) OR ( p_country NOT IN ('US', 'CA', 'AU') AND UPPER(p_addr_field) <> 'LOCALITY' ) THEN

            v_return := NULL;

      ELSIF posn.state_posn > 0 AND posn.province_posn = 0 THEN
         v_return := RTRIM(LTRIM(p_state));

      ELSIF posn.province_posn > 0 AND posn.state_posn = 0 THEN
         v_return := RTRIM(LTRIM(p_province));

      ELSIF posn.state_posn < posn.province_posn THEN
         v_return := RTRIM(LTRIM(  RTRIM(LTRIM(p_state)) || ' ' || RTRIM(LTRIM(p_province))  ));

      ELSE
         v_return := RTRIM(LTRIM(  RTRIM(LTRIM(p_province)) || ' ' || RTRIM(LTRIM(p_state))  ));

      END IF;

      CLOSE get_posn;
      RETURN v_return;


      EXCEPTION WHEN OTHERS THEN
        CLOSE get_posn;
        RETURN NULL;

   END get_addr_val;


   FUNCTION get_ou_print_ctry(p_operating_unit NUMBER DEFAULT xxcm_common.get_curr_operating_unit)
     RETURN VARCHAR2 RESULT_CACHE IS

       CURSOR ou_country_cur IS
         Select asp.default_country
         From ar_system_parameters_all asp
         Where asp.org_id = p_operating_unit
           AND asp.print_home_country_flag = 'N';

       v_country hr_locations_all_v.country%TYPE;
   BEGIN
      OPEN ou_country_cur;
      FETCH ou_country_cur INTO v_country;
      CLOSE ou_country_cur;

      RETURN v_country;

   END get_ou_print_ctry;

   FUNCTION get_curr_operating_unit
     RETURN NUMBER IS
     v_operating_unit NUMBER;
   BEGIN

      v_operating_unit := nvl(mo_global.get_current_org_id,mo_utils.get_default_org_id);
      IF v_operating_unit IS NULL THEN
         select
            NVL (TO_NUMBER
                  ( DECODE ( SUBSTR(USERENV('CLIENT_INFO'),1,1),
                             ' ', NULL,
                             SUBSTR(USERENV('CLIENT_INFO'),1,10)
                           )
                  ),-99)
         into v_operating_unit
         from dual;
      END IF;

      RETURN v_operating_unit;
   END get_curr_operating_unit;

   PROCEDURE string2array (p_string VARCHAR2, p_delimiter VARCHAR2, p_out_array OUT string_tbl) IS
      cnt      NUMBER := 0;
      arr_element VARCHAR2(32000);
   BEGIN
      IF p_string IS NOT NULL THEN
         LOOP
           cnt := cnt + 1;
           arr_element := REGEXP_SUBSTR(p_string,'.*?'||p_delimiter, 1, cnt);

           IF arr_element IS NULL THEN
              -- Grab last element
              arr_element := SUBSTR(p_string,instr(p_string,p_delimiter,-1)+1);
              cnt := 0;
           ELSE
              arr_element := rtrim(arr_element,p_delimiter);
           END IF;

           p_out_array(p_out_array.count+1) := arr_element;
           EXIT when cnt = 0;
         END LOOP;
      END IF;
   END string2array;

   ----------------------------------------------------------------------
   -- set_process_id
   --   local procedure to set the process_id for insert_debug_msg
   ----------------------------------------------------------------------
   /*
   PROCEDURE set_process_id IS
   BEGIN
     select xxsp_debug_log_s.nextval
       into g_process_id
     from dual;

   END set_process_id;
  */
   ----------------------------------------------------------------------
   -- insert_debug_msg
   --   this procedure inserts a debug message and is designed to be a
   --   generic procedure to replace individual procedures in multiple
   --   packages
   ----------------------------------------------------------------------
   PROCEDURE insert_debug_msg(p_process_name VARCHAR2
                              ,p_message      VARCHAR2)
   IS
     PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN

     -- If debug is explicitly setup, it will have a value.
     -- If not, debugging should be controlled from outside this procedure
     /*
     IF g_process_id IS NULL THEN
       set_process_id;
     END IF;
    */
    /*
     insert into XXSP_DEBUG_LOG
       (process_id
       ,process_name
       ,message
       ,time_stamp
       ,created_by
       ,creation_date)
     VALUES
       (g_process_id
       ,p_process_name
       ,p_message
       ,systimestamp
       ,-1
       ,sysdate);

     commit;
     */
     null;
  END insert_debug_msg;

/*-------------------------------------------------------------------------------
     Function get_flex_value_id: based on flex_value_set and flex_value, lookup
     and return the id from fnd_flex_values table.  If p_enabled_only flag is set,
     only return id if enabled.
  -------------------------------------------------------------------------------*/

    FUNCTION get_flex_id(p_flex_value_set IN VARCHAR2
                     ,p_flex_value IN VARCHAR2
                     ,p_enabled_only IN VARCHAR2 DEFAULT 'N')
    RETURN NUMBER IS
        l_fv_id NUMBER := NULL;
    BEGIN

            SELECT
                fv.flex_value_id
            INTO
                l_fv_id
            FROM
                fnd_flex_values fv
               ,fnd_flex_value_sets fvs
            WHERE
                fv.flex_value_set_id = fvs.flex_value_set_id
                AND
                fvs.flex_value_set_name = p_flex_value_set
                AND
                fv.flex_value = p_flex_value
                AND
                (
                    NVL(p_enabled_only,'N') = 'N' OR
                       (NVL(fv.enabled_flag, 'Y') = 'Y' AND SYSDATE BETWEEN NVL(fv.start_date_active,SYSDATE) AND NVL(fv.end_date_active,SYSDATE))
                )
            ;
            RETURN l_fv_id;

            EXCEPTION WHEN OTHERS THEN
                RETURN NULL;

   END get_flex_id;

   PROCEDURE init_moac IS
      l_resp_id  NUMBER;
      l_app_name VARCHAR2(20);
   BEGIN
      l_resp_id    := fnd_profile.value('RESP_ID');

      select a.application_short_name
        into l_app_name
      from fnd_responsibility r
         , fnd_application a
      where a.application_id = r.application_id
        and r.responsibility_id = l_resp_id;

      -- Needs to be initialized to enable MOAC
      mo_global.init(l_app_name);

   END init_moac;

   FUNCTION get_org_name (p_org_id hr_organization_units.organization_id%TYPE)
     RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE IS

     v_org_name hr_organization_units.NAME%TYPE;

     CURSOR org_name_cur IS
        SELECT NAME
        FROM hr_organization_units
        WHERE organization_id = p_org_id;

   BEGIN
      OPEN org_name_cur;
      FETCH org_name_cur INTO v_org_name;
      CLOSE org_name_cur;

      RETURN v_org_name;
   END get_org_name;

   FUNCTION get_user_name (p_user_id fnd_user.user_id%TYPE)
     RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE IS

     v_user_name fnd_user.user_name%TYPE;

     CURSOR user_name_cur IS
        SELECT user_name
        FROM fnd_user
        WHERE user_id = p_user_id;

   BEGIN
      OPEN user_name_cur;
      FETCH user_name_cur INTO v_user_name;
      CLOSE user_name_cur;

      RETURN v_user_name;
   END get_user_name;

   FUNCTION get_business_unit_by_prod_type ( p_product_type VARCHAR2 )
      RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE
   IS

      v_business_unit VARCHAR2(10);
      CURSOR c_business IS
         SELECT xxcm_common.get_business_unit(pcode.attribute1)
         FROM pa_class_codes pcode
         WHERE pcode.class_category = xxcm_common.get_constant_value('XXBS_PRODUCT_TYPE')
           AND UPPER(pcode.class_code) = UPPER(p_product_type);

   BEGIN
      OPEN c_business;
      FETCH c_business INTO v_business_unit;
      CLOSE c_business;

      RETURN v_business_unit;
   END get_business_unit_by_prod_type;

   FUNCTION get_business_id_by_prod_type ( p_product_type VARCHAR2 )
      RETURN NUMBER RESULT_CACHE PARALLEL_ENABLE IS

      v_business_unit VARCHAR2(10);
      v_business_id   NUMBER;
   BEGIN
      v_business_unit := get_business_unit_by_prod_type(p_product_type);
      v_business_id := xxcm_common.get_flex_value_id(
                          xxcm_common.get_constant_value('XXBS_BUSINESS_SEGMENT_VALUES')
                        , v_business_unit);

      RETURN v_business_id;

   END get_business_id_by_prod_type;

   FUNCTION get_business_unit (p_product_line VARCHAR2)
      RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE IS

      v_business_unit VARCHAR2(10);
   BEGIN
      v_business_unit := xxcm_common.get_flex_value_field(
                               xxcm_common.get_constant_value('XXBS_PRODUCT_LINE_VALUES')
                             , p_product_line
                             , 'XXGL_BUSINESS_UNIT');

      RETURN v_business_unit;

   END get_business_unit;

   FUNCTION get_business_id (p_product_line VARCHAR2)
     RETURN NUMBER RESULT_CACHE PARALLEL_ENABLE IS
      v_business_unit   VARCHAR2(10);
      v_business_id     NUMBER;
   BEGIN
      v_business_unit := get_business_unit(p_product_line);

      v_business_id := xxcm_common.get_flex_value_id(
           xxcm_common.get_constant_value('XXBS_BUSINESS_SEGMENT_VALUES')
         , v_business_unit);

      RETURN v_business_id;

   END get_business_id;

   FUNCTION get_org_key (p_org_id hr_organization_units.organization_id%TYPE)
      RETURN VARCHAR2 RESULT_CACHE
   IS
      v_org_key VARCHAR2(10);
   BEGIN
      SELECT h.attribute2 operating_unit_key
         INTO v_org_key
      FROM hr_organization_information h
      WHERE h.org_information_context = 'Operating Unit Information'
        AND h.organization_iD = p_org_id;

      RETURN v_org_key;
   END get_org_key;

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
                                   p_web_plsql_url  OUT VARCHAR2)
   IS

      path_list dbms_epg.varchar2_table;
      v_framework_agent VARCHAR2(100) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

   BEGIN
      p_web_host := regexp_replace(v_framework_agent,'.*://(.*):.*','\1');
      p_web_port := substr(v_framework_agent,-4);

      select host_name into p_db_host from v$instance;

      IF INSTR(p_db_host,'.') = 0 THEN
        -- Extract web host instance name, and pre-pend db host name
        p_db_host := p_db_host || regexp_substr(p_web_host,'\..*');
      END IF;

      -- For now same as web tier port
      p_web_plsql_port := p_web_port;

      BEGIN -- This will fail if DAD not configured.
         dbms_epg.get_all_dad_mappings('XXCM_DAD', path_list);
         p_web_plsql_path :=substr(path_list(1),1,length(path_list(1))-2);
         p_web_plsql_url := 'http://' || p_db_host || ':' || p_web_plsql_port || p_web_plsql_path || '/';
      EXCEPTION
         WHEN OTHERS THEN
           p_web_plsql_path := NULL;
           p_web_plsql_url := NULL;
      END;

   EXCEPTION
      WHEN OTHERS
      THEN
         p_web_host := NULL;
         p_web_port := NULL;
   END get_web_plsql_values;

   ----------------------------------------------------------------------
   -- get_web_plsql_value
   --   Function to call to retrieve a single value needed to make
   --   web call.
   ----------------------------------------------------------------------
   FUNCTION get_web_plsql_value (p_web_name VARCHAR2) RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE
   IS

      v_return_val      VARCHAR2(200);
      v_web_host        VARCHAR2(50);
      v_web_port        VARCHAR2(10);
      v_db_host         VARCHAR2(50);
      v_web_plsql_port  VARCHAR2(10);
      v_web_plsql_path  VARCHAR2(50);
      v_web_plsql_URL   VARCHAR2(200);

   BEGIN

      get_web_plsql_values
            (v_web_host,
             v_web_port,
             v_db_host,
             v_web_plsql_port,
             v_web_plsql_path,
             v_web_plsql_url);


      IF p_web_name = 'WEB_HOST' THEN
         v_return_val := v_web_host;
      ELSIF p_web_name = 'WEB_PORT' THEN
         v_return_val := v_web_port;
      ELSIF p_web_name = 'DB_HOST' THEN
         v_return_val := v_db_host;
      ELSIF p_web_name = 'WEBPLSQL_PORT' THEN
         v_return_val := v_web_plsql_port;
      ELSIF p_web_name = 'WEBPLSQL_PATH' THEN
         v_return_val := v_web_plsql_path;
      ELSIF p_web_name = 'WEBPLSQL_URL' THEN
         v_return_val := v_web_plsql_URL;
      ELSIF p_web_name= 'WEB_ATTACH_URL' THEN
         v_return_val := 'http://' || v_web_host || ':' || v_web_port ||'/OA_HTML';
      ELSE
         v_return_val := NULL;
      END IF;

      RETURN v_return_val;

   EXCEPTION
      WHEN OTHERS THEN
         v_return_val := NULL;
         RETURN v_return_val;
   END get_web_plsql_value;

   FUNCTION get_utl_path ( p_directory VARCHAR2 )
      RETURN VARCHAR2 RESULT_CACHE
   IS
     v_utl_path all_directories.directory_path%TYPE;
   BEGIN
     SELECT directory_path
       INTO v_utl_path
     FROM all_directories
     WHERE directory_name = p_directory;

     RETURN v_utl_path;
   END get_utl_path;
FUNCTION get_trx_type_name (p_trx_type_id NUMBER)
     RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE IS

     v_trx_type_name ra_cust_trx_types.name%TYPE;

     CURSOR cur_trx_type (p_trx_type_id NUMBER)  IS
        SELECT name
        FROM ra_cust_trx_types_all
        WHERE cust_trx_type_id = p_trx_type_id;

   BEGIN
      OPEN cur_trx_type (p_trx_type_id);
      FETCH cur_trx_type INTO v_trx_type_name ;
      CLOSE cur_trx_type;

      RETURN  v_trx_type_name;
   END get_trx_type_name;

   FUNCTION get_trx_type (p_trx_type_id NUMBER)
     RETURN VARCHAR2 RESULT_CACHE PARALLEL_ENABLE IS

     v_trx_type ra_cust_trx_types.type%TYPE;

     CURSOR cur_trx_type (p_trx_type_id NUMBER)  IS
        SELECT type
        FROM ra_cust_trx_types_all
        WHERE cust_trx_type_id = p_trx_type_id;

   BEGIN
      OPEN cur_trx_type (p_trx_type_id);
      FETCH cur_trx_type INTO v_trx_type ;
      CLOSE cur_trx_type;

      RETURN  v_trx_type;
   END get_trx_type;

 FUNCTION get_sup_id (p_person_id IN NUMBER)
   RETURN NUMBER IS
         v_sup   NUMBER;
  CURSOR sup_cur  IS
      SELECT DISTINCT pa.supervisor_id
        FROM per_assignments_f pa
           , per_people_f f
      WHERE f.person_id = pa.person_id
      AND f.person_id =  p_person_id
      AND
         ( ( f.effective_start_date <= SYSDATE
            AND f.effective_end_date >= SYSDATE
            AND person_type_id = 6)
       OR (person_type_id = 9
             AND f.effective_start_date <= SYSDATE
             AND f.effective_end_date >= SYSDATE));

        BEGIN
           OPEN sup_cur;
           FETCH  sup_cur INTO v_sup;
           CLOSE sup_cur;

      RETURN v_sup;

   END get_sup_id;

   FUNCTION get_sup_email (p_person_id IN NUMBER)
   RETURN VARCHAR2 IS
         v_email  per_people_f.email_address%TYPE := NULL;
  CURSOR sup_cur  IS
      SELECT f.email_address
        FROM per_assignments_f pa
           , per_people_f f
      WHERE f.person_id = pa.person_id
      AND f.person_id = p_person_id
       AND f.effective_start_date <= SYSDATE
       AND f.effective_end_date >= SYSDATE
       AND person_type_id = 6;

        BEGIN
           OPEN sup_cur;
           FETCH  sup_cur INTO v_email;
           CLOSE sup_cur;

      RETURN v_email;

   END get_sup_email;

   FUNCTION get_sup_email (p_prep_person_id IN NUMBER,
                                         p_req_person_id  IN NUMBER,
                                         p_by_person_id IN NUMBER)
   RETURN VARCHAR2 IS
   v_notify_email  per_people_f.email_address%TYPE := NULL;

 BEGIN
   IF p_prep_person_id IS NOT NULL
   THEN
      v_notify_email := xxcm_common.get_sup_email (p_prep_person_id);

      IF v_notify_email IS NOT NULL
      THEN
         RETURN (v_notify_email);
      END IF;

      IF v_notify_email IS NULL
      THEN

         v_notify_email := xxcm_common.get_sup_email (p_req_person_id);

         IF v_notify_email IS NOT NULL
         THEN
            RETURN (v_notify_email);
         END IF;

         v_notify_email :=
            xxcm_common.get_sup_email (
               xxcm_common.get_sup_id (p_req_person_id));

         IF v_notify_email IS NOT NULL
         THEN
            RETURN (v_notify_email);
         END IF;

         v_notify_email := xxcm_common.get_sup_email (p_by_person_id);

         IF v_notify_email IS NOT NULL
         THEN
            RETURN (v_notify_email);
         END IF;

         v_notify_email :=
            xxcm_common.get_sup_email (
               xxcm_common.get_sup_id (p_by_person_id));

         IF v_notify_email IS NOT NULL
         THEN
            RETURN (v_notify_email);
         END IF;

         v_notify_email := xxcm_common.get_constant_value ('SOURCING_EMAIL');
         RETURN (v_notify_email);
      ELSE
         v_notify_email := xxcm_common.get_constant_value ('SOURCING_EMAIL');
         RETURN (v_notify_email);
      END IF;
   ELSE
      v_notify_email := xxcm_common.get_constant_value ('SOURCING_EMAIL');
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN (v_notify_email);
END get_sup_email;

FUNCTION get_currency_precision ( p_currency VARCHAR2 )
  RETURN NUMBER RESULT_CACHE PARALLEL_ENABLE
IS
   v_precision NUMBER;

   CURSOR currency_cur IS
      SELECT precision
      FROM fnd_currencies
      WHERE currency_code = p_currency;

BEGIN
   OPEN currency_cur;
   FETCH currency_cur INTO v_precision;
   CLOSE currency_cur;

   RETURN nvl(v_precision,2);

END get_currency_precision;

FUNCTION get_user_email (p_userid NUMBER DEFAULT fnd_global.user_id)
  RETURN VARCHAR2 RESULT_CACHE
IS
   v_email  fnd_user.email_address%TYPE;

   CURSOR email_cur IS
      SELECT email_address
      FROM fnd_user u
      WHERE user_id = p_userid;
BEGIN

   OPEN email_cur;
   FETCH email_cur INTO v_email;
   CLOSE email_cur;

   RETURN v_email;

END get_user_email;

FUNCTION currency_round( p_amount NUMBER, p_precision NUMBER, p_rule VARCHAR2 )
   RETURN NUMBER IS
BEGIN

   RETURN CASE UPPER(nvl(p_rule,'NEAREST'))
            WHEN 'DOWN' THEN trunc(p_amount, p_precision)
            WHEN 'UP'
               -- ceil does not handle precision,
               --    multiplying before doing ceil, and then dividing back to remove offending decimal places
               THEN ceil(p_amount * power(10,p_precision)) / power(10,p_precision)
            ELSE round(p_amount,  p_precision)
          END;

END currency_round;

/*
FUNCTION currency_round( p_amount NUMBER, p_currency VARCHAR2)
RETURN NUMBER PARALLEL_ENABLE IS

    v_precision      NUMBER := get_currency_precision(p_currency);
    v_rounding_rule  VARCHAR2(50);

    CURSOR round_rule_cur IS
      SELECT rounding_rule
      FROM fnd_currencies c
        JOIN fnd_currencies_dfv dfv ON dfv.row_id = c.rowid
      WHERE c.currency_code = p_currency;

BEGIN

   OPEN round_rule_cur;
   FETCH round_rule_cur INTO v_rounding_rule;
   CLOSE round_rule_cur;

   RETURN currency_round(p_amount, v_precision, v_rounding_rule);

END currency_round;
*/
FUNCTION get_org_hq ( p_org_id NUMBER ) RETURN VARCHAR2 IS

   out_hq VARCHAR2(5);

BEGIN
   SELECT nvl(h.attribute3,'US') hq
      INTO out_hq
   FROM hr_organization_information h
   WHERE h.org_information_context = 'Operating Unit Information'
     AND h.organization_id = p_org_id;

   RETURN out_hq;

END get_org_hq;

end xxcm_common;

/
