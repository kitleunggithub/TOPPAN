--------------------------------------------------------
--  DDL for Package XXBS_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXBS_TRX_PKG" 
AS
/*******************************************************************************
 *
 * Module Name : Custom Billing
 * Package Name: XXBS_TRX_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 01-MAR-2021
 *
 * Purpose     : This program purpose for custom billing trx report.
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung    01-MAR-2021   Initial Release.
 * DASH Kit Leung    04-MAY-2021   add function 
                                    get_convsalesrep - get salesrep for data conversion trx
                                    get_othersalesrep - get non-primary salesrep for Custom Billing
                                    get_convothersalesrep - get non-primary salesrep for data conversion trx
                                    get_salesrep_by_trx - get salesrep by transaction number
 *
 *******************************************************************************/

    FUNCTION get_sub_sell (p_customer_trx_id IN NUMBER)
    RETURN NUMBER;

    --FUNCTION get_sub_cost (p_customer_trx_id IN NUMBER)
    --RETURN NUMBER;

    FUNCTION get_sell (p_customer_trx_id IN NUMBER
                      ,p_line_type       IN VARCHAR2)
    RETURN NUMBER;

    FUNCTION get_base_sell(p_customer_Trx_id IN NUMBER)
    RETURN NUMBER;

    FUNCTION get_pa_cost(p_customer_Trx_id IN NUMBER, p_category IN VARCHAR2)
    RETURN NUMBER;

    -- function to get salesrep from custom billing module
    FUNCTION get_salesrep (p_customer_trx_id IN NUMBER,p_rank IN NUMBER,p_type IN NUMBER)
    RETURN VARCHAR2;

    -- function to get salesrep from AR module to handle interface_header_context = 'TM CONVERSION'
    FUNCTION get_convsalesrep (p_customer_trx_id IN NUMBER,p_rank IN NUMBER,p_type IN NUMBER)
    RETURN VARCHAR2;

    -- function to get non-primary salesrep from custom billing module
    FUNCTION get_othersalesrep (p_customer_trx_id IN NUMBER,p_type IN NUMBER)
    RETURN VARCHAR2;

    -- function to get non-primary salesrep from AR module to handle interface_header_context = 'TM CONVERSION'    
    FUNCTION get_convothersalesrep (p_customer_trx_id IN NUMBER,p_type IN NUMBER)
    RETURN VARCHAR2;    

    -- function to get salesrep from AR module by trx number
    FUNCTION get_salesrep_by_trx (p_org_id number, p_trx_number IN VARCHAR,p_rank IN NUMBER,p_type IN NUMBER)
    RETURN VARCHAR2;    

    -- function to get user name
    FUNCTION get_username (p_user_id IN NUMBER)
    RETURN VARCHAR2;

    -- function to get primary product type name
    FUNCTION get_pri_product_type_name (p_primary_product_type_id IN NUMBER)
    RETURN VARCHAR2;    

    FUNCTION get_attachment_yn (p_customer_trx_id IN NUMBER)
    RETURN VARCHAR2;
END xxbs_trx_pkg;


/
