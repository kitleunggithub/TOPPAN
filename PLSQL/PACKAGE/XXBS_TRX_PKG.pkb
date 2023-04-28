--------------------------------------------------------
--  DDL for Package Body XXBS_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXBS_TRX_PKG" 
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
        RETURN NUMBER
    IS
        lv_sub_sell        xxbs_customer_trx_lines.sell_amount%TYPE := 0;
        BEGIN
            SELECT sum(xctl.sell_amount)
            into lv_sub_sell
            FROM xxbs_customer_trx_lines xctl
            WHERE xctl.customer_trx_id = p_customer_trx_id
            ;

            RETURN nvl(lv_sub_sell,0);
        EXCEPTION WHEN OTHERS THEN
            RETURN 0;    
    END get_sub_sell;
/*
   FUNCTION get_sub_cost (p_customer_trx_id IN NUMBER)
     RETURN NUMBER
   IS
      lv_sub_cost         xxbs_customer_trx_lines.est_cost_amount%TYPE := 0;

      CURSOR get_base IS
        SELECT xctl.est_cost_amount cost_amount
        FROM xxbs_customer_trx_lines xctl
        WHERE xctl.customer_trx_id = p_customer_trx_id
        AND   xctl.void_flag = 'N'
        AND   xctl.late_cost_flag = 'N';

   BEGIN
      FOR base_rec IN get_base LOOP
         lv_sub_cost := lv_sub_cost + base_rec.cost_amount;
      END LOOP;

      RETURN lv_sub_cost;
   END get_sub_cost;
*/
    FUNCTION get_sell (p_customer_trx_id IN NUMBER
                 ,p_line_type       IN VARCHAR2)
    RETURN NUMBER
    IS
        lv_sell         xxbs_customer_trx_lines.sell_amount%TYPE := 0;

    BEGIN
        SELECT sum(xctl.sell_amount)
        INTO lv_sell
        FROM xxbs_customer_trx_lines xctl
        WHERE xctl.customer_trx_id = p_customer_trx_id
        AND   xctl.line_type = p_line_type
        ;

        RETURN NVL(lv_sell,0);
    EXCEPTION WHEN OTHERS THEN
        RETURN 0;            
    END get_sell;

    FUNCTION get_base_sell (p_customer_trx_id IN NUMBER)
        RETURN NUMBER
    IS
        lv_sub_sell         xxbs_customer_trx_lines.sell_amount%TYPE := 0;

    BEGIN
        SELECT sum(xctl.sell_amount * xct.exchange_rate) AS sell_amount
        INTO lv_sub_sell
        FROM xxbs_customer_trx xct
        ,    xxbs_customer_trx_lines xctl
        WHERE xct.customer_trx_id = p_customer_trx_id
        AND   xctl.customer_trx_id = xct.customer_trx_id
        ;

        RETURN nvl(lv_sub_sell,0);
    EXCEPTION WHEN OTHERS THEN
        RETURN 0;          
    END get_base_sell;

    FUNCTION get_pa_cost (p_customer_trx_id IN NUMBER, p_category IN VARCHAR2)
        RETURN NUMBER
    IS
        ln_pa_cost         number := 0;
    BEGIN

        select nvl(sum(pcdla.amount),0)
        into ln_pa_cost
        from pa_expenditure_items_all peia
            ,PA_EXPENDITURES_ALL pea
            ,PA_EXPENDITURE_TYPES pet
            ,PA_COST_DISTRIBUTION_LINES_ALL pcdla
            ,PA_PROJECTS_ALL ppa
            ,xxbs_customer_trx xct
        where peia.expenditure_id = pea.expenditure_id
        and peia.expenditure_type = pet.expenditure_type
        and peia.expenditure_item_id = pcdla.expenditure_item_id
        and ppa.project_id = pcdla.project_id
        and ppa.org_id = pcdla.org_id
        and pet.expenditure_category = p_category --'Internal'
        and ppa.project_id = xct.original_project_id
        and xct.customer_trx_id = p_customer_trx_id;

        RETURN ln_pa_cost;
    END get_pa_cost;    

    -- function to get salesrep from custom billing module
    FUNCTION get_salesrep (p_customer_trx_id IN NUMBER,p_rank IN NUMBER,p_type IN NUMBER)
        RETURN VARCHAR2
    IS   
        ln_split        xxbs_rep_splits.split_percentage%TYPE;
        lv_salesrep     JTF_RS_DEFRESOURCES_V.resource_name%TYPE;
        ln_salesid      JTF_RS_DEFRESOURCES_V.resource_id%TYPE;
    BEGIN
        if p_rank = 1 then
            select jrdv.resource_name,split_percentage,resource_id
            into lv_salesrep,ln_split,ln_salesid
            from XXBS_REP_SPLITS xrs,JTF_RS_DEFRESOURCES_V jrdv 
            where xrs.salesrep_id = jrdv.resource_id 
            and xrs.primary_flag = 'Y' 
            and xrs.customer_trx_id = p_customer_trx_id
            and rownum = 1
            ;
        else            
            select resource_name, split_percentage, resource_id
            into lv_salesrep,ln_split,ln_salesid
            from (select jrdv.resource_name
                ,split_percentage 
                ,xrs.rep_split_id
                ,jrdv.resource_id
                ,ROW_NUMBER() OVER(ORDER BY xrs.rep_split_id) RowNumber
                from XXBS_REP_SPLITS xrs,JTF_RS_DEFRESOURCES_V jrdv 
                where xrs.salesrep_id = jrdv.resource_id 
                and xrs.primary_flag <> 'Y' 
                and xrs.customer_trx_id = p_customer_trx_id
                order by xrs.rep_split_id)
            where rownumber = p_rank-1         
            ;
        end if;

        if p_type = 1 then
            return lv_salesrep;
        elsif p_type = 2 then
            return ln_split;
        elsif p_type = 3 then
            return ln_salesid;
        else
            return null;
        end if;
    END get_salesrep;

    -- function to get salesrep from AR module to handle interface_header_context = 'TM CONVERSION'
    FUNCTION get_convsalesrep (p_customer_trx_id IN NUMBER,p_rank IN NUMBER,p_type IN NUMBER)
        RETURN VARCHAR2
    IS   
        ln_split        xxbs_rep_splits.split_percentage%TYPE;
        lv_salesrep     JTF_RS_DEFRESOURCES_V.resource_name%TYPE;
        ln_salesid      JTF_RS_DEFRESOURCES_V.resource_id%TYPE;
    BEGIN

        select sales_name,sales_split,sales_id
        into lv_salesrep,ln_split,ln_salesid
        from
        (
            select 1 rank,customer_trx_id,trx_number,resource_name sales_name,interface_header_attribute11 sales_split,interface_header_attribute10 sales_id 
            from RA_CUSTOMER_TRX_ALL,JTF_RS_DEFRESOURCES_V 
            where resource_id (+) = interface_header_attribute10 
            and resource_name is not null 
            and interface_header_context = 'TM CONVERSION'
            union all
            select 2 rank,customer_trx_id,trx_number,resource_name sales_name,interface_header_attribute13 sales_split,interface_header_attribute12 sales_id 
            from RA_CUSTOMER_TRX_ALL,JTF_RS_DEFRESOURCES_V 
            where resource_id (+) = interface_header_attribute12 
            and resource_name is not null 
            and interface_header_context = 'TM CONVERSION'
            union all 
            select 3 rank,customer_trx_id,trx_number,resource_name sales_name,interface_header_attribute15 sales_split,interface_header_attribute14 sales_id 
            from RA_CUSTOMER_TRX_ALL,JTF_RS_DEFRESOURCES_V 
            where resource_id (+) = interface_header_attribute14 
            and resource_name is not null 
            and interface_header_context = 'TM CONVERSION'
        )
        where rank = p_rank
        and customer_trx_id = p_customer_trx_id;

        if p_type = 1 then
            return lv_salesrep;
        elsif p_type = 2 then
            return ln_split;
        elsif p_type = 3 then
            return ln_salesid;
        else
            return null;
        end if;
    END get_convsalesrep;

    -- function to get non-primary salesrep from custom billing module
    FUNCTION get_othersalesrep (p_customer_trx_id IN NUMBER,p_type IN NUMBER)
        RETURN VARCHAR2
    IS   
        lv_split        VARCHAR2(4000);
        lv_salesrep     VARCHAR2(4000);
        lv_salesid      VARCHAR2(4000);
    BEGIN

        select
            LISTAGG(jrd.resource_name, ', ') WITHIN GROUP (ORDER BY xrs.rep_split_id) OTHER_SALESREP_NAME,
            LISTAGG(xrs.split_percentage, ', ') WITHIN GROUP (ORDER BY xrs.rep_split_id) OTHER_SALESREP_SPLIT,
            LISTAGG(xrs.rep_split_id, ', ') WITHIN GROUP (ORDER BY xrs.rep_split_id) OTHER_SALESREP_ID
        into
            lv_salesrep,
            lv_split,
            lv_salesid
        from xxbs_rep_splits xrs ,JTF_RS_DEFRESOURCES_V jrd
        where xrs.salesrep_id = jrd.resource_id   
        and xrs.primary_flag <> 'Y'
        and xrs.customer_trx_id = p_customer_trx_id
        group by xrs.customer_trx_id
        ;

        if p_type = 1 then
            return lv_salesrep;
        elsif p_type = 2 then
            return lv_split;
        elsif p_type = 3 then
            return lv_salesid;
        else
            return null;
        end if;
    END get_othersalesrep;

    -- function to get non-primary salesrep from AR module to handle interface_header_context = 'TM CONVERSION'    
    FUNCTION get_convothersalesrep (p_customer_trx_id IN NUMBER,p_type IN NUMBER)
        RETURN VARCHAR2
    IS   
        lv_split        VARCHAR2(4000);
        lv_salesrep     VARCHAR2(4000);
        lv_salesid      VARCHAR2(4000);
    BEGIN

        select 
            LISTAGG(sales_name, ', ') WITHIN GROUP (ORDER BY rank) OTHER_SALESREP_NAME,
            LISTAGG(sales_split, ', ') WITHIN GROUP (ORDER BY rank) OTHER_SALESREP_SPLIT,
            LISTAGG(sales_id, ', ') WITHIN GROUP (ORDER BY rank) OTHER_SALESREP_ID     
        into
            lv_salesrep,
            lv_split,
            lv_salesid            
        from
        (
            select 1 rank,customer_trx_id,trx_number,resource_name sales_name,interface_header_attribute11 sales_split,interface_header_attribute10 sales_id 
            from RA_CUSTOMER_TRX_ALL,JTF_RS_DEFRESOURCES_V 
            where resource_id (+) = interface_header_attribute10 
            and resource_name is not null 
            and interface_header_context = 'TM CONVERSION'
            union all
            select 2 rank,customer_trx_id,trx_number,resource_name sales_name,interface_header_attribute13 sales_split,interface_header_attribute12 sales_id 
            from RA_CUSTOMER_TRX_ALL,JTF_RS_DEFRESOURCES_V 
            where resource_id (+) = interface_header_attribute12 
            and resource_name is not null 
            and interface_header_context = 'TM CONVERSION'
            union all 
            select 3 rank,customer_trx_id,trx_number,resource_name sales_name,interface_header_attribute15 sales_split,interface_header_attribute14 sales_id 
            from RA_CUSTOMER_TRX_ALL,JTF_RS_DEFRESOURCES_V 
            where resource_id (+) = interface_header_attribute14 
            and resource_name is not null 
            and interface_header_context = 'TM CONVERSION'
        )
        where customer_trx_id = p_customer_trx_id
        and rank >= 2;

        if p_type = 1 then
            return lv_salesrep;
        elsif p_type = 2 then
            return lv_split;
        elsif p_type = 3 then
            return lv_salesid;
        else
            return null;
        end if;
    END get_convothersalesrep;

    -- function to get salesrep from AR module by trx number
    FUNCTION get_salesrep_by_trx (p_org_id number, p_trx_number IN VARCHAR,p_rank IN NUMBER,p_type IN NUMBER)
        RETURN VARCHAR2
    IS   
        ln_customer_trx_id varchar2(300);
        lv_context varchar2(300);
    BEGIN

        select (case when interface_header_context = 'TM CONVERSION' then to_char(customer_trx_id) 
                when interface_header_context = 'XXBS BILLING INVOICES' then interface_header_attribute3 
                else to_char(customer_trx_id) end) customer_trx_id,
                interface_header_context 
        into ln_customer_trx_id,
            lv_context
        from RA_CUSTOMER_TRX_ALL 
        where org_id = p_org_id
        and trx_number = p_trx_number;

        if lv_context = 'TM CONVERSION' then
            if p_rank = 999 then
                return get_convothersalesrep (ln_customer_trx_id,p_type);
            else
                return get_convsalesrep (ln_customer_trx_id,p_rank,p_type);
            end if;    
        elsif lv_context = 'XXBS BILLING INVOICES' then
            if p_rank = 999 then
                return get_othersalesrep (ln_customer_trx_id,p_type);
            else
                return get_salesrep (ln_customer_trx_id,p_rank,p_type);
            end if;    
        else
            return null;
        end if;

        return null;
    END get_salesrep_by_trx;   

    -- function to get user name
    FUNCTION get_username (p_user_id IN NUMBER)
    RETURN VARCHAR2
    IS   
        lv_username varchar2(300);
    BEGIN
        SELECT description
        INTO lv_username
        FROM FND_USER
        WHERE USER_ID = p_user_id;

        return lv_username;

    END get_username;  

    -- function to get primary product type name
    FUNCTION get_pri_product_type_name (p_primary_product_type_id IN NUMBER)
    RETURN VARCHAR2
    IS   
        lv_name varchar2(300);
    BEGIN
        SELECT name
        INTO lv_name
        FROM AR_MEMO_LINES_ALL_VL
        WHERE memo_line_id = p_primary_product_type_id;

        return lv_name;

    END get_pri_product_type_name;

    FUNCTION get_attachment_yn (p_customer_trx_id IN NUMBER)
        RETURN VARCHAR2
    IS   
        ln_count        number;
    BEGIN
        SELECT count(*)
        INTO ln_count
        FROM
            fnd_documents_vl        d,
            fnd_attached_documents  ad
        WHERE d.document_id = ad.document_id
        AND ad.entity_name = 'XXBS_CUSTOMER_TRX'
        AND ad.pk1_value = p_customer_trx_id
        AND d.datatype_id IN ( 6, 2, 1, 5 )
        AND ( d.security_type = 4 OR d.publish_flag = 'Y');

        if ln_count >=1 then
            return 'Y';
        else
            return 'N';
        end if;

        return 'N';
    END get_attachment_yn;

END xxbs_trx_pkg;


/
