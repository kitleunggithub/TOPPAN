--------------------------------------------------------
--  DDL for Package XXFA_ASSET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXFA_ASSET_PKG" IS
  --------------------------------------------------------------------------------------------------
  /*
  $Revision:   1.0  $
  Package Name:    XXFA_ASSET_PKG.pks
  Author's Name:   Sandeep Akula
  Date Written:    14-JAN-2016
  Purpose:         Fixed Assets package for loading adjustments and additions into staging table
  Program Style:   Stored Package SPECIFICATION
  Called From:
  Calls To:
  Maintenance History:
  Date:          Version                   Name            Remarks
  -----------    ----------------         -------------   ------------------
  14-JAN-2016        1.0                  Sandeep Akula    Initial Version
  ---------------------------------------------------------------------------------------------------*/
  p_request_id NUMBER := fnd_global.conc_request_id;
  p_book_class VARCHAR2(15);
  p_book_type_code VARCHAR2(200); --BC 20210120
  p_from_period VARCHAR2(10);
  p_to_period VARCHAR2(10);
  c_where_clause1 VARCHAR2(150);


TYPE book_record IS RECORD(book_type_code            fa_book_controls.book_type_code%type,
                           accounting_flex_structure fa_book_controls.accounting_flex_structure%type,
                           distribution_source_book  fa_book_controls.distribution_source_book%type,
                           currency_code             gl_sets_of_books.currency_code%type,
                           precision                 fnd_currencies.precision%type);

TYPE currency_exchange_record IS RECORD(entered_currency_amount  NUMBER,
                                      conversion_type VARCHAR2(100),
                                      conversion_date VARCHAR2(30),
                                      conversion_rate NUMBER,
                                      functional_currency_amount NUMBER,
                                      entered_currency VARCHAR2(10),
                                      functional_currency VARCHAR2(10));

TYPE period_record IS RECORD(period_name VARCHAR2(15),
                             period_counter NUMBER,
                             period_open_date DATE,
                             period_close_date DATE,
                             fiscal_year NUMBER);

TYPE addition_period_record IS RECORD(calendar_period_close_date DATE,
                                      fiscal_year NUMBER,
                                      period_name VARCHAR2(15));

TYPE cost_history_record IS RECORD(transaction_header_id  fa_financial_inquiry_cost_v.transaction_header_id_in%type,
                                    transaction_type  fa_financial_inquiry_cost_v.transaction_type%type,
                                    period_entered  fa_financial_inquiry_cost_v.period_entered%type,
                                    period_effective  fa_financial_inquiry_cost_v.period_effective%type,
                                    current_cost  fa_financial_inquiry_cost_v.current_cost%type,
                                    transaction_date_entered  fa_financial_inquiry_cost_v.transaction_date_entered%type,
                                    fiscal_year  fa_financial_inquiry_cost_v.fiscal_year%type,
                                    date_effective  fa_financial_inquiry_cost_v.date_effective%type);

PROCEDURE reset_sequence(p_seq_name IN VARCHAR2);

FUNCTION get_accounting_flex_structure(p_sob_type IN VARCHAR2,
                                       p_book_type IN VARCHAR2)
RETURN book_record;

FUNCTION get_period_info(p_book_type_code IN VARCHAR2,
                         p_period IN VARCHAR2,
                         p_sob_type IN VARCHAR2)
RETURN period_record;

FUNCTION get_gl_string(p_ccid IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_currency_conversion(p_entered_curr_amt IN NUMBER,
                        p_conversion_date IN DATE,
                        --p_conversion_type IN VARCHAR2,
                        p_from_currency IN VARCHAR2)
RETURN currency_exchange_record;

PROCEDURE adjustments(p_sob_id IN NUMBER,
                      p_sob_type IN VARCHAR2,
                      p_book_class IN varchar2,
                      p_book_type_code IN VARCHAR2,
                      p_from_period IN varchar2,
                      p_to_period IN varchar2);

PROCEDURE adjustments_mrc(p_sob_id IN NUMBER,
                          p_sob_type IN VARCHAR2,
                          p_book_class IN varchar2,
                          p_book_type_code IN VARCHAR2,
                          p_from_period IN varchar2,
                          p_to_period IN varchar2);

PROCEDURE load_adjustments(p_book_class IN varchar2,
						   p_book_type_code IN VARCHAR2,  --BC 20210120
                           p_from_period IN varchar2,
                           p_to_period IN varchar2);

FUNCTION get_addition_fiscal_year(p_book_type IN VARCHAR2,
                                  p_period_counter1 IN NUMBER,
                                  p_period_counter2 IN NUMBER,
                                  p_date_effective IN DATE)
RETURN addition_period_record;

PROCEDURE additions(p_sob_id IN NUMBER,
                    p_sob_type IN VARCHAR2,
                    p_book_class IN varchar2,
                    p_book_type_code IN VARCHAR2,
                    p_from_period IN varchar2,
                    p_to_period IN varchar2);

PROCEDURE additions_mrc(p_sob_id IN NUMBER,
                        p_sob_type IN VARCHAR2,
                        p_book_class IN varchar2,
                        p_book_type_code IN VARCHAR2,
                        p_from_period IN varchar2,
                        p_to_period IN varchar2);

PROCEDURE load_additions(p_book_class IN varchar2,
						 p_book_type_code IN VARCHAR2,  --BC 20210120
                         p_from_period IN varchar2,
                         p_to_period IN varchar2);

FUNCTION get_segment_prompt(p_coa_id IN NUMBER,
                            p_segment_num IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_cc_segment_value(p_ccid IN NUMBER,
                              p_segment_column IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION afterpform RETURN BOOLEAN;

FUNCTION beforereport RETURN BOOLEAN ;

FUNCTION afterreport RETURN BOOLEAN;

-- Retirements report Procedures/Functions

FUNCTION get_reserve_retired(p_asset_id IN NUMBER,
                             p_asset_book IN VARCHAR2,
                             p_transaction_header_id IN NUMBER,
                             p_distribution_id IN NUMBER)
RETURN NUMBER;

FUNCTION get_cost_history(p_sob_id IN NUMBER,
                          p_book_type_code IN VARCHAR2,
                          p_asset_id IN NUMBER,
                          p_transaction_header_id IN NUMBER)
RETURN  cost_history_record;


PROCEDURE retirements(p_sob_id IN NUMBER,
                      p_sob_type IN VARCHAR2,
                      p_book_class IN varchar2,
                      p_book_type_code IN VARCHAR2,
                      p_from_period IN varchar2,
                      p_to_period IN varchar2);

PROCEDURE retirements_mrc(p_sob_id IN NUMBER,
                          p_sob_type IN VARCHAR2,
                          p_book_class IN varchar2,
                          p_book_type_code IN VARCHAR2,
                          p_from_period IN varchar2,
                          p_to_period IN varchar2);

PROCEDURE load_retirements(p_book_class IN varchar2,
						   p_book_type_code IN VARCHAR2,  --BC 20210120
                           p_from_period IN varchar2,
                           p_to_period IN varchar2);

FUNCTION ret_afterpform RETURN BOOLEAN;

FUNCTION ret_beforereport RETURN BOOLEAN ;

FUNCTION ret_afterreport RETURN BOOLEAN;


END XXFA_ASSET_PKG;

/
