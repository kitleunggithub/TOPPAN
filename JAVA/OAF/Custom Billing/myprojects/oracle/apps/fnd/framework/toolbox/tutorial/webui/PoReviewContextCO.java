/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.form.OAFormValueBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageStyledTextBean;

/**
 * Controller for FWK_TBX_T_LSN7_DET_CONTEXT
 */
public class PoReviewContextCO extends OAControllerImpl
{
  // Required for Applications source control
  public static final String RCS_ID="$Header: PoReviewContextCO.java 120.1 2005/06/06 17:20:42 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.webui");

  /**
   * Layout and page setup logic for AK region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the AK region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);
 
    // The "Order Total" prompt needs to be replaced with a message that
    // can display the currency, which is stored in a hidden field on the
    // page.  So it should look like:  Order Total (USD)

    OAMessageStyledTextBean orderTotal = 
      (OAMessageStyledTextBean)webBean.findIndexedChildRecursive("OrderTotal");

    if (orderTotal == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "OrderTotal") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

    // When you select the item style "Hidden" a form value bean is created.
    // Since we place the currency value on the page manually, we don't want
    // it rendering with the other fields.
    
    OAFormValueBean currency =
      (OAFormValueBean)webBean.findIndexedChildRecursive("Currency");

    if (currency == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "Currency") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }  
  
    MessageToken[] currencyToken = { new MessageToken("CURRENCY_CODE", (String)currency.getValue(pageContext)) };
    String orderTotalPrompt = pageContext.getMessage("AK", "FWK_TBX_T_ORDER_TOTAL_PROMPT", currencyToken);

    orderTotal.setPrompt(orderTotalPrompt);

    } // end processRequest()

}
