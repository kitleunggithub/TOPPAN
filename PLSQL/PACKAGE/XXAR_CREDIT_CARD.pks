--------------------------------------------------------
--  DDL for Package XXAR_CREDIT_CARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAR_CREDIT_CARD" 
/*************************************************************************
DESCRIPTION  This is the specification for the package to process
        credit card payments using CyberSource so we don't have to
        store the credit card numbers.  Detailed comments are in the
        file that contains the body, XXAR_CREDIT_CARD.pkb.
History:
03/10/2015 jzamow - Created package
04/10/2015 akaplan - Enh 1150 - Increase size of authtransactionid
**************************************************************************/
AS
  c_cc_flexset      CONSTANT VARCHAR2(40)  := xxcm_common.get_db_constant('CREDITCARD_VSET');

  PROCEDURE customer_email(p_ref_number xxar_creditcard_ref.reference_number%TYPE);
  PROCEDURE get_reference(p_reference_number      IN NUMBER
                         ,p_status               OUT VARCHAR2
                         ,p_phone_number         OUT VARCHAR2
                         ,p_currency             OUT VARCHAR2
                         ,p_payment_amount       OUT NUMBER
                         ,p_merchant_id          OUT VARCHAR2
                         ,p_profile_name         OUT VARCHAR2
                         ,p_profile_id           OUT VARCHAR2
                         ,p_key_name             OUT VARCHAR2
                         ,p_access_key           OUT VARCHAR2
                         ,p_security_key         OUT VARCHAR2);

  PROCEDURE load_trx(p_xml_message                   IN CLOB
                    ,p_response                      OUT VARCHAR2);


  PROCEDURE xxar_receipt_register (p_retcode             OUT NUMBER
                                  ,p_errbuf              OUT VARCHAR2
                                  ,p_gl_date_low         IN  VARCHAR2
                                  ,p_gl_date_high        IN  VARCHAR2
                                  ,p_chart_of_accounts_id IN NUMBER
                                  ,p_company_low         IN  VARCHAR2
                                  ,p_company_high        IN  VARCHAR2
                                  ,p_currency_code       IN  VARCHAR2
                                  ,p_receipt_number_low  IN  VARCHAR2
                                  ,p_receipt_number_high IN  VARCHAR2
                                  ,p_batch_name_low      IN  VARCHAR2
                                  ,p_batch_name_high     IN  VARCHAR2
                                  ,p_customer_name_low   IN  VARCHAR2
                                  ,p_customer_name_high  IN  VARCHAR2
                                  ,p_deposit_date_from   IN  VARCHAR2
                                  ,p_deposit_date_to     IN  VARCHAR2
                                  ,p_payment_method      IN  VARCHAR2
                                  ,p_bank_name           IN  VARCHAR2
                                  ,p_receipt_status_low  IN  VARCHAR2
                                  ,p_receipt_status_high IN  VARCHAR2
                                  ,p_receipt_type         IN VARCHAR2);

  TYPE response_rec_type IS RECORD
   (authamount                iby_trxn_summaries_all.amount%TYPE
   ,authavscode               iby_trxn_core.avscode%TYPE
   ,authavscoderaw            VARCHAR2(50)
   ,authcode                  iby_trxn_core.authcode%TYPE
   ,authcvresult              VARCHAR2(50)
   ,authcvresultraw           VARCHAR2(50)
   ,authresponse              VARCHAR2(50)
   ,authtime                  VARCHAR2(50)
   ,authtransactionid         iby_trxn_summaries_all.transactionid%TYPE
   ,decision                  cys_response.decision%TYPE
   ,message                   iby_trxn_summaries_all.bepmessage%TYPE
   ,paymenttoken              VARCHAR2(50)
   ,reasoncode                iby_trxn_summaries_all.bepcode%TYPE
   ,reqaccesskey              VARCHAR2(50)
   ,reqamount                 VARCHAR2(50)
   ,reqbilltosirname          VARCHAR2(50)
   ,reqbilltoforename         VARCHAR2(50)
   ,reqbilltoaddressline1     VARCHAR2(50)
   ,reqbilltoaddresscity      VARCHAR2(50)
   ,reqbilltoaddressstate     VARCHAR2(50)
   ,reqbilltoaddresspostal    VARCHAR2(50)
   ,reqbilltoaddresscountry   VARCHAR2(50)
   ,reqbilltoemail            VARCHAR2(50)
   ,reqcardtype               iby_trxn_core.instrname%TYPE
   ,reqcardnumber             VARCHAR2(50)
   ,reqcardexpirydate         VARCHAR2(50)
   ,reqcurrency               VARCHAR2(50)
   ,reqlocal                  VARCHAR2(50)
   ,reqpaymentmethod          VARCHAR2(50)
   ,reqprofileid              VARCHAR2(50)
   ,reqreferencenumber        xxar_creditcard_ref.reference_number%TYPE
   ,reqtransactiontype        VARCHAR2(50)
   ,reqtransactionuuid        VARCHAR2(50)
   ,requestToken              cys_response.request_token%TYPE
   ,response                  VARCHAR2(50)
   ,signature                 iby_trxn_summaries_all.instrnumber%TYPE
   ,signeddatetime            VARCHAR2(20)
   ,signedfieldnames          VARCHAR2(300)
   );

END xxar_credit_card;

/
