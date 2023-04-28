--------------------------------------------------------
--  DDL for Package Body XXAR_CREDIT_CARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAR_CREDIT_CARD" 
AS
---------------------------------------------------------------------------------------------
-- Package: XXAR_CREDITCARD_REF
-- Purpose: Creditcard Payment functions
--
-- Change History
-- Author      Date        Description
-- akaplan     11/18/14    Created
-- jzamow      02/05/15    Added load_trx procedure for the web service the Merrill payment
--                         site calls after a payment has been processed and added comments.
-- jzamow      03/09/15    Added status to web service for reference numbers already paid.
-- jzamow      04/09/15    Enh 1150: Changes for XXAR Receipt Register Report and insert into
--                         cys_request_item based on a new requirement from CyberSource.
-- jzamow      04/24/15    Bug fixes for XXAR Receipt Register Report.
-- akaplan     07/21/15    R12 Upgrade Project
--                           Request 280 - Process all currencies
--                           Request 289 - Process partial payments
--                           Enable multi-org for customer_email
-- akaplan     11/02/15      Modify to create Credit Card transaction
--                           Add iby_fndcpt_tx_operations insert when creating auth transaction
-- tringhand   12/01/15    Changed query in xxar_receipt_register to return LE name.
-- akaplan     02/16/16    Add remaining_balance to get_reference procedure
-- akaplan     03/07/16    Enh Req 1338: Partial Payments
-- akaplan     06/21/16    Enh Req 1540: Allow payments for non-functional currency
-- akaplan     11/28/16    Enh Req 1218: Close cursor breaking error handling
-- amishra/akaplan 04/05/2-16 ER 1780 - site use id and cursor close issue
-- akaplan     10/31/18    Enhance debugging for Oracle API calls
---------------------------------------------------------------------------------------------

  /*************************************************************************
  The customer_email procedure is called by the form that was created to
  pay credit cards using CyberSource.  The filename for the form is
  XXARCCARD.  The purpose of the procedure is to send an email to the
  customer, so the customer can click a link and pay by credit card.
  **************************************************************************/
   PROCEDURE customer_email(p_ref_number xxar_creditcard_ref.reference_number%TYPE
                           )
   IS
     c_blank_line      CONSTANT VARCHAR2(100) := '<TR><TD>&nbsp;</TD></TR>';
     c_instance        CONSTANT VARCHAR2(100) := xxcm_common.get_db;
     c_merrill_logo    CONSTANT VARCHAR2(100) := xxcm_common.get_constant_value('XXCM_MERRILL_LOGO');
     c_smtp_host       CONSTANT VARCHAR2(100) := xxcm_common.get_db_constant('SMTP_HOST');
     c_cc_pay_site     CONSTANT VARCHAR2(100) := xxcm_common.get_db_constant('CREDIT_CARD_PAY_SITE');
     c_override_bcc    CONSTANT VARCHAR2(100) := CASE WHEN xxcm_common.is_prod_db != 'Y'
                                                      THEN xxcm_common.get_db_constant('DEFAULT_EMAIL')
                                                 END;
     c_link            CONSTANT VARCHAR2(100) := c_cc_pay_site||'/index.aspx?Ref='||p_ref_number;
     CR                CONSTANT VARCHAR2(1)   := chr(10);

     l_days_to_expire           NUMBER;
     l_phone_number             VARCHAR2(50);
     l_sent_from                VARCHAR2(50);
     l_bcc_email                VARCHAR2(50);
     l_merchant_id              VARCHAR2(100);


     l_body                     VARCHAR2(32767);
     l_subject                  VARCHAR2(100);
     l_total_amount             NUMBER        := 0;
     l_total_remaining          NUMBER        := 0;
     l_total_payment            NUMBER        := 0;
     l_font                     VARCHAR2(100) := 'font-family: Arial, Helvetica, sans-serif; font-size: 10pt;';
     l_span                     VARCHAR2(100) := '<span style="'||l_font||'">';

     l_error                    VARCHAR2(100);

     CURSOR invoice_cur IS
         SELECT distinct cust.account_number  cust_num
              , party.party_name              cust_name
              , inv.invoice_currency_code
              , xref.org_id
              , xref.email_recipient          recipient
              , xref.trx_number
         FROM xxar_creditcard_ref xref
          JOIN ra_customer_trx_all inv on ( inv.trx_number = xref.trx_number
                                        AND inv.org_id = xref.org_id )
          JOIN hz_cust_accounts    cust on ( cust.cust_account_id = inv.bill_to_customer_id )
          JOIN hz_parties          party on ( party.party_id = cust.party_id )
         WHERE xref.reference_number = p_ref_number;

     CURSOR invoice_dtl_cur IS
         SELECT xref.trx_number
              , xref.original_total
              , xref.remaining_balance
              , xref.payment_amount
         FROM xxar_creditcard_ref xref
         WHERE xref.reference_number = p_ref_number;

     r_inv invoice_cur%ROWTYPE;

   BEGIN
     l_subject := 'Merrill Open Invoices - Credit Card Payment Request - Reference Number '||p_ref_number;

     OPEN invoice_cur;
     FETCH invoice_cur INTO r_inv;

     l_days_to_expire  := xxcm_common.get_dep_flex_value_field(r_inv.org_id, c_cc_flexset, r_inv.invoice_currency_code, 'DAYS_TO_EXPIRE');
     l_phone_number    := xxcm_common.get_dep_flex_value_field(r_inv.org_id, c_cc_flexset, r_inv.invoice_currency_code, 'PHONE_NUMBER');
     l_sent_from       := xxcm_common.get_dep_flex_value_field(r_inv.org_id, c_cc_flexset, r_inv.invoice_currency_code, 'SENT_FROM');
     l_bcc_email       := xxcm_common.get_dep_flex_value_field(r_inv.org_id, c_cc_flexset, r_inv.invoice_currency_code, 'BCC_ADDRESS');
     l_merchant_id     := xxcm_common.get_dep_flex_value_field(r_inv.org_id, c_cc_flexset, r_inv.invoice_currency_code, 'MERCHANT_ID');

     l_body := '<html xmlns="http://www.w3.org/1999/xhtml">
<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/></head>
<body style="font-family: Arial, Helvetica, sans-serif;">
<table width="600" border="0" cellpadding="0" style="font-family: Arial, Helvetica, sans-serif;">
  <tr bgcolor="#0076C0" >
    <td style="padding-bottom:10pt; padding-top:10pt">
      <img style="padding-right:120pt" src="'||c_cc_pay_site||'/'||c_merrill_logo||'" height="35" alt="Merrill Corporation" />
    </td>
  </tr>
  <tr align="center">
    <td>
      <table width="600" border="0" cellpadding="3">
        <tr>
          <td colspan="2" align="left"><h4 style="font-weight: bold; font-family: Arial, Helvetica, sans-serif; color: #717074; margin:0pt;">Credit Card Payment Request</h4></td>
        </tr>
        <tr>
          <td colspan="2"><p style="padding-top: 1pt; '||l_font||'">This email is in response to your request to process payment for the following invoices through a credit card:</p></td>
        </tr>
        <tr>
          <td width="150" align="left">'||l_span||'<strong>Customer Number:</strong></span></td>
          <td width="411" align="left">'||l_span|| r_inv.cust_num ||'</span></td>
        </tr>
        <tr>
          <td align="left">'||l_span||'<strong>Customer Name:</strong></span></td>
          <td align="left">'||l_span||replace(r_inv.cust_name,'&','&amp;')||'</span></td>
        </tr>
        <tr>
          <td align="left">'||l_span||'<strong>Reference Number: </strong></span></td>
          <td align="left">'||l_span||p_ref_number||'</span></td>
        </tr>
        <tr align="left">
          <td colspan="2">
            <table width="600" align="center" cellpadding="5">
              <tr bgcolor="#CCCCCC">
                <td width="160" align="center">'||l_span||'<strong>Invoice #</strong></span></td>
                <td width="180" align="right">'||l_span||'<strong>Original Amount</strong></span></td>
                <td width="165" align="right">'||l_span||'<strong>Balance Due</strong></span></td>
                <td width="165" align="right">'||l_span||'<strong>Payment Amount</strong></span></td>
                <td width="75" align="center">'||l_span||'<strong>Currency</strong></span></td>
              </tr>';

     FOR r_dtl IN invoice_dtl_cur LOOP

        l_total_amount := l_total_amount + r_dtl.original_total;
        l_total_remaining := l_total_remaining + r_dtl.remaining_balance;
        l_total_payment := l_total_payment + r_dtl.payment_amount;

        l_body := l_body
               ||'<tr><td align="center">'||l_span||r_dtl.trx_number||'</span></TD>'
               ||'    <td align="right">'||l_span||ltrim(to_char(r_dtl.original_total,'999,999,999.00'))||'</span></td>'
               ||'    <td align="right">'||l_span||ltrim(to_char(r_dtl.remaining_balance,'999,999,999.00'))||'</span></td>'
               ||'    <td align="right">'||l_span||ltrim(to_char(r_dtl.payment_amount,'999,999,999.00'))||'</span></td>'
               ||'    <td align="center">'||l_span||r_inv.invoice_currency_code||'</td></tr>'||CR;

     END LOOP;

     l_body := l_body || '
    <tr bgcolor="#CCCCCC">
      <td colspan="2" align="right">'||l_span||'<strong>Total</strong></span></td>
      <td align="right">'||l_span||ltrim(to_char(l_total_remaining,'999,999,999.00'))||'</span></td>
      <td align="right">'||l_span||ltrim(to_char(l_total_payment,'999,999,999.00'))||'</span></td>
      <td align="center">'||l_span||r_inv.invoice_currency_code||'</span></td></tr>
    </table>
    <tr align="left" bgcolor="#ffffff">
        <td colspan="4" style="padding:5px">'||l_span||'
            <p>Simply click the following link to access Merrill&#39;s payment processing center - <a href="'||c_link||'" target="_blank">'||c_cc_pay_site||'</a>.
            Please note that this reference number will expire in '||l_days_to_expire||' days.<br/><br/>
            If you require a new reference number please contact us at '||l_phone_number||'.</p>
            <p>Thank you.</p></span>
        </td>
    </tr>
  <tr align="left">
    <td colspan="4">
      <p style="'||l_font||'"><em style="font-size: 8pt">This is an auto-generated message. Replies to automated messages are not monitored.</em></p>
    </td>
  </tr>
  <tr align="left">
    <td colspan="4">
      <p style="'||l_font||'"><em style="font-size: 8pt">This e-mail may contain CONFIDENTIAL or LEGALLY PRIVILEGED information. If you are not the intended recipient, please notify Merrill at '||l_phone_number||' and delete this communication and any copy immediately.</em></p>
    </td>
  </tr>
</table>

</body>
</html>';
/*
      xxcm_email.sendmail( c_smtp_host
                          , l_sent_from
                          , r_inv.recipient
                          , NULL
                          , nvl(c_override_bcc, l_bcc_email)
                          -- If NOT using default email, tack on instance to subject
                          , l_subject || CASE WHEN xxcm_common.is_prod_db = 'N'
                                              THEN ' - TEST from '||c_instance
                                         END
                          , l_body
                          );
*/
      CLOSE invoice_cur;

   EXCEPTION
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20100,'Error generating New Customer Notification. '||dbms_utility.format_error_backtrace||'Location:'||l_error);
   END customer_email;


  /*************************************************************************
  The get_reference procedure is exposed as the web service
  server:port/Credit-Card-context-root/ValidateSoapHttpPort
  The purpose of the web service is to receive a reference number from a
  Merrill payment site and respond with whether the reference number is
  valid and can be paid by credit card.
  **************************************************************************/
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
                         ,p_security_key         OUT VARCHAR2)
  IS

     /* Need a cursor to get all transactions for the one reference number      */
     CURSOR ref_cur (p_ref_num NUMBER)
     IS
       SELECT inv.invoice_currency_code, inv.org_id, xref.paid_date
            , min(expiration_date) expiration_date
            , sum(nvl(payment_amount,0)) payment_amount
            , sum(nvl(remaining_balance,0)) remaining_balance
       FROM xxar_creditcard_ref xref
          JOIN ra_customer_trx_all inv on ( inv.trx_number = xref.trx_number
                                        AND inv.org_id = xref.org_id
                                        AND inv.batch_source_id = xref.batch_source_id )
       WHERE xref.reference_number = p_ref_num
       GROUP BY inv.invoice_currency_code, inv.org_id, xref.paid_date;

     ref_rec            ref_cur%rowtype;

     /* This is used for invalid reference numbers where the cursor above
        does not return any rows or there is an unknown error so we can
        look up a phone number                                               */
     default_org_id     number := 21;
     default_currency   VARCHAR2(3) := 'USD';

  BEGIN

     OPEN ref_cur(p_reference_number);
     FETCH ref_cur INTO ref_rec;
     CLOSE ref_cur;

     p_currency     := ref_rec.invoice_currency_code;

     p_phone_number := xxcm_common.get_dep_flex_value_field(ref_rec.org_id, c_cc_flexset, p_currency, 'PHONE_NUMBER');
     p_merchant_id  := xxcm_common.get_dep_flex_value_field(ref_rec.org_id, c_cc_flexset, p_currency, 'MERCHANT_ID');
     p_access_key   := xxcm_common.get_dep_flex_value_field(ref_rec.org_id, c_cc_flexset, p_currency, 'ACCESS_KEY');
     p_profile_name := xxcm_common.get_dep_flex_value_field(ref_rec.org_id, c_cc_flexset, p_currency, 'PROFILE_NAME');
     p_profile_id   := xxcm_common.get_dep_flex_value_field(ref_rec.org_id, c_cc_flexset, p_currency, 'PROFILE_ID');
     p_key_name     := xxcm_common.get_dep_flex_value_field(ref_rec.org_id, c_cc_flexset, p_currency, 'KEY_NAME');
     p_security_key := xxcm_common.get_dep_flex_value_field(ref_rec.org_id, c_cc_flexset, p_currency, 'SECURITY_KEY1')
                    || xxcm_common.get_dep_flex_value_field(ref_rec.org_id, c_cc_flexset, p_currency, 'SECURITY_KEY2');

     -- Default - Is this even valid anymore with multiple orgs/currencies?
     IF p_phone_number IS NULL THEN
        p_phone_number := xxcm_common.get_dep_flex_value_field(default_org_id, c_cc_flexset, default_currency, 'PHONE_NUMBER');
     END IF;

     -- Initialize values to 0
     p_payment_amount := 0;

     /* return P for paid                      */
     /* return I for inactive and A for active */
     /* only return amount if active           */
     IF (ref_rec.paid_date is not NULL) THEN
       p_status := 'P';
     ELSIF (sysdate > nvl(ref_rec.expiration_date,sysdate - 1)) THEN
       p_status := 'I';
     ELSE
       p_status := 'A';
       p_payment_amount := ref_rec.payment_amount;
     END IF;

  EXCEPTION
     WHEN OTHERS THEN
        p_status := 'I';
        p_phone_number := xxcm_common.get_dep_flex_value_field(nvl(ref_rec.org_id,default_org_id)
                                                              ,c_cc_flexset
                                                              ,nvl(p_currency,default_currency)
                                                              ,'PHONE_NUMBER');

  END get_reference;

  /*************************************************************************
  The load_trx procedure is exposed as the web service
  server:port/CreditTrx-Card-context-root/LoadCCSoapHttpPort
  The purpose of the web service is to take the information from the
  Merrill payment site and create a bank account and update the receivables
  transactions so that a receipt can be created by the concurrent program,
  Automatic Receipts Creation Program (SRS).
  **************************************************************************/
  PROCEDURE load_trx(p_xml_message      IN CLOB
                    ,p_response        OUT VARCHAR2)

  IS
   c_api_version  CONSTANT NUMBER := 1.0;
   ePackageErr             exception;
   l_xml_msg               sys.xmltype;
   l_namespace             VARCHAR2(256);
   l_source_instance       VARCHAR2(100);
   l_message_id            NUMBER;
   l_response_data         CLOB;
   l_parser                dbms_xmlparser.Parser;
   l_doc                   dbms_xmldom.DOMDocument;
   l_response_nl           dbms_xmldom.DOMNodeList;
   l_response_n            dbms_xmldom.DOMNode;
   r_xml_response          response_rec_type;
   l_ns                    VARCHAR2(100) := 'xmlns=http://finance/creditcard/v1';
   l_trx_number            ra_customer_trx.trx_number%TYPE;
   l_remit_bank_acct_id    NUMBER;
   l_bill_to_customer_id   ra_customer_trx_all.bill_to_customer_id%TYPE;
   l_bill_to_site_use_id   ra_customer_trx_all.bill_to_site_use_id%TYPE;
   l_inv_curr_code         ra_customer_trx_all.invoice_currency_code%TYPE;
   l_org_curr_code         gl_ledgers.currency_code%TYPE;
   l_org_id                ra_customer_trx_all.org_id%TYPE;
   l_receipt_method_id     ra_customer_trx_all.receipt_method_id%TYPE;
   l_expiry_date           DATE;
   l_error_msg             VARCHAR2(1000);
   l_error_app             XXCM_ERROR_LINES.application_name%TYPE := 'XXAR_CREDIT_CARD pkg';
   l_error_module          XXCM_ERROR_LINES.module_name%TYPE := 'load_trx';
   l_customer_name         hz_parties.party_name%TYPE;
   l_card_type             VARCHAR2(50);
   l_cash_receipt_id       NUMBER;

   -- New R12 upgrade variables
   l_party_id              NUMBER;
   l_response              IBY_FNDCPT_COMMON_PUB.Result_rec_type;
   l_return_status         VARCHAR2(10);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(2000);

   l_card_id               NUMBER;
   l_assign_id             NUMBER;

   r_creditcard            IBY_FNDCPT_SETUP_PUB.CreditCard_rec_type;
   r_payer                 IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
   r_assignment_attribs    IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
   r_instrument            IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;

   r_trxn_attribs          IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
   r_payee                 IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type;
   r_auth_attribs          IBY_FNDCPT_TRXN_PUB.AuthAttribs_rec_type;
   r_amt                   IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
   r_auth_result           IBY_FNDCPT_TRXN_PUB.AuthResult_rec_type;


   l_receipt               VARCHAR2(100);
   l_entity_id             NUMBER;
   l_customer_trx_id       RA_CUSTOMER_TRX.customer_trx_id%TYPE;

   /* Pick up all transactions for the reference number provided               */
   CURSOR invoice_cur (p_ref_number VARCHAR2) IS
     SELECT inv.customer_trx_id, inv.trx_number, inv.org_id, xref.payment_amount
     FROM xxar_creditcard_ref xref
       JOIN ra_customer_trx inv on ( inv.trx_number = xref.trx_number
                                 AND inv.org_id = xref.org_id
                                 AND inv.batch_source_id = xref.batch_source_id
                                   )
    WHERE xref.reference_number = p_ref_number;

   r_inv invoice_cur%ROWTYPE;

   FUNCTION get_response(p_field VARCHAR2, p_size NUMBER) RETURN VARCHAR2 IS
     l_outval VARCHAR2(500);
   BEGIN
     RETURN substr(dbms_xslprocessor.valueOf
                      (n => l_response_n
                      ,pattern => p_field||'/text()'
                      ,namespace => l_ns)
                  , 1, p_size);
   END get_response;

   PROCEDURE raise_if_error (p_response      IBY_FNDCPT_COMMON_PUB.Result_rec_type
                            ,p_error_msg     VARCHAR2
                            )
   IS
      l_new_msg VARCHAR2(2000);

      CURSOR c_msg (p_err VARCHAR2) IS
         SELECT message_name||':'||message_text
         FROM fnd_new_messages m
            JOIN fnd_application a on ( a.application_id = m.application_id )
         WHERE a.application_short_name = 'IBY'
           AND message_name = p_err;
   BEGIN
      IF p_response.result_code != 'SUCCESS' THEN

         -- Some non-printable characters were preventing entire message from displaying
         l_error_msg := l_error_msg || chr(10) || p_error_msg || ' [' || p_response.result_message || ']';
         raise NO_DATA_FOUND;

      END IF;
   END raise_if_error;

   PROCEDURE raise_if_error ( p_return_status VARCHAR2 )
   IS
      l_error BOOLEAN := FALSE;
   BEGIN
      IF l_return_status != 'S' THEN
         xxcm_common.put_line('Return stat:'||l_return_status||'('||fnd_msg_pub.count_msg||')->'||l_msg_data);
         IF (fnd_msg_pub.count_msg > 0)THEN
            l_error_msg := l_error_msg ||'[Return Status='|| l_return_status
                        ||', Msg Count='||fnd_msg_pub.count_msg||']'||chr(10)
                        || l_msg_data
                        || chr(10) || 'API Error(s): ';
--            xxcm_errors.log_error(
--                     p_application_name => l_error_app
--                    ,p_module_name     => l_error_module
--                    ,p_error_message   => substr(l_error_msg,1,500)
--                    ,p_commit_errors   => FALSE);
            FOR i IN 1..fnd_msg_pub.count_msg
            LOOP
               fnd_msg_pub.get
                  ( p_msg_index => i,
                    p_encoded => 'F',
                    p_data => l_msg_data,
                    p_msg_index_out => l_msg_count
                  );

               l_error_msg := l_error_msg
                           || substr(l_msg_data,1,200);

--               xxcm_errors.log_error (
--                     p_application_name => l_error_app
--                    ,p_module_name     => l_error_module
--                    ,p_error_message   => substr(l_msg_data, 1, 500)
--                    ,p_commit_errors   => FALSE);
               l_error := TRUE;
            END LOOP;
         END IF;
      END IF;

      IF l_error THEN
--         xxcm_errors.write_log;
         RAISE ePackageErr;
      END IF;
   END raise_if_error;

   PROCEDURE create_auth (pr_xml_response   response_rec_type
                         ,p_currency_code   VARCHAR2
                         ,p_org_id          NUMBER
                         ,p_card_type       VARCHAR2
                         ,p_assign_id       NUMBER
                         ,p_trxn_entity_id  NUMBER
                         )
   IS
      l_merchant_id           iby_bepkeys.key%TYPE;
      l_mtangibleid           iby_tangible.mtangibleid%TYPE;
      l_trxnmid               iby_trxn_core.trxnmid%TYPE;
      l_transactionid         iby_trxn_summaries_all.transactionid%TYPE;

      r_bepkeys               iby_bepkeys%ROWTYPE;
      r_payee                 iby_payee%ROWTYPE;
      r_routing               iby_routinginfo%ROWTYPE;
      r_iby_tangible          iby_tangible%ROWTYPE;

      l_auth_exists           NUMBER;

   BEGIN
      l_merchant_id := xxcm_common.get_dep_flex_value_field(p_org_id, c_cc_flexset, p_currency_code, 'MERCHANT_ID');

      select count(*)
        into l_auth_exists
      from iby_tangible
      where tangibleid = to_char(pr_xml_response.reqreferencenumber);

      IF l_auth_exists > 0
      THEN
         l_error_msg := 'Auth already exists for '||pr_xml_response.reqreferencenumber;
         raise TOO_MANY_ROWS;
      END IF;


      l_error_msg := 'Loading data from iby_bepkeys.';
      SELECT *
        INTO r_bepkeys
      FROM iby_bepkeys
      WHERE key = l_merchant_id;

      l_error_msg := 'Loading data from iby_payee.';
      SELECT *
        INTO r_payee
      FROM iby_payee
      WHERE name = l_merchant_id;

      l_error_msg := 'Loading data from iby_routinginfo.';
      SELECT *
        INTO r_routing
      FROM iby_routinginfo
      WHERE payeeid = l_merchant_id;

      l_error_msg := 'Loading data to iby_tangible.';
      INSERT INTO iby_tangible
        ( mtangibleid
        , tangibleid
        , amount
        , currencynamecode
        , issuedate
        , object_version_number
        , creation_date, created_by
        , last_update_date, last_updated_by
        , last_update_login
        )
      VALUES
        ( IBY_TANGIBLE_S.nextval
        , pr_xml_response.reqreferencenumber
        , pr_xml_response.authamount
        , p_currency_code
        , sysdate
        , r_bepkeys.object_version_number
        , sysdate, -1
        , sysdate, -1
        , -1
        ) RETURNING mtangibleid INTO l_mtangibleid;


      l_error_msg := 'Loading data to iby_trxn_summaries_all.';
      INSERT INTO iby_trxn_summaries_all
        (trxnmid
        ,transactionid
        ,tangibleid
        ,reqdate
        ,reqtype
        ,payeeid
        ,bepid
        ,mpayeeid
        ,ecappid
        ,org_id
        ,paymentmethodname
        ,mtangibleid
        ,amount
        ,instrnumber
        ,currencynamecode
        ,status
        ,trxntypeid
        ,bepcode
        ,bepmessage
        ,object_version_number
        ,updatedate
        ,last_update_date,last_updated_by
        ,creation_date,created_by
        ,last_update_login
        ,instrtype
        ,bepkey
        ,instrsubtype
        ,payerinstrid
        ,payerid
        )
      VALUES
        (
          IBY_TRXNSUMM_MID_S.nextval                       --TRXNMID
        , IBY_TRXNSUMM_TRXNID_S.nextval                    --TRANSACTIONID
        , pr_xml_response.reqreferencenumber                --TANGIBLEID
        -- authtime comes in GMT.  Need to convert to CST
        , cast( from_tz( cast( to_date( pr_xml_response.authtime
                                      , 'YYYY-MM-DD"T"HH24MISS') as timestamp ), 'GMT')
                at time zone 'US/Central' as date)
        , 'ORAPMTREQ'                                      -- reqtype
        , l_merchant_id                                    --PAYEEID
        , r_bepkeys.bepid                                  --BEPID
        , r_payee.mpayeeid                                 --MPAYEEID
        , r_payee.ecappid                                  --ECAPPID
        , p_org_id                                         --ORG_ID
        , r_routing.paymentmethodname                      --PAYMENTMETHODNAME
        , l_mtangibleid                                    --MTANGIBLEID
        , pr_xml_response.authamount                        --AMOUNT
        , pr_xml_response.signature                         --INSTRNUMBER
        , p_currency_code                                  --CURRENCYNAMECODE
        , 0                                                --STATUS (Successful)
        , 2                                                --TRXNTYPEID
        , pr_xml_response.reasonCode                        --BEPCODE
        , pr_xml_response.message                           --BEPMESSAGE
        , r_bepkeys.object_version_number                  --OBJECT_VERSION_NUMBER
        , sysdate
        , sysdate, -1
        , sysdate, -1
        , -1
        , IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_CREDITCARD    --INSTRTYPE
        , l_merchant_id                                    --BEPKEY
        , 'UNKNOWN'                                        --INSTRSUBTYPE
        , l_card_id                                        --payerinstrid
        , l_party_id                                       -- payerid
        ) RETURNING trxnmid, transactionid INTO l_trxnmid, l_transactionid;

      l_error_msg := 'Loading data to iby_trxn_core.';
      INSERT INTO iby_trxn_core
        ( trxnmid
        , authcode
        , instrname
        , authtype
        , avscode
        , referencecode
        , object_version_number
        , last_update_date, last_updated_by
        , creation_date, created_by
        , last_update_login
        )
      VALUES
        ( l_trxnmid
        , pr_xml_response.authCode
        , p_card_type
        , NULL -- currently only null values in table
        , pr_xml_response.authavscode
        , pr_xml_response.authtransactionid
        , r_bepkeys.object_version_number
        , sysdate, -1
        , sysdate, -1
        , -1
        );

        l_error_msg := 'Load IBY_FNDCPT_TX_OPERATIONS';
        INSERT INTO iby_fndcpt_tx_operations
          ( trxn_extension_id
          , transactionid
          , object_version_number
          , creation_date, created_by
          , last_update_date, last_updated_by, last_update_login
          )
        VALUES
          ( p_trxn_entity_id
          , l_transactionid
          , 1
          , sysdate, fnd_global.user_id
          , sysdate, fnd_global.user_id, fnd_global.user_id
          );

      l_error_msg := 'Loading data to cys_response.';
      INSERT into cys_response
        (order_id, transaction_id, action_id
        ,request_id
        ,reason_code
        ,decision
        ,auth_code, cv_code, reconciliation_id
        ,request_token
        ,trx_datetime)
      VALUES
        (pr_xml_response.reqReferenceNumber, NULL, 2 -- AUTHORIZED
        ,pr_xml_response.authTransactionId
        ,pr_xml_response.reasonCode
        ,pr_xml_response.decision
        ,pr_xml_response.authCode,NULL,NULL
        ,pr_xml_response.requestToken
        ,sysdate);


   END create_auth;

   BEGIN

     /* This first section of code parses the message provided to web service   */
     l_xml_msg := xmlType(p_xml_message);
     l_namespace := xmltype(p_xml_message).getNamespace();

     INSERT into xxar_creditcard_int_doc
         (doc_id, creditcard_file, creation_date)
     values
         (xxar_creditcard_int_doc_s.nextval, l_xml_msg, sysdate);

     COMMIT;

     IF l_namespace IS NOT NULL THEN
       l_namespace := 'xmlns=' || l_namespace;
     END IF;

     l_response_data := p_xml_message;
     l_parser := dbms_xmlparser.newParser;
     dbms_xmlparser.parseClob(l_parser, l_response_data);
     l_doc := dbms_xmlparser.getDocument(l_parser);

     l_response_nl := dbms_xslprocessor.selectNodes
             ( n => dbms_xmldom.makeNode(l_doc)
             , pattern =>'/CreditCardResponse'
             , namespace => l_ns);

     IF dbms_xmldom.getLength(l_response_nl) > 0 THEN
       l_response_n := dbms_xmldom.item(l_response_nl,0);

       r_xml_response.reqreferencenumber      := get_response('reqreferencenumber', 20);

       -- Get minimal information for making sure correct VSET can be selected for future error handling
       l_error_msg := 'Getting trx number based on ref#: '||r_xml_response.reqreferencenumber;
       select cc.trx_number, cc.org_id, l.currency_code
         into l_trx_number, l_org_id, l_org_curr_code
       from xxar_creditcard_ref cc
         JOIN hr_operating_units ou ON ( ou.organization_id = cc.org_id )
         JOIN gl_ledgers          l ON ( l.ledger_id = ou.set_of_books_id )
       where reference_number = r_xml_response.reqreferencenumber
         and rownum = 1;

       mo_global.set_policy_context('S',l_org_id);

       l_error_msg := 'Getting customer info [Org='||l_org_id||']: '||l_trx_number;
       /* Get information needed from transactions to create bank account         */
       SELECT distinct customer_trx_id, bill_to_customer_id, bill_to_site_use_id, invoice_currency_code
         into l_customer_trx_id, l_bill_to_customer_id, l_bill_to_site_use_id, l_inv_curr_code
       FROM ra_customer_trx inv
       WHERE trx_number = l_trx_number
         AND org_id = l_org_id;


       r_xml_response.authamount              := get_response('authamount',20);
       r_xml_response.authavscode             := get_response('authavscode', 80);
       r_xml_response.authavscoderaw          := get_response('authavscoderaw', 20);
       r_xml_response.authcode                := get_response('authcode', 80);
       r_xml_response.authcvresult            := get_response('authcvresult', 20);
       r_xml_response.authcvresultraw         := get_response('authcvresultraw', 20);
       r_xml_response.authresponse            := get_response('authresponse', 20);
       r_xml_response.authtime                := get_response('authtime', 17);
       r_xml_response.authtransactionid       := get_response('authtransactionid', 30);
       r_xml_response.decision                := get_response('decision', 20);
       r_xml_response.message                 := get_response('message', 255);
       r_xml_response.paymenttoken            := get_response('payment_token', 50);
       r_xml_response.reasoncode              := get_response('reasoncode', 40);
       r_xml_response.reqaccesskey            := get_response('reqaccesskey', 20);
       r_xml_response.reqamount               := get_response('reqamount', 20);
       r_xml_response.reqbilltosirname        := get_response('reqbilltosirname', 20);
       r_xml_response.reqbilltoforename       := get_response('reqbilltoforename', 20);
       r_xml_response.reqbilltoaddressline1   := get_response('reqbilltoaddressline1', 20);
       r_xml_response.reqbilltoaddresscity    := get_response('reqbilltoaddresscity', 20);
       r_xml_response.reqbilltoaddressstate   := get_response('reqbilltoaddressstate', 20);
       r_xml_response.reqbilltoaddresspostal  := get_response('reqbilltoaddresspostal', 20);
       r_xml_response.reqbilltoaddresscountry := get_response('reqbilltoaddresscountry', 20);
       r_xml_response.reqbilltoemail          := get_response('reqbilltoemail', 20);
       r_xml_response.reqcardtype             := get_response('reqcardtype', 80);
       r_xml_response.reqcardnumber           := get_response('reqcardnumber', 50);
       r_xml_response.reqcardexpirydate       := get_response('reqcardexpirydate', 7);
       r_xml_response.reqcurrency             := get_response('reqcurrency', 20);
       r_xml_response.reqlocal                := get_response('reqlocal', 20);
       r_xml_response.reqpaymentmethod        := get_response('reqpaymentmethod', 20);
       r_xml_response.reqprofileid            := get_response('reqprofileid', 20);
       r_xml_response.reqtransactiontype      := get_response('reqtransactiontype', 20);
       r_xml_response.reqtransactionuuid      := get_response('reqtransactionuuid', 20);
       r_xml_response.requestToken            := get_response('request_token', 256);
       r_xml_response.response                := get_response('response', 20);
       r_xml_response.signature               := get_response('signature', 60);
       r_xml_response.signeddatetime          := get_response('signeddatetime', 20);
       r_xml_response.signedfieldnames        := get_response('signedfieldnames', 20);

     END IF;

     IF (r_xml_response.decision = 'ACCEPT') THEN

       l_error_msg := 'Extracting cc expiration date: '||r_xml_response.reqcardexpirydate;
       /* Need to reformat the expiration date provided by CyberSource            */
       l_expiry_date := to_date(substr(r_xml_response.reqcardexpirydate,1,2) || '01' ||
                                  substr(r_xml_response.reqcardexpirydate,4,4),'MM/DD/YYYY');
       l_expiry_date := last_day(l_expiry_date);

       l_error_msg := 'Getting account info: '||l_bill_to_customer_id;
       SELECT hp.party_name,hca.party_id
         into l_customer_name,l_party_id
       FROM hz_cust_accounts hca
         JOIN hz_parties hp on ( hp.party_id = hca.party_id )
       WHERE hca.cust_account_id = l_bill_to_customer_id;

       l_card_type := xxcm_common.get_flex_value_field('XXAR_CREDITCARD_TYPE'
                                                      ,r_xml_response.reqcardtype
                                                      ,'PAYMENT_METHOD');

       -- Create credit card
       l_error_msg := 'Creating Credit Card ['||r_creditcard.Card_Issuer||']:'||r_creditcard.card_number;
       r_creditcard.Owner_Id              := l_party_id;
       r_creditcard.Card_Holder_Name      := l_customer_name;
       r_creditcard.Billing_Address_Id    := NULL;
       r_creditcard.Card_Number           := r_xml_response.paymenttoken;
       r_creditcard.Expiration_Date       := l_expiry_date;
       r_creditcard.Instrument_Type       := IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_CREDITCARD;
       r_creditcard.PurchaseCard_Flag     := 'N';
       r_creditcard.Card_Issuer           := xxcm_common.get_flex_value_field('XXAR_CREDITCARD_TYPE',r_xml_response.reqcardtype);
       r_creditcard.Single_Use_Flag       := 'N';
       r_creditcard.Info_Only_Flag        := 'N';
       r_creditcard.Card_Purpose          := 'N';
       r_creditcard.Card_Description      := l_customer_name || ' '
                                          || l_card_type || ' '
                                          || r_xml_response.reqreferencenumber;
       r_creditcard.Active_Flag           := 'Y';
       r_creditcard.register_invalid_card := 'Y';

       IBY_FNDCPT_SETUP_PUB.Create_Card (
                 p_api_version     => c_api_version,
                 x_return_status   => l_return_status,
                 x_msg_count       => l_msg_count,
                 x_msg_data        => l_msg_data,
                 p_card_instrument => r_creditcard,
                 x_card_id         => l_card_id ,
                 x_response        => l_response,
                 p_init_msg_list   => FND_API.G_TRUE
       );

       raise_if_error(l_response, l_error_msg);
--xxcm_common.write_log(l_error_msg);

       -- Assign Payer
       l_error_msg := 'Assigning payer to credit card ['|| l_customer_name || '] [' || l_card_type ||']';
       r_payer.payment_function        := 'CUSTOMER_PAYMENT';
       r_payer.party_id                := l_party_id;
       r_payer.org_type                := 'OPERATING_UNIT';
       r_payer.org_id                  := l_org_id;
       r_payer.cust_account_id         := l_bill_to_customer_id;
       r_payer.account_site_id         := l_bill_to_site_use_id;
       r_instrument.instrument_type    := r_creditcard.Instrument_Type;
       r_instrument.instrument_id      := l_card_id;
       r_assignment_attribs.instrument := r_instrument;
       r_assignment_attribs.priority   := 1;
       r_assignment_attribs.start_date := SYSDATE;
       r_assignment_attribs.end_date   := l_expiry_date;

       IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment(
                                                        p_api_version        => c_api_version
                                                      , p_init_msg_list      => fnd_api.g_true
                                                      , p_commit             => fnd_api.g_false
                                                      , x_return_status      => l_return_status
                                                      , x_msg_count          => l_msg_count
                                                      , x_msg_data           => l_msg_data
                                                      , p_payer              => r_payer
                                                      , p_assignment_attribs => r_assignment_attribs
                                                      , x_assign_id          => l_assign_id
                                                      , x_response           => l_response
                                                      );

       raise_if_error(l_response, l_error_msg);

       -- Create Extension
       l_error_msg := 'Getting extension for trx='||l_trx_number||', assign_id:'||l_assign_id;
--       xxcm_common.write_log(l_error_msg);
       select max(trxn_extension_id)
         into l_entity_id
       from  iby_fndcpt_tx_extensions
       where order_id =  l_trx_number;

       l_receipt := 'CC'||r_xml_response.reqreferencenumber;
       IF l_entity_id IS NULL THEN
          l_error_msg := 'Creating extension for trx='||l_trx_number||', assign_id:'||l_assign_id;
          r_trxn_attribs.Originating_Application_Id := arp_standard.application_id;
          r_trxn_attribs.order_id := r_xml_response.reqreferencenumber;
          r_trxn_attribs.trxn_ref_number1 := 'RECEIPT';
          r_trxn_attribs.trxn_ref_number2 := l_receipt;


          IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension(
                                                            p_api_version        => c_api_version
                                                           ,p_init_msg_list      => fnd_api.g_true
                                                           ,p_commit             => fnd_api.g_false
                                                           ,x_return_status      => l_return_status
                                                           ,x_msg_count          => l_msg_count
                                                           ,x_msg_data           => l_msg_data
                                                           ,p_payer              => r_payer
                                                           ,p_pmt_channel        => 'CREDIT_CARD'
                                                           ,p_instr_assignment   => l_assign_id
                                                           ,p_trxn_attribs       => r_trxn_attribs
                                                           ,x_entity_id          => l_entity_id
                                                           ,x_response           => l_response
                                                           );
          raise_if_error(l_response, l_error_msg);

       END IF;

       create_auth(r_xml_response
                  ,l_inv_curr_code
                  ,l_org_id
                  ,l_card_type
                  ,l_assign_id
                  ,l_entity_id
                  );

       l_error_msg := 'Getting receipt method/Remit Bank: [org='||l_org_id||'] [method='||l_card_type||'] [currency='||l_inv_curr_code||']';

       select rma.receipt_method_id, bau.bank_acct_use_id
         into l_receipt_method_id, l_remit_bank_acct_id
       from ar_receipt_methods rm
          JOIN ar_receipt_method_accounts rma ON ( rma.receipt_method_id = rm.receipt_method_id )
          JOIN ce_bank_acct_uses          bau ON ( bau.bank_acct_use_id = rma.remit_bank_acct_use_id )
          JOIN ce_bank_accounts            ba ON ( ba.bank_account_id = bau.bank_account_id )
       where (sysdate between rma.start_date and rma.end_date or rma.end_date is null)
         and rma.org_id = l_org_id
         and ba.currency_code = l_inv_curr_code
         and rm.name = l_card_type;

       l_error_msg := 'Create_Cash API';
       ar_receipt_api_pub.Create_cash( p_api_version                => 1
                                     , x_return_status              => l_return_status
                                     , x_msg_count                  => l_msg_count
                                     , x_msg_data                   => l_msg_data
                                     , p_currency_code              => l_inv_curr_code
                                     , p_amount                     => r_xml_response.authamount
                                     , p_customer_id                => l_bill_to_customer_id
                                     , p_customer_site_use_id       => l_bill_to_site_use_id
                                     , p_receipt_method_id          => l_receipt_method_id
                                     , p_remittance_bank_account_id => l_remit_bank_acct_id
                                     , p_exchange_rate_type         => CASE
                                                                         -- Only use currency conversion rate type
                                                                         -- if invoice currency differs from org currency
                                                                         WHEN l_org_curr_code != l_inv_curr_code
                                                                         THEN xxcm_common.get_constant_value('XXGL_RATE_CONVERSION_TYPE')
                                                                       END
                                     , p_payment_trxn_extension_id  => l_entity_id
                                     , p_called_from                => 'CC_LOAD_TRX'
                                     , p_receipt_number             => l_receipt
                                     , p_cr_id                      => l_cash_receipt_id
                                     );
       raise_if_error(l_return_status);

       l_error_msg := 'Get Invoices '||r_xml_response.reqreferencenumber;
       /* Update all transactions                                                 */
       OPEN invoice_cur (r_xml_response.reqreferencenumber);
       LOOP
         FETCH invoice_cur into r_inv;
         EXIT WHEN invoice_cur%NOTFOUND;

         l_error_msg := 'ar_receipt_api_pub.apply: '||r_xml_response.reqreferencenumber
                     || chr(10) || 'Receipt:'||l_receipt
                     || chr(10) || 'Invoice:' ||r_inv.customer_trx_id;
         ar_receipt_api_pub.apply( p_api_version               => 1
                                 , x_return_status             => l_return_status
                                 , x_msg_count                 => l_msg_count
                                 , x_msg_data                  => l_msg_data
                                 , p_cash_receipt_id           => l_cash_receipt_id
                                 , p_customer_trx_id           => r_inv.customer_trx_id
                                 , p_amount_applied            => r_inv.payment_amount
                                 , p_called_from               => 'CC_LOAD_TRX'
                                 );

         raise_if_error(l_return_status);

       END LOOP;
       CLOSE invoice_cur;

       /* Update the credit card reference table used by the Credit Card Payment
          form                                                                    */
       UPDATE xxar_creditcard_ref
       SET paid_date = sysdate
       WHERE reference_number = r_xml_response.reqreferencenumber;

     END IF;

     p_response := 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF invoice_cur%ISOPEN THEN
        close invoice_cur;
      END IF;
      l_error_msg := l_error_msg || chr(10) || 'Invoices affected:';
      FOR rInv IN invoice_cur (r_xml_response.reqreferencenumber) LOOP
         l_error_msg := l_error_msg || chr(10) || rInv.trx_Number ;
      END LOOP;
      dbms_output.put_line('Error: '||l_error_msg);
      xxcm_common.put_line(SQLERRM,'N');
      p_response := 'FAILED TO LOAD';

      xxcm_common.put_line('Org:'||l_org_id||chr(10)||',VSET:'||c_cc_flexset||',CURR:'||l_inv_curr_code);
      xxcm_common.put_line('Recipient'||xxcm_common.get_dep_flex_value_field(l_org_id
                                                                                   ,c_cc_flexset
                                                                                   ,l_inv_curr_code
                                                                                   ,'BCC_ADDRESS'));
      xxcm_common.put_line(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

/*
      xxcm_email.sendmail(p_smtpserver_name => xxcm_common.get_db_constant('SMTP_HOST')
                         ,p_sender          => xxcm_common.get_dep_flex_value_field(l_org_id
                                                                                   ,c_cc_flexset
                                                                                   ,l_inv_curr_code
                                                                                   ,'SENT_FROM')
                         ,p_recipient       => xxcm_common.get_dep_flex_value_field(l_org_id
                                                                                   ,c_cc_flexset
                                                                                   ,l_inv_curr_code
                                                                                   ,'BCC_ADDRESS')
                         ,p_cc_recipient    => NULL
                         ,p_bcc_recipient   => NULL
                         ,p_subject         => 'Cybersource ERROR for '||xxcm_common.get_db
                                            || ' Reference: '||r_xml_response.reqreferencenumber
                         ,p_body            => 'Error: '||l_error_msg||'<BR>'||SQLERRM||'<BR>'||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                         );
*/
/*
      -- This API puts the error into the tables xxcm_error_groups and xxcm_error_lines
      xxcm_errors.log_error (
             p_application_name => l_error_app
            ,p_module_name     => l_error_module
            ,p_error_message   => substr(l_error_msg || chr(10) || SQLERRM, 1, 200)
            ,p_commit_errors   => TRUE);
*/            
  END load_trx;

  /*************************************************************************
  The xxar_receipt_register procedure is called by the XXAR Receipt
  Register Report.  This was a new report written for the credit card
  project.
  **************************************************************************/
  PROCEDURE xxar_receipt_register (p_retcode             OUT NUMBER
                                  ,p_errbuf              OUT VARCHAR2
                                  ,p_gl_date_low          IN VARCHAR2
                                  ,p_gl_date_high         IN VARCHAR2
                                  ,p_chart_of_accounts_id IN NUMBER
                                  ,p_company_low          IN VARCHAR2
                                  ,p_company_high         IN VARCHAR2
                                  ,p_currency_code        IN VARCHAR2
                                  ,p_receipt_number_low   IN VARCHAR2
                                  ,p_receipt_number_high  IN VARCHAR2
                                  ,p_batch_name_low       IN VARCHAR2
                                  ,p_batch_name_high      IN VARCHAR2
                                  ,p_customer_name_low    IN VARCHAR2
                                  ,p_customer_name_high   IN VARCHAR2
                                  ,p_deposit_date_from    IN VARCHAR2
                                  ,p_deposit_date_to      IN VARCHAR2
                                  ,p_payment_method       IN VARCHAR2
                                  ,p_bank_name            IN VARCHAR2
                                  ,p_receipt_status_low   IN VARCHAR2
                                  ,p_receipt_status_high  IN VARCHAR2
                                  ,p_receipt_type         IN VARCHAR2
                                  )
  IS

  l_query                VARCHAR2(32767);
  l_select1              VARCHAR2(8000);
  l_where1               VARCHAR2(8000);
  l_group_by             VARCHAR2(4000);
  l_order_by             VARCHAR2(4000);
  qryCtx                 DBMS_XMLGEN.ctxHandle;
  result                 CLOB;

BEGIN

   xxcm_bi_reporting_pub.pl('-- Begin XXAR Receipt Register Report --');
   xxcm_bi_reporting_pub.pl('Input Parameters:  ');
   xxcm_bi_reporting_pub.pl('    GL Date Low             = ' || p_gl_date_low);
   xxcm_bi_reporting_pub.pl('    GL Date High            = ' || p_gl_date_high);
   xxcm_bi_reporting_pub.pl('    Company Low             = ' || p_company_low);
   xxcm_bi_reporting_pub.pl('    Company High            = ' || p_company_high);
   xxcm_bi_reporting_pub.pl('    Receipt Currency        = ' || p_currency_code);
   xxcm_bi_reporting_pub.pl('    Receipt Number Low      = ' || p_receipt_number_low);
   xxcm_bi_reporting_pub.pl('    Receipt Number High     = ' || p_receipt_number_high);
   xxcm_bi_reporting_pub.pl('    Batch Name Low          = ' || p_batch_name_low);
   xxcm_bi_reporting_pub.pl('    Batch Name High         = ' || p_batch_name_high);
   xxcm_bi_reporting_pub.pl('    Customer Name Low       = ' || p_customer_name_low);
   xxcm_bi_reporting_pub.pl('    Customer Name High      = ' || p_customer_name_high);
   xxcm_bi_reporting_pub.pl('    Deposit Date From       = ' || p_deposit_date_from);
   xxcm_bi_reporting_pub.pl('    Deposit Date To         = ' || p_deposit_date_to);
   xxcm_bi_reporting_pub.pl('    Payment Method          = ' || p_payment_method);
   xxcm_bi_reporting_pub.pl('    Bank Name               = ' || p_bank_name);
   xxcm_bi_reporting_pub.pl('    Receipt Status Low      = ' || p_receipt_status_low);
   xxcm_bi_reporting_pub.pl('    Receipt Status High     = ' || p_receipt_status_high);
   xxcm_bi_reporting_pub.pl('    Receipt Type            = ' || p_receipt_type);

   l_select1 :=
      'select decode(crh.status, ''REVERSED'', batchfirst.name, batch.name) batch_name,
       FV.DESCRIPTION segment1,
       arm.name method_name, cr.deposit_date,
       party.party_name, cust.account_number, cr.receipt_number || ''  '' receipt_number, cr.receipt_date,
       decode(cr.status,''APP'',''Applied'',''UNAPP'',''Unapplied'',''UNID'',''Unidentified'',''NSF'',''Non-sufficient funds'',''REV'',decode(crh.status,''CLEARED'',''Applied'',''Reversed''),''STOP'',''Stopped'',NULL) receipt_status,
       crh.gl_date, decode(crh.status,''REVERSED'',-1*crh.amount, crh.amount) entered_amount,
       decode(crh.status,''REVERSED'',-1*crh.acctd_amount, crh.acctd_amount) acctd_amount,
       DECODE(cr.type,''CASH'',''Standard'',''MISC'',''Miscellaneous'') receipt_type
       from
         AR_CASH_RECEIPTS CR,
         FND_DOCUMENT_SEQUENCES DOCSEQ,
         ZX_RATES_B TAX,
         CE_BANK_ACCOUNTS ABA,
         CE_BANK_ACCT_USES ABB,
         AR_RECEIPT_METHODS ARM,
         AR_CASH_RECEIPT_HISTORY CRH,
         GL_CODE_COMBINATIONS CC,
         HZ_CUST_ACCOUNTS_ALL CUST,
         HZ_PARTIES PARTY,
         AR_BATCHES BATCH,
         AR_CASH_RECEIPT_HISTORY CRHFIRST,
         AR_BATCHES BATCHFIRST,
         FND_FLEX_VALUE_SETS FS,
         FND_FLEX_VALUES_VL FV
     ';

   l_where1 :=
       'WHERE CR.CASH_RECEIPT_ID = CRHFIRST.CASH_RECEIPT_ID
          AND CRHFIRST.FIRST_POSTED_RECORD_FLAG = ''Y''
     AND CRHFIRST.BATCH_ID = BATCHFIRST.BATCH_ID(+)
     AND CRH.BATCH_ID = BATCH.BATCH_ID(+)
     AND CR.DOC_SEQUENCE_ID = DOCSEQ.DOC_SEQUENCE_ID(+)
     AND CR.VAT_TAX_ID = TAX.TAX_RATE_ID(+)
     AND ABA.BANK_ACCOUNT_ID = ABB.BANK_ACCOUNT_ID
     AND CR.REMIT_BANK_ACCT_USE_ID = ABB.BANK_ACCT_USE_ID
     AND CR.RECEIPT_METHOD_ID = ARM.RECEIPT_METHOD_ID
     AND CR.CASH_RECEIPT_ID = CRH.CASH_RECEIPT_ID
     AND CC.CODE_COMBINATION_ID = CRH.ACCOUNT_CODE_COMBINATION_ID
     AND CC.SEGMENT1 = FV.FLEX_VALUE
     AND FV.FLEX_VALUE_SET_ID = FS.FLEX_VALUE_SET_ID
     AND FS.FLEX_VALUE_SET_NAME LIKE ''XXGL_LEGAL_ENTITY''
     AND CR.PAY_FROM_CUSTOMER = CUST.CUST_ACCOUNT_ID(+)
     AND CUST.PARTY_ID = PARTY.PARTY_ID(+)
     AND ((CRH.CURRENT_RECORD_FLAG = ''Y'' AND CRH.STATUS = ''REVERSED'' )
       OR (CRH.CASH_RECEIPT_HISTORY_ID IN (
           SELECT MAX(INCRH.CASH_RECEIPT_HISTORY_ID)
           FROM AR_CASH_RECEIPT_HISTORY_ALL INCRH
      WHERE INCRH.CASH_RECEIPT_ID = CRH.CASH_RECEIPT_ID
             AND INCRH.STATUS <> ''REVERSED''
      )))
     ';

    IF (p_gl_date_low IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND crh.gl_date >= TO_DATE(:P_GL_DATE_LOW,''YYYY/MM/DD HH24:MI:SS'') ';
    END IF;

    IF (p_gl_date_high IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND crh.gl_date <= TO_DATE(:P_GL_DATE_HIGH,''YYYY/MM/DD HH24:MI:SS'') ';
    END IF;

    IF (p_currency_code IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND cr.currency_code = :P_CURRENCY_CODE ';
    END IF;

    IF (p_receipt_number_low IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND cr.receipt_number >= :P_RECEIPT_NUMBER_LOW ';
    END IF;

    IF (p_receipt_number_high IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND cr.receipt_number <= :P_RECEIPT_NUMBER_HIGH ';
    END IF;

    IF (p_batch_name_low IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND decode(crh.status, ''REVERSED'', batchfirst.name, batch.name) >= :P_BATCH_NAME_LOW ';
    END IF;

    IF (p_batch_name_high IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND decode(crh.status, ''REVERSED'', batchfirst.name, batch.name) <= :P_BATCH_NAME_HIGH ';
    END IF;

    IF (p_customer_name_low IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND party.party_name >= :P_CUSTOMER_NAME_LOW ';
    END IF;

    IF (p_customer_name_high IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND party.party_name <= :P_CUSTOMER_NAME_HIGH ';
    END IF;

    IF (p_deposit_date_from IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND cr.receipt_date >= TO_DATE(:P_DEPOSIT_DATE_FROM,''YYYY/MM/DD HH24:MI:SS'') ';
    END IF;

    IF (p_deposit_date_to IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND cr.receipt_date <= TO_DATE(:P_DEPOSIT_DATE_TO,''YYYY/MM/DD HH24:MI:SS'') ';
    END IF;

    IF (p_payment_method IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND arm.name = :P_PAYMENT_METHOD ';
    END IF;

    IF (p_receipt_status_low IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND cr.status >= :P_RECEIPT_STATUS_LOW ';
    END IF;

    IF (p_receipt_status_high IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND cr.status <= :P_RECEIPT_STATUS_HIGH ';
    END IF;

    IF (p_company_low IS NOT NULL) THEN
      --l_where1 := l_where1 ||' AND cc.segment5 >= :P_COMPANY_LOW '; --Commented for R12 Upgrade COA Changes
      l_where1 := l_where1 ||' AND cc.segment1 >= :P_COMPANY_LOW ';   --Added for R12 Upgrade COA Changes
    END IF;

    IF (p_company_high IS NOT NULL) THEN
     -- l_where1 := l_where1 ||' AND cc.segment5 <= :P_COMPANY_HIGH '; --Commented for R12 Upgrade COA Changes
      l_where1 := l_where1 ||' AND cc.segment1 <= :P_COMPANY_HIGH ';   --Added for R12 Upgrade COA Changes
    END IF;

    IF (p_bank_name IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND aba.bank_account_name = :P_BANK_NAME ';
    END IF;

    --Added for R12 Upgrade additional requirement

    IF (p_receipt_type IS NOT NULL) THEN
      l_where1 := l_where1 ||' AND cr.type= DECODE(:P_RECEIPT_TYPE,''Standard'',''CASH'',''Miscellaneous'',''MISC'') ';
    END IF;

    l_query := l_select1 || l_where1;

    xxcm_bi_reporting_pub.pl(l_query,'N');
    qryCtx := DBMS_XMLGEN.newContext(l_query);

    /*  Set the bind variables  */
    xxcm_bi_reporting_pub.pl('Set Bind Variables');
--    dbms_xmlgen.setbindvalue(qryCtx, 'P_ORG_ID', p_org_id);

    IF (p_gl_date_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_GL_DATE_LOW', p_gl_date_low);
    END IF;

    IF (p_gl_date_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_GL_DATE_HIGH', p_gl_date_high);
    END IF;

    IF (p_currency_code IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_CURRENCY_CODE', p_currency_code);
    END IF;

    IF (p_receipt_number_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_RECEIPT_NUMBER_LOW', p_receipt_number_low);
    END IF;

    IF (p_receipt_number_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_RECEIPT_NUMBER_HIGH', p_receipt_number_high);
    END IF;

    IF (p_batch_name_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_BATCH_NAME_LOW', p_batch_name_low);
    END IF;

    IF (p_batch_name_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_BATCH_NAME_HIGH', p_batch_name_high);
    END IF;

    IF (p_customer_name_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_CUSTOMER_NAME_LOW', p_customer_name_low);
    END IF;

    IF (p_customer_name_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_CUSTOMER_NAME_HIGH', p_customer_name_high);
    END IF;

    IF (p_deposit_date_from IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_DEPOSIT_DATE_FROM', p_deposit_date_from);
    END IF;

    IF (p_deposit_date_to IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_DEPOSIT_DATE_TO', p_deposit_date_to);
    END IF;

    IF (p_payment_method IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_PAYMENT_METHOD', p_payment_method);
    END IF;

    IF (p_receipt_status_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_RECEIPT_STATUS_LOW', p_receipt_status_low);
    END IF;

    IF (p_receipt_status_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_RECEIPT_STATUS_HIGH', p_receipt_status_high);
    END IF;

    IF (p_company_low IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_COMPANY_LOW', p_company_low);
    END IF;

    IF (p_company_high IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_COMPANY_HIGH', p_company_high);
    END IF;

    IF (p_bank_name IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_BANK_NAME', p_bank_name);
    END IF;

    --Added for R12 Upgrade additional requirement
    IF (p_receipt_type IS NOT NULL) THEN
       dbms_xmlgen.setbindvalue(qryCtx, 'P_RECEIPT_TYPE', p_receipt_type);
    END IF;

  /* Sets the name of the element enclosing the entire result */
  xxcm_bi_reporting_pub.pl('dbms_xmlgen.setrowsettag');
  dbms_xmlgen.setrowsettag(qryCtx, 'XXAR_RECEIPT_REGISTER');

  /* Sets the name of the element enclosing each row of the result */
  xxcm_bi_reporting_pub.pl('dbms_xmlgen.setrowtag');
  --dbms_xmlgen.setrowtag(qryCtx,'');

  /* Set the null handling option - Leave out the tags for null values */
  xxcm_bi_reporting_pub.pl('dbms_xmlgen.setnullhandling');
  dbms_xmlgen.setnullhandling(qryCtx, 0);

  /*  Generate the XML data to the result  */
  xxcm_bi_reporting_pub.pl('dbms_xmlgen.get_xml');
  result := DBMS_XMLGEN.getXML(qryCtx);

  /*  Closes a given context and releases all resources associated
  with it, including the SQL cursor and bind and define buffers */
  dbms_xmlgen.closecontext(qryctx);

  /*  Call procedure to write the xml output to the bi report */
  xxcm_bi_reporting_pub.write_xml_output(result);
  xxcm_bi_reporting_pub.pl('END xxcm_bi_reporting_pub.xxar_receipt_register');

 EXCEPTION
    WHEN OTHERS THEN
      p_retcode := sqlcode;
      p_errbuf  := sqlerrm;
      xxcm_bi_reporting_pub.pl('Return Code = ' || p_retcode || ' ERROR: ' || p_errbuf);
      RAISE ;
END xxar_receipt_register;
END XXAR_CREDIT_CARD;

/
