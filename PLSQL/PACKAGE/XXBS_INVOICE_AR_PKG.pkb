--------------------------------------------------------
--  DDL for Package Body XXBS_INVOICE_AR_PKG
--------------------------------------------------------

create or replace PACKAGE BODY          "APPS"."XXBS_INVOICE_AR_PKG" AS


    PROCEDURE send_cb_to_ar
    ( p_customer_trx_id      IN  NUMBER 
     ,p_return_status           OUT VARCHAR2 
     ,p_msg                     OUT VARCHAR2
    ) IS
    
    
    v_ar_line_rec        RA_INTERFACE_LINES_ALL%ROWTYPE;
    v_ar_dist_rec        RA_INTERFACE_DISTRIBUTIONS_ALL%ROWTYPE;

    ar_exists EXCEPTION;
    gl_period_not_open EXCEPTION;
	cm_ref_not_found EXCEPTION;
	line_not_found EXCEPTION;

	v_line_count NUMBER(15) := 0;
	v_customer_trx_line_ref NUMBER := NULL;

    CURSOR v_line_cur(p_customer_trx_id IN NUMBER) IS
        select
             l.CUSTOMER_TRX_LINE_ID
             ,l.CUSTOMER_TRX_ID
             ,l.LINE_NUMBER
			 ,l.LINE_TYPE
             ,l.PROJECT_ID
             ,l.ORG_ID
             ,l.QUANTITY_SELL
             ,l.UNIT_SELL
             ,l.SELL_AMOUNT
             ,l.LONG_DESCRIPTION
			 ,l.PRODUCT_TYPE_ID
             ,h.ENTERED_CURRENCY_CODE
             ,h.CUST_TRX_TYPE_ID
             ,h.Period_Name
             ,h.BILL_TO_ADDRESS_ID
             ,h.BILL_TO_CUSTOMER_ID
             ,h.SET_OF_BOOKS_ID
             ,h.TERM_ID
             ,h.AR_TRX_NUMBER
             ,h.TRX_DATE
             ,h.EXCHANGE_RATE_TYPE
             ,h.EXCHANGE_RATE
             ,h.PRIMARY_PRODUCT_TYPE_ID
             ,h.ORIGINAL_PROJECT_ID 
             ,p.SEGMENT1 PROJECT_NUMBER
             ,p.LONG_NAME PROJECT_NAME			 
			 ,t.NAME CUST_TRX_TYPE_NAME
			 ,t.TYPE CUST_TRX_TYPE
			 ,l.REVISED_CUSTOMER_TRX_ID
			 ,l.REVISED_CUSTOMER_TRX_LINE_ID
			 ,rh.ORIGINAL_PROJECT_ID REVISED_ORIGINAL_PROJECT_ID
			 ,rp.SEGMENT1 REVISED_PROJECT_NUMBER
			 ,rh.AR_TRX_NUMBER REVISED_AR_TRX_NUMBER			 
             ,oh.AR_TRX_NUMBER ORIG_CUSTOMER_TRX_NUMBER			 
          from
             xxbs_customer_trx_lines l, xxbs_customer_trx h, pa_projects_all p, ra_cust_trx_types_all t, xxbs_customer_trx rh, xxbs_customer_trx_lines rl, pa_projects_all rp, xxbs_customer_trx oh
          where
            1=1
             --AND NVL(l.VOID_FLAG,'N') = 'N'
             --AND NVL(l.LATE_COST_FLAG,'N') = 'N'
             --AND NVL(l.ignore_flag, 'N') = 'N'
             --AND l.wo_reason_code IS NULL
             --AND NVL(xxcm_common.get_constant_value(c_blank_line),-99) <> l.inventory_item_id -- exclude 'blank' lines -- q2c 12/6/2017
             AND l.CUSTOMER_TRX_ID = h.CUSTOMER_TRX_ID  
             AND h.CUSTOMER_TRX_ID  =p_customer_trx_id
             AND h.ORIGINAL_PROJECT_ID = p.PROJECT_ID (+)
			 AND h.CUST_TRX_TYPE_ID = t.CUST_TRX_TYPE_ID (+)
			 AND h.REVISED_CUSTOMER_TRX_ID = rh.CUSTOMER_TRX_ID (+)
			 AND l.REVISED_CUSTOMER_TRX_ID = rl.CUSTOMER_TRX_ID (+)
			 AND l.REVISED_CUSTOMER_TRX_LINE_ID = rl.CUSTOMER_TRX_LINE_ID(+)
			 AND rh.ORIGINAL_PROJECT_ID = rp.PROJECT_ID (+)
			 AND l.ORIG_CUSTOMER_TRX_ID = oh.CUSTOMER_TRX_ID (+)
            --ORDER BY LINE_NUMBER;
			ORDER BY ORIG_CUSTOMER_TRX_NUMBER ASC NULLS FIRST, PROJECT_NAME, LINE_NUMBER, CUSTOMER_TRX_LINE_ID;

	BEGIN




        IF check_exists_in_ar(p_customer_trx_id) THEN
             RAISE ar_exists;
        END IF;
        
        v_line_count :=0;
        BEGIN
            select count(*)
            into v_line_count
            from xxbs_customer_trx_lines l, xxbs_customer_trx h, pa_projects_all p, ra_cust_trx_types_all t, xxbs_customer_trx rh, xxbs_customer_trx_lines rl, pa_projects_all rp, xxbs_customer_trx oh
            where
            1=1
            --AND NVL(l.VOID_FLAG,'N') = 'N'
            --AND NVL(l.LATE_COST_FLAG,'N') = 'N'
            --AND NVL(l.ignore_flag, 'N') = 'N'
            --AND l.wo_reason_code IS NULL
            --AND NVL(xxcm_common.get_constant_value(c_blank_line),-99) <> l.inventory_item_id -- exclude 'blank' lines -- q2c 12/6/2017
            AND l.CUSTOMER_TRX_ID = h.CUSTOMER_TRX_ID  
            AND h.CUSTOMER_TRX_ID  =p_customer_trx_id
            AND h.ORIGINAL_PROJECT_ID = p.PROJECT_ID (+)
            AND h.CUST_TRX_TYPE_ID = t.CUST_TRX_TYPE_ID (+)
            AND h.REVISED_CUSTOMER_TRX_ID = rh.CUSTOMER_TRX_ID (+)
            AND l.REVISED_CUSTOMER_TRX_ID = rl.CUSTOMER_TRX_ID (+)
            AND l.REVISED_CUSTOMER_TRX_LINE_ID = rl.CUSTOMER_TRX_LINE_ID(+)
            AND rh.ORIGINAL_PROJECT_ID = rp.PROJECT_ID (+)
            AND l.ORIG_CUSTOMER_TRX_ID = oh.CUSTOMER_TRX_ID (+);
        EXCEPTION WHEN OTHERS THEN
            v_line_count :=0;
        END;
        
   		IF (v_line_count = 0) THEN
			RAISE line_not_found;
		END IF;

        IF (NOT check_gl_period_open(p_customer_trx_id))  THEN
            RAISE gl_period_not_open;
        END IF;

		v_line_count :=0;

        FOR v_line_rec IN v_line_cur(p_customer_trx_id) LOOP

			v_line_count := v_line_count+1;

            --dbms_output.put_line( v_line_rec.CUSTOMER_TRX_LINE_ID);        

            v_ar_line_rec := NULL;
			v_customer_trx_line_ref:= NULL;

            v_ar_line_rec.INTERFACE_LINE_CONTEXT         := 'XXBS BILLING INVOICES';
            v_ar_line_rec.BATCH_SOURCE_NAME              := 'XXBS BILLING INVOICES';
            v_ar_line_rec.AMOUNT                         := v_line_rec.sell_amount;

            v_ar_line_rec.CONVERSION_RATE                := v_line_rec.EXCHANGE_RATE;
            v_ar_line_rec.CONVERSION_TYPE                := v_line_rec.EXCHANGE_RATE_TYPE;
            v_ar_line_rec.CURRENCY_CODE                  := v_line_rec.ENTERED_CURRENCY_CODE;
            v_ar_line_rec.CUST_TRX_TYPE_ID               := v_line_rec.cust_trx_type_id;
            v_ar_line_rec.DESCRIPTION                    := SUBSTRB(v_line_rec.long_description,1,240);
            v_ar_line_rec.GL_DATE                        := to_date(v_line_rec.PERIOD_NAME, 'MON-RR');

            v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE1      := v_line_rec.PROJECT_NUMBER;
            v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE2      := v_line_rec.ORIGINAL_PROJECT_ID;
            v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE3      := v_line_rec.CUSTOMER_TRX_ID;
            v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE4      := CASE WHEN (v_line_rec.CUST_TRX_TYPE = 'INV' AND v_line_rec.REVISED_CUSTOMER_TRX_ID IS NOT NULL)
                                                                  THEN v_line_rec.REVISED_AR_TRX_NUMBER
                                                                  ELSE NULL
															END;
            v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE5      := v_line_rec.customer_trx_line_id;
            v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE6      := v_line_rec.PROJECT_ID;
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE1      := p_trx_rec.customer_trx_id;
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE2      := v_line_rec.ar_trx_line_id;
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE13     := xxcm_common.get_constant_value('XXBS_AR_IN_COLLECTIONS');
              --v_ar_line_rec.INTERFACE_LINE_CONTEXT         := xxcm_common.get_constant_value('XXBS_AR_INTERFACE_CONTEXT');
              --v_ar_line_rec.LINE_TYPE                      := v_line_rec.ar_line_type;
            --v_ar_line_rec.LINE_TYPE                      := 'LINE';
			v_ar_line_rec.LINE_TYPE                      := CASE WHEN (v_line_rec.LINE_TYPE = 'Freight' OR v_line_rec.LINE_TYPE = 'Line' OR v_line_rec.LINE_TYPE = 'Postage' )
                                                                  THEN 'LINE'
                                                                    ELSE NULL
															END;
            v_ar_line_rec.ORG_ID                         := v_line_rec.ORG_ID;
            v_ar_line_rec.ORIG_SYSTEM_BILL_ADDRESS_ID    := v_line_rec.bill_to_address_id;
            v_ar_line_rec.ORIG_SYSTEM_BILL_CUSTOMER_ID   := v_line_rec.bill_to_customer_id;
              --v_ar_line_rec.ORIG_SYSTEM_SHIP_ADDRESS_ID    := v_line_rec.ship_to_address_id;
              --v_ar_line_rec.ORIG_SYSTEM_SHIP_CUSTOMER_ID   := v_line_rec.ship_to_customer_id;
              --v_ar_line_rec.PRIMARY_SALESREP_ID            := v_line_rec.primary_salesrep_id;
            v_ar_line_rec.SET_OF_BOOKS_ID                := v_line_rec.set_of_books_id;


			IF (v_line_rec.CUST_TRX_TYPE = 'CM') THEN 

				v_customer_trx_line_ref 				:= get_customer_trx_line_ref(v_line_rec.REVISED_CUSTOMER_TRX_ID ,v_line_rec.REVISED_CUSTOMER_TRX_LINE_ID);
				IF (v_customer_trx_line_ref IS NULL) THEN
					RAISE cm_ref_not_found;
				ELSE	
					v_ar_line_rec.REFERENCE_LINE_ID     := v_customer_trx_line_ref;			
					v_ar_line_rec.REFERENCE_LINE_CONTEXT := 'XXBS BILLING INVOICES';
				END IF;
			ELSE
				v_ar_line_rec.REFERENCE_LINE_ID  		:= NULL;
				v_ar_line_rec.REFERENCE_LINE_CONTEXT    := NULL;
			END IF;

			--v_ar_line_rec.REFERENCE_LINE_CONTEXT         := CASE WHEN v_line_rec.CUST_TRX_TYPE = 'CM'
            --                                                     THEN 'XXBS BILLING INVOICES'
            --                                                        ELSE NULL
			--												END;													
                --v_ar_line_rec.REFERENCE_LINE_ID              := CASE WHEN v_trx_type = 'CM'
                --                                                     THEN v_ref_rev_line_id--v_line_rec.reference_ar_trx_line_id
                --                                                     ELSE v_line_rec.pre_payment_id
                --                                                END;
                --v_ar_line_rec.REFERENCE_LINE_CONTEXT         := xxcm_common.get_constant_value('XXBS_AR_INTERFACE_CONTEXT');
            v_ar_line_rec.TERM_ID                        := CASE WHEN v_line_rec.CUST_TRX_TYPE = 'CM'
                                                                  THEN NULL
                                                                    ELSE v_line_rec.term_id
															END;
            v_ar_line_rec.TRX_NUMBER                     := v_line_rec.ar_trx_number;
            v_ar_line_rec.TRX_DATE                       := v_line_rec.trx_date;
              --v_ar_line_rec.UOM_CODE                       := v_line_rec.uom_code;
              --v_ar_line_rec.ATTRIBUTE1                     := v_line_rec.billing_line_type;
              --v_ar_line_rec.ATTRIBUTE2                     := v_line_rec.customer_trx_line_id;
              --v_ar_line_rec.ATTRIBUTE3                     := 'N';-- flag for indicating whether vertex enabled
              --v_ar_line_rec.MEMO_LINE_ID                   := CASE WHEN v_inventory_item_id IS NULL THEN v_memo_line_id ELSE NULL END;
            v_ar_line_rec.MEMO_LINE_ID                     :=v_line_rec.PRODUCT_TYPE_ID;
              --v_ar_line_rec.MEMO_LINE_NAME                 := CASE WHEN v_inventory_item_id IS NULL THEN v_memo_line_name ELSE NULL END;
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE3      := v_line_rec.foreign_system_number;
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE4      := v_line_rec.orig_ar_trx_number;
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE5      := nvl(p_trx_rec.late_fee,0);
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE10     := xxbs_common_pkg.get_original_trx(p_trx_rec.customer_trx_id); -- p_trx_rec.parent_orig_trx_number;
              --v_ar_line_rec.COMMENTS                       := substrb(v_orderedby_note,1,240);
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE6      := rtrim(substrb(p_trx_rec.job_number,1,30));
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE7      := rtrim(substrb(p_trx_rec.job_date,1,30));
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE8      := v_witness_name;
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE9      := rtrim(substrb(p_trx_rec.case_caption,1,30));
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE11     := rtrim(substrb(p_trx_rec.bill_to_contact_id,1,30));
              --v_ar_line_rec.INTERFACE_LINE_ATTRIBUTE12     := v_prepayment;
            v_ar_line_rec.LINE_NUMBER                       := v_line_rec.LINE_NUMBER;
            v_ar_line_rec.QUANTITY                       := v_line_rec.quantity_sell;
            v_ar_line_rec.QUANTITY_ORDERED               := v_line_rec.quantity_sell;
              --v_ar_line_rec.WAYBILL_NUMBER                 := v_waybill_number;
              --v_ar_line_rec.INVENTORY_ITEM_ID              := v_inventory_item_id;
              --v_ar_line_rec.taxable_flag   := 'N'; -- per Manoj 9/25/15 to keep AR from calc'ing tax.

              v_ar_line_rec.CREATED_BY                     := FND_GLOBAL.USER_ID;
              v_ar_line_rec.CREATION_DATE                  := SYSDATE;
              v_ar_line_rec.LAST_UPDATED_BY                := FND_GLOBAL.USER_ID;
              v_ar_line_rec.LAST_UPDATE_DATE               := SYSDATE;
              v_ar_line_rec.LAST_UPDATE_LOGIN              := FND_GLOBAL.LOGIN_ID;

              INSERT INTO ra_interface_lines_all VALUES v_ar_line_rec;      

        END LOOP; -- line rec

		IF (v_line_count = 0) THEN
			RAISE line_not_found;
		END IF;

        p_return_status:= 'S';
        p_msg:= NULL;

    EXCEPTION
        WHEN ar_exists THEN
            p_return_status:= 'W';
            p_msg:= p_customer_trx_id||' AR Transaction already exists';    
            dbms_output.put_line(p_msg);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_msg);
        WHEN line_not_found THEN
            p_return_status:= 'W';
            p_msg:= p_customer_trx_id||' AR Transaction has no line';    
            dbms_output.put_line(p_msg);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_msg);
        WHEN gl_period_not_open THEN
            p_return_status:= 'F';
            p_msg:= p_customer_trx_id||' AR Transaction GL Period Not Open';    
            dbms_output.put_line(p_msg);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_msg);
        WHEN cm_ref_not_found THEN
            p_return_status:= 'F';
            p_msg:= p_customer_trx_id||' Reference Invoice not found for credit memo';    
            dbms_output.put_line(p_msg);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_msg);
		WHEN OTHERS THEN
			p_return_status:= 'F';
            p_msg:= p_customer_trx_id|| ' '|| SUBSTR(SQLERRM, 1, 200);    
            dbms_output.put_line(p_msg);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_msg);			
	END send_cb_to_ar;

    FUNCTION check_exists_in_ar 
    (p_customer_trx_id IN NUMBER
    ) RETURN BOOLEAN
    IS
        v_count NUMBER := 0;

    BEGIN

        SELECT COUNT(*) INTO v_count
        FROM ra_customer_trx_all t
        ,    ra_batch_sources_all bs
        ,    xxbs_customer_trx cb
        WHERE 
        cb.customer_trx_id = p_customer_trx_id
        AND cb.ar_trx_number = t.trx_number 
        AND t.batch_source_id = bs.batch_source_id
        AND bs.name = 'XXBS BILLING INVOICES';

         IF v_count = 0 THEN
            SELECT COUNT(*) INTO v_count
            FROM ra_interface_lines_all t
            ,    xxbs_customer_trx cb
            WHERE 
            cb.customer_trx_id = p_customer_trx_id
            AND cb.ar_trx_number = t.trx_number
            AND t.batch_source_name = 'XXBS BILLING INVOICES';
         END IF;

         RETURN (v_count > 0);

    EXCEPTION WHEN OTHERS THEN
         RETURN FALSE;
    END check_exists_in_ar;

    FUNCTION check_gl_period_open
    (p_customer_trx_id IN NUMBER
    ) RETURN BOOLEAN 
    IS
       retval boolean := null;
       v_error_message varchar2(2000):= null;
       v_error_occurred EXCEPTION;
       v_period_closing_status gl_period_statuses.CLOSING_STATUS%type := null;
    begin

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
            return false;
        else
            return true;
        end if;
    end check_gl_period_open;


	FUNCTION get_customer_trx_line_ref
	(p_customer_trx_id IN NUMBER
	, p_customer_trx_line_id IN NUMBER
	)RETURN NUMBER
	IS
    v_customer_trx_line_id NUMBER;
	BEGIN
         SELECT customer_trx_line_id into v_customer_trx_line_id
         FROM ra_customer_trx_lines_all 
         WHERE interface_line_attribute3 = TO_CHAR(p_customer_trx_id)
         AND interface_line_attribute5 = TO_CHAR(p_customer_trx_line_id);
		 RETURN v_customer_trx_line_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_customer_trx_line_id := NULL;
		RETURN v_customer_trx_line_id;
	END get_customer_trx_line_ref;

END XXBS_INVOICE_AR_PKG;

/
