--------------------------------------------------------
--  DDL for Package Body XXFA_ASSET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXFA_ASSET_PKG" IS
  --------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Package Name:    XXFA_ASSET_PKG.pkb
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         Fixed Assets package for loading adjustments and additions into staging table
  Program Style:   Stored Package BODY
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula    Initial Version
  ---------------------------------------------------------------------------------------------------*/
 c_debug_module CONSTANT VARCHAR2(100) := 'XXFA.XXFA_ASSET_PKG.';

 --------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Procedure Name:  reset_sequence
  Author's Name:   Sandeep Akula
  Date Written:    09-FEB-2016
  Purpose:         This Procedure resets the sequence value to 0
  Program Style:   Procedure Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  09-FEB-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
PROCEDURE reset_sequence(p_seq_name IN VARCHAR2) IS

 l_val number;

BEGIN

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'reset_sequence',
                   message   => 'Inside Procedure reset_sequence');

   execute immediate 'select ' || p_seq_name || '.nextval from dual' INTO l_val;

   fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'reset_sequence',
                   message   => 'l_val:'||l_val);

   IF l_val > 999999999999999999999949999 THEN

          fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'reset_sequence',
                   message   => 'Inside IF Statement');

      execute immediate 'alter sequence ' || p_seq_name || ' increment by -' || l_val ||' minvalue 0';
      execute immediate 'select ' || p_seq_name || '.nextval from dual' INTO l_val;
      execute immediate 'alter sequence ' || p_seq_name || ' increment by 1 minvalue 0';

   END IF;


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'reset_sequence',
                   message   => 'End of Procedure reset_sequence'||
                                ' l_val:'||l_val);

EXCEPTION
WHEN OTHERS THEN
fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'reset_sequence',
                   message   => 'SQL Error:'||SQLERRM);
END reset_sequence;

 --------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    get_accounting_flex_structure
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Function gets Asset Book Information
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/

FUNCTION get_accounting_flex_structure(p_sob_type IN VARCHAR2,
                                       p_book_type IN VARCHAR2)
RETURN book_record IS

l_of_book book_record;

BEGIN

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_accounting_flex_structure',
                   message   => 'Inside Function get_accounting_flex_structure');


IF upper(p_sob_type) = 'R' THEN
  SELECT bc.book_type_code,
         bc.accounting_flex_structure,
         bc.distribution_source_book,
         sob.currency_code,
         cur.precision
  INTO   l_of_book
  FROM   FA_BOOK_CONTROLS_MRC_V bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = p_book_type
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    cur.currency_code = sob.currency_code;
ELSE
  SELECT bc.book_type_code,
         bc.accounting_flex_structure,
         bc.distribution_source_book,
         sob.currency_code,
         cur.precision
  INTO   l_of_book
  FROM   FA_BOOK_CONTROLS bc,
         GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = p_book_type
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    cur.currency_code = sob.currency_code;
END IF;

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_accounting_flex_structure',
                   message   => 'book_type_code:'||l_of_book.book_type_code||
                                ' accounting_flex_structure:'||l_of_book.accounting_flex_structure||
                                ' distribution_source_book:'||l_of_book.distribution_source_book||
                                ' currency_code:'||l_of_book.currency_code||
                                ' precision:'||l_of_book.precision);

RETURN(l_of_book);

END get_accounting_flex_structure;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    get_period_info
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Function gets period counter for a given period
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION get_period_info(p_book_type_code IN VARCHAR2,
                         p_period IN VARCHAR2,
                         p_sob_type IN VARCHAR2)
RETURN period_record IS

l_period period_record;

BEGIN

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_period_info',
                   message   => 'Inside Function get_period_info');


IF upper(p_sob_type) = 'R'
THEN
      select period_name,
             period_counter,
             period_open_date,
             nvl(period_close_date, sysdate),
             fiscal_year
      into   l_period
      from   fa_deprn_periods_mrc_v
      where  book_type_code = p_book_type_code
      and    period_name = p_period;
ELSE
      select period_name,
             period_counter,
             period_open_date,
             nvl(period_close_date, sysdate),
             fiscal_year
      into   l_period
      from   fa_deprn_periods
      where  book_type_code = p_book_type_code
      and    period_name = p_period;
END IF;


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_period_info',
                   message   => 'period_name:'||l_period.period_name||
                                ' period_counter:'||l_period.period_counter||
                                ' period_open_date:'||l_period.period_open_date||
                                ' period_close_date:'||l_period.period_close_date||
                                ' fiscal_year:'||l_period.fiscal_year);


RETURN(l_period);

EXCEPTION
WHEN OTHERS THEN
fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_period_info',
                   message   => 'SQL Error:'||SQLERRM);
RETURN(NULL);

END get_period_info;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    get_gl_string
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Function gets concatenated GL String for a code combination ID
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION get_gl_string(p_ccid IN NUMBER)
RETURN VARCHAR2 IS
l_gl_string gl_code_combinations_kfv.concatenated_segments%type;

BEGIN

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_gl_string',
                   message   => 'Inside Function get_gl_string');


select concatenated_segments
into l_gl_string
from gl_code_combinations_kfv
where code_combination_id = p_ccid;

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_gl_string',
                   message   => 'l_gl_string:'||l_gl_string);

return(l_gl_string);

EXCEPTION
WHEN OTHERS THEN
fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_gl_string',
                   message   => 'SQL Error:'||SQLERRM);
return(null);

END get_gl_string;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    get_currency_conversion
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Function converts amount into USD and returns the USD Value
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION get_currency_conversion(p_entered_curr_amt IN NUMBER,
                                 p_conversion_date IN DATE,
                                -- p_conversion_type IN VARCHAR2,
                                 p_from_currency IN VARCHAR2)
RETURN currency_exchange_record IS

l_currency_info currency_exchange_record;

BEGIN

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_currency_conversion',
                   message   => 'Inside function get_currency_conversion'||
                                ' p_entered_curr_amt:'||p_entered_curr_amt||
                                ' p_conversion_date:'||p_conversion_date||
                                ' p_from_currency:'||p_from_currency);

--IF p_from_currency = 'USD' THEN
--BC 20210115
IF p_from_currency = 'HKD' THEN 
fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_currency_conversion',
                   message   => 'p_from_currency is USD');

select p_entered_curr_amt,
       --(CASE WHEN p_conversion_date >= to_date('01-JAN-15','DD-MON-RR') THEN '1380' ELSE 'Period End1' END), --BC 20210113
	   (CASE WHEN p_conversion_date >= to_date('01-JAN-15','DD-MON-RR') THEN '1001' ELSE 'Period End1' END),
       p_conversion_date,
       1,
       ROUND(1*p_entered_curr_amt,2),
       p_from_currency,
       --'USD'
	   'HKD'
into l_currency_info
from dual;

ELSE

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_currency_conversion',
                   message   => 'p_from_currency is not USD');

--select p_entered_curr_amt,conversion_type,conversion_date,conversion_rate,ROUND(conversion_rate*p_entered_curr_amt,2),p_from_currency,'USD' --BC 20210115 change converto to HKD
select p_entered_curr_amt,conversion_type,conversion_date,conversion_rate,ROUND(conversion_rate*p_entered_curr_amt,2),p_from_currency,'HKD'
into l_currency_info
from gl_daily_rates
where from_currency = p_from_currency and
      --to_currency = 'USD' and
	  to_currency = 'HKD' and   --BC 20210115 change converto to HKD
      conversion_date = p_conversion_date and
      --conversion_type = (CASE WHEN conversion_date >= to_date('01-JAN-15','DD-MON-RR') THEN '1380' ELSE 'Period End1' END);
	  conversion_type = (CASE WHEN conversion_date >= to_date('01-JAN-15','DD-MON-RR') THEN '1001' ELSE 'Period End1' END);  --BC 20210113 

END IF;

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_currency_conversion',
                   message   => 'entered_currency_amount:'||l_currency_info.entered_currency_amount||
                                ' conversion_type:'||l_currency_info.conversion_type||
                                ' conversion_date:'||l_currency_info.conversion_date||
                                ' conversion_rate:'||l_currency_info.conversion_rate||
                                ' functional_currency_amount:'||l_currency_info.functional_currency_amount||
                                ' entered_currency:'||l_currency_info.entered_currency||
                                ' functional_currency:'||l_currency_info.functional_currency);

 return(l_currency_info);

EXCEPTION
WHEN OTHERS THEN
fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_currency_conversion',
                   message   => 'SQL Error:'||SQLERRM);
return(null);

END get_currency_conversion;
  --------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Procedure Name:  adjustments
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Procedure loads Asset adjustments for a given period into staging table
  Program Style:   Procedure Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
PROCEDURE adjustments(p_sob_id IN NUMBER,
                      p_sob_type IN VARCHAR2,
                      p_book_class IN varchar2,
                      p_book_type_code IN VARCHAR2,
                      p_from_period IN varchar2,
                      p_to_period IN varchar2) IS

CURSOR c_adjustments(cp_book_type   IN VARCHAR2,
                     cp_period_counter1 in NUMBER,
                     cp_period_counter2 in NUMBER,
                     cp_dist_source_book IN VARCHAR2,
                     cp_acct_flex_bal_seg IN VARCHAR2,
                     cp_acct_flex_cost_seg IN VARCHAR2,
                     cp_cat_flex_all_seg IN VARCHAR2,
                     cp_precision IN NUMBER) IS
SELECT asset,
       asset_id,
       descr,
       category_id,
       asset_major_category,
       asset_minor_category,
       serial_number,
       tag_number,
       fiscal_year,
       calendar_period_close_date,
       asset_book,
       date_placed_in_service,
       life_in_months,
       asset_type,
       asset_account,
       source_transaction_header_id,
       thid,
       transaction_date_entered,
       transaction_type_code,
       old_cost1,
       new_cost1,
       old_cost_rsum,
       new_cost_rsum,
       unit_sum,
       units,
       old_cost,
       new_cost,
       country,
       state,
       city,
       location,
       Depreciation_Reserve_account,
       asset_cost_account,
       depreciation_account,
       asset_cost_acct,
       deprn_reserve_acct,
       deprn_expense_account_ccid,
       DECODE(unit_sum,units,NEW_COST1+new_cost-NEW_COST_RSUM,NEW_COST1) -
       DECODE(unit_sum,units,OLD_COST1+old_cost-OLD_COST_RSUM,OLD_COST1) adjustment_amount,
       period_entered
FROM (
select ad.asset_number                asset,
       ad.asset_id,
       ad.description                descr,
       cat.category_id,
       cat.segment1 asset_major_category,
       cat.segment2 asset_minor_category,
       ad.serial_number,
       ad.tag_number,
       dp.fiscal_year,
       dp.calendar_period_close_date,
       th.book_type_code asset_book,
       to_char(books_new.date_placed_in_service,'DD-MON-RRRR') date_placed_in_service,
       books_new.life_in_months,
       ups.meaning      asset_type,
       decode(ah.asset_type, 'CIP', cb.cip_cost_acct,cb.asset_cost_acct)         asset_account,
       th.source_transaction_header_id,
       th.transaction_header_id        thid,
       th.transaction_date_entered,
       th.transaction_type_code,
       round((books_old.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision) old_cost1,
       (round((books_old.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision) +
        round(((books_new.cost - books_old.cost)* nvl(dh.units_assigned,ah.units)/ah.units), cp_precision)) new_cost1,
       sum(round((books_old.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision))
       over(partition by dh.asset_id order by dh.distribution_id) old_cost_rsum,
       sum((round((books_old.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision) +
        round(((books_new.cost - books_old.cost)* nvl(dh.units_assigned,ah.units)/ah.units), cp_precision)))
        over(partition by dh.asset_id order by dh.distribution_id) new_cost_rsum,
        sum(nvl(dh.units_assigned,ah.units)) over (partition by dh.asset_id order by dh.distribution_id) unit_sum,
        ah.units units,
        books_old.cost old_cost,
        books_new.cost new_cost,
        fl.segment1 country,
        fl.segment2 state,
        fl.segment3 city,
        fl.segment4 location,
        get_gl_string(cb.reserve_account_ccid) Depreciation_Reserve_account,
        get_gl_string(cb.asset_cost_account_ccid) asset_cost_account,
        get_gl_string(dh.code_combination_id) depreciation_account,
        cb.asset_cost_acct,
        cb.deprn_reserve_acct,
        dh.code_combination_id deprn_expense_account_ccid,
        dp.period_name period_entered
from
    fa_asset_history        ah,
    fa_additions            ad,
    fa_categories            cat,
    fa_category_books        cb,
    fa_books            books_old,
    fa_books            books_new,
    fa_lookups            ups,
    fa_deprn_periods        dp,
    fa_distribution_history         dh,
    gl_code_combinations        dhcc,
    fa_transaction_headers        th,
    fa_locations fl
where
    dp.book_type_code                  = cp_book_type   and
    dp.period_counter                  >= cp_period_counter1  and
    dp.period_counter                  <= nvl(cp_period_counter2, dp.period_counter) and
    th.book_type_code                  =  dp.book_type_code        and
    th.date_effective                  between dp.period_open_date and nvl(dp.period_close_date, sysdate) and
    th.transaction_type_code           in ('ADJUSTMENT','CIP ADJUSTMENT') and
    books_old.transaction_header_id_out = th.transaction_header_id    and
    books_old.book_type_code            = th.book_type_code and
    books_new.transaction_header_id_in  = th.transaction_header_id    and
    books_new.book_type_code            = th.book_type_code and
    ad.asset_id                         = th.asset_id and
    ups.lookup_type                     = 'ASSET TYPE' and
    cb.category_id                      = ah.category_id    and
    cb.book_type_code                   = th.book_type_code and
    cat.category_id                     = cb.category_id and
    ah.asset_id                         = ad.asset_id            and
    ah.asset_type                       = ups.lookup_code        and
    th.transaction_header_id            >= ah.transaction_header_id_in and
    th.transaction_header_id            < nvl(ah.transaction_header_id_out, th.transaction_header_id + 1) and
    th.asset_id                         = dh.asset_id            and
    dh.book_type_code                   = cp_dist_source_book and
    th.transaction_header_id            >=  dh.transaction_header_id_in         and
    th.transaction_header_id            < nvl(dh.transaction_header_id_out, th.transaction_header_id + 1) and
    dh.code_combination_id              = dhcc.code_combination_id and
    dh.location_id = fl.location_id(+) and
    round((books_old.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision) !=
    round((books_new.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision)
    )
ORDER BY asset_book,asset;


TYPE adjustments_type IS TABLE OF c_adjustments%ROWTYPE
INDEX BY PLS_INTEGER;

l_adjustments adjustments_type;


l_book book_record;
l_currency_code VARCHAR2(10);
l_company_name fa_system_controls.company_name%type;
l_category_flex_structure  fa_system_controls.category_flex_structure%type;
l_period_counter1 period_record;
l_period_counter2 period_record;
l_currency currency_exchange_record;

BEGIN

         -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => 'Inside the Procedure adjustments'||
                                ' p_sob_id:'||p_sob_id||
                                ' p_sob_type:'||p_sob_type||
                                ' p_book_type_code:'||p_book_type_code||
                                ' p_book_class:' || p_book_class||
                                ' p_from_period:'||p_from_period||
                                ' p_to_period:'||p_to_period);

select company_name,category_flex_structure
into l_company_name,l_category_flex_structure
from   fa_system_controls;

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => 'l_company_name:'||l_company_name||
                                ' l_category_flex_structure:'||l_category_flex_structure);

l_book :=  get_accounting_flex_structure(p_sob_type,p_book_type_code);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => 'Before l_period_counter1');

l_period_counter1 := get_period_info(p_book_type_code,p_from_period,p_sob_type);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => 'Before l_period_counter2');

l_period_counter2 := get_period_info(p_book_type_code,p_to_period,p_sob_type);

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => 'Before Cusor c_adjustments');

  OPEN c_adjustments(cp_book_type         => p_book_type_code,
                     cp_period_counter1 => l_period_counter1.period_counter,
                     cp_period_counter2 => l_period_counter2.period_counter,
                     cp_dist_source_book => l_book.distribution_source_book,
                     cp_acct_flex_bal_seg => null,
                     cp_acct_flex_cost_seg => null,
                     cp_cat_flex_all_seg => l_category_flex_structure,
                     cp_precision => l_book.precision);
  LOOP

    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => 'Inside Cursor c_adjustments');

    FETCH c_adjustments BULK COLLECT INTO l_adjustments LIMIT 100;
    EXIT WHEN l_adjustments.count = 0;

      FOR indx IN 1..l_adjustments.count LOOP


         fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => 'Inside c_adjustments loop'||
                                ' Asset:'||l_adjustments(indx).asset||
                                ' Currency:'||l_book.currency_code||
                                ' Cost:'||l_adjustments(indx).adjustment_amount||
                                ' Transaction Date:'||l_adjustments(indx).transaction_date_entered||
                                ' calendar_period_close_date:'||l_adjustments(indx).calendar_period_close_date);

          --l_currency := get_currency_conversion(l_adjustments(indx).new_cost,l_adjustments(indx).calendar_period_close_date,l_book.currency_code);
          l_currency := get_currency_conversion(l_adjustments(indx).adjustment_amount,l_adjustments(indx).calendar_period_close_date,l_book.currency_code);

          fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => 'Before Insert into xxfa_global_assets');

           INSERT INTO xxfa_global_assets(request_id,
                                          seq_no,
                                          transaction_type,
                                          asset_number,
                                          asset_description,
                                          asset_major_category,
                                          asset_minor_category,
                                          serial_number,
                                          tag_number,
                                          fiscal_year,
                                          asset_book,
                                          date_placed_in_service,
                                          life_in_months,
                                          country,
                                          state,
                                          city,
                                          location,
                                          asset_currency,
                                          asset_cost,
                                          transaction_date,
                                          exchange_rate,
                                          cost_in_usd,
                                          category_id,
                                          asset_type,
                                          transaction_header_id,
                                          source_transaction_header_id,
                                          asset_id,
                                          attribute1,
                                          book_type_code,
                                          book_class,
                                          sob_id,
                                          sob_type,
                                          company_name,
                                          category_flex_structure,
                                          asset_cost_acct,
                                          deprn_reserve_acct,
                                          depreciation_resrv_acct_string,
                                          asset_cost_account_string,
                                          depreciation_account_string,
                                          deprn_expense_account_ccid,
                                          period_entered)
                                    VALUES(p_request_id,   -- request_id
                                           xxfa_ga_seq.nextval,  -- seq_no
                                           'ADJUSTMENTS',  -- transaction_type
                                           l_adjustments(indx).asset, -- asset_number
                                           l_adjustments(indx).descr, -- asset_description
                                           l_adjustments(indx).asset_major_category, -- asset_major_category
                                           l_adjustments(indx).asset_minor_category,  -- asset_minor_category
                                           l_adjustments(indx).serial_number,  -- serial_number
                                           l_adjustments(indx).tag_number, --tag_number
                                           l_adjustments(indx).fiscal_year,  --fiscal_year
                                           l_adjustments(indx).asset_book,  --asset_book
                                           l_adjustments(indx).date_placed_in_service, -- date_placed_in_service
                                           l_adjustments(indx).life_in_months,  -- life_in_months
                                           l_adjustments(indx).country,
                                           l_adjustments(indx).state,
                                           l_adjustments(indx).city,
                                           l_adjustments(indx).location,
                                           l_currency.entered_currency,  -- asset_currency
                                           --l_adjustments(indx).new_cost,  -- asset_cost
                                           l_adjustments(indx).adjustment_amount,  -- asset_cost
                                           l_adjustments(indx).transaction_date_entered, -- transaction_date
                                           l_currency.conversion_rate, -- exchange_rate
                                           l_currency.functional_currency_amount, -- cost_in_usd
                                           l_adjustments(indx).category_id,
                                           l_adjustments(indx).asset_type,
                                           l_adjustments(indx).thid, -- transaction_header_id
                                           l_adjustments(indx).source_transaction_header_id,
                                           l_adjustments(indx).asset_id,
                                           null, -- attribute1
                                           l_adjustments(indx).asset_book, --book_type_code,
                                           p_book_class,  -- book_class
                                           p_sob_id,  --sob_id
                                           p_sob_type, -- sob_type
                                           l_company_name,  -- company_name
                                           l_category_flex_structure, -- category_flex_structure
                                           l_adjustments(indx).asset_cost_acct,  -- asset_cost_acct
                                           l_adjustments(indx).deprn_reserve_acct, -- deprn_reserve_acct
                                           l_adjustments(indx).depreciation_reserve_account, -- depreciation_resrv_acct_string
                                           l_adjustments(indx).asset_cost_account, -- asset_cost_account_string
                                           l_adjustments(indx).depreciation_account,  -- depreciation_account_string
                                           l_adjustments(indx).deprn_expense_account_ccid, -- deprn_expense_account_ccid
                                           l_adjustments(indx).period_entered  -- period_entered
                                           );

            fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => 'After Insert into xxfa_global_assets');

      end loop;

    EXIT WHEN l_adjustments.count < 100;

  END LOOP;

  CLOSE c_adjustments;

   fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => ' AFter Cursor close');

  COMMIT;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => 'End of Procedure adjustments');

EXCEPTION
WHEN OTHERS THEN
 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments',
                   message   => 'SQL error:'||sqlerrm);
END adjustments;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Procedure Name:  adjustments_mrc
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Procedure loads Asset adjustments for a given period into staging table
  Program Style:   Procedure Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
PROCEDURE adjustments_mrc(p_sob_id IN NUMBER,
                          p_sob_type IN VARCHAR2,
                          p_book_class IN varchar2,
                          p_book_type_code IN VARCHAR2,
                          p_from_period IN varchar2,
                          p_to_period IN varchar2) IS

CURSOR c_adjustments(cp_book_type   IN VARCHAR2,
                     cp_period_counter1 in NUMBER,
                     cp_period_counter2 in NUMBER,
                     cp_dist_source_book IN VARCHAR2,
                     cp_acct_flex_bal_seg IN VARCHAR2,
                     cp_acct_flex_cost_seg IN VARCHAR2,
                     cp_cat_flex_all_seg IN VARCHAR2,
                     cp_precision IN NUMBER) IS
SELECT asset,
       asset_id,
       descr,
       category_id,
       asset_major_category,
       asset_minor_category,
       serial_number,
       tag_number,
       fiscal_year,
       calendar_period_close_date,
       asset_book,
       date_placed_in_service,
       life_in_months,
       asset_type,
       asset_account,
       source_transaction_header_id,
       thid,
       transaction_date_entered,
       transaction_type_code,
       old_cost1,
       new_cost1,
       old_cost_rsum,
       new_cost_rsum,
       unit_sum,
       units,
       old_cost,
       new_cost,
       country,
       state,
       city,
       location,
       Depreciation_Reserve_account,
       asset_cost_account,
       depreciation_account,
       asset_cost_acct,
       deprn_reserve_acct,
       deprn_expense_account_ccid,
       DECODE(unit_sum,units,NEW_COST1+new_cost-NEW_COST_RSUM,NEW_COST1) -
       DECODE(unit_sum,units,OLD_COST1+old_cost-OLD_COST_RSUM,OLD_COST1) adjustment_amount,
       period_entered
FROM (
select ad.asset_number                asset,
       ad.asset_id,
       ad.description                descr,
       cat.category_id,
       cat.segment1 asset_major_category,
       cat.segment2 asset_minor_category,
       ad.serial_number,
       ad.tag_number,
       dp.fiscal_year,
       dp.calendar_period_close_date,
       th.book_type_code asset_book,
       to_char(books_new.date_placed_in_service,'DD-MON-RRRR') date_placed_in_service,
       books_new.life_in_months,
       ups.meaning      asset_type,
       decode(ah.asset_type, 'CIP', cb.cip_cost_acct,cb.asset_cost_acct)         asset_account,
       th.source_transaction_header_id,
       th.transaction_header_id        thid,
       th.transaction_date_entered,
       th.transaction_type_code,
       round((books_old.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision) old_cost1,
       (round((books_old.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision) +
        round(((books_new.cost - books_old.cost)* nvl(dh.units_assigned,ah.units)/ah.units), cp_precision)) new_cost1,
       sum(round((books_old.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision))
       over(partition by dh.asset_id order by dh.distribution_id) old_cost_rsum,
       sum((round((books_old.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision) +
        round(((books_new.cost - books_old.cost)* nvl(dh.units_assigned,ah.units)/ah.units), cp_precision)))
        over(partition by dh.asset_id order by dh.distribution_id) new_cost_rsum,
        sum(nvl(dh.units_assigned,ah.units)) over (partition by dh.asset_id order by dh.distribution_id) unit_sum,
        ah.units units,
        books_old.cost old_cost,
        books_new.cost new_cost,
        (nvl(books_new.cost,0)-nvl(books_old.cost,0)) adjustment_amount,
        fl.segment1 country,
        fl.segment2 state,
        fl.segment3 city,
        fl.segment4 location,
        get_gl_string(cb.reserve_account_ccid) Depreciation_Reserve_account,
        get_gl_string(cb.asset_cost_account_ccid) asset_cost_account,
        get_gl_string(dh.code_combination_id) depreciation_account,
        cb.asset_cost_acct,
        cb.deprn_reserve_acct,
        dh.code_combination_id deprn_expense_account_ccid,
        dp.period_name period_entered
from
    fa_asset_history        ah,
    fa_additions            ad,
    fa_categories            cat,
    fa_category_books        cb,
    fa_books_mrc_v            books_old,
    fa_books_mrc_v            books_new,
    fa_lookups            ups,
    fa_deprn_periods_mrc_v        dp,
    fa_distribution_history         dh,
    gl_code_combinations        dhcc,
    fa_transaction_headers        th,
    fa_locations fl
where
    dp.book_type_code                  = cp_book_type   and
    dp.period_counter                  >= cp_period_counter1  and
    dp.period_counter                  <= nvl(cp_period_counter2, dp.period_counter) and
    th.book_type_code                  =  dp.book_type_code        and
    th.date_effective                  between dp.period_open_date and nvl(dp.period_close_date, sysdate) and
    th.transaction_type_code           in ('ADJUSTMENT','CIP ADJUSTMENT') and
    books_old.transaction_header_id_out = th.transaction_header_id    and
    books_old.book_type_code            = th.book_type_code and
    books_new.transaction_header_id_in  = th.transaction_header_id    and
    books_new.book_type_code            = th.book_type_code and
    ad.asset_id                         = th.asset_id and
    ups.lookup_type                     = 'ASSET TYPE' and
    cb.category_id                      = ah.category_id    and
    cb.book_type_code                   = th.book_type_code and
    cat.category_id                     = cb.category_id and
    ah.asset_id                         = ad.asset_id            and
    ah.asset_type                       = ups.lookup_code        and
    th.transaction_header_id            >= ah.transaction_header_id_in and
    th.transaction_header_id            < nvl(ah.transaction_header_id_out, th.transaction_header_id + 1) and
    th.asset_id                         = dh.asset_id            and
    dh.book_type_code                   = cp_dist_source_book and
    th.transaction_header_id            >=  dh.transaction_header_id_in         and
    th.transaction_header_id            < nvl(dh.transaction_header_id_out, th.transaction_header_id + 1) and
    dh.code_combination_id              = dhcc.code_combination_id and
    dh.location_id = fl.location_id(+) and
    round((books_old.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision) !=
    round((books_new.cost * nvl(dh.units_assigned,ah.units)/ah.units), cp_precision)
    )
ORDER BY asset_book,asset;


TYPE adjustments_type IS TABLE OF c_adjustments%ROWTYPE
INDEX BY PLS_INTEGER;

l_adjustments adjustments_type;


l_book book_record;
l_currency_code VARCHAR2(10);
l_company_name fa_system_controls.company_name%type;
l_category_flex_structure  fa_system_controls.category_flex_structure%type;
l_period_counter1 period_record;
l_period_counter2 period_record;
l_currency currency_exchange_record;

BEGIN

         -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => 'Inside the Procedure adjustments_mrc'||
                                ' p_sob_id:'||p_sob_id||
                                ' p_sob_type:'||p_sob_type||
                                ' p_book_type_code:'||p_book_type_code||
                                ' p_book_class:' || p_book_class||
                                ' p_from_period:'||p_from_period||
                                ' p_to_period:'||p_to_period);

fnd_client_info.set_currency_context(p_sob_id);

select company_name,category_flex_structure
into l_company_name,l_category_flex_structure
from   fa_system_controls;

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => 'l_company_name:'||l_company_name||
                                ' l_category_flex_structure:'||l_category_flex_structure);

l_book :=  get_accounting_flex_structure(p_sob_type,p_book_type_code);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => 'Before l_period_counter1');

l_period_counter1 := get_period_info(p_book_type_code,p_from_period,p_sob_type);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => 'Before l_period_counter2');

l_period_counter2 := get_period_info(p_book_type_code,p_to_period,p_sob_type);

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => 'Before Cusor c_adjustments');

  OPEN c_adjustments(cp_book_type         => p_book_type_code,
                     cp_period_counter1 => l_period_counter1.period_counter,
                     cp_period_counter2 => l_period_counter2.period_counter,
                     cp_dist_source_book => l_book.distribution_source_book,
                     cp_acct_flex_bal_seg => null,
                     cp_acct_flex_cost_seg => null,
                     cp_cat_flex_all_seg => l_category_flex_structure,
                     cp_precision => l_book.precision);
  LOOP

    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => 'Inside Cursor c_adjustments');

    FETCH c_adjustments BULK COLLECT INTO l_adjustments LIMIT 100;
    EXIT WHEN l_adjustments.count = 0;

      FOR indx IN 1..l_adjustments.count LOOP


         fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => 'Inside c_adjustments loop'||
                                ' Asset:'||l_adjustments(indx).asset||
                                ' Currency:'||l_book.currency_code||
                                ' Cost:'||l_adjustments(indx).adjustment_amount||
                                ' Transaction Date:'||l_adjustments(indx).transaction_date_entered||
                                ' Calendar_period_close_date:'||l_adjustments(indx).calendar_period_close_date);

          l_currency := get_currency_conversion(l_adjustments(indx).new_cost,l_adjustments(indx).calendar_period_close_date,l_book.currency_code);

          fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => 'Before Insert into xxfa_global_assets');

           INSERT INTO xxfa_global_assets(request_id,
                                          seq_no,
                                          transaction_type,
                                          asset_number,
                                          asset_description,
                                          asset_major_category,
                                          asset_minor_category,
                                          serial_number,
                                          tag_number,
                                          fiscal_year,
                                          asset_book,
                                          date_placed_in_service,
                                          life_in_months,
                                          country,
                                          state,
                                          city,
                                          location,
                                          asset_currency,
                                          asset_cost,
                                          transaction_date,
                                          exchange_rate,
                                          cost_in_usd,
                                          category_id,
                                          asset_type,
                                          transaction_header_id,
                                          source_transaction_header_id,
                                          asset_id,
                                          attribute1,
                                          book_type_code,
                                          book_class,
                                          sob_id,
                                          sob_type,
                                          company_name,
                                          category_flex_structure,
                                          asset_cost_acct,
                                          deprn_reserve_acct,
                                          depreciation_resrv_acct_string,
                                          asset_cost_account_string,
                                          depreciation_account_string,
                                          deprn_expense_account_ccid,
                                          period_entered)
                                    VALUES(p_request_id,   -- request_id
                                           xxfa_ga_seq.nextval,  -- seq_no
                                           'ADJUSTMENTS',  -- transaction_type
                                           l_adjustments(indx).asset, -- asset_number
                                           l_adjustments(indx).descr, -- asset_description
                                           l_adjustments(indx).asset_major_category, -- asset_major_category
                                           l_adjustments(indx).asset_minor_category,  -- asset_minor_category
                                           l_adjustments(indx).serial_number,  -- serial_number
                                           l_adjustments(indx).tag_number, --tag_number
                                           l_adjustments(indx).fiscal_year,  --fiscal_year
                                           l_adjustments(indx).asset_book,  --asset_book
                                           l_adjustments(indx).date_placed_in_service, -- date_placed_in_service
                                           l_adjustments(indx).life_in_months,  -- life_in_months
                                           l_adjustments(indx).country,
                                           l_adjustments(indx).state,
                                           l_adjustments(indx).city,
                                           l_adjustments(indx).location,
                                           l_currency.entered_currency,  -- asset_currency
                                           --l_adjustments(indx).new_cost,  -- asset_cost
                                           l_adjustments(indx).adjustment_amount,  -- asset_cost
                                           l_adjustments(indx).transaction_date_entered, -- transaction_date
                                           l_currency.conversion_rate, -- exchange_rate
                                           l_currency.functional_currency_amount, -- cost_in_usd
                                           l_adjustments(indx).category_id,
                                           l_adjustments(indx).asset_type,
                                           l_adjustments(indx).thid, -- transaction_header_id
                                           l_adjustments(indx).source_transaction_header_id,
                                           l_adjustments(indx).asset_id,
                                           null, -- attribute1
                                           l_adjustments(indx).asset_book, --book_type_code,
                                           p_book_class,  -- book_class
                                           p_sob_id,  --sob_id
                                           p_sob_type, -- sob_type
                                           l_company_name,  -- company_name
                                           l_category_flex_structure, -- category_flex_structure
                                           l_adjustments(indx).asset_cost_acct,  -- asset_cost_acct
                                           l_adjustments(indx).deprn_reserve_acct, -- deprn_reserve_acct
                                           l_adjustments(indx).depreciation_reserve_account, -- depreciation_resrv_acct_string
                                           l_adjustments(indx).asset_cost_account, -- asset_cost_account_string
                                           l_adjustments(indx).depreciation_account,  -- depreciation_account_string
                                           l_adjustments(indx).deprn_expense_account_ccid, -- deprn_expense_account_ccid
                                           l_adjustments(indx).period_entered -- period_entered
                                           );

            fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => 'After Insert into xxfa_global_assets');

      end loop;

    EXIT WHEN l_adjustments.count < 100;

  END LOOP;

  CLOSE c_adjustments;

   fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => ' AFter Cursor close');

  COMMIT;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => 'End of Procedure adjustments_mrc');

EXCEPTION
WHEN OTHERS THEN
 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'adjustments_mrc',
                   message   => 'SQL error:'||sqlerrm);
END adjustments_mrc;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Procedure Name:  load_adjustments
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Procedure is a wrapper prorgam which calls the appropriate procedure for each asset book type
                   to load asset adjustments for a given period into staging table
  Program Style:   Procedure Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
PROCEDURE load_adjustments(p_book_class IN varchar2,
                           p_book_type_code IN VARCHAR2, --BC 20210120
                           p_from_period IN varchar2,
                           p_to_period IN varchar2) IS

CURSOR c_books(cp_book_class IN varchar2,cp_book_type_code IN varchar2) IS
select book_type_name,
       book_type_code,
       book_class
from fa_book_controls_sec
where book_class = cp_book_class
and   book_type_code = cp_book_type_code; --BC 20210120

l_sob_type varchar2(100);
l_sob_id NUMBER;
l_currency_code VARCHAR2(10);

BEGIN

   -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_adjustments',
                   message   => 'p_book_class:'||p_book_class||
                                ' p_from_period:'||p_from_period||
                                ' p_to_period:'||p_to_period);

--FOR c_1 IN c_books(p_book_class) LOOP --BC 20210120 add p_book_type_code para.

FOR c_1 IN c_books(p_book_class,p_book_type_code) LOOP 

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_adjustments',
                   message   => 'Inside c_books Cursor'||
                                ' Book Type Code:'||c_1.book_type_code);


select set_of_books_id
into l_sob_id
from gl_sets_of_books
where set_of_books_id = (select set_of_books_id
                         from fa_book_controls
                         where book_type_code=c_1.book_type_code
                         union all
                         select set_of_books_id
                         from fa_mc_book_controls
                         where book_type_code=c_1.book_type_code);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_adjustments',
                   message   => 'l_sob_id:'||l_sob_id);


IF l_sob_id <> -1999
THEN
  BEGIN
   select mrc_sob_type_code, currency_code
   into l_sob_type, l_currency_code
   from gl_sets_of_books
   where set_of_books_id = l_sob_id;
  EXCEPTION
    WHEN OTHERS THEN
     l_sob_type := 'P';
  END;
ELSE
   l_sob_type := 'P';
END IF;


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_adjustments',
                   message   => 'l_sob_type:'||l_sob_type);

IF upper(l_sob_type) = 'R' THEN


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_adjustments',
                   message   => 'Before Procedure adjustments_mrc');

adjustments_mrc(p_sob_id => l_sob_id,
                p_sob_type => l_sob_type,
                p_book_class => c_1.book_class,
                p_book_type_code => c_1.book_type_code,
                p_from_period => p_from_period,
                p_to_period => p_to_period);

ELSE

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_adjustments',
                   message   => 'Before Procedure adjustments');

  adjustments(p_sob_id => l_sob_id,
              p_sob_type => l_sob_type,
              p_book_class => c_1.book_class,
              p_book_type_code => c_1.book_type_code,
              p_from_period => p_from_period,
              p_to_period => p_to_period);
END IF;


END LOOP;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_adjustments',
                   message   => ' AFter Cursor Loop End');

COMMIT;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_adjustments',
                   message   => 'End of Procedure load_adjustments');

EXCEPTION
WHEN OTHERS THEN
 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_adjustments',
                   message   => 'SQL error:'||sqlerrm);
END load_adjustments;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    get_addition_fiscal_year
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Function derives the Fiscal year for Asset Addition Transactions
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/

FUNCTION get_addition_fiscal_year(p_book_type IN VARCHAR2,
                                  p_period_counter1 IN NUMBER,
                                  p_period_counter2 IN NUMBER,
                                  p_date_effective IN DATE)
RETURN addition_period_record IS

l_addition_year_info addition_period_record;

BEGIN

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_addition_fiscal_year',
                   message   => 'Inside Function get_addition_fiscal_year'||
                                'p_book_type:'||p_book_type||
                                ' p_period_counter1:'||p_period_counter1||
                                ' p_period_counter2:'||p_period_counter2||
                                ' p_date_effective:'||p_date_effective);

select calendar_period_close_date,fiscal_year,period_name
into l_addition_year_info
from fa_deprn_periods
where book_type_code   = p_book_type   and
    period_counter  >= p_period_counter1  and
    period_counter  <= nvl(p_period_counter2, period_counter) and
    p_date_effective  between period_open_date and nvl(period_close_date, sysdate);


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_addition_fiscal_year',
                   message   => ' fiscal_year:'||l_addition_year_info.fiscal_year||
                                ' calendar_period_close_date:'||l_addition_year_info.calendar_period_close_date );

RETURN(l_addition_year_info);

EXCEPTION
WHEN OTHERS THEN
fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_addition_fiscal_year',
                   message   => 'SQL Error:'||SQLERRM);
RETURN(NULL);
END  get_addition_fiscal_year;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Procedure Name:  additions
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Procedure loads Asset additions for a given period into staging table
  Program Style:   Procedure Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
PROCEDURE additions(p_sob_id IN NUMBER,
                    p_sob_type IN VARCHAR2,
                    p_book_class IN varchar2,
                    p_book_type_code IN VARCHAR2,
                    p_from_period IN varchar2,
                    p_to_period IN varchar2) IS

CURSOR c_additions(cp_book_type   IN VARCHAR2,
                   cp_period1_pod in DATE,
                   cp_period2_pcd in DATE) IS
SELECT ad.asset_number     asset,
       ad.asset_id,
       ad.description     descr,
       cat.category_id,
       cat.segment1 asset_major_category,
       cat.segment2 asset_minor_category,
       ad.serial_number,
       ad.tag_number,
       th.book_type_code asset_book,
       falu.meaning                                                      asset_type,
       decode(ah.asset_type, 'CIP', cb.cip_cost_acct,cb.asset_cost_acct) gl_account,
       decode(ah.asset_type, 'CIP', null,cb.deprn_reserve_acct)          res_account,
      -- ad.asset_number          || ' - ' || ad.description               asset_number,
       bks.date_placed_in_service,
       bks.deprn_method_code                                             method,
       bks.life_in_months                                                life,
       bks.production_capacity                                           prod,
       bks.adjusted_rate                                                 adj_rate,
       decode (ah.asset_type, 'CIP', 0,nvl(ds.bonus_rate,0))             bonus_rate,
       sum(nvl(decode(adj1.debit_credit_flag,'DR',1,-1) * adj1.adjustment_amount, dd.addition_cost_to_clear) ) cost,
       sum(nvl(dd.ytd_deprn,0))                     ytd_deprn,
       sum(dd.deprn_reserve)                        deprn_reserve,
       th.source_transaction_header_id,
       th.transaction_header_id        thid,
       th.transaction_date_entered,
       th.date_effective,
       th.transaction_type_code,
       fl.segment1 country,
       fl.segment2 state,
       fl.segment3 city,
       fl.segment4 location,
       get_gl_string(cb.reserve_account_ccid) Depreciation_Reserve_account,
       get_gl_string(cb.asset_cost_account_ccid) asset_cost_account,
       get_gl_string(dh.code_combination_id) depreciation_account,
       cb.asset_cost_acct,
       cb.deprn_reserve_acct,
       dh.code_combination_id deprn_expense_account_ccid
FROM
      fa_lookups falu              ,
      fa_additions ad              ,
      fa_asset_history ah          ,
      fa_transaction_headers th    ,
      fa_category_books cb         ,
      fa_distribution_history dh   ,
      gl_code_combinations dhcc    ,
      fa_adjustments adj1      ,
      fa_books bks             ,
      fa_deprn_summary ds      ,
      fa_deprn_detail dd       ,
      fnd_currencies fc        ,
      fa_book_controls bc      ,
      gl_sets_of_books sob,
      fa_categories  cat,
      fa_locations fl
WHERE th.book_type_code = cp_book_type
  and th.date_effective between cp_period1_pod and cp_period2_pcd
  and adj1.book_type_code = th.book_type_code
  and adj1.transaction_header_id = th.transaction_header_id
  and ((adj1.source_type_code = 'CIP ADDITION' and adj1.adjustment_type = 'CIP COST') or
       (adj1.source_type_code = 'ADDITION' and adj1.adjustment_type = 'COST'))
  and dh.distribution_id = adj1.distribution_id
  and dhcc.code_combination_id                  = dh.code_combination_id
  and falu.lookup_type                          = 'ASSET TYPE'
  and ah.asset_type                             =  falu.lookup_code
  and ad.asset_id                               = th.asset_id
  and ah.asset_id                               = th.asset_id
  and th.date_effective                         >= ah.date_effective
  and th.date_effective                         < nvl(ah.date_ineffective, sysdate)
  and bks.transaction_header_id_in              = th.transaction_header_id
  and cb.book_type_code = th.book_type_code
  and cb.category_id = cat.category_id
  and cb.category_id = ah.category_id
  and bc.book_type_code = cp_book_type
  and sob.set_of_books_id = bc.set_of_books_id
  and sob.currency_code = fc.currency_code
  and dd.book_type_code (+)                     = adj1.book_type_code
  and dd.distribution_id (+)                    = adj1.distribution_id
  and dd.deprn_source_code (+)                  = 'B'
  and ds.book_type_code (+)                     = adj1.book_type_code
  and ds.asset_id (+)                           = adj1.asset_id
  and ds.period_counter (+)                     = adj1.period_counter_created
  and dh.location_id = fl.location_id(+)
GROUP BY ad.asset_number,
       ad.asset_id,
       ad.description,
       cat.category_id,
       cat.segment1,
       cat.segment2,
       ad.serial_number,
       ad.tag_number,
       th.book_type_code,
       falu.meaning,
       decode(ah.asset_type, 'CIP', cb.cip_cost_acct,cb.asset_cost_acct),
       decode(ah.asset_type, 'CIP', null,cb.deprn_reserve_acct),
       bks.date_placed_in_service,
       bks.deprn_method_code,
       bks.life_in_months,
       bks.production_capacity,
       bks.adjusted_rate,
       decode (ah.asset_type, 'CIP', 0,nvl(ds.bonus_rate,0)),
       fc.precision,
       th.transaction_header_id ,
       th.source_transaction_header_id,
       th.transaction_date_entered,
       th.date_effective,
       th.transaction_type_code,
       fl.segment1,
       fl.segment2,
       fl.segment3,
       fl.segment4 ,
       cb.reserve_account_ccid,
       cb.asset_cost_account_ccid,
       dh.code_combination_id,
       cb.asset_cost_acct,
       cb.deprn_reserve_acct
UNION
SELECT DISTINCT
       ad.asset_number     asset,
       ad.asset_id,
       ad.description     descr,
       cat.category_id,
       cat.segment1 asset_major_category,
       cat.segment2 asset_minor_category,
       ad.serial_number,
       ad.tag_number,
       th.book_type_code asset_book,
       falu.meaning                                            asset_type,
       decode(ah.asset_type, 'CIP', cb.cip_cost_acct,cb.asset_cost_acct) gl_account,
       decode(ah.asset_type, 'CIP', null, cb.deprn_reserve_acct)   res_account,
      -- AD.ASSET_NUMBER          || ' - ' || AD.DESCRIPTION     ASSET_NUMBER,
       bks.date_placed_in_service ,
       bks.deprn_method_code                                   method,
       bks.life_in_months                                      life,
       bks.production_capacity                                 prod,
       bks.adjusted_rate                                       adj_rate,
       decode (ah.asset_type, 'CIP', 0,
               nvl(ds.bonus_rate,0))                           bonus_rate,
       0                                                        cost,
       0                                                       ytd_deprn,
       0                                                      deprn_reserve,
       th.source_transaction_header_id,
       th.transaction_header_id        thid,
       th.transaction_date_entered,
       th.date_effective,
       th.transaction_type_code,
       fl.segment1 country,
       fl.segment2 state,
       fl.segment3 city,
       fl.segment4 location,
       get_gl_string(cb.reserve_account_ccid) Depreciation_Reserve_account,
       get_gl_string(cb.asset_cost_account_ccid) asset_cost_account,
       get_gl_string(dh.code_combination_id) depreciation_account,
       cb.asset_cost_acct,
       cb.deprn_reserve_acct,
       dh.code_combination_id deprn_expense_account_ccid
FROM
     fa_lookups falu              ,
      fa_additions ad              ,
      fa_asset_history ah          ,
      fa_category_books cb         ,
      gl_code_combinations dhcc    ,
      fa_distribution_history dh   ,
      fa_books bks             ,
      fa_deprn_summary ds      ,
      fnd_currencies fc            ,
      fa_book_controls bc      ,
      gl_sets_of_books sob         ,
      (select th.book_type_code ,
              th.transaction_header_id ,
              th.source_transaction_header_id,
              th.transaction_date_entered,
              th.transaction_type_code,
              th.asset_id ,
              th.date_effective ,
              dp.period_counter
         from fa_transaction_headers th ,
              fa_deprn_periods dp
        where th.book_type_code = cp_book_type AND
              th.transaction_type_code in ('ADDITION', 'CIP ADDITION') and
              th.date_effective BETWEEN cp_period1_pod AND cp_period2_pcd
          AND dp.book_type_code = th.book_type_code and
              th.date_effective between dp.period_open_date and
                                   nvl (dp.period_close_date, sysdate)
      ) th,
      fa_categories  cat,
      fa_locations fl
WHERE dh.asset_id = th.asset_id
  and th.date_effective                         >= dh.date_effective
  and th.date_effective                         < nvl(dh.date_ineffective, sysdate)
  and dhcc.code_combination_id                  = dh.code_combination_id
  and falu.lookup_type                          = 'ASSET TYPE'
  and ah.asset_type                             =  falu.lookup_code
  and ad.asset_id                               = th.asset_id
  and ah.asset_id                               = th.asset_id
  and th.date_effective                        >= ah.date_effective
  and th.date_effective                         < nvl(ah.date_ineffective, sysdate)
  and bks.transaction_header_id_in               = th.transaction_header_id
  and bks.cost = 0
  and cb.book_type_code = th.book_type_code
  and cb.category_id = ah.category_id
  and cb.category_id = cat.category_id
  and bc.book_type_code = cp_book_type
  and sob.set_of_books_id = bc.set_of_books_id
  and sob.currency_code = fc.currency_code
  and ds.book_type_code (+)                     = th.book_type_code
  and ds.asset_id (+)                           = th.asset_id
  and ds.period_counter (+)                     = th.period_counter
  and dh.location_id = fl.location_id(+)
order by asset_book,asset;


TYPE additions_type IS TABLE OF c_additions%ROWTYPE
INDEX BY PLS_INTEGER;

l_additions additions_type;


l_book book_record;
l_currency_code VARCHAR2(10);
l_company_name fa_system_controls.company_name%type;
l_category_flex_structure  fa_system_controls.category_flex_structure%type;
l_period_counter1 period_record;
l_period_counter2 period_record;
l_currency currency_exchange_record;
l_addition_year_info addition_period_record;

BEGIN

         -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'Inside the Procedure additions'||
                                ' p_sob_id:'||p_sob_id||
                                ' p_sob_type:'||p_sob_type||
                                ' p_book_type_code:'||p_book_type_code||
                                ' p_book_class:' || p_book_class||
                                ' p_from_period:'||p_from_period||
                                ' p_to_period:'||p_to_period);

select company_name,category_flex_structure
into l_company_name,l_category_flex_structure
from   fa_system_controls;

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'l_company_name:'||l_company_name||
                                ' l_category_flex_structure:'||l_category_flex_structure);

l_book :=  get_accounting_flex_structure(p_sob_type,p_book_type_code);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'Before l_period_counter1');

l_period_counter1 := get_period_info(p_book_type_code,p_from_period,p_sob_type);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'Before l_period_counter2');

l_period_counter2 := get_period_info(p_book_type_code,p_to_period,p_sob_type);

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'Before Cusor c_additions');

  OPEN c_additions(cp_book_type   => p_book_type_code,
                   cp_period1_pod => l_period_counter1.period_open_date,
                   cp_period2_pcd => l_period_counter2.period_close_date);
  LOOP

    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'Inside Cursor c_additions');

    FETCH c_additions BULK COLLECT INTO l_additions LIMIT 100;
    EXIT WHEN l_additions.count = 0;

      FOR indx IN 1..l_additions.count LOOP


         fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'Before l_addition_year_info');


                l_addition_year_info := get_addition_fiscal_year(p_book_type => p_book_type_code,
                                                                 p_period_counter1 => l_period_counter1.period_counter,
                                                                 p_period_counter2 => l_period_counter2.period_counter,
                                                                 p_date_effective => l_additions(indx).date_effective);

         fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'Inside c_additions loop'||
                                ' Asset:'||l_additions(indx).asset||
                                ' Currency:'||l_book.currency_code||
                                ' Cost:'||l_additions(indx).cost||
                                ' Transaction Date:'||l_additions(indx).transaction_date_entered||
                                ' calendar_period_close_date:'||l_addition_year_info.calendar_period_close_date||
                                ' Period Name:'||l_addition_year_info.period_name);

          l_currency := get_currency_conversion(l_additions(indx).cost,l_addition_year_info.calendar_period_close_date,l_book.currency_code);


          fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'Before Insert into xxfa_global_assets');

           INSERT INTO xxfa_global_assets(request_id,
                                          seq_no,
                                          transaction_type,
                                          asset_number,
                                          asset_description,
                                          asset_major_category,
                                          asset_minor_category,
                                          serial_number,
                                          tag_number,
                                          fiscal_year,
                                          asset_book,
                                          date_placed_in_service,
                                          life_in_months,
                                          country,
                                          state,
                                          city,
                                          location,
                                          asset_currency,
                                          asset_cost,
                                          transaction_date,
                                          exchange_rate,
                                          cost_in_usd,
                                          category_id,
                                          asset_type,
                                          transaction_header_id,
                                          source_transaction_header_id,
                                          asset_id,
                                          attribute1,
                                          book_type_code,
                                          book_class,
                                          sob_id,
                                          sob_type,
                                          company_name,
                                          category_flex_structure,
                                          asset_cost_acct,
                                          deprn_reserve_acct,
                                          depreciation_resrv_acct_string,
                                          asset_cost_account_string,
                                          depreciation_account_string,
                                          deprn_expense_account_ccid,
                                          period_entered)
                                    VALUES(p_request_id,   -- request_id
                                           xxfa_ga_seq.nextval,  -- seq_no
                                           'ADDITIONS',  -- transaction_type
                                           l_additions(indx).asset, -- asset_number
                                           l_additions(indx).descr, -- asset_description
                                           l_additions(indx).asset_major_category, -- asset_major_category
                                           l_additions(indx).asset_minor_category,  -- asset_minor_category
                                           l_additions(indx).serial_number,  -- serial_number
                                           l_additions(indx).tag_number, --tag_number
                                           l_addition_year_info.fiscal_year,  --fiscal_year
                                           l_additions(indx).asset_book,  --asset_book
                                           l_additions(indx).date_placed_in_service, -- date_placed_in_service
                                           l_additions(indx).life,  -- life_in_months
                                           l_additions(indx).country,
                                           l_additions(indx).state,
                                           l_additions(indx).city,
                                           l_additions(indx).location,
                                           l_currency.entered_currency,  -- asset_currency
                                           l_additions(indx).cost,  -- asset_cost
                                           l_additions(indx).transaction_date_entered, -- transaction_date
                                           l_currency.conversion_rate, -- exchange_rate
                                           l_currency.functional_currency_amount, -- cost_in_usd
                                           l_additions(indx).category_id,
                                           l_additions(indx).asset_type,
                                           l_additions(indx).thid, -- transaction_header_id
                                           l_additions(indx).source_transaction_header_id,
                                           l_additions(indx).asset_id,
                                           null, -- attribute1
                                           l_additions(indx).asset_book, --book_type_code,
                                           p_book_class,  -- book_class
                                           p_sob_id,  --sob_id
                                           p_sob_type, -- sob_type
                                           l_company_name,  -- company_name
                                           l_category_flex_structure, -- category_flex_structure
                                           l_additions(indx).asset_cost_acct,  -- asset_cost_acct
                                           l_additions(indx).deprn_reserve_acct, -- deprn_reserve_acct
                                           l_additions(indx).depreciation_reserve_account, -- depreciation_resrv_acct_string
                                           l_additions(indx).asset_cost_account, -- asset_cost_account_string
                                           l_additions(indx).depreciation_account,  -- depreciation_account_string
                                           l_additions(indx).deprn_expense_account_ccid,--deprn_expense_account_ccid
                                           l_addition_year_info.period_name -- period_entered
                                           );

            fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'After Insert into xxfa_global_assets');

      end loop;

    EXIT WHEN l_additions.count < 100;

  END LOOP;

  CLOSE c_additions;

   fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => ' AFter Cursor close');

  COMMIT;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'End of Procedure additions');

EXCEPTION
WHEN OTHERS THEN
 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions',
                   message   => 'SQL error:'||sqlerrm);
END additions;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Procedure Name:  additions_mrc
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Procedure loads Asset additions for a given period into staging table
  Program Style:   Procedure Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
PROCEDURE additions_mrc(p_sob_id IN NUMBER,
                        p_sob_type IN VARCHAR2,
                        p_book_class IN varchar2,
                        p_book_type_code IN VARCHAR2,
                        p_from_period IN varchar2,
                        p_to_period IN varchar2) IS

CURSOR c_additions(cp_book_type   IN VARCHAR2,
                   cp_period1_pod in DATE,
                   cp_period2_pcd in DATE) IS
SELECT ad.asset_number     asset,
       ad.asset_id,
       ad.description     descr,
       cat.category_id,
       cat.segment1 asset_major_category,
       cat.segment2 asset_minor_category,
       ad.serial_number,
       ad.tag_number,
       th.book_type_code asset_book,
       falu.meaning                                                      asset_type,
       decode(ah.asset_type, 'CIP', cb.cip_cost_acct,cb.asset_cost_acct) gl_account,
       decode(ah.asset_type, 'CIP', null,cb.deprn_reserve_acct)          res_account,
      -- ad.asset_number          || ' - ' || ad.description               asset_number,
       bks.date_placed_in_service,
       bks.deprn_method_code                                             method,
       bks.life_in_months                                                life,
       bks.production_capacity                                           prod,
       bks.adjusted_rate                                                 adj_rate,
       decode (ah.asset_type, 'CIP', 0,nvl(ds.bonus_rate,0))             bonus_rate,
       sum(nvl(decode(adj1.debit_credit_flag,'DR',1,-1) * adj1.adjustment_amount, dd.addition_cost_to_clear) ) cost,
       sum(nvl(dd.ytd_deprn,0))                     ytd_deprn,
       sum(dd.deprn_reserve)                        deprn_reserve,
       th.source_transaction_header_id,
       th.transaction_header_id        thid,
       th.transaction_date_entered,
       th.date_effective,
       th.transaction_type_code,
       fl.segment1 country,
       fl.segment2 state,
       fl.segment3 city,
       fl.segment4 location,
       get_gl_string(cb.reserve_account_ccid) Depreciation_Reserve_account,
       get_gl_string(cb.asset_cost_account_ccid) asset_cost_account,
       get_gl_string(dh.code_combination_id) depreciation_account,
       cb.asset_cost_acct,
       cb.deprn_reserve_acct,
       dh.code_combination_id deprn_expense_account_ccid
FROM
      fa_lookups falu              ,
      fa_additions ad              ,
      fa_asset_history ah          ,
      fa_transaction_headers th    ,
      fa_category_books cb         ,
      fa_distribution_history dh   ,
      gl_code_combinations dhcc    ,
      fa_adjustments_mrc_v adj1      ,
      fa_books_mrc_v bks             ,
      fa_deprn_summary_mrc_v ds      ,
      fa_deprn_detail_mrc_v dd       ,
      fnd_currencies fc        ,
      fa_book_controls_mrc_v bc      ,
      gl_sets_of_books sob,
      fa_categories  cat,
      fa_locations fl
WHERE th.book_type_code = cp_book_type
  and th.date_effective between cp_period1_pod and cp_period2_pcd
  and adj1.book_type_code = th.book_type_code
  and adj1.transaction_header_id = th.transaction_header_id
  and ((adj1.source_type_code = 'CIP ADDITION' and adj1.adjustment_type = 'CIP COST') or
       (adj1.source_type_code = 'ADDITION' and adj1.adjustment_type = 'COST'))
  and dh.distribution_id = adj1.distribution_id
  and dhcc.code_combination_id                  = dh.code_combination_id
  and falu.lookup_type                          = 'ASSET TYPE'
  and ah.asset_type                             =  falu.lookup_code
  and ad.asset_id                               = th.asset_id
  and ah.asset_id                               = th.asset_id
  and th.date_effective                         >= ah.date_effective
  and th.date_effective                         < nvl(ah.date_ineffective, sysdate)
  and bks.transaction_header_id_in              = th.transaction_header_id
  and cb.book_type_code = th.book_type_code
  and cb.category_id = cat.category_id
  and cb.category_id = ah.category_id
  and bc.book_type_code = cp_book_type
  and sob.set_of_books_id = bc.set_of_books_id
  and sob.currency_code = fc.currency_code
  and dd.book_type_code (+)                     = adj1.book_type_code
  and dd.distribution_id (+)                    = adj1.distribution_id
  and dd.deprn_source_code (+)                  = 'B'
  and ds.book_type_code (+)                     = adj1.book_type_code
  and ds.asset_id (+)                           = adj1.asset_id
  and ds.period_counter (+)                     = adj1.period_counter_created
  and dh.location_id = fl.location_id(+)
GROUP BY ad.asset_number,
       ad.asset_id,
       ad.description,
       cat.category_id,
       cat.segment1,
       cat.segment2,
       ad.serial_number,
       ad.tag_number,
       th.book_type_code,
       falu.meaning,
       decode(ah.asset_type, 'CIP', cb.cip_cost_acct,cb.asset_cost_acct),
       decode(ah.asset_type, 'CIP', null,cb.deprn_reserve_acct),
       bks.date_placed_in_service,
       bks.deprn_method_code,
       bks.life_in_months,
       bks.production_capacity,
       bks.adjusted_rate,
       decode (ah.asset_type, 'CIP', 0,nvl(ds.bonus_rate,0)),
       fc.precision,
       th.transaction_header_id ,
       th.source_transaction_header_id,
       th.transaction_date_entered,
       th.date_effective,
       th.transaction_type_code,
       fl.segment1,
       fl.segment2,
       fl.segment3,
       fl.segment4 ,
       cb.reserve_account_ccid,
       cb.asset_cost_account_ccid,
       dh.code_combination_id,
       cb.asset_cost_acct,
       cb.deprn_reserve_acct
UNION
SELECT DISTINCT
       ad.asset_number     asset,
       ad.asset_id,
       ad.description     descr,
       cat.category_id,
       cat.segment1 asset_major_category,
       cat.segment2 asset_minor_category,
       ad.serial_number,
       ad.tag_number,
       th.book_type_code asset_book,
       falu.meaning                                            asset_type,
       decode(ah.asset_type, 'CIP', cb.cip_cost_acct,cb.asset_cost_acct) gl_account,
       decode(ah.asset_type, 'CIP', null, cb.deprn_reserve_acct)   res_account,
      -- AD.ASSET_NUMBER          || ' - ' || AD.DESCRIPTION     ASSET_NUMBER,
       bks.date_placed_in_service ,
       bks.deprn_method_code                                   method,
       bks.life_in_months                                      life,
       bks.production_capacity                                 prod,
       bks.adjusted_rate                                       adj_rate,
       decode (ah.asset_type, 'CIP', 0,
               nvl(ds.bonus_rate,0))                           bonus_rate,
       0                                                        cost,
       0                                                       ytd_deprn,
       0                                                      deprn_reserve,
       th.source_transaction_header_id,
       th.transaction_header_id        thid,
       th.transaction_date_entered,
       th.date_effective,
       th.transaction_type_code,
       fl.segment1 country,
       fl.segment2 state,
       fl.segment3 city,
       fl.segment4 location,
       get_gl_string(cb.reserve_account_ccid) Depreciation_Reserve_account,
       get_gl_string(cb.asset_cost_account_ccid) asset_cost_account,
       get_gl_string(dh.code_combination_id) depreciation_account,
       cb.asset_cost_acct,
       cb.deprn_reserve_acct,
       dh.code_combination_id deprn_expense_account_ccid
FROM
     fa_lookups falu              ,
      fa_additions ad              ,
      fa_asset_history ah          ,
      fa_category_books cb         ,
      gl_code_combinations dhcc    ,
      fa_distribution_history dh   ,
      fa_books_mrc_v bks             ,
      fa_deprn_summary_mrc_v ds      ,
      fnd_currencies fc            ,
      fa_book_controls_mrc_v bc      ,
      gl_sets_of_books sob         ,
      (select th.book_type_code ,
              th.transaction_header_id ,
              th.source_transaction_header_id,
              th.transaction_date_entered,
              th.transaction_type_code,
              th.asset_id ,
              th.date_effective ,
              dp.period_counter
         from fa_transaction_headers th ,
              fa_deprn_periods_mrc_v dp
        where th.book_type_code = cp_book_type AND
              th.transaction_type_code in ('ADDITION', 'CIP ADDITION') and
              th.date_effective BETWEEN cp_period1_pod AND cp_period2_pcd
          AND dp.book_type_code = th.book_type_code and
              th.date_effective between dp.period_open_date and
                                   nvl (dp.period_close_date, sysdate)
      ) th,
      fa_categories  cat,
      fa_locations fl
WHERE dh.asset_id = th.asset_id
  and th.date_effective                         >= dh.date_effective
  and th.date_effective                         < nvl(dh.date_ineffective, sysdate)
  and dhcc.code_combination_id                  = dh.code_combination_id
  and falu.lookup_type                          = 'ASSET TYPE'
  and ah.asset_type                             =  falu.lookup_code
  and ad.asset_id                               = th.asset_id
  and ah.asset_id                               = th.asset_id
  and th.date_effective                        >= ah.date_effective
  and th.date_effective                         < nvl(ah.date_ineffective, sysdate)
  and bks.transaction_header_id_in               = th.transaction_header_id
  and bks.cost = 0
  and cb.book_type_code = th.book_type_code
  and cb.category_id = ah.category_id
  and cb.category_id = cat.category_id
  and bc.book_type_code = cp_book_type
  and sob.set_of_books_id = bc.set_of_books_id
  and sob.currency_code = fc.currency_code
  and ds.book_type_code (+)                     = th.book_type_code
  and ds.asset_id (+)                           = th.asset_id
  and ds.period_counter (+)                     = th.period_counter
  and dh.location_id = fl.location_id(+)
order by asset_book,asset;


TYPE additions_type IS TABLE OF c_additions%ROWTYPE
INDEX BY PLS_INTEGER;

l_additions additions_type;


l_book book_record;
l_currency_code VARCHAR2(10);
l_company_name fa_system_controls.company_name%type;
l_category_flex_structure  fa_system_controls.category_flex_structure%type;
l_period_counter1 period_record;
l_period_counter2 period_record;
l_currency currency_exchange_record;
l_addition_year_info addition_period_record;

BEGIN

         -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'Inside the Procedure additions_mrc'||
                                ' p_sob_id:'||p_sob_id||
                                ' p_sob_type:'||p_sob_type||
                                ' p_book_type_code:'||p_book_type_code||
                                ' p_book_class:' || p_book_class||
                                ' p_from_period:'||p_from_period||
                                ' p_to_period:'||p_to_period);

fnd_client_info.set_currency_context(p_sob_id);

select company_name,category_flex_structure
into l_company_name,l_category_flex_structure
from   fa_system_controls;

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'l_company_name:'||l_company_name||
                                ' l_category_flex_structure:'||l_category_flex_structure);

l_book :=  get_accounting_flex_structure(p_sob_type,p_book_type_code);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'Before l_period_counter1');

l_period_counter1 := get_period_info(p_book_type_code,p_from_period,p_sob_type);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'Before l_period_counter2');

l_period_counter2 := get_period_info(p_book_type_code,p_to_period,p_sob_type);

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'Before Cusor c_additions');

  OPEN c_additions(cp_book_type   => p_book_type_code,
                   cp_period1_pod => l_period_counter1.period_open_date,
                   cp_period2_pcd => l_period_counter2.period_close_date);
  LOOP

    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'Inside Cursor c_additions');

    FETCH c_additions BULK COLLECT INTO l_additions LIMIT 100;
    EXIT WHEN l_additions.count = 0;

      FOR indx IN 1..l_additions.count LOOP


           fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'Before l_addition_year_info');


                l_addition_year_info := get_addition_fiscal_year(p_book_type => p_book_type_code,
                                                                 p_period_counter1 => l_period_counter1.period_counter,
                                                                 p_period_counter2 => l_period_counter2.period_counter,
                                                                 p_date_effective => l_additions(indx).date_effective);

         fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'Inside c_additions loop'||
                                ' Asset:'||l_additions(indx).asset||
                                ' Currency:'||l_book.currency_code||
                                ' Cost:'||l_additions(indx).cost||
                                ' Transaction Date:'||l_additions(indx).transaction_date_entered||
                                ' calendar_period_close_date:'||l_addition_year_info.calendar_period_close_date||
                                ' Period Name:'||l_addition_year_info.period_name);

          l_currency := get_currency_conversion(l_additions(indx).cost,l_addition_year_info.calendar_period_close_date,l_book.currency_code);

          fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'Before Insert into xxfa_global_assets');

           INSERT INTO xxfa_global_assets(request_id,
                                          seq_no,
                                          transaction_type,
                                          asset_number,
                                          asset_description,
                                          asset_major_category,
                                          asset_minor_category,
                                          serial_number,
                                          tag_number,
                                          fiscal_year,
                                          asset_book,
                                          date_placed_in_service,
                                          life_in_months,
                                          country,
                                          state,
                                          city,
                                          location,
                                          asset_currency,
                                          asset_cost,
                                          transaction_date,
                                          exchange_rate,
                                          cost_in_usd,
                                          category_id,
                                          asset_type,
                                          transaction_header_id,
                                          source_transaction_header_id,
                                          asset_id,
                                          attribute1,
                                          book_type_code,
                                          book_class,
                                          sob_id,
                                          sob_type,
                                          company_name,
                                          category_flex_structure,
                                          asset_cost_acct,
                                          deprn_reserve_acct,
                                          depreciation_resrv_acct_string,
                                          asset_cost_account_string,
                                          depreciation_account_string,
                                          deprn_expense_account_ccid,
                                          period_entered)
                                    VALUES(p_request_id,   -- request_id
                                           xxfa_ga_seq.nextval,  -- seq_no
                                           'ADDITIONS',  -- transaction_type
                                           l_additions(indx).asset, -- asset_number
                                           l_additions(indx).descr, -- asset_description
                                           l_additions(indx).asset_major_category, -- asset_major_category
                                           l_additions(indx).asset_minor_category,  -- asset_minor_category
                                           l_additions(indx).serial_number,  -- serial_number
                                           l_additions(indx).tag_number, --tag_number
                                           l_addition_year_info.fiscal_year,  --fiscal_year
                                           l_additions(indx).asset_book,  --asset_book
                                           l_additions(indx).date_placed_in_service, -- date_placed_in_service
                                           l_additions(indx).life,  -- life_in_months
                                           l_additions(indx).country,
                                           l_additions(indx).state,
                                           l_additions(indx).city,
                                           l_additions(indx).location,
                                           l_currency.entered_currency,  -- asset_currency
                                           l_additions(indx).cost,  -- asset_cost
                                           l_additions(indx).transaction_date_entered, -- transaction_date
                                           l_currency.conversion_rate, -- exchange_rate
                                           l_currency.functional_currency_amount, -- cost_in_usd
                                           l_additions(indx).category_id,
                                           l_additions(indx).asset_type,
                                           l_additions(indx).thid, -- transaction_header_id
                                           l_additions(indx).source_transaction_header_id,
                                           l_additions(indx).asset_id,
                                           null, -- attribute1
                                           l_additions(indx).asset_book, --book_type_code,
                                           p_book_class,  -- book_class
                                           p_sob_id,  --sob_id
                                           p_sob_type, -- sob_type
                                           l_company_name,  -- company_name
                                           l_category_flex_structure, -- category_flex_structure
                                           l_additions(indx).asset_cost_acct,  -- asset_cost_acct
                                           l_additions(indx).deprn_reserve_acct, -- deprn_reserve_acct
                                           l_additions(indx).depreciation_reserve_account, -- depreciation_resrv_acct_string
                                           l_additions(indx).asset_cost_account, -- asset_cost_account_string
                                           l_additions(indx).depreciation_account,  -- depreciation_account_string
                                           l_additions(indx).deprn_expense_account_ccid, -- deprn_expense_account_ccid
                                           l_addition_year_info.period_name -- period_entered
                                           );

            fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'After Insert into xxfa_global_assets');

      end loop;

    EXIT WHEN l_additions.count < 100;

  END LOOP;

  CLOSE c_additions;

   fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => ' AFter Cursor close');

  COMMIT;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'End of Procedure additions_mrc');

EXCEPTION
WHEN OTHERS THEN
 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'additions_mrc',
                   message   => 'SQL error:'||sqlerrm);
END additions_mrc;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Procedure Name:  load_additions
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Procedure is a wrapper prorgam which calls the appropriate procedure for each asset book type
                   to load asset additions for a given period into staging table
  Program Style:   Procedure Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
PROCEDURE load_additions(p_book_class IN varchar2,
						 p_book_type_code IN VARCHAR2, --BC 20210120
                           p_from_period IN varchar2,
                           p_to_period IN varchar2) IS

CURSOR c_books(cp_book_class IN varchar2,cp_book_type_code IN varchar2) IS
select book_type_name,
       book_type_code,
       book_class
from fa_book_controls_sec
where book_class = cp_book_class
and   book_type_code = cp_book_type_code; --BC 20210120

l_sob_type varchar2(100);
l_sob_id NUMBER;
l_currency_code VARCHAR2(10);

BEGIN

   -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_additions',
                   message   => 'p_book_class:'||p_book_class||
                                ' p_from_period:'||p_from_period||
                                ' p_to_period:'||p_to_period);

FOR c_1 IN c_books(p_book_class,p_book_type_code) LOOP  --BC 20210120 add p_book_type_code

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_additions',
                   message   => 'Inside c_books Cursor'||
                                ' Book Type Code:'||c_1.book_type_code);


select set_of_books_id
into l_sob_id
from gl_sets_of_books
where set_of_books_id = (select set_of_books_id
                         from fa_book_controls
                         where book_type_code=c_1.book_type_code
                         union all
                         select set_of_books_id
                         from fa_mc_book_controls
                         where book_type_code=c_1.book_type_code);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_additions',
                   message   => 'l_sob_id:'||l_sob_id);


IF l_sob_id <> -1999
THEN
  BEGIN
   select mrc_sob_type_code, currency_code
   into l_sob_type, l_currency_code
   from gl_sets_of_books
   where set_of_books_id = l_sob_id;
  EXCEPTION
    WHEN OTHERS THEN
     l_sob_type := 'P';
  END;
ELSE
   l_sob_type := 'P';
END IF;


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_additions',
                   message   => 'l_sob_type:'||l_sob_type);

IF upper(l_sob_type) = 'R' THEN


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_additions',
                   message   => 'Before Procedure additions_mrc');

additions_mrc(p_sob_id => l_sob_id,
                p_sob_type => l_sob_type,
                p_book_class => c_1.book_class,
                p_book_type_code => c_1.book_type_code,
                p_from_period => p_from_period,
                p_to_period => p_to_period);

ELSE

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_additions',
                   message   => 'Before Procedure additions');

  additions(p_sob_id => l_sob_id,
              p_sob_type => l_sob_type,
              p_book_class => c_1.book_class,
              p_book_type_code => c_1.book_type_code,
              p_from_period => p_from_period,
              p_to_period => p_to_period);
END IF;


END LOOP;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_additions',
                   message   => ' AFter Cursor Loop End');

COMMIT;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_additions',
                   message   => 'End of Procedure load_additions');

EXCEPTION
WHEN OTHERS THEN
 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_additions',
                   message   => 'SQL error:'||sqlerrm);
END load_additions;

 --------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    get_segment_prompt
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Function gets GL Accounting String Segment Prompt based on the segment number
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION get_segment_prompt(p_coa_id IN NUMBER,
                            p_segment_num IN NUMBER)
RETURN VARCHAR2 IS

l_segment_prompt  VARCHAR2(80);

BEGIN

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_segment_prompt',
                   message   => 'Inside Function get_segment_prompt'||
                                ' p_coa_id:'||p_coa_id||
                                ' p_segment_num:'||p_segment_num);

select b.form_left_prompt
into l_segment_prompt
--b.form_left_prompt user_segment_name,
--b.description,
--a.segment_name,
--c.id_flex_structure_name,
--b.application_column_name,
--a.segment_num
from
fnd_id_flex_segments a,
fnd_id_flex_segments_tl b,
fnd_id_flex_structures_vl c
where
b.language = 'US'
and c.id_flex_num = b.id_flex_num
and c.id_flex_code = b.id_flex_code
and c.enabled_flag = 'Y'
and b.application_id = a.application_id
and b.id_flex_num = a.id_flex_num
and b.application_column_name = a.application_column_name
and b.id_flex_code = a.id_flex_code
and a.application_id = 101
and a.id_flex_code = 'GL#'
and a.id_flex_num = p_coa_id
and a.segment_num = p_segment_num;

RETURN(l_segment_prompt);


EXCEPTION
WHEN OTHERS THEN
fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_segment_prompt',
                   message   => 'SQL error:'||sqlerrm);
RETURN(NULL);

END get_segment_prompt;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    get_cc_segment_value
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         This Function derives individual segment values of a GL string based on CCID and segment column name
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION get_cc_segment_value(p_ccid IN NUMBER,
                              p_segment_column IN VARCHAR2)
RETURN VARCHAR2 IS

l_query VARCHAR2(1000);
l_segment_value varchar2(100);

BEGIN

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_cc_segment_value',
                   message   => 'Inside Function get_cc_segment_value'||
                                ' p_ccid:'||p_ccid||
                                ' p_segment_column:'||p_segment_column);


 l_query:=  'select '||p_segment_column||' from gl_code_combinations where code_combination_id = :ccid';

  EXECUTE IMMEDIATE l_query
  INTO l_segment_value
  USING p_ccid;

  fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_cc_segment_value',
                   message   => 'l_segment_value:'||l_segment_value);

  RETURN(l_segment_value);

EXCEPTION
WHEN OTHERS THEN
fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_cc_segment_value',
                   message   => 'SQL error:'||sqlerrm);
RETURN(NULL);

END get_cc_segment_value;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    afterpform
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         Standard report afterpform trigger Function
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION afterpform RETURN BOOLEAN IS
begin

     c_where_clause1 := 'WHERE request_id = :p_request_id';

return (TRUE);
END afterpform;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    beforereport
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         Standard report beforereport trigger Function
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION beforereport RETURN BOOLEAN  IS
begin

  -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'beforereport',
                   message   => 'Inside Function beforereport');

reset_sequence('xxfa.xxfa_ga_seq');

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'beforereport',
                   message   => 'Before load_adjustments');

--load_adjustments(p_book_class,p_from_period,p_to_period);
load_adjustments(p_book_class,p_book_type_code,p_from_period,p_to_period);  --BC 20210120 Add P_BOOK_TYPE_CODE to specify FA BOOK for reporting.


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'beforereport',
                   message   => 'Before Calling Procedure load_additions');

--load_additions(p_book_class,p_from_period,p_to_period);  --BC 20210120 Add P_BOOK_TYPE_CODE to specify FA BOOK for reporting
load_additions(p_book_class,p_book_type_code,p_from_period,p_to_period);

return (TRUE);
END beforereport;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    afterreport
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         Standard report afterreport trigger Function
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION afterreport RETURN BOOLEAN IS
BEGIN

--DELETE FROM xxfa_global_assets
--WHERE request_id = p_request_id;
--COMMIT;

return (TRUE);
END afterreport;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    get_reserve_retired
  Author's Name:   Sandeep Akula
  Date Written:    03-FEB-2016
  Purpose:         This Function derives the accumulated depreciation of an asset when it is retired
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  03-FEB-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION get_reserve_retired(p_asset_id IN NUMBER,
                             p_asset_book IN VARCHAR2,
                             p_transaction_header_id IN NUMBER,
                             p_distribution_id IN NUMBER)
RETURN NUMBER IS

l_adjustment_amount NUMBER;

BEGIN

      -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_reserve_retired',
                   message   => 'Inside the Procedure get_reserve_retired'||
                                ' p_asset_id:'||p_asset_id||
                                ' p_asset_book:'||p_asset_book||
                                ' p_transaction_header_id:'||p_transaction_header_id||
                                ' p_distribution_id:'||p_distribution_id);

select decode(debit_credit_flag, 'DR', 1, 'CR', -1, 0) * adjustment_amount
into l_adjustment_amount
from fa_adjustments
where asset_id = p_asset_id and
      book_type_code = p_asset_book and
      transaction_header_id = p_transaction_header_id and
      distribution_id = p_distribution_id and
      source_type_code = 'RETIREMENT' and
      adjustment_type = 'RESERVE';


RETURN(l_adjustment_amount);

EXCEPTION
WHEN OTHERS THEN
fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_reserve_retired',
                   message   => 'SQL error:'||sqlerrm);
RETURN(NULL);
END get_reserve_retired;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    get_cost_history
  Author's Name:   Sandeep Akula
  Date Written:    03-FEB-2016
  Purpose:         This Function derives the cost History of an asset
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  03-FEB-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION get_cost_history(p_sob_id IN NUMBER,
                          p_book_type_code IN VARCHAR2,
                          p_asset_id IN NUMBER,
                          p_transaction_header_id IN NUMBER)
RETURN  cost_history_record IS

l_cost_hist cost_history_record;

BEGIN

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_cost_history',
                   message   => 'Inside function get_cost_history'||
                                ' p_sob_id:'||p_sob_id||
                                ' p_book_type_code:'||p_book_type_code||
                                ' p_asset_id:'||p_asset_id||
                                ' p_transaction_header_id:'||p_transaction_header_id);

select transaction_header_id_in,
       transaction_type,
       period_entered,
       period_effective,
       current_cost,
       transaction_date_entered,
       fiscal_year,
       date_effective
into l_cost_hist
from fa_financial_inquiry_cost_v
where sob_id= p_sob_id and
      book_type_code= p_book_type_code and
      asset_id = p_asset_id and
      transaction_header_id_in = p_transaction_header_id;

RETURN(l_cost_hist);

EXCEPTION
WHEN OTHERS THEN
fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'get_cost_history',
                   message   => 'SQL error:'||sqlerrm);
RETURN(NULL);
END get_cost_history;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Procedure Name:  retirements
  Author's Name:   Sandeep Akula
  Date Written:    01-FEB-2016
  Purpose:         This Procedure loads Asset retirements for a given period into staging table
  Program Style:   Procedure Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  01-FEB-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
PROCEDURE retirements(p_sob_id IN NUMBER,
                    p_sob_type IN VARCHAR2,
                    p_book_class IN varchar2,
                    p_book_type_code IN VARCHAR2,
                    p_from_period IN varchar2,
                    p_to_period IN varchar2) IS

CURSOR c_retirements(cp_book_type   IN VARCHAR2,
                     cp_period1_pod in DATE,
                     cp_period2_pcd in DATE) IS
SELECT book_type_code,
       asset_type,
       account,
       descr,
       asset_number,
       date_retired,
       asset_num_desc,
       transaction_type_code,
       asset_id,
       source_transaction_header_id,
       transaction_header_id,
       date_placed_in_service,
       SUM(cost_retired) cost_retired,
       SUM(nbv) nbv,
       SUM(proceeds) proceeds,
       SUM(removal) removal,
       SUM(reval_rsv_ret) reval_rsv_ret,
       code,
       Depreciation_Reserve_account,
       asset_cost_account,
       depreciation_account,
       asset_cost_acct,
       deprn_reserve_acct,
       deprn_expense_account_ccid,
       date_effective,
       transaction_date_entered,
       SUM(adjustment_amount) adjustment_amount,
       (-SUM(ret.nbv) + SUM(ret.proceeds) - SUM(ret.removal) + SUM(ret.reval_rsv_ret)) gain_loss
FROM
(SELECT     /*+ ordered */
    th.book_type_code,
    falu.meaning                asset_type,
    decode (ah.asset_type,'CIP', cb.cip_cost_acct,cb.asset_cost_acct) account,
    --ad.asset_id,
    ad.description descr,
    ad.asset_number,
    ret.date_retired,
    ad.asset_number || ' - ' || ad.description        asset_num_desc,
    th.transaction_type_code,
    th.asset_id,
    th.source_transaction_header_id,
    th.transaction_header_id,
    books.date_placed_in_service,
    sum(decode(aj.adjustment_type, 'COST', 1, 'CIP COST', 1, 0) *
        decode(aj.debit_credit_flag, 'DR', -1, 'CR', 1, 0) *
        aj.adjustment_amount)        cost_retired,
    sum(decode(aj.adjustment_type, 'NBV RETIRED', -1, 0) *
        decode(aj.debit_credit_flag, 'DR', -1, 'CR', 1, 0) *
        aj.adjustment_amount)        nbv,
    sum(decode(aj.adjustment_type, 'PROCEEDS CLR', 1, 'PROCEEDS', 1, 0) *
        decode(aj.debit_credit_flag, 'DR', 1, 'CR', -1, 0) *
        aj.adjustment_amount)        proceeds,
    sum(decode(aj.adjustment_type, 'REMOVALCOST', -1, 0) *
        decode(aj.debit_credit_flag, 'DR', -1, 'CR', 1, 0) *
        aj.adjustment_amount)        removal,
    sum(decode(aj.adjustment_type,'REVAL RSV RET',1,0)*
        decode(aj.debit_credit_flag, 'DR',-1,'CR',1,0)*
         aj.adjustment_amount)        reval_rsv_ret,
    decode (th.transaction_type_code,'REINSTATEMENT', '*','PARTIAL RETIREMENT','P',to_char(null)) code,
    get_gl_string(cb.reserve_account_ccid) Depreciation_Reserve_account,
    get_gl_string(cb.asset_cost_account_ccid) asset_cost_account,
    get_gl_string(dh.code_combination_id) depreciation_account,
    cb.asset_cost_acct,
    cb.deprn_reserve_acct,
    dh.code_combination_id deprn_expense_account_ccid,
    th.date_effective,
    th.transaction_date_entered,
    get_reserve_retired(th.asset_id,th.book_type_code,th.transaction_header_id,dh.distribution_id) adjustment_amount
FROM
    fa_transaction_headers        th,
    fa_additions            ad,
    fa_books                books,
    fa_retirements            ret,
    fa_adjustments            aj,
    fa_distribution_history        dh,
    gl_code_combinations        dhcc,
    fa_asset_history            ah,
    fa_category_books            cb,
    fa_lookups            falu
WHERE
    th.date_effective         >=cp_period1_pod
and    th.date_effective         <= cp_period2_pcd
and    th.book_type_code         =  cp_book_type
and    th.transaction_key        = 'R'
and    ret.book_type_code        = cp_book_type
and    ret.asset_id        = books.asset_id
and    decode (th.transaction_type_code,'REINSTATEMENT', ret.transaction_header_id_out,ret.transaction_header_id_in)    = th.transaction_header_id
and    ad.asset_id        = th.asset_id
and    aj.asset_id        = ret.asset_id
and    aj.book_type_code    = cp_book_type
and    aj.adjustment_type not in (select  'PROCEEDS'
                                  from fa_adjustments aj1
                                  where aj1.book_type_code = aj.book_type_code
                                    and aj1.asset_id = aj.asset_id
                                    and aj1.transaction_header_id = aj.transaction_header_id
                                    and aj1.adjustment_type = 'PROCEEDS CLR')
and    aj.transaction_header_id    = th.transaction_header_id
and    ah.asset_id        = ad.asset_id
and    ah.date_effective        <= th.date_effective
and    nvl(ah.date_ineffective, th.date_effective+1)  > th.date_effective
and    falu.lookup_code        = ah.asset_type
and    falu.lookup_type        = 'ASSET TYPE'
and    books.transaction_header_id_out = th.transaction_header_id
and    books.book_type_code    = cp_book_type
and    books.asset_id        = ad.asset_id
and    cb.category_id        = ah.category_id
and    cb.book_type_code        = cp_book_type
and    dh.distribution_id    = aj.distribution_id
and    th.asset_id = dh.asset_id
and    dhcc.code_combination_id    = dh.code_combination_id
GROUP BY
    th.book_type_code,
    falu.meaning,
    th.transaction_type_code,
    th.asset_id,
    cb.asset_cost_acct,
    cb.cip_cost_acct,
    ad.asset_number,
     ad.description,
    books.date_placed_in_service,
    ret.date_retired,
    th.transaction_header_id,
    ah.asset_type,
    ret.gain_loss_amount,
    cb.reserve_account_ccid,
    cb.asset_cost_account_ccid,
    dh.code_combination_id,
    cb.asset_cost_acct,
    cb.deprn_reserve_acct,
    th.source_transaction_header_id,
    th.transaction_header_id,
    th.date_effective,
    th.transaction_date_entered,
    dh.distribution_id
UNION
SELECT  /*+ ordered */   --added query for bug10255794
    th.book_type_code,
    falu.meaning       asset_type,
    decode (ah.asset_type,'CIP', cb.cip_cost_acct,cb.asset_cost_acct)  account,
    --ad.asset_id,
    ad.description descr,
    ad.asset_number,
    ret.date_retired,
    ad.asset_number || ' - ' || ad.description        asset_num_desc,
    th.transaction_type_code,
    th.asset_id,
    th.source_transaction_header_id,
    th.transaction_header_id,
    books.date_placed_in_service,
    0        cost_retired,
    0    nbv,
    nvl(ret.proceeds_of_sale,0)    proceeds,
    nvl(ret.cost_of_removal,0)        removal,
    0        reval_rsv_ret,
    decode (ret.status,'DELETED', '*',to_char(null)) code,
    get_gl_string(cb.reserve_account_ccid) Depreciation_Reserve_account,
    get_gl_string(cb.asset_cost_account_ccid) asset_cost_account,
    get_gl_string(dh.code_combination_id) depreciation_account,
    cb.asset_cost_acct,
    cb.deprn_reserve_acct,
    dh.code_combination_id deprn_expense_account_ccid,
    th.date_effective,
    th.transaction_date_entered,
    get_reserve_retired(th.asset_id,th.book_type_code,th.transaction_header_id,dh.distribution_id) adjustment_amount
from
    fa_transaction_headers        th,
    fa_additions            ad,
    fa_books                books,
    fa_retirements            ret,
    (select dh.* from fa_transaction_headers th1,
            fa_distribution_history dh,
            fa_book_controls bc,
            fa_transaction_headers th2
     where th1.book_type_code = cp_book_type
        and th1.transaction_type_code = 'FULL RETIREMENT'
        and th1.date_effective between cp_period1_pod and cp_period2_pcd
        and th1.asset_id = dh.asset_id
        and bc.book_type_code = th1.book_type_code
        and bc.distribution_source_book = dh.book_type_code
        and th1.date_effective <= nvl(dh.date_ineffective,th1.date_effective)
        and th1.asset_id = th2.asset_id
        and th2.book_type_code = cp_book_type
        and th2.transaction_type_code = 'REINSTATEMENT'
        and th2.date_effective between cp_period1_pod and cp_period2_pcd
        and th2.date_effective >=  dh.date_effective)        dh,
    gl_code_combinations        dhcc,
    fa_asset_history            ah,
    fa_category_books            cb,
    fa_lookups            falu
WHERE
    th.date_effective         >= cp_period1_pod
and    th.date_effective         <= cp_period2_pcd
and    th.book_type_code         =  cp_book_type
and    th.transaction_key        = 'R'
and    ret.book_type_code        = cp_book_type
and    ret.asset_id        = books.asset_id
and    ret.transaction_header_id_out = th.transaction_header_id
and    ad.asset_id        = th.asset_id
and    ah.asset_id        = ad.asset_id
and    ah.date_effective        <= th.date_effective
and    nvl(ah.date_ineffective, th.date_effective+1)
                > th.date_effective
and    falu.lookup_code        = ah.asset_type
and    falu.lookup_type        = 'ASSET TYPE'
and    books.transaction_header_id_out
                = th.transaction_header_id
and    books.book_type_code    = cp_book_type
and    books.asset_id        = ad.asset_id
and    cb.category_id        = ah.category_id
and    cb.book_type_code        =  cp_book_type
and    th.asset_id = dh.asset_id
and    dhcc.code_combination_id    = dh.code_combination_id
and    th.transaction_type_code = 'REINSTATEMENT'
and    ret.cost_retired = 0
and    ret.cost_of_removal = 0
and    ret.proceeds_of_sale = 0
GROUP BY
    th.book_type_code,
    falu.meaning,
    th.transaction_type_code,
    th.asset_id,
    cb.asset_cost_acct,
    cb.cip_cost_acct,
    ad.asset_number,
     ad.description,
    books.date_placed_in_service,
    ret.date_retired,
    th.transaction_header_id,
    ah.asset_type,
    ret.gain_loss_amount,
    ret.status,
    ret.proceeds_of_sale,
    ret.cost_of_removal,
    cb.reserve_account_ccid,
    cb.asset_cost_account_ccid,
    dh.code_combination_id,
    cb.asset_cost_acct,
    cb.deprn_reserve_acct,
    th.source_transaction_header_id,
    th.transaction_header_id,
    th.date_effective,
    th.transaction_date_entered,
    dh.distribution_id
) ret
GROUP BY book_type_code,
       asset_type,
       account,
       descr,
       asset_number,
       date_retired,
       asset_num_desc,
       transaction_type_code,
       asset_id,
       source_transaction_header_id,
       transaction_header_id,
       date_placed_in_service,
       code,
       Depreciation_Reserve_account,
       asset_cost_account,
       depreciation_account,
       asset_cost_acct,
       deprn_reserve_acct,
       deprn_expense_account_ccid,
       date_effective,
       transaction_date_entered
ORDER BY ret.book_type_code,ret.asset_number;


TYPE retirements_type IS TABLE OF c_retirements%ROWTYPE
INDEX BY PLS_INTEGER;

l_retirements retirements_type;


l_book book_record;
l_currency_code VARCHAR2(10);
l_company_name fa_system_controls.company_name%type;
l_category_flex_structure  fa_system_controls.category_flex_structure%type;
l_period_counter1 period_record;
l_period_counter2 period_record;
l_cost_retired currency_exchange_record;
l_reserve_retired currency_exchange_record;
l_net_book_value_retired currency_exchange_record;
l_proceeds_of_sale currency_exchange_record;
l_removal_cost currency_exchange_record;
l_gain_loss currency_exchange_record;
l_addition_year_info addition_period_record;
l_cost_history cost_history_record;

BEGIN

         -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'Inside the Procedure retirements'||
                                ' p_sob_id:'||p_sob_id||
                                ' p_sob_type:'||p_sob_type||
                                ' p_book_type_code:'||p_book_type_code||
                                ' p_book_class:' || p_book_class||
                                ' p_from_period:'||p_from_period||
                                ' p_to_period:'||p_to_period);

select sc.company_name,
    sc.category_flex_structure
    --sc.location_flex_structure,
    --sc.asset_key_flex_structure,
    --bc.book_type_code,
    --bc.book_class,
    --bc.accounting_flex_structure,
    --bc.distribution_source_book,
    --sob.currency_code
into l_company_name,l_category_flex_structure
from
    fa_system_controls    sc,
    fa_book_controls      bc,
    gl_sets_of_books      sob
where
    bc.book_type_code = p_book_type_code and
    sob.set_of_books_id = bc.set_of_books_id;


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'l_company_name:'||l_company_name||
                                ' l_category_flex_structure:'||l_category_flex_structure);

l_book :=  get_accounting_flex_structure(p_sob_type,p_book_type_code);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'Before l_period_counter1');

l_period_counter1 := get_period_info(p_book_type_code,p_from_period,p_sob_type);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'Before l_period_counter2');

l_period_counter2 := get_period_info(p_book_type_code,p_to_period,p_sob_type);

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'Before Cusor c_retirements');

  OPEN c_retirements(cp_book_type   => p_book_type_code,
                     cp_period1_pod => l_period_counter1.period_open_date,
                     cp_period2_pcd => l_period_counter2.period_close_date);
  LOOP

    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'Inside Cursor c_retirements');

    FETCH c_retirements BULK COLLECT INTO l_retirements LIMIT 100;
    EXIT WHEN l_retirements.count = 0;

      FOR indx IN 1..l_retirements.count LOOP


         fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'Before l_addition_year_info');


                l_addition_year_info := get_addition_fiscal_year(p_book_type => p_book_type_code,
                                                                 p_period_counter1 => l_period_counter1.period_counter,
                                                                 p_period_counter2 => l_period_counter2.period_counter,
                                                                 p_date_effective => l_retirements(indx).date_effective);

         fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'Inside c_retirements loop'||
                                ' Asset:'||l_retirements(indx).asset_number||
                                ' Asset ID:'||l_retirements(indx).asset_id||
                                ' Currency:'||l_book.currency_code||
                                ' Asset Book :'||l_retirements(indx).book_type_code||
                                ' Transaction Header ID:'||l_retirements(indx).transaction_header_id||
                                ' Transaction Date:'||l_retirements(indx).transaction_date_entered||
                                ' calendar_period_close_date:'||l_addition_year_info.calendar_period_close_date||
                                ' Cost Retired:'||l_retirements(indx).cost_retired||
                                ' NBV :'||l_retirements(indx).nbv||
                                ' Proceeds of Sale :'||l_retirements(indx).proceeds||
                                ' Removal Cost :'||l_retirements(indx).removal||
                                ' Gain Loos :'||l_retirements(indx).gain_loss
                                );

          l_cost_retired := get_currency_conversion(l_retirements(indx).cost_retired,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_reserve_retired  := get_currency_conversion(l_retirements(indx).adjustment_amount,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_net_book_value_retired  := get_currency_conversion(l_retirements(indx).nbv,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_proceeds_of_sale  := get_currency_conversion(l_retirements(indx).proceeds,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_removal_cost  := get_currency_conversion(l_retirements(indx).removal,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_gain_loss  := get_currency_conversion(l_retirements(indx).gain_loss,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_cost_history := get_cost_history(p_sob_id,l_retirements(indx).book_type_code,l_retirements(indx).asset_id,l_retirements(indx).transaction_header_id);


          fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'Before Insert into xxfa_global_asset_retirements');

          INSERT INTO xxfa_global_asset_retirements(request_id,
                                                    seq_no,
                                                    transaction_type,
                                                    book_type_code,
                                                    book_class,
                                                    sob_id,
                                                    sob_type,
                                                    asset_id,
                                                    asset_type,
                                                    asset_number,
                                                    asset_description,
                                                    asset_book,
                                                    date_placed_in_service,
                                                    transaction_header_id,
                                                    source_transaction_header_id,
                                                    transaction_date,
                                                    period_effective,
                                                    period_entered,
                                                    asset_currency,
                                                    cost_retired,
                                                    reserve_retired,
                                                    net_book_value_retired,
                                                    proceeds_of_sale,
                                                    removal_cost,
                                                    gain_loss,
                                                    exchange_rate,
                                                    conversion_date,
                                                    cost_retired_usd,
                                                    reserve_retired_usd,
                                                    net_book_value_retired_usd,
                                                    proceeds_of_sale_usd,
                                                    removal_cost_usd,
                                                    gain_loss_usd,
                                                    deprn_expense_account_ccid,
                                                    depreciation_account_string,
                                                    asset_cost_account_string,
                                                    asset_cost_acct,
                                                    deprn_reserve_acct,
                                                    depreciation_resrv_acct_string,
                                                    company_name,
                                                    category_flex_structure)
                                            VALUES(p_request_id,   -- request_id
                                                   xxfa_ga_ret_seq.nextval,  -- seq_no
                                                   'RETIREMENTS',  -- transaction_type
                                                   l_retirements(indx).book_type_code, --book_type_code,
                                                   p_book_class,  -- book_class
                                                   p_sob_id,  --sob_id
                                                   p_sob_type, -- sob_type
                                                   l_retirements(indx).asset_id,
                                                   l_retirements(indx).asset_type,
                                                   l_retirements(indx).asset_number, -- asset_number
                                                   l_retirements(indx).descr, -- asset_description
                                                   l_retirements(indx).book_type_code, --asset_book
                                                   l_retirements(indx).date_placed_in_service, -- date_placed_in_service
                                                   l_retirements(indx).transaction_header_id, -- transaction_header_id
                                                   l_retirements(indx).source_transaction_header_id, -- source_transaction_header_id
                                                   l_retirements(indx).transaction_date_entered, -- transaction_date
                                                   l_cost_history.period_effective, --period_effective
                                                   l_cost_history.period_entered, -- period_entered
                                                   l_cost_retired.entered_currency,  -- asset_currency
                                                   l_retirements(indx).cost_retired,
                                                   l_retirements(indx).adjustment_amount, -- reserve_retired
                                                   l_retirements(indx).nbv,--net_book_value_retired
                                                   l_retirements(indx).proceeds,-- proceeds_of_sale
                                                   l_retirements(indx).removal,-- removal_cost
                                                   l_retirements(indx).gain_loss, -- gain_loss
                                                   l_cost_retired.conversion_rate, -- exchange_rate
                                                   l_cost_retired.conversion_date, -- conversion_date,
                                                   l_cost_retired.functional_currency_amount, -- cost_retired_usd,
                                                   l_reserve_retired.functional_currency_amount, -- reserve_retired_usd,
                                                   l_net_book_value_retired.functional_currency_amount,-- net_book_value_retired_usd,
                                                   l_proceeds_of_sale.functional_currency_amount,-- proceeds_of_sale_usd,
                                                   l_removal_cost.functional_currency_amount,-- removal_cost_usd,
                                                   l_gain_loss.functional_currency_amount,-- gain_loss_usd,
                                                   l_retirements(indx).deprn_expense_account_ccid,--deprn_expense_account_ccid
                                                   l_retirements(indx).depreciation_account,  -- depreciation_account_string
                                                   l_retirements(indx).asset_cost_account, -- asset_cost_account_string
                                                   l_retirements(indx).asset_cost_acct,  -- asset_cost_acct
                                                   l_retirements(indx).deprn_reserve_acct, -- deprn_reserve_acct
                                                   l_retirements(indx).depreciation_reserve_account, -- depreciation_resrv_acct_string
                                                   l_company_name,  -- company_name
                                                   l_category_flex_structure -- category_flex_structure
                                                   --l_retirements(indx).category_id,
                                                   );

            fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'After Insert into xxfa_global_asset_retirements');

      end loop;

    EXIT WHEN l_retirements.count < 100;

  END LOOP;

  CLOSE c_retirements;

   fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => ' AFter Cursor close');

  COMMIT;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'End of Procedure retirements');

EXCEPTION
WHEN OTHERS THEN
 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements',
                   message   => 'SQL error:'||sqlerrm);
END retirements;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Procedure Name:  retirements_mrc
  Author's Name:   Sandeep Akula
  Date Written:    01-FEB-2016
  Purpose:         This Procedure loads Asset retirements for a given period into staging table
  Program Style:   Procedure Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  01-FEB-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
PROCEDURE retirements_mrc(p_sob_id IN NUMBER,
                          p_sob_type IN VARCHAR2,
                          p_book_class IN varchar2,
                          p_book_type_code IN VARCHAR2,
                          p_from_period IN varchar2,
                          p_to_period IN varchar2) IS

CURSOR c_retirements(cp_book_type   IN VARCHAR2,
                     cp_period1_pod in DATE,
                     cp_period2_pcd in DATE) IS
SELECT book_type_code,
       asset_type,
       account,
       descr,
       asset_number,
       date_retired,
       asset_num_desc,
       transaction_type_code,
       asset_id,
       source_transaction_header_id,
       transaction_header_id,
       date_placed_in_service,
       SUM(cost_retired) cost_retired,
       SUM(nbv) nbv,
       SUM(proceeds) proceeds,
       SUM(removal) removal,
       SUM(reval_rsv_ret) reval_rsv_ret,
       code,
       Depreciation_Reserve_account,
       asset_cost_account,
       depreciation_account,
       asset_cost_acct,
       deprn_reserve_acct,
       deprn_expense_account_ccid,
       date_effective,
       transaction_date_entered,
       SUM(adjustment_amount) adjustment_amount,
       (-SUM(ret.nbv) + SUM(ret.proceeds) - SUM(ret.removal) + SUM(ret.reval_rsv_ret)) gain_loss
FROM
(SELECT     /*+ ordered */
    th.book_type_code,
    falu.meaning                asset_type,
    decode (ah.asset_type,'CIP', cb.cip_cost_acct,cb.asset_cost_acct) account,
    --ad.asset_id,
    ad.description descr,
    ad.asset_number,
    ret.date_retired,
    ad.asset_number || ' - ' || ad.description        asset_num_desc,
    th.transaction_type_code,
    th.asset_id,
    th.source_transaction_header_id,
    th.transaction_header_id,
    books.date_placed_in_service,
    sum(decode(aj.adjustment_type, 'COST', 1, 'CIP COST', 1, 0) *
        decode(aj.debit_credit_flag, 'DR', -1, 'CR', 1, 0) *
        aj.adjustment_amount)        cost_retired,
    sum(decode(aj.adjustment_type, 'NBV RETIRED', -1, 0) *
        decode(aj.debit_credit_flag, 'DR', -1, 'CR', 1, 0) *
        aj.adjustment_amount)        nbv,
    sum(decode(aj.adjustment_type, 'PROCEEDS CLR', 1, 'PROCEEDS', 1, 0) *
        decode(aj.debit_credit_flag, 'DR', 1, 'CR', -1, 0) *
        aj.adjustment_amount)        proceeds,
    sum(decode(aj.adjustment_type, 'REMOVALCOST', -1, 0) *
        decode(aj.debit_credit_flag, 'DR', -1, 'CR', 1, 0) *
        aj.adjustment_amount)        removal,
    sum(decode(aj.adjustment_type,'REVAL RSV RET',1,0)*
        decode(aj.debit_credit_flag, 'DR',-1,'CR',1,0)*
         aj.adjustment_amount)        reval_rsv_ret,
    decode (th.transaction_type_code,'REINSTATEMENT', '*','PARTIAL RETIREMENT','P',to_char(null)) code,
    get_gl_string(cb.reserve_account_ccid) Depreciation_Reserve_account,
    get_gl_string(cb.asset_cost_account_ccid) asset_cost_account,
    get_gl_string(dh.code_combination_id) depreciation_account,
    cb.asset_cost_acct,
    cb.deprn_reserve_acct,
    dh.code_combination_id deprn_expense_account_ccid,
    th.date_effective,
    th.transaction_date_entered,
    get_reserve_retired(th.asset_id,th.book_type_code,th.transaction_header_id,dh.distribution_id) adjustment_amount
FROM
    fa_transaction_headers        th,
    fa_additions            ad,
    fa_books_mrc_v          books,
    fa_retirements_mrc_v            ret,
    fa_adjustments_mrc_v            aj,
    fa_distribution_history        dh,
    gl_code_combinations        dhcc,
    fa_asset_history            ah,
    fa_category_books            cb,
    fa_lookups            falu
WHERE
    th.date_effective         >=cp_period1_pod
and    th.date_effective         <= cp_period2_pcd
and    th.book_type_code         =  cp_book_type
and    th.transaction_key        = 'R'
and    ret.book_type_code        = cp_book_type
and    ret.asset_id        = books.asset_id
and    decode (th.transaction_type_code,'REINSTATEMENT', ret.transaction_header_id_out,ret.transaction_header_id_in)    = th.transaction_header_id
and    ad.asset_id        = th.asset_id
and    aj.asset_id        = ret.asset_id
and    aj.book_type_code    = cp_book_type
and    aj.adjustment_type not in (select  'PROCEEDS'
                                  from fa_adjustments_mrc_v aj1
                                  where aj1.book_type_code = aj.book_type_code
                                    and aj1.asset_id = aj.asset_id
                                    and aj1.transaction_header_id = aj.transaction_header_id
                                    and aj1.adjustment_type = 'PROCEEDS CLR')
and    aj.transaction_header_id    = th.transaction_header_id
and    ah.asset_id        = ad.asset_id
and    ah.date_effective        <= th.date_effective
and    nvl(ah.date_ineffective, th.date_effective+1)  > th.date_effective
and    falu.lookup_code        = ah.asset_type
and    falu.lookup_type        = 'ASSET TYPE'
and    books.transaction_header_id_out = th.transaction_header_id
and    books.book_type_code    = cp_book_type
and    books.asset_id        = ad.asset_id
and    cb.category_id        = ah.category_id
and    cb.book_type_code        = cp_book_type
and    dh.distribution_id    = aj.distribution_id
and    th.asset_id = dh.asset_id
and    dhcc.code_combination_id    = dh.code_combination_id
GROUP BY
    th.book_type_code,
    falu.meaning,
    th.transaction_type_code,
    th.asset_id,
    cb.asset_cost_acct,
    cb.cip_cost_acct,
    ad.asset_number,
     ad.description,
    books.date_placed_in_service,
    ret.date_retired,
    th.transaction_header_id,
    ah.asset_type,
    ret.gain_loss_amount,
    cb.reserve_account_ccid,
    cb.asset_cost_account_ccid,
    dh.code_combination_id,
    cb.asset_cost_acct,
    cb.deprn_reserve_acct,
    th.source_transaction_header_id,
    th.transaction_header_id,
    th.date_effective,
    th.transaction_date_entered,
    dh.distribution_id
UNION
SELECT  /*+ ordered */   --added query for bug10255794
    th.book_type_code,
    falu.meaning       asset_type,
    decode (ah.asset_type,'CIP', cb.cip_cost_acct,cb.asset_cost_acct)  account,
    --ad.asset_id,
    ad.description descr,
    ad.asset_number,
    ret.date_retired,
    ad.asset_number || ' - ' || ad.description        asset_num_desc,
    th.transaction_type_code,
    th.asset_id,
    th.source_transaction_header_id,
    th.transaction_header_id,
    books.date_placed_in_service,
    0        cost_retired,
    0    nbv,
    nvl(ret.proceeds_of_sale,0)    proceeds,
    nvl(ret.cost_of_removal,0)        removal,
    0        reval_rsv_ret,
    decode (ret.status,'DELETED', '*',to_char(null)) code,
    get_gl_string(cb.reserve_account_ccid) Depreciation_Reserve_account,
    get_gl_string(cb.asset_cost_account_ccid) asset_cost_account,
    get_gl_string(dh.code_combination_id) depreciation_account,
    cb.asset_cost_acct,
    cb.deprn_reserve_acct,
    dh.code_combination_id deprn_expense_account_ccid,
    th.date_effective,
    th.transaction_date_entered,
    get_reserve_retired(th.asset_id,th.book_type_code,th.transaction_header_id,dh.distribution_id) adjustment_amount
from
    fa_transaction_headers        th,
    fa_additions            ad,
    fa_books_mrc_v         books,
    fa_retirements_mrc_v   ret,
    (select dh.* from fa_transaction_headers th1,
            fa_distribution_history dh,
            fa_book_controls bc,
            fa_transaction_headers th2
     where th1.book_type_code = cp_book_type
        and th1.transaction_type_code = 'FULL RETIREMENT'
        and th1.date_effective between cp_period1_pod and cp_period2_pcd
        and th1.asset_id = dh.asset_id
        and bc.book_type_code = th1.book_type_code
        and bc.distribution_source_book = dh.book_type_code
        and th1.date_effective <= nvl(dh.date_ineffective,th1.date_effective)
        and th1.asset_id = th2.asset_id
        and th2.book_type_code = cp_book_type
        and th2.transaction_type_code = 'REINSTATEMENT'
        and th2.date_effective between cp_period1_pod and cp_period2_pcd
        and th2.date_effective >=  dh.date_effective)        dh,
    gl_code_combinations        dhcc,
    fa_asset_history            ah,
    fa_category_books            cb,
    fa_lookups            falu
WHERE
    th.date_effective         >= cp_period1_pod
and    th.date_effective         <= cp_period2_pcd
and    th.book_type_code         =  cp_book_type
and    th.transaction_key        = 'R'
and    ret.book_type_code        = cp_book_type
and    ret.asset_id        = books.asset_id
and    ret.transaction_header_id_out = th.transaction_header_id
and    ad.asset_id        = th.asset_id
and    ah.asset_id        = ad.asset_id
and    ah.date_effective        <= th.date_effective
and    nvl(ah.date_ineffective, th.date_effective+1)
                > th.date_effective
and    falu.lookup_code        = ah.asset_type
and    falu.lookup_type        = 'ASSET TYPE'
and    books.transaction_header_id_out
                = th.transaction_header_id
and    books.book_type_code    = cp_book_type
and    books.asset_id        = ad.asset_id
and    cb.category_id        = ah.category_id
and    cb.book_type_code        =  cp_book_type
and    th.asset_id = dh.asset_id
and    dhcc.code_combination_id    = dh.code_combination_id
and    th.transaction_type_code = 'REINSTATEMENT'
and    ret.cost_retired = 0
and    ret.cost_of_removal = 0
and    ret.proceeds_of_sale = 0
GROUP BY
    th.book_type_code,
    falu.meaning,
    th.transaction_type_code,
    th.asset_id,
    cb.asset_cost_acct,
    cb.cip_cost_acct,
    ad.asset_number,
     ad.description,
    books.date_placed_in_service,
    ret.date_retired,
    th.transaction_header_id,
    ah.asset_type,
    ret.gain_loss_amount,
    ret.status,
    ret.proceeds_of_sale,
    ret.cost_of_removal,
    cb.reserve_account_ccid,
    cb.asset_cost_account_ccid,
    dh.code_combination_id,
    cb.asset_cost_acct,
    cb.deprn_reserve_acct,
    th.source_transaction_header_id,
    th.transaction_header_id,
    th.date_effective,
    th.transaction_date_entered,
    dh.distribution_id
) ret
GROUP BY book_type_code,
       asset_type,
       account,
       descr,
       asset_number,
       date_retired,
       asset_num_desc,
       transaction_type_code,
       asset_id,
       source_transaction_header_id,
       transaction_header_id,
       date_placed_in_service,
       code,
       Depreciation_Reserve_account,
       asset_cost_account,
       depreciation_account,
       asset_cost_acct,
       deprn_reserve_acct,
       deprn_expense_account_ccid,
       date_effective,
       transaction_date_entered
ORDER BY ret.book_type_code,ret.asset_number;


TYPE retirements_type IS TABLE OF c_retirements%ROWTYPE
INDEX BY PLS_INTEGER;

l_retirements retirements_type;


l_book book_record;
l_currency_code VARCHAR2(10);
l_company_name fa_system_controls.company_name%type;
l_category_flex_structure  fa_system_controls.category_flex_structure%type;
l_period_counter1 period_record;
l_period_counter2 period_record;
l_cost_retired currency_exchange_record;
l_reserve_retired currency_exchange_record;
l_net_book_value_retired currency_exchange_record;
l_proceeds_of_sale currency_exchange_record;
l_removal_cost currency_exchange_record;
l_gain_loss currency_exchange_record;
l_addition_year_info addition_period_record;
l_cost_history cost_history_record;

BEGIN

         -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'Inside the Procedure retirements_mrc'||
                                ' p_sob_id:'||p_sob_id||
                                ' p_sob_type:'||p_sob_type||
                                ' p_book_type_code:'||p_book_type_code||
                                ' p_book_class:' || p_book_class||
                                ' p_from_period:'||p_from_period||
                                ' p_to_period:'||p_to_period);

fnd_client_info.set_currency_context(p_sob_id);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'Before deriving Company Name');

select sc.company_name,
    sc.category_flex_structure
    --sc.location_flex_structure,
    --sc.asset_key_flex_structure,
    --bc.book_type_code,
    --bc.book_class,
    --bc.accounting_flex_structure,
    --bc.distribution_source_book,
    --sob.currency_code
into l_company_name,l_category_flex_structure
from
    fa_system_controls    sc,
    fa_book_controls      bc,
    gl_sets_of_books      sob
where
    bc.book_type_code = p_book_type_code and
    sob.set_of_books_id = bc.set_of_books_id;


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'l_company_name:'||l_company_name||
                                ' l_category_flex_structure:'||l_category_flex_structure);

l_book :=  get_accounting_flex_structure(p_sob_type,p_book_type_code);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'Before l_period_counter1');

l_period_counter1 := get_period_info(p_book_type_code,p_from_period,p_sob_type);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'Before l_period_counter2');

l_period_counter2 := get_period_info(p_book_type_code,p_to_period,p_sob_type);

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'Before Cusor c_retirements');

  OPEN c_retirements(cp_book_type   => p_book_type_code,
                     cp_period1_pod => l_period_counter1.period_open_date,
                     cp_period2_pcd => l_period_counter2.period_close_date);
  LOOP

    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'Inside Cursor c_retirements');

    FETCH c_retirements BULK COLLECT INTO l_retirements LIMIT 100;
    EXIT WHEN l_retirements.count = 0;

      FOR indx IN 1..l_retirements.count LOOP


         fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'Before l_addition_year_info');


                l_addition_year_info := get_addition_fiscal_year(p_book_type => p_book_type_code,
                                                                 p_period_counter1 => l_period_counter1.period_counter,
                                                                 p_period_counter2 => l_period_counter2.period_counter,
                                                                 p_date_effective => l_retirements(indx).date_effective);

         fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'Inside c_retirements loop'||
                                ' Asset:'||l_retirements(indx).asset_number||
                                ' Asset ID:'||l_retirements(indx).asset_id||
                                ' Currency:'||l_book.currency_code||
                                ' Asset Book :'||l_retirements(indx).book_type_code||
                                ' Transaction Header ID:'||l_retirements(indx).transaction_header_id||
                                ' Transaction Date:'||l_retirements(indx).transaction_date_entered||
                                ' calendar_period_close_date:'||l_addition_year_info.calendar_period_close_date||
                                ' Cost Retired:'||l_retirements(indx).cost_retired||
                                ' NBV :'||l_retirements(indx).nbv||
                                ' Proceeds of Sale :'||l_retirements(indx).proceeds||
                                ' Removal Cost :'||l_retirements(indx).removal||
                                ' Gain Loos :'||l_retirements(indx).gain_loss
                                );

          l_cost_retired := get_currency_conversion(l_retirements(indx).cost_retired,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_reserve_retired  := get_currency_conversion(l_retirements(indx).adjustment_amount,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_net_book_value_retired  := get_currency_conversion(l_retirements(indx).nbv,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_proceeds_of_sale  := get_currency_conversion(l_retirements(indx).proceeds,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_removal_cost  := get_currency_conversion(l_retirements(indx).removal,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_gain_loss  := get_currency_conversion(l_retirements(indx).gain_loss,l_addition_year_info.calendar_period_close_date,l_book.currency_code);
          l_cost_history := get_cost_history(p_sob_id,l_retirements(indx).book_type_code,l_retirements(indx).asset_id,l_retirements(indx).transaction_header_id);


          fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'Before Insert into xxfa_global_asset_retirements');

          INSERT INTO xxfa_global_asset_retirements(request_id,
                                                    seq_no,
                                                    transaction_type,
                                                    book_type_code,
                                                    book_class,
                                                    sob_id,
                                                    sob_type,
                                                    asset_id,
                                                    asset_type,
                                                    asset_number,
                                                    asset_description,
                                                    asset_book,
                                                    date_placed_in_service,
                                                    transaction_header_id,
                                                    source_transaction_header_id,
                                                    transaction_date,
                                                    period_effective,
                                                    period_entered,
                                                    asset_currency,
                                                    cost_retired,
                                                    reserve_retired,
                                                    net_book_value_retired,
                                                    proceeds_of_sale,
                                                    removal_cost,
                                                    gain_loss,
                                                    exchange_rate,
                                                    conversion_date,
                                                    cost_retired_usd,
                                                    reserve_retired_usd,
                                                    net_book_value_retired_usd,
                                                    proceeds_of_sale_usd,
                                                    removal_cost_usd,
                                                    gain_loss_usd,
                                                    deprn_expense_account_ccid,
                                                    depreciation_account_string,
                                                    asset_cost_account_string,
                                                    asset_cost_acct,
                                                    deprn_reserve_acct,
                                                    depreciation_resrv_acct_string,
                                                    company_name,
                                                    category_flex_structure)
                                            VALUES(p_request_id,   -- request_id
                                                   xxfa_ga_ret_seq.nextval,  -- seq_no
                                                   'RETIREMENTS',  -- transaction_type
                                                   l_retirements(indx).book_type_code, --book_type_code,
                                                   p_book_class,  -- book_class
                                                   p_sob_id,  --sob_id
                                                   p_sob_type, -- sob_type
                                                   l_retirements(indx).asset_id,
                                                   l_retirements(indx).asset_type,
                                                   l_retirements(indx).asset_number, -- asset_number
                                                   l_retirements(indx).descr, -- asset_description
                                                   l_retirements(indx).book_type_code, --asset_book
                                                   l_retirements(indx).date_placed_in_service, -- date_placed_in_service
                                                   l_retirements(indx).transaction_header_id, -- transaction_header_id
                                                   l_retirements(indx).source_transaction_header_id, -- source_transaction_header_id
                                                   l_retirements(indx).transaction_date_entered, -- transaction_date
                                                   l_cost_history.period_effective, --period_effective
                                                   l_cost_history.period_entered, -- period_entered
                                                   l_cost_retired.entered_currency,  -- asset_currency
                                                   l_retirements(indx).cost_retired,
                                                   l_retirements(indx).adjustment_amount, -- reserve_retired
                                                   l_retirements(indx).nbv,--net_book_value_retired
                                                   l_retirements(indx).proceeds,-- proceeds_of_sale
                                                   l_retirements(indx).removal,-- removal_cost
                                                   l_retirements(indx).gain_loss, -- gain_loss
                                                   l_cost_retired.conversion_rate, -- exchange_rate
                                                   l_cost_retired.conversion_date, -- conversion_date,
                                                   l_cost_retired.functional_currency_amount, -- cost_retired_usd,
                                                   l_reserve_retired.functional_currency_amount, -- reserve_retired_usd,
                                                   l_net_book_value_retired.functional_currency_amount,-- net_book_value_retired_usd,
                                                   l_proceeds_of_sale.functional_currency_amount,-- proceeds_of_sale_usd,
                                                   l_removal_cost.functional_currency_amount,-- removal_cost_usd,
                                                   l_gain_loss.functional_currency_amount,-- gain_loss_usd,
                                                   l_retirements(indx).deprn_expense_account_ccid,--deprn_expense_account_ccid
                                                   l_retirements(indx).depreciation_account,  -- depreciation_account_string
                                                   l_retirements(indx).asset_cost_account, -- asset_cost_account_string
                                                   l_retirements(indx).asset_cost_acct,  -- asset_cost_acct
                                                   l_retirements(indx).deprn_reserve_acct, -- deprn_reserve_acct
                                                   l_retirements(indx).depreciation_reserve_account, -- depreciation_resrv_acct_string
                                                   l_company_name,  -- company_name
                                                   l_category_flex_structure -- category_flex_structure
                                                   --l_retirements(indx).category_id,
                                                   );

            fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'After Insert into xxfa_global_asset_retirements');

      end loop;

    EXIT WHEN l_retirements.count < 100;

  END LOOP;

  CLOSE c_retirements;

   fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => ' AFter Cursor close');

  COMMIT;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'End of Procedure retirements_mrc');

EXCEPTION
WHEN OTHERS THEN
 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'retirements_mrc',
                   message   => 'SQL error:'||sqlerrm);
END retirements_mrc;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Procedure Name:  load_retirements
  Author's Name:   Sandeep Akula
  Date Written:    04-FEB-2016
  Purpose:         This Procedure is a wrapper program which calls the appropriate procedure for each asset book type
                   to load asset retirements for a given period into staging table
  Program Style:   Procedure Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  04-FEB-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
PROCEDURE load_retirements(p_book_class IN varchar2,
                           p_book_type_code IN varchar2, --BC 20210120
                           p_from_period IN varchar2,
                           p_to_period IN varchar2) IS

CURSOR c_books(cp_book_class IN varchar2, cp_book_type_code IN varchar2) IS
select book_type_name,
       book_type_code,
       book_class
from fa_book_controls_sec
where book_class = cp_book_class
and   book_type_code = cp_book_type_code; --BC 20210120

l_sob_type varchar2(100);
l_sob_id NUMBER;
l_currency_code VARCHAR2(10);

BEGIN

   -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_retirements',
                   message   => 'p_book_class:'||p_book_class||
                                ' p_from_period:'||p_from_period||
                                ' p_to_period:'||p_to_period);

--FOR c_1 IN c_books(p_book_class) LOOP
FOR c_1 IN c_books(p_book_class,p_book_type_code) LOOP  --BC 20210120

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_retirements',
                   message   => 'Inside c_books Cursor'||
                                ' Book Type Code:'||c_1.book_type_code);


select set_of_books_id
into l_sob_id
from gl_sets_of_books
where set_of_books_id = (select set_of_books_id
                         from fa_book_controls
                         where book_type_code=c_1.book_type_code
                         union all
                         select set_of_books_id
                         from fa_mc_book_controls
                         where book_type_code=c_1.book_type_code);

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_retirements',
                   message   => 'l_sob_id:'||l_sob_id);


IF l_sob_id <> -1999
THEN
  BEGIN
   select mrc_sob_type_code, currency_code
   into l_sob_type, l_currency_code
   from gl_sets_of_books
   where set_of_books_id = l_sob_id;
  EXCEPTION
    WHEN OTHERS THEN
     l_sob_type := 'P';
  END;
ELSE
   l_sob_type := 'P';
END IF;


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_retirements',
                   message   => 'l_sob_type:'||l_sob_type);

IF upper(l_sob_type) = 'R' THEN


fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_retirements',
                   message   => 'Before Procedure retirements_mrc');

retirements_mrc(p_sob_id => l_sob_id,
                p_sob_type => l_sob_type,
                p_book_class => c_1.book_class,
                p_book_type_code => c_1.book_type_code,
                p_from_period => p_from_period,
                p_to_period => p_to_period);

ELSE

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_retirements',
                   message   => 'Before Procedure retirements');

  retirements(p_sob_id => l_sob_id,
              p_sob_type => l_sob_type,
              p_book_class => c_1.book_class,
              p_book_type_code => c_1.book_type_code,
              p_from_period => p_from_period,
              p_to_period => p_to_period);
END IF;


END LOOP;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_retirements',
                   message   => ' AFter Cursor Loop End');

COMMIT;

 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_retirements',
                   message   => 'End of Procedure load_retirements');

EXCEPTION
WHEN OTHERS THEN
 fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'load_retirements',
                   message   => 'SQL error:'||sqlerrm);
END load_retirements;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    ret_afterpform
  Author's Name:   Sandeep Akula
  Date Written:    04-FEB-2016
  Purpose:         Standard report afterpform trigger Function
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  04-FEB-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION ret_afterpform RETURN BOOLEAN IS
begin

     c_where_clause1 := 'WHERE request_id = :p_request_id';

return (TRUE);
END ret_afterpform;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:   ret_beforereport
  Author's Name:   Sandeep Akula
  Date Written:    04-FEB-2016
  Purpose:         Standard report beforereport trigger Function
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  04-FEB-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION ret_beforereport RETURN BOOLEAN  IS
begin

  -- Debug Message
    fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'ret_beforereport',
                   message   => 'Inside Function ret_beforereport');

reset_sequence('xxfa.xxfa_ga_ret_seq');

fnd_log.string(log_level => fnd_log.level_event,
                   module    => c_debug_module || 'ret_beforereport',
                   message   => 'Before Calling Procedure load_retirements');

--load_retirements(p_book_class,p_from_period,p_to_period);
load_retirements(p_book_class,p_book_type_code,p_from_period,p_to_period);  --BC 20210120

return (TRUE);
END ret_beforereport;

--------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Function Name:    ret_afterreport
  Author's Name:   Sandeep Akula
  Date Written:    04-FEB-2016
  Purpose:         Standard report afterreport trigger Function
  Program Style:   Function Definition
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  04-FEB-2016        1.0                  Sandeep Akula     Initial Version
  ---------------------------------------------------------------------------------------------------*/
FUNCTION ret_afterreport RETURN BOOLEAN IS
BEGIN

null;

return (TRUE);
END ret_afterreport;
END XXFA_ASSET_PKG;

/
