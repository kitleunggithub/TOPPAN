--------------------------------------------------------
--  DDL for Package XXBS_INVOICE_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXBS_INVOICE_AR_PKG" AS

    PROCEDURE send_cb_to_ar
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );

    FUNCTION check_exists_in_ar 
    (p_customer_trx_id IN NUMBER
    ) RETURN BOOLEAN;

    FUNCTION check_gl_period_open 
    (p_customer_trx_id IN NUMBER
    ) RETURN BOOLEAN;

	FUNCTION get_customer_trx_line_ref
	(p_customer_trx_id IN NUMBER
	, p_customer_trx_line_id IN NUMBER
	)RETURN NUMBER;

end XXBS_INVOICE_AR_PKG;


/
