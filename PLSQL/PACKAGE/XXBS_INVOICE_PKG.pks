--------------------------------------------------------
--  DDL for Package XXBS_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXBS_INVOICE_PKG" AS

    PROCEDURE submit_to_review
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );

    PROCEDURE submit_to_mgr_review
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );

    PROCEDURE submit_to_ar
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );

    PROCEDURE submit_approval_void
    ( p_customer_trx_id      IN  NUMBER 
	 ,p_approval_reason           IN VARCHAR2 
	 ,p_justification           IN VARCHAR2 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );

    PROCEDURE approve_void
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );

    PROCEDURE reject_void
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );

    PROCEDURE submit_approval_revise
    ( p_customer_trx_id      IN  NUMBER
     ,p_revise_to_num        IN  NUMBER DEFAULT 1
	 ,p_approval_reason           IN VARCHAR2 
	 ,p_justification           IN VARCHAR2 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );

    PROCEDURE approve_revise
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );

    PROCEDURE reject_revise
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );


    PROCEDURE perform_audit
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );

    PROCEDURE perform_print
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );

    PROCEDURE copy_final_invoice
    ( p_customer_trx_id      IN  NUMBER 
	 ,p_cust_trx_type_id		IN  NUMBER  
	 ,p_new_cust_trx_id			OUT NUMBER
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE check_parent_for_combine
    ( p_parent_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE check_child_for_combine
    ( p_parent_customer_trx_id      IN  NUMBER 
	 ,p_child_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE check_trx_for_revise
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE create_combine_req
    ( p_parent_customer_trx_id      IN  NUMBER 
	 ,p_combine_req_id			OUT  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE submit_approval_combine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
	 ,p_approval_reason			IN  VARCHAR2
	 ,p_justification			IN  VARCHAR2
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE approve_combine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE reject_combine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE create_uncombine_req
    ( p_parent_customer_trx_id      IN  NUMBER 
	 ,p_combine_req_id			OUT  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE submit_approval_uncombine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
	 ,p_approval_reason			IN  VARCHAR2
	 ,p_justification			IN  VARCHAR2
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE approve_uncombine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE reject_uncombine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

	PROCEDURE reset_default_sales_rep
    ( 
	 p_customer_trx_id			IN  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ); 

    PROCEDURE check_gl_period_open 
    (p_customer_trx_id IN NUMBER
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) ;	

    PROCEDURE check_payment_term_active 
    (p_customer_trx_id IN NUMBER
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) ;	

    PROCEDURE trigger_mgr_review_wf
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    );	

    FUNCTION get_cm_trx_number 
    (p_current_trx_number IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION get_cm_trx_type 
    (p_current_trx_type_id IN NUMBER
    ) RETURN NUMBER;

    FUNCTION get_revise_trx_number 
    (p_current_trx_number IN VARCHAR2
	,p_num_new_trx_number IN NUMBER DEFAULT NULL
    ) RETURN VARCHAR2;

	FUNCTION get_gl_period
	(
	 p_trx_date IN DATE
	 ,p_set_of_books_id IN NUMBER	 
	) RETURN VARCHAR2;



end XXBS_INVOICE_PKG;

/
