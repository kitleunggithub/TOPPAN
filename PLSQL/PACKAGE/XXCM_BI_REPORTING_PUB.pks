--------------------------------------------------------
--  File created - Wednesday-July-14-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package XXCM_BI_REPORTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXCM_BI_REPORTING_PUB" 
IS
/*******************************************************************************
*
* -- 10/20/2013 - Jill DiLeva
* -- New procedures
* ---- xxbs_trx_vat_reg
* ---- xxgl_chart_of_accts_rpt
* ---- xxgl_manual_je_rpt
* ---- xxpa_incorrect_cur_rpt
*
* -- 11/17/2013 - Jill DiLeva
* -- New procedures
* ---- xxar_open_commit_asia_acr
* ---- xxpa_cost_asia_acr
*
* -- 3/3/2014 Jill DiLeva
* -- New function... submit_request_burst
* -- new variables p_emailaddr and p_depositdate
*
* 09/03/2014 akaplan Add apply reset_template
*
* -- 8/20/2015 Jill Dileva
* -- add p_lockbox which we need for the Lockbox data template/bursting process
* 08/21/2017 akaplan    WorkDay - Remediate request_burst (modify parameters)
* 02/14/2018 akaplan    Add function to return standard stylesheet
* 10/17/2018 akaplan    Add exec_parallel function
* 05/24/2019 akaplan    Enh Req 2465: Add Sales Analysis BIP for easier HK access
* 10/01/2019 akaplan    Enh Req 2584: Remove obsolete functions (xxgl_chart_of_accts_rpt, xxpa_cost_asia_acr)
*
*******************************************************************************/



-- BIP Implementation of trigger require the following:
--   all parameters used by BI Publisher must be created here
--   defaultPackage referenced in dataTemplate setup
   p_emailaddr    VARCHAR2(100);
   p_depositdate  VARCHAR2(100);
   p_lockbox      VARCHAR2(100);
   p_date         DATE;
   p_location     VARCHAR2(100);
   p1 VARCHAR2(100);
   p2 VARCHAR2(100);
   p3 VARCHAR2(100);
   p4 VARCHAR2(100);
   p5 VARCHAR2(100);
   p6 VARCHAR2(100);
   p7 VARCHAR2(100);
   p8 VARCHAR2(100);
   p9 VARCHAR2(100);
   p10 VARCHAR2(100);
   p11 VARCHAR2(100);
   p12 VARCHAR2(100);
   p13 VARCHAR2(100);
   p14 VARCHAR2(100);
   p15 VARCHAR2(100);
   p16 VARCHAR2(100);
   p17 VARCHAR2(100);
   p18 VARCHAR2(100);
   p19 VARCHAR2(100);
   p_template     VARCHAR2(100);



 PROCEDURE write_formatted_xml(p_xml        IN XMLTYPE);
 PROCEDURE write_xml_output(p_xml_clob   IN CLOB);
 FUNCTION get_stylesheet RETURN XMLTYPE;
 PROCEDURE data_exists ( p_rowcount NUMBER );

 PROCEDURE xxar_gst_rpt (p_retcode       OUT NUMBER
                        ,p_errbuf        OUT VARCHAR2
                        ,p_trx_class     IN  VARCHAR2
                        ,p_gl_date_low   IN  VARCHAR2
                        ,p_gl_date_high  IN  VARCHAR2
                        ,p_trx_date_low  IN  VARCHAR2
                        ,p_trx_date_high IN  VARCHAR2
                        ,p_tax_code_low  IN  VARCHAR2
                        ,p_tax_code_high IN  VARCHAR2
                        ,p_currency_low  IN  VARCHAR2
                        ,p_currency_high IN  VARCHAR2
                        ,p_posted_status IN  VARCHAR2
                        ,p_org_id        IN  NUMBER);

 PROCEDURE xxap_gst_rpt (p_retcode       OUT NUMBER
                        ,p_errbuf        OUT VARCHAR2
                        ,p_invoice_type  IN  VARCHAR2
                        ,p_gl_date_low   IN  VARCHAR2
                        ,p_gl_date_high  IN  VARCHAR2
                        ,p_trx_date_low  IN  VARCHAR2
                        ,p_trx_date_high IN  VARCHAR2
                        ,p_tax_code_low  IN  VARCHAR2
                        ,p_tax_code_high IN  VARCHAR2
                        ,p_currency_low  IN  VARCHAR2
                        ,p_currency_high IN  VARCHAR2
                        ,p_posted_status IN  VARCHAR2
                        ,p_org_id        IN  NUMBER);

 PROCEDURE xxgl_curr_trial_bal (p_retcode       OUT NUMBER
                               ,p_errbuf        OUT VARCHAR2
                               ,p_period_name   IN  VARCHAR2
							   ,p_access_set_id IN  NUMBER
							   ,p_ledger_short_name   IN  VARCHAR2);

 PROCEDURE xxbs_man_draftrev_rpt (p_retcode     OUT NUMBER
                                 ,p_errbuf      OUT VARCHAR2);

PROCEDURE xxbs_trx_vat_reg (p_retcode       OUT NUMBER
                              ,p_errbuf        OUT VARCHAR2
                              ,p_fr_period_name   IN  VARCHAR2,
                              p_to_period_name   IN  VARCHAR2,
                              p_org_id        IN  NUMBER);

PROCEDURE xxpa_incorrect_cur_rpt (p_retcode OUT NUMBER
                              ,p_errbuf        OUT VARCHAR2
                              ,p_from_gl_date   IN  VARCHAR2
                              ,p_to_gl_date IN VARCHAR2);

PROCEDURE xxpa_open_commit_asia_acr (p_retcode     OUT NUMBER
                                 ,p_errbuf      OUT VARCHAR2);

PROCEDURE xxcm_sales_analysis (p_retcode     OUT NUMBER
                              ,p_errbuf      OUT VARCHAR2
                              ,p_from_period IN  VARCHAR2
                              ,p_to_period   IN  VARCHAR2
                              ,p_le          IN  VARCHAR2
                              ,p_bu          IN  VARCHAR2
                              ,p_site        IN  VARCHAR2
                              ,p_prod_line   IN  VARCHAR2
                              ,p_prod_vert   IN  VARCHAR2
                              ,p_cust_name   IN  VARCHAR2
                              ,p_ic_invoices IN  VARCHAR2);


function submit_request_burst (p_request_id in number
                             , p_burst_type VARCHAR2 DEFAULT 'STD'
                             , p_location   VARCHAR2 DEFAULT NULL
                             )
  return boolean;

 FUNCTION apply_template (p_template VARCHAR2) RETURN BOOLEAN;
 
 FUNCTION apply_printer (p_printer VARCHAR2, p_copies NUMBER) RETURN BOOLEAN;
  
 FUNCTION formatXMLDate (p_date DATE) RETURN VARCHAR2;


 PROCEDURE pl( p_str IN VARCHAR2
             , p_show_time IN VARCHAR2 DEFAULT 'Y');

 FUNCTION exec_parallel RETURN VARCHAR2;

END;

/
