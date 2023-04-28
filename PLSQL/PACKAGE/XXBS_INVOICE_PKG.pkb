--------------------------------------------------------
--  DDL for Package Body XXBS_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXBS_INVOICE_PKG" AS


    PROCEDURE submit_to_review
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) IS
	
	BEGIN
		UPDATE XXBS_CUSTOMER_TRX
		SET 
		CURRENT_STATUS = 'Out For Review'
		,CURRENT_STATUS_DATE = SYSDATE
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		p_return_status:= 'S';
		p_msg:= NULL;

	END submit_to_review;


    PROCEDURE submit_to_mgr_review
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) IS
	v_revised_customer_trx_id NUMBER;
	BEGIN
		SELECT REVISED_CUSTOMER_TRX_ID INTO v_revised_customer_trx_id 
		FROM XXBS_CUSTOMER_TRX 
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		IF (v_revised_customer_trx_id IS NOT NULL) THEN
			UPDATE XXBS_CUSTOMER_TRX
			SET 
			CURRENT_STATUS = 'Pending Manager Review'
			,CURRENT_STATUS_DATE = SYSDATE
			,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
			,LAST_UPDATE_DATE = SYSDATE
			,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		END IF;

		p_return_status:= 'S';
		p_msg:= NULL;

	END submit_to_mgr_review;

    PROCEDURE submit_to_ar
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) IS
	v_revised_customer_trx_id NUMBER;
	v_rebill_trx_not_invoiced_count NUMBER;
	BEGIN
		SELECT REVISED_CUSTOMER_TRX_ID INTO v_revised_customer_trx_id 
		FROM XXBS_CUSTOMER_TRX 
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		IF (v_revised_customer_trx_id IS NULL) THEN
			UPDATE XXBS_CUSTOMER_TRX
			SET 
			CURRENT_STATUS = 'Invoiced'
			,CURRENT_STATUS_DATE = SYSDATE
			,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
			,LAST_UPDATE_DATE = SYSDATE
			,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		ELSE			
			UPDATE XXBS_CUSTOMER_TRX
			SET 
			CURRENT_STATUS = 'Pending Invoiced'
			,CURRENT_STATUS_DATE = SYSDATE
			,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
			,LAST_UPDATE_DATE = SYSDATE
			,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

			SELECT COUNT(1) INTO v_rebill_trx_not_invoiced_count 
			FROM XXBS_CUSTOMER_TRX 
			WHERE 
			REVISED_CUSTOMER_TRX_ID = v_revised_customer_trx_id 
			AND CUST_TRX_TYPE_ID IN (SELECT CUST_TRX_TYPE_ID FROM RA_CUST_TRX_TYPES_ALL WHERE TYPE='INV')
			AND CURRENT_STATUS <> 'Pending Invoiced';

			IF (v_rebill_trx_not_invoiced_count = 0) THEN
				UPDATE XXBS_CUSTOMER_TRX
				SET 
				CURRENT_STATUS = 'Invoiced'
				,CURRENT_STATUS_DATE = SYSDATE
				,PERIOD_NAME = (SELECT PERIOD_NAME FROM XXBS_CUSTOMER_TRX WHERE CUSTOMER_TRX_ID = p_customer_trx_id)
				,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
				,LAST_UPDATE_DATE = SYSDATE
				,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
				WHERE 
				REVISED_CUSTOMER_TRX_ID = v_revised_customer_trx_id
				AND CUST_TRX_TYPE_ID IN (SELECT CUST_TRX_TYPE_ID FROM RA_CUST_TRX_TYPES_ALL WHERE TYPE IN('INV','CM') )
				AND CURRENT_STATUS IN ( 'Pending CM', 'Pending Invoiced');
			END IF;

		END IF;

		p_return_status:= 'S';
		p_msg:= NULL;

	END submit_to_ar;


    PROCEDURE submit_approval_void
    ( p_customer_trx_id      IN  NUMBER 
	 ,p_approval_reason           IN VARCHAR2 
	 ,p_justification           IN VARCHAR2 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
	BEGIN
		UPDATE XXBS_CUSTOMER_TRX
		SET 
		PREVIOUS_STATUS = CURRENT_STATUS
		,CURRENT_STATUS = 'Pending Approval Void'
		,CURRENT_STATUS_DATE = SYSDATE
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, p_customer_trx_id
		, SYSDATE
		, 'Requested for approval'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Void'
		, p_approval_reason
		, p_justification
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);

		p_return_status:= 'S';
		p_msg:= NULL;
	END;


    PROCEDURE approve_void
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
	BEGIN

		UPDATE XXBS_CUSTOMER_TRX
		SET 
		CURRENT_STATUS = 'Void'
		,CURRENT_STATUS_DATE = SYSDATE
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, p_customer_trx_id
		, SYSDATE
		, 'Request approved'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Void'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);

		p_return_status:= 'S';
		p_msg:= NULL;

	END;

    PROCEDURE reject_void
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
	BEGIN

		UPDATE XXBS_CUSTOMER_TRX
		SET 
		CURRENT_STATUS = NVL(PREVIOUS_STATUS,'Created')
		--CURRENT_STATUS = 'Created'
		,CURRENT_STATUS_DATE = SYSDATE
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, p_customer_trx_id
		, SYSDATE
		, 'Request rejected'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Void'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);

		p_return_status:= 'S';
		p_msg:= NULL;

	END;


    PROCEDURE submit_approval_revise
    ( p_customer_trx_id      IN  NUMBER 
	 ,p_revise_to_num			IN  NUMBER 
	 ,p_approval_reason           IN VARCHAR2 
	 ,p_justification           IN VARCHAR2 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
	BEGIN
		UPDATE XXBS_CUSTOMER_TRX
		SET 
		REVISE_TO_NUM = p_revise_to_num
		,PREVIOUS_STATUS = CURRENT_STATUS
		,CURRENT_STATUS = 'Pending Approval CM '||chr(38)||' RI'
		,CURRENT_STATUS_DATE = SYSDATE
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, p_customer_trx_id
		, SYSDATE
		, 'Requested for approval'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Revise to '||p_revise_to_num||' Invoice(s)'
		, p_approval_reason
		, p_justification
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);

		p_return_status:= 'S';
		p_msg:= NULL;
	END;


    PROCEDURE approve_revise
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
    v_cm_cust_trx_id NUMBER;
    v_revise_cust_trx_id NUMBER;
	v_revise_num NUMBER; 
	v_loop_count NUMBER;  
    v_gl_period XXBS_CUSTOMER_TRX.PERIOD_NAME%TYPE;
    v_gl_ledger_id XXBS_CUSTOMER_TRX.SET_OF_BOOKS_ID%TYPE;
    e_gl_period exception;
	BEGIN
        SELECT SET_OF_BOOKS_ID 
        INTO v_gl_ledger_id
        FROM XXBS_CUSTOMER_TRX 
        WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

        BEGIN
            v_gl_period := get_gl_period(SYSDATE,v_gl_ledger_id); --PERIOD_NAME
        EXCEPTION WHEN OTHERS THEN
            --if gl period not open
            raise e_gl_period;
        END;
		SELECT REVISE_TO_NUM into v_revise_num FROM XXBS_CUSTOMER_TRX 
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id; 

		UPDATE XXBS_CUSTOMER_TRX
		SET 
		CURRENT_STATUS = 'Invoiced'
		,CURRENT_STATUS_DATE = SYSDATE
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, p_customer_trx_id
		, SYSDATE
		, 'Request approved'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Revise to '||v_revise_num|| ' Invoice(s)'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);


		--Create Credit Memo
        v_cm_cust_trx_id:= XXBS_CUSTOMER_TRX_S.nextval;

		INSERT INTO XXBS_CUSTOMER_TRX
		(
			CUSTOMER_TRX_ID         
			,PARENT_CUSTOMER_TRX_ID  
			,AR_TRX_NUMBER           
			,SET_OF_BOOKS_ID         
			,PRIMARY_PRODUCT_TYPE_ID 
			,PROFILE_ID              
			,CUST_TRX_TYPE_ID        
			,TRX_DATE                
			,DATE_RECEIVED           
			,PERIOD_NAME             
			,PRIMARY_SALESREP_ID     
			,DESCRIPTION             
			,COMMENTS                
			,BILL_TO_ADDRESS_ID      
			,BILL_TO_CUSTOMER_ID     
			,ATTENDEE                
			,ATTENDEE_EMAIL          
			,INVOICE_ADDRESS_ID      
			,ORDER_NUMBER            
			,CUSTOMER_ORDER_NUMBER   
			,OWNING_BILLER_ID        
			,ACTIVE_BILLER_ID        
			,CURRENT_STATUS_DATE     
			,TERM_ID                 
			,CURRENCY_CODE           
			,ENTERED_CURRENCY_CODE   
			,EXCHANGE_DATE           
			,EXCHANGE_RATE           
			,EXCHANGE_RATE_TYPE      
			,CREATED_BY              
			,CREATION_DATE           
			,LAST_UPDATED_BY         
			,LAST_UPDATE_DATE        
			,LAST_UPDATE_LOGIN       
			,PROJECT_CATEGORY_ID     
			,PRIMARY_PROJECT_ORG_ID  
			,ORIGINAL_PROJECT_ID     
			,SOURCE_SYSTEM           
			,PROJECT_COMPLETE_DATE   
			,COST_SUM_SEND_DATE      
			,MARGIN_REPORT_SEND_DATE 
			,BILL_REMARK             
			,INVOICE_CLASS           
			,CURRENT_STATUS          
			,INVOICE_STYLE_NAME      
			,INVOICE_TITLE           
			,INVOICE_DESC_ONE_LINE   
			,TAX_DESC                
			,TAX_AMOUNT              
			,INVOICE_FOOT_TOP        
			,INVOICE_FOOT_BOTTOM     
			,DISPLAY_SALESPERSON     
			,DISPLAY_LEVEL_1         
			,DISPLAY_LEVEL_1_TOTAL   
			,DISPLAY_LEVEL_2         
			,DISPLAY_LEVEL_2_TOTAL   
			,DISPLAY_LEVEL_3         
			,DISPLAY_LEVEL_3_TOTAL    
			,PRELIMINARY             
			,BILL_TO_CONTACT_ID      
			,SEC_BILL_TO_CUSTOMER_ID 
			,ORG_ID                  
			,PRINT_REQUEST_ID     
			,REVISED_CUSTOMER_TRX_ID			
		)
		SELECT 
			v_cm_cust_trx_id         
			,PARENT_CUSTOMER_TRX_ID
			,get_cm_trx_number(AR_TRX_NUMBER) --AR_TRX_NUMBER
			,SET_OF_BOOKS_ID         
			,PRIMARY_PRODUCT_TYPE_ID  --PRIMARY_PRODUCT_TYPE_ID
			,PROFILE_ID              
			,get_cm_trx_type(CUST_TRX_TYPE_ID)  --CUST_TRX_TYPE_ID      
			,SYSDATE --TRX_DATE                
			,DATE_RECEIVED           
			--,get_gl_period(SYSDATE, SET_OF_BOOKS_ID) --PERIOD_NAME
			,v_gl_period             
			,PRIMARY_SALESREP_ID     
			,DESCRIPTION             
			,COMMENTS                
			,BILL_TO_ADDRESS_ID      
			,BILL_TO_CUSTOMER_ID     
			,ATTENDEE                
			,ATTENDEE_EMAIL          
			,INVOICE_ADDRESS_ID      
			,ORDER_NUMBER            
			,CUSTOMER_ORDER_NUMBER   
			,OWNING_BILLER_ID        
			,ACTIVE_BILLER_ID        
			,SYSDATE --CURRENT_STATUS_DATE     
			,TERM_ID                 
			,CURRENCY_CODE           
			,ENTERED_CURRENCY_CODE   
			,EXCHANGE_DATE           
			,EXCHANGE_RATE           
			,EXCHANGE_RATE_TYPE      
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
			,PROJECT_CATEGORY_ID     
			,PRIMARY_PROJECT_ORG_ID  
			,ORIGINAL_PROJECT_ID     
			,SOURCE_SYSTEM           
			,PROJECT_COMPLETE_DATE   
			,COST_SUM_SEND_DATE      
			,MARGIN_REPORT_SEND_DATE 
			,BILL_REMARK             
			,INVOICE_CLASS           
			,'Pending CM' --CURRENT_STATUS 'Pending CM'         
			,INVOICE_STYLE_NAME      
			,INVOICE_TITLE           
			,INVOICE_DESC_ONE_LINE   
			,TAX_DESC                
			,TAX_AMOUNT              
			,INVOICE_FOOT_TOP        
			,INVOICE_FOOT_BOTTOM     
			,DISPLAY_SALESPERSON     
			,DISPLAY_LEVEL_1         
			,DISPLAY_LEVEL_1_TOTAL   
			,DISPLAY_LEVEL_2         
			,DISPLAY_LEVEL_2_TOTAL   
			,DISPLAY_LEVEL_3         
			,DISPLAY_LEVEL_3_TOTAL    
			,PRELIMINARY             
			,BILL_TO_CONTACT_ID      
			,SEC_BILL_TO_CUSTOMER_ID 
			,ORG_ID                  
			,NULL --PRINT_REQUEST_ID    		
			,CUSTOMER_TRX_ID
		FROM XXBS_CUSTOMER_TRX
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;


		INSERT INTO XXBS_CUSTOMER_TRX_LINES
		(
		CUSTOMER_TRX_LINE_ID 
		,CUSTOMER_TRX_ID      
		,ORIG_CUSTOMER_TRX_ID 
		,ORIG_TRX_LINE_ID     
		,PROJECT_ID           
		,LINE_NUMBER          
		,ORG_ID               
		,PROJECT_ORG_ID       
		,QUANTITY_SELL        
		,UNIT_SELL            
		,SELL_AMOUNT          
		,PRODUCT_TYPE_ID      
		,LONG_DESCRIPTION     
		,CREATED_BY           
		,CREATION_DATE        
		,LAST_UPDATED_BY      
		,LAST_UPDATE_DATE     
		,LAST_UPDATE_LOGIN    
		,AR_TRX_LINE_NUMBER   
		,LINE_TYPE            
		,STATUS               
		,LEVEL_1              
		,LEVEL_2              
		,LEVEL_3
        ,REVISED_CUSTOMER_TRX_ID
        ,REVISED_CUSTOMER_TRX_LINE_ID		
		) 
		SELECT 
		 XXBS_CUSTOMER_TRX_LINE_S.nextval 
		,v_cm_cust_trx_id    
		,ORIG_CUSTOMER_TRX_ID 
		,ORIG_TRX_LINE_ID     
		,PROJECT_ID           
		,LINE_NUMBER          
		,ORG_ID               
		,PROJECT_ORG_ID       
		,QUANTITY_SELL        
		,0 - UNIT_SELL            
		,0 - SELL_AMOUNT          
		,PRODUCT_TYPE_ID      
		,LONG_DESCRIPTION     
		,FND_GLOBAL.USER_ID  --CREATED_BY           
		,SYSDATE --CREATION_DATE        
		,FND_GLOBAL.USER_ID  --LAST_UPDATED_BY      
		,SYSDATE --LAST_UPDATE_DATE     
		,FND_GLOBAL.LOGIN_ID --LAST_UPDATE_LOGIN    
		,AR_TRX_LINE_NUMBER   
		,LINE_TYPE            
		,STATUS               
		,LEVEL_1              
		,LEVEL_2              
		,LEVEL_3         	
        ,CUSTOMER_TRX_ID
		,CUSTOMER_TRX_LINE_ID		
		FROM XXBS_CUSTOMER_TRX_LINES
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;


		INSERT INTO XXBS_REP_SPLITS
		(
		REP_SPLIT_ID            
		,CUSTOMER_TRX_ID         
		,SALESREP_ID             
		,PRIMARY_FLAG            
		,SPLIT_PERCENTAGE        
		,CREATED_BY              
		,CREATION_DATE           
		,LAST_UPDATED_BY         
		,LAST_UPDATE_DATE        
		,LAST_UPDATE_LOGIN       
		,ADJUSTMENT              
		,SALESPERSON_TYPE        
		,SEQUENCE_NUMBER 
		)
		SELECT
		XXBS_REP_SPLITS_S.nextval            
		,v_cm_cust_trx_id         
		,SALESREP_ID             
		,PRIMARY_FLAG            
		,SPLIT_PERCENTAGE        
		,FND_GLOBAL.USER_ID --CREATED_BY              
		,SYSDATE --CREATION_DATE           
		,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
		,SYSDATE --LAST_UPDATE_DATE        
		,FND_GLOBAL.LOGIN_ID --LAST_UPDATE_LOGIN       
		,ADJUSTMENT              
		,SALESPERSON_TYPE        
		,SEQUENCE_NUMBER 		
		FROM XXBS_REP_SPLITS
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		UPDATE XXBS_CUSTOMER_TRX
		SET TOTAL_LINE_AMOUNT = (SELECT SUM (SELL_AMOUNT) FROM XXBS_CUSTOMER_TRX_LINES WHERE CUSTOMER_TRX_ID = XXBS_CUSTOMER_TRX.CUSTOMER_TRX_ID)
		WHERE CUSTOMER_TRX_ID  = v_cm_cust_trx_id;


		--Create Revise Invoice

		FOR v_loop_count IN 1..v_revise_num LOOP

			v_revise_cust_trx_id:= XXBS_CUSTOMER_TRX_S.nextval;

			INSERT INTO XXBS_CUSTOMER_TRX
			(
				CUSTOMER_TRX_ID         
				,PARENT_CUSTOMER_TRX_ID  
				,AR_TRX_NUMBER           
				,SET_OF_BOOKS_ID         
				,PRIMARY_PRODUCT_TYPE_ID 
				,PROFILE_ID              
				,CUST_TRX_TYPE_ID        
				,TRX_DATE                
				,DATE_RECEIVED           
				,PERIOD_NAME             
				,PRIMARY_SALESREP_ID     
				,DESCRIPTION             
				,COMMENTS                
				,BILL_TO_ADDRESS_ID      
				,BILL_TO_CUSTOMER_ID     
				,ATTENDEE                
				,ATTENDEE_EMAIL          
				,INVOICE_ADDRESS_ID      
				,ORDER_NUMBER            
				,CUSTOMER_ORDER_NUMBER   
				,OWNING_BILLER_ID        
				,ACTIVE_BILLER_ID        
				,CURRENT_STATUS_DATE     
				,TERM_ID                 
				,CURRENCY_CODE           
				,ENTERED_CURRENCY_CODE   
				,EXCHANGE_DATE           
				,EXCHANGE_RATE           
				,EXCHANGE_RATE_TYPE      
				,CREATED_BY              
				,CREATION_DATE           
				,LAST_UPDATED_BY         
				,LAST_UPDATE_DATE        
				,LAST_UPDATE_LOGIN       
				,PROJECT_CATEGORY_ID     
				,PRIMARY_PROJECT_ORG_ID  
				,ORIGINAL_PROJECT_ID     
				,SOURCE_SYSTEM           
				,PROJECT_COMPLETE_DATE   
				,COST_SUM_SEND_DATE      
				,MARGIN_REPORT_SEND_DATE 
				,BILL_REMARK             
				,INVOICE_CLASS           
				,CURRENT_STATUS          
				,INVOICE_STYLE_NAME      
				,INVOICE_TITLE           
				,INVOICE_DESC_ONE_LINE   
				,TAX_DESC                
				,TAX_AMOUNT              
				,INVOICE_FOOT_TOP        
				,INVOICE_FOOT_BOTTOM     
				,DISPLAY_SALESPERSON     
				,DISPLAY_LEVEL_1         
				,DISPLAY_LEVEL_1_TOTAL   
				,DISPLAY_LEVEL_2         
				,DISPLAY_LEVEL_2_TOTAL   
				,DISPLAY_LEVEL_3         
				,DISPLAY_LEVEL_3_TOTAL    
				,PRELIMINARY             
				,BILL_TO_CONTACT_ID      
				,SEC_BILL_TO_CUSTOMER_ID 
				,ORG_ID                  
				,PRINT_REQUEST_ID   
				,REVISED_CUSTOMER_TRX_ID
			)
			SELECT 
				v_revise_cust_trx_id         
				,PARENT_CUSTOMER_TRX_ID
				,get_revise_trx_number(AR_TRX_NUMBER, v_loop_count)
				,SET_OF_BOOKS_ID         
				,PRIMARY_PRODUCT_TYPE_ID
				,PROFILE_ID              
				,CUST_TRX_TYPE_ID
				,TRX_DATE                
				,DATE_RECEIVED           
				,PERIOD_NAME             
				,PRIMARY_SALESREP_ID     
				,DESCRIPTION             
				,COMMENTS                
				,BILL_TO_ADDRESS_ID      
				,BILL_TO_CUSTOMER_ID     
				,ATTENDEE                
				,ATTENDEE_EMAIL          
				,INVOICE_ADDRESS_ID      
				,ORDER_NUMBER            
				,CUSTOMER_ORDER_NUMBER   
				,OWNING_BILLER_ID        
				,ACTIVE_BILLER_ID        
				,SYSDATE --CURRENT_STATUS_DATE     
				,TERM_ID                 
				,CURRENCY_CODE           
				,ENTERED_CURRENCY_CODE   
				,EXCHANGE_DATE           
				,EXCHANGE_RATE           
				,EXCHANGE_RATE_TYPE      
				,FND_GLOBAL.USER_ID --CREATED_BY              
				,SYSDATE --CREATION_DATE           
				,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
				,SYSDATE --LAST_UPDATE_DATE        
				,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
				,PROJECT_CATEGORY_ID     
				,PRIMARY_PROJECT_ORG_ID  
				,ORIGINAL_PROJECT_ID     
				,SOURCE_SYSTEM           
				,PROJECT_COMPLETE_DATE   
				,COST_SUM_SEND_DATE      
				,MARGIN_REPORT_SEND_DATE 
				,BILL_REMARK             
				,INVOICE_CLASS           
				,'Created RI' --CURRENT_STATUS          
				,INVOICE_STYLE_NAME      
				,INVOICE_TITLE           
				,INVOICE_DESC_ONE_LINE   
				,TAX_DESC                
				,TAX_AMOUNT              
				,INVOICE_FOOT_TOP        
				,INVOICE_FOOT_BOTTOM     
				,DISPLAY_SALESPERSON     
				,DISPLAY_LEVEL_1         
				,DISPLAY_LEVEL_1_TOTAL   
				,DISPLAY_LEVEL_2         
				,DISPLAY_LEVEL_2_TOTAL   
				,DISPLAY_LEVEL_3         
				,DISPLAY_LEVEL_3_TOTAL    
				,PRELIMINARY             
				,BILL_TO_CONTACT_ID      
				,SEC_BILL_TO_CUSTOMER_ID 
				,ORG_ID                  
				,NULL --PRINT_REQUEST_ID
				,CUSTOMER_TRX_ID
			FROM XXBS_CUSTOMER_TRX
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;


			INSERT INTO XXBS_CUSTOMER_TRX_LINES
			(
			CUSTOMER_TRX_LINE_ID 
			,CUSTOMER_TRX_ID      
			,ORIG_CUSTOMER_TRX_ID 
			,ORIG_TRX_LINE_ID     
			,PROJECT_ID           
			,LINE_NUMBER          
			,ORG_ID               
			,PROJECT_ORG_ID       
			,QUANTITY_SELL        
			,UNIT_SELL            
			,SELL_AMOUNT          
			,PRODUCT_TYPE_ID      
			,LONG_DESCRIPTION     
			,CREATED_BY           
			,CREATION_DATE        
			,LAST_UPDATED_BY      
			,LAST_UPDATE_DATE     
			,LAST_UPDATE_LOGIN    
			,AR_TRX_LINE_NUMBER   
			,LINE_TYPE            
			,STATUS               
			,LEVEL_1              
			,LEVEL_2              
			,LEVEL_3
			,REVISED_CUSTOMER_TRX_ID
			,REVISED_CUSTOMER_TRX_LINE_ID
			) 
			SELECT 
			 XXBS_CUSTOMER_TRX_LINE_S.nextval 
			,v_revise_cust_trx_id      
			,ORIG_CUSTOMER_TRX_ID 
			,ORIG_TRX_LINE_ID     
			,PROJECT_ID           
			,LINE_NUMBER          
			,ORG_ID               
			,PROJECT_ORG_ID       
			,QUANTITY_SELL        
			,UNIT_SELL            
			,SELL_AMOUNT          
			,PRODUCT_TYPE_ID      
			,LONG_DESCRIPTION     
			,FND_GLOBAL.USER_ID  --CREATED_BY           
			,SYSDATE --CREATION_DATE        
			,FND_GLOBAL.USER_ID  --LAST_UPDATED_BY      
			,SYSDATE --LAST_UPDATE_DATE     
			,FND_GLOBAL.LOGIN_ID --LAST_UPDATE_LOGIN    
			,AR_TRX_LINE_NUMBER   
			,LINE_TYPE            
			,STATUS               
			,LEVEL_1              
			,LEVEL_2              
			,LEVEL_3         
			,CUSTOMER_TRX_ID
			,CUSTOMER_TRX_LINE_ID
			FROM XXBS_CUSTOMER_TRX_LINES
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;


			INSERT INTO XXBS_REP_SPLITS
			(
			REP_SPLIT_ID            
			,CUSTOMER_TRX_ID         
			,SALESREP_ID             
			,PRIMARY_FLAG            
			,SPLIT_PERCENTAGE        
			,CREATED_BY              
			,CREATION_DATE           
			,LAST_UPDATED_BY         
			,LAST_UPDATE_DATE        
			,LAST_UPDATE_LOGIN       
			,ADJUSTMENT              
			,SALESPERSON_TYPE        
			,SEQUENCE_NUMBER 
			)
			SELECT
			XXBS_REP_SPLITS_S.nextval            
			,v_revise_cust_trx_id         
			,SALESREP_ID             
			,PRIMARY_FLAG            
			,SPLIT_PERCENTAGE        
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID --LAST_UPDATE_LOGIN       
			,ADJUSTMENT              
			,SALESPERSON_TYPE        
			,SEQUENCE_NUMBER 		
			FROM XXBS_REP_SPLITS
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

			UPDATE XXBS_CUSTOMER_TRX
			SET TOTAL_LINE_AMOUNT = (SELECT SUM (SELL_AMOUNT) FROM XXBS_CUSTOMER_TRX_LINES WHERE CUSTOMER_TRX_ID = XXBS_CUSTOMER_TRX.CUSTOMER_TRX_ID)
			WHERE CUSTOMER_TRX_ID  = v_revise_cust_trx_id;				

		END LOOP;

		p_return_status:= 'S';
		p_msg:= NULL;
    EXCEPTION WHEN e_gl_period THEN
        p_return_status:= 'F';
        p_msg:= 'GL Period ['||to_char(sysdate,'MON-RR')||'] is not Opened';
	END;

    PROCEDURE reject_revise
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
	v_revise_num NUMBER;
	BEGIN

		SELECT REVISE_TO_NUM into v_revise_num FROM XXBS_CUSTOMER_TRX 
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id; 

		UPDATE XXBS_CUSTOMER_TRX
		SET 
		REVISE_TO_NUM = NULL
		,CURRENT_STATUS = NVL(PREVIOUS_STATUS,'Created')
		--CURRENT_STATUS = 'Created'
		,CURRENT_STATUS_DATE = SYSDATE
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, p_customer_trx_id
		, SYSDATE
		, 'Request rejected'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Revise to '||v_revise_num||' Invoice(s)'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);

		p_return_status:= 'S';
		p_msg:= NULL;

	END;


    PROCEDURE perform_audit
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) IS
	v_count NUMBER;
	BEGIN

		DELETE FROM XXBS_TRX_AUDITS WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		v_count:=0;

		SELECT COUNT(1) INTO v_count 
		FROM XXBS_CUSTOMER_TRX trx
		, XXBS_CUSTOMER_TRX_LINES lines
		, RA_CUST_TRX_TYPES_ALL trx_type
		WHERE trx.CUSTOMER_TRX_ID = p_customer_trx_id 
		AND trx.CUSTOMER_TRX_ID = lines.CUSTOMER_TRX_ID (+)
		AND trx.CUST_TRX_TYPE_ID = trx_type.CUST_TRX_TYPE_ID (+)
		AND trx_type.NAME IN ('TM FINANCIAL INV', 'TM DEPOSIT INV', 'TM MEAL INV')
		AND (lines.SELL_AMOUNT <=0 OR lines.SELL_AMOUNT IS NULL);

		IF v_count > 0 THEN
			INSERT INTO XXBS_TRX_AUDITS
			(
			TRX_AUDIT_ID
			, CUSTOMER_TRX_ID
			, PROBLEM_DESC
			, FIX_DESC
			, CREATED_BY
			, CREATION_DATE
			, LAST_UPDATED_BY
			, LAST_UPDATE_DATE
			, LAST_UPDATE_LOGIN
			)VALUES
			(
			XXBS_TRX_AUDIT_S.nextval
			,p_customer_trx_id
			,'Total Sell Amount Must be Positive for Transaction Type'
			,'Please correct line amounts'
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
			);
		END IF;

		v_count:=0;

		SELECT COUNT(1) INTO v_count 
		FROM XXBS_CUSTOMER_TRX trx
		, HZ_CUST_ACCOUNTS_ALL acc
		, HZ_PARTIES cust
		WHERE trx.CUSTOMER_TRX_ID = p_customer_trx_id 
		AND trx.BILL_TO_CUSTOMER_ID = acc.CUST_ACCOUNT_ID (+)
		AND acc.PARTY_ID = cust.PARTY_ID (+)
		AND cust.PARTY_NAME = 'Default Customer';

		IF v_count > 0 THEN
			INSERT INTO XXBS_TRX_AUDITS
			(
			TRX_AUDIT_ID
			, CUSTOMER_TRX_ID
			, PROBLEM_DESC
			, FIX_DESC
			, CREATED_BY
			, CREATION_DATE
			, LAST_UPDATED_BY
			, LAST_UPDATE_DATE
			, LAST_UPDATE_LOGIN
			)VALUES
			(
			XXBS_TRX_AUDIT_S.nextval
			,p_customer_trx_id
			,'Customer is a default billing setup customer'
			,'Change the customer on the transaction'
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
			);		
		END IF;

		v_count:=0;

		SELECT COUNT(1) into v_count
		FROM
		(
		SELECT COUNT(1) SALESREP_COUNT, SALESREP_ID 
		FROM XXBS_REP_SPLITS
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id
		GROUP BY SALESREP_ID
		)
		WHERE SALESREP_COUNT > 1;


		IF v_count > 0 THEN
			INSERT INTO XXBS_TRX_AUDITS
			(
			TRX_AUDIT_ID
			, CUSTOMER_TRX_ID
			, PROBLEM_DESC
			, FIX_DESC
			, CREATED_BY
			, CREATION_DATE
			, LAST_UPDATED_BY
			, LAST_UPDATE_DATE
			, LAST_UPDATE_LOGIN
			)VALUES
			(
			XXBS_TRX_AUDIT_S.nextval
			,p_customer_trx_id
			,'Duplicate Salesrep in Rep Splits'
			,'Remove the duplicate salesrep from the Rep Splits'
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
			);		
		END IF;

		v_count:=0;

		SELECT COUNT(1) into v_count
		FROM
		(
		SELECT SUM(SPLIT_PERCENTAGE) TOTAL
		FROM XXBS_REP_SPLITS
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id
		)
		WHERE TOTAL <> 100;

		IF v_count > 0 THEN
			INSERT INTO XXBS_TRX_AUDITS
			(
			TRX_AUDIT_ID
			, CUSTOMER_TRX_ID
			, PROBLEM_DESC
			, FIX_DESC
			, CREATED_BY
			, CREATION_DATE
			, LAST_UPDATED_BY
			, LAST_UPDATE_DATE
			, LAST_UPDATE_LOGIN
			)VALUES
			(
			XXBS_TRX_AUDIT_S.nextval
			,p_customer_trx_id
			,'Total of Rep Splits must be a 100'
			,'Correct the Rep Splits'
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
			);		
		END IF;


		v_count:=0;

		SELECT COUNT(1) into v_count
		FROM
		(
		SELECT COUNT(1) SALESREP_COUNT 
		FROM XXBS_REP_SPLITS
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id
		AND PRIMARY_FLAG ='Y'
		)
		WHERE SALESREP_COUNT > 1;


		IF v_count > 0 THEN
			INSERT INTO XXBS_TRX_AUDITS
			(
			TRX_AUDIT_ID
			, CUSTOMER_TRX_ID
			, PROBLEM_DESC
			, FIX_DESC
			, CREATED_BY
			, CREATION_DATE
			, LAST_UPDATED_BY
			, LAST_UPDATE_DATE
			, LAST_UPDATE_LOGIN
			)VALUES
			(
			XXBS_TRX_AUDIT_S.nextval
			,p_customer_trx_id
			,'Duplicate Primary Salesrep in Rep Splits'
			,'Remove the duplicate primary salesrep from the Rep Splits'
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
			);		
		END IF;

		v_count:=0;

		SELECT COUNT(1) into v_count
		FROM XXBS_CUSTOMER_TRX_LINES
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		IF v_count <= 0 THEN
			INSERT INTO XXBS_TRX_AUDITS
			(
			TRX_AUDIT_ID
			, CUSTOMER_TRX_ID
			, PROBLEM_DESC
			, FIX_DESC
			, CREATED_BY
			, CREATION_DATE
			, LAST_UPDATED_BY
			, LAST_UPDATE_DATE
			, LAST_UPDATE_LOGIN
			)VALUES
			(
			XXBS_TRX_AUDIT_S.nextval
			,p_customer_trx_id
			,'Transaction has no lines'
			,'Create Lines'
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
			);		
		END IF;

		v_count:=0;

		SELECT COUNT(1) into v_count
		FROM GL_PERIOD_STATUSES period, XXBS_CUSTOMER_TRX trx 
		WHERE 
		trx.CUSTOMER_TRX_ID = p_customer_trx_id
		AND trx.SET_OF_BOOKS_ID = period.SET_OF_BOOKS_ID (+) 
		AND trx.PERIOD_NAME = period.PERIOD_NAME (+)
		AND (trunc(trx.TRX_DATE) > trunc(period.END_DATE) OR period.END_DATE IS NULL)
		AND APPLICATION_ID in (SELECT FA.APPLICATION_ID from FND_APPLICATION FA where FA.APPLICATION_SHORT_NAME in ('AR'));

		IF v_count > 0 THEN
			INSERT INTO XXBS_TRX_AUDITS
			(
			TRX_AUDIT_ID
			, CUSTOMER_TRX_ID
			, PROBLEM_DESC
			, FIX_DESC
			, CREATED_BY
			, CREATION_DATE
			, LAST_UPDATED_BY
			, LAST_UPDATE_DATE
			, LAST_UPDATE_LOGIN
			)VALUES
			(
			XXBS_TRX_AUDIT_S.nextval
			,p_customer_trx_id
			,'Transaction date is after last day of GL Period'
			,'Set transaction date to fall within or before GL Period'
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
			);		
		END IF;

		v_count:=0;

		SELECT COUNT(1) into v_count
		FROM XXBS_CUSTOMER_TRX_LINES
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id
		AND (LEVEL_1 IS NULL AND LEVEL_2 IS NULL AND LEVEL_3 IS NULL);

		IF v_count > 0 THEN
			INSERT INTO XXBS_TRX_AUDITS
			(
			TRX_AUDIT_ID
			, CUSTOMER_TRX_ID
			, PROBLEM_DESC
			, FIX_DESC
			, CREATED_BY
			, CREATION_DATE
			, LAST_UPDATED_BY
			, LAST_UPDATE_DATE
			, LAST_UPDATE_LOGIN
			)VALUES
			(
			XXBS_TRX_AUDIT_S.nextval
			,p_customer_trx_id
			,'Lines with blank Levels'
			,'Assign Levels to all Lines'
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
			);		
		END IF;		

		p_return_status:= 'S';
		p_msg:= NULL;

	END perform_audit;

    PROCEDURE perform_print
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) IS
	v_con_req_id            NUMBER;
	v_ar_trx_number		VARCHAR2(50);
	BEGIN
		SELECT AR_TRX_NUMBER into v_ar_trx_number 
		FROM XXBS_CUSTOMER_TRX WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		  v_con_req_id := fnd_request.submit_request ( 
									application   =>'XXTM', 
									program       =>'XXAR_INV_PRINT_MAIN', 
									description   =>'XXAR_INV_PRINT_MAIN', 
									start_time    =>sysdate, 
									sub_request   =>FALSE,
									argument1     =>v_ar_trx_number
		);


		IF v_con_req_id = 0
		THEN
		 dbms_output.put_line ('Concurrent Program failed to Call from plsql');
		ELSE
		 dbms_output.put_line('Concurrent Program Sucessfully Call from plsql');
		END IF;  

		p_return_status:= 'S';
		p_msg:= NULL;
	EXCEPTION
	WHEN OTHERS THEN
		dbms_output.put_line('Error In Running Concurrent Program XXAR_INV_PRINT_MAIN');
		p_return_status:= 'F';
		p_msg:= 'Error In Running Concurrent Program XXAR_INV_PRINT_MAIN';

	END perform_print;	


    PROCEDURE copy_final_invoice
    ( p_customer_trx_id      	IN  NUMBER 
	 ,p_cust_trx_type_id		IN  NUMBER  
	 ,p_new_cust_trx_id			OUT NUMBER
	 ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) IS
	v_trx_type varchar2(100);
	BEGIN

		SELECT NAME INTO v_trx_type FROM RA_CUST_TRX_TYPES_ALL where CUST_TRX_TYPE_ID = p_cust_trx_type_id AND TYPE ='INV';

		IF (v_trx_type= 'TM FINANCIAL INV') THEN
			p_new_cust_trx_id := XXBS_CUSTOMER_TRX_S.nextval;
			INSERT INTO XXBS_CUSTOMER_TRX
			(
				CUSTOMER_TRX_ID         
				,PARENT_CUSTOMER_TRX_ID  
				,AR_TRX_NUMBER           
				,SET_OF_BOOKS_ID         
				,PRIMARY_PRODUCT_TYPE_ID 
				,PROFILE_ID              
				,CUST_TRX_TYPE_ID        
				,TRX_DATE                
				,DATE_RECEIVED           
				,PERIOD_NAME             
				,PRIMARY_SALESREP_ID     
				,DESCRIPTION             
				,COMMENTS                
				,BILL_TO_ADDRESS_ID      
				,BILL_TO_CUSTOMER_ID     
				,ATTENDEE                
				,ATTENDEE_EMAIL          
				,INVOICE_ADDRESS_ID      
				,ORDER_NUMBER            
				,CUSTOMER_ORDER_NUMBER   
				,OWNING_BILLER_ID        
				,ACTIVE_BILLER_ID        
				,CURRENT_STATUS_DATE     
				,TERM_ID                 
				,CURRENCY_CODE           
				,ENTERED_CURRENCY_CODE   
				,EXCHANGE_DATE           
				,EXCHANGE_RATE           
				,EXCHANGE_RATE_TYPE      
				,CREATED_BY              
				,CREATION_DATE           
				,LAST_UPDATED_BY         
				,LAST_UPDATE_DATE        
				,LAST_UPDATE_LOGIN       
				,PROJECT_CATEGORY_ID     
				,PRIMARY_PROJECT_ORG_ID  
				,ORIGINAL_PROJECT_ID     
				,SOURCE_SYSTEM           
				,PROJECT_COMPLETE_DATE   
				,COST_SUM_SEND_DATE      
				,MARGIN_REPORT_SEND_DATE 
				,BILL_REMARK             
				,INVOICE_CLASS           
				,CURRENT_STATUS          
				,INVOICE_STYLE_NAME      
				,INVOICE_TITLE           
				,INVOICE_DESC_ONE_LINE   
				,TAX_DESC                
				,TAX_AMOUNT              
				,INVOICE_FOOT_TOP        
				,INVOICE_FOOT_BOTTOM     
				,DISPLAY_SALESPERSON     
				,DISPLAY_LEVEL_1         
				,DISPLAY_LEVEL_1_TOTAL   
				,DISPLAY_LEVEL_2         
				,DISPLAY_LEVEL_2_TOTAL   
				,DISPLAY_LEVEL_3         
				,DISPLAY_LEVEL_3_TOTAL    
				,PRELIMINARY             
				,BILL_TO_CONTACT_ID      
				,SEC_BILL_TO_CUSTOMER_ID 
				,ORG_ID                  
				,PRINT_REQUEST_ID        
			)
			SELECT 
				p_new_cust_trx_id         
				,NULL --PARENT_CUSTOMER_TRX_ID
				,XXBS_AR_TRX_NUMBER_S.nextval            
				,SET_OF_BOOKS_ID         
				,PRIMARY_PRODUCT_TYPE_ID
				,PROFILE_ID              
				,p_cust_trx_type_id --CUST_TRX_TYPE_ID  
				,TRX_DATE                
				,DATE_RECEIVED           
				,PERIOD_NAME             
				,PRIMARY_SALESREP_ID     
				,DESCRIPTION             
				,COMMENTS                
				,BILL_TO_ADDRESS_ID      
				,BILL_TO_CUSTOMER_ID     
				,ATTENDEE                
				,ATTENDEE_EMAIL          
				,INVOICE_ADDRESS_ID      
				,ORDER_NUMBER            
				,CUSTOMER_ORDER_NUMBER   
				,OWNING_BILLER_ID        
				,ACTIVE_BILLER_ID        
				,SYSDATE --CURRENT_STATUS_DATE     
				,TERM_ID                 
				,CURRENCY_CODE           
				,ENTERED_CURRENCY_CODE   
				,EXCHANGE_DATE           
				,EXCHANGE_RATE           
				,EXCHANGE_RATE_TYPE      
				,FND_GLOBAL.USER_ID --CREATED_BY              
				,SYSDATE --CREATION_DATE           
				,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
				,SYSDATE --LAST_UPDATE_DATE        
				,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
				,PROJECT_CATEGORY_ID     
				,PRIMARY_PROJECT_ORG_ID  
				,ORIGINAL_PROJECT_ID     
				,SOURCE_SYSTEM           
				,PROJECT_COMPLETE_DATE   
				,COST_SUM_SEND_DATE      
				,MARGIN_REPORT_SEND_DATE 
				,BILL_REMARK             
				,INVOICE_CLASS           
				,'Created' --CURRENT_STATUS          
				,INVOICE_STYLE_NAME      
				,INVOICE_TITLE           
				,INVOICE_DESC_ONE_LINE   
				,TAX_DESC                
				,TAX_AMOUNT              
				,INVOICE_FOOT_TOP        
				,INVOICE_FOOT_BOTTOM     
				,DISPLAY_SALESPERSON     
				,DISPLAY_LEVEL_1         
				,DISPLAY_LEVEL_1_TOTAL   
				,DISPLAY_LEVEL_2         
				,DISPLAY_LEVEL_2_TOTAL   
				,DISPLAY_LEVEL_3         
				,DISPLAY_LEVEL_3_TOTAL    
				,PRELIMINARY             
				,BILL_TO_CONTACT_ID      
				,SEC_BILL_TO_CUSTOMER_ID 
				,ORG_ID                  
				,NULL --PRINT_REQUEST_ID    		
			FROM XXBS_CUSTOMER_TRX
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;


			INSERT INTO XXBS_CUSTOMER_TRX_LINES
			(
			CUSTOMER_TRX_LINE_ID 
			,CUSTOMER_TRX_ID      
			,ORIG_CUSTOMER_TRX_ID 
			,ORIG_TRX_LINE_ID     
			,PROJECT_ID           
			,LINE_NUMBER          
			,ORG_ID               
			,PROJECT_ORG_ID       
			,QUANTITY_SELL        
			,UNIT_SELL            
			,SELL_AMOUNT          
			,PRODUCT_TYPE_ID      
			,LONG_DESCRIPTION     
			,CREATED_BY           
			,CREATION_DATE        
			,LAST_UPDATED_BY      
			,LAST_UPDATE_DATE     
			,LAST_UPDATE_LOGIN    
			,AR_TRX_LINE_NUMBER   
			,LINE_TYPE            
			,STATUS               
			,LEVEL_1              
			,LEVEL_2              
			,LEVEL_3              
			) 
			SELECT 
			 XXBS_CUSTOMER_TRX_LINE_S.nextval 
			,p_new_cust_trx_id      
			,ORIG_CUSTOMER_TRX_ID 
			,ORIG_TRX_LINE_ID     
			,PROJECT_ID           
			,LINE_NUMBER          
			,ORG_ID               
			,PROJECT_ORG_ID       
			,QUANTITY_SELL        
			,UNIT_SELL            
			,SELL_AMOUNT          
			,PRODUCT_TYPE_ID      
			,LONG_DESCRIPTION     
			,FND_GLOBAL.USER_ID  --CREATED_BY           
			,SYSDATE --CREATION_DATE        
			,FND_GLOBAL.USER_ID  --LAST_UPDATED_BY      
			,SYSDATE --LAST_UPDATE_DATE     
			,FND_GLOBAL.LOGIN_ID --LAST_UPDATE_LOGIN    
			,AR_TRX_LINE_NUMBER   
			,LINE_TYPE            
			,STATUS               
			,LEVEL_1              
			,LEVEL_2              
			,LEVEL_3         		
			FROM XXBS_CUSTOMER_TRX_LINES
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;


			INSERT INTO XXBS_REP_SPLITS
			(
			REP_SPLIT_ID            
			,CUSTOMER_TRX_ID         
			,SALESREP_ID             
			,PRIMARY_FLAG            
			,SPLIT_PERCENTAGE        
			,CREATED_BY              
			,CREATION_DATE           
			,LAST_UPDATED_BY         
			,LAST_UPDATE_DATE        
			,LAST_UPDATE_LOGIN       
			,ADJUSTMENT              
			,SALESPERSON_TYPE        
			,SEQUENCE_NUMBER 
			)
			SELECT
			XXBS_REP_SPLITS_S.nextval            
			,p_new_cust_trx_id         
			,SALESREP_ID             
			,PRIMARY_FLAG            
			,SPLIT_PERCENTAGE        
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID --LAST_UPDATE_LOGIN       
			,ADJUSTMENT              
			,SALESPERSON_TYPE        
			,SEQUENCE_NUMBER 		
			FROM XXBS_REP_SPLITS
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

			UPDATE XXBS_CUSTOMER_TRX
			SET TOTAL_LINE_AMOUNT = (SELECT SUM (SELL_AMOUNT) FROM XXBS_CUSTOMER_TRX_LINES WHERE CUSTOMER_TRX_ID = XXBS_CUSTOMER_TRX.CUSTOMER_TRX_ID)
			WHERE CUSTOMER_TRX_ID  = p_new_cust_trx_id;			

		ELSIF (v_trx_type= 'TM DEPOSIT INV' OR v_trx_type= 'TM MEAL INV' ) THEN
			p_new_cust_trx_id := XXBS_CUSTOMER_TRX_S.nextval;
			INSERT INTO XXBS_CUSTOMER_TRX
			(
				CUSTOMER_TRX_ID         
				,PARENT_CUSTOMER_TRX_ID  
				,AR_TRX_NUMBER           
				,SET_OF_BOOKS_ID         
				,PRIMARY_PRODUCT_TYPE_ID 
				,PROFILE_ID              
				,CUST_TRX_TYPE_ID        
				,TRX_DATE                
				,DATE_RECEIVED           
				,PERIOD_NAME             
				,PRIMARY_SALESREP_ID     
				,DESCRIPTION             
				,COMMENTS                
				,BILL_TO_ADDRESS_ID      
				,BILL_TO_CUSTOMER_ID     
				,ATTENDEE                
				,ATTENDEE_EMAIL          
				,INVOICE_ADDRESS_ID      
				,ORDER_NUMBER            
				,CUSTOMER_ORDER_NUMBER   
				,OWNING_BILLER_ID        
				,ACTIVE_BILLER_ID        
				,CURRENT_STATUS_DATE     
				,TERM_ID                 
				,CURRENCY_CODE           
				,ENTERED_CURRENCY_CODE   
				,EXCHANGE_DATE           
				,EXCHANGE_RATE           
				,EXCHANGE_RATE_TYPE      
				,CREATED_BY              
				,CREATION_DATE           
				,LAST_UPDATED_BY         
				,LAST_UPDATE_DATE        
				,LAST_UPDATE_LOGIN       
				,PROJECT_CATEGORY_ID     
				,PRIMARY_PROJECT_ORG_ID  
				,ORIGINAL_PROJECT_ID     
				,SOURCE_SYSTEM           
				,PROJECT_COMPLETE_DATE   
				,COST_SUM_SEND_DATE      
				,MARGIN_REPORT_SEND_DATE 
				,BILL_REMARK             
				,INVOICE_CLASS           
				,CURRENT_STATUS          
				,INVOICE_STYLE_NAME      
				,INVOICE_TITLE           
				,INVOICE_DESC_ONE_LINE   
				,TAX_DESC                
				,TAX_AMOUNT              
				,INVOICE_FOOT_TOP        
				,INVOICE_FOOT_BOTTOM     
				,DISPLAY_SALESPERSON     
				,DISPLAY_LEVEL_1         
				,DISPLAY_LEVEL_1_TOTAL   
				,DISPLAY_LEVEL_2         
				,DISPLAY_LEVEL_2_TOTAL   
				,DISPLAY_LEVEL_3         
				,DISPLAY_LEVEL_3_TOTAL    
				,PRELIMINARY             
				,BILL_TO_CONTACT_ID      
				,SEC_BILL_TO_CUSTOMER_ID 
				,ORG_ID                  
				,PRINT_REQUEST_ID        
			)
			SELECT 
				p_new_cust_trx_id         
				,NULL --PARENT_CUSTOMER_TRX_ID
				,XXBS_AR_TRX_NUMBER_S.nextval            
				,SET_OF_BOOKS_ID         
				,(select ATTRIBUTE2 FROM RA_CUST_TRX_TYPES_ALL where CUST_TRX_TYPE_ID = p_cust_trx_type_id)  --PRIMARY_PRODUCT_TYPE_ID
				,PROFILE_ID              
				,p_cust_trx_type_id  --CUST_TRX_TYPE_ID      
				,TRX_DATE                
				,DATE_RECEIVED           
				,PERIOD_NAME             
				,PRIMARY_SALESREP_ID     
				,DESCRIPTION             
				,COMMENTS                
				,BILL_TO_ADDRESS_ID      
				,BILL_TO_CUSTOMER_ID     
				,ATTENDEE                
				,ATTENDEE_EMAIL          
				,INVOICE_ADDRESS_ID      
				,ORDER_NUMBER            
				,CUSTOMER_ORDER_NUMBER   
				,OWNING_BILLER_ID        
				,ACTIVE_BILLER_ID        
				,SYSDATE --CURRENT_STATUS_DATE     
				,TERM_ID                 
				,CURRENCY_CODE           
				,ENTERED_CURRENCY_CODE   
				,EXCHANGE_DATE           
				,EXCHANGE_RATE           
				,EXCHANGE_RATE_TYPE      
				,FND_GLOBAL.USER_ID --CREATED_BY              
				,SYSDATE --CREATION_DATE           
				,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
				,SYSDATE --LAST_UPDATE_DATE        
				,FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN       
				,PROJECT_CATEGORY_ID     
				,PRIMARY_PROJECT_ORG_ID  
				,ORIGINAL_PROJECT_ID     
				,SOURCE_SYSTEM           
				,PROJECT_COMPLETE_DATE   
				,COST_SUM_SEND_DATE      
				,MARGIN_REPORT_SEND_DATE 
				,BILL_REMARK             
				,INVOICE_CLASS           
				,'Created' --CURRENT_STATUS          
				,INVOICE_STYLE_NAME      
				,INVOICE_TITLE           
				,INVOICE_DESC_ONE_LINE   
				,TAX_DESC                
				,TAX_AMOUNT              
				,INVOICE_FOOT_TOP        
				,INVOICE_FOOT_BOTTOM     
				,DISPLAY_SALESPERSON     
				,DISPLAY_LEVEL_1         
				,DISPLAY_LEVEL_1_TOTAL   
				,DISPLAY_LEVEL_2         
				,DISPLAY_LEVEL_2_TOTAL   
				,DISPLAY_LEVEL_3         
				,DISPLAY_LEVEL_3_TOTAL    
				,PRELIMINARY             
				,BILL_TO_CONTACT_ID      
				,SEC_BILL_TO_CUSTOMER_ID 
				,ORG_ID                  
				,NULL --PRINT_REQUEST_ID    		
			FROM XXBS_CUSTOMER_TRX
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;


			INSERT INTO XXBS_CUSTOMER_TRX_LINES
			(
			CUSTOMER_TRX_LINE_ID 
			,CUSTOMER_TRX_ID      
			,ORIG_CUSTOMER_TRX_ID 
			,ORIG_TRX_LINE_ID     
			,PROJECT_ID           
			,LINE_NUMBER          
			,ORG_ID               
			,PROJECT_ORG_ID       
			,QUANTITY_SELL        
			,UNIT_SELL            
			,SELL_AMOUNT          
			,PRODUCT_TYPE_ID      
			,LONG_DESCRIPTION     
			,CREATED_BY           
			,CREATION_DATE        
			,LAST_UPDATED_BY      
			,LAST_UPDATE_DATE     
			,LAST_UPDATE_LOGIN    
			,AR_TRX_LINE_NUMBER   
			,LINE_TYPE            
			,STATUS               
			,LEVEL_1              
			,LEVEL_2              
			,LEVEL_3              
			) 
			SELECT 
			 XXBS_CUSTOMER_TRX_LINE_S.nextval 
			,p_new_cust_trx_id      
			,ORIG_CUSTOMER_TRX_ID 
			,ORIG_TRX_LINE_ID     
			,PROJECT_ID           
			,LINE_NUMBER          
			,ORG_ID               
			,PROJECT_ORG_ID       
			,QUANTITY_SELL        
			,UNIT_SELL            
			,SELL_AMOUNT          
			,PRODUCT_TYPE_ID      
			,LONG_DESCRIPTION     
			,FND_GLOBAL.USER_ID  --CREATED_BY           
			,SYSDATE --CREATION_DATE        
			,FND_GLOBAL.USER_ID  --LAST_UPDATED_BY      
			,SYSDATE --LAST_UPDATE_DATE     
			,FND_GLOBAL.LOGIN_ID --LAST_UPDATE_LOGIN    
			,AR_TRX_LINE_NUMBER   
			,LINE_TYPE            
			,STATUS               
			,LEVEL_1              
			,LEVEL_2              
			,LEVEL_3         		
			FROM XXBS_CUSTOMER_TRX_LINES
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;


			INSERT INTO XXBS_REP_SPLITS
			(
			REP_SPLIT_ID            
			,CUSTOMER_TRX_ID         
			,SALESREP_ID             
			,PRIMARY_FLAG            
			,SPLIT_PERCENTAGE        
			,CREATED_BY              
			,CREATION_DATE           
			,LAST_UPDATED_BY         
			,LAST_UPDATE_DATE        
			,LAST_UPDATE_LOGIN       
			,ADJUSTMENT              
			,SALESPERSON_TYPE        
			,SEQUENCE_NUMBER 
			)
			SELECT
			XXBS_REP_SPLITS_S.nextval            
			,p_new_cust_trx_id         
			,SALESREP_ID             
			,PRIMARY_FLAG            
			,SPLIT_PERCENTAGE        
			,FND_GLOBAL.USER_ID --CREATED_BY              
			,SYSDATE --CREATION_DATE           
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY         
			,SYSDATE --LAST_UPDATE_DATE        
			,FND_GLOBAL.LOGIN_ID --LAST_UPDATE_LOGIN       
			,ADJUSTMENT              
			,SALESPERSON_TYPE        
			,SEQUENCE_NUMBER 		
			FROM XXBS_REP_SPLITS
			WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

			UPDATE XXBS_CUSTOMER_TRX
			SET TOTAL_LINE_AMOUNT = (SELECT SUM (SELL_AMOUNT) FROM XXBS_CUSTOMER_TRX_LINES WHERE CUSTOMER_TRX_ID = XXBS_CUSTOMER_TRX.CUSTOMER_TRX_ID)
			WHERE CUSTOMER_TRX_ID  = p_new_cust_trx_id;

		END IF;

		p_return_status:= 'S';
		p_msg:= NULL;	
	END copy_final_invoice;	


	PROCEDURE check_parent_for_combine
    ( p_parent_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
	v_count_parent NUMBER;
	v_count_child  NUMBER;
	BEGIN

		SELECT COUNT(1) INTO v_count_parent
		FROM  XXBS_COMBINE_REQ req
		WHERE req.PARENT_CUSTOMER_TRX_ID = p_parent_customer_trx_id
		AND req.STATUS IN('Created','Pending Approval Combine', 'Pending Approval Uncombine');

		SELECT COUNT(1) INTO v_count_child
		FROM  XXBS_COMBINE_REQ req, XXBS_COMBINE_REQ_DTL dtl
		WHERE req.COMBINE_REQ_ID = dtl.COMBINE_REQ_ID
		AND dtl.CHILD_CUSTOMER_TRX_ID = p_parent_customer_trx_id
		AND req.STATUS IN('Created','Pending Approval Combine', 'Pending Approval Uncombine');


		IF (v_count_parent > 0 OR v_count_child > 0) THEN
			p_return_status:= 'F';
			p_msg:= 'Ouststanding combine/uncombine request is found';

		ELSE
			p_return_status:= 'S';
			p_msg:= NULL;

		END IF;

	END check_parent_for_combine;	



	PROCEDURE check_child_for_combine
    ( p_parent_customer_trx_id      IN  NUMBER 
	 ,p_child_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
	v_count_parent NUMBER;
	v_count_child  NUMBER;	
	BEGIN

		SELECT COUNT(1) INTO v_count_parent
		FROM  XXBS_COMBINE_REQ req
		WHERE req.PARENT_CUSTOMER_TRX_ID = p_child_customer_trx_id
		AND req.STATUS IN('Created','Pending Approval Combine', 'Pending Approval Uncombine');

		SELECT COUNT(1) INTO v_count_child
		FROM  XXBS_COMBINE_REQ req, XXBS_COMBINE_REQ_DTL dtl
		WHERE req.COMBINE_REQ_ID = dtl.COMBINE_REQ_ID
		AND dtl.CHILD_CUSTOMER_TRX_ID = p_child_customer_trx_id
		AND req.STATUS IN('Created','Pending Approval Combine', 'Pending Approval Uncombine');


		IF (v_count_parent > 0 OR v_count_child > 0) THEN
			p_return_status:= 'F';
			p_msg:= 'Ouststanding combine/uncombine request is found';
		ELSE
			p_return_status:= 'S';
			p_msg:= NULL;

		END IF;

	END check_child_for_combine;	


	PROCEDURE check_trx_for_revise
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
	v_revise_count NUMBER;
	BEGIN

		v_revise_count := 0;
		SELECT COUNT(1) INTO v_revise_count
		FROM  XXBS_CUSTOMER_TRX 
		WHERE REVISED_CUSTOMER_TRX_ID = p_customer_trx_id;

		IF (v_revise_count > 0 ) THEN
			p_return_status:= 'F';
			p_msg:= 'Invoice Transaction was already revised before';
		ELSE
			p_return_status:= 'S';
			p_msg:= NULL;

		END IF;


	END check_trx_for_revise;

	PROCEDURE create_combine_req
    ( p_parent_customer_trx_id      IN  NUMBER 
	 ,p_combine_req_id			OUT  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
	BEGIN

		p_combine_req_id := XXBS_COMBINE_REQ_S.nextval;

		INSERT INTO XXBS_COMBINE_REQ
		(
	     COMBINE_REQ_ID
		,REQ_TYPE 
		,PARENT_CUSTOMER_TRX_ID 
		,COMBINE_REQ_NUMBER 
		,STATUS 
		,APPROVAL_REASON 
		,JUSTIFICATION 
		,ORG_ID 
		,CREATED_BY 
		,CREATION_DATE
		,LAST_UPDATED_BY 
		,LAST_UPDATE_DATE 
		,LAST_UPDATE_LOGIN 				
		) VALUES
		(
	     p_combine_req_id
		,'Combine' 
		,p_parent_customer_trx_id 
		,XXBS_COMBINE_REQ_NUM_S.nextval
		,'Created' 
		,NULL
		,NULL
		,FND_PROFILE.VALUE('ORG_ID') 
		,FND_GLOBAL.USER_ID --CREATED_BY 
		,SYSDATE --CREATION_DATE
		,FND_GLOBAL.USER_ID --LAST_UPDATED_BY 
		,SYSDATE 
		,FND_GLOBAL.LOGIN_ID --LAST_UPDATE_LOGIN       
		);

		p_return_status:= 'S';
		p_msg:= NULL;		

	END create_combine_req;	

	PROCEDURE submit_approval_combine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
	 ,p_approval_reason			IN  VARCHAR2
	 ,p_justification			IN  VARCHAR2
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
	v_parent_customer_trx_id NUMBER;
	BEGIN

		SELECT PARENT_CUSTOMER_TRX_ID into v_parent_customer_trx_id 
		FROM XXBS_COMBINE_REQ WHERE COMBINE_REQ_ID = p_combine_req_id;

		UPDATE XXBS_COMBINE_REQ
		SET STATUS = 'Pending Approval Combine'
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE COMBINE_REQ_ID = p_combine_req_id;

		UPDATE XXBS_CUSTOMER_TRX
		SET 
		PREVIOUS_STATUS = CURRENT_STATUS
		,CURRENT_STATUS = 'Pending Approval Combine'
		,CURRENT_STATUS_DATE = SYSDATE			
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE CUSTOMER_TRX_ID = v_parent_customer_trx_id;

		UPDATE XXBS_CUSTOMER_TRX
		SET 
		PREVIOUS_STATUS = CURRENT_STATUS
		,CURRENT_STATUS = 'Pending Approval Combine'
		,CURRENT_STATUS_DATE = SYSDATE			
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, v_parent_customer_trx_id
		, SYSDATE
		, 'Requested for approval'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Combine'
		, p_approval_reason
		, p_justification
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) 
		SELECT
		XXBS_TRX_ACTIVITY_S.nextval
		, CUSTOMER_TRX_ID
		, SYSDATE
		, 'Requested for approval'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Combine'
		, p_approval_reason
		, p_justification
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		FROM XXBS_CUSTOMER_TRX
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );

		p_return_status:= 'S';
		p_msg:= NULL;		

	END submit_approval_combine_req;


	PROCEDURE approve_combine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS 
	v_parent_customer_trx_id NUMBER;
	BEGIN

		SELECT PARENT_CUSTOMER_TRX_ID into v_parent_customer_trx_id FROM XXBS_COMBINE_REQ WHERE COMBINE_REQ_ID = p_combine_req_id;

		UPDATE XXBS_COMBINE_REQ
		SET STATUS = 'Approved'
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE COMBINE_REQ_ID = p_combine_req_id;

		UPDATE XXBS_CUSTOMER_TRX
		SET 
		CURRENT_STATUS = NVL(PREVIOUS_STATUS,'Created')
		--CURRENT_STATUS = 'Created'
		,CURRENT_STATUS_DATE = SYSDATE			
		,INVOICE_CLASS = 'P' 
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE CUSTOMER_TRX_ID = v_parent_customer_trx_id;

		/*
		INSERT INTO XXBS_CUSTOMER_TRX_LINES
		(
			CUSTOMER_TRX_LINE_ID      
			,CUSTOMER_TRX_ID      
			,ORIG_CUSTOMER_TRX_ID 
			,ORIG_TRX_LINE_ID     
			,PROJECT_ID            
			,LINE_NUMBER          
			,ORG_ID               
			,PROJECT_ORG_ID       
			,QUANTITY_SELL        
			,UNIT_SELL            
			,SELL_AMOUNT          
			,PRODUCT_TYPE_ID      
			,LONG_DESCRIPTION     
			,CREATED_BY           
			,CREATION_DATE        
			,LAST_UPDATED_BY      
			,LAST_UPDATE_DATE     
			,LAST_UPDATE_LOGIN    
			,AR_TRX_LINE_NUMBER   
			,LINE_TYPE            
			,STATUS               
			,LEVEL_1              
			,LEVEL_2              
			,LEVEL_3              
		)
		SELECT 
			XXBS_CUSTOMER_TRX_LINE_S.nextval
			,v_parent_customer_trx_id
			,CUSTOMER_TRX_ID
			,CUSTOMER_TRX_LINE_ID
			,PROJECT_ID
			,LINE_NUMBER          
			,ORG_ID               
			,PROJECT_ORG_ID       
			,QUANTITY_SELL        
			,UNIT_SELL            
			,SELL_AMOUNT          
			,PRODUCT_TYPE_ID      
			,LONG_DESCRIPTION     
			,CREATED_BY           
			,CREATION_DATE        
			,LAST_UPDATED_BY      
			,LAST_UPDATE_DATE     
			,LAST_UPDATE_LOGIN    
			,AR_TRX_LINE_NUMBER   
			,LINE_TYPE            
			,STATUS               
			,LEVEL_1              
			,LEVEL_2              
			,LEVEL_3              
		FROM XXBS_CUSTOMER_TRX_LINES
		WHERE 
		CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );
		*/

		/*
		DELETE FROM XXBS_CUSTOMER_TRX_LINES
		WHERE 
		CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );
		*/


		UPDATE XXBS_CUSTOMER_TRX_LINES
		SET ORIG_CUSTOMER_TRX_ID = CUSTOMER_TRX_ID
		,CUSTOMER_TRX_ID = v_parent_customer_trx_id
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );


		UPDATE XXBS_CUSTOMER_TRX
		SET TOTAL_LINE_AMOUNT = (SELECT SUM (SELL_AMOUNT) FROM XXBS_CUSTOMER_TRX_LINES WHERE CUSTOMER_TRX_ID = XXBS_CUSTOMER_TRX.CUSTOMER_TRX_ID)
		WHERE CUSTOMER_TRX_ID  = v_parent_customer_trx_id;

		UPDATE XXBS_CUSTOMER_TRX
		SET TOTAL_LINE_AMOUNT = (SELECT SUM (SELL_AMOUNT) FROM XXBS_CUSTOMER_TRX_LINES WHERE CUSTOMER_TRX_ID = XXBS_CUSTOMER_TRX.CUSTOMER_TRX_ID)
		WHERE CUSTOMER_TRX_ID  IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );


		UPDATE XXBS_CUSTOMER_TRX
		SET 
		PARENT_CUSTOMER_TRX_ID = v_parent_customer_trx_id
		 ,CURRENT_STATUS = 'Void'
		 ,CURRENT_STATUS_DATE = SYSDATE			
		 ,INVOICE_CLASS = 'C' 
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );



		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, v_parent_customer_trx_id
		, SYSDATE
		, 'Request approved'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Combine'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) 
		SELECT
		XXBS_TRX_ACTIVITY_S.nextval
		, CUSTOMER_TRX_ID
		, SYSDATE
		, 'Request approved'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Combine'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		FROM XXBS_CUSTOMER_TRX
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );

		p_return_status:= 'S';
		p_msg:= NULL;		


	END approve_combine_req;


	PROCEDURE reject_combine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS 
	v_parent_customer_trx_id NUMBER;
	BEGIN

		SELECT PARENT_CUSTOMER_TRX_ID into v_parent_customer_trx_id FROM XXBS_COMBINE_REQ WHERE COMBINE_REQ_ID = p_combine_req_id;

		UPDATE XXBS_COMBINE_REQ
		SET STATUS = 'Rejected'
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE COMBINE_REQ_ID = p_combine_req_id;

		UPDATE XXBS_CUSTOMER_TRX
		SET CURRENT_STATUS = NVL(PREVIOUS_STATUS,'Created')
		--CURRENT_STATUS = 'Created'
		 ,CURRENT_STATUS_DATE = SYSDATE			
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE CUSTOMER_TRX_ID IN (SELECT PARENT_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ WHERE COMBINE_REQ_ID = p_combine_req_id );

		UPDATE XXBS_CUSTOMER_TRX
		SET CURRENT_STATUS = NVL(PREVIOUS_STATUS,'Created')
		--CURRENT_STATUS = 'Created'
		 ,CURRENT_STATUS_DATE = SYSDATE			
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, v_parent_customer_trx_id
		, SYSDATE
		, 'Requested rejected'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Combine'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) 
		SELECT
		XXBS_TRX_ACTIVITY_S.nextval
		, CUSTOMER_TRX_ID
		, SYSDATE
		, 'Request rejected'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Combine'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		FROM XXBS_CUSTOMER_TRX
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );

		p_return_status:= 'S';
		p_msg:= NULL;		

	END reject_combine_req;


	PROCEDURE create_uncombine_req
    ( p_parent_customer_trx_id      IN  NUMBER 
	 ,p_combine_req_id			OUT  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS

	/*
	CURSOR v_child_customer_trx_cur(p_customer_trx_id in NUMBER) IS
		SELECT DISTINCT ORIG_CUSTOMER_TRX_ID
		FROM XXBS_CUSTOMER_TRX_LINES
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id
		AND ORIG_CUSTOMER_TRX_ID IS NOT NULL
		;
	*/
	CURSOR v_child_customer_trx_cur(p_customer_trx_id in NUMBER) IS
		SELECT DISTINCT CUSTOMER_TRX_ID ORIG_CUSTOMER_TRX_ID
		FROM XXBS_CUSTOMER_TRX
		WHERE PARENT_CUSTOMER_TRX_ID = p_customer_trx_id
		;

	BEGIN
		p_combine_req_id := XXBS_COMBINE_REQ_S.nextval;

		INSERT INTO XXBS_COMBINE_REQ
		(
	     COMBINE_REQ_ID
		,REQ_TYPE 
		,PARENT_CUSTOMER_TRX_ID 
		,COMBINE_REQ_NUMBER 
		,STATUS 
		,APPROVAL_REASON 
		,JUSTIFICATION 
		,ORG_ID 
		,CREATED_BY 
		,CREATION_DATE
		,LAST_UPDATED_BY 
		,LAST_UPDATE_DATE 
		,LAST_UPDATE_LOGIN 				
		) VALUES
		(
	     p_combine_req_id
		,'Uncombine' 
		,p_parent_customer_trx_id 
		,XXBS_COMBINE_REQ_NUM_S.nextval
		,'Created' 
		,NULL
		,NULL
		,FND_PROFILE.VALUE('ORG_ID')  
		,FND_GLOBAL.USER_ID --CREATED_BY 
		,SYSDATE --CREATION_DATE
		,FND_GLOBAL.USER_ID --LAST_UPDATED_BY 
		,SYSDATE 
		,FND_GLOBAL.LOGIN_ID --LAST_UPDATE_LOGIN       
		);

		FOR v_child_customer_trx_rec in v_child_customer_trx_cur(p_parent_customer_trx_id) LOOP
			INSERT INTO XXBS_COMBINE_REQ_DTL
			(
			   "COMBINE_REQ_DTL_ID" 
				,"COMBINE_REQ_ID" 
				,"CHILD_CUSTOMER_TRX_ID" 
				,"CREATED_BY" 
				,"CREATION_DATE" 
				,"LAST_UPDATED_BY" 
				,"LAST_UPDATE_DATE" 
				,"LAST_UPDATE_LOGIN"

			) VALUES
			(
			XXBS_COMBINE_REQ_DTL_S.nextval
			, p_combine_req_id
			, v_child_customer_trx_rec.ORIG_CUSTOMER_TRX_ID
			,FND_GLOBAL.USER_ID --CREATED_BY 
			,SYSDATE --CREATION_DATE
			,FND_GLOBAL.USER_ID --LAST_UPDATED_BY 
			,SYSDATE 
			,FND_GLOBAL.LOGIN_ID --LAST_UPDATE_LOGIN       
			);
		END LOOP; 		

		p_return_status:= 'S';
		p_msg:= NULL;		

	END create_uncombine_req;

	PROCEDURE submit_approval_uncombine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
	 ,p_approval_reason			IN  VARCHAR2
	 ,p_justification			IN  VARCHAR2
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
	)IS
	v_parent_customer_trx_id NUMBER;
	BEGIN

		SELECT PARENT_CUSTOMER_TRX_ID into v_parent_customer_trx_id 
		FROM XXBS_COMBINE_REQ WHERE COMBINE_REQ_ID = p_combine_req_id;

		UPDATE XXBS_COMBINE_REQ
		SET STATUS = 'Pending Approval Uncombine'
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE COMBINE_REQ_ID = p_combine_req_id;

		UPDATE XXBS_CUSTOMER_TRX
		SET PREVIOUS_STATUS = CURRENT_STATUS
		, CURRENT_STATUS = 'Pending Approval Uncombine'
		 ,CURRENT_STATUS_DATE = SYSDATE			
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE CUSTOMER_TRX_ID = v_parent_customer_trx_id;

		UPDATE XXBS_CUSTOMER_TRX
		SET PREVIOUS_STATUS = CURRENT_STATUS
		, CURRENT_STATUS = 'Pending Approval Uncombine'
		 ,CURRENT_STATUS_DATE = SYSDATE			
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );


		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, v_parent_customer_trx_id
		, SYSDATE
		, 'Requested for approval'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Uncombine'
		, p_approval_reason
		, p_justification
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);


		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) 
		SELECT
		XXBS_TRX_ACTIVITY_S.nextval
		, CUSTOMER_TRX_ID
		, SYSDATE
		, 'Requested for approval'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Uncombine'
		, p_approval_reason
		, p_justification
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		FROM XXBS_CUSTOMER_TRX
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );

		p_return_status:= 'S';
		p_msg:= NULL;		
	END submit_approval_uncombine_req;

	PROCEDURE approve_uncombine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
	) IS
	v_parent_customer_trx_id NUMBER;
	BEGIN

		SELECT PARENT_CUSTOMER_TRX_ID into v_parent_customer_trx_id FROM XXBS_COMBINE_REQ WHERE COMBINE_REQ_ID = p_combine_req_id;

		UPDATE XXBS_COMBINE_REQ
		SET STATUS = 'Approved'
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE COMBINE_REQ_ID = p_combine_req_id;




		UPDATE XXBS_CUSTOMER_TRX_LINES
		SET 
		CUSTOMER_TRX_ID = ORIG_CUSTOMER_TRX_ID
		,ORIG_CUSTOMER_TRX_ID = NULL
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 		
		WHERE CUSTOMER_TRX_ID = v_parent_customer_trx_id
		AND ORIG_CUSTOMER_TRX_ID IS NOT NULL; 


		UPDATE XXBS_CUSTOMER_TRX
		SET TOTAL_LINE_AMOUNT = (SELECT SUM (SELL_AMOUNT) FROM XXBS_CUSTOMER_TRX_LINES WHERE XXBS_CUSTOMER_TRX_LINES.CUSTOMER_TRX_ID = XXBS_CUSTOMER_TRX.CUSTOMER_TRX_ID)
		WHERE CUSTOMER_TRX_ID  = v_parent_customer_trx_id;

		UPDATE XXBS_CUSTOMER_TRX
		SET TOTAL_LINE_AMOUNT = (SELECT SUM (SELL_AMOUNT) FROM XXBS_CUSTOMER_TRX_LINES WHERE XXBS_CUSTOMER_TRX_LINES.CUSTOMER_TRX_ID = XXBS_CUSTOMER_TRX.CUSTOMER_TRX_ID)
		WHERE CUSTOMER_TRX_ID  IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );


		UPDATE XXBS_CUSTOMER_TRX
		SET CURRENT_STATUS = 'Created'
		 ,PARENT_CUSTOMER_TRX_ID = NULL		 
		 ,CURRENT_STATUS_DATE = SYSDATE			
		 ,INVOICE_CLASS = 'N' 
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		--WHERE CUSTOMER_TRX_ID IN (SELECT DISTINCT ORIG_CUSTOMER_TRX_ID FROM XXBS_CUSTOMER_TRX_LINES WHERE CUSTOMER_TRX_ID = v_parent_customer_trx_id AND ORIG_CUSTOMER_TRX_ID IS NOT NULL);
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );



		UPDATE XXBS_CUSTOMER_TRX
		SET CURRENT_STATUS = NVL(PREVIOUS_STATUS,'Created')
		--CURRENT_STATUS = 'Created'
		,CURRENT_STATUS_DATE = SYSDATE			
		,INVOICE_CLASS = 'N' 
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE CUSTOMER_TRX_ID = v_parent_customer_trx_id;

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, v_parent_customer_trx_id
		, SYSDATE
		, 'Request approved'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Uncombine'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) 
		SELECT
		XXBS_TRX_ACTIVITY_S.nextval
		, CUSTOMER_TRX_ID
		, SYSDATE
		, 'Request approved'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Combine'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		FROM XXBS_CUSTOMER_TRX
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );

		p_return_status:= 'S';
		p_msg:= NULL;		

	END approve_uncombine_req;

	PROCEDURE reject_uncombine_req
    ( 
	 p_combine_req_id			IN  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS 
	v_parent_customer_trx_id NUMBER;
	BEGIN

        SELECT PARENT_CUSTOMER_TRX_ID into v_parent_customer_trx_id FROM XXBS_COMBINE_REQ WHERE COMBINE_REQ_ID = p_combine_req_id;

		UPDATE XXBS_COMBINE_REQ
		SET STATUS = 'Rejected'
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE COMBINE_REQ_ID = p_combine_req_id;

		UPDATE XXBS_CUSTOMER_TRX
		SET CURRENT_STATUS = NVL(PREVIOUS_STATUS,'Created')
		--CURRENT_STATUS = 'Created'
		 ,CURRENT_STATUS_DATE = SYSDATE			
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE CUSTOMER_TRX_ID IN (SELECT PARENT_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ WHERE COMBINE_REQ_ID = p_combine_req_id );

		UPDATE XXBS_CUSTOMER_TRX
		SET CURRENT_STATUS = NVL(PREVIOUS_STATUS,'Void')
		--CURRENT_STATUS = 'Created'
		 ,CURRENT_STATUS_DATE = SYSDATE			
		,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		,LAST_UPDATE_DATE = SYSDATE
		,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID 
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );


		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) VALUES
		(
		XXBS_TRX_ACTIVITY_S.nextval
		, v_parent_customer_trx_id
		, SYSDATE
		, 'Requested rejected'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Uncombine'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		);

		INSERT INTO XXBS_TRX_ACTIVITY 
		(
		TRX_ACTIVITY_ID   
		,CUSTOMER_TRX_ID   
		,ACTIVITY_DATE     
		,ACTIVITY_TYPE     
		,PERSON            
		,CHANGE_FROM                
		,CHANGE_TO                  
		,APPROVAL_ACTION            
		,APPROVAL_REASON            
		,JUSTIFICATION              
		,CREATED_BY        
		,CREATION_DATE     
		,LAST_UPDATED_BY   
		,LAST_UPDATE_DATE  
		,LAST_UPDATE_LOGIN 
		) 
		SELECT
		XXBS_TRX_ACTIVITY_S.nextval
		, CUSTOMER_TRX_ID
		, SYSDATE
		, 'Request rejected'
		, FND_GLOBAL.USER_ID
		, NULL
		, NULL
		, 'Uncombine'
		, NULL
		, NULL
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.USER_ID
		, SYSDATE
		, FND_GLOBAL.LOGIN_ID
		FROM XXBS_CUSTOMER_TRX
		WHERE CUSTOMER_TRX_ID IN (SELECT CHILD_CUSTOMER_TRX_ID FROM XXBS_COMBINE_REQ_DTL WHERE COMBINE_REQ_ID = p_combine_req_id );


		p_return_status:= 'S';
		p_msg:= NULL;		
	END reject_uncombine_req;


	PROCEDURE reset_default_sales_rep
    ( 
	 p_customer_trx_id			IN  NUMBER  
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    )IS
	v_salesrep_id_1  VARCHAR2(150);
	v_split_percentage_1  VARCHAR2(150);
	v_salesrep_id_2  VARCHAR2(150);
	v_split_percentage_2  VARCHAR2(150);
	v_salesrep_id_3  VARCHAR2(150);
	v_split_percentage_3  VARCHAR2(150);
	v_salesrep_id_4  VARCHAR2(150);
	v_split_percentage_4  VARCHAR2(150);
	v_salesrep_id_5  VARCHAR2(150);
	v_split_percentage_5  VARCHAR2(150);

	BEGIN
		SELECT 
		attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8,attribute9,attribute10 into 
		v_salesrep_id_1,v_split_percentage_1,v_salesrep_id_2,v_split_percentage_2,v_salesrep_id_3,v_split_percentage_3,v_salesrep_id_4,v_split_percentage_4,v_salesrep_id_5,v_split_percentage_5 
		FROM XXBS_CUSTOMER_TRX trx, HZ_CUST_ACCOUNTS_ALL cust
		WHERE 
		trx.CUSTOMER_TRX_ID = p_customer_trx_id
		AND trx.BILL_TO_CUSTOMER_ID = cust.CUST_ACCOUNT_ID (+);

		DELETE FROM XXBS_REP_SPLITS 
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		IF (v_salesrep_id_1 IS NOT NULL AND v_split_percentage_1 IS NOT NULL) THEN
			INSERT INTO XXBS_REP_SPLITS
			(
			"REP_SPLIT_ID" 
			,"CUSTOMER_TRX_ID" 
			,"SALESREP_ID" 
			,"PRIMARY_FLAG" 
			,"SPLIT_PERCENTAGE" 
			,"CREATED_BY" 
			,"CREATION_DATE" 
			,"LAST_UPDATED_BY" 
			,"LAST_UPDATE_DATE" 
			,"LAST_UPDATE_LOGIN" 
			) VALUES
			(
			XXBS_REP_SPLITS_S.nextval
			,p_customer_trx_id
			,TO_NUMBER (v_salesrep_id_1)
			,'Y'
			,TO_NUMBER (v_split_percentage_1)
			, FND_GLOBAL.USER_ID
			, SYSDATE
			, FND_GLOBAL.USER_ID
			, SYSDATE
			, FND_GLOBAL.LOGIN_ID
			);		
		END IF;


		IF (v_salesrep_id_2 IS NOT NULL AND v_split_percentage_2 IS NOT NULL) THEN
			INSERT INTO XXBS_REP_SPLITS
			(
			"REP_SPLIT_ID" 
			,"CUSTOMER_TRX_ID" 
			,"SALESREP_ID" 
			,"PRIMARY_FLAG" 
			,"SPLIT_PERCENTAGE" 
			,"CREATED_BY" 
			,"CREATION_DATE" 
			,"LAST_UPDATED_BY" 
			,"LAST_UPDATE_DATE" 
			,"LAST_UPDATE_LOGIN" 
			) VALUES
			(
			XXBS_REP_SPLITS_S.nextval
			,p_customer_trx_id
			,TO_NUMBER (v_salesrep_id_2)
			,'N'
			,TO_NUMBER (v_split_percentage_2)
			, FND_GLOBAL.USER_ID
			, SYSDATE
			, FND_GLOBAL.USER_ID
			, SYSDATE
			, FND_GLOBAL.LOGIN_ID
			);		
		END IF;

		IF (v_salesrep_id_3 IS NOT NULL AND v_split_percentage_3 IS NOT NULL) THEN
			INSERT INTO XXBS_REP_SPLITS
			(
			"REP_SPLIT_ID" 
			,"CUSTOMER_TRX_ID" 
			,"SALESREP_ID" 
			,"PRIMARY_FLAG" 
			,"SPLIT_PERCENTAGE" 
			,"CREATED_BY" 
			,"CREATION_DATE" 
			,"LAST_UPDATED_BY" 
			,"LAST_UPDATE_DATE" 
			,"LAST_UPDATE_LOGIN" 
			) VALUES
			(
			XXBS_REP_SPLITS_S.nextval
			,p_customer_trx_id
			,TO_NUMBER (v_salesrep_id_3)
			,'N'
			,TO_NUMBER (v_split_percentage_3)
			, FND_GLOBAL.USER_ID
			, SYSDATE
			, FND_GLOBAL.USER_ID
			, SYSDATE
			, FND_GLOBAL.LOGIN_ID
			);		
		END IF;


		IF (v_salesrep_id_4 IS NOT NULL AND v_split_percentage_4 IS NOT NULL) THEN
			INSERT INTO XXBS_REP_SPLITS
			(
			"REP_SPLIT_ID" 
			,"CUSTOMER_TRX_ID" 
			,"SALESREP_ID" 
			,"PRIMARY_FLAG" 
			,"SPLIT_PERCENTAGE" 
			,"CREATED_BY" 
			,"CREATION_DATE" 
			,"LAST_UPDATED_BY" 
			,"LAST_UPDATE_DATE" 
			,"LAST_UPDATE_LOGIN" 
			) VALUES
			(
			XXBS_REP_SPLITS_S.nextval
			,p_customer_trx_id
			,TO_NUMBER (v_salesrep_id_4)
			,'N'
			,TO_NUMBER (v_split_percentage_4)
			, FND_GLOBAL.USER_ID
			, SYSDATE
			, FND_GLOBAL.USER_ID
			, SYSDATE
			, FND_GLOBAL.LOGIN_ID
			);		
		END IF;		

		IF (v_salesrep_id_5 IS NOT NULL AND v_split_percentage_5 IS NOT NULL) THEN
			INSERT INTO XXBS_REP_SPLITS
			(
			"REP_SPLIT_ID" 
			,"CUSTOMER_TRX_ID" 
			,"SALESREP_ID" 
			,"PRIMARY_FLAG" 
			,"SPLIT_PERCENTAGE" 
			,"CREATED_BY" 
			,"CREATION_DATE" 
			,"LAST_UPDATED_BY" 
			,"LAST_UPDATE_DATE" 
			,"LAST_UPDATE_LOGIN" 
			) VALUES
			(
			XXBS_REP_SPLITS_S.nextval
			,p_customer_trx_id
			,TO_NUMBER (v_salesrep_id_5)
			,'N'
			,TO_NUMBER (v_split_percentage_5)
			, FND_GLOBAL.USER_ID
			, SYSDATE
			, FND_GLOBAL.USER_ID
			, SYSDATE
			, FND_GLOBAL.LOGIN_ID
			);		
		END IF;		

		p_return_status:= 'S';
		p_msg:= NULL;			

	END reset_default_sales_rep;


    PROCEDURE check_gl_period_open 
    (p_customer_trx_id IN NUMBER
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) IS
	v_period_closing_status gl_period_statuses.CLOSING_STATUS%type := null;
	BEGIN
        select
            gps.closing_status
        into
             v_period_closing_status
        from
            gl_period_statuses gps,
            fnd_application_vl fa,
            xxbs_customer_trx cb
        where
            cb.CUSTOMER_TRX_ID = p_customer_trx_id
            AND fa.application_short_name = 'AR'
            AND fa.application_id = gps.application_id
            AND gps.set_of_books_id = cb.set_of_books_id
            AND gps.period_name = cb.period_name;

        if v_period_closing_status <> 'O' then
            p_return_status:= 'F';
			p_msg:= 'GL Period is not Opened';
        else
            p_return_status:= 'S';
			p_msg:= NULL;
        end if;

	EXCEPTION
	   WHEN OTHERS THEN
	        p_return_status:= 'F';
			p_msg:= 'GL Period is not Opened';
	END check_gl_period_open;


    PROCEDURE check_payment_term_active 
    (p_customer_trx_id IN NUMBER
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) IS
	v_count NUMBER;
	BEGIN
        SELECT
            count(1) --SELECT TERM_ID, NAME, DESCRIPTION  
        INTO 			
			v_count
		FROM ra_terms_vl pt, xxbs_customer_trx cb 
		WHERE  
		cb.customer_trx_id = p_customer_trx_id
		AND cb.term_id = pt.term_id
		AND	NVL(TRUNC(pt.end_date_active),TRUNC(SYSDATE)) >= TRUNC(SYSDATE);				

        if v_count <= 0 then
            p_return_status:= 'F';
			p_msg:= 'Payment Term is not Active';
        else
            p_return_status:= 'S';
			p_msg:= NULL;
        end if;

	EXCEPTION
	   WHEN OTHERS THEN
	        p_return_status:= 'F';
			p_msg:= 'Payment Term is not Active';
	END check_payment_term_active;

    PROCEDURE trigger_mgr_review_wf
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) IS
	v_revised_customer_trx_id NUMBER;
	v_rebill_trx_not_review_count NUMBER;
	v_rebill_trx_review_count NUMBER;
	v_biller_name VARCHAR2(1000);
	v_rebill_trx_numbers VARCHAR2(4000);
	v_receive_role VARCHAR2(1000):= 'XXBSMGR';
	v_return_status VARCHAR2(1000);
	v_msg VARCHAR2(4000);

	BEGIN
		SELECT REVISED_CUSTOMER_TRX_ID INTO v_revised_customer_trx_id 
		FROM XXBS_CUSTOMER_TRX 
		WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

		IF (v_revised_customer_trx_id IS NOT NULL) THEN
			SELECT COUNT(1) INTO v_rebill_trx_not_review_count 
			FROM XXBS_CUSTOMER_TRX 
			WHERE 
			REVISED_CUSTOMER_TRX_ID = v_revised_customer_trx_id 
			AND CUST_TRX_TYPE_ID IN (SELECT CUST_TRX_TYPE_ID FROM RA_CUST_TRX_TYPES_ALL WHERE TYPE='INV')
			AND CURRENT_STATUS <> 'Pending Manager Review';

			IF (v_rebill_trx_not_review_count = 0) THEN
				--trigger workflow

				SELECT DESCRIPTION INTO v_biller_name FROM FND_USER WHERE USER_ID = FND_GLOBAL.USER_ID;

				/*
				SELECT LISTAGG(trx.AR_TRX_NUMBER, '|') WITHIN GROUP(ORDER BY trxtype.TYPE DESC, trx.AR_TRX_NUMBER) INTO v_rebill_trx_numbers 
				FROM XXBS_CUSTOMER_TRX trx, RA_CUST_TRX_TYPES_ALL trxtype 
				WHERE 
				trx.REVISED_CUSTOMER_TRX_ID = v_revised_customer_trx_id 
				AND trx.CUST_TRX_TYPE_ID = trxtype.CUST_TRX_TYPE_ID
				AND trxtype.TYPE IN ('INV', 'CM');
				*/

				SELECT LISTAGG(AR_TRX_NUMBER, '|') INTO v_rebill_trx_numbers FROM XXBS_CUSTOMER_TRX
				WHERE REVISED_CUSTOMER_TRX_ID = v_revised_customer_trx_id 
				AND CUST_TRX_TYPE_ID IN (SELECT CUST_TRX_TYPE_ID FROM RA_CUST_TRX_TYPES_ALL WHERE TYPE='INV');


				XXBS_INVOICE_WF_PKG.START_WORKFLOW(
					v_biller_name,
					v_rebill_trx_numbers,
					v_receive_role,
					p_return_status,
					p_msg
				);

			END IF;

		END IF;

		IF (p_return_status IS NULL) THEN
            p_return_status:= 'S';
			p_msg:= NULL;		
		END IF;


	END trigger_mgr_review_wf;


    FUNCTION get_cm_trx_number 
    (p_current_trx_number IN VARCHAR2
    ) RETURN VARCHAR2
	IS 
	v_last_num varchar2(100);
	v_next_num varchar2(100);
	v_next_trx_number varchar2(100);
	BEGIN
		v_last_num := REGEXP_SUBSTR (p_current_trx_number, '-R\d*$') ;
		IF (v_last_num IS NULL) THEN
			v_next_trx_number := p_current_trx_number ||'-C1';
		ELSE 
		    v_next_num := REGEXP_SUBSTR(v_last_num, '\d*$');
			v_next_num := '-C' || TO_CHAR(TO_NUMBER(v_next_num) + 1 );
			v_next_trx_number := p_current_trx_number ;
			SELECT REPLACE(v_next_trx_number, v_last_num ,v_next_num) INTO v_next_trx_number FROM DUAL;
		END IF;

		RETURN v_next_trx_number;
	END get_cm_trx_number;

    FUNCTION get_cm_trx_type 
    (p_current_trx_type_id IN NUMBER
    ) RETURN NUMBER
	IS 
	v_current_trx_type varchar2(100);
	v_cm_trx_type_id NUMBER;
	BEGIN

		SELECT NAME INTO v_current_trx_type FROM RA_CUST_TRX_TYPES_ALL where CUST_TRX_TYPE_ID = p_current_trx_type_id AND TYPE ='INV';

		IF (v_current_trx_type = 'TM FINANCIAL INV') THEN
			SELECT CUST_TRX_TYPE_ID INTO v_cm_trx_type_id FROM RA_CUST_TRX_TYPES_ALL 
			WHERE NAME = 'TM FINANCIAL CM' AND TYPE='CM' 
			AND ORG_ID = FND_PROFILE.VALUE('ORG_ID');

		ELSIF (v_current_trx_type = 'TM DEPOSIT INV') THEN
			SELECT CUST_TRX_TYPE_ID INTO v_cm_trx_type_id FROM RA_CUST_TRX_TYPES_ALL 
			WHERE NAME = 'TM DEPOSIT CM' AND TYPE='CM' 
			AND ORG_ID = FND_PROFILE.VALUE('ORG_ID');

		ELSIF (v_current_trx_type = 'TM MEAL INV') THEN
			SELECT CUST_TRX_TYPE_ID INTO v_cm_trx_type_id FROM RA_CUST_TRX_TYPES_ALL 
			WHERE NAME = 'TM MEAL CM' AND TYPE='CM' 
			AND ORG_ID = FND_PROFILE.VALUE('ORG_ID');

		END IF;

		RETURN v_cm_trx_type_id;

	END get_cm_trx_type;

    FUNCTION get_revise_trx_number 
    (p_current_trx_number IN VARCHAR2
	 ,p_num_new_trx_number IN NUMBER
    ) RETURN VARCHAR2
	IS 
	v_last_num varchar2(100);
	v_next_num varchar2(100);
	v_next_trx_number varchar2(100);
	BEGIN

		v_last_num := REGEXP_SUBSTR (p_current_trx_number, '-R\d*$') ;

		IF (p_num_new_trx_number IS NULL OR p_num_new_trx_number = 1) THEN
			IF (v_last_num IS NULL) THEN
				v_next_trx_number := p_current_trx_number ||'-R1';
			ELSE 
				v_next_num := REGEXP_SUBSTR(v_last_num, '\d*$');
				v_next_num := '-R' || TO_CHAR(TO_NUMBER(v_next_num) + 1 );
				v_next_trx_number := p_current_trx_number ;
				SELECT REPLACE(v_next_trx_number, v_last_num ,v_next_num) INTO v_next_trx_number FROM DUAL;					

			END IF;
		ELSE
			IF (v_last_num IS NULL) THEN
				v_next_trx_number := XXBS_AR_TRX_NUMBER_S.nextval  ||'-R1';
			ELSE 
				v_next_num := REGEXP_SUBSTR(v_last_num, '\d*$');
				v_next_num := '-R' || TO_CHAR(TO_NUMBER(v_next_num) + 1 );
				v_next_trx_number := XXBS_AR_TRX_NUMBER_S.nextval || v_next_num;

			END IF;
		END IF;
		RETURN v_next_trx_number;


	END get_revise_trx_number;


	FUNCTION get_gl_period
	(
	 p_trx_date IN DATE
	 ,p_set_of_books_id IN NUMBER	 
	) RETURN VARCHAR2
	IS
	v_gl_period varchar2(100);
	BEGIN
	select PERIOD_NAME into  v_gl_period
	from GL_PERIOD_STATUSES 
	where APPLICATION_ID in 
	(select FA.APPLICATION_ID from FND_APPLICATION FA where FA.APPLICATION_SHORT_NAME in ('AR'))
	AND TRUNC(START_DATE) <= TRUNC(p_trx_date)
	AND TRUNC(END_DATE) >= TRUNC(p_trx_date)
	AND SET_OF_BOOKS_ID = p_set_of_books_id
	AND CLOSING_STATUS = 'O';

	RETURN v_gl_period;
	END get_gl_period;
END XXBS_INVOICE_PKG;	


/
