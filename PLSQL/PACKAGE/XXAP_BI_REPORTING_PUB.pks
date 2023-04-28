--------------------------------------------------------
--  DDL for Package XXAP_BI_REPORTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAP_BI_REPORTING_PUB" 
IS
/********************************************************************************
**       		MERRILL CORPORATION - R12 12.2.4
**
**			MERRILL TECHNOLOGIES INDIA PRIVATE LIMITED
************************************************************************************
**
**    File - xxap_bi_reporting_pub.pks
**
************************************************************************************
**
**  DESCRIPTION
**
**    Package Specification - This Package is used to list the Outstanding Transacton for US_USB_Corporate_Card.
**
**
**  MODIFIED BY
**
**    Senthil Nathan  02-APR-2019      Initial draft Version
**
**********************************************************************************
**
**********************************************************************************
**  REVISION HISTORY:
**
**  Version      Author                  Date          Description
**  ---------    ---------------------   -----------   --------------------------------
**	  1.0        xxxx					 DD-MON-YYYY   Initial Development
**    1.1        SenthilNathan       	 02-APR-2019   CR Enhancement - CR#2350
*****************************************************************************************/

  p_emailaddr    VARCHAR2(100);
  p_date         DATE;
  p_location     VARCHAR2(100);
  p1 VARCHAR2(100);
  p2 VARCHAR2(100);
  p3 VARCHAR2(100);
  p4 VARCHAR2(100);
  p5 VARCHAR2(100);
  p_template     VARCHAR2(100);

FUNCTION  get_sup_id  (p_person_id IN NUMBER) RETURN NUMBER;

PROCEDURE write_xml_output(p_xml_clob   IN CLOB);

PROCEDURE xxap_boa_cc_outstanding (p_retcode  			OUT NUMBER
                                  ,p_errbuf       		OUT VARCHAR2
                                  ,p_card         		IN  NUMBER
                                  ,p_posted_from_date	IN  VARCHAR2
                                  ,p_posted_to_date     IN  VARCHAR2
                                  ,p_employee     		IN  NUMBER
                                  ,p_manager      		IN  NUMBER
                                  );

PROCEDURE xxap_us_cc_outstanding (p_retcode  			OUT NUMBER
                                 ,p_errbuf       		OUT VARCHAR2
                                 ,p_card         		IN  NUMBER
                                 ,p_posted_from_date	IN  VARCHAR2
                                 ,p_posted_to_date      IN  VARCHAR2
                                 ,p_employee     		IN  NUMBER
                                 ,p_manager      		IN  NUMBER
                                 );

PROCEDURE xxap_dist_var_rep ( p_retcode      OUT NUMBER
                             ,p_errbuf       OUT VARCHAR2
                            );

PROCEDURE pl( p_str        IN VARCHAR2
             ,p_show_time IN VARCHAR2 DEFAULT 'Y');

END;

/
