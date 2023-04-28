--------------------------------------------------------
--  DDL for Package Body XXFA_BALREP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXFA_BALREP_PKG" AS
  /*$Header: fabalrepb.pls 120.15.12020000.5 2013/11/19 11:25:39 bmaddine ship $*/
  PROCEDURE load_workers(p_book_type_code IN VARCHAR2,
                                         p_request_id     IN NUMBER ,
                                         p_errbuf  OUT NOCOPY VARCHAR2,
                                         p_retcode OUT NOCOPY NUMBER) IS
     l_total_requests NUMBER;
  BEGIN
    fnd_profile.get('FA_NUM_PARALLEL_REQUESTS', l_total_requests);
    l_total_requests := nvl(l_total_requests, 1);


    INSERT INTO fa_worker_jobs (start_range, end_range, worker_num,
                                status, request_id)
          SELECT MIN(asset_id), MAX(asset_id), unit_id,
	                       'UNASSIGNED', p_request_id
            FROM (SELECT /*+ parallel(BK) */
                   asset_id,
                   ntile(par.val) over(ORDER BY asset_id) as unit_id
                  FROM fa_books bk, ( select l_total_requests as val
		                      from   sys.dual) par
                   WHERE bk.book_type_code =  p_book_type_code
                     AND bk.transaction_header_id_out IS NULL)
           GROUP BY unit_id;

    COMMIT;
    p_retcode := 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := SQLCODE;
      p_errbuf  := SQLERRM;
      RAISE fnd_api.g_exc_unexpected_error;
  END load_workers;

  PROCEDURE launch_workers(book                     IN VARCHAR2,
                           report_type              IN VARCHAR2,
                           report_style             IN VARCHAR2,
                           l_request_id             IN NUMBER,
                           period1_pc               IN NUMBER,
                           period1_pod              IN DATE,
                           period1_pcd              IN DATE,
                           period2_pc               IN NUMBER,
                           period2_pcd              IN DATE,
                           distribution_source_book IN VARCHAR2,
                           p_total_requests1        IN NUMBER,
                           l_errbuf                 OUT NOCOPY VARCHAR2,
                           l_retcode                OUT NOCOPY NUMBER) IS
    TYPE num_tbl_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
    l_bool boolean;
    l_num_requests  number := nvl(p_total_requests1, 1);
    l_child_requests num_tbl_type;
  BEGIN
    -- set the mode
    l_bool := fnd_request.set_mode(false);
    FOR i IN 1 ..l_num_requests  LOOP

      l_child_requests(i) := fnd_request.submit_request('OFA',
                                                     'RXFAPOGT',
                                                     NULL,
                                                     SYSDATE,
                                                     FALSE,
                                                     book,
                                                     report_type, --'COST'
                                                     report_style,
                                                     l_request_id,
                                                     i, --worker number
                                                     period1_pc,
                                                     period1_pod,
                                                     period1_pcd,
                                                     period2_pc,
                                                     period2_pcd,
                                                     distribution_source_book);

      COMMIT;
    END LOOP;
  EXCEPTION WHEN OTHERS THEN
     RAISE;
  END launch_workers;

  -- Bug 8902344 : Changed UNION to UNION ALL in all the inserts
  PROCEDURE get_adjustments(book                     IN VARCHAR2,
                            distribution_source_book IN VARCHAR2,
                            period1_pc               IN NUMBER,
                            period2_pc               IN NUMBER,
                            report_type              IN VARCHAR2,
                            balance_type             IN VARCHAR2,
                            start_range              IN NUMBER,
                            end_range                IN NUMBER,
                            h_request_id             IN NUMBER) IS
    h_set_of_books_id NUMBER;
    h_reporting_flag  VARCHAR2(1);
  BEGIN

    -- get mrc related info
    BEGIN
      -- h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
      SELECT to_number(substrb(userenv('CLIENT_INFO'), 45, 10))
        INTO h_set_of_books_id
        FROM dual;

      IF (h_set_of_books_id = -1) THEN
        h_set_of_books_id := NULL;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        h_set_of_books_id := NULL;
    END;

    IF (h_set_of_books_id IS NOT NULL) THEN
      IF NOT
          fa_cache_pkg.fazcsob(x_set_of_books_id   => h_set_of_books_id,
                               x_mrc_sob_type_code => h_reporting_flag) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      SELECT set_of_books_id
        INTO h_set_of_books_id
        FROM fa_book_controls
       WHERE book_type_code = book;

      h_reporting_flag := 'P';
    END IF;

    -- Fix for Bug #1892406.  Run only if CRL not installed.
    IF (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'N') THEN

      IF (h_reporting_flag = 'R') THEN
        /* Bug 7498880: Added new query for upgraded periods */
        INSERT INTO xxfa_balances_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT dh.asset_id,
                 dh.code_combination_id,
                 aj.code_combination_id,
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_transaction_headers  th,
                 fa_asset_history        ah,
                 fa_mc_adjustments       aj,
                 fa_deprn_periods        dp
           WHERE dh.book_type_code = distribution_source_book
             AND dh.asset_id BETWEEN start_range AND end_range --Anuj
             AND aj.asset_id = dh.asset_id
             AND aj.book_type_code = book
             AND aj.distribution_id = dh.distribution_id
	     AND aj.set_of_books_id = h_set_of_books_id
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND DP.xla_conversion_status is not null
             AND AJ.code_combination_id is not null
             AND th.transaction_header_id = aj.transaction_header_id
             AND ah.asset_id = dh.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND th.transaction_header_id BETWEEN
                 ah.transaction_header_id_in AND
                 nvl(ah.transaction_header_id_out - 1,
                     th.transaction_header_id)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    aj.code_combination_id,
                    aj.source_type_code
          UNION ALL
          SELECT /*+ leading(AJ) */
                 dh.asset_id,
                 dh.code_combination_id,
                 lines.code_combination_id, --AJ.Code_Combination_ID,
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_transaction_headers  th,
                 fa_asset_history        ah,
                 fa_mc_adjustments       aj,
                 fa_deprn_periods        dp
                 /* SLA Changes */,
                 xla_ae_headers         headers,
                 xla_ae_lines           lines,
                 xla_distribution_links links
           WHERE dh.book_type_code = distribution_source_book
             AND dh.asset_id BETWEEN start_range AND end_range --Anuj
             AND aj.asset_id = dh.asset_id
             AND aj.book_type_code = book
             AND aj.distribution_id = dh.distribution_id
	     AND aj.set_of_books_id = h_set_of_books_id
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND (dp.xla_conversion_status is null or
                  aj.code_combination_id is null)
             AND th.transaction_header_id = aj.transaction_header_id
             AND ah.asset_id = dh.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND th.transaction_header_id BETWEEN
                 ah.transaction_header_id_in AND
                 nvl(ah.transaction_header_id_out - 1,
                     th.transaction_header_id)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
                /* SLA Changes */
             AND links.source_distribution_id_num_1 =
                 aj.transaction_header_id
             AND links.source_distribution_id_num_2 = aj.adjustment_line_id
             AND links.application_id = 140
             AND links.source_distribution_type = 'TRX'
             AND headers.application_id = 140
             AND headers.ae_header_id = links.ae_header_id
             AND headers.ledger_id = h_set_of_books_id
             AND lines.ae_header_id = links.ae_header_id
             AND lines.ae_line_num = links.ae_line_num
             AND lines.application_id = 140
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    lines.code_combination_id, --AJ.Code_Combination_ID,
                    aj.source_type_code;

      ELSE
        /* Bug 7498880: Added new query for upgraded periods */
        -- Added for compatibility issues 1/29/16
        IF (report_type != 'RESERVE') THEN

        INSERT INTO xxfa_balances_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT dh.asset_id,
                 dh.code_combination_id,
                 aj.code_combination_id,
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_transaction_headers  th,
                 fa_asset_history        ah,
                 fa_adjustments          aj,
                 fa_deprn_periods        dp
           WHERE dh.book_type_code = distribution_source_book
             AND dh.asset_id BETWEEN start_range AND end_range --Anuj
             AND aj.asset_id = dh.asset_id
             AND aj.book_type_code = book
             AND aj.distribution_id = dh.distribution_id
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND dp.xla_conversion_status IS NOT NULL
             AND aj.code_combination_id IS NOT NULL
             AND th.transaction_header_id = aj.transaction_header_id
             AND ah.asset_id = dh.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND th.transaction_header_id BETWEEN
                 ah.transaction_header_id_in AND
                 nvl(ah.transaction_header_id_out - 1,
                     th.transaction_header_id)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    aj.code_combination_id,
                    aj.source_type_code
          UNION ALL
          SELECT /*+ leading(AJ) */
                 dh.asset_id,
                 dh.code_combination_id,
                 lines.code_combination_id, --AJ.Code_Combination_ID,
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_transaction_headers  th,
                 fa_asset_history        ah,
                 fa_adjustments          aj,
                 fa_deprn_periods        dp
                 /* SLA Changes */,
                 xla_ae_headers         headers,
                 xla_ae_lines           lines,
                 xla_distribution_links links
           WHERE dh.book_type_code = distribution_source_book
             AND dh.asset_id BETWEEN start_range AND end_range --Anuj
             AND aj.asset_id = dh.asset_id
             AND aj.book_type_code = book
             AND aj.distribution_id = dh.distribution_id
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND (dp.xla_conversion_status IS NULL OR
                 aj.code_combination_id IS NULL)
             AND th.transaction_header_id = aj.transaction_header_id
             AND ah.asset_id = dh.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND th.transaction_header_id BETWEEN
                 ah.transaction_header_id_in AND
                 nvl(ah.transaction_header_id_out - 1,
                     th.transaction_header_id)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
                /* SLA Changes */
             AND links.source_distribution_id_num_1 =
                 aj.transaction_header_id
             AND links.source_distribution_id_num_2 = aj.adjustment_line_id
             AND links.application_id = 140
             AND links.source_distribution_type = 'TRX'
             AND headers.application_id = 140
             AND headers.ae_header_id = links.ae_header_id
             AND headers.ledger_id = h_set_of_books_id
             AND lines.ae_header_id = links.ae_header_id
             AND lines.ae_line_num = links.ae_line_num
             AND lines.application_id = 140
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    lines.code_combination_id, --AJ.Code_Combination_ID,
                    aj.source_type_code;
      ELSE

        INSERT INTO xxfa_reserve_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT dh.asset_id,
                 dh.code_combination_id,
                 aj.code_combination_id,
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_transaction_headers  th,
                 fa_asset_history        ah,
                 fa_adjustments          aj,
                 fa_deprn_periods        dp
           WHERE dh.book_type_code = distribution_source_book
             AND dh.asset_id BETWEEN start_range AND end_range --Anuj
             AND aj.asset_id = dh.asset_id
             AND aj.book_type_code = book
             AND aj.distribution_id = dh.distribution_id
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND dp.xla_conversion_status IS NOT NULL
             AND aj.code_combination_id IS NOT NULL
             AND th.transaction_header_id = aj.transaction_header_id
             AND ah.asset_id = dh.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND th.transaction_header_id BETWEEN
                 ah.transaction_header_id_in AND
                 nvl(ah.transaction_header_id_out - 1,
                     th.transaction_header_id)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    aj.code_combination_id,
                    aj.source_type_code
          UNION ALL
          SELECT /*+ leading(AJ) */
                 dh.asset_id,
                 dh.code_combination_id,
                 lines.code_combination_id, --AJ.Code_Combination_ID,
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_transaction_headers  th,
                 fa_asset_history        ah,
                 fa_adjustments          aj,
                 fa_deprn_periods        dp
                 /* SLA Changes */,
                 xla_ae_headers         headers,
                 xla_ae_lines           lines,
                 xla_distribution_links links
           WHERE dh.book_type_code = distribution_source_book
             AND dh.asset_id BETWEEN start_range AND end_range --Anuj
             AND aj.asset_id = dh.asset_id
             AND aj.book_type_code = book
             AND aj.distribution_id = dh.distribution_id
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND (dp.xla_conversion_status IS NULL OR
                 aj.code_combination_id IS NULL)
             AND th.transaction_header_id = aj.transaction_header_id
             AND ah.asset_id = dh.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND th.transaction_header_id BETWEEN
                 ah.transaction_header_id_in AND
                 nvl(ah.transaction_header_id_out - 1,
                     th.transaction_header_id)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
                /* SLA Changes */
             AND links.source_distribution_id_num_1 =
                 aj.transaction_header_id
             AND links.source_distribution_id_num_2 = aj.adjustment_line_id
             AND links.application_id = 140
             AND links.source_distribution_type = 'TRX'
             AND headers.application_id = 140
             AND headers.ae_header_id = links.ae_header_id
             AND headers.ledger_id = h_set_of_books_id
             AND lines.ae_header_id = links.ae_header_id
             AND lines.ae_line_num = links.ae_line_num
             AND lines.application_id = 140
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    lines.code_combination_id, --AJ.Code_Combination_ID,
                    aj.source_type_code;
      END IF;
      END IF;

      -- Fix for Bug #1892406.  Run only if CRL installed.
    ELSIF (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') THEN

      IF (h_reporting_flag = 'R') THEN
        /* Bug 7498880: Added new query for upgraded periods */
        INSERT INTO xxfa_balances_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT dh.asset_id,
                 dh.code_combination_id,
                 aj.code_combination_id,
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_transaction_headers  th,
                 fa_asset_history        ah,
                 fa_mc_adjustments       aj,
                 fa_deprn_periods        dp
           WHERE dh.book_type_code = distribution_source_book
             AND dh.asset_id BETWEEN start_range AND end_range --Anuj
             AND aj.asset_id = dh.asset_id
             AND aj.book_type_code = book
             AND aj.distribution_id = dh.distribution_id
	     AND aj.set_of_books_id = h_set_of_books_id
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND DP.xla_conversion_status is not null
             AND AJ.code_combination_id is not null
             AND th.transaction_header_id = aj.transaction_header_id
             AND ah.asset_id = dh.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND th.transaction_header_id BETWEEN
                 ah.transaction_header_id_in AND
                 nvl(ah.transaction_header_id_out - 1,
                     th.transaction_header_id)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
                -- start of cua
             AND NOT EXISTS
           (SELECT 'x'
                    FROM fa_mc_books bks
                   WHERE bks.book_type_code = book
                     AND bks.asset_id = aj.asset_id
                     AND bks.group_asset_id IS NOT NULL
		     AND bks.set_of_books_id = h_set_of_books_id
                     AND bks.date_ineffective IS NOT NULL)
          -- end of cua
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    aj.code_combination_id,
                    aj.source_type_code
          UNION ALL
          SELECT dh.asset_id,
                 dh.code_combination_id,
                 lines.code_combination_id, --AJ.Code_Combination_ID,
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_transaction_headers  th,
                 fa_asset_history        ah,
                 fa_mc_adjustments    aj,
                 fa_deprn_periods        dp
                 /* SLA Changes */,
                 xla_ae_headers         headers,
                 xla_ae_lines           lines,
                 xla_distribution_links links
           WHERE dh.book_type_code = distribution_source_book
             AND dh.asset_id BETWEEN start_range AND end_range --Anuj
             AND aj.asset_id = dh.asset_id
             AND aj.book_type_code = book
             AND aj.distribution_id = dh.distribution_id
	     AND aj.set_of_books_id = h_set_of_books_id
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND (dp.xla_conversion_status is null or
                  aj.code_combination_id is null)
             AND th.transaction_header_id = aj.transaction_header_id
             AND ah.asset_id = dh.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND th.transaction_header_id BETWEEN
                 ah.transaction_header_id_in AND
                 nvl(ah.transaction_header_id_out - 1,
                     th.transaction_header_id)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
                -- start of cua
             AND NOT EXISTS
           (SELECT 'x'
                    FROM fa_mc_books bks
                   WHERE bks.book_type_code = book
                     AND bks.asset_id = aj.asset_id
		     AND bks.set_of_books_id = h_set_of_books_id
                     AND bks.group_asset_id IS NOT NULL
                     AND bks.date_ineffective IS NOT NULL)
                -- end of cua
                /* SLA Changes */
             AND links.source_distribution_id_num_1 =
                 aj.transaction_header_id
             AND links.source_distribution_id_num_2 = aj.adjustment_line_id
             AND links.application_id = 140
             AND links.source_distribution_type = 'TRX'
             AND headers.application_id = 140
             AND headers.ae_header_id = links.ae_header_id
             AND headers.ledger_id = h_set_of_books_id
             AND lines.ae_header_id = links.ae_header_id
             AND lines.ae_line_num = links.ae_line_num
             AND lines.application_id = 140
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    lines.code_combination_id, --AJ.Code_Combination_ID,
                    aj.source_type_code;

      ELSE
        /* Bug 7498880: Added new query for upgraded periods */
        INSERT INTO xxfa_balances_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT dh.asset_id,
                 dh.code_combination_id,
                 aj.code_combination_id,
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_transaction_headers  th,
                 fa_asset_history        ah,
                 fa_adjustments          aj,
                 fa_deprn_periods        dp

           WHERE dh.book_type_code = distribution_source_book
             AND dh.asset_id BETWEEN start_range AND end_range --Anuj
             AND aj.asset_id = dh.asset_id
             AND aj.book_type_code = book
             AND aj.distribution_id = dh.distribution_id
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND DP.xla_conversion_status is not null
             AND AJ.code_combination_id is not null
             AND th.transaction_header_id = aj.transaction_header_id
             AND ah.asset_id = dh.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND th.transaction_header_id BETWEEN
                 ah.transaction_header_id_in AND
                 nvl(ah.transaction_header_id_out - 1,
                     th.transaction_header_id)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
                -- start of cua
             AND NOT EXISTS
           (SELECT 'x'
                    FROM fa_books bks
                   WHERE bks.book_type_code = book
                     AND bks.asset_id = aj.asset_id
                     AND bks.group_asset_id IS NOT NULL
                     AND bks.date_ineffective IS NOT NULL)
          -- end of cua
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    aj.code_combination_id,
                    aj.source_type_code
          UNION ALL
          SELECT dh.asset_id,
                 dh.code_combination_id,
                 lines.code_combination_id, --AJ.Code_Combination_ID,
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_transaction_headers  th,
                 fa_asset_history        ah,
                 fa_adjustments          aj,
                 fa_deprn_periods        dp
                 /* SLA Changes */,
                 xla_ae_headers         headers,
                 xla_ae_lines           lines,
                 xla_distribution_links links
           WHERE dh.book_type_code = distribution_source_book
             AND dh.asset_id BETWEEN start_range AND end_range --Anuj
             AND aj.asset_id = dh.asset_id
             AND aj.book_type_code = book
             AND aj.distribution_id = dh.distribution_id
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND (dp.xla_conversion_status is null or
                  aj.code_combination_id is null)
             AND th.transaction_header_id = aj.transaction_header_id
             AND ah.asset_id = dh.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND th.transaction_header_id BETWEEN
                 ah.transaction_header_id_in AND
                 nvl(ah.transaction_header_id_out - 1,
                     th.transaction_header_id)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
                -- start of cua
             AND NOT EXISTS
           (SELECT 'x'
                    FROM fa_books bks
                   WHERE bks.book_type_code = book
                     AND bks.asset_id = aj.asset_id
                     AND bks.group_asset_id IS NOT NULL
                     AND bks.date_ineffective IS NOT NULL)
                -- end of cua
                /* SLA Changes */
             AND links.source_distribution_id_num_1 =
                 aj.transaction_header_id
             AND links.source_distribution_id_num_2 = aj.adjustment_line_id
             AND links.application_id = 140
             AND links.source_distribution_type = 'TRX'
             AND headers.application_id = 140
             AND headers.ae_header_id = links.ae_header_id
             AND headers.ledger_id = h_set_of_books_id
             AND lines.ae_header_id = links.ae_header_id
             AND lines.ae_line_num = links.ae_line_num
             AND lines.application_id = 140
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    lines.code_combination_id, --AJ.Code_Combination_ID,
                    aj.source_type_code;

      END IF;

    END IF;

    IF report_type = 'RESERVE' THEN
      IF (h_reporting_flag = 'R') THEN
        INSERT INTO xxfa_balances_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT /*+ leading(dh, dd, ah, cb) */ dh.asset_id,
                 dh.code_combination_id,
                 NULL,
                 cb.deprn_reserve_acct,
                 'ADDITION',
                 SUM(dd.deprn_reserve),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_category_books       cb,
                 fa_asset_history        ah,
                 fa_mc_deprn_detail      dd
           WHERE NOT EXISTS
           (SELECT /*+ push_subq no_unnest */ asset_id
                    FROM fa_balances_reports_itf
                   WHERE asset_id = dh.asset_id
                     AND distribution_ccid = dh.code_combination_id
                     AND source_type_code = 'ADDITION'
                     AND request_id = h_request_id)
             AND dd.book_type_code = book
	     AND dd.set_of_books_id = h_set_of_books_id
             AND dd.asset_id BETWEEN start_range AND end_range --Anuj
             AND (dd.period_counter + 1) BETWEEN period1_pc AND period2_pc
             AND dd.deprn_source_code = 'B'
             AND dd.asset_id = dh.asset_id
             AND dd.deprn_reserve <> 0
             AND dd.distribution_id = dh.distribution_id
             AND dd.asset_id = ah.asset_id
             AND ah.date_effective < nvl(dh.date_ineffective, SYSDATE)
             AND nvl(dh.date_ineffective, SYSDATE) <=
                 nvl(ah.date_ineffective, SYSDATE)
             AND dd.book_type_code = cb.book_type_code
             AND ah.category_id = cb.category_id
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    cb.deprn_reserve_acct;
      ELSE
        INSERT INTO xxfa_reserve_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT /*+ leading(bc, dh, dd, ah, cb) */ dh.asset_id,
                 dh.code_combination_id,
                 NULL,
                 cb.deprn_reserve_acct,
                 'ADDITION',
                 SUM(nvl(dd.deprn_reserve, 0)),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_category_books       cb,
                 fa_asset_history        ah,
                 fa_book_controls        bc,
                 fa_deprn_detail         dd
           WHERE NOT EXISTS
           (SELECT /*+ push_subq no_unnest */ asset_id
                    FROM fa_balances_reports_itf
                   WHERE asset_id = dh.asset_id
                     AND distribution_ccid = dh.code_combination_id
                     AND source_type_code = 'ADDITION'
                     AND request_id = h_request_id)
             AND dd.book_type_code = book
             AND bc.book_type_code = book
             AND dd.asset_id BETWEEN start_range AND end_range --Anuj
             AND (dd.period_counter + 1) BETWEEN period1_pc AND period2_pc
             AND dd.deprn_source_code = 'B'
             AND dd.asset_id = dh.asset_id
             AND bc.distribution_source_book = dh.book_type_code
             AND dd.deprn_reserve <> 0
             AND dd.distribution_id = dh.distribution_id
             AND dd.asset_id = ah.asset_id
             AND ah.date_effective < nvl(dh.date_ineffective, SYSDATE)
             AND nvl(dh.date_ineffective, SYSDATE) <=
                 nvl(ah.date_ineffective, SYSDATE)
             AND dd.book_type_code = cb.book_type_code
             AND ah.category_id = cb.category_id
           GROUP BY dh.asset_id,
                    dh.code_combination_id,
                    cb.deprn_reserve_acct;
      END IF;

    END IF;

  END get_adjustments;

  -- Bug 8902344 : Changed UNION to UNION ALL in all the inserts
  PROCEDURE get_adjustments_for_group(book                     IN VARCHAR2,
                                      distribution_source_book IN VARCHAR2,
                                      period1_pc               IN NUMBER,
                                      period2_pc               IN NUMBER,
                                      report_type              IN VARCHAR2,
                                      balance_type             IN VARCHAR2,
                                      start_range              IN NUMBER,
                                      end_range                IN NUMBER,
                                      h_request_id             IN NUMBER) IS
    h_set_of_books_id NUMBER;
    h_reporting_flag  VARCHAR2(1);
  BEGIN

    -- get mrc related info
    BEGIN
      --h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
      SELECT to_number(substrb(userenv('CLIENT_INFO'), 45, 10))
        INTO h_set_of_books_id
        FROM dual;

      IF (h_set_of_books_id = -1) THEN
        h_set_of_books_id := NULL;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        h_set_of_books_id := NULL;
    END;

    IF (h_set_of_books_id IS NOT NULL) THEN
      IF NOT
          fa_cache_pkg.fazcsob(x_set_of_books_id   => h_set_of_books_id,
                               x_mrc_sob_type_code => h_reporting_flag) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      SELECT set_of_books_id
        INTO h_set_of_books_id
        FROM fa_book_controls
       WHERE book_type_code = book;

      h_reporting_flag := 'P';
    END IF;

    -- run only if CRL installed
    IF (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') THEN

      IF (h_reporting_flag = 'R') THEN
        /* Bug 7498880: Added new query for upgraded periods */
        INSERT INTO xxfa_balances_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT aj.asset_id,
                 -- Changed for BMA1
                 -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
                 gad.deprn_expense_acct_ccid,
                 decode(aj.adjustment_type,
                        'COST',
                        gad.asset_cost_acct_ccid,
                        aj.code_combination_id),
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_mc_adjustments     aj,
                 fa_mc_books         bk,
                 fa_group_asset_default gad,
                 fa_deprn_periods       dp
           WHERE bk.asset_id = aj.asset_id
             AND bk.book_type_code = book
             AND bk.group_asset_id = gad.group_asset_id
             AND bk.book_type_code = gad.book_type_code
	     AND aj.set_of_books_id = h_set_of_books_id
	     AND bk.set_of_books_id = h_set_of_books_id
             AND bk.date_ineffective IS NULL
             AND aj.asset_id IN
                 (SELECT asset_id
                    FROM fa_mc_books
                   WHERE group_asset_id IS NOT NULL
		     AND set_of_books_id = h_set_of_books_id
                     AND date_ineffective IS NULL)
             AND aj.asset_id = bk.asset_id
             AND aj.asset_id BETWEEN start_range AND end_range --anuj
             AND aj.book_type_code = book
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND DP.xla_conversion_status is not null
             AND AJ.code_combination_id is not null
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
           GROUP BY aj.asset_id,
                    -- Changed for BMA1
                    -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
                    gad.deprn_expense_acct_ccid,
                    decode(aj.adjustment_type,
                           'COST',
                           gad.asset_cost_acct_ccid,
                           aj.code_combination_id),
                    aj.source_type_code
          UNION ALL
          SELECT aj.asset_id,
                 -- Changed for BMA1
                 -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
                 gad.deprn_expense_acct_ccid,
                 decode(aj.adjustment_type,
                        'COST',
                        gad.asset_cost_acct_ccid,
                        lines.code_combination_id /*AJ.Code_Combination_ID*/),
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_mc_adjustments      aj,
                 fa_mc_books            bk,
                 fa_group_asset_default gad,
                 fa_deprn_periods       dp
                 /* SLA Changes */,
                 xla_ae_headers         headers,
                 xla_ae_lines           lines,
                 xla_distribution_links links
           WHERE bk.asset_id = aj.asset_id
             AND bk.book_type_code = book
             AND bk.group_asset_id = gad.group_asset_id
             AND bk.book_type_code = gad.book_type_code
             AND bk.date_ineffective IS NULL
	     AND aj.set_of_books_id = h_set_of_books_id
	     AND bk.set_of_books_id = h_set_of_books_id
             AND aj.asset_id BETWEEN start_range AND end_range --anuj
             AND aj.asset_id IN
                 (SELECT asset_id
                    FROM fa_mc_books
                   WHERE group_asset_id IS NOT NULL
		     AND set_of_books_id = h_set_of_books_id
                     AND date_ineffective IS NULL)
             AND aj.asset_id = bk.asset_id
             AND aj.book_type_code = book
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND (dp.xla_conversion_status is null or
                  aj.code_combination_id is null)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
                /* SLA Changes */
             AND links.source_distribution_id_num_1 =
                 aj.transaction_header_id
             AND links.source_distribution_id_num_2 = aj.adjustment_line_id
             AND links.application_id = 140
             AND links.source_distribution_type = 'TRX'
             AND headers.application_id = 140
             AND headers.ae_header_id = links.ae_header_id
             AND headers.ledger_id = h_set_of_books_id
             AND lines.ae_header_id = links.ae_header_id
             AND lines.ae_line_num = links.ae_line_num
             AND lines.application_id = 140
           GROUP BY aj.asset_id,
                    -- Changed for BMA1
                    -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
                    gad.deprn_expense_acct_ccid,
                    decode(aj.adjustment_type,
                           'COST',
                           gad.asset_cost_acct_ccid,
                           lines.code_combination_id /*AJ.Code_Combination_ID*/),
                    aj.source_type_code;
      ELSE
        /* Bug 7498880: Added new query for upgraded periods */
        INSERT INTO xxfa_balances_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT aj.asset_id,
                 -- Changed for BMA1
                 -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
                 gad.deprn_expense_acct_ccid,
                 decode(aj.adjustment_type,
                        'COST',
                        gad.asset_cost_acct_ccid,
                        aj.code_combination_id),
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_adjustments         aj,
                 fa_books               bk,
                 fa_group_asset_default gad,
                 fa_deprn_periods       dp
           WHERE bk.asset_id = aj.asset_id
             AND bk.book_type_code = book
             AND aj.asset_id BETWEEN start_range AND end_range --anuj
             AND bk.group_asset_id = gad.group_asset_id
             AND bk.book_type_code = gad.book_type_code
             AND bk.date_ineffective IS NULL
             AND aj.asset_id IN
                 (SELECT asset_id
                    FROM fa_books
                   WHERE group_asset_id IS NOT NULL
                     AND date_ineffective IS NULL)
             AND aj.asset_id = bk.asset_id
             AND aj.book_type_code = book
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND DP.xla_conversion_status is not null
             AND AJ.code_combination_id is not null
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0
           GROUP BY aj.asset_id,
                    -- Changed for BMA1
                    -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
                    gad.deprn_expense_acct_ccid,
                    decode(aj.adjustment_type,
                           'COST',
                           gad.asset_cost_acct_ccid,
                           aj.code_combination_id),
                    aj.source_type_code
          UNION ALL
          SELECT aj.asset_id,
                 -- Changed for BMA1
                 -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
                 gad.deprn_expense_acct_ccid,
                 decode(aj.adjustment_type,
                        'COST',
                        gad.asset_cost_acct_ccid,
                        lines.code_combination_id /*AJ.Code_Combination_ID*/),
                 NULL,
                 aj.source_type_code,
                 SUM(decode(aj.debit_credit_flag, balance_type, 1, -1) *
                     aj.adjustment_amount),
                 h_request_id,
                 book
            FROM fa_adjustments         aj,
                 fa_books               bk,
                 fa_group_asset_default gad,
                 fa_deprn_periods       dp

                 /* SLA Changes */,
                 xla_ae_headers         headers,
                 xla_ae_lines           lines,
                 xla_distribution_links links
           WHERE bk.asset_id = aj.asset_id
             AND bk.book_type_code = book
             AND aj.asset_id BETWEEN start_range AND end_range --anuj
             AND bk.group_asset_id = gad.group_asset_id
             AND bk.book_type_code = gad.book_type_code
             AND bk.date_ineffective IS NULL
             AND aj.asset_id IN
                 (SELECT asset_id
                    FROM fa_books
                   WHERE group_asset_id IS NOT NULL
                     AND date_ineffective IS NULL)
             AND aj.asset_id = bk.asset_id
             AND aj.book_type_code = book
             AND aj.adjustment_type IN
                 (report_type,
                  decode(report_type, 'REVAL RESERVE', 'REVAL AMORT'))
             AND aj.period_counter_created BETWEEN period1_pc AND
                 period2_pc
             AND dp.book_type_code = aj.book_type_code
             AND dp.period_counter = aj.period_counter_created
             AND (dp.xla_conversion_status is null or
                  aj.code_combination_id is null)
             AND (decode(report_type, aj.adjustment_type, 1, 0) *
                 aj.adjustment_amount) <> 0

                /* SLA Changes */
             AND links.source_distribution_id_num_1 =
                 aj.transaction_header_id
             AND links.source_distribution_id_num_2 = aj.adjustment_line_id
             AND links.application_id = 140
             AND links.source_distribution_type = 'TRX'
             AND headers.application_id = 140
             AND headers.ae_header_id = links.ae_header_id
             AND headers.ledger_id = h_set_of_books_id
             AND lines.ae_header_id = links.ae_header_id
             AND lines.ae_line_num = links.ae_line_num
             AND lines.application_id = 140
           GROUP BY aj.asset_id,
                    -- Changed for BMA1
                    -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
                    gad.deprn_expense_acct_ccid,
                    decode(aj.adjustment_type,
                           'COST',
                           gad.asset_cost_acct_ccid,
                           lines.code_combination_id /* AJ.Code_Combination_ID*/),
                    aj.source_type_code;
      END IF;

    END IF;

  END get_adjustments_for_group;

  PROCEDURE get_balance(book                     IN VARCHAR2,
                        distribution_source_book IN VARCHAR2,
                        period_pc                IN NUMBER,
                        earliest_pc              IN NUMBER,
                        period_date              IN DATE,
                        additions_date           IN DATE,
                        report_type              IN VARCHAR2,
                        balance_type             IN VARCHAR2,
                        begin_or_end             IN VARCHAR2,
                        start_range              IN NUMBER,
                        end_range                IN NUMBER,
                        h_request_id             IN NUMBER) IS
    p_date            DATE := period_date;
    a_date            DATE := additions_date;
    h_set_of_books_id NUMBER;
    h_reporting_flag  VARCHAR2(1);
    h_book_id         VARCHAR2(240);
  BEGIN

    -- get mrc related info
    BEGIN
      SELECT argument2
        INTO h_book_id
        FROM fnd_concurrent_requests
       WHERE request_id = h_request_id;

      fnd_client_info.set_currency_context(to_number(h_book_id));

      SELECT to_number(substrb(userenv('CLIENT_INFO'), 45, 10))
        INTO h_set_of_books_id
        FROM dual;

    EXCEPTION
      WHEN OTHERS THEN
        h_set_of_books_id := NULL;
    END;

    IF (h_set_of_books_id IS NOT NULL) THEN
      IF NOT
          fa_cache_pkg.fazcsob(x_set_of_books_id   => h_set_of_books_id,
                               x_mrc_sob_type_code => h_reporting_flag) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      h_reporting_flag := 'P';
    END IF;

--insert into tmp_log (fname ,value ,log_date) values ('h_reporting_flag',h_reporting_flag,sysdate);
    -- Fix for Bug #1892406.  Run only if CRL not installed.
    IF (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'N') THEN

      IF (h_reporting_flag = 'R') THEN

        INSERT INTO xxfa_balances_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT dh.asset_id,
                 dh.code_combination_id,
                 NULL,
                 decode(report_type,
                        'COST',
                        cb.asset_cost_acct,
                        'CIP COST',
                        cb.cip_cost_acct,
                        'RESERVE',
                        cb.deprn_reserve_acct,
                        'REVAL RESERVE',
                        cb.reval_reserve_acct),
                 decode(report_type,
                        'RESERVE',
                        decode(dd.deprn_source_code,
                               'D',
                               begin_or_end,
                               'ADDITION'),
                        'REVAL RESERVE',
                        decode(dd.deprn_source_code,
                               'D',
                               begin_or_end,
                               'ADDITION'),
                        begin_or_end),
                 decode(report_type,
                        'COST',
                        dd.cost,
                        'CIP COST',
                        dd.cost,
                        'RESERVE',
                        dd.deprn_reserve,
                        'REVAL RESERVE',
                        dd.reval_reserve),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_mc_deprn_detail      dd,
                 fa_asset_history        ah,
                 fa_category_books       cb,
                 fa_mc_books             bk
           WHERE dh.book_type_code = distribution_source_book
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                 dh.date_effective AND nvl(dh.date_ineffective, SYSDATE)
             AND dd.asset_id = dh.asset_id
             AND dd.book_type_code = book
             AND dd.distribution_id = dh.distribution_id
             AND dd.period_counter <= period_pc
	     AND dd.set_of_books_id = h_set_of_books_id
	     AND bk.set_of_books_id = h_set_of_books_id
             AND dd.asset_id BETWEEN start_range AND end_range --Anuj
                -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
             AND decode(report_type,
                        'CIP COST',
                        dd.deprn_source_code,
                        decode(begin_or_end,
                               'BEGIN',
                               dd.deprn_source_code,
                               'D')) = dd.deprn_source_code
             AND
                /*        DECODE(Begin_or_End,
                'BEGIN', DD.Deprn_Source_Code, 'D') =
                        DD.Deprn_Source_Code AND */
                -- End bug fix 5076193
                 dd.period_counter =
                 (SELECT MAX(sub_dd.period_counter)
                    FROM fa_mc_deprn_detail sub_dd
                   WHERE sub_dd.book_type_code = book
                     AND sub_dd.distribution_id = dh.distribution_id
                     AND dh.distribution_id = dd.distribution_id
		     AND sub_dd.set_of_books_id = h_set_of_books_id
                     AND sub_dd.period_counter <= period_pc)
             AND ah.asset_id = dd.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                 ah.date_effective AND nvl(ah.date_ineffective, SYSDATE)
             AND cb.category_id = ah.category_id
             AND cb.book_type_code = dd.book_type_code -- changed from book var to column
             AND bk.book_type_code = cb.book_type_code
             AND -- changed from book var to column
                 bk.asset_id = dd.asset_id
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                 bk.date_effective AND nvl(bk.date_ineffective, SYSDATE)
             AND nvl(bk.period_counter_fully_retired, period_pc + 1) >
                 earliest_pc
             AND decode(report_type,
                        'COST',
                        decode(ah.asset_type,
                               'CAPITALIZED',
                               cb.asset_cost_acct,
                               NULL),
                        'CIP COST',
                        decode(ah.asset_type, 'CIP', cb.cip_cost_acct, NULL),
                        'RESERVE',
                        cb.deprn_reserve_acct,
                        'REVAL RESERVE',
                        cb.reval_reserve_acct) IS NOT NULL;
      ELSE
        -- split for 'COST','CIP COST' and 'RESERVE','REVAL RESERVE' for better performance.

        IF report_type IN ('COST', 'CIP COST') THEN
         /*bug16852688 added union all for performance reason */
          INSERT INTO xxfa_balances_reports_itf
            (asset_id,
             distribution_ccid,
             adjustment_ccid,
             category_books_account,
             source_type_code,
             amount,
             request_id,
             book_type_code)
            SELECT /*+ USE_HASH(SUB_DD,BK) leading(BK) leading(bk) index(dd, fa_deprn_detail_n1) index(bk, fa_books_u2)*/
             dh.asset_id,
             dh.code_combination_id,
             NULL,
             decode(report_type,
                    'COST',
                    cb.asset_cost_acct,
                    'CIP COST',
                    cb.cip_cost_acct,
                    'RESERVE',
                    cb.deprn_reserve_acct,
                    'REVAL RESERVE',
                    cb.reval_reserve_acct),
             decode(report_type,
                    'RESERVE',
                    decode(dd.deprn_source_code,
                           'D',
                           begin_or_end,
                           'ADDITION'),
                    'REVAL RESERVE',
                    decode(dd.deprn_source_code,
                           'D',
                           begin_or_end,
                           'ADDITION'),
                    begin_or_end),
             decode(report_type,
                    'COST',
                    dd.cost,
                    'CIP COST',
                    dd.cost,
                    'RESERVE',
                    dd.deprn_reserve,
                    'REVAL RESERVE',
                    dd.reval_reserve),
             h_request_id,
             book
              FROM fa_deprn_detail dd,
                   fa_distribution_history dh,
                   fa_asset_history ah,
                   fa_category_books cb,
                   fa_books bk,
                   (SELECT /*+ index(FA_DEPRN_DETAIL, FA_DEPRN_DETAIL_N3) no_merge */
                           asset_id,
                           distribution_id,
                           MAX(period_counter) mpc
                      FROM fa_deprn_detail
                     WHERE book_type_code = book
                       AND period_counter <= period_pc
                     GROUP BY asset_id, distribution_id) sub_dd
             WHERE dh.book_type_code = distribution_source_book
               AND dd.deprn_source_code = 'D'
               AND p_date
               between dh.date_effective AND nvl(dh.date_ineffective, SYSDATE)
               AND dd.asset_id = dh.asset_id
               AND dd.book_type_code = book
               AND dd.distribution_id = dh.distribution_id
               AND dd.period_counter <= period_pc
               AND dd.asset_id BETWEEN start_range AND end_range
                  -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
               AND decode(report_type,
                          'CIP COST',
                          dd.deprn_source_code,
                          decode(begin_or_end,
                                 'BEGIN',
                                 dd.deprn_source_code,
                                 'D')) = dd.deprn_source_code
               AND dd.period_counter = sub_dd.mpc
               AND dd.distribution_id = sub_dd.distribution_id
               AND sub_dd.asset_id = dd.asset_id
               AND ah.asset_id = dd.asset_id
               --AND ah.asset_type <> 'EXPENSED'      /* Commented and added below for Bug 16326387 */
               AND ah.asset_type IN ('CAPITALIZED', 'CIP', 'GROUP')
               AND dd.deprn_source_code = 'D'
               AND p_date
               between ah.date_effective AND nvl(ah.date_ineffective, SYSDATE)
               AND cb.category_id = ah.category_id
               AND cb.book_type_code = dd.book_type_code
               AND bk.book_type_code = cb.book_type_code
               AND bk.asset_id = dd.asset_id
               AND dd.deprn_source_code = 'D'
               AND p_date
               between bk.date_effective AND nvl(bk.date_ineffective, SYSDATE)
               AND nvl(bk.period_counter_fully_retired, period_pc + 1) >
                   earliest_pc
               AND decode(report_type,
                          'COST',
                          decode(ah.asset_type,
                                 'CAPITALIZED',
                                 cb.asset_cost_acct,
                                 NULL),
                          'CIP COST',
                          decode(ah.asset_type,
                                 'CIP',
                                 cb.cip_cost_acct,
                                 NULL),
                          'RESERVE',
                          cb.deprn_reserve_acct,
                          'REVAL RESERVE',
                          cb.reval_reserve_acct) IS NOT NULL
         union all
            SELECT /*+ USE_HASH(SUB_DD,BK) leading(BK) leading(bk) index(dd, fa_deprn_detail_n1) index(bk, fa_books_u2)*/
             dh.asset_id,
             dh.code_combination_id,
             NULL,
             decode(report_type,
                    'COST',
                    cb.asset_cost_acct,
                    'CIP COST',
                    cb.cip_cost_acct,
                    'RESERVE',
                    cb.deprn_reserve_acct,
                    'REVAL RESERVE',
                    cb.reval_reserve_acct),
             decode(report_type,
                    'RESERVE',
                    decode(dd.deprn_source_code,
                           'D',
                           begin_or_end,
                           'ADDITION'),
                    'REVAL RESERVE',
                    decode(dd.deprn_source_code,
                           'D',
                           begin_or_end,
                           'ADDITION'),
                    begin_or_end),
             decode(report_type,
                    'COST',
                    dd.cost,
                    'CIP COST',
                    dd.cost,
                    'RESERVE',
                    dd.deprn_reserve,
                    'REVAL RESERVE',
                    dd.reval_reserve),
             h_request_id,
             book
              FROM fa_deprn_detail dd,
                   fa_distribution_history dh,
                   fa_asset_history ah,
                   fa_category_books cb,
                   fa_books bk,
                   (SELECT /*+ index(FA_DEPRN_DETAIL, FA_DEPRN_DETAIL_N3) no_merge */
                           asset_id,
                           distribution_id,
                           MAX(period_counter) mpc
                      FROM fa_deprn_detail
                     WHERE book_type_code = book
                       AND period_counter <= period_pc
                     GROUP BY asset_id, distribution_id) sub_dd
             WHERE dh.book_type_code = distribution_source_book
               AND dd.deprn_source_code = 'B'
               AND a_date
               between dh.date_effective AND nvl(dh.date_ineffective, SYSDATE)
               AND dd.asset_id = dh.asset_id
               AND dd.book_type_code = book
               AND dd.distribution_id = dh.distribution_id
               AND dd.period_counter <= period_pc
               AND dd.asset_id BETWEEN start_range AND end_range
                  -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
               AND decode(report_type,
                          'CIP COST',
                          dd.deprn_source_code,
                          decode(begin_or_end,
                                 'BEGIN',
                                 dd.deprn_source_code,
                                 'D')) = dd.deprn_source_code
               AND dd.period_counter = sub_dd.mpc
               AND dd.distribution_id = sub_dd.distribution_id
               AND sub_dd.asset_id = dd.asset_id
               AND ah.asset_id = dd.asset_id
               --AND ah.asset_type <> 'EXPENSED'      /* Commented and added below for Bug 16326387 */
               AND ah.asset_type IN ('CAPITALIZED', 'CIP', 'GROUP')
               AND dd.deprn_source_code = 'B'
               AND a_date
               between ah.date_effective AND nvl(ah.date_ineffective, SYSDATE)
               AND cb.category_id = ah.category_id
               AND cb.book_type_code = dd.book_type_code
               AND bk.book_type_code = cb.book_type_code
               AND bk.asset_id = dd.asset_id
               AND dd.deprn_source_code = 'B'
               AND a_date
               between bk.date_effective AND nvl(bk.date_ineffective, SYSDATE)
               AND nvl(bk.period_counter_fully_retired, period_pc + 1) >
                   earliest_pc
               AND decode(report_type,
                          'COST',
                          decode(ah.asset_type,
                                 'CAPITALIZED',
                                 cb.asset_cost_acct,
                                 NULL),
                          'CIP COST',
                          decode(ah.asset_type,
                                 'CIP',
                                 cb.cip_cost_acct,
                                 NULL),
                          'RESERVE',
                          cb.deprn_reserve_acct,
                          'REVAL RESERVE',
                          cb.reval_reserve_acct) IS NOT NULL ;

        ELSE/*
		  --BC 20210114
		  insert into tmp_log (fname,value,log_date	) values ('In step 1.1',null,sysdate);
		  insert into tmp_log (fname,value,log_date	) values ('begin_or_end',begin_or_end,sysdate);
		  insert into tmp_log (fname,value,log_date	) values ('period_pc',period_pc,sysdate);
		  insert into tmp_log (fname,value,log_date	) values ('distribution_source_book',distribution_source_book,sysdate);
		  insert into tmp_log (fname,value,log_date	) values ('p_date',p_date,sysdate);
		  insert into tmp_log (fname,value,log_date	) values ('a_date',a_date,sysdate);
		  insert into tmp_log (fname,value,log_date	) values ('earliest_pc',earliest_pc,sysdate);
		  */
          -- report_type in ('RESERVE','REVAL RESERVE')

          /* Bug 6998035 */
        -- Changed for compatibility issue 1/29/16
        --  INSERT INTO xxfa_balances_reports_itf
        INSERT INTO xxfa_reserve_reports_itf
            (asset_id,
             distribution_ccid,
             adjustment_ccid,
             category_books_account,
             source_type_code,
             amount,
             request_id,
             book_type_code)
            SELECT /*+ USE_HASH(SUB_DD,BK) leading(BK) leading(bk) index(dd, fa_deprn_detail_n1) index(bk, fa_books_u2)*/
	           dh.asset_id,
                   dh.code_combination_id,
                   NULL,
                   decode(report_type,
                          'COST',
                          cb.asset_cost_acct,
                          'CIP COST',
                          cb.cip_cost_acct,
                          'RESERVE',
                          cb.deprn_reserve_acct,
                          'REVAL RESERVE',
                          cb.reval_reserve_acct),
                   decode(report_type,
                          'RESERVE',
                          decode(dd.deprn_source_code,
                                 'D',
                                 begin_or_end,
                                 'ADDITION'),
                          'REVAL RESERVE',
                          decode(dd.deprn_source_code,
                                 'D',
                                 begin_or_end,
                                 'ADDITION'),
                          begin_or_end),
                   decode(report_type,
                          'COST',
                          dd.cost,
                          'CIP COST',
                          dd.cost,
                          'RESERVE',
                          dd.deprn_reserve,
                          'REVAL RESERVE',
                          dd.reval_reserve),
                   h_request_id,
                   book
              FROM fa_deprn_detail         dd,
                   fa_distribution_history dh,
                   fa_asset_history        ah,
                   fa_category_books       cb,
                   fa_books                bk,
                   (SELECT /*+ index(FA_DEPRN_DETAIL, FA_DEPRN_DETAIL_N3) no_merge */
                           asset_id,
                           distribution_id,
                           MAX(period_counter) mpc
                      FROM fa_deprn_detail
                     WHERE book_type_code = book
                     AND period_counter <= period_pc
                     GROUP BY asset_id, distribution_id) sub_dd
             WHERE dh.book_type_code = distribution_source_book
               AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                   dh.date_effective AND nvl(dh.date_ineffective, SYSDATE)
               AND dd.asset_id BETWEEN start_range AND end_range --Anuj
               AND dd.asset_id = dh.asset_id
               AND dd.book_type_code = book
               AND dd.distribution_id = dh.distribution_id
               AND dd.period_counter <= period_pc
               AND decode(begin_or_end, 'BEGIN', dd.deprn_source_code, 'D') =
                   dd.deprn_source_code
               AND dd.period_counter = sub_dd.mpc
               AND dd.distribution_id = sub_dd.distribution_id
               AND sub_dd.asset_id = dd.asset_id
               AND ah.asset_id = dd.asset_id
               AND ah.asset_type IN ('CAPITALIZED', 'CIP')
               AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                   ah.date_effective AND nvl(ah.date_ineffective, SYSDATE)
               AND cb.category_id = ah.category_id
               AND cb.book_type_code = dd.book_type_code -- changed from book var to column
               AND bk.book_type_code = cb.book_type_code
               AND -- changed from book var to column
                   bk.asset_id = dd.asset_id
               AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                   bk.date_effective AND nvl(bk.date_ineffective, SYSDATE)
               AND nvl(bk.period_counter_fully_retired, period_pc + 1) >
                   earliest_pc
               /*AND decode(report_type,
                          'COST',
                          decode(ah.asset_type,
                                 'CAPITALIZED',
                                 cb.asset_cost_acct,
                                 NULL),
                          'CIP COST',
                          decode(ah.asset_type,
                                 'CIP',
                                 cb.cip_cost_acct,
                                 NULL),
                          'RESERVE',
                          cb.deprn_reserve_acct,
                          'REVAL RESERVE',
                          cb.reval_reserve_acct) IS NOT NULL 
				*/		  
						  ;

        END IF;

      END IF;

      -- Fix for Bug #1892406.  Run only if CRL installed.
    ELSIF (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') THEN

      IF (h_reporting_flag = 'R') THEN
        INSERT INTO xxfa_balances_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT dh.asset_id,
                 dh.code_combination_id,
                 NULL,
                 decode(report_type,
                        'COST',
                        cb.asset_cost_acct,
                        'CIP COST',
                        cb.cip_cost_acct,
                        'RESERVE',
                        cb.deprn_reserve_acct,
                        'REVAL RESERVE',
                        cb.reval_reserve_acct),
                 decode(report_type,
                        'RESERVE',
                        decode(dd.deprn_source_code,
                               'D',
                               begin_or_end,
                               'ADDITION'),
                        'REVAL RESERVE',
                        decode(dd.deprn_source_code,
                               'D',
                               begin_or_end,
                               'ADDITION'),
                        begin_or_end),
                 decode(report_type,
                        'COST',
                        dd.cost,
                        'CIP COST',
                        dd.cost,
                        'RESERVE',
                        dd.deprn_reserve,
                        'REVAL RESERVE',
                        dd.reval_reserve),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_mc_deprn_detail      dd,
                 fa_asset_history        ah,
                 fa_category_books       cb,
                 fa_mc_books             bk
           WHERE dh.book_type_code = distribution_source_book
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                 dh.date_effective AND nvl(dh.date_ineffective, SYSDATE)
             AND dd.asset_id BETWEEN start_range AND end_range --Anuj
             AND dd.asset_id = dh.asset_id
             AND dd.book_type_code = book
	     AND dd.set_of_books_id = h_set_of_books_id
	     AND bk.set_of_books_id = h_set_of_books_id
             AND dd.distribution_id = dh.distribution_id
             AND dd.period_counter <= period_pc
             AND
                -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
                 decode(report_type,
                        'CIP COST',
                        dd.deprn_source_code,
                        decode(begin_or_end,
                               'BEGIN',
                               dd.deprn_source_code,
                               'D')) = dd.deprn_source_code
             AND
                /*  DECODE(Begin_or_End,
                'BEGIN', DD.Deprn_Source_Code, 'D') =
                  DD.Deprn_Source_Code AND  */
                -- end bug fix 5076193
                 dd.period_counter =
                 (SELECT MAX(sub_dd.period_counter)
                    FROM fa_mc_deprn_detail sub_dd
                   WHERE sub_dd.book_type_code = book
                     AND sub_dd.distribution_id = dh.distribution_id
                     AND dh.distribution_id = dd.distribution_id
		     AND sub_dd.set_of_books_id = h_set_of_books_id
                     AND sub_dd.period_counter <= period_pc)
             AND ah.asset_id = dd.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                 ah.date_effective AND nvl(ah.date_ineffective, SYSDATE)
             AND cb.category_id = ah.category_id
             AND cb.book_type_code = dd.book_type_code -- changed from book var to column
             AND bk.book_type_code = cb.book_type_code
             AND -- changed from book var to column
                 bk.asset_id = dd.asset_id
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                 bk.date_effective AND nvl(bk.date_ineffective, SYSDATE)
             AND nvl(bk.period_counter_fully_retired, period_pc + 1) >
                 earliest_pc
             AND decode(report_type,
                        'COST',
                        decode(ah.asset_type,
                               'CAPITALIZED',
                               cb.asset_cost_acct,
                               NULL),
                        'CIP COST',
                        decode(ah.asset_type, 'CIP', cb.cip_cost_acct, NULL),
                        'RESERVE',
                        cb.deprn_reserve_acct,
                        'REVAL RESERVE',
                        cb.reval_reserve_acct) IS NOT NULL
                -- start of CUA - This is to exclude the Group Asset Members
             AND bk.group_asset_id IS NULL;
      ELSE
        INSERT INTO xxfa_balances_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT dh.asset_id,
                 dh.code_combination_id,
                 NULL,
                 decode(report_type,
                        'COST',
                        cb.asset_cost_acct,
                        'CIP COST',
                        cb.cip_cost_acct,
                        'RESERVE',
                        cb.deprn_reserve_acct,
                        'REVAL RESERVE',
                        cb.reval_reserve_acct),
                 decode(report_type,
                        'RESERVE',
                        decode(dd.deprn_source_code,
                               'D',
                               begin_or_end,
                               'ADDITION'),
                        'REVAL RESERVE',
                        decode(dd.deprn_source_code,
                               'D',
                               begin_or_end,
                               'ADDITION'),
                        begin_or_end),
                 decode(report_type,
                        'COST',
                        dd.cost,
                        'CIP COST',
                        dd.cost,
                        'RESERVE',
                        dd.deprn_reserve,
                        'REVAL RESERVE',
                        dd.reval_reserve),
                 h_request_id,
                 book
            FROM fa_distribution_history dh,
                 fa_deprn_detail         dd,
                 fa_asset_history        ah,
                 fa_category_books       cb,
                 fa_books                bk
           WHERE dh.book_type_code = distribution_source_book
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                 dh.date_effective AND nvl(dh.date_ineffective, SYSDATE)
             AND dd.asset_id BETWEEN start_range AND end_range --Anuj
             AND dd.asset_id = dh.asset_id
             AND dd.book_type_code = book
             AND dd.distribution_id = dh.distribution_id
             AND dd.period_counter <= period_pc
             AND
                -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
                 decode(report_type,
                        'CIP COST',
                        dd.deprn_source_code,
                        decode(begin_or_end,
                               'BEGIN',
                               dd.deprn_source_code,
                               'D')) = dd.deprn_source_code
             AND
                /*  DECODE(Begin_or_End,
                'BEGIN', DD.Deprn_Source_Code, 'D') =
                  DD.Deprn_Source_Code AND  */
                -- End bug fix 5076193
                 dd.period_counter =
                 (SELECT MAX(sub_dd.period_counter)
                    FROM fa_deprn_detail sub_dd
                   WHERE sub_dd.book_type_code = book
                     AND sub_dd.distribution_id = dh.distribution_id
                     AND dh.distribution_id = dd.distribution_id
                     AND sub_dd.period_counter <= period_pc)
             AND ah.asset_id = dd.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
                 report_type IN ('COST', 'CIP COST')) OR
                 (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
                 report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                 ah.date_effective AND nvl(ah.date_ineffective, SYSDATE)
             AND cb.category_id = ah.category_id
             AND cb.book_type_code = dd.book_type_code -- changed from book var to column
             AND bk.book_type_code = cb.book_type_code
             AND -- changed from book var to column
                 bk.asset_id = dd.asset_id
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
                 bk.date_effective AND nvl(bk.date_ineffective, SYSDATE)
             AND nvl(bk.period_counter_fully_retired, period_pc + 1) >
                 earliest_pc
             AND decode(report_type,
                        'COST',
                        decode(ah.asset_type,
                               'CAPITALIZED',
                               cb.asset_cost_acct,
                               NULL),
                        'CIP COST',
                        decode(ah.asset_type, 'CIP', cb.cip_cost_acct, NULL),
                        'RESERVE',
                        cb.deprn_reserve_acct,
                        'REVAL RESERVE',
                        cb.reval_reserve_acct) IS NOT NULL
                -- start of CUA - This is to exclude the Group Asset Members
             AND bk.group_asset_id IS NULL;
      END IF;
      -- end of cua

      COMMIT;
    END IF;
  END get_balance;

  PROCEDURE get_balance_group_begin(book                     IN VARCHAR2,
                                    distribution_source_book IN VARCHAR2,
                                    period_pc                IN NUMBER,
                                    earliest_pc              IN NUMBER,
                                    period_date              IN DATE,
                                    additions_date           IN DATE,
                                    report_type              IN VARCHAR2,
                                    balance_type             IN VARCHAR2,
                                    begin_or_end             IN VARCHAR2,
                                    start_range              IN NUMBER,
                                    end_range                IN NUMBER,
                                    h_request_id             NUMBER) IS
    p_date            DATE := period_date;
    a_date            DATE := additions_date;
    h_set_of_books_id NUMBER;
    h_reporting_flag  VARCHAR2(1);
  BEGIN

    -- get mrc related info
    BEGIN
      --h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
      SELECT to_number(substrb(userenv('CLIENT_INFO'), 45, 10))
        INTO h_set_of_books_id
        FROM dual;

    EXCEPTION
      WHEN OTHERS THEN
        h_set_of_books_id := NULL;
    END;

    IF (h_set_of_books_id IS NOT NULL) THEN
      IF NOT
          fa_cache_pkg.fazcsob(x_set_of_books_id   => h_set_of_books_id,
                               x_mrc_sob_type_code => h_reporting_flag) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      h_reporting_flag := 'P';
    END IF;

    -- run only if CRL installed
    IF (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') THEN

      IF (report_type NOT IN ('RESERVE')) THEN
        IF (h_reporting_flag = 'R') THEN
          INSERT INTO xxfa_balances_reports_itf
            (asset_id,
             distribution_ccid,
             adjustment_ccid,
             category_books_account,
             source_type_code,
             amount,
             request_id,
             book_type_code)
            SELECT dh.asset_id,
                   --DH.Code_Combination_ID,
                   nvl(gad.deprn_expense_acct_ccid, dh.code_combination_id),
                   -- Changed for BMA1
                   -- nvl(gad.asset_cost_acct_ccid,1127),
                   gad.asset_cost_acct_ccid,
                   NULL,
                   decode(report_type,
                          'RESERVE',
                          decode(dd.deprn_source_code,
                                 'D',
                                 begin_or_end,
                                 'ADDITION'),
                          'REVAL RESERVE',
                          decode(dd.deprn_source_code,
                                 'D',
                                 begin_or_end,
                                 'ADDITION'),
                          begin_or_end),
                   decode(report_type,
                          -- Commented by Prabakar
                          'COST',
                          decode(nvl(bk.group_asset_id, -2),
                                 -2,
                                 dd.cost,
                                 bk.cost),
                          --          'COST', DD.Cost,
                          'CIP COST',
                          dd.cost,
                          'RESERVE',
                          dd.deprn_reserve,
                          'REVAL RESERVE',
                          dd.reval_reserve),
                   h_request_id,
                   book
              FROM fa_mc_books          bk,
                   fa_category_books       cb,
                   fa_asset_history        ah,
                   fa_mc_deprn_detail   dd,
                   fa_distribution_history dh,
                   -- Commented by Prabakar
                   fa_group_asset_default gad
             WHERE
            -- Commented by Prabakar
             gad.book_type_code = bk.book_type_code
             AND gad.group_asset_id = bk.group_asset_id
             AND
            -- This is to include only the Group Asset Members
             bk.group_asset_id IS NOT NULL
             AND dh.book_type_code = distribution_source_book
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
             dh.date_effective AND nvl(dh.date_ineffective, SYSDATE)
             AND dd.asset_id BETWEEN start_range AND end_range --Anuj
             AND dd.asset_id = dh.asset_id
	     AND bk.set_of_books_id = h_set_of_books_id
	     AND dd.set_of_books_id = h_set_of_books_id
             AND dd.book_type_code = book
             AND dd.distribution_id = dh.distribution_id
             AND dd.period_counter <= period_pc
             AND decode(begin_or_end, 'BEGIN', dd.deprn_source_code, 'D') =
             dd.deprn_source_code
             AND dd.period_counter =
             (SELECT MAX(sub_dd.period_counter)
                FROM fa_mc_deprn_detail sub_dd
               WHERE sub_dd.book_type_code = book
                 AND sub_dd.distribution_id = dh.distribution_id
		 AND sub_dd.set_of_books_id = h_set_of_books_id
                 AND sub_dd.period_counter <= period_pc)
             AND ah.asset_id = dd.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
             report_type IN ('COST', 'CIP COST')) OR
             (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
             report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
             ah.date_effective AND nvl(ah.date_ineffective, SYSDATE)
             AND cb.category_id = ah.category_id
             AND cb.book_type_code = book
             AND bk.book_type_code = book
             AND bk.asset_id = dd.asset_id
             AND
            -- Commented by Prabakar
             (bk.transaction_header_id_in =
             (SELECT MIN(fab.transaction_header_id_in)
                 FROM fa_books_groups_mrc_v bg, fa_mc_books fab
                WHERE bg.group_asset_id = nvl(bk.group_asset_id, -2)
                  AND bg.book_type_code = fab.book_type_code
                  AND fab.transaction_header_id_in <=
                      bg.transaction_header_id_in
                  AND nvl(fab.transaction_header_id_out,
                          bg.transaction_header_id_in) >=
                      bg.transaction_header_id_in
                  AND bg.period_counter = period_pc + 1
		  AND fab.set_of_books_id = h_set_of_books_id
                  AND fab.asset_id = bk.asset_id
                  AND fab.book_type_code = bk.book_type_code
                  AND bg.beginning_balance_flag IS NOT NULL))
             AND decode(report_type,
                    'COST',
                    decode(ah.asset_type,
                           'CAPITALIZED',
                           cb.asset_cost_acct,
                           NULL),
                    'CIP COST',
                    decode(ah.asset_type, 'CIP', cb.cip_cost_acct, NULL),
                    'RESERVE',
                    cb.deprn_reserve_acct,
                    'REVAL RESERVE',
                    cb.reval_reserve_acct) IS NOT NULL;
        ELSE
          INSERT INTO xxfa_balances_reports_itf
            (asset_id,
             distribution_ccid,
             adjustment_ccid,
             category_books_account,
             source_type_code,
             amount,
             request_id,
             book_type_code)
            SELECT dh.asset_id,
                   --DH.Code_Combination_ID,
                   nvl(gad.deprn_expense_acct_ccid, dh.code_combination_id),
                   -- Changed for BMA1
                   -- nvl(gad.asset_cost_acct_ccid,1127),
                   gad.asset_cost_acct_ccid,
                   NULL,
                   decode(report_type,
                          'RESERVE',
                          decode(dd.deprn_source_code,
                                 'D',
                                 begin_or_end,
                                 'ADDITION'),
                          'REVAL RESERVE',
                          decode(dd.deprn_source_code,
                                 'D',
                                 begin_or_end,
                                 'ADDITION'),
                          begin_or_end),
                   decode(report_type,
                          -- Commented by Prabakar
                          'COST',
                          decode(nvl(bk.group_asset_id, -2),
                                 -2,
                                 dd.cost,
                                 bk.cost),
                          --          'COST', DD.Cost,
                          'CIP COST',
                          dd.cost,
                          'RESERVE',
                          dd.deprn_reserve,
                          'REVAL RESERVE',
                          dd.reval_reserve),
                   h_request_id,
                   book
              FROM fa_books                bk,
                   fa_category_books       cb,
                   fa_asset_history        ah,
                   fa_deprn_detail         dd,
                   fa_distribution_history dh,
                   -- Commented by Prabakar
                   fa_group_asset_default gad
             WHERE
            -- Commented by Prabakar
             gad.book_type_code = bk.book_type_code
             AND gad.group_asset_id = bk.group_asset_id
             AND
            -- This is to include only the Group Asset Members
             bk.group_asset_id IS NOT NULL
             AND dh.book_type_code = distribution_source_book
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
             dh.date_effective AND nvl(dh.date_ineffective, SYSDATE)
             AND dd.asset_id BETWEEN start_range AND end_range --Anuj
             AND dd.asset_id = dh.asset_id
             AND dd.book_type_code = book
             AND dd.distribution_id = dh.distribution_id
             AND dd.period_counter <= period_pc
             AND decode(begin_or_end, 'BEGIN', dd.deprn_source_code, 'D') =
             dd.deprn_source_code
             AND dd.period_counter =
             (SELECT MAX(sub_dd.period_counter)
                FROM fa_deprn_detail sub_dd
               WHERE sub_dd.book_type_code = book
                 AND sub_dd.distribution_id = dh.distribution_id
                 AND sub_dd.period_counter <= period_pc)
             AND ah.asset_id = dd.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
             report_type IN ('COST', 'CIP COST')) OR
             (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
             report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
             ah.date_effective AND nvl(ah.date_ineffective, SYSDATE)
             AND cb.category_id = ah.category_id
             AND cb.book_type_code = book
             AND bk.book_type_code = book
             AND bk.asset_id = dd.asset_id
             AND
            -- Commented by Prabakar
             (bk.transaction_header_id_in =
             (SELECT MIN(fab.transaction_header_id_in)
                 FROM fa_books_groups bg, fa_books fab
                WHERE bg.group_asset_id = nvl(bk.group_asset_id, -2)
                  AND bg.book_type_code = fab.book_type_code
                  AND fab.transaction_header_id_in <=
                      bg.transaction_header_id_in
                  AND nvl(fab.transaction_header_id_out,
                          bg.transaction_header_id_in) >=
                      bg.transaction_header_id_in
                  AND bg.period_counter = period_pc + 1
                  AND fab.asset_id = bk.asset_id
                  AND fab.book_type_code = bk.book_type_code
                  AND bg.beginning_balance_flag IS NOT NULL))
             AND decode(report_type,
                    'COST',
                    decode(ah.asset_type,
                           'CAPITALIZED',
                           cb.asset_cost_acct,
                           NULL),
                    'CIP COST',
                    decode(ah.asset_type, 'CIP', cb.cip_cost_acct, NULL),
                    'RESERVE',
                    cb.deprn_reserve_acct,
                    'REVAL RESERVE',
                    cb.reval_reserve_acct) IS NOT NULL;
        END IF;
      ELSE

        -- Get the Depreciation reserve begin balance

        IF (h_reporting_flag = 'R') THEN
          INSERT INTO xxfa_balances_reports_itf
            (asset_id,
             distribution_ccid,
             adjustment_ccid,
             category_books_account,
             source_type_code,
             amount,
             request_id,
             book_type_code)
            SELECT gar.group_asset_id asset_id,
                   gad.deprn_expense_acct_ccid,
                   gad.deprn_reserve_acct_ccid,
                   NULL,
                   /* DECODE(Report_Type,
                     'RESERVE', DECODE(DD.Deprn_Source_Code,
                       'D', Begin_or_End, 'ADDITION'),
                     'REVAL RESERVE',
                   DECODE(DD.Deprn_Source_Code,
                       'D', Begin_or_End, 'ADDITION'),
                     Begin_or_End),
                         */
                   'BEGIN',
                   dd.deprn_reserve,
                   h_request_id,
                   book
              FROM fa_mc_deprn_summary dd,
                   fa_group_asset_rules   gar,
                   fa_group_asset_default gad
             WHERE dd.book_type_code = book
               AND dd.asset_id = gar.group_asset_id
               AND gar.book_type_code = dd.book_type_code
               AND gad.book_type_code = gar.book_type_code
	       AND dd.set_of_books_id = h_set_of_books_id
               AND gad.group_asset_id = gar.group_asset_id
               AND dd.asset_id BETWEEN start_range AND end_range --Anuj
               AND dd.period_counter =
                   (SELECT MAX(dd_sub.period_counter)
                      FROM fa_mc_deprn_detail dd_sub
                     WHERE dd_sub.book_type_code = book
                       AND dd_sub.asset_id = gar.group_asset_id
		       AND dd_sub.set_of_books_id = h_set_of_books_id
                       AND dd_sub.period_counter <= period_pc);
        ELSE
          INSERT INTO xxfa_balances_reports_itf
            (asset_id,
             distribution_ccid,
             adjustment_ccid,
             category_books_account,
             source_type_code,
             amount,
             request_id,
             book_type_code)
            SELECT gar.group_asset_id asset_id,
                   gad.deprn_expense_acct_ccid,
                   gad.deprn_reserve_acct_ccid,
                   NULL,
                   /* DECODE(Report_Type,
                     'RESERVE', DECODE(DD.Deprn_Source_Code,
                       'D', Begin_or_End, 'ADDITION'),
                     'REVAL RESERVE',
                   DECODE(DD.Deprn_Source_Code,
                       'D', Begin_or_End, 'ADDITION'),
                     Begin_or_End),
                         */
                   'BEGIN',
                   dd.deprn_reserve,
                   h_request_id,
                   book
              FROM fa_deprn_summary       dd,
                   fa_group_asset_rules   gar,
                   fa_group_asset_default gad
             WHERE dd.book_type_code = book
               AND dd.asset_id = gar.group_asset_id
               AND dd.asset_id BETWEEN start_range AND end_range --Anuj
               AND gar.book_type_code = dd.book_type_code
               AND gad.book_type_code = gar.book_type_code
               AND gad.group_asset_id = gar.group_asset_id
               AND dd.period_counter =
                   (SELECT MAX(dd_sub.period_counter)
                      FROM fa_deprn_detail dd_sub
                     WHERE dd_sub.book_type_code = book
                       AND dd_sub.asset_id = gar.group_asset_id
                       AND dd_sub.period_counter <= period_pc);
        END IF;
        --NULL;
      END IF;

    END IF; --end of CRL check
  END get_balance_group_begin;

  PROCEDURE get_balance_group_end(book                     IN VARCHAR2,
                                  distribution_source_book IN VARCHAR2,
                                  period_pc                IN NUMBER,
                                  earliest_pc              IN NUMBER,
                                  period_date              IN DATE,
                                  additions_date           IN DATE,
                                  report_type              IN VARCHAR2,
                                  balance_type             IN VARCHAR2,
                                  begin_or_end             IN VARCHAR2,
                                  start_range              IN NUMBER,
                                  end_range                IN NUMBER,
                                  h_request_id             IN NUMBER) IS
    p_date            DATE := period_date;
    a_date            DATE := additions_date;
    h_set_of_books_id NUMBER;
    h_reporting_flag  VARCHAR2(1);
  BEGIN

    -- get mrc related info
    BEGIN
      --h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
      SELECT to_number(substrb(userenv('CLIENT_INFO'), 45, 10))
        INTO h_set_of_books_id
        FROM dual;

    EXCEPTION
      WHEN OTHERS THEN
        h_set_of_books_id := NULL;
    END;

    IF (h_set_of_books_id IS NOT NULL) THEN
      IF NOT
          fa_cache_pkg.fazcsob(x_set_of_books_id   => h_set_of_books_id,
                               x_mrc_sob_type_code => h_reporting_flag) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      h_reporting_flag := 'P';
    END IF;

    -- run only if CRL installed
    IF (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') THEN

      IF report_type NOT IN ('RESERVE') THEN
        IF (h_reporting_flag = 'R') THEN
          INSERT INTO xxfa_balances_reports_itf
            (asset_id,
             distribution_ccid,
             adjustment_ccid,
             category_books_account,
             source_type_code,
             amount,
             request_id,
             book_type_code)
            SELECT dh.asset_id,
                   -- DH.Code_Combination_ID,
                   nvl(gad.deprn_expense_acct_ccid, dh.code_combination_id),
                   -- Changed for BMA1
                   -- nvl(gad.asset_cost_acct_ccid,1127),
                   gad.asset_cost_acct_ccid,
                   NULL,
                   decode(report_type,
                          'RESERVE',
                          decode(dd.deprn_source_code,
                                 'D',
                                 begin_or_end,
                                 'ADDITION'),
                          'REVAL RESERVE',
                          decode(dd.deprn_source_code,
                                 'D',
                                 begin_or_end,
                                 'ADDITION'),
                          begin_or_end),
                   decode(report_type,
                          'COST',
                          decode(nvl(bk.group_asset_id, -2),
                                 -2,
                                 dd.cost,
                                 bk.cost),
                          'CIP COST',
                          dd.cost,
                          'RESERVE',
                          dd.deprn_reserve,
                          'REVAL RESERVE',
                          dd.reval_reserve),
                   h_request_id,
                   book
              FROM fa_mc_books          bk,
                   fa_category_books       cb,
                   fa_asset_history        ah,
                   fa_mc_deprn_detail   dd,
                   fa_distribution_history dh,
                   -- Commented by Prabakar
                   fa_group_asset_default gad
             WHERE
            -- Commented by Prabakar
             gad.book_type_code = bk.book_type_code
             AND gad.group_asset_id = bk.group_asset_id
            -- This is to include only the Group Asset Members
             AND bk.group_asset_id IS NOT NULL
             AND dh.book_type_code = distribution_source_book
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
             dh.date_effective AND nvl(dh.date_ineffective, SYSDATE)
             AND dd.asset_id = dh.asset_id
             AND dd.book_type_code = book
             AND dd.distribution_id = dh.distribution_id
             AND dd.period_counter <= period_pc
             AND dd.asset_id BETWEEN start_range AND end_range --Anuj
	     AND bk.set_of_books_id = h_set_of_books_id
	     AND dd.set_of_books_id = h_set_of_books_id
             AND decode(begin_or_end, 'BEGIN', dd.deprn_source_code, 'D') =
             dd.deprn_source_code
             AND dd.period_counter =
             (SELECT MAX(sub_dd.period_counter)
                FROM fa_mc_deprn_detail sub_dd
               WHERE sub_dd.book_type_code = book
                 AND sub_dd.distribution_id = dh.distribution_id
		 AND sub_dd.set_of_books_id = h_set_of_books_id
                 AND sub_dd.period_counter <= period_pc)
             AND ah.asset_id = dd.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
             report_type IN ('COST', 'CIP COST')) OR
             (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
             report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
             ah.date_effective AND nvl(ah.date_ineffective, SYSDATE)
             AND cb.category_id = ah.category_id
             AND cb.book_type_code = book
             AND bk.book_type_code = book
             AND bk.asset_id = dd.asset_id
             AND
            -- Commented by Prabakar
             (bk.transaction_header_id_in =
             (SELECT MIN(fab.transaction_header_id_in)
                 FROM fa_books_groups_mrc_v bg, fa_mc_books fab
                WHERE bg.group_asset_id = nvl(bk.group_asset_id, -2)
                  AND bg.book_type_code = fab.book_type_code
                  AND fab.transaction_header_id_in <=
                      bg.transaction_header_id_in
		  AND fab.set_of_books_id = h_set_of_books_id
                  AND nvl(fab.transaction_header_id_out,
                          bg.transaction_header_id_in) >=
                      bg.transaction_header_id_in
                  AND bg.period_counter = period_pc + 1
                  AND fab.asset_id = bk.asset_id
                  AND fab.book_type_code = bk.book_type_code
                  AND bg.beginning_balance_flag IS NOT NULL))
             AND decode(report_type,
                    'COST',
                    decode(ah.asset_type,
                           'CAPITALIZED',
                           cb.asset_cost_acct,
                           NULL),
                    'CIP COST',
                    decode(ah.asset_type, 'CIP', cb.cip_cost_acct, NULL),
                    'RESERVE',
                    cb.deprn_reserve_acct,
                    'REVAL RESERVE',
                    cb.reval_reserve_acct) IS NOT NULL;
        ELSE
          INSERT INTO xxfa_balances_reports_itf
            (asset_id,
             distribution_ccid,
             adjustment_ccid,
             category_books_account,
             source_type_code,
             amount,
             request_id,
             book_type_code)
            SELECT dh.asset_id,
                   -- DH.Code_Combination_ID,
                   nvl(gad.deprn_expense_acct_ccid, dh.code_combination_id),
                   -- Changed for BMA1
                   -- nvl(gad.asset_cost_acct_ccid,1127),
                   gad.asset_cost_acct_ccid,
                   NULL,
                   decode(report_type,
                          'RESERVE',
                          decode(dd.deprn_source_code,
                                 'D',
                                 begin_or_end,
                                 'ADDITION'),
                          'REVAL RESERVE',
                          decode(dd.deprn_source_code,
                                 'D',
                                 begin_or_end,
                                 'ADDITION'),
                          begin_or_end),
                   decode(report_type,
                          'COST',
                          decode(nvl(bk.group_asset_id, -2),
                                 -2,
                                 dd.cost,
                                 bk.cost),
                          'CIP COST',
                          dd.cost,
                          'RESERVE',
                          dd.deprn_reserve,
                          'REVAL RESERVE',
                          dd.reval_reserve),
                   h_request_id,
                   book
              FROM fa_books                bk,
                   fa_category_books       cb,
                   fa_asset_history        ah,
                   fa_deprn_detail         dd,
                   fa_distribution_history dh,
                   -- Commented by Prabakar
                   fa_group_asset_default gad
             WHERE
            -- Commented by Prabakar
             gad.book_type_code = bk.book_type_code
             AND gad.group_asset_id = bk.group_asset_id
            -- This is to include only the Group Asset Members
             AND bk.group_asset_id IS NOT NULL
             AND dh.book_type_code = distribution_source_book
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
             dh.date_effective AND nvl(dh.date_ineffective, SYSDATE)
             AND dd.asset_id BETWEEN start_range AND end_range --Anuj
             AND dd.asset_id = dh.asset_id
             AND dd.book_type_code = book
             AND dd.distribution_id = dh.distribution_id
             AND dd.period_counter <= period_pc
             AND decode(begin_or_end, 'BEGIN', dd.deprn_source_code, 'D') =
             dd.deprn_source_code
             AND dd.period_counter =
             (SELECT MAX(sub_dd.period_counter)
                FROM fa_deprn_detail sub_dd
               WHERE sub_dd.book_type_code = book
                 AND sub_dd.distribution_id = dh.distribution_id
                 AND sub_dd.period_counter <= period_pc)
             AND ah.asset_id = dd.asset_id
             AND ((ah.asset_type <> 'EXPENSED' AND
             report_type IN ('COST', 'CIP COST')) OR
             (ah.asset_type IN ('CAPITALIZED', 'CIP') AND
             report_type IN ('RESERVE', 'REVAL RESERVE')))
             AND decode(dd.deprn_source_code, 'D', p_date, a_date) BETWEEN
             ah.date_effective AND nvl(ah.date_ineffective, SYSDATE)
             AND cb.category_id = ah.category_id
             AND cb.book_type_code = book
             AND bk.book_type_code = book
             AND bk.asset_id = dd.asset_id
             AND
            -- Commented by Prabakar
             (bk.transaction_header_id_in =
             (SELECT MIN(fab.transaction_header_id_in)
                 FROM fa_books_groups bg, fa_books fab
                WHERE bg.group_asset_id = nvl(bk.group_asset_id, -2)
                  AND bg.book_type_code = fab.book_type_code
                  AND fab.transaction_header_id_in <=
                      bg.transaction_header_id_in
                  AND nvl(fab.transaction_header_id_out,
                          bg.transaction_header_id_in) >=
                      bg.transaction_header_id_in
                  AND bg.period_counter = period_pc + 1
                  AND fab.asset_id = bk.asset_id
                  AND fab.book_type_code = bk.book_type_code
                  AND bg.beginning_balance_flag IS NOT NULL))
             AND decode(report_type,
                    'COST',
                    decode(ah.asset_type,
                           'CAPITALIZED',
                           cb.asset_cost_acct,
                           NULL),
                    'CIP COST',
                    decode(ah.asset_type, 'CIP', cb.cip_cost_acct, NULL),
                    'RESERVE',
                    cb.deprn_reserve_acct,
                    'REVAL RESERVE',
                    cb.reval_reserve_acct) IS NOT NULL;
        END IF;

      ELSE

        IF (h_reporting_flag = 'R') THEN
          INSERT INTO xxfa_balances_reports_itf
            (asset_id,
             distribution_ccid,
             adjustment_ccid,
             category_books_account,
             source_type_code,
             amount,
             request_id,
             book_type_code)
            SELECT gar.group_asset_id asset_id,
                   gad.deprn_expense_acct_ccid,
                   gad.deprn_reserve_acct_ccid,
                   NULL,
                   /* DECODE(Report_Type,
                     'RESERVE', DECODE(DD.Deprn_Source_Code,
                       'D', Begin_or_End, 'ADDITION'),
                     'REVAL RESERVE',
                   DECODE(DD.Deprn_Source_Code,
                       'D', Begin_or_End, 'ADDITION'),
                     Begin_or_End),*/
                   'END',
                   dd.deprn_reserve,
                   h_request_id,
                   book
              FROM fa_mc_deprn_summary dd,
                   fa_group_asset_rules   gar,
                   fa_group_asset_default gad
             WHERE dd.book_type_code = book
               AND dd.asset_id = gar.group_asset_id
               AND dd.asset_id BETWEEN start_range AND end_range --Anuj
               AND gar.book_type_code = dd.book_type_code
               AND gad.book_type_code = gar.book_type_code
               AND gad.group_asset_id = gar.group_asset_id
	       AND dd.set_of_books_id = h_set_of_books_id
               AND dd.period_counter =
                   (SELECT MAX(dd_sub.period_counter)
                      FROM fa_mc_deprn_detail dd_sub
                     WHERE dd_sub.book_type_code = book
                       AND dd_sub.asset_id = gar.group_asset_id
		       AND dd_sub.set_of_books_id = h_set_of_books_id
                       AND dd_sub.period_counter <= period_pc);
        ELSE
          INSERT INTO xxfa_balances_reports_itf
            (asset_id,
             distribution_ccid,
             adjustment_ccid,
             category_books_account,
             source_type_code,
             amount,
             request_id,
             book_type_code)
            SELECT gar.group_asset_id asset_id,
                   gad.deprn_expense_acct_ccid,
                   gad.deprn_reserve_acct_ccid,
                   NULL,
                   /* DECODE(Report_Type,
                     'RESERVE', DECODE(DD.Deprn_Source_Code,
                       'D', Begin_or_End, 'ADDITION'),
                     'REVAL RESERVE',
                   DECODE(DD.Deprn_Source_Code,
                       'D', Begin_or_End, 'ADDITION'),
                     Begin_or_End),*/
                   'END',
                   dd.deprn_reserve,
                   h_request_id,
                   book
              FROM fa_deprn_summary       dd,
                   fa_group_asset_rules   gar,
                   fa_group_asset_default gad
             WHERE dd.book_type_code = book
               AND dd.asset_id = gar.group_asset_id
               AND dd.asset_id BETWEEN start_range AND end_range --Anuj
               AND gar.book_type_code = dd.book_type_code
               AND gad.book_type_code = gar.book_type_code
               AND gad.group_asset_id = gar.group_asset_id
               AND dd.period_counter =
                   (SELECT MAX(dd_sub.period_counter)
                      FROM fa_deprn_detail dd_sub
                     WHERE dd_sub.book_type_code = book
                       AND dd_sub.asset_id = gar.group_asset_id
                       AND dd_sub.period_counter <= period_pc);
        END IF;
      END IF;

    END IF; -- end of CRL check
  END get_balance_group_end;

  PROCEDURE get_deprn_effects(book                     IN VARCHAR2,
                              distribution_source_book IN VARCHAR2,
                              period1_pc               IN NUMBER,
                              period2_pc               IN NUMBER,
                              report_type              IN VARCHAR2,
                              start_range              IN NUMBER,
                              end_range                IN NUMBER,
                              h_request_id             IN NUMBER) IS
    h_set_of_books_id NUMBER;
    h_reporting_flag  VARCHAR2(1);
  BEGIN

    -- get mrc related info
    BEGIN
      -- h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
      SELECT to_number(substrb(userenv('CLIENT_INFO'), 45, 10))
        INTO h_set_of_books_id
        FROM dual;

    EXCEPTION
      WHEN OTHERS THEN
        h_set_of_books_id := NULL;
    END;

    IF (h_set_of_books_id IS NOT NULL) THEN
      IF NOT
          fa_cache_pkg.fazcsob(x_set_of_books_id   => h_set_of_books_id,
                               x_mrc_sob_type_code => h_reporting_flag) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      h_reporting_flag := 'P';
    END IF;

    IF (h_reporting_flag = 'R') THEN
      INSERT INTO xxfa_reserve_reports_itf
        (asset_id,
         distribution_ccid,
         adjustment_ccid,
         category_books_account,
         source_type_code,
         amount,
         request_id,
         book_type_code)
        SELECT dh.asset_id,
               dh.code_combination_id,
               NULL,
               decode(report_type,
                      'RESERVE',
                      cb.deprn_reserve_acct,
                      'REVAL RESERVE',
                      cb.reval_reserve_acct),
               decode(dd.deprn_source_code, 'D', 'DEPRECIATION', 'ADDITION'),
               SUM(decode(report_type,
                          'RESERVE',
                          dd.deprn_amount -
                          decode(adj.debit_credit_flag, 'DR', 1, -1) *
                          nvl(adj.adjustment_amount, 0),
                          'REVAL RESERVE',
                          -dd.reval_amortization)),
               h_request_id,
               book
          FROM fa_category_books       cb,
               fa_distribution_history dh,
               fa_asset_history        ah,
               fa_mc_deprn_detail   dd,
               fa_mc_deprn_periods  dp,
               fa_mc_adjustments    adj
         WHERE dh.book_type_code = distribution_source_book
           AND ah.asset_id = dd.asset_id
           AND ah.asset_type IN ('CAPITALIZED', 'CIP')
           AND ah.date_effective < nvl(dh.date_ineffective, SYSDATE)
           AND nvl(dh.date_ineffective, SYSDATE) <=
               nvl(ah.date_ineffective, SYSDATE)
           AND dd.asset_id BETWEEN start_range AND end_range --Anuj
           AND cb.category_id = ah.category_id
           AND cb.book_type_code = book
           AND ((dd.deprn_source_code = 'B' AND
               (dd.period_counter + 1) < period2_pc) OR
               (dd.deprn_source_code = 'D'))
           AND dd.book_type_code || '' = book
           AND dd.asset_id = dh.asset_id
           AND dd.distribution_id = dh.distribution_id
	   AND dd.set_of_books_id = h_set_of_books_id
	   AND dp.set_of_books_id = h_set_of_books_id
	   AND adj.set_of_books_id(+) = h_set_of_books_id
           AND dd.period_counter BETWEEN period1_pc AND period2_pc
           AND dp.book_type_code = dd.book_type_code
           AND dp.period_counter = dd.period_counter
           AND decode(report_type,
                      'RESERVE',
                      cb.deprn_reserve_acct,
                      'REVAL RESERVE',
                      cb.reval_reserve_acct) IS NOT NULL
           AND (decode(report_type,
                       'RESERVE',
                       dd.deprn_amount,
                       'REVAL RESERVE',
                       nvl(dd.reval_amortization, 0)) <> 0 OR
               decode(report_type,
                       'RESERVE',
                       dd.deprn_amount - nvl(dd.deprn_adjustment_amount, 0),
                       'REVAL RESERVE',
                       nvl(dd.reval_amortization, 0)) <> 0)
           AND adj.asset_id(+) = dd.asset_id
           AND adj.book_type_code(+) = dd.book_type_code
           AND adj.period_counter_created(+) = dd.period_counter
           AND adj.distribution_id(+) = dd.distribution_id
           AND adj.source_type_code(+) = 'REVALUATION'
           AND adj.adjustment_type(+) = 'EXPENSE'
           AND adj.adjustment_amount(+) <> 0
         GROUP BY dh.asset_id,
                  dh.code_combination_id,
                  decode(report_type,
                         'RESERVE',
                         cb.deprn_reserve_acct,
                         'REVAL RESERVE',
                         cb.reval_reserve_acct),
                  dd.deprn_source_code;
    ELSE
      INSERT INTO xxfa_reserve_reports_itf
        (asset_id,
         distribution_ccid,
         adjustment_ccid,
         category_books_account,
         source_type_code,
         amount,
         request_id,
         book_type_code)
        SELECT dh.asset_id,
               dh.code_combination_id,
               NULL,
               decode(report_type,
                      'RESERVE',
                      cb.deprn_reserve_acct,
                      'REVAL RESERVE',
                      cb.reval_reserve_acct),
               decode(dd.deprn_source_code, 'D', 'DEPRECIATION', 'ADDITION'),
               SUM(decode(report_type,
                          'RESERVE',
                          dd.deprn_amount -
                          decode(adj.debit_credit_flag, 'DR', 1, -1) *
                          nvl(adj.adjustment_amount, 0),
                          'REVAL RESERVE',
                          -dd.reval_amortization)),
               h_request_id,
               book
          FROM --fa_lookups_b            rt, Bug fix 11727910 fa_lookups_b is not used in this report
               fa_category_books       cb,
               fa_distribution_history dh,
               fa_asset_history        ah,
               fa_deprn_detail         dd,
               fa_deprn_periods        dp,
               fa_adjustments          adj
         WHERE dh.book_type_code = distribution_source_book
           AND ah.asset_id = dd.asset_id
           AND ah.asset_type IN ('CAPITALIZED', 'CIP')
           AND ah.date_effective < nvl(dh.date_ineffective, SYSDATE)
           AND nvl(dh.date_ineffective, SYSDATE) <=
               nvl(ah.date_ineffective, SYSDATE)
           AND dd.asset_id BETWEEN start_range AND end_range --Anuj
           AND cb.category_id = ah.category_id
           AND cb.book_type_code = book
           AND ((dd.deprn_source_code = 'B' AND
               (dd.period_counter + 1) < period2_pc) OR
               (dd.deprn_source_code = 'D'))
           AND dd.book_type_code || '' = book
           AND dd.asset_id = dh.asset_id
           AND dd.distribution_id = dh.distribution_id
           AND dd.period_counter BETWEEN period1_pc AND period2_pc
           AND dp.book_type_code = dd.book_type_code
           AND dp.period_counter = dd.period_counter
           AND decode(report_type,
                      'RESERVE',
                      cb.deprn_reserve_acct,
                      'REVAL RESERVE',
                      cb.reval_reserve_acct) IS NOT NULL
           AND (decode(report_type,
                       'RESERVE',
                       dd.deprn_amount,
                       'REVAL RESERVE',
                       nvl(dd.reval_amortization, 0)) <> 0 OR
               decode(report_type,
                       'RESERVE',
                       dd.deprn_amount - nvl(dd.deprn_adjustment_amount, 0),
                       'REVAL RESERVE',
                       nvl(dd.reval_amortization, 0)) <> 0)
           AND adj.asset_id(+) = dd.asset_id
           AND adj.book_type_code(+) = dd.book_type_code
           AND adj.period_counter_created(+) = dd.period_counter
           AND adj.distribution_id(+) = dd.distribution_id
           AND adj.source_type_code(+) = 'REVALUATION'
           AND adj.adjustment_type(+) = 'EXPENSE'
           AND adj.adjustment_amount(+) <> 0
         GROUP BY dh.asset_id,
                  dh.code_combination_id,
                  decode(report_type,
                         'RESERVE',
                         cb.deprn_reserve_acct,
                         'REVAL RESERVE',
                         cb.reval_reserve_acct),
                  dd.deprn_source_code;
    END IF;

    -- run only if CRL installed
    IF (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') THEN

      -- Get the Group Depreciation Effects

      IF (h_reporting_flag = 'R') THEN
        INSERT INTO xxfa_reserve_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT dd.asset_id,
                 gad.deprn_expense_acct_ccid,
                 gad.deprn_reserve_acct_ccid,
                 NULL,
                 'DEPRECIATION',
                 SUM(dd.deprn_amount),
                 h_request_id,
                 book
            FROM fa_mc_deprn_summary dd,
                 fa_group_asset_rules   gar,
                 fa_group_asset_default gad
           WHERE dd.book_type_code = book
             AND dd.asset_id = gar.group_asset_id
             AND dd.asset_id BETWEEN start_range AND end_range --Anuj
             AND gar.book_type_code = dd.book_type_code
             AND gad.book_type_code = gar.book_type_code
             AND gad.group_asset_id = gar.group_asset_id
	     AND dd.set_of_books_id = h_set_of_books_id
             AND dd.period_counter BETWEEN period1_pc AND period2_pc
           GROUP BY dd.asset_id,
                    gad.deprn_expense_acct_ccid,
                    gad.deprn_reserve_acct_ccid,
                    NULL,
                    'DEPRECIATION';
      ELSE
        INSERT INTO xxfa_reserve_reports_itf
          (asset_id,
           distribution_ccid,
           adjustment_ccid,
           category_books_account,
           source_type_code,
           amount,
           request_id,
           book_type_code)
          SELECT dd.asset_id,
                 gad.deprn_expense_acct_ccid,
                 gad.deprn_reserve_acct_ccid,
                 NULL,
                 'DEPRECIATION',
                 SUM(dd.deprn_amount),
                 h_request_id,
                 book
            FROM fa_deprn_summary       dd,
                 fa_group_asset_rules   gar,
                 fa_group_asset_default gad
           WHERE dd.book_type_code = book
             AND dd.asset_id = gar.group_asset_id
             AND dd.asset_id BETWEEN start_range AND end_range --Anuj
             AND gar.book_type_code = dd.book_type_code
             AND gad.book_type_code = gar.book_type_code
             AND gad.group_asset_id = gar.group_asset_id
             AND dd.period_counter BETWEEN period1_pc AND period2_pc
           GROUP BY dd.asset_id,
                    gad.deprn_expense_acct_ccid,
                    gad.deprn_reserve_acct_ccid,
                    NULL,
                    'DEPRECIATION';
      END IF;
    END IF; -- end of CRL check

  END get_deprn_effects;

  PROCEDURE  submit_jobs( book                     IN VARCHAR2,
 	                           report_type              IN VARCHAR2,
 	                           report_style             IN VARCHAR2,
 	                           request_id               IN NUMBER,
 	                           period1_pc               IN NUMBER,
 	                           period1_pod              IN DATE,
 	                           period1_pcd              IN DATE,
 	                           period2_pc               IN NUMBER,
 	                           period2_pcd              IN DATE,
 	                           distribution_source_book IN VARCHAR2) is
  begin
     null;
  end;


  PROCEDURE populate_gt_table(errbuf                   IN OUT NOCOPY VARCHAR2,
                              retcode                  IN OUT NOCOPY VARCHAR2,
                              book                     IN VARCHAR2,
                              report_type              IN VARCHAR2,
                              report_style             IN VARCHAR2,
                              request_id               IN NUMBER,
                              worker_number            IN NUMBER,
                              period1_pc               IN NUMBER,
                              period1_pod              IN DATE,
                              period1_pcd              IN DATE,
                              period2_pc               IN NUMBER,
                              period2_pcd              IN DATE,
                              distribution_source_book IN VARCHAR2) IS
    --Define worker cursor here ..

    CURSOR c_range_lock ( request_id_in number,
                          worker_number_in number ) IS
      SELECT start_range, end_range
        FROM fa_worker_jobs
       WHERE request_id = request_id_in
         AND worker_num = worker_number_in
         AND status     = 'UNASSIGNED'
         FOR UPDATE OF status
         order by start_range
         ;

    start_asset_id NUMBER;
    end_asset_id   NUMBER;
    balance_type   VARCHAR2(10);

    beg_period_open_date  DATE;
    beg_period_close_date DATE;
    end_period_open_date  DATE;
    end_period_close_date DATE;
    l_request_id          NUMBER; -- Bug# 8936484
    l_worker_number  number;
    l_bool           boolean;

  BEGIN

    IF (report_type = 'RESERVE' OR report_type = 'REVAL RESERVE') THEN
      balance_type := 'CR';
    ELSE
      balance_type := 'DR';
    END IF;
    l_worker_number := worker_number;
    l_request_id := request_id;


    -- lock the rows owned by the worker
    -- process them 1 by 1
    FOR l_rec in c_range_lock ( l_request_id, l_worker_number ) loop
       BEGIN
            update fa_worker_jobs
            set    status = 'IN PROCESS'
            WHERE  current of c_range_lock;

            start_asset_id := l_rec.start_range;
            end_asset_id   := l_rec.end_range;

        SELECT period_open_date, nvl(period_close_date, SYSDATE)
          INTO beg_period_open_date, beg_period_close_date
          FROM fa_deprn_periods
         WHERE book_type_code = book
           AND period_counter = period1_pc;

        get_balance(book,
                    distribution_source_book,
                    period1_pc - 1,
                    period1_pc - 1,
                    beg_period_open_date,
                    beg_period_close_date,
                    report_type,
                    balance_type,
                    'BEGIN',
                    start_asset_id,
                    end_asset_id,
                    l_request_id);

        -- run only if CRL installed

        IF (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') THEN
          get_balance_group_begin(book,
                                  distribution_source_book,
                                  period1_pc - 1,
                                  period1_pc - 1,
                                  beg_period_open_date,
                                  beg_period_close_date,
                                  report_type,
                                  balance_type,
                                  'BEGIN',
                                  start_asset_id,
                                  end_asset_id,
                                  l_request_id);
        END IF;

        SELECT period_open_date, nvl(period_close_date, SYSDATE)
          INTO end_period_open_date, end_period_close_date
          FROM fa_deprn_periods
         WHERE book_type_code = book
           AND period_counter = period2_pc;

        -- Get Ending Balance
        get_balance(book,
                    distribution_source_book,
                    period2_pc,
                    period1_pc - 1,
                    end_period_close_date,
                    end_period_close_date,
                    report_type,
                    balance_type,
                    'END',
                    start_asset_id,
                    end_asset_id,
                    l_request_id);

        -- run only if CRL installed
        IF (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') THEN
          get_balance_group_end(book,
                                distribution_source_book,
                                period2_pc,
                                period1_pc - 1,
                                end_period_close_date,
                                end_period_close_date,
                                report_type,
                                balance_type,
                                'END',
                                start_asset_id,
                                end_asset_id,
                                l_request_id);
        END IF;

		--BC 20210217, comment out get_adjustments to avoid duplicated sum of ADDITIONS amonut for each asset.
		/*
        get_adjustments(book,
                        distribution_source_book,
                        period1_pc,
                        period2_pc,
                        report_type,
                        balance_type,
                        start_asset_id,
                        end_asset_id,
                        l_request_id);
		*/				

        -- run only if CRL installed
        IF (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') THEN
          get_adjustments_for_group(book,
                                    distribution_source_book,
                                    period1_pc,
                                    period2_pc,
                                    report_type,
                                    balance_type,
                                    start_asset_id,
                                    end_asset_id,
                                    l_request_id);
        END IF;

        IF (report_type = 'RESERVE' OR report_type = 'REVAL RESERVE') THEN
          get_deprn_effects(book,
                            distribution_source_book,
                            period1_pc,
                            period2_pc,
                            report_type,
                            start_asset_id,
                            end_asset_id,
                            l_request_id);
        END IF;
            update fa_worker_jobs
            set    status = 'COMPLETED'
            WHERE  current of c_range_lock;

         EXCEPTION WHEN OTHERS THEN
            update fa_worker_jobs
            set    status = 'FAILED'
            WHERE  current of c_range_lock;

            RAISE;
         END;

      END LOOP;

        COMMIT;
  l_bool := fnd_concurrent.set_completion_status ( status => 'NORMAL',
                                                   message => 'Normal completion');

  EXCEPTION  WHEN OTHERS THEN
          l_bool := fnd_concurrent.set_completion_status ( status => 'ERROR',
                                                           message => SQLERRM );

  END populate_gt_table;

END xxfa_balrep_pkg;

/
