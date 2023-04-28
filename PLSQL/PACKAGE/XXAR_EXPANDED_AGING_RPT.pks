--------------------------------------------------------
--  DDL for Package XXAR_EXPANDED_AGING_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAR_EXPANDED_AGING_RPT" 
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
   TYPE xxar_expanded_aging_tbl IS TABLE OF xxar_expanded_aging_type;

   FUNCTION get_records(p1    IN VARCHAR2 DEFAULT NULL -- p_reporting_level
                       ,p2    IN NUMBER DEFAULT NULL -- p_reporting_entity_id
                       ,p3    IN NUMBER DEFAULT NULL -- p_ca_set_of_books_id
                       ,p4    IN NUMBER DEFAULT NULL -- p_coaid
                       ,p5    IN NUMBER DEFAULT NULL
                       ,p6    IN VARCHAR2 DEFAULT NULL -- p_in_as_of_date_low
                       ,p7    IN VARCHAR2 DEFAULT NULL -- p_in_bucket_type_low
                       ,p8    IN VARCHAR2 DEFAULT NULL -- p_credit_option
                       ,p9    IN VARCHAR2 DEFAULT NULL -- p_in_currency
                       ,p10   IN VARCHAR2 DEFAULT NULL -- p_risk_option
					   ,p11   IN VARCHAR2 DEFAULT NULL -- p_customer_name  Added as part of CR#1904
					   )
      RETURN xxar_expanded_aging_tbl
      PIPELINED;

    -- Export Record to Tableau
    PROCEDURE get_records_tableau ( p_dir        IN  VARCHAR2,
                                    p_file       IN  VARCHAR2);

END xxar_expanded_aging_rpt;


/
