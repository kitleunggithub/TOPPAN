--------------------------------------------------------
--  DDL for Package XXBS_TRX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXBS_TRX_PUB" as

/*******************************************************************************
 *
 * Module Name : Custom Billing
 * Package Name: XXBS_TRX_PUB
 *
 * Author      : DASH Kit Leung
 * Date        : 07-JAN-2020
 *
 * Purpose     : Custom Billing Transaction API
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung   07-JAN-2020   Initial Release.
 *
 *******************************************************************************/

    --Package constant used for package version validation
    G_API_VERSION_NUMBER    CONSTANT NUMBER := 1.0;

    TYPE bs_hdr_in_rec_type IS RECORD
    (AR_TRX_NUMBER              XXBS_CUSTOMER_TRX.AR_TRX_NUMBER%TYPE    := null
    ,ORG_ID                     XXBS_CUSTOMER_TRX.ORG_ID%TYPE    := null
    --,SET_OF_BOOKS_ID            XXBS_CUSTOMER_TRX.SET_OF_BOOKS_ID%TYPE    := null    
    ,PRIMARY_PRODUCT_TYPE_ID    XXBS_CUSTOMER_TRX.PRIMARY_PRODUCT_TYPE_ID%TYPE    := null
    --,PROFILE_ID                 XXBS_CUSTOMER_TRX.PROFILE_ID%TYPE    := null
    --,CUST_TRX_TYPE_ID           XXBS_CUSTOMER_TRX.CUST_TRX_TYPE_ID%TYPE    := null --get from ar_memo_lines_all_b.attribute2
    ,TRX_DATE                   XXBS_CUSTOMER_TRX.TRX_DATE%TYPE    := null
    ,DATE_RECEIVED              XXBS_CUSTOMER_TRX.DATE_RECEIVED%TYPE    := null
    ,PERIOD_NAME                XXBS_CUSTOMER_TRX.PERIOD_NAME%TYPE    := null
    ,DESCRIPTION                XXBS_CUSTOMER_TRX.DESCRIPTION%TYPE    := null
    ,COMMENTS                   XXBS_CUSTOMER_TRX.COMMENTS%TYPE    := null
    ,BILL_TO_ADDRESS_ID         XXBS_CUSTOMER_TRX.BILL_TO_ADDRESS_ID%TYPE    := null
    ,BILL_TO_CUSTOMER_ID        XXBS_CUSTOMER_TRX.BILL_TO_CUSTOMER_ID%TYPE    := null
    --,ATTENDEE                   XXBS_CUSTOMER_TRX.ATTENDEE%TYPE    := null
    ,BILL_TO_CONTACT_ID         XXBS_CUSTOMER_TRX.BILL_TO_CONTACT_ID%TYPE := null
    ,ATTENDEE_EMAIL             XXBS_CUSTOMER_TRX.ATTENDEE_EMAIL%TYPE    := null
    ,INVOICE_ADDRESS_ID         XXBS_CUSTOMER_TRX.INVOICE_ADDRESS_ID%TYPE    := null    
    ,ORDER_NUMBER               XXBS_CUSTOMER_TRX.ORDER_NUMBER%TYPE    := null
    ,CUSTOMER_ORDER_NUMBER      XXBS_CUSTOMER_TRX.CUSTOMER_ORDER_NUMBER%TYPE    := null
    ,OWNING_BILLER_ID           XXBS_CUSTOMER_TRX.OWNING_BILLER_ID%TYPE    := null
    ,ACTIVE_BILLER_ID           XXBS_CUSTOMER_TRX.ACTIVE_BILLER_ID%TYPE    := null
    --,CURRENT_STATUS_DATE        XXBS_CUSTOMER_TRX.CURRENT_STATUS_DATE%TYPE    := null
    ,TERM_ID                    XXBS_CUSTOMER_TRX.TERM_ID%TYPE    := null
    --,CURRENCY_CODE              XXBS_CUSTOMER_TRX.CURRENCY_CODE%TYPE    := null
    ,ENTERED_CURRENCY_CODE      XXBS_CUSTOMER_TRX.ENTERED_CURRENCY_CODE%TYPE    := null
    ,EXCHANGE_DATE              XXBS_CUSTOMER_TRX.EXCHANGE_DATE%TYPE    := null
    ,EXCHANGE_RATE              XXBS_CUSTOMER_TRX.EXCHANGE_RATE%TYPE    := null
    ,EXCHANGE_RATE_TYPE         XXBS_CUSTOMER_TRX.EXCHANGE_RATE_TYPE%TYPE    := null
    ,PROJECT_CATEGORY_ID        XXBS_CUSTOMER_TRX.PROJECT_CATEGORY_ID%TYPE    := null
    ,PRIMARY_PROJECT_ORG_ID     XXBS_CUSTOMER_TRX.PRIMARY_PROJECT_ORG_ID%TYPE    := null        
    ,ORIGINAL_PROJECT_ID        XXBS_CUSTOMER_TRX.ORIGINAL_PROJECT_ID%TYPE    := null
    ,SOURCE_SYSTEM              XXBS_CUSTOMER_TRX.SOURCE_SYSTEM%TYPE    := null 
    ,PROJECT_COMPLETE_DATE      XXBS_CUSTOMER_TRX.PROJECT_COMPLETE_DATE%TYPE    := null    
    ,COST_SUM_SEND_DATE         XXBS_CUSTOMER_TRX.COST_SUM_SEND_DATE%TYPE    := null 
    ,MARGIN_REPORT_SEND_DATE    XXBS_CUSTOMER_TRX.MARGIN_REPORT_SEND_DATE%TYPE    := null      
    ,BILL_REMARK                XXBS_CUSTOMER_TRX.BILL_REMARK%TYPE    := null
    ,INVOICE_CLASS              XXBS_CUSTOMER_TRX.INVOICE_CLASS%TYPE    := null
    ,CURRENT_STATUS             XXBS_CUSTOMER_TRX.CURRENT_STATUS%TYPE    := null
    ,INVOICE_STYLE_NAME         XXBS_CUSTOMER_TRX.INVOICE_STYLE_NAME%TYPE    := null
    );

    --Project record type that is used to pass data coming out of an API
    TYPE bs_hdr_out_rec_type IS RECORD
    (CUSTOMER_TRX_ID         XXBS_CUSTOMER_TRX.CUSTOMER_TRX_ID%TYPE    := null
     ,AR_TRX_NUMBER          XXBS_CUSTOMER_TRX.AR_TRX_NUMBER%TYPE      := null
     ,RETURN_STATUS          VARCHAR2(1) := null
    );

    -- the first one salesrep will be primary
    TYPE salerep_in_rec_type IS RECORD
    (CUSTOMER_TRX_ID         XXBS_REP_SPLITS.CUSTOMER_TRX_ID%TYPE      := null
    ,SALESREP_ID             XXBS_REP_SPLITS.SALESREP_ID%TYPE          := null
    ,SPLIT_PERCENTAGE        XXBS_REP_SPLITS.SPLIT_PERCENTAGE%TYPE     := null
    /*
    ,ADJUSTMENT              XXBS_REP_SPLITS.ADJUSTMENT%TYPE           := null
    ,SALESPERSON_TYPE        XXBS_REP_SPLITS.SALESPERSON_TYPE%TYPE     := null
    ,SEQUENCE_NUMBER         XXBS_REP_SPLITS.SEQUENCE_NUMBER%TYPE      := null
    */
    );    

    TYPE salerep_in_tbl_type IS TABLE OF salerep_in_rec_type
    INDEX BY BINARY_INTEGER;

    TYPE salerep_out_rec_type IS RECORD
    (REP_SPLIT_ID            XXBS_REP_SPLITS.REP_SPLIT_ID%TYPE      := null
     ,CUSTOMER_TRX_ID        XXBS_REP_SPLITS.SALESREP_ID%TYPE          := null
     ,RETURN_STATUS          VARCHAR2(1) := null
    );

    TYPE salerep_out_tbl_type IS TABLE OF salerep_out_rec_type
        INDEX BY BINARY_INTEGER;

    PROCEDURE create_bs_trx
    ( p_api_version_number      IN  NUMBER 
     ,p_commit                  IN  VARCHAR2    := FND_API.G_FALSE
     ,p_msg                    OUT  NOCOPY VARCHAR2
     ,p_return_status          OUT  NOCOPY VARCHAR2 
     ,p_bs_hdr_in               IN  bs_hdr_in_rec_type
     ,p_bs_hdr_out             OUT  NOCOPY  bs_hdr_out_rec_type
     ,p_salerep_in              IN  salerep_in_tbl_type
     ,p_salerep_out            OUT  NOCOPY  salerep_out_tbl_type
    );

end XXBS_TRX_PUB;

/
