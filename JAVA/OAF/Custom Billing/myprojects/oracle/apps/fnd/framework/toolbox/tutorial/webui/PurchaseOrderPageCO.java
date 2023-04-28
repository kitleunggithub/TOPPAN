/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
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
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.form.OAFormValueBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAPageLayoutBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageStyledTextBean;


/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.PurchaseOrderPG 
 * page.
 */
public class PurchaseOrderPageCO extends OAControllerImpl
{
  // Required for Applications source control
  public static final String RCS_ID="$Header: PurchaseOrderPageCO.java 120.2 2005/07/26 09:36:45 atgops1 noship $";
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

    // Put a transaction value indicating that the update transaction
    // is now in progress (transaction-in-progress indicator).
    // Do this only at the first page of the Update flow.
    TransactionUnitHelper.startTransactionUnit(pageContext, "poUpdateTxn");

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
    boolean rowFound = ((Boolean)am.invokeMethod("init", parameters)).booleanValue(); 

    // If a matching row is not found, it could have been deleted... Need to display
    // and error message to the user.
    if (!rowFound)
    {
      // Add logic to display a dialog page with a custom error message instead
      // of the standard state loss error shown here.
      OADialogPage dialogPage = new OADialogPage(STATE_LOSS_ERROR); 
      pageContext.redirectToDialogPage(dialogPage); 
    }
    else // proceed normally
    {

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
  
      MessageToken[] currencyToken = 
         { new MessageToken("CURRENCY_CODE", (String)currency.getValue(pageContext)) };
      String orderTotalPrompt = 
         pageContext.getMessage("AK", "FWK_TBX_T_ORDER_TOTAL_PROMPT", currencyToken);

      orderTotal.setPrompt(orderTotalPrompt);
    }  
  } // end processRequest()
    

  /**
   * Procedure to handle form submissions for form elements in
   * region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);

    OAApplicationModule am = pageContext.getApplicationModule(webBean);

    if (pageContext.getParameter("Apply") != null)
    {
      // If the user presses the "Apply" button, we want to save their changes
      // and display a confirmation message at the top of the page.  The users
      // can make iterative edits.  When they're ready to leave the page, they
      // can select "Cancel" to abandon any unsaved changes, the "Return to
      // Purchase Orders" link, or they can can simply navigate out of the page
      // by selecting a menu item.

      am.invokeMethod("apply");

      // Now, redisply the page with a confirmation message at the top.  

      // Get the purchase order number from the request.

      String orderNumber = pageContext.getParameter("headerId");
      
      MessageToken[] tokens = { new MessageToken("PO_NUMBER", orderNumber) };
      OAException message = new OAException("AK", "FWK_TBX_T_PO_UPDATE_CONFIRM", tokens,
                                            OAException.CONFIRMATION, null);

      pageContext.putDialogMessage(message);

    }
    else if (pageContext.getParameter("Cancel") != null)
    {
       am.invokeMethod("rollbackPurchaseOrder");  

       // Remove the "in transaction" indicator
       TransactionUnitHelper.endTransactionUnit(pageContext, "poUpdateTxn");
       
       pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/tutorial/webui/PoSummaryUpdatePG",
                                      null,
                                      OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                      null,
                                      null,
                                      true, // retain AM
                                      OAWebBeanConstants.ADD_BREAD_CRUMB_NO);
    }

  } // end processFormRequest()

}
