--------------------------------------------------------
--  File created - Wednesday-July-14-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package XXIBY_PAYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXIBY_PAYMENT_PKG" 
IS

/*******************************************************************************
 *
 * Module Name : Payables
 * Package Name: XXIBY_PAYMENT_PKG
 *
 * Author      : DASH Kit Leung
 * Date        : 30-JUN-2020
 *
 * Purpose     : Customization for validation and transfer of payment file 
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung   30-JUN-2021   Initial Release.
 *
 *******************************************************************************/

    PROCEDURE VALIDATE_PAYMENT
        ( p_payment_id                   IN VARCHAR2
        , p_error_code                   OUT NUMBER
        , p_error_msg                    OUT VARCHAR2        
        );

    PROCEDURE VALIDATION_MAIN
        ( p_errbuf                      OUT VARCHAR2
        , p_retcode                     OUT NUMBER
        , p_payment_method              IN VARCHAR2
        , p_payment_date                IN VARCHAR2
        , p_payment_process_request     IN VARCHAR2
        , p_specific_payment            IN VARCHAR2
        );
        
    PROCEDURE TRANSFER_MAIN
        ( p_errbuf                  OUT VARCHAR2
        , p_retcode                 OUT NUMBER
        , p_rerun                   IN VARCHAR2
        , p_payment_batch_id        IN VARCHAR2
        , p_payment_transfer_id     IN VARCHAR2
        , p_value_day               IN VARCHAR2        
        );        
END XXIBY_PAYMENT_PKG;

/
