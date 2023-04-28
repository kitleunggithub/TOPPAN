DROP VIEW APPS.XXHR_CODE_COMBINATIONS_V;

/* Formatted on 9/11/2020 12:13:02 pm (QP5 v5.360) */
CREATE OR REPLACE FORCE VIEW APPS.XXHR_CODE_COMBINATIONS_V
(
    CODE_COMBINATION_ID,
    DEFAULT_ACCOUNT
)
BEQUEATH DEFINER
AS
    SELECT code_combination_id,
              segment1
           || '-'
           || segment2
           || '-'
           || segment3
           || '-'
           || segment4
           || '-'
           || segment5
           || '-'
           || segment6    default_account
      FROM gl_code_combinations
     WHERE segment5 = '999999';
