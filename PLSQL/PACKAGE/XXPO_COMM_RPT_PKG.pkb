--------------------------------------------------------
--  DDL for Package Body XXPO_COMM_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXPO_COMM_RPT_PKG" 
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
   --    05-MAY-16 AM              Updated get_comp_logo_addr for new logo
   --    12/31/18  akaplan       Toppan cleanup and logo selection
   --------------------------------------------------------------------------------

   FUNCTION get_customer_acct (p_header_id NUMBER)
      RETURN VARCHAR2
   IS
      l_cust_account   AP_SUPPLIERS.CUSTOMER_NUM%TYPE;
   BEGIN
      BEGIN
         l_cust_account := NULL;

         SELECT NVL (a_site.customer_num, a_sup.customer_num)
           INTO l_cust_account
           FROM po_headers_all pha,
                ap_suppliers a_sup,
                ap_supplier_sites_all a_site
          WHERE     1 = 1
                AND pha.vendor_id = a_sup.vendor_id
                AND a_sup.vendor_id = a_site.vendor_id
                AND a_site.vendor_site_id = pha.vendor_site_id
                AND pha.po_header_id = p_header_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_cust_account := NULL;
      END;

      RETURN l_cust_account;
   END get_customer_acct;

   FUNCTION get_requester_name (p_header_id NUMBER)
      RETURN VARCHAR2
   IS
      l_requester_name   VARCHAR2 (50);
   BEGIN
      BEGIN
         l_requester_name := NULL;

         SELECT DISTINCT pap.last_name || ', ' || pap.first_name
           INTO l_requester_name
           FROM per_all_people_f pap, po_distributions_all pda
          WHERE 1 = 1 AND pap.person_id(+) = pda.deliver_to_person_id
                AND TRUNC (SYSDATE) BETWEEN EFFECTIVE_START_DATE
                                        AND EFFECTIVE_END_DATE
                AND pda.po_header_id = p_header_id
                AND pda.deliver_to_person_id IS NOT NULL;
      --AND ROWNUM = 1;
      EXCEPTION
         WHEN TOO_MANY_ROWS
         THEN
            l_requester_name := 'Multiple, See Below';
         WHEN OTHERS
         THEN
            l_requester_name := NULL;
      END;

      RETURN l_requester_name;
   END get_requester_name;

   FUNCTION get_requester_name (p_header_id           NUMBER,
                                p_line_location_id    NUMBER)
      RETURN VARCHAR2
   IS
      l_requester_name   VARCHAR2 (150) := NULL;
      l_email_address    per_all_people_f.email_address%TYPE := NULL;
   BEGIN
      BEGIN
         SELECT pap.last_name || ', ' || pap.first_name
           INTO l_requester_name
           FROM per_all_people_f pap, po_distributions_all pda
          WHERE 1 = 1 AND pap.person_id(+) = pda.deliver_to_person_id
                AND TRUNC (SYSDATE) BETWEEN EFFECTIVE_START_DATE
                                        AND EFFECTIVE_END_DATE
                AND pda.po_header_id = p_header_id
                AND pda.line_location_id = p_line_location_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_requester_name := NULL;
      END;

      RETURN l_requester_name;
   END get_requester_name;

   FUNCTION get_requester_email (p_header_id           NUMBER,
                                 p_line_location_id    NUMBER)
      RETURN VARCHAR2
   IS
      l_email_address   per_all_people_f.email_address%TYPE := NULL;
   BEGIN
      BEGIN
         SELECT email_address
           INTO l_email_address
           FROM per_all_people_f pap, po_distributions_all pda
          WHERE 1 = 1 AND pap.person_id(+) = pda.deliver_to_person_id
                AND TRUNC (SYSDATE) BETWEEN EFFECTIVE_START_DATE
                                        AND EFFECTIVE_END_DATE
                AND pda.po_header_id = p_header_id
                AND pda.line_location_id = p_line_location_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_email_address := NULL;
      END;

      RETURN l_email_address;
   END get_requester_email;

   FUNCTION get_ship_to_address (p_header_id NUMBER)
      RETURN VARCHAR2
   IS
      l_count             NUMBER := 0;
      l_ship_to_address   VARCHAR2 (320) := NULL;
   BEGIN
      SELECT COUNT (DISTINCT ship_to_location_id)
        INTO l_count
        FROM po_line_locations_all
       WHERE 1 = 1 AND po_header_id = p_header_id;

      IF l_count = 0
      THEN
         SELECT    ADDRESS_LINE_1
                || DECODE (ADDRESS_LINE_2, NULL, '', CHR (10))
                || DECODE (ADDRESS_LINE_2, NULL, '')
                || UPPER (ADDRESS_LINE_2)
                || DECODE (ADDRESS_LINE_3, NULL, '', CHR (10))
                || DECODE (ADDRESS_LINE_3, NULL, '')
                || UPPER (ADDRESS_LINE_3)
                || DECODE (LOC_INFORMATION14, NULL, '', CHR (10))
                || DECODE (LOC_INFORMATION14, NULL, '')
                || UPPER (LOC_INFORMATION14)
                || DECODE (LOC_INFORMATION15, NULL, '', CHR (10))
                || DECODE (LOC_INFORMATION15, NULL, '')
                || UPPER (LOC_INFORMATION15)
                || DECODE (LOC_INFORMATION16, NULL, '', CHR (10))
                || DECODE (LOC_INFORMATION16, NULL, '')
                || UPPER (LOC_INFORMATION16)
                || DECODE (TOWN_OR_CITY, NULL, '', CHR (10))
                || DECODE (TOWN_OR_CITY, NULL, '')
                || UPPER (TOWN_OR_CITY)
                || DECODE (REGION_2, NULL, '', ', ')
                || DECODE (REGION_2, NULL, '')
                || UPPER (REGION_2)
                || DECODE (postal_code, NULL, '', ' ')
                || DECODE (postal_code, NULL, '')
                || postal_code
                || DECODE (TERRITORY_SHORT_NAME, NULL, '', CHR (10))
                || DECODE (TERRITORY_SHORT_NAME, NULL, '')
                || UPPER (TERRITORY_SHORT_NAME)
                   SHIP_TO_ADDRESS
           INTO l_ship_to_address
           FROM po_headers_all pha, hr_locations hl, fnd_territories_tl fte3
          WHERE     1 = 1
                AND pha.ship_to_location_id = hl.location_id
                AND SUBSTR (hl.country, 1, 25) = fte3.territory_code(+)
                AND DECODE (fte3.territory_code, NULL, '1', fte3.LANGUAGE) =
                       DECODE (fte3.territory_code,
                               NULL, '1',
                               USERENV ('LANG'))
                AND pha.po_header_id = p_header_id;
      ELSIF l_count = 1
      THEN
         BEGIN
            SELECT DISTINCT
                      ADDRESS_LINE_1
                   || DECODE (ADDRESS_LINE_2, NULL, '', CHR (10))
                   || DECODE (ADDRESS_LINE_2, NULL, '')
                   || UPPER (ADDRESS_LINE_2)
                   || DECODE (ADDRESS_LINE_3, NULL, '', CHR (10))
                   || DECODE (ADDRESS_LINE_3, NULL, '')
                   || UPPER (ADDRESS_LINE_3)
                   || DECODE (LOC_INFORMATION14, NULL, '', CHR (10))
                   || DECODE (LOC_INFORMATION14, NULL, '')
                   || UPPER (LOC_INFORMATION14)
                   || DECODE (LOC_INFORMATION15, NULL, '', CHR (10))
                   || DECODE (LOC_INFORMATION15, NULL, '')
                   || UPPER (LOC_INFORMATION15)
                   || DECODE (LOC_INFORMATION16, NULL, '', CHR (10))
                   || DECODE (LOC_INFORMATION16, NULL, '')
                   || UPPER (LOC_INFORMATION16)
                   || DECODE (TOWN_OR_CITY, NULL, '', CHR (10))
                   || DECODE (TOWN_OR_CITY, NULL, '')
                   || UPPER (TOWN_OR_CITY)
                   || DECODE (REGION_2, NULL, '', ', ')
                   || DECODE (REGION_2, NULL, '')
                   || UPPER (REGION_2)
                   || DECODE (postal_code, NULL, '', ' ')
                   || DECODE (postal_code, NULL, '')
                   || postal_code
                   || DECODE (TERRITORY_SHORT_NAME, NULL, '', CHR (10))
                   || DECODE (TERRITORY_SHORT_NAME, NULL, '')
                   || UPPER (TERRITORY_SHORT_NAME)
                      SHIP_TO_ADDRESS
              INTO l_ship_to_address
              FROM po_line_locations_all plla,
                   hr_locations hl,
                   fnd_territories_tl fte3
             WHERE     1 = 1
                   AND plla.ship_to_location_id = hl.location_id
                   AND SUBSTR (hl.country, 1, 25) = fte3.territory_code(+)
                   AND DECODE (fte3.territory_code, NULL, '1', fte3.LANGUAGE) =
                          DECODE (fte3.territory_code,
                                  NULL, '1',
                                  USERENV ('LANG'))
                   AND plla.po_header_id = p_header_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_ship_to_address := NULL;
         END;
      ELSE
         l_ship_to_address := 'MULTIPLE, SEE BELOW ';
      END IF;


      RETURN UPPER (l_ship_to_address);
   END get_ship_to_address;

   FUNCTION get_bill_to_address (p_header_id NUMBER)
      RETURN VARCHAR2
   IS
      l_bill_to_address   VARCHAR2 (320) := NULL;
   BEGIN
      BEGIN
         SELECT    ADDRESS_LINE_1
                || DECODE (ADDRESS_LINE_2, NULL, '', CHR (10))
                || DECODE (ADDRESS_LINE_2, NULL, '')
                || UPPER (ADDRESS_LINE_2)
                || DECODE (ADDRESS_LINE_3, NULL, '', CHR (10))
                || DECODE (ADDRESS_LINE_3, NULL, '')
                || UPPER (ADDRESS_LINE_3)
                || DECODE (LOC_INFORMATION14, NULL, '', CHR (10))
                || DECODE (LOC_INFORMATION14, NULL, '')
                || UPPER (LOC_INFORMATION14)
                || DECODE (LOC_INFORMATION15, NULL, '', CHR (10))
                || DECODE (LOC_INFORMATION15, NULL, '')
                || UPPER (LOC_INFORMATION15)
                || DECODE (LOC_INFORMATION16, NULL, '', CHR (10))
                || DECODE (LOC_INFORMATION16, NULL, '')
                || UPPER (LOC_INFORMATION16)
                || DECODE (TOWN_OR_CITY, NULL, '', CHR (10))
                || DECODE (TOWN_OR_CITY, NULL, '')
                || UPPER (TOWN_OR_CITY)
                || DECODE (REGION_2, NULL, '', ', ')
                || DECODE (REGION_2, NULL, '')
                || UPPER (REGION_2)
                || DECODE (postal_code, NULL, '', ' ')
                || DECODE (postal_code, NULL, '')
                || postal_code
                || DECODE (TERRITORY_SHORT_NAME, NULL, '', CHR (10))
                || DECODE (TERRITORY_SHORT_NAME, NULL, '')
                || UPPER (TERRITORY_SHORT_NAME)
                   BILL_TO_ADDRESS
           INTO l_bill_to_address
           FROM po_headers_all pha, hr_locations hl, fnd_territories_tl fte3
          WHERE     1 = 1
                AND pha.bill_to_location_id = hl.location_id
                AND SUBSTR (hl.country, 1, 25) = fte3.territory_code(+)
                AND DECODE (fte3.territory_code, NULL, '1', fte3.LANGUAGE) =
                       DECODE (fte3.territory_code,
                               NULL, '1',
                               USERENV ('LANG'))
                AND pha.po_header_id = p_header_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_bill_to_address := NULL;
      END;

      RETURN l_bill_to_address;
   END get_bill_to_address;

   FUNCTION get_ship_to_address (p_header_id           NUMBER,
                                 p_line_location_id    NUMBER)
      RETURN VARCHAR2
   IS
      l_count              NUMBER := 0;
      l_ship_to_address    VARCHAR2 (320) := NULL;
      l_type_lookup_code   PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE := NULL;
   BEGIN
      BEGIN
         SELECT type_lookup_code
           INTO l_type_lookup_code
           FROM po_headers_all
          WHERE 1 = 1 AND po_header_id = p_header_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_type_lookup_code := NULL;
      END;

      IF l_type_lookup_code = 'BLANKET'
      THEN
         BEGIN
            SELECT    ADDRESS_LINE_1
                   || DECODE (ADDRESS_LINE_2, NULL, '', CHR (10))
                   || DECODE (ADDRESS_LINE_2, NULL, '')
                   || UPPER (ADDRESS_LINE_2)
                   || DECODE (ADDRESS_LINE_3, NULL, '', CHR (10))
                   || DECODE (ADDRESS_LINE_3, NULL, '')
                   || UPPER (ADDRESS_LINE_3)
                   || DECODE (LOC_INFORMATION14, NULL, '', CHR (10))
                   || DECODE (LOC_INFORMATION14, NULL, '')
                   || UPPER (LOC_INFORMATION14)
                   || DECODE (LOC_INFORMATION15, NULL, '', CHR (10))
                   || DECODE (LOC_INFORMATION15, NULL, '')
                   || UPPER (LOC_INFORMATION15)
                   || DECODE (LOC_INFORMATION16, NULL, '', CHR (10))
                   || DECODE (LOC_INFORMATION16, NULL, '')
                   || UPPER (LOC_INFORMATION16)
                   || DECODE (TOWN_OR_CITY, NULL, '', CHR (10))
                   || DECODE (TOWN_OR_CITY, NULL, '')
                   || UPPER (TOWN_OR_CITY)
                   || DECODE (REGION_2, NULL, '', ', ')
                   || DECODE (REGION_2, NULL, '')
                   || UPPER (REGION_2)
                   || DECODE (postal_code, NULL, '', ' ')
                   || DECODE (postal_code, NULL, '')
                   || postal_code
                   || DECODE (TERRITORY_SHORT_NAME, NULL, '', CHR (10))
                   || DECODE (TERRITORY_SHORT_NAME, NULL, '')
                   || UPPER (TERRITORY_SHORT_NAME)
                      SHIP_TO_ADDRESS
              INTO l_ship_to_address
              FROM po_line_locations_all plla,
                   hr_locations hl,
                   fnd_territories_tl fte3
             WHERE     1 = 1
                   AND plla.ship_to_location_id = hl.location_id
                   AND SUBSTR (hl.country, 1, 25) = fte3.territory_code(+)
                   AND DECODE (fte3.territory_code, NULL, '1', fte3.LANGUAGE) =
                          DECODE (fte3.territory_code,
                                  NULL, '1',
                                  USERENV ('LANG'))
                   AND plla.po_header_id = p_header_id
                   AND plla.line_location_id = p_line_location_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_ship_to_address := NULL;
         END;
      ELSE
         SELECT COUNT (DISTINCT ship_to_location_id)
           INTO l_count
           FROM po_line_locations_all
          WHERE 1 = 1 AND po_header_id = p_header_id;

         IF l_count = 0
         THEN
            l_ship_to_address :=
               'Use the ship-to address at the top of page 1';
         ELSIF l_count = 1
         THEN
            l_ship_to_address :=
               'Use the ship-to address at the top of page 1';
         ELSE
            BEGIN
               SELECT    ADDRESS_LINE_1
                      || DECODE (ADDRESS_LINE_2, NULL, '', CHR (10))
                      || DECODE (ADDRESS_LINE_2, NULL, '')
                      || UPPER (ADDRESS_LINE_2)
                      || DECODE (ADDRESS_LINE_3, NULL, '', CHR (10))
                      || DECODE (ADDRESS_LINE_3, NULL, '')
                      || UPPER (ADDRESS_LINE_3)
                      || DECODE (LOC_INFORMATION14, NULL, '', CHR (10))
                      || DECODE (LOC_INFORMATION14, NULL, '')
                      || UPPER (LOC_INFORMATION14)
                      || DECODE (LOC_INFORMATION15, NULL, '', CHR (10))
                      || DECODE (LOC_INFORMATION15, NULL, '')
                      || UPPER (LOC_INFORMATION15)
                      || DECODE (LOC_INFORMATION16, NULL, '', CHR (10))
                      || DECODE (LOC_INFORMATION16, NULL, '')
                      || UPPER (LOC_INFORMATION16)
                      || DECODE (TOWN_OR_CITY, NULL, '', CHR (10))
                      || DECODE (TOWN_OR_CITY, NULL, '')
                      || UPPER (TOWN_OR_CITY)
                      || DECODE (REGION_2, NULL, '', ', ')
                      || DECODE (REGION_2, NULL, '')
                      || UPPER (REGION_2)
                      || DECODE (postal_code, NULL, '', ' ')
                      || DECODE (postal_code, NULL, '')
                      || postal_code
                      || DECODE (TERRITORY_SHORT_NAME, NULL, '', CHR (10))
                      || DECODE (TERRITORY_SHORT_NAME, NULL, '')
                      || UPPER (TERRITORY_SHORT_NAME)
                         SHIP_TO_ADDRESS
                 INTO l_ship_to_address
                 FROM po_line_locations_all plla,
                      hr_locations hl,
                      fnd_territories_tl fte3
                WHERE     1 = 1
                      AND plla.ship_to_location_id = hl.location_id
                      AND SUBSTR (hl.country, 1, 25) = fte3.territory_code(+)
                      AND DECODE (fte3.territory_code,
                                  NULL, '1',
                                  fte3.LANGUAGE) =
                             DECODE (fte3.territory_code,
                                     NULL, '1',
                                     USERENV ('LANG'))
                      AND plla.po_header_id = p_header_id
                      AND plla.line_location_id = p_line_location_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_ship_to_address := NULL;
            END;
         END IF;
      END IF;

      RETURN l_ship_to_address;
   END get_ship_to_address;

   FUNCTION get_taxable_flag (p_header_id NUMBER, p_line_id NUMBER)
      RETURN VARCHAR2
   IS
      l_taxable_flag   VARCHAR2 (1) := NULL;
   BEGIN
      BEGIN
         SELECT DISTINCT attribute14
           INTO l_taxable_flag
           FROM po_line_locations_all plla
          WHERE     1 = 1
                AND plla.po_header_id = p_header_id
                AND plla.po_line_id = p_line_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_taxable_flag := 'N';
      END;

      RETURN NVL (l_taxable_flag, 'N');
   END get_taxable_flag;

   FUNCTION get_note_to_vendor (p_header_id NUMBER)
      RETURN VARCHAR2
   IS
      l_note_to_vendor   po_headers_all.note_to_vendor%TYPE := NULL;
   BEGIN
      BEGIN
         SELECT NOTE_TO_VENDOR
           INTO l_note_to_vendor
           FROM po_headers_all pha
          WHERE 1 = 1 AND po_header_id = p_header_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_note_to_vendor := NULL;
      END;

      RETURN l_note_to_vendor;
   END get_note_to_vendor;

   FUNCTION get_canceled_quantity (p_header_id NUMBER, p_line_id NUMBER)
      RETURN NUMBER
   IS
      l_quantity_cancelled   PO_LINE_LOCATIONS_ALL.QUANTITY_CANCELLED%TYPE;
   BEGIN
      BEGIN
         SELECT SUM (NVL (quantity_cancelled, 0))
           INTO l_quantity_cancelled
           FROM po_line_locations_all
          WHERE     1 = 1
                AND po_header_id = p_header_id
                AND po_line_id = p_line_id
                AND cancel_flag = 'Y';
      EXCEPTION
         WHEN OTHERS
         THEN
            l_quantity_cancelled := 0;
      END;

      RETURN l_quantity_cancelled;
   END get_canceled_quantity;

   FUNCTION get_original_quantity (p_header_id NUMBER, p_line_id NUMBER)
      RETURN NUMBER
   IS
      l_quantity   PO_LINE_LOCATIONS_ALL.QUANTITY%TYPE;
   BEGIN
      BEGIN
         SELECT SUM (NVL (quantity, 0))
           INTO l_quantity
           FROM po_line_locations_all
          WHERE     1 = 1
                AND po_header_id = p_header_id
                AND po_line_id = p_line_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_quantity := 0;
      END;

      RETURN l_quantity;
   END get_original_quantity;

   FUNCTION get_po_hdr_cancel_flag (p_header_id NUMBER)
      RETURN VARCHAR2
   IS
      l_cancel_flag   po_headers_all.cancel_flag%TYPE := NULL;
   BEGIN
      BEGIN
         SELECT cancel_flag
           INTO l_cancel_flag
           FROM po_headers_all
          WHERE 1 = 1 AND po_header_id = p_header_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_cancel_flag := NULL;
      END;

      RETURN l_cancel_flag;
   END get_po_hdr_cancel_flag;

   FUNCTION get_comp_logo (p_header_id         NUMBER,
                           type_lookup_code    VARCHAR2)
      RETURN VARCHAR2 IS

      l_logo   VARCHAR2 (2000) := NULL;

   BEGIN
      BEGIN
         IF type_lookup_code = 'STANDARD'
         THEN
            --Logo Logic for Standard PO if LE Exist in VS - XXPO_PO_PRINT_LOGOS
            BEGIN
               SELECT XXCM_COMMON.get_flex_value_field (
                         'XXPO_PO_PRINT_LOGOS', gcc.segment1, 'LOGO')
                  INTO l_logo
                 FROM po_distributions_all pda, gl_code_combinations gcc
                WHERE 1 = 1
                      AND (po_line_id, line_location_id, po_distribution_id) =
                             (SELECT MIN (plla.po_line_id),
                                     MIN (plla.line_location_id),
                                     MIN (pda.po_distribution_id)
                                FROM po_headers_all pha,
                                     po_lines_all pla,
                                     po_line_locations_all plla,
                                     po_distributions_all pda
                               WHERE     1 = 1
                                     AND pha.po_header_id = pla.po_header_id
                                     AND pla.po_header_id = plla.po_header_id
                                     AND pla.po_line_id = plla.po_line_id
                                     AND pda.line_location_id =
                                            plla.line_location_id
                                     AND pda.code_combination_id IS NOT NULL
                                     AND pha.po_header_id = p_header_id)
                      AND pda.code_combination_id = gcc.code_combination_id
                      AND pda.po_header_id = p_header_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_logo := NULL;
            END;

            --Default Logo Logic for Standard PO
            IF l_logo IS NULL
            THEN
               SELECT XXCM_COMMON.get_flex_value_field (
                            'XXPO_PO_PRINT_LOGOS',
                            fte3.territory_short_name, 'LOGO')
                 INTO l_logo
                 FROM po_headers_all pha,
                      hr_locations hl,
                      fnd_territories_tl fte3
                WHERE     1 = 1
                      AND pha.ship_to_location_id = hl.location_id
                      AND SUBSTR (hl.country, 1, 25) = fte3.territory_code(+)
                      AND DECODE (fte3.territory_code,
                                  NULL, '1',
                                  fte3.LANGUAGE) =
                             DECODE (fte3.territory_code,
                                     NULL, '1',
                                     USERENV ('LANG'))
                      AND pha.po_header_id = p_header_id;
            END IF;
         ELSE
            --Logo Logic for BPA and CPA
            SELECT XXCM_COMMON.get_flex_value_field (
                            'XXPO_PO_PRINT_LOGOS',
                            fte3.territory_short_name, 'LOGO')
               INTO l_logo
              FROM po_headers_all pha,
                   hr_locations hl,
                   fnd_territories_tl fte3
             WHERE     1 = 1
                   AND pha.ship_to_location_id = hl.location_id
                   AND SUBSTR (hl.country, 1, 25) = fte3.territory_code(+)
                   AND DECODE (fte3.territory_code, NULL, '1', fte3.LANGUAGE) =
                          DECODE (fte3.territory_code,
                                  NULL, '1',
                                  USERENV ('LANG'))
                   AND pha.po_header_id = p_header_id;
         END IF;

         IF l_logo IS NULL THEN
           l_logo :=  XXCM_COMMON.get_flex_value_field (
                                            'XXPO_PO_PRINT_LOGOS',
                                            'ALL','LOGO');
         END IF;

      EXCEPTION
         WHEN OTHERS
         THEN
           -- If anything fails, use the standard logo
           l_logo :=  XXCM_COMMON.get_flex_value_field (
                                            'XXPO_PO_PRINT_LOGOS',
                                            'ALL','LOGO');
      END;

      RETURN l_logo;
   END get_comp_logo;

   FUNCTION get_comp_logo_addr (p_header_id         NUMBER,
                                type_lookup_code    VARCHAR2)
      RETURN VARCHAR2
   IS
      l_logo_addr   VARCHAR2 (2000) := NULL;
   BEGIN
      BEGIN
         IF type_lookup_code = 'STANDARD'
         THEN
            --Logo Logic for Standard PO if LE Exist in VS - XXPO_PO_PRINT_LOGOS
            BEGIN
               SELECT XXCM_COMMON.get_flex_value_field (
                         'XXPO_PO_PRINT_LOGOS', gcc.segment1, 'ADDRESS_LINE1')
                      || CHR (10)
                      || XXCM_COMMON.get_flex_value_field (
                         'XXPO_PO_PRINT_LOGOS', gcc.segment1, 'ADDRESS_LINE2')
                      || CHR (10)
                      || XXCM_COMMON.get_flex_value_field (
                         'XXPO_PO_PRINT_LOGOS', gcc.segment1, 'ADDRESS_LINE3')
                      || CHR (10)
                      || XXCM_COMMON.get_flex_value_field (
                         'XXPO_PO_PRINT_LOGOS', gcc.segment1, 'ADDRESS_LINE4')
                  INTO l_logo_addr
                 FROM po_distributions_all pda, gl_code_combinations gcc
                WHERE 1 = 1
                      AND (po_line_id, line_location_id, po_distribution_id) =
                             (SELECT MIN (plla.po_line_id),
                                     MIN (plla.line_location_id),
                                     MIN (pda.po_distribution_id)
                                FROM po_headers_all pha,
                                     po_lines_all pla,
                                     po_line_locations_all plla,
                                     po_distributions_all pda
                               WHERE     1 = 1
                                     AND pha.po_header_id = pla.po_header_id
                                     AND pla.po_header_id = plla.po_header_id
                                     AND pla.po_line_id = plla.po_line_id
                                     AND pda.line_location_id =
                                            plla.line_location_id
                                     AND pda.code_combination_id IS NOT NULL
                                     AND pha.po_header_id = p_header_id)
                      AND pda.code_combination_id = gcc.code_combination_id
                      AND pda.po_header_id = p_header_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_logo_addr := NULL;
            END;

            --Default Logo Logic for Standard PO
            IF l_logo_addr IS NULL
            THEN
               SELECT XXCM_COMMON.get_flex_value_field (
                            'XXPO_PO_PRINT_LOGOS',
                            fte3.territory_short_name, 'ADDRESS_LINE1')
                      || CHR (10)
                      || XXCM_COMMON.get_flex_value_field (
                            'XXPO_PO_PRINT_LOGOS',
                            fte3.territory_short_name, 'ADDRESS_LINE2')
                      || CHR (10)
                      || XXCM_COMMON.get_flex_value_field (
                            'XXPO_PO_PRINT_LOGOS',
                            fte3.territory_short_name, 'ADDRESS_LINE3')
                      || CHR (10)
                      || XXCM_COMMON.get_flex_value_field (
                            'XXPO_PO_PRINT_LOGOS',
                            fte3.territory_short_name, 'ADDRESS_LINE4')
                 INTO l_logo_addr
                 FROM po_headers_all pha,
                      hr_locations hl,
                      fnd_territories_tl fte3
                WHERE     1 = 1
                      AND pha.ship_to_location_id = hl.location_id
                      AND SUBSTR (hl.country, 1, 25) = fte3.territory_code(+)
                      AND DECODE (fte3.territory_code,
                                  NULL, '1',
                                  fte3.LANGUAGE) =
                             DECODE (fte3.territory_code,
                                     NULL, '1',
                                     USERENV ('LANG'))
                      AND pha.po_header_id = p_header_id;
            END IF;
         ELSE
            --Logo Logic for BPA and CPA
            SELECT XXCM_COMMON.get_flex_value_field (
                            'XXPO_PO_PRINT_LOGOS',
                            fte3.territory_short_name, 'ADDRESS_LINE1')
                   || CHR (10)
                   || XXCM_COMMON.get_flex_value_field (
                            'XXPO_PO_PRINT_LOGOS',
                            fte3.territory_short_name, 'ADDRESS_LINE2')
                   || CHR (10)
                   || XXCM_COMMON.get_flex_value_field (
                            'XXPO_PO_PRINT_LOGOS',
                            fte3.territory_short_name, 'ADDRESS_LINE3')
                   || CHR (10)
                   ||XXCM_COMMON.get_flex_value_field (
                            'XXPO_PO_PRINT_LOGOS',
                            fte3.territory_short_name, 'ADDRESS_LINE4')
               INTO l_logo_addr
              FROM po_headers_all pha,
                   hr_locations hl,
                   fnd_territories_tl fte3
             WHERE     1 = 1
                   AND pha.ship_to_location_id = hl.location_id
                   AND SUBSTR (hl.country, 1, 25) = fte3.territory_code(+)
                   AND DECODE (fte3.territory_code, NULL, '1', fte3.LANGUAGE) =
                          DECODE (fte3.territory_code,
                                  NULL, '1',
                                  USERENV ('LANG'))
                   AND pha.po_header_id = p_header_id;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_logo_addr := 'NULL';
      END;

      RETURN l_logo_addr;
   END get_comp_logo_addr;

   FUNCTION get_terms_and_conditions ( p_country VARCHAR2 )
      RETURN CLOB IS

      v_tc CLOB;

      CURSOR tc_cur (p_country VARCHAR2) IS
          select long_text
          from fnd_documents_vl d
            join fnd_documents_long_text lt on ( lt.media_id = d.media_id )
          where 1=1
            and category_description = 'PO Notes'
            and upper(description) = upper(p_country||' T AND C');

   BEGIN
      OPEN tc_cur ( p_country );
      FETCH tc_cur INTO v_tc;
      CLOSE tc_cur;

      IF v_tc IS NULL THEN
         OPEN tc_cur ( 'STANDARD' );
         FETCH tc_cur INTO v_tc;
         CLOSE tc_cur;
      END IF;

      RETURN v_tc;
   END get_terms_and_conditions;

   FUNCTION get_po_notes ( p_country VARCHAR2 )
      RETURN CLOB IS

      v_notes CLOB;

      CURSOR note_cur (p_country VARCHAR2) IS
          select long_text
          from fnd_documents_vl d
            join fnd_documents_long_text lt on ( lt.media_id = d.media_id )
          where 1=1
            and category_description = 'PO Notes'
            and upper(description) = upper(p_country||' NOTES');

   BEGIN
      OPEN note_cur ( p_country);
      FETCH note_cur INTO v_notes;
      CLOSE note_cur;

      IF v_notes IS NULL THEN
         OPEN note_cur ( 'STANDARD' );
         FETCH note_cur INTO v_notes;
         CLOSE note_cur;
      END IF;

      RETURN v_notes;
   END get_po_notes;
END XXPO_COMM_RPT_PKG;

/
