--------------------------------------------------------
--  DDL for Package Body XXAR_EXPANDED_AGING_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAR_EXPANDED_AGING_RPT" 
AS
/*********************************************************************************
**
**      MERRILL TECHNOLOGIES INDIA PRIVATE LIMITED
**
**********************************************************************************
**    File
**       XXAR_EXPANDED_AGING_RPT.sql
**       $HEADER VER.1.2 20170918$
**
**    MERRILL Information
**       VERSION       : 1.2
**       DATE CHANGED  :
**       DATE RETRIEVED:
**
**********************************************************************************
**
**  DESCRIPTION
**
**  Package Specification - This package is used for the report
**							"Expanded Aging - 7 Buckets Report - Merrill"
**
**********************************************************************************
**
**********************************************************************************
**  REVISION HISTORY:
**
**  Version      Author                  Date          Description
**  ---------    ---------------------   -----------   --------------------
**  1.0          Senthil Nathan          18-SEP-2017   CR Enhancement Request# 1904
**       									   		   Added Customer Name Parameter
**  1.1          DASH Kit Leung          08-MAR-2021   TM Oralce Spin - Sales Rep logic get from xxbs schema, rather than ar schema
**  1.2          DASH Kit Leung          05-MAY-2021   CR Enhancement Request 
                                                        1. Added new column 
                                                            primary sales split ,2nd salesrep, 2nd salesrep split,
                                                            3rd salesrep, 3rd salesrep split,4th salesrep, 
                                                            4th salesrep split, SOE_YN, CREDIT_LIMIT,STOCK_CODE
                                                        2. add 8 bucket    
                                                        3. get_records_tableau - Export record to Tableau
*********************************************************************************/

   FUNCTION get_records(p1    IN VARCHAR2 DEFAULT NULL -- p_reporting_level
                       ,p2    IN NUMBER DEFAULT NULL -- p_reporting_entity_id
                       ,p3    IN NUMBER DEFAULT NULL -- p_ca_set_of_books_id
                       ,p4    IN NUMBER DEFAULT NULL -- p_coaid
                       ,p5    IN NUMBER DEFAULT NULL  -- p_conc_request_id
                       ,p6    IN VARCHAR2 DEFAULT NULL -- p_in_as_of_date_low
                       ,p7    IN VARCHAR2 DEFAULT NULL -- p_in_bucket_type_low
                       ,p8    IN VARCHAR2 DEFAULT NULL -- p_credit_option
                       ,p9    IN VARCHAR2 DEFAULT NULL -- p_in_currency
                       ,p10   IN VARCHAR2 DEFAULT NULL -- p_risk_option
                  ,p11   IN VARCHAR2 DEFAULT NULL -- p_customer_name  Added as part of CR#1904
                  )
      RETURN xxar_expanded_aging_tbl
      PIPELINED
   IS
      p_reporting_level       VARCHAR2(30) := p1;
      p_reporting_entity_id   NUMBER := p2;
      p_ca_set_of_books_id    NUMBER := p3;
      p_coaid                 NUMBER := p4;
      p_in_as_of_date_low     VARCHAR2(30) := p6;
      p_in_bucket_type_low    VARCHAR2(30) := p7;
      p_credit_option         VARCHAR2(80) := p8;
      p_in_currency           VARCHAR2(20) := p9;
      p_risk_option           VARCHAR2(80) := p10;
     p_customer_name         VARCHAR2(240) := p11;

      bucket_category         VARCHAR2(30);
      bucket_line_type_0      VARCHAR2(30);
      bucket_days_from_0      NUMBER;
      bucket_days_to_0        NUMBER;
      bucket_line_type_1      VARCHAR2(30);
      bucket_days_from_1      NUMBER;
      bucket_days_to_1        NUMBER;
      bucket_line_type_2      VARCHAR2(30);
      bucket_days_from_2      NUMBER;
      bucket_days_to_2        NUMBER;
      bucket_line_type_3      VARCHAR2(30);
      bucket_days_from_3      NUMBER;
      bucket_days_to_3        NUMBER;
      bucket_line_type_4      VARCHAR2(30);
      bucket_days_from_4      NUMBER;
      bucket_days_to_4        NUMBER;
      bucket_line_type_5      VARCHAR2(30);
      bucket_days_from_5      NUMBER;
      bucket_days_to_5        NUMBER;
      bucket_line_type_6      VARCHAR2(30);
      bucket_days_from_6      NUMBER;
      bucket_days_to_6        NUMBER;
      --Dash Kit Leung - 05-MAY-2021
      bucket_line_type_7      VARCHAR2(30);
      bucket_days_from_7      NUMBER;
      bucket_days_to_7        NUMBER;
      -- END Dash Kit Leung - 05-MAY-2021  
      p_mrcsobtype            VARCHAR2(10);
      p_org_where_ps          VARCHAR2(2000);
      p_org_where_gld         VARCHAR2(2000);
      p_org_where_ct          VARCHAR2(2000);
      p_org_where_sales       VARCHAR2(2000);
      p_org_where_ct2         VARCHAR2(2000);
      p_org_where_adj         VARCHAR2(2000);
      p_org_where_app         VARCHAR2(2000);
      p_org_where_crh         VARCHAR2(2000);
      p_org_where_cr          VARCHAR2(2000);
      p_org_where_addr        VARCHAR2(2000);
      p_short_unid_phrase     VARCHAR2(40);
      lp_payment_meaning      VARCHAR2(80);
      lp_risk_meaning         VARCHAR2(80);
      as_of_date              VARCHAR2(30);

      functional_currency     VARCHAR2(20);
      c_convert_flag          VARCHAR2(20);

      common_query_inv        VARCHAR2(32767);
      l_loop_cnt              NUMBER;
      i                       INTEGER;

      PROCEDURE set_buckets(p_bucket_type          IN     VARCHAR2
                           ,p_bucket_category         OUT VARCHAR2
                           ,p_bucket_line_type_0      OUT VARCHAR2
                           ,p_bucket_days_from_0      OUT NUMBER
                           ,p_bucket_days_to_0        OUT NUMBER
                           ,p_bucket_line_type_1      OUT VARCHAR2
                           ,p_bucket_days_from_1      OUT NUMBER
                           ,p_bucket_days_to_1        OUT NUMBER
                           ,p_bucket_line_type_2      OUT VARCHAR2
                           ,p_bucket_days_from_2      OUT NUMBER
                           ,p_bucket_days_to_2        OUT NUMBER
                           ,p_bucket_line_type_3      OUT VARCHAR2
                           ,p_bucket_days_from_3      OUT NUMBER
                           ,p_bucket_days_to_3        OUT NUMBER
                           ,p_bucket_line_type_4      OUT VARCHAR2
                           ,p_bucket_days_from_4      OUT NUMBER
                           ,p_bucket_days_to_4        OUT NUMBER
                           ,p_bucket_line_type_5      OUT VARCHAR2
                           ,p_bucket_days_from_5      OUT NUMBER
                           ,p_bucket_days_to_5        OUT NUMBER
                           ,p_bucket_line_type_6      OUT VARCHAR2
                           ,p_bucket_days_from_6      OUT NUMBER
                           ,p_bucket_days_to_6        OUT NUMBER
                           --Dash Kit Leung - 05-MAY-2021
                           ,p_bucket_line_type_7      OUT VARCHAR2
                           ,p_bucket_days_from_7      OUT NUMBER
                           ,p_bucket_days_to_7        OUT NUMBER
                           --END Dash Kit Leung - 05-MAY-2021
                           )
      IS
         CURSOR buck_cur
         IS
              SELECT days_start, days_to, TYPE
                FROM ar_aging_bucket_lines lines, ar_aging_buckets buckets
               WHERE lines.aging_bucket_id = buckets.aging_bucket_id
                 AND UPPER(buckets.bucket_name) = UPPER(p_bucket_type)
                 AND NVL(buckets.status, 'A') = 'A'
            ORDER BY lines.bucket_sequence_num;

         i   NUMBER(1) := 0;
      BEGIN

         FOR buck_rec IN buck_cur LOOP

            IF i = 0 THEN
               p_bucket_line_type_0   := buck_rec.TYPE;
               p_bucket_days_from_0   := buck_rec.days_start;
               p_bucket_days_to_0     := buck_rec.days_to;
            END IF;

            IF i = 1 THEN
               p_bucket_line_type_1   := buck_rec.TYPE;
               p_bucket_days_from_1   := buck_rec.days_start;
               p_bucket_days_to_1     := buck_rec.days_to;
            END IF;

            IF i = 2 THEN
               p_bucket_line_type_2   := buck_rec.TYPE;
               p_bucket_days_from_2   := buck_rec.days_start;
               p_bucket_days_to_2     := buck_rec.days_to;
            END IF;

            IF i = 3 THEN
               p_bucket_line_type_3   := buck_rec.TYPE;
               p_bucket_days_from_3   := buck_rec.days_start;
               p_bucket_days_to_3     := buck_rec.days_to;
            END IF;

            IF i = 4 THEN
               p_bucket_line_type_4   := buck_rec.TYPE;
               p_bucket_days_from_4   := buck_rec.days_start;
               p_bucket_days_to_4     := buck_rec.days_to;
            END IF;

            IF i = 5 THEN
               p_bucket_line_type_5   := buck_rec.TYPE;
               p_bucket_days_from_5   := buck_rec.days_start;
               p_bucket_days_to_5     := buck_rec.days_to;
            END IF;

            IF i = 6 THEN
               p_bucket_line_type_6   := buck_rec.TYPE;
               p_bucket_days_from_6   := buck_rec.days_start;
               p_bucket_days_to_6     := buck_rec.days_to;
            END IF;

            --Dash Kit Leung - 05-MAY-2021
            IF i = 7 THEN
               p_bucket_line_type_7   := buck_rec.TYPE;
               p_bucket_days_from_7   := buck_rec.days_start;
               p_bucket_days_to_7     := buck_rec.days_to;
            END IF;            
            --END Dash Kit Leung - 05-MAY-2021

            IF (buck_rec.TYPE = 'DISPUTE_ONLY') OR (buck_rec.TYPE = 'PENDADJ_ONLY') OR (buck_rec.TYPE = 'DISPUTE_PENDADJ') THEN
               p_bucket_category   := buck_rec.TYPE;
            END IF;

            i   := i + 1;

         END LOOP;

      END set_buckets;

      FUNCTION build_invoice_select
         RETURN LONG
      IS
         l_inv_sel    LONG;

         l_inv_sel1   LONG;
         l_inv_sel2   LONG;
         l_inv_sel3   LONG;
         l_inv_sel4   LONG;
         l_inv_sel5   LONG;
      BEGIN
         ------------------------------------------------------------
         -- BUILD FIRST SELECT STATEMENT
         ------------------------------------------------------------
         l_inv_sel1      :=
            -- 'select substrb(party.party_name,1,50) customer_name, '				 -- Commented as part of CR#1904
            'select DISTINCT substrb(party.party_name,1,50) customer_name, '		 -- Added as part of CR#1904
            || '    cust_acct.account_number customer_number,';

            --Dash Kit Leung - 05-MAY-2021
            l_inv_sel1   := l_inv_sel1 || '    ps.org_id ORG_ID, '
            || '    cust_acct.cust_account_id CUST_ACCOUNT_ID, '
            || '    ps.customer_trx_id AR_CUSTOMER_TRX_ID, '
            || '    xxcm_common.get_org_name(ps.org_id) OPERATING_UNIT_NAME, '
            || '    cust_acct.attribute14 CREDIT_LIMIT, '
            || '    cust_acct.attribute11 STOCK_CODE, '
            || '    cust_acct.attribute19 SOE_YN, '
            || '    ps.gl_date GL_DATE,';

         --l_inv_sel1   := l_inv_sel1 || ' c.segment1 business_unit, ' || ' c.segment3 site,     ' || ' c.segment5 legal_entity,'; -- Merrill Custom --Commented for R12 COA Changes
         l_inv_sel1   := l_inv_sel1 || ' c.segment2 product_line, ' || ' c.segment3 site,     ' || ' c.segment1 legal_entity,';    -- Merrill Custom --Added for R12 COA Changes Replace BU with PL

         l_inv_sel1      :=
               l_inv_sel1
            --Dash Kit Leung - 05-MAY-2021
            --|| ' bill.primary_product_type_id primary_product_type, '
            --|| ' sales.name sales_rep, '
            || ' xxbs_trx_pkg.get_pri_product_type_name(bill.primary_product_type_id) primary_product_type, '
            || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,1,1) PRIMARY_SALESREP, '
            || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,1,2) PRIMARY_SALESREP_SPLIT, '
            || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,2,1) SALESREP_2ND, '
            || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,2,2) SALESREP_2ND_SPLIT, '
            || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,3,1) SALESREP_3RD, '
            || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,3,2) SALESREP_3RD_SPLIT, '
            || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,4,1) SALESREP_4TH, '
            || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,4,2) SALESREP_4TH_SPLIT, '
            || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,5,1) SALESREP_5TH, '
            || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,5,2) SALESREP_5TH_SPLIT, '            
            || ' xxbs_trx_pkg.get_username(bill.active_biller_id) ACTIVE_BILLER, '
            || ' terms.name payment_terms,';
         --Dash Kit Leung - 08-MAR-2021
         /*
         l_inv_sel1      :=
               l_inv_sel1               
            || ' rct_c.interface_header_attribute13 collection_status, '
            || ' rct_c.interface_header_attribute14 collection_stage1_date, '
            || ' rct_c.interface_header_attribute15 collection_stage2_date,'; -- Merrill Custom
         */
         --End Dash Kit Leung - 08-MAR-2021

         l_inv_sel1      :=
               l_inv_sel1
            || ' ps.trx_number invoice_number, '
            || ' arpt_sql_func_util.get_org_trx_type_details(ps.cust_trx_type_id,ps.org_id) invoice_type, '
            --Dash Kit Leung
            --|| ' bill.trx_date invoice_date, '
            || ' ps.trx_date invoice_date, '
            || ' ps.due_date ,'
            --Dash Kit Leung
            --|| ' bill.description bill_trx_descr, '
            || ' ps.project_name bill_trx_descr, '
            || ' NVL(ps.exchange_rate,1) exchange_rate, ';

         l_inv_sel1   := l_inv_sel1 || '''' || functional_currency || ''','; -- Merrill Custom


         l_inv_sel1      :=
               l_inv_sel1
            || ' amt_due_remaining_inv amount_due, '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_0
            || ''','
            || ' dh.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_0
            || ','
            || bucket_days_to_0
            || ','
            || ' ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0,amt_due_remaining_inv) current_due, '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_1
            || ''','
            || '  dh.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_1
            || ','
            || bucket_days_to_1
            || ','
            || '  ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0,amt_due_remaining_inv) past_due30,'
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_2
            || ''','
            || ' dh.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_2
            || ','
            || bucket_days_to_2
            || ','
            || '  ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0,amt_due_remaining_inv) past_due60, '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_3
            || ''','
            || ' dh.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_3
            || ','
            || bucket_days_to_3
            || ','
            || '  ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0,amt_due_remaining_inv) past_due90, '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_4
            || ''','
            || ' dh.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_4
            || ','
            || bucket_days_to_4
            || ','
            || '  ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0,amt_due_remaining_inv) past_due120, '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_5
            || ''','
            || ' dh.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_5
            || ','
            || bucket_days_to_5
            || ','
            || '  ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0,amt_due_remaining_inv) past_due180, '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_6
            || ''','
            || ' dh.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_6
            || ','
            || bucket_days_to_6
            || ','
            || '  ps.due_date, '''
            || bucket_category
            || ''',to_Date('''
            || as_of_date
            || ''')),0,0,amt_due_remaining_inv) past_due360, ';

            --Dash Kit Leung - 05-MAY-2021
            if bucket_line_type_7 is not null then
                l_inv_sel1 := l_inv_sel1
                || ' DECODE(arpt_sql_func_util.bucket_function('''
                || bucket_line_type_7
                || ''','
                || ' dh.amount_in_dispute,ps.amount_adjusted_pending, '
                || bucket_days_from_7
                || ','
                || bucket_days_to_7
                || ','
                || '  ps.due_date, '''
                || bucket_category
                || ''',to_Date('''
                || as_of_date
                || ''')),0,0,amt_due_remaining_inv) past_dueover360,';
            else
                l_inv_sel1 := l_inv_sel1 || ' 0 past_dueover361,';
            end if;
            --Dash Kit Leung - 05-MAY-2021

         l_inv_sel1      :=
               l_inv_sel1
            || ' ps.invoice_currency_code invoice_currency, '
            || ' (amt_due_remaining_inv / NVL(ps.exchange_rate,1)) amount_due_invoice_currency'; -- Merrill Custom


         IF UPPER(p_mrcsobtype) = 'R' THEN
            l_inv_sel1   := l_inv_sel1 || ' from hz_cust_accounts cust_acct, ' || '     hz_parties party, ';

            /*Bug 3487101 : Incorporated the logic of COMP_AMT_DUE_REM_INVFORMULA() in the main query itself */
            l_inv_sel1      :=
                  l_inv_sel1
               || '(select a.customer_id,'
               || '     a.customer_site_use_id ,'
               || '     a.customer_trx_id,'
               || '     a.payment_schedule_id,'
               || '     a.class ,'
               || '     sum(a.primary_salesrep_id) primary_salesrep_id,'
               || '     a.trx_date ,' --Dash Kit Leung - 08-MAR-2021
               || '     a.due_date ,'
               || '     sum(a.amount_due_remaining) amt_due_remaining_inv,'
               || '     a.trx_number,'
               || '     a.amount_adjusted,'
               || '     a.amount_applied ,'
               || '     a.amount_credited ,'
               || '     a.amount_adjusted_pending,'
               || '     a.acctd_amount_due_remaining, '
               || '     a.gl_date ,'
               || '     a.cust_trx_type_id,'
               || '     a.org_id,'
               || '     a.invoice_currency_code,'
               || '     a.exchange_rate,'
               || '     sum(a.cons_inv_id) cons_inv_id,'
               || '     a.project_name' --Dash Kit Leung - 08-MAR-2021
               || '  from'
               || '   (  select'
               || ' ps.customer_id,'
               || ' ps.customer_site_use_id ,'
               || ' ps.customer_trx_id,'
               || ' ps.payment_schedule_id,'
               || ' ps.class ,'
               || ' 0 primary_salesrep_id,'
               || ' ps.trx_date ,' --Dash Kit Leung - 08-MAR-2021
               || ' ps.due_date ,'
               || ' nvl(sum ( decode( '''
               ||                            c_convert_flag
               ||                            ''', ''Y'','
               || '                          nvl(adj.acctd_amount, 0),'
               || '                          adj.amount )'
               || '                       ),0) * (-1)  amount_due_remaining,'
               || ' ps.trx_number,'
               || ' ps.amount_adjusted ,'
               || ' ps.amount_applied ,'
               || ' ps.amount_credited ,'
               || ' ps.amount_adjusted_pending,'
               || ' ps.acctd_amount_due_remaining,'
               || ' ps.gl_date,'
               || ' ps.cust_trx_type_id,'
               || ' ps.org_id,'
               || ' ps.invoice_currency_code,'
               || ' nvl(ps.exchange_rate,1) exchange_rate,'
               || ' 0 cons_inv_id,'
               || ' '''' project_name' --Dash Kit Leung - 08-MAR-2021
               || '   from ar_payment_schedules_all_mrc_v ps,'
               || '            ar_adjustments_all_mrc_v adj'
               || '      where  ps.gl_date <= '''
               || as_of_date
               || ''''
               || '        and ps.customer_id > 0'
               || '        and ('''
               || p_credit_option
               || ''' != ''NONE'''
               || '         or   ((ps.class != ''PMT'''
               || '         and    ps.class != ''CM'''
               || '         and    ps.class != ''CLAIM'')'
               || '         and   '''
               || p_credit_option
               || ''' = ''NONE''))'
               || '       and  ps.gl_date_closed  > '''
               || as_of_date
               || ''''
               || '       and  decode(upper('''
               || p_in_currency
               || '''),NULL, ps.invoice_currency_code,'
               || '                 upper('''
               || p_in_currency
               || ''')) = ps.invoice_currency_code'
               || '       and  adj.payment_schedule_id = ps.payment_schedule_id'
               || '       and  adj.status = ''A'''
               || '       and  adj.gl_date > '''
               || as_of_date
               || '''';

            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_ps, ':p_reporting_entity_id', p_reporting_entity_id);
            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_adj, ':p_reporting_entity_id', p_reporting_entity_id);
            l_inv_sel1      :=
                  l_inv_sel1
               || 'group by '
               || '      ps.customer_id,'
               || '         ps.customer_site_use_id ,'
               || '         ps.customer_trx_id,'
               || '         ps.class ,'
               || '         ps.trx_date,' --Dash Kit Leung - 08-MAR-2021
               || '         ps.due_date,'
               || '         ps.trx_number,'
               || '         ps.amount_adjusted ,'
               || '         ps.amount_applied ,'
               || '         ps.amount_credited ,'
               || '         ps.amount_adjusted_pending,'
               || '         ps.acctd_amount_due_remaining,'
               || '         ps.gl_date ,'
               || '         ps.cust_trx_type_id,'
               || '         ps.org_id,'
               || '         ps.invoice_currency_code,'
               || '         nvl(ps.exchange_rate,1),'
               || '         ps.payment_schedule_id'
               || '   UNION ALL'
               || '      select  ps.customer_id,'
               || '         ps.customer_site_use_id ,'
               || '         ps.customer_trx_id,'
               || '         ps.payment_schedule_id,'
               || '         ps.class ,'
               || '         0 primary_salesrep_id,'
               || '         ps.trx_date  ,' --Dash Kit Leung - 08-MAR-2021
               || '         ps.due_date  ,'
               || '         nvl(sum ( decode'
               || '                      ( '''
               || c_convert_flag
               || ''', ''Y'','
               || '                (decode(ps.class, ''CM'','
               || '                   decode ( app.application_type, ''CM'','
               || '                        app.acctd_amount_applied_from,'
               || '                                            app.acctd_amount_applied_to'
               || '                       ),'
               || '                   app.acctd_amount_applied_to)+'
               || '                          nvl(app.acctd_earned_discount_taken,0) +'
               || '                          nvl(app.acctd_unearned_discount_taken,0))'
               || '                ,'
               || '                        ( app.amount_applied +'
               || '                          nvl(app.earned_discount_taken,0) +'
               || '                          nvl(app.unearned_discount_taken,0) )'
               || '              ) *'
               || '              decode'
               || '                      ( ps.class, ''CM'','
               || '                         decode(app.application_type, ''CM'', -1, 1), 1 )'
               || '                   ), 0) amount_due_remaining_inv,'
               || '         ps.trx_number ,'
               || '         ps.amount_adjusted,'
               || '         ps.amount_applied ,'
               || '         ps.amount_credited ,'
               || '         ps.amount_adjusted_pending,'
               || '         ps.acctd_amount_due_remaining,'
               || '         ps.gl_date gl_date_inv,'
               || '         ps.cust_trx_type_id,'
               || '         ps.org_id,'
               || '         ps.invoice_currency_code,'
               || '         nvl(ps.exchange_rate, 1) exchange_rate,'
               || '         0 cons_inv_id,'
               || '         '''' project_name' --Dash Kit Leung - 08-MAR-2021
               || '      from  ar_payment_schedules_all_mrc_v ps,'
               || '            ar_receivable_apps_mrc_v app'
               || '      where  ps.gl_date <= '''
               || as_of_date
               || ''''
               || '        and ('''
               || p_credit_option
               || ''' != ''NONE'''
               || '         or   ((ps.class != ''PMT'''
               || '         and    ps.class != ''CM'''
               || '         and    ps.class != ''CLAIM'')'
               || '         and   '''
               || p_credit_option
               || ''' = ''NONE''))'
               || '       and   ps.customer_id > 0'
               || '       and   ps.gl_date_closed  > '''
               || as_of_date
               || ''''
               || '       and   decode(upper('''
               || p_in_currency
               || '''),NULL, ps.invoice_currency_code,'
               || '                 upper('''
               || p_in_currency
               || ''')) = ps.invoice_currency_code'
               || '       and   (app.applied_payment_schedule_id = ps.payment_schedule_id'
               || '                   OR'
               || '         app.payment_schedule_id = ps.payment_schedule_id)'
               || '       and   app.status = ''APP'''
               || '       and   nvl( app.confirmed_flag, ''Y'' ) = ''Y'''
               || '       and   app.gl_date > '''
               || as_of_date
               || '''';

            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_ps, ':p_reporting_entity_id', p_reporting_entity_id);
            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_app, ':p_reporting_entity_id', p_reporting_entity_id);
            l_inv_sel1      :=
                  l_inv_sel1
               || 'group by '
               || '     ps.customer_id,'
               || '         ps.customer_site_use_id ,'
               || '         ps.customer_trx_id,'
               || '         ps.class ,'
               || '         ps.trx_date,' --Dash Kit Leung - 08-MAR-2021
               || '         ps.due_date,'
               || '         ps.trx_number,'
               || '         ps.amount_adjusted ,'
               || '         ps.amount_applied ,'
               || '         ps.amount_credited ,'
               || '         ps.amount_adjusted_pending,'
               || '         ps.acctd_amount_due_remaining,'
               || '         ps.gl_date ,'
               || '         ps.cust_trx_type_id,'
               || '         ps.org_id,'
               || '         ps.invoice_currency_code,'
               || '         nvl(ps.exchange_rate, 1),'
               || '         ps.payment_schedule_id'
               || '   UNION ALL'
               || '      select  ps.customer_id,'
               || '         ps.customer_site_use_id ,'
               || '         ps.customer_trx_id,'
               || '         ps.payment_schedule_id,'
               || '         ps.class class_inv,'
               || '         nvl(ct.primary_salesrep_id, -3) primary_salesrep_id,'
               || '         ps.trx_date  ,' --Dash Kit Leung - 08-MAR-2021
               || '         ps.due_date  due_date_inv,'
               || '         decode( '''
               || c_convert_flag
               || ''', ''Y'','
               || '                 ps.acctd_amount_due_remaining,'
               || '                 ps.amount_due_remaining) amt_due_remaining_inv,'
               || '         ps.trx_number,'
               || '         ps.amount_adjusted ,'
               || '         ps.amount_applied ,'
               || '         ps.amount_credited ,'
               || '         ps.amount_adjusted_pending,'
               || '         ps.acctd_amount_due_remaining,'
               || '         ps.gl_date ,'
               || '         ps.cust_trx_type_id,'
               || '         ps.org_id,'
               || '         ps.invoice_currency_code,'
               || '         nvl(ps.exchange_rate, 1) exchange_rate,'
               || '         ps.cons_inv_id,'
               || '         '''' project_name' --Dash Kit Leung - 08-MAR-2021
               || '      from  ar_payment_schedules_all_mrc_v ps,'
               || '            ra_customer_trx_all_mrc_v ct'
               || '      where  ps.gl_date <= '''
               || as_of_date
               || ''''
               || '        and ('''
               || p_credit_option
               || ''' != ''NONE'''
               || '         or   ((ps.class != ''PMT'''
               || '         and    ps.class != ''CM'''
               || '         and    ps.class != ''CLAIM'')'
               || '         and   '''
               || p_credit_option
               || ''' = ''NONE''))'
               || '        and ps.customer_id > 0'
               || '       and   ps.gl_date_closed  > '''
               || as_of_date
               || ''''
               || '       and   decode(upper('''
               || p_in_currency
               || '''),NULL, ps.invoice_currency_code,'
               || '                 upper('''
               || p_in_currency
               || ''')) = ps.invoice_currency_code'
               || '       and  ps.customer_trx_id = ct.customer_trx_id';

            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_ps, ':p_reporting_entity_id', p_reporting_entity_id);
            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_ct, ':p_reporting_entity_id', p_reporting_entity_id);

            l_inv_sel1      :=
                  l_inv_sel1
               || ' ) a '
               || '   group by a.customer_id,'
               || '         a.customer_site_use_id ,'
               || '         a.customer_trx_id,'
               || '         a.payment_schedule_id,'
               || '         a.class ,'
               || '         a.trx_date ,' --Dash Kit Leung - 08-MAR-2021              
               || '         a.due_date ,'
               || '         a.trx_number,'
               || '         a.amount_adjusted,'
               || '         a.amount_applied ,'
               || '         a.amount_credited ,'
               || '         a.amount_adjusted_pending,'
               || '         a.acctd_amount_due_remaining,'
               || '         a.gl_date ,'
               || '         a.cust_trx_type_id,'
               || '         a.org_id,'
               || '         a.invoice_currency_code,'
               || '         a.exchange_rate, '
               || '         a.project_name) ps, ' --Dash Kit Leung - 08-MAR-2021
               ;


         ELSE
            l_inv_sel1   := l_inv_sel1 || ' from hz_cust_accounts cust_acct,' || '     hz_parties party, ';

            /*Bug 3487101 : Incorporated the logic of COMP_AMT_DUE_REM_INVFORMULA() in the main query itself */
            l_inv_sel1      :=
                  l_inv_sel1
               || '(select a.customer_id,'
               || '         a.customer_site_use_id ,'
               || '         a.customer_trx_id,'
               || '         a.payment_schedule_id,'
               || '         a.class ,'
               || '         sum(a.primary_salesrep_id) primary_salesrep_id,'
               || '         a.trx_date ,'  --Dash Kit Leung - 08-MAR-2021             
               || '         a.due_date ,'
               || '         sum(a.amount_due_remaining) amt_due_remaining_inv,'
               || '         a.trx_number,'
               || '         a.amount_adjusted,'
               || '         a.amount_applied ,'
               || '         a.amount_credited ,'
               || '         a.amount_adjusted_pending,'
               || '         a.acctd_amount_due_remaining,'
               || '         a.gl_date ,'
               || '         a.cust_trx_type_id,'
               || '         a.org_id,'
               || '         a.invoice_currency_code,'
               || '         a.exchange_rate,'
               || '         sum(a.cons_inv_id) cons_inv_id,'
               || '         a.project_name' --Dash Kit Leung - 08-MAR-2021
               || '   from'
               || '   (  select'
               || '         ps.customer_id,'
               || '         ps.customer_site_use_id ,'
               || '         ps.customer_trx_id,'
               || '         ps.payment_schedule_id,'
               || '         ps.class ,'
               || '         0 primary_salesrep_id,'
               || '         ps.trx_date ,' --Dash Kit Leung - 08-MAR-2021              
               || '         ps.due_date ,'
               || '         nvl(sum ( decode('''
               || c_convert_flag
               || ''', ''Y'','
               || '                         nvl(adj.acctd_amount, 0),'
               || '                         adj.amount )'
               || '                      ),0) * (-1)  amount_due_remaining,'
               || '         ps.trx_number,'
               || '         ps.amount_adjusted ,'
               || '         ps.amount_applied ,'
               || '         ps.amount_credited ,'
               || '         ps.amount_adjusted_pending,'
               || '         ps.acctd_amount_due_remaining,'
               || '         ps.gl_date ,'
               || '         ps.cust_trx_type_id,'
               || '         ps.org_id,'
               || '         ps.invoice_currency_code,'
               || '         nvl(ps.exchange_rate,1) exchange_rate,'
               || '         0 cons_inv_id,'
               || '         '''' project_name' --Dash Kit Leung - 08-MAR-2021
               || '      from  ar_payment_schedules ps,'
               || '            ar_adjustments       adj'
               || '      where  ps.gl_date <= '''
               || as_of_date
               || ''''
               || '        and ('''
               || p_credit_option
               || ''' != ''NONE'''
               || '         or   ((ps.class != ''PMT'''
               || '         and    ps.class != ''CM'''
               || '         and    ps.class != ''CLAIM'')'
               || '         and   '''
               || p_credit_option
               || ''' = ''NONE''))'
               || '        and ps.customer_id > 0'
               || '       and  ps.gl_date_closed  >'''
               || as_of_date
               || ''''
               || '       and  decode(upper('''
               || p_in_currency
               || '''),NULL, ps.invoice_currency_code,'
               || '                 upper('''
               || p_in_currency
               || ''')) = ps.invoice_currency_code'
               || '       and  adj.payment_schedule_id = ps.payment_schedule_id'
               || '       and  adj.status = ''A'''
               || '       and  adj.gl_date > '''
               || as_of_date
               || '''';

            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_ps, ':p_reporting_entity_id', p_reporting_entity_id);
            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_adj, ':p_reporting_entity_id', p_reporting_entity_id);

            l_inv_sel1      :=
                  l_inv_sel1
               || 'group by '
               || '      ps.customer_id,'
               || '         ps.customer_site_use_id ,'
               || '         ps.customer_trx_id,'
               || '         ps.class ,'
               || '         ps.trx_date,' --Dash Kit Leung - 08-MAR-2021
               || '         ps.due_date,'
               || '         ps.trx_number,'
               || '         ps.amount_adjusted ,'
               || '         ps.amount_applied ,'
               || '         ps.amount_credited ,'
               || '         ps.amount_adjusted_pending,'
               || '         ps.acctd_amount_due_remaining,'
               || '         ps.gl_date ,'
               || '         ps.cust_trx_type_id,'
               || '         ps.org_id,'
               || '         ps.invoice_currency_code,'
               || '         nvl(ps.exchange_rate,1),'
               || '         ps.payment_schedule_id'
               || '   UNION ALL'
               || '      select  ps.customer_id,'
               || '         ps.customer_site_use_id ,'
               || '         ps.customer_trx_id,'
               || '         ps.payment_schedule_id,'
               || '         ps.class ,'
               || '         0 primary_salesrep_id,'
               || '         ps.trx_date  ,' --Dash Kit Leung - 08-MAR-2021
               || '         ps.due_date  ,'
               || '         nvl(sum ( decode'
               || '                      ( '''
               || c_convert_flag
               || ''', ''Y'','
               || '                (decode(ps.class, ''CM'','
               || '                   decode ( app.application_type, ''CM'','
               || '                        app.acctd_amount_applied_from,'
               || '                                            app.acctd_amount_applied_to'
               || '                       ),'
               || '                   app.acctd_amount_applied_to)+'
               || '                          nvl(app.acctd_earned_discount_taken,0) +'
               || '                          nvl(app.acctd_unearned_discount_taken,0))'
               || '                ,'
               || '                        ( app.amount_applied +'
               || '                          nvl(app.earned_discount_taken,0) +'
               || '                          nvl(app.unearned_discount_taken,0) )'
               || '              ) *'
               || '              decode'
               || '                      ( ps.class, ''CM'','
               || '                         decode(app.application_type, ''CM'', -1, 1), 1 )'
               || '                   ), 0) amount_due_remaining_inv, '
               || '         ps.trx_number ,'
               || '         ps.amount_adjusted,'
               || '         ps.amount_applied ,'
               || '         ps.amount_credited ,'
               || '         ps.amount_adjusted_pending,'
               || '         ps.acctd_amount_due_remaining,'
               || '         ps.gl_date gl_date_inv,'
               || '         ps.cust_trx_type_id,'
               || '         ps.org_id,'
               || '         ps.invoice_currency_code,'
               || '         nvl(ps.exchange_rate, 1) exchange_rate,'
               || '         0 cons_inv_id,'
               || '         '''' project_name'
               || '      from  ar_payment_schedules        ps,'
               || '            ar_receivable_applications  app'
               || '      where  ps.gl_date <='''
               || as_of_date
               || ''''
               || '        and ('''
               || p_credit_option
               || ''' != ''NONE'''
               || '         or   ((ps.class != ''PMT'''
               || '         and    ps.class != ''CM'''
               || '         and    ps.class != ''CLAIM'')'
               || '         and   '''
               || p_credit_option
               || ''' = ''NONE''))'
               || '       and   ps.customer_id > 0'
               || '       and   ps.gl_date_closed  > '''
               || as_of_date
               || ''''
               || '       and   decode(upper('''
               || p_in_currency
               || '''),NULL, ps.invoice_currency_code,'
               || '                 upper('''
               || p_in_currency
               || ''')) = ps.invoice_currency_code'
               || '       and  (app.applied_payment_schedule_id = ps.payment_schedule_id'
               || '               OR'
               || '         app.payment_schedule_id = ps.payment_schedule_id)'
               || '       and   app.status = ''APP'''
               || '       and   nvl( app.confirmed_flag, ''Y'' ) = ''Y'''
               || '       and   app.gl_date > '''
               || as_of_date
               || '''';

            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_ps, ':p_reporting_entity_id', p_reporting_entity_id);
            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_app, ':p_reporting_entity_id', p_reporting_entity_id);
            l_inv_sel1      :=
                  l_inv_sel1
               || 'group by'
               || '     ps.customer_id,'
               || '         ps.customer_site_use_id ,'
               || '         ps.customer_trx_id,'
               || '         ps.class ,'
               || '         ps.trx_date,' --Dash Kit Leung - 08-MAR-2021
               || '         ps.due_date,'
               || '         ps.trx_number,'
               || '         ps.amount_adjusted ,'
               || '         ps.amount_applied ,'
               || '         ps.amount_credited ,'
               || '         ps.amount_adjusted_pending,'
               || '         ps.acctd_amount_due_remaining,'
               || '         ps.gl_date ,'
               || '         ps.cust_trx_type_id,'
               || '         ps.org_id,'
               || '         ps.invoice_currency_code,'
               || '         nvl(ps.exchange_rate, 1),'
               || '         ps.payment_schedule_id'
               || '   UNION ALL'
               || '      select  ps.customer_id,'
               || '         ps.customer_site_use_id ,'
               || '         ps.customer_trx_id,'
               || '         ps.payment_schedule_id,'
               || '         ps.class class_inv,'
               || '         nvl(ct.primary_salesrep_id, -3) primary_salesrep_id,'
               || '         ps.trx_date,' --Dash Kit Leung - 08-MAR-2021              
               || '         ps.due_date  due_date_inv,'
               || '         decode( '''
               || c_convert_flag
               || ''', ''Y'','
               || '                 ps.acctd_amount_due_remaining,'
               || '                 ps.amount_due_remaining) amt_due_remaining_inv,'
               || '         ps.trx_number,'
               || '         ps.amount_adjusted ,'
               || '         ps.amount_applied ,'
               || '         ps.amount_credited ,'
               || '         ps.amount_adjusted_pending,'
               || '         ps.acctd_amount_due_remaining,'
               || '         ps.gl_date ,'
               || '         ps.cust_trx_type_id,'
               || '         ps.org_id,'
               || '         ps.invoice_currency_code,'
               || '         nvl(ps.exchange_rate, 1) exchange_rate,'
               || '         ps.cons_inv_id,'
               --Dash Kit Leung - 08-MAR-2021
               || '         case when ct.interface_header_context = ''TM CONVERSION'' then (ct.interface_header_attribute5) when ct.interface_header_context = ''XXBS BILLING INVOICES'' then (select long_name from pa_projects_all where project_id = ct.interface_header_attribute2) else null end project_name'
               || '      from  ar_payment_schedules  ps,'
               || '            ra_customer_trx       ct'
               || '      where  ps.gl_date <= '''
               || as_of_date
               || ''''
               || --   '  and ps.customer_id > 0' ||
                  '       and   ps.gl_date_closed  > '''
               || as_of_date
               || ''''
               || '        and ('''
               || p_credit_option
               || ''' != ''NONE'''
               || '         or   ((ps.class != ''PMT'''
               || '         and    ps.class != ''CM'''
               || '         and    ps.class != ''CLAIM'')'
               || '         and   '''
               || p_credit_option
               || ''' = ''NONE''))'
               || '       and   decode(upper('''
               || p_in_currency
               || '''),NULL, ps.invoice_currency_code,'
               || '                 upper('''
               || p_in_currency
               || ''')) = ps.invoice_currency_code'
               || '       and  ps.customer_trx_id = ct.customer_trx_id';

            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_ps, ':p_reporting_entity_id', p_reporting_entity_id);
            l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_ct, ':p_reporting_entity_id', p_reporting_entity_id);

            l_inv_sel1      :=
                  l_inv_sel1
               || ' ) a '
               || '   group by a.customer_id,'
               || '         a.customer_site_use_id ,'
               || '         a.customer_trx_id,'
               || '         a.payment_schedule_id,'
               || '         a.class ,'
               || '         a.trx_date ,' --Dash Kit Leung - 08-MAR-2021
               || '         a.due_date ,'
               || '         a.trx_number,'
               || '         a.amount_adjusted,'
               || '         a.amount_applied ,'
               || '         a.amount_credited ,'
               || '         a.amount_adjusted_pending,'
               || '         a.acctd_amount_due_remaining,'
               || '         a.gl_date ,'
               || '         a.cust_trx_type_id,'
               || '         a.org_id,'
               || '         a.invoice_currency_code,'
               || '         a.exchange_rate, '
               || '         a.project_name) ps, ' --Dash Kit Leung - 08-MAR-2021
               ;

         END IF;

         l_inv_sel1      :=
               l_inv_sel1
            || '   ra_customer_trx    rct_c, '
            || '    ra_terms_tl terms,  '
            --Dash Kit Leung - 08-MAR-2021
            /*
            || '   (SELECT rep.org_id, rep.salesrep_id, ext.resource_name name '
            || '    FROM jtf_rs_salesreps rep'
            || '    JOIN jtf_rs_resource_extns_tl ext on ( ext.resource_id = rep.resource_id )) sales, '
            */
            --End Dash Kit Leung - 08-MAR-2021
            || '    xxbs_customer_trx bill, ';

         IF UPPER(p_mrcsobtype) = 'R' THEN
            l_inv_sel1      :=
                  l_inv_sel1
               || '      hz_cust_site_uses     site,'
               || '      hz_cust_acct_sites    acct_site,'
               || '      hz_party_sites        party_site,'
               || '      hz_locations          loc,'
               || '      ra_trx_line_gl_dist_all_mrc_v gld,'
               || '      ar_dispute_history    dh,'
               || '      gl_code_combinations   c ';
         ELSE
            l_inv_sel1      :=
                  l_inv_sel1
               || '      hz_cust_site_uses      site,'
               || '      hz_cust_acct_sites     acct_site,'
               || '      hz_party_sites         party_site,'
               || '      hz_locations loc,'
               || '      ra_cust_trx_line_gl_dist  gld,'
               || '      ar_dispute_history dh,'
               || '      gl_code_combinations c ';

         END IF;

         l_inv_sel1      :=
               l_inv_sel1
            || ' where ps.customer_site_use_id = site.site_use_id'
            || ' and   site.cust_acct_site_id = acct_site.cust_acct_site_id'
            || ' and   acct_site.party_site_id = party_site.party_site_id'
            || ' and   loc.location_id = party_site.location_id'
            || ' and   gld.account_class = ''REC'''
            || ' and   gld.latest_rec_flag = ''Y'''
            || ' and   gld.code_combination_id = c.code_combination_id'
            || ' and   ps.payment_schedule_id  =  dh. payment_schedule_id(+)'
            || ' and  '''
            || as_of_date
            || ''' >= nvl(dh.start_date(+), to_date('''
            || as_of_date
            || '''))'
            || ' and  '''
            || as_of_date
            || ''' <  nvl(dh.end_date(+), to_date('''
            || as_of_date
            || ''') + 1)'
            || ' and   cust_acct.party_id = party.party_id ';

         l_inv_sel1      :=
               l_inv_sel1
            || ' and ps.customer_trx_id+0 = rct_c.customer_trx_id '
            || ' and rct_c.term_id+0 = terms.term_id (+) '
            --Dash Kit Leung - 08-MAR-2021
            --|| ' and rct_c.primary_salesrep_id+0 = sales.salesrep_id (+) '            
            --End Dash Kit Leung - 08-MAR-2021
            || ' and rct_c.trx_number = bill.ar_trx_number(+)'; -- Merrill custom

         l_inv_sel1      :=
               l_inv_sel1
            || ' and ps.customer_id = cust_acct.cust_account_id '
            || ' and ps.customer_trx_id = gld.customer_trx_id '
            || ' and ps.amt_due_remaining_inv <> 0 ';

         /* Added as part of CR#1904 */

         IF p_customer_name IS NOT NULL THEN

         l_inv_sel1 := l_inv_sel1 || ' AND party.party_name LIKE '||''''||p_customer_name||'%'||'''';

         END IF;

         /* End for CR#1904 */

         -- Bug 3487101 :
         -- l_inv_sel1 := l_inv_sel1 || p_org_where_ps;

         l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_gld, ':p_reporting_entity_id', p_reporting_entity_id);
         l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_addr, ':p_reporting_entity_id', p_reporting_entity_id);
         l_inv_sel1   := l_inv_sel1 || REPLACE( p_org_where_sales, ':p_reporting_entity_id', p_reporting_entity_id);

         l_inv_sel    := l_inv_sel1;

         -----------------------------------------------------------------
         -- BUILD SELECT #3
         -----------------------------------------------------------------

         /* Bug 2551346: Performance Issue, added following Hint */

         l_inv_sel3      :=
            -- 'select /*+ LEADING(ps) */ '						-- Commented as part of CR#1904
            'select DISTINCT /*+ LEADING(ps) */ ' 			-- Added as part of CR#1904
            || '  substrb(nvl(party.party_name,'''
            || p_short_unid_phrase
            || '''),1,50) ,'
            || ' cust_acct.account_number,';

        --Dash Kit Leung - 05-MAY-2021
        l_inv_sel3   := l_inv_sel3 || '    ps.org_id ORG_ID, '
        || '    cust_acct.cust_account_id CUST_ACCOUNT_ID, '
        || '    ps.customer_trx_id AR_CUSTOMER_TRX_ID, '
        || '    xxcm_common.get_org_name(ps.org_id) OPERATING_UNIT_NAME, '
        || '    cust_acct.attribute14 CREDIT_LIMIT, '
        || '    cust_acct.attribute11 STOCK_CODE, '
        || '    cust_acct.attribute19 SOE_YN, '
        || '    ps.gl_date GL_DATE,';
        --END Dash Kit Leung - 05-MAY-2021

         --l_inv_sel3   := l_inv_sel3 || ' c.segment1, ' || ' c.segment3, ' || ' c.segment5,'; -- Merrill Custom --Commented for R12 COA Changes
         l_inv_sel3   := l_inv_sel3 || ' c.segment2, ' || ' c.segment3, ' || ' c.segment1,'; -- Merrill Custom  --Added for R12 COA Changes BU Replaced with PL

        --Dash Kit Leung - 05-MAY-2021
        -- l_inv_sel3   := l_inv_sel3 || ' NULL, ' || ' NULL, ' || ' NULL,';
        l_inv_sel3   := l_inv_sel3 || ' NULL, ' || ' NULL, ' || ' NULL,'|| ' NULL, ' || ' NULL, ' || ' NULL,'|| ' NULL, ' || ' NULL, ' || ' NULL,'|| ' NULL, ' || ' NULL,'|| ' NULL, ' || ' NULL,';

         --Dash Kit Leung - 08-MAR-2021
         --l_inv_sel3   := l_inv_sel3 || ' NULL, ' || ' NULL, ' || ' NULL,'; -- Merrill Custom

         l_inv_sel3      :=
               l_inv_sel3
            || ' ps.trx_number,  '
            || ' initcap('''
            || lp_payment_meaning
            || '''),   '
            || ' ps.trx_date, '
            || ' ps.due_date, '
            || ' NULL,'
            || ' NVL(ps.exchange_rate,1), ';

         l_inv_sel3   := l_inv_sel3 || '''' || functional_currency || ''','; -- Merrill Custom

         l_inv_sel3      :=
               l_inv_sel3
            || ' decode'
            || '              ( '''
            || c_convert_flag
            || ''', ''Y'', nvl(-sum(app.acctd_amount_applied_from),0),'
            || '                nvl(-sum(app.amount_applied),0)),'
            || '         DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_0
            || ''','
            || '                   ps.amount_in_dispute,ps.amount_adjusted_pending,'
            || bucket_days_from_0
            || ','
            || bucket_days_to_0
            || ','
            || '                    ps.due_date,'''
            || bucket_category
            || ''', to_date('''
            || as_of_date
            || ''')),0,0,'
            || ' decode'
            || ' ( '''
            || c_convert_flag
            || ''', ''Y'', nvl(-sum(app.acctd_amount_applied_from),0),'
            || '   nvl(-sum(app.amount_applied),0))),'
            || '         DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_1
            || ''','
            || '                   ps.amount_in_dispute,ps.amount_adjusted_pending,'
            || bucket_days_from_1
            || ','
            || bucket_days_to_1
            || ','
            || '                    ps.due_date,'''
            || bucket_category
            || ''', to_date('''
            || as_of_date
            || ''')),0,0,'
            || ' decode'
            || ' ( '''
            || c_convert_flag
            || ''', ''Y'', nvl(-sum(app.acctd_amount_applied_from),0),'
            || '   nvl(-sum(app.amount_applied),0))),'
            || '         DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_2
            || ''','
            || '                   ps.amount_in_dispute,ps.amount_adjusted_pending,'
            || bucket_days_from_2
            || ','
            || bucket_days_to_2
            || ','
            || '                    ps.due_date,'''
            || bucket_category
            || ''', to_date('''
            || as_of_date
            || ''')),0,0,'
            || ' decode'
            || ' ( '''
            || c_convert_flag
            || ''', ''Y'', nvl(-sum(app.acctd_amount_applied_from),0),'
            || '   nvl(-sum(app.amount_applied),0))),'
            || '         DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_3
            || ''','
            || '                   ps.amount_in_dispute,ps.amount_adjusted_pending,'
            || bucket_days_from_3
            || ','
            || bucket_days_to_3
            || ','
            || '                    ps.due_date,'''
            || bucket_category
            || ''', to_date('''
            || as_of_date
            || ''')),0,0,'
            || ' decode'
            || ' ( '''
            || c_convert_flag
            || ''', ''Y'', nvl(-sum(app.acctd_amount_applied_from),0),'
            || '   nvl(-sum(app.amount_applied),0))),'
            || '         DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_4
            || ''','
            || '                   ps.amount_in_dispute,ps.amount_adjusted_pending,'
            || bucket_days_from_4
            || ','
            || bucket_days_to_4
            || ','
            || '                    ps.due_date,'''
            || bucket_category
            || ''', to_date('''
            || as_of_date
            || ''')),0,0,'
            || ' decode'
            || ' ( '''
            || c_convert_flag
            || ''', ''Y'', nvl(-sum(app.acctd_amount_applied_from),0),'
            || '   nvl(-sum(app.amount_applied),0))),'
            || '         DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_5
            || ''','
            || '                   ps.amount_in_dispute,ps.amount_adjusted_pending,'
            || bucket_days_from_5
            || ','
            || bucket_days_to_5
            || ','
            || '                    ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0,'
            || ' decode'
            || ' ( '''
            || c_convert_flag
            || ''', ''Y'', nvl(-sum(app.acctd_amount_applied_from),0),'
            || '   nvl(-sum(app.amount_applied),0))),'
            || '         DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_6
            || ''','
            || '                   ps.amount_in_dispute,ps.amount_adjusted_pending,'
            || bucket_days_from_6
            || ','
            || bucket_days_to_6
            || ','
            || '                    ps.due_date,'''
            || bucket_category
            || ''', to_date('''
            || as_of_date
            || ''')),0,0,'
            || ' decode'
            || ' ( '''
            || c_convert_flag
            || ''', ''Y'', nvl(-sum(app.acctd_amount_applied_from),0),'
            || '   nvl(-sum(app.amount_applied),0))) ,';

            --Dash Kit Leung - 05-MAY-2021
            if bucket_line_type_7 is not null then
                l_inv_sel3 := l_inv_sel3
                || '         DECODE(arpt_sql_func_util.bucket_function('''
                || bucket_line_type_7
                || ''','
                || '                   ps.amount_in_dispute,ps.amount_adjusted_pending,'
                || bucket_days_from_7
                || ','
                || bucket_days_to_7
                || ','
                || '                    ps.due_date,'''
                || bucket_category
                || ''', to_date('''
                || as_of_date
                || ''')),0,0,'
                || ' decode'
                || ' ( '''
                || c_convert_flag
                || ''', ''Y'', nvl(-sum(app.acctd_amount_applied_from),0),'
                || '   nvl(-sum(app.amount_applied),0))),';                
            else
                l_inv_sel3 := l_inv_sel3 || ' 0, ';
            end if;
            --END Dash Kit Leung - 05-MAY-2021



         l_inv_sel3      :=
               l_inv_sel3
            || ' ps.invoice_currency_code, '
            || ' (decode( '''
            || c_convert_flag
            || ''', ''Y'', nvl(-sum(app.acctd_amount_applied_from),0),'
            || '     nvl(-sum(app.amount_applied),0)) / NVL(ps.exchange_rate,1))';

         IF UPPER(p_mrcsobtype) = 'R' THEN
            l_inv_sel3      :=
                  l_inv_sel3
               || ' from  hz_cust_accounts cust_acct, '
               || '       hz_parties party, '
               || '       ar_payment_schedules_all_mrc_v ps,';
         ELSE
            l_inv_sel3      :=
                  l_inv_sel3
               || ' from  hz_cust_accounts cust_acct, '
               || '       hz_parties party, '
               || '       ar_payment_schedules  ps,';
         END IF;

         IF UPPER(p_mrcsobtype) = 'R' THEN
            l_inv_sel3      :=
                  l_inv_sel3
               || '      hz_cust_site_uses     site, '
               || '      hz_cust_acct_sites    acct_site, '
               || '      hz_party_sites        party_site, '
               || '      hz_locations          loc, '
               || '      ar_receivable_apps_all_mrc_v app, '
               || '      gl_code_combinations    c';
         ELSE
            l_inv_sel3      :=
                  l_inv_sel3
               || '      hz_cust_site_uses     site, '
               || '      hz_cust_acct_sites    acct_site, '
               || '      hz_party_sites        party_site, '
               || '      hz_locations          loc, '
               || '      ar_receivable_applications app, '
               || '      gl_code_combinations    c';
         END IF;

         l_inv_sel3      :=
               l_inv_sel3
            || ' where    app.gl_date <= to_date('''
            || as_of_date
            || ''') '
            || '   and ('''
            || p_credit_option
            || ''' != ''NONE'''
            || '    or   ((ps.class != ''PMT'''
            || '   and    ps.class != ''CM'''
            || '   and    ps.class != ''CLAIM'')'
            || '   and   '''
            || p_credit_option
            || ''' = ''NONE''))'
            || '   and    ps.trx_number is not null '
            || '   and    ps.customer_id = cust_acct.cust_account_id(+) '
            || '   and    cust_acct.party_id = party.party_id (+) '
            || '   and    ps.cash_receipt_id = app.cash_receipt_id '
            || '   and    app.code_combination_id = c.code_combination_id '
            || '   and    app.status in ( ''ACC'', ''UNAPP'', ''UNID'',''OTHER ACC'') '
            || '   and    nvl(app.confirmed_flag, ''Y'') = ''Y''';

         l_inv_sel3      :=
               l_inv_sel3
            || '   and    ps.customer_site_use_id = site.site_use_id(+) '
            || '   and    site.cust_acct_site_id = acct_site.cust_acct_site_id(+) '
            || '   and    acct_site.party_site_id = party_site.party_site_id(+) '
            || '   and    loc.location_id(+) = party_site.location_id '
            || '   and    ps.gl_date_closed  > to_date('''
            || as_of_date
            || ''') '
            || '   and    ((app.reversal_gl_date is not null AND '
            || '            ps.gl_date <= to_date('''
            || as_of_date
            || ''')) '
            || '           OR '
            || '           app.reversal_gl_date is null ) '
            || '   and    decode(upper('''
            || p_in_currency
            || '''), NULL, ps.invoice_currency_code, '
            || '          upper('''
            || p_in_currency
            || ''')) = ps.invoice_currency_code '
            || '   and    nvl( ps.receipt_confirmed_flag, ''Y'' ) = ''Y'' ';

         /* Added as part of CR#1904 */

         IF p_customer_name IS NOT NULL THEN

         l_inv_sel3 := l_inv_sel3 || ' AND party.party_name LIKE '||''''||p_customer_name||'%'||'''';

         END IF;

         /* End for CR#1904 */

         l_inv_sel3   := l_inv_sel3 || REPLACE( p_org_where_ps, ':p_reporting_entity_id', p_reporting_entity_id);
         l_inv_sel3   := l_inv_sel3 || REPLACE( p_org_where_app, ':p_reporting_entity_id', p_reporting_entity_id);
         l_inv_sel3   := l_inv_sel3 || REPLACE( p_org_where_addr, ':p_reporting_entity_id', p_reporting_entity_id);

         l_inv_sel3      :=
               l_inv_sel3
            || ' GROUP BY party.party_name, '
            || ' cust_acct.account_number, '
            --Dash Kit Leung - 05-MAY-2021
            || ' ps.org_id, '
            || ' cust_acct.cust_account_id, '
            || ' ps.customer_trx_id, '
            || ' xxcm_common.get_org_name(ps.org_id), '
            || ' cust_acct.attribute14, '
            || ' cust_acct.attribute11, '
            || ' cust_acct.attribute19, '
            || ' ps.gl_date, '            
            --END Dash Kit Leung - 05-MAY-2021
            || ' ps.trx_date, '
            || ' ps.due_date, '
            || ' ps.trx_number, '
            || ' NVL(ps.exchange_rate,1), '
            || ' NVL(ps.acctd_amount_due_remaining, ps.amount_due_remaining), '
            || ' ps.invoice_currency_code, '
            || ' ps.amount_in_dispute, '
            || ' ps.amount_adjusted_pending,';

         --l_inv_sel3 := l_inv_sel3 || :lp_acct_flex_bal_seg || ',';
         --l_inv_sel3   := l_inv_sel3 || ' c.segment1,'; --Commented for R12 Upgrade COA Changes
         l_inv_sel3   := l_inv_sel3 || ' c.segment2,'; --Added for R12 Upgrade COA Changes
         l_inv_sel3   := l_inv_sel3 || ' c.segment3,'; -- Merrill Custom
         --l_inv_sel3   := l_inv_sel3 || ' c.segment5,'; -- Merrill Custom --Commented for R12 Upgrade COA Changes
         l_inv_sel3   := l_inv_sel3 || ' c.segment1,'; -- Merrill Custom --Added for R12 Upgrade COA Changes
         l_inv_sel3   := l_inv_sel3 || ' ps.invoice_currency_code,'; -- Merrill Custom
         l_inv_sel3   := l_inv_sel3 || '''' || functional_currency || ''','; -- Merrill Custom
         l_inv_sel3   := l_inv_sel3 || ' initcap(''' || lp_payment_meaning || ''')';
         l_inv_sel3      :=
               l_inv_sel3
            || ' HAVING decode( '''
            || c_convert_flag
            || ''', ''Y'', nvl(-sum(app.acctd_amount_applied_from),0),'
            || '                nvl(-sum(app.amount_applied),0))  <> 0 ';



         l_inv_sel    := l_inv_sel || 'UNION ALL ' || l_inv_sel3;

         -----------------------------------------------------------------
         -- BUILD SELECT #4
         -----------------------------------------------------------------

         l_inv_sel4      :=
             -- 'select substrb(nvl(party.party_name, '''				-- Commented as part of CR#1904
             'select DISTINCT substrb(nvl(party.party_name, '''		-- Added as part of CR#1904
            || p_short_unid_phrase
            || '''),1,50) ,'
            || '    cust_acct.account_number,';

        --Dash Kit Leung - 05-MAY-2021
        l_inv_sel4   := l_inv_sel4 || '    ps.org_id ORG_ID, '
        || '    cust_acct.cust_account_id CUST_ACCOUNT_ID, '
        || '    ps.customer_trx_id AR_CUSTOMER_TRX_ID, '
        || '    xxcm_common.get_org_name(ps.org_id) OPERATING_UNIT_NAME, '
        || '    cust_acct.attribute14 CREDIT_LIMIT, '
        || '    cust_acct.attribute11 STOCK_CODE, '
        || '    cust_acct.attribute19 SOE_YN, '
        || '    ps.gl_date GL_DATE,';            


         --l_inv_sel4   := l_inv_sel4 || ' c.segment1, ' || ' c.segment3, ' || ' c.segment5,'; -- Merrill Custom --Commented for R12 Upgrade COA Changes
         l_inv_sel4   := l_inv_sel4 || ' c.segment2, ' || ' c.segment3, ' || ' c.segment1,'; -- Merrill Custom --Added for R12 Upgrade COA Changes

        --Dash Kit Leung - 05-MAY-2021
        -- l_inv_sel4   := l_inv_sel4 || ' NULL, ' || ' NULL, ' || ' NULL,';
        l_inv_sel4   := l_inv_sel4 || ' NULL, ' || ' NULL, ' || ' NULL,'|| ' NULL, ' || ' NULL, ' || ' NULL,'|| ' NULL, ' || ' NULL, ' || ' NULL,'|| ' NULL, ' || ' NULL,'|| ' NULL, ' || ' NULL,';

         --Dash Kit Leung - 08-MAR-2021
         --l_inv_sel4   := l_inv_sel4 || ' NULL,' || ' NULL,' || ' NULL,'; -- Merrill Custom

         l_inv_sel4      :=
               l_inv_sel4
            || ' ps.trx_number,'
            || ' initcap('''
            || lp_risk_meaning
            || '''),'
            || ' ps.trx_date, '
            || ' ps.due_date,'
            || ' NULL, '
            || ' NVL(ps.exchange_rate,1), ';


         l_inv_sel4   := l_inv_sel4 || '''' || functional_currency || ''','; -- Merrill Custom

         l_inv_sel4      :=
               l_inv_sel4
            || ' decode( '''
            || c_convert_flag
            || ''', ''Y'', crh.acctd_amount, crh.amount), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_0
            || ''', '
            || '0,0,'
            || bucket_days_from_0
            || ','
            || bucket_days_to_0
            || ', '
            || 'ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || ' decode( '''
            || c_convert_flag
            || ''', ''Y'', crh.acctd_amount, crh.amount)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_1
            || ''', '
            || '           0,0,'
            || bucket_days_from_1
            || ','
            || bucket_days_to_1
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || ' decode( '''
            || c_convert_flag
            || ''', ''Y'', crh.acctd_amount, crh.amount)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_2
            || ''', '
            || '           0,0,'
            || bucket_days_from_2
            || ','
            || bucket_days_to_2
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || ' decode( '''
            || c_convert_flag
            || ''', ''Y'', crh.acctd_amount, crh.amount)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_3
            || ''', '
            || '           0,0,'
            || bucket_days_from_3
            || ','
            || bucket_days_to_3
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || ' decode( '''
            || c_convert_flag
            || ''', ''Y'', crh.acctd_amount, crh.amount)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_4
            || ''', '
            || '           0,0,'
            || bucket_days_from_4
            || ','
            || bucket_days_to_4
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || ' decode( '''
            || c_convert_flag
            || ''', ''Y'', crh.acctd_amount, crh.amount)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_5
            || ''', '
            || '           0,0,'
            || bucket_days_from_5
            || ','
            || bucket_days_to_5
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || ' decode( '''
            || c_convert_flag
            || ''', ''Y'', crh.acctd_amount, crh.amount)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_6
            || ''', '
            || '           0,0,'
            || bucket_days_from_6
            || ','
            || bucket_days_to_6
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0,'
            || ' decode( '''
            || c_convert_flag
            || ''', ''Y'', crh.acctd_amount, crh.amount)), ';

            --Dash Kit Leung - 05-MAY-2021
            if bucket_line_type_7 is not null then
                l_inv_sel4 := l_inv_sel4
                || ' DECODE(arpt_sql_func_util.bucket_function('''
                || bucket_line_type_7
                || ''', '
                || '           0,0,'
                || bucket_days_from_7
                || ','
                || bucket_days_to_7
                || ', '
                || '            ps.due_date,'''
                || bucket_category
                || ''',to_date('''
                || as_of_date
                || ''')),0,0,'
                || ' decode( '''
                || c_convert_flag
                || ''', ''Y'', crh.acctd_amount, crh.amount)), ';
            else
                l_inv_sel4 := l_inv_sel4 || ' 0, ';
            end if;
            --END Dash Kit Leung - 05-MAY-2021


         l_inv_sel4      :=
               l_inv_sel4
            || ' ps.invoice_currency_code, '
            || ' (decode( '''
            || c_convert_flag
            || ''', ''Y'', crh.acctd_amount, crh.amount) / NVL(ps.exchange_rate,1))';

         IF UPPER(p_mrcsobtype) = 'R' THEN
            l_inv_sel4      :=
                  l_inv_sel4
               || ' from   hz_cust_accounts cust_acct, '
               || '        hz_parties party, '
               || '        ar_payment_schedules_all_mrc_v ps,';
         ELSE
            l_inv_sel4      :=
                  l_inv_sel4
               || ' from   hz_cust_accounts cust_acct, '
               || '        hz_parties        party, '
               || '        ar_payment_schedules ps,';
         END IF;


         IF UPPER(p_mrcsobtype) = 'R' THEN
            l_inv_sel4      :=
                  l_inv_sel4
               || '   hz_cust_site_uses  site, '
               || '   hz_cust_acct_sites acct_site, '
               || '   hz_party_sites     party_site, '
               || '   hz_locations       loc, '
               || '   ar_cash_receipts_all_mrc_v cr, '
               || '   ar_cash_receipt_hist_all_mrc_v crh, '
               || '   gl_code_combinations c';
         ELSE
            l_inv_sel4      :=
                  l_inv_sel4
               || '   hz_cust_site_uses   site, '
               || '   hz_cust_acct_sites  acct_site, '
               || '   hz_party_sites      party_site, '
               || '   hz_locations        loc, '
               || '   ar_cash_receipts    cr, '
               || '   ar_cash_receipt_history crh, '
               || '   gl_code_combinations c';
         END IF;

         l_inv_sel4      :=
               l_inv_sel4
            || ' where  crh.gl_date <= to_date('''
            || as_of_date
            || ''') '
            || ' and    ps.trx_number is not null '
            || ' and    upper('''
            || p_risk_option
            || ''') != ''NONE'' '
            || ' and    ps.customer_id = cust_acct.cust_account_id(+) '
            || ' and    cust_acct.party_id = party.party_id(+) '
            || ' and    ps.cash_receipt_id = cr.cash_receipt_id '
            || ' and    cr.cash_receipt_id = crh.cash_receipt_id '
            || ' and    crh.account_code_combination_id = c.code_combination_id '
            || ' and    ps.customer_site_use_id = site.site_use_id(+) '
            || ' and    site.cust_acct_site_id = acct_site.cust_acct_site_id(+) '
            || ' and    acct_site.party_site_id = party_site.party_site_id(+) '
            || ' and    loc.location_id(+) = party_site.location_id '
            || ' and    decode(upper('''
            || p_in_currency
            || '''), NULL, ps.invoice_currency_code, '
            || '             upper('''
            || p_in_currency
            || ''')) = ps.invoice_currency_code '
            || ' and (  crh.current_record_flag = ''Y'' '
            || '        or crh.reversal_gl_date > to_date('''
            || as_of_date
            || ''') ) '
            || ' and    crh.status not in ( decode(crh.factor_flag, '
            || '                                     ''Y'',''RISK_ELIMINATED'', '
            || '                                     ''N'',''CLEARED''), '
            || '                                           ''REVERSED'') '
            || ' and   decode( '''
            || c_convert_flag
            || ''', ''Y'', crh.acctd_amount, crh.amount) <> 0  ';

         /* Added as part of CR#1904 */

         IF p_customer_name IS NOT NULL THEN

         l_inv_sel4 := l_inv_sel4 || ' AND party.party_name LIKE '||''''||p_customer_name||'%'||'''';

         END IF;

         /* End for CR#1904 */

         l_inv_sel4   := l_inv_sel4 || REPLACE( p_org_where_ps, ':p_reporting_entity_id', p_reporting_entity_id);
         l_inv_sel4   := l_inv_sel4 || REPLACE( p_org_where_crh, ':p_reporting_entity_id', p_reporting_entity_id);
         l_inv_sel4   := l_inv_sel4 || REPLACE( p_org_where_cr, ':p_reporting_entity_id', p_reporting_entity_id);
         l_inv_sel4   := l_inv_sel4 || REPLACE( p_org_where_addr, ':p_reporting_entity_id', p_reporting_entity_id);

         l_inv_sel    := l_inv_sel || ' UNION ALL ' || l_inv_sel4;

         -----------------------------------------------------------------
         -- BUILD SELECT #5
         -----------------------------------------------------------------

     -- l_inv_sel5   := 'select substrb(party.party_name,1,50) , ' || '       cust_acct.account_number,';				-- Commented as part of CR#1904
         l_inv_sel5   := 'select DISTINCT substrb(party.party_name,1,50) , ' || '       cust_acct.account_number,';		-- Added as part of CR#1904

        --Dash Kit Leung - 05-MAY-2021
        l_inv_sel5   := l_inv_sel5 || '    ps.org_id ORG_ID, '
        || '    cust_acct.cust_account_id CUST_ACCOUNT_ID, '
        || '    ps.customer_trx_id AR_CUSTOMER_TRX_ID, '
        || '    xxcm_common.get_org_name(ps.org_id) OPERATING_UNIT_NAME, '
        || '    cust_acct.attribute14 CREDIT_LIMIT, '
        || '    cust_acct.attribute11 STOCK_CODE, '
        || '    cust_acct.attribute19 SOE_YN, '
        || '    ps.gl_date GL_DATE,';

         --l_inv_sel5   := l_inv_sel5 || ' c.segment1, ' || ' c.segment3, ' || ' c.segment5,'; -- Merrill Custom --Commented for R12 Upgrade COA Changes
         l_inv_sel5   := l_inv_sel5 || ' c.segment2, ' || ' c.segment3, ' || ' c.segment1,'; -- Merrill Custom   --Added for R12 Upgrade COA Changes

        --Dash Kit Leung - 05-MAY-2021
         --l_inv_sel5   := l_inv_sel5 || ' bill.primary_product_type_id, ' 
         --|| ' sales.name, '
         --|| ' terms.name,';
        l_inv_sel5   := l_inv_sel5 || ' xxbs_trx_pkg.get_pri_product_type_name(bill.primary_product_type_id), ' 
        || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,1,1) PRIMARY_SALESREP, '
        || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,1,2) PRIMARY_SALESREP_SPLIT, '
        || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,2,1) SALESREP_2ND, '
        || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,2,2) SALESREP_2ND_SPLIT, '
        || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,3,1) SALESREP_3RD, '
        || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,3,2) SALESREP_3RD_SPLIT, '
        || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,4,1) SALESREP_4TH, '
        || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,4,2) SALESREP_4TH_SPLIT, '
        || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,5,1) SALESREP_5TH, '
        || ' xxbs_trx_pkg.get_salesrep_by_trx(ps.org_id,ps.trx_number,5,2) SALESREP_5TH_SPLIT, '
        || ' xxbs_trx_pkg.get_username(bill.active_biller_id) ACTIVE_BILLER, '
        || ' terms.name,';
        --END Dash Kit Leung - 05-MAY-2021

         --Dash Kit Leung - 08-MAR-2021
         /*
         l_inv_sel5      :=
               l_inv_sel5
            || ' rct_c.interface_header_attribute13, '
            || ' rct_c.interface_header_attribute14, '
            || ' rct_c.interface_header_attribute15,'; -- Merrill Custom
         */   
         --End Dash Kit Leung - 08-MAR-2021

         l_inv_sel5      :=
               l_inv_sel5
            || ' ps.trx_number,  '
            || ' arpt_sql_func_util.get_org_trx_type_details(ps.cust_trx_type_id,ps.org_id), '
            || ' ps.trx_date, '
            || ' ps.due_date ,'
            || ' bill.description, '
            || ' ps.exchange_rate, ';

         l_inv_sel5   := l_inv_sel5 || '''' || functional_currency || ''','; -- Merrill Custom

         l_inv_sel5      :=
               l_inv_sel5
            || ' decode( '''
            || c_convert_flag
            || ''', ''Y'', '
            || '            ps.acctd_amount_due_remaining, '
            || '            ps.amount_due_remaining), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_0
            || ''', '
            || '           ps.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_0
            || ','
            || bucket_days_to_0
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || '           decode( '''
            || c_convert_flag
            || ''', ''Y'', '
            || '            ps.acctd_amount_due_remaining, '
            || '            ps.amount_due_remaining)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_1
            || ''', '
            || '           ps.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_1
            || ','
            || bucket_days_to_1
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || '           decode( '''
            || c_convert_flag
            || ''', ''Y'', '
            || '            ps.acctd_amount_due_remaining, '
            || '            ps.amount_due_remaining)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_2
            || ''', '
            || '           ps.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_2
            || ','
            || bucket_days_to_2
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || '           decode( '''
            || c_convert_flag
            || ''', ''Y'', '
            || '            ps.acctd_amount_due_remaining, '
            || '            ps.amount_due_remaining)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_3
            || ''', '
            || '           ps.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_3
            || ','
            || bucket_days_to_3
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || '           decode( '''
            || c_convert_flag
            || ''', ''Y'', '
            || '            ps.acctd_amount_due_remaining, '
            || '            ps.amount_due_remaining)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_4
            || ''', '
            || '           ps.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_4
            || ','
            || bucket_days_to_4
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || '           decode( '''
            || c_convert_flag
            || ''', ''Y'', '
            || '            ps.acctd_amount_due_remaining, '
            || '            ps.amount_due_remaining)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_5
            || ''', '
            || '           ps.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_5
            || ','
            || bucket_days_to_5
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0, '
            || '           decode( '''
            || c_convert_flag
            || ''', ''Y'', '
            || '            ps.acctd_amount_due_remaining, '
            || '            ps.amount_due_remaining)), '
            || ' DECODE(arpt_sql_func_util.bucket_function('''
            || bucket_line_type_6
            || ''', '
            || '           ps.amount_in_dispute,ps.amount_adjusted_pending, '
            || bucket_days_from_6
            || ','
            || bucket_days_to_6
            || ', '
            || '            ps.due_date,'''
            || bucket_category
            || ''',to_date('''
            || as_of_date
            || ''')),0,0,'
            || '           decode( '''
            || c_convert_flag
            || ''', ''Y'', '
            || '            ps.acctd_amount_due_remaining, '
            || '            ps.amount_due_remaining)), ';

            --Dash Kit Leung - 05-MAY-2021
            if bucket_line_type_7 is not null then
                l_inv_sel5 := l_inv_sel5
                || ' DECODE(arpt_sql_func_util.bucket_function('''
                || bucket_line_type_7
                || ''', '
                || '           ps.amount_in_dispute,ps.amount_adjusted_pending, '
                || bucket_days_from_7
                || ','
                || bucket_days_to_7
                || ', '
                || '            ps.due_date,'''
                || bucket_category
                || ''',to_date('''
                || as_of_date
                || ''')),0,0,'
                || '           decode( '''
                || c_convert_flag
                || ''', ''Y'', '
                || '            ps.acctd_amount_due_remaining, '
                || '            ps.amount_due_remaining)), ';
            else
                l_inv_sel5 := l_inv_sel5 || ' 0, ';
            end if;    
            --END Dash Kit Leung - 05-MAY-2021

         l_inv_sel5      :=
               l_inv_sel5
            || ' ps.invoice_currency_code, '
            || ' (decode( '''
            || c_convert_flag
            || ''', ''Y'', '
            || '            ps.acctd_amount_due_remaining, '
            || '            ps.amount_due_remaining) / NVL(ps.exchange_rate,1))';

         IF UPPER(p_mrcsobtype) = 'R' THEN
            l_inv_sel5      :=
                  l_inv_sel5
               || ' from  hz_cust_accounts cust_acct, '
               || '       hz_parties party, '
               || '       ar_payment_schedules_all_mrc_v ps,';
         ELSE
            l_inv_sel5      :=
                  l_inv_sel5
               || ' from  hz_cust_accounts cust_acct, '
               || '       hz_parties party, '
               || '       ar_payment_schedules ps,';
         END IF;


         IF UPPER(p_mrcsobtype) = 'R' THEN
            l_inv_sel5      :=
                  l_inv_sel5
               || '      hz_cust_site_uses   site, '
               || '      hz_cust_acct_sites  acct_site, '
               || '      hz_party_sites      party_site, '
               || '      hz_locations        loc, '
               || '      ar_trx_history_all_mrc_v th, '
               || '      ar_distributions_all_mrc_v dist, '
               || '      gl_code_combinations c';
         ELSE
            l_inv_sel5      :=
                  l_inv_sel5
               || '      hz_cust_site_uses   site, '
               || '      hz_cust_acct_sites  acct_site, '
               || '      hz_party_sites party_site, '
               || '      hz_locations loc, '
               || '      ar_transaction_history th, '
               || '      ar_distributions       dist, '
               || '      gl_code_combinations c';
         END IF;

         l_inv_sel5      :=
               l_inv_sel5
            || '  ,ra_customer_trx     rct_c  '
            || '   ,ra_terms_tl        terms  '
            --Dash Kit Leung - 08-MAR-2021
            /*
            || '  ,(SELECT rep.org_id, rep.salesrep_id, ext.resource_name name '
            || '     FROM jtf_rs_salesreps rep'
            || '     JOIN jtf_rs_resource_extns_tl ext on ( ext.resource_id = rep.resource_id )) sales'
            */
            --End Dash Kit Leung - 08-MAR-2021
            || '   ,xxbs_customer_trx bill';

         l_inv_sel5      :=
               l_inv_sel5
            || ' where  ps.gl_date <= to_date('''
            || as_of_date
            || ''')'
            || ' and    ('''
            || p_credit_option
            || ''' != ''NONE'''
            || '  or     ((ps.class != ''PMT'''
            || ' and       ps.class != ''CM'''
            || ' and       ps.class != ''CLAIM'')'
            || ' and     '''
            || p_credit_option
            || ''' = ''NONE''))'
            || ' and   ps.customer_site_use_id = site.site_use_id'
            || ' and   site.cust_acct_site_id = acct_site.cust_acct_site_id'
            || ' and   acct_site.party_site_id  = party_site.party_site_id'
            || ' and   loc.location_id = party_site.location_id'
            || ' and   ps.gl_date_closed  > to_date('''
            || as_of_date
            || ''')'
            || ' and   ps.class = ''BR'''
            || ' and   decode(upper('''
            || p_in_currency
            || '''),NULL, ps.invoice_currency_code,'
            || '          upper('''
            || p_in_currency
            || ''')) = ps.invoice_currency_code'
            || -- Bug 3221577 : we cannot just get current record since its gldate
               -- may not be before as_of_date
               -- th.current_accounted_flag = ''Y''
               -- instead get the max TH row with gl_date <= as of date
               -- that has DR row in ar_distributions
               ' and   th.transaction_history_id = '
            || '      (select max(transaction_history_id)'
            || '         from ar_transaction_history th2,'
            || '              ar_distributions dist2'
            || '        where th2.transaction_history_id = dist2.source_id'
            || '          and  dist2.source_table = ''TH'''
            || '          and  th2.gl_date <= to_date('''
            || as_of_date
            || ''')'
            || '          and  dist2.amount_dr is not null'
            || '          and  th2.customer_trx_id = ps.customer_trx_id)'
            || ' and   th.transaction_history_id = dist.source_id'
            || ' and   dist.source_table = ''TH'''
            || -- Bug 3221577 : remove following condition
               -- and   dist.source_type = ''REC''
               -- add the following instead
               ' and   dist.amount_dr is not null'
            || ' and   dist.source_table_secondary is NULL'
            || ' and   dist.code_combination_id = c.code_combination_id'
            || ' and   cust_acct.party_id = party.party_id ';

         /* changes done for 2484126 have been reverted, instead the condition
            to check for amount_dr was moved above for the fix done in 3221577
         */

         l_inv_sel5      :=
               l_inv_sel5
            || ' and ps.customer_trx_id+0 = rct_c.customer_trx_id  '
            || ' and rct_c.term_id+0 = terms.term_id (+) '
            --Dash Kit Leung - 08-MAR-2021
            --|| ' and rct_c.primary_salesrep_id+0 = sales.salesrep_id (+) '            
            --End Dash Kit Leung - 08-MAR-2021            
            || ' and rct_c.trx_number = bill.ar_trx_number (+)'; -- Merrill custom

         l_inv_sel5      :=
               l_inv_sel5
            || ' and ps.customer_id = cust_acct.cust_account_id  '
            || ' and ps.customer_trx_id = th.customer_trx_id '
            || ' and decode( '''
            || c_convert_flag
            || ''', ''Y'', '
            || '            ps.acctd_amount_due_remaining, '
            || '            ps.amount_due_remaining) <> 0  ';

         /* Added as part of CR#1904 */

         IF p_customer_name IS NOT NULL THEN

         l_inv_sel5 := l_inv_sel5 || ' AND party.party_name LIKE '||''''||p_customer_name||'%'||'''';

         END IF;

         /* End for CR#1904 */

         l_inv_sel5   := l_inv_sel5 || REPLACE( p_org_where_ps, ':p_reporting_entity_id', p_reporting_entity_id);
         l_inv_sel5   := l_inv_sel5 || REPLACE( p_org_where_addr, ':p_reporting_entity_id', p_reporting_entity_id);
         l_inv_sel5   := l_inv_sel5 || REPLACE( p_org_where_sales, ':p_reporting_entity_id', p_reporting_entity_id);

         l_inv_sel    := l_inv_sel || ' UNION ALL ' || l_inv_sel5;

         RETURN (l_inv_sel);
      END build_invoice_select;
   BEGIN
      fnd_file.put_line( fnd_file.LOG, 'within main PLSQL block');

      -------------------------------------------------------------------------------------------------------------------------------------------
      -- Select additional information needed to process report request
      -------------------------------------------------------------------------------------------------------------------------------------------
      DECLARE
         l_sysparam_sob_id   NUMBER;
      BEGIN

         IF p_ca_set_of_books_id <> -1999 THEN

            BEGIN

               SELECT --mrc_sob_type_code --Commented for R12 Upgrade
                      DECODE (alc_ledger_type_code,
                             'TARGET', 'R',
                             'SOURCE', 'P',
                             'N') mrc_sob_type_code --Added for R12 Upgrade
                 INTO p_mrcsobtype
                 FROM --gl_sets_of_books --Commented for R12 Upgrade
                      gl_ledgers --Added for R12 Upgrade
                WHERE --set_of_books_id = p_ca_set_of_books_id --Commented for R12 Upgrade
                      ledger_id = p_ca_set_of_books_id; --Added for R12 Upgrade
            EXCEPTION
               WHEN OTHERS THEN
                  p_mrcsobtype   := 'P';
            END;

         ELSE
            p_mrcsobtype   := 'P';
         END IF;

        BEGIN
         SELECT set_of_books_id
           INTO l_sysparam_sob_id
           FROM ar_system_parameters;
        EXCEPTION
          WHEN OTHERS THEN
             l_sysparam_sob_id := NULL;
             FOR rec IN(SELECT set_of_books_id
                          FROM ar_system_parameters)
             LOOP
                 fnd_file.put_line( fnd_file.LOG, '**set_of_books_id = ' || rec.set_of_books_id);
             END LOOP;
        END;
         IF (UPPER(p_mrcsobtype) = 'R') THEN
            fnd_client_info.set_currency_context(p_ca_set_of_books_id);
         END IF;

         IF l_sysparam_sob_id = p_ca_set_of_books_id THEN
            p_mrcsobtype   := 'P';
         END IF;

         fnd_file.put_line( fnd_file.LOG, 'mrc sob type = ' || p_mrcsobtype);

         xla_mo_reporting_api.initialize( p_reporting_level, p_reporting_entity_id, 'AUTO');

         p_org_where_ps        := xla_mo_reporting_api.get_predicate( 'ps', NULL);
         p_org_where_gld       := xla_mo_reporting_api.get_predicate( 'gld', NULL);
         p_org_where_ct        := xla_mo_reporting_api.get_predicate( 'ct', NULL);
         --p_org_where_sales     := xla_mo_reporting_api.get_predicate( 'sales', NULL);
         p_org_where_ct2       := xla_mo_reporting_api.get_predicate( 'ct2', NULL);
         p_org_where_adj       := xla_mo_reporting_api.get_predicate( 'adj', NULL);
         p_org_where_app       := xla_mo_reporting_api.get_predicate( 'app', NULL);
         p_org_where_crh       := xla_mo_reporting_api.get_predicate( 'crh', NULL);
         p_org_where_cr        := xla_mo_reporting_api.get_predicate( 'cr', NULL);
         p_org_where_addr      := xla_mo_reporting_api.get_predicate( 'acct_site', NULL);

         fnd_file.put_line( fnd_file.LOG, 'p_org_where_ps = ' || p_org_where_ps);
         fnd_file.put_line( fnd_file.LOG, 'p_org_where_gld = ' || p_org_where_gld);
         fnd_file.put_line( fnd_file.LOG, 'p_org_where_ct = ' || p_org_where_ct);
         fnd_file.put_line( fnd_file.LOG, 'p_org_where_sales = ' || p_org_where_sales);
         fnd_file.put_line( fnd_file.LOG, 'p_org_where_ct2 = ' || p_org_where_ct2);
         fnd_file.put_line( fnd_file.LOG, 'p_org_where_adj = ' || p_org_where_adj);
         fnd_file.put_line( fnd_file.LOG, 'p_org_where_app = ' || p_org_where_app);
         fnd_file.put_line( fnd_file.LOG, 'p_org_where_crh = ' || p_org_where_crh);
         fnd_file.put_line( fnd_file.LOG, 'p_org_where_cr = ' || p_org_where_cr);
         fnd_file.put_line( fnd_file.LOG, 'p_org_where_addr = ' || p_org_where_addr);

         p_short_unid_phrase   := RTRIM(RPAD( arpt_sql_func_util.get_lookup_meaning( 'MISC_PHRASES', 'UNIDENTIFIED_PAYMENT'), 18));

         fnd_file.put_line( fnd_file.LOG, 'short_unid_phrase = ' || p_short_unid_phrase);

         lp_payment_meaning    := RTRIM(RPAD( arpt_sql_func_util.get_lookup_meaning( 'INV/CM/ADJ', 'PMT'), 20));

         fnd_file.put_line( fnd_file.LOG, 'payment_meaning = ' || lp_payment_meaning);

         lp_risk_meaning       := RTRIM(RPAD( arpt_sql_func_util.get_lookup_meaning( 'MISC_PHRASES', 'RISK'), 20));

         fnd_file.put_line( fnd_file.LOG, 'risk meaning = ' || lp_risk_meaning);

         as_of_date            := TO_CHAR(TO_DATE( p_in_as_of_date_low, 'YYYY/MM/DD HH24:MI:SS'));

         fnd_file.put_line( fnd_file.LOG, 'Before call to set buckets');
         set_buckets(p_in_bucket_type_low
                    ,bucket_category
                    ,bucket_line_type_0
                    ,bucket_days_from_0
                    ,bucket_days_to_0
                    ,bucket_line_type_1
                    ,bucket_days_from_1
                    ,bucket_days_to_1
                    ,bucket_line_type_2
                    ,bucket_days_from_2
                    ,bucket_days_to_2
                    ,bucket_line_type_3
                    ,bucket_days_from_3
                    ,bucket_days_to_3
                    ,bucket_line_type_4
                    ,bucket_days_from_4
                    ,bucket_days_to_4
                    ,bucket_line_type_5
                    ,bucket_days_from_5
                    ,bucket_days_to_5
                    ,bucket_line_type_6
                    ,bucket_days_from_6
                    ,bucket_days_to_6
                    --Dash Kit Leung - 05-MAY-2021
                    ,bucket_line_type_7
                    ,bucket_days_from_7
                    ,bucket_days_to_7
                    --END Dash Kit Leung - 05-MAY-2021
                    );
         fnd_file.put_line( fnd_file.LOG, 'After call to set buckets.  ');
         fnd_file.put_line( fnd_file.LOG, 'bucket 0 = ' || bucket_line_type_0 || ' ' || bucket_days_from_0 || ' ' || bucket_days_to_0);
         fnd_file.put_line( fnd_file.LOG, 'bucket 1 = ' || bucket_line_type_1 || ' ' || bucket_days_from_1 || ' ' || bucket_days_to_1);
         fnd_file.put_line( fnd_file.LOG, 'bucket 2 = ' || bucket_line_type_2 || ' ' || bucket_days_from_2 || ' ' || bucket_days_to_2);
         fnd_file.put_line( fnd_file.LOG, 'bucket 3 = ' || bucket_line_type_3 || ' ' || bucket_days_from_3 || ' ' || bucket_days_to_3);
         fnd_file.put_line( fnd_file.LOG, 'bucket 4 = ' || bucket_line_type_4 || ' ' || bucket_days_from_4 || ' ' || bucket_days_to_4);
         fnd_file.put_line( fnd_file.LOG, 'bucket 5 = ' || bucket_line_type_5 || ' ' || bucket_days_from_5 || ' ' || bucket_days_to_5);
         fnd_file.put_line( fnd_file.LOG, 'bucket 6 = ' || bucket_line_type_6 || ' ' || bucket_days_from_6 || ' ' || bucket_days_to_6);
         --Dash Kit Leung - 05-MAY-2021
         fnd_file.put_line( fnd_file.LOG, 'bucket 7 = ' || bucket_line_type_7 || ' ' || bucket_days_from_7 || ' ' || bucket_days_to_7);
fnd_file.put_line( fnd_file.LOG,'line 1979-1' );
         BEGIN
            -- DASH Kit Leung - Bug Fix - one ledger have two OU
            /*
            SELECT sob.currency_code functional_currency, DECODE(p_in_currency, NULL, 'Y', NULL) convert_flag
              INTO functional_currency, c_convert_flag
              FROM --gl_sets_of_books sob, --Commented for R12 Upgrade
                   gl_ledgers sob, --Added for R12 Upgrade
                   ar_system_parameters param
             WHERE --sob.set_of_books_id = param.set_of_books_id --Commented for R12 Upgrade
                   sob.ledger_id =  param.set_of_books_id --Added for R12 Upgrade
               AND sob.ledger_id = p_reporting_entity_id; --Added for R12 Upgrade #If Reporting Level - Ledger
            */
            SELECT sob.currency_code functional_currency, DECODE(p_in_currency, NULL, 'Y', NULL) convert_flag
              INTO functional_currency, c_convert_flag
              FROM gl_ledgers sob
             WHERE sob.ledger_id = p_reporting_entity_id; --Added for R12 Upgrade #If Reporting Level - Ledger
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
            --
            --Added for R12 Upgrade to Pick Functional Currency If Reporting Level - Operating Unit
            --
            SELECT sob.currency_code functional_currency, DECODE(p_in_currency, NULL, 'Y', NULL) convert_flag
              INTO functional_currency, c_convert_flag
              FROM --gl_sets_of_books sob, --Commented for R12 Upgrade
                   gl_ledgers sob, --Added for R12 Upgrade
                   ar_system_parameters param
             WHERE --sob.set_of_books_id = param.set_of_books_id --Commented for R12 Upgrade
                   sob.ledger_id =  param.set_of_books_id --Added for R12 Upgrade
               AND param.org_id = p_reporting_entity_id; --Added for R12 Upgrade #If Reporting Level - Operating Unit
            WHEN OTHERS THEN
               fnd_file.put_line( fnd_file.LOG,'Exception While selecting Functional Currency::'||SQLERRM);
         END;
fnd_file.put_line( fnd_file.LOG,'line 1979-2' );
         fnd_file.put_line( fnd_file.LOG, 'After select of functional currency.  Functional Currency = ' || functional_currency);

         fnd_file.put_line( fnd_file.LOG, 'Before call to build_invoice_select');
         common_query_inv      := build_invoice_select;
         fnd_file.put_line( fnd_file.LOG, 'After call to build_invoice select.');
         fnd_file.put_line( fnd_file.LOG, 'common_query_inv = ');
         xxcm_common.write_log(common_query_inv);
        -- l_loop_cnt            := CEIL(LENGTH(common_query_inv) / 255);
        -- fnd_file.put_line( fnd_file.LOG, SUBSTR( common_query_inv, 1, 255));

        -- FOR i IN 1 .. l_loop_cnt LOOP
        --    fnd_file.put_line( fnd_file.LOG, SUBSTR( common_query_inv, i * 255, 255));
        -- END LOOP;

      END;

      -----------------------------------------------------------------------
      -- Generate Report Output
      -----------------------------------------------------------------------
      DECLARE
         l_thecursor     INTEGER DEFAULT DBMS_SQL.open_cursor;
         l_columnvalue   VARCHAR2(4000);
         l_status        INTEGER;
         l_colcnt        NUMBER DEFAULT 0;
         l_cnt           NUMBER DEFAULT 0;
         l_col1          varchar2(400);
         l_col2          varchar2(400);
         l_col3          varchar2(400);
         l_col4          varchar2(400);
         l_col5          varchar2(400);
         l_col6          varchar2(400);
         l_col7          varchar2(400);
         l_col8          varchar2(400);
         l_col9          varchar2(400);
         l_col10         varchar2(400);
         l_col11         varchar2(400);
         l_col12         varchar2(400);
         l_col13         varchar2(400);
         l_col14         varchar2(400);
         l_col15         varchar2(400);
         l_col16         varchar2(400);
         l_col17         varchar2(400);
         l_col18         varchar2(400);
         l_col19         varchar2(400);
         l_col20         varchar2(400);
         l_col21         varchar2(400);
         l_col22         varchar2(400);
         l_col23         varchar2(400);
         l_col24         varchar2(400);
         l_col25         varchar2(400);
         l_col26         varchar2(400);
         l_col27         varchar2(400);
         l_col28         varchar2(400);
         l_col29         varchar2(400);
         l_col30         varchar2(400);
         l_col31         varchar2(400);
         l_col32         varchar2(400);
         l_col33         varchar2(400);
         l_col34         varchar2(400);
         l_col35         varchar2(400);
         l_col36         varchar2(400);
         l_col37         varchar2(400);
         l_col38         varchar2(400);
         l_col39         varchar2(400);
         l_col40         varchar2(400);
         l_col41         varchar2(400);
         l_col42         varchar2(400);
         l_col43         varchar2(400);
         l_col44         varchar2(400);         

      BEGIN

         DBMS_SQL.parse( l_thecursor, common_query_inv, DBMS_SQL.native);

         FOR i IN 1 .. 255 LOOP

            BEGIN
               DBMS_SQL.define_column(l_thecursor
                                     ,i
                                     ,l_columnvalue
                                     ,4000);
               l_colcnt   := i;
            EXCEPTION
               WHEN OTHERS THEN

                  IF (SQLCODE = -1007) THEN
                     EXIT;
                  ELSE
                     RAISE;
                  END IF;

            END;

         END LOOP;

         DBMS_SQL.define_column(l_thecursor
                               ,1
                               ,l_columnvalue
                               ,4000);
         l_status   := DBMS_SQL.execute(l_thecursor);

         LOOP
            EXIT WHEN (DBMS_SQL.fetch_rows(l_thecursor) <= 0);

               DBMS_SQL.COLUMN_VALUE( l_thecursor, 1, l_col1);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 2, l_col2);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 3, l_col3);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 4, l_col4);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 5, l_col5);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 6, l_col6);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 7, l_col7);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 8, l_col8);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 9, l_col9);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 10, l_col10);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 11, l_col11);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 12, l_col12);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 13, l_col13);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 14, l_col14);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 15, l_col15);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 16, l_col16);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 17, l_col17);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 18, l_col18);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 19, l_col19);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 20, l_col20);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 21, l_col21);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 22, l_col22);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 23, l_col23);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 24, l_col24);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 25, l_col25);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 26, l_col26);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 27, l_col27);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 28, l_col28);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 29, l_col29);
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 30, l_col30);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 31, l_col31);         
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 32, l_col32);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 33, l_col33);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 34, l_col34);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 35, l_col35);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 36, l_col36);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 37, l_col37);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 38, l_col38);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 39, l_col39);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 40, l_col40);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 41, l_col41);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 42, l_col42);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 43, l_col43);               
               DBMS_SQL.COLUMN_VALUE( l_thecursor, 44, l_col44);

                PIPE ROW (xxar_expanded_aging_type(
                                                    l_col1,
                                                    l_col2,
                                                    l_col3,
                                                    l_col4,
                                                    l_col5,
                                                    l_col6,
                                                    l_col7,
                                                    l_col8,
                                                    l_col9,
                                                    l_col10,
                                                    l_col11,
                                                    l_col12,
                                                    l_col13,
                                                    l_col14,
                                                    l_col15,
                                                    l_col16,
                                                    l_col17,
                                                    l_col18,
                                                    l_col19,
                                                    l_col20,
                                                    l_col21,
                                                    l_col22,
                                                    l_col23,
                                                    l_col24,
                                                    l_col25,
                                                    l_col26,
                                                    l_col27,
                                                    l_col28,                                                    
                                                    l_col29,
                                                    l_col30,
                                                    l_col31,
                                                    l_col32,
                                                    l_col33,
                                                    l_col34,
                                                    l_col35,
                                                    l_col36,
                                                    l_col37,
                                                    l_col38,
                                                    l_col39,
                                                    l_col40,
                                                    l_col41,
                                                    l_col42,
                                                    l_col43,
                                                    l_col44                                                   
                                                   ));
            l_cnt           := l_cnt + 1;

         END LOOP;

         DBMS_SQL.close_cursor(l_thecursor);

      END;
      dbms_output.put_line('end');
   EXCEPTION
     when no_data_found then
        raise;
     when others then
     dbms_output.put_line(sqlerrm);
        fnd_file.put_line(fnd_file.log,sqlerrm);
   END get_records;

    --Dash Kit Leung - 05-MAY-2021
    --Export Record to Tableau
    PROCEDURE get_records_tableau ( p_dir        IN  VARCHAR2,
                                    p_file       IN  VARCHAR2)
    IS
    BEGIN

        MO_GLOBAL.INIT('AR');

        FOR rec IN (select * from gl_ledgers where ledger_category_code = 'PRIMARY')        
        LOOP
            xla_mo_reporting_api.initialize( 1000, rec.ledger_id, 'AUTO');

            --INSERT INTO XXAR_AGING_TMP
            --SELECT *
            --FROM TABLE(XXAR_EXPANDED_AGING_RPT.get_records (1000,rec.ledger_id,null,rec.CHART_OF_ACCOUNTS_ID,null,(select to_char(trunc(date_value),'YYYY/MM/DD HH24:MI:SS') from xxtm_tableau_params where params_name = 'CUTOFFDATE'),'Collections','DETAIL',null,'DETAIL',null))
            --ORDER BY 1,12 ASC;
            INSERT INTO "XXAR_AGING_TMP" (ORG_ID, CUST_ACCOUNT_ID, AR_CUSTOMER_TRX_ID, 
            OPERATING_UNIT_NAME, CUSTOMER_NAME, CUSTOMER_NUMBER, 
            CREDIT_LIMIT, STOCK_CODE, SOE_YN, 
            PRODUCT_LINE, SITE, LEGAL_ENTITY, 
            PRIMARY_PRODUCT_TYPE, PRIMARY_SALESREP, PRIMARY_SALESREP_SPLIT, 
            SALESREP_2ND, SALESREP_2ND_SPLIT, SALESREP_3RD, 
            SALESREP_3RD_SPLIT, SALESREP_4TH, SALESREP_4TH_SPLIT,
            SALESREP_5TH, SALESREP_5TH_SPLIT,
            ACTIVE_BILLER, PAYMENT_TERMS, INVOICE_NUMBER, 
            INVOICE_TYPE, INVOICE_DATE, DUE_DATE, 
            GL_DATE, BILL_TRX_DESC, EXCHANGE_RATE, 
            FUNC_CURRENCY, AMOUNT_DUE, CURRENT_DUE, 
            PAST_DUE30, PAST_DUE60, PAST_DUE90, 
            PAST_DUE120, PAST_DUE180, PAST_DUE360, 
            PAST_DUEOVER361, INVOICE_CURRENCY, 
            AMOUNT_IN_INVOICE_CURRENCY
            )
            SELECT ORG_ID,CUST_ACCOUNT_ID, AR_CUSTOMER_TRX_ID, 
                OPERATING_UNIT_NAME, CUSTOMER_NAME, CUSTOMER_NUMBER, 
                CREDIT_LIMIT, STOCK_CODE, SOE_YN, 
                BUSINESS_UNIT, SITE, LEGAL_ENTITY, 
                PRIMARY_PRODUCT_TYPE, PRIMARY_SALESREP, PRIMARY_SALESREP_SPLIT, 
                SALESREP_2ND, SALESREP_2ND_SPLIT, SALESREP_3RD, 
                SALESREP_3RD_SPLIT, SALESREP_4TH, SALESREP_4TH_SPLIT,
                SALESREP_5TH, SALESREP_5TH_SPLIT,
                ACTIVE_BILLER, PAYMENT_TERMS, INVOICE_NUMBER, 
                INVOICE_TYPE, INVOICE_DATE, DUE_DATE, 
                GL_DATE, DESCRIPTION, EXCHANGE_RATE, 
                FUNCTIONAL_CURRENCY, OUTSTANDING_AMOUNT, BUCKET0, 
                BUCKET1, BUCKET2, BUCKET3, 
                BUCKET4, BUCKET5, BUCKET6, 
                BUCKET7, INVOICED_CURRENCY, 
                AMOUNT_IN_INVOICE_CURRENCY
            FROM TABLE(XXAR_EXPANDED_AGING_RPT.get_records (1000,rec.ledger_id,null,rec.CHART_OF_ACCOUNTS_ID,null,(select to_char(trunc(date_value),'YYYY/MM/DD HH24:MI:SS') from xxtm_tableau_params where params_name = 'CUTOFFDATE'),'Collections 8-Bucket','DETAIL',null,'DETAIL',null))
            ORDER BY CUSTOMER_NAME,DUE_DATE ASC;
        END LOOP;

        XXTM_CSV_GENERATOR.GENERATE_FILE(p_dir => p_dir,
                                         p_file => p_file,
                                         p_query => 'SELECT * FROM XXAR_AGING_TMP');

    END get_records_tableau;
END xxar_expanded_aging_rpt;



/
