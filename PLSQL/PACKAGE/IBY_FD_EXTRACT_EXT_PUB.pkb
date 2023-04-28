create or replace PACKAGE BODY IBY_FD_EXTRACT_EXT_PUB  AS
/* $Header: ibyfdxeb.pls 120.2 2006/09/20 18:52:12 frzhang noship $ */


  --
  -- This API is called once only for the payment instruction.
  -- Implementor should construct the extract extension elements
  -- at the payment instruction level as a SQLX XML Aggregate
  -- and return the aggregate.
  --
  -- Below is an example implementation:
/*
  FUNCTION Get_Ins_Ext_Agg(p_payment_instruction_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_ins_ext_agg XMLTYPE;

    CURSOR l_ins_ext_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT XMLConcat(
             XMLElement("Extend",
               XMLElement("Name", ext_table.attr_name1),
               XMLElement("Value", ext_table.attr_value1)),
             XMLElement("Extend",
               XMLElement("Name", ext_table.attr_name2),
               XMLElement("Value", ext_table.attr_value2))
           )
      FROM your_pay_instruction_lvl_table ext_table
     WHERE ext_table.payment_instruction_id = p_payment_instruction_id;

  BEGIN

    OPEN l_ins_ext_csr (p_payment_instruction_id);
    FETCH l_ins_ext_csr INTO l_ins_ext_agg;
    CLOSE l_ins_ext_csr;

    RETURN l_ins_ext_agg;

  END Get_Ins_Ext_Agg;
*/
  FUNCTION Get_Ins_Ext_Agg(p_payment_instruction_id IN NUMBER)
  RETURN XMLTYPE
  IS
  BEGIN
    RETURN NULL;
  END Get_Ins_Ext_Agg;


  --
  -- This API is called once per payment.
  -- Implementor should construct the extract extension elements
  -- at the payment level as a SQLX XML Aggregate
  -- and return the aggregate.
  --
  FUNCTION Get_Pmt_Ext_Agg(p_payment_id IN NUMBER)
  RETURN XMLTYPE
  IS
  v_all_inv_paid varchar2(4000);
  v_result XMLTYPE;
  BEGIN
    --20210316 BC
	for r in (select calling_app_doc_ref_number||' ('||rtrim(ltrim(to_char(payment_amount,'999,999,999,990.00')))||')' inv_paid 
			  from   iby_docs_payable_all
			 where  payment_Id = p_payment_id 
			 order by calling_app_doc_ref_number)
	loop
	v_all_inv_paid := case when v_all_inv_paid is null then r.inv_paid else v_all_inv_paid || ', ' || r.inv_paid END;
	--lv_all_salesrep := case when lv_all_salesrep is null then lv_resource_name else lv_all_salesrep || '/ ' ||lv_resource_name END;
    
    -- DASH 20230208 - bug fix to handle a case more than 200 invoices
    if length(v_all_inv_paid) >= 3500 then
        exit;
    end if;  
    -- END DASH    
    
	end loop;

	select XMLConcat(XMLElement("Extend",
			XMLElement("XXALL_INVOICES_PAID",v_all_inv_paid)))
	into   v_result
	from   dual;

	RETURN V_RESULT;
    --RETURN NULL;
  END Get_Pmt_Ext_Agg;


  --
  -- This API is called once per document payable.
  -- Implementor should construct the extract extension elements
  -- at the document level as a SQLX XML Aggregate
  -- and return the aggregate.
  --
  FUNCTION Get_Doc_Ext_Agg(p_document_payable_id IN NUMBER)
  RETURN XMLTYPE
  IS
  BEGIN
    RETURN NULL;
  END Get_Doc_Ext_Agg;


  --
  -- This API is called once per document payable line.
  -- Implementor should construct the extract extension elements
  -- at the doc line level as a SQLX XML Aggregate
  -- and return the aggregate.
  --
  -- Parameters:
  --   p_document_payable_id: primary key of IBY iby_docs_payable_all table
  --   p_line_number: calling app doc line number. For AP this is
  --   ap_invoice_lines_all.line_number.
  --
  -- The combination of p_document_payable_id and p_line_number
  -- can uniquely locate a document line.
  -- For example if the calling product of a doc is AP
  -- p_document_payable_id can locate
  -- iby_docs_payable_all/ap_documents_payable.calling_app_doc_unique_ref2,
  -- which is ap_invoice_all.invoice_id. The combination of invoice_id and
  -- p_line_number will uniquely identify the doc line.
  --
  FUNCTION Get_Docline_Ext_Agg(p_document_payable_id IN NUMBER, p_line_number IN NUMBER)
  RETURN XMLTYPE
  IS
  BEGIN
    RETURN NULL;
  END Get_Docline_Ext_Agg;


  --
  -- This API is called once only for the payment process request.
  -- Implementor should construct the extract extension elements
  -- at the payment request level as a SQLX XML Aggregate
  -- and return the aggregate.
  --
  FUNCTION Get_Ppr_Ext_Agg(p_payment_service_request_id IN NUMBER)
  RETURN XMLTYPE
  IS
  BEGIN
    RETURN NULL;
  END Get_Ppr_Ext_Agg;


END IBY_FD_EXTRACT_EXT_PUB;

/