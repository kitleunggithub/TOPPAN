--------------------------------------------------------
--  DDL for Package XXPO_COMM_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXPO_COMM_RPT_PKG" 
AS
   --------------------------------------------------------------------------------
   -- Owner                : MERRILL
   -- Project              : Merrill Corporation
   -- Program Type         : Package Header
   --
   -- Modification History:
   --    ========= ===========   =================================================
   --    Date      Author        Comments
   --    ========= ===========   =================================================
   --    07-AUG-15 Shrikant Kale   Initial Creation
   --
   --
   --------------------------------------------------------------------------------
   FUNCTION get_customer_acct (p_header_id NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_po_hdr_cancel_flag (p_header_id NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_requester_name (p_header_id NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_requester_name (p_header_id           NUMBER,
                                p_line_location_id    NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_requester_email (p_header_id           NUMBER,
                                 p_line_location_id    NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_ship_to_address (p_header_id NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_bill_to_address (p_header_id NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_ship_to_address (p_header_id           NUMBER,
                                 p_line_location_id    NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_taxable_flag (p_header_id NUMBER, p_line_id NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_note_to_vendor (p_header_id NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_canceled_quantity (p_header_id NUMBER, p_line_id NUMBER)
      RETURN NUMBER;

   FUNCTION get_original_quantity (p_header_id NUMBER, p_line_id NUMBER)
      RETURN NUMBER;

   FUNCTION get_comp_logo_addr (p_header_id NUMBER,
                                type_lookup_code VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_comp_logo (p_header_id NUMBER,
                           type_lookup_code VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_terms_and_conditions ( p_country VARCHAR2 )
      RETURN CLOB;

   FUNCTION get_po_notes ( p_country VARCHAR2 )
      RETURN CLOB;

END XXPO_COMM_RPT_PKG;

/
