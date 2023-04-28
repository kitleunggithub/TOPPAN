  CREATE OR REPLACE EDITIONABLE TRIGGER "APPS"."XXBS_CUSTOMER_TRX_TGR" AFTER INSERT OR UPDATE ON XXTM.XXBS_CUSTOMER_TRX
FOR EACH ROW
DECLARE
    v_msg VARCHAR2(100) :=null;
	v_old_value VARCHAR2(100) :=null;
	v_new_value VARCHAR2(100) :=null;
	v_customer_trx_id NUMBER; 
    --v_old_value VARCHAR2(100) :=null;
    --v_new_value VARCHAR2(100) :=null;
BEGIN

	IF (FND_GLOBAL.USER_ID IS NOT NULL) THEN
		IF (
			(:OLD.CURRENT_STATUS <> :NEW.CURRENT_STATUS)
            OR (:OLD.CURRENT_STATUS IS NULL AND :NEW.CURRENT_STATUS IS NOT NULL)
            OR (:OLD.CURRENT_STATUS IS NOT NULL AND :NEW.CURRENT_STATUS IS NULL)
		) THEN

            IF (:OLD.CUSTOMER_TRX_ID IS NOT NULL) THEN 
                v_customer_trx_id :=:OLD.CUSTOMER_TRX_ID;
            END IF;

            IF (:NEW.CUSTOMER_TRX_ID IS NOT NULL) THEN 
                v_customer_trx_id :=:NEW.CUSTOMER_TRX_ID;
            END IF;

			IF (:OLD.CURRENT_STATUS IS NOT NULL) THEN
				SELECT 
				ffvt.description into v_old_value
				FROM 
				fnd_flex_value_sets ffvs ,
				fnd_flex_values ffv ,
				fnd_flex_values_tl ffvt
				WHERE
				ffvs.flex_value_set_id = ffv.flex_value_set_id
				AND ffv.flex_value_id = ffvt.flex_value_id
				AND ffvt.language = 'US'
				AND flex_value_set_name = 'XXBS_INVOICE_STATUS'
				AND ffv.enabled_flag = 'Y'
				AND ffv.flex_value = :OLD.CURRENT_STATUS; 
			END IF;

			IF (:NEW.CURRENT_STATUS IS NOT NULL) THEN
				SELECT 
				ffvt.description into v_new_value
				FROM 
				fnd_flex_value_sets ffvs ,
				fnd_flex_values ffv ,
				fnd_flex_values_tl ffvt
				WHERE
				ffvs.flex_value_set_id = ffv.flex_value_set_id
				AND ffv.flex_value_id = ffvt.flex_value_id
				AND ffvt.language = 'US'
				AND flex_value_set_name = 'XXBS_INVOICE_STATUS'
				AND ffv.enabled_flag = 'Y'
				AND ffv.flex_value = :NEW.CURRENT_STATUS; 
			END IF;

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
            , v_customer_trx_id
            , SYSDATE
            , 'Change of Status'
            , FND_GLOBAL.USER_ID
            , v_old_value
            , v_new_value
            , NULL
            , NULL
            , NULL
            , FND_GLOBAL.USER_ID
            , SYSDATE
            , FND_GLOBAL.USER_ID
            , SYSDATE
            , FND_GLOBAL.LOGIN_ID
            );
        END IF;



		IF ((:OLD.ACTIVE_BILLER_ID <> :NEW.ACTIVE_BILLER_ID)
            OR (:OLD.ACTIVE_BILLER_ID IS NULL AND :NEW.ACTIVE_BILLER_ID IS NOT NULL)
            OR (:OLD.ACTIVE_BILLER_ID IS NOT NULL AND :NEW.ACTIVE_BILLER_ID IS NULL)		
		) THEN

			IF (:OLD.ACTIVE_BILLER_ID  IS NOT NULL) THEN
				SELECT i.description into v_old_value
				from fnd_user i
				where i.user_id = :OLD.ACTIVE_BILLER_ID;
			END IF;

			IF (:NEW.ACTIVE_BILLER_ID  IS NOT NULL) THEN
				SELECT i.description into v_new_value
				from fnd_user i
				where i.user_id = :NEW.ACTIVE_BILLER_ID;
			END IF;

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
            , :NEW.CUSTOMER_TRX_ID
            , SYSDATE
            , 'Change of Biller'
            , FND_GLOBAL.USER_ID
            , v_old_value
            , v_new_value
            , NULL
            , NULL
            , NULL
            , FND_GLOBAL.USER_ID
            , SYSDATE
            , FND_GLOBAL.USER_ID
            , SYSDATE
            , FND_GLOBAL.LOGIN_ID
            );

        END IF;


		IF ((:OLD.TOTAL_LINE_AMOUNT <> :NEW.TOTAL_LINE_AMOUNT)
            OR (:OLD.TOTAL_LINE_AMOUNT IS NULL AND :NEW.TOTAL_LINE_AMOUNT IS NOT NULL)
            OR (:OLD.TOTAL_LINE_AMOUNT IS NOT NULL AND :NEW.TOTAL_LINE_AMOUNT IS NULL)		
		) THEN

			IF (:OLD.TOTAL_LINE_AMOUNT  IS NOT NULL) THEN
				v_old_value:= TO_CHAR(:OLD.TOTAL_LINE_AMOUNT);
			ELSE
				v_old_value:= NULL;
			END IF;
			IF (:NEW.TOTAL_LINE_AMOUNT  IS NOT NULL) THEN
				v_new_value:= TO_CHAR(:NEW.TOTAL_LINE_AMOUNT);
			ELSE
				v_new_value:= NULL;
			END IF;			

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
            , :NEW.CUSTOMER_TRX_ID
            , SYSDATE
            , 'Change of invoice total amount'
            , FND_GLOBAL.USER_ID
            , v_old_value
            , v_new_value
            , NULL
            , NULL
            , NULL
            , FND_GLOBAL.USER_ID
            , SYSDATE
            , FND_GLOBAL.USER_ID
            , SYSDATE
            , FND_GLOBAL.LOGIN_ID
            );

        END IF;		

   END If;
--EXCEPTION
--exception_handling statements


END;
/
ALTER TRIGGER "APPS"."XXBS_CUSTOMER_TRX_TGR" ENABLE;