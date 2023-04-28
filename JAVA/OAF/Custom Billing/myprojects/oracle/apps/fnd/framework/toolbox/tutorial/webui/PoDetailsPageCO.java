/*===========================================================================+
 |      Copyright (c) 2001, 2019 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import java.io.Serializable;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAUrl;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.form.OAFormValueBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAPageLayoutBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageStyledTextBean;
import oracle.apps.fnd.framework.webui.beans.nav.OALinkBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.PoDetailsPG
 * page.
 */
public class PoDetailsPageCO extends OAControllerImpl
{
  // Required for Applications source control
 
  public static final String RCS_ID="$Header: PoDetailsPageCO.java 120.1.12020000.6 2019/03/19 08:47:38 atgops1 ship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.webui");

  /**
   * Layout and page setup logic for region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);
    
    String retainAMParam = pageContext.getParameter("retainAM");
    String fromLSR = pageContext.getParameter("fromLSR");
    OALinkBean returnNavLink = (OALinkBean) pageContext.getRootWebBean().findChildRecursive("returnLink");
    String destination = returnNavLink.getDestination();
    
    if("Y".equals(fromLSR))
    {
      String newDest = destination.replace("OAFunc=FWK_TOOLBOX_PO_SEARCH","page=/oracle/apps/fnd/framework/toolbox/tutorial/webui/PoListSearchPG");
      
      destination = newDest;
    }
    if("N".equals(retainAMParam))
    {
      String newDest = destination.replace("retainAM=Y","retainAM=N");
      destination = newDest;
    }
    
    String newUrlString = new OAUrl(destination).createURL(pageContext.getRenderingContext());
    returnNavLink.setDestination(newUrlString);

    // Get the purchase order number from the request.

    String orderNumber = pageContext.getParameter("headerId");

    // We need to set the page header text to include the po order number for reference.

    MessageToken[] tokens = { new MessageToken("PO_NUMBER", orderNumber) };

    // Always use a translated value from Message Dictionary when setting strings in
	  // your controllers.

    String pageHeaderText = pageContext.getMessage("AK", "FWK_TBX_T_PO_HEADER_TEXT", tokens);

    // Set the po-specific page title (which also appears in the breadcrumbs)
    
    ((OAPageLayoutBean)webBean).setTitle(pageHeaderText);

    // Now we want to initialize the query for our single purchase order with all of its
	  // details.  

    OAApplicationModule am = pageContext.getApplicationModule(webBean);
    Serializable[] parameters = { orderNumber };
    am.invokeMethod("initDetails", parameters); 

    // The "Order Total" prompt needs to be replaced with a message that
    // can display the currency, which is stored in a hidden field on the
    // page.  So it should look like:  Order Total (USD)

    OAMessageStyledTextBean orderTotal = 
      (OAMessageStyledTextBean)webBean.findIndexedChildRecursive("OrderTotal");

    if (orderTotal == null)
    {
      MessageToken[] errTokens = { new MessageToken("OBJECT_NAME", "OrderTotal") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", errTokens);
    }  

    // When you select the item style "Hidden" a form value bean is created.
    // Since we place the currency value on the page manually, we don't want
    // it rendering with the other fields.
    
    OAFormValueBean currency =
      (OAFormValueBean)webBean.findIndexedChildRecursive("Currency");

    if (currency == null)
    {
      MessageToken[] errTokens = { new MessageToken("OBJECT_NAME", "Currency") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", errTokens);
    }  
  
    MessageToken[] currencyToken = { new MessageToken("CURRENCY_CODE", (String)currency.getValue(pageContext)) };
    String orderTotalPrompt = pageContext.getMessage("AK", "FWK_TBX_T_ORDER_TOTAL_PROMPT", currencyToken);

    orderTotal.setPrompt(orderTotalPrompt);
    
    webBean.findChildRecursive("DescRN").setAttributeValue(RESPONSIVE_ATTR,Boolean.TRUE);
  } // end processRequest()

}
