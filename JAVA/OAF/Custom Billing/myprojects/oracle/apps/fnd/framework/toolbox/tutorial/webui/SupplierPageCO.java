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

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageStyledTextBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.SupplierPG 
 * page.
 */
public class SupplierPageCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: SupplierPageCO.java 120.1 2005/06/06 17:43:00 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.webui");


  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    // If isBackNavigationFired = false, we're here after a valid navigation
    // and we should proceed normally.
    // isBackNavigationFired(false /* trackFormSubmitOnly */) tracks the
    // browser back button event for non-form-submit request case as well.
    // We don't want to create a redundant new record whenever user reloads
    // the Create page, so tracking non-form-submit case as well.
      
    if (!pageContext.isBackNavigationFired(false))
    {
      TransactionUnitHelper.startTransactionUnit(pageContext, "supplierCreateTxn");
      
      // Create page's controller processRequest could be re-entered
      // upon normal page flow form submission if failover to another
      // JVM occurred or if a recycled AM was activated.
      // We don't want to re-create a new row with a new primary key
      // in such case because the new row should already be present.
      // Re-creating a new row with a different primary key would
      // result in a stale data error situation.
      if (!pageContext.isFormSubmission())
      {
        OAApplicationModule am = pageContext.getApplicationModule(webBean);
        am.invokeMethod("createSupplier", null);
      } 
    }
    else 
    { 
      if (!TransactionUnitHelper.isTransactionUnitInProgress(pageContext, "supplierCreateTxn", true))
      { 
        // We got here through some use of the browser "Back" button, so we 
        // want to display a stale data error and disallow access to the page.

        // If this were a real application, we would probably display a more
        // context-specific message telling the user she can't use the browser
        // "Back" button and the "Create" page.  Instead, we wanted to illustrate
        // how to display the Applications standard STATE LOSS ERROR message.
        OADialogPage dialogPage = new OADialogPage(STATE_LOSS_ERROR); 
        pageContext.redirectToDialogPage(dialogPage); 
      } 
    } 
  

  } // end processRequest()

  
  /**
   * Procedure to handle form submissions for form elements in
   * AK region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the AK region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);

    OAApplicationModule am = pageContext.getApplicationModule(webBean);
    
    // Pressing the "Apply" button means the transaction should be validated
    // and committed.
    
    if (pageContext.getParameter("Apply") != null) 
    {
	    String name = pageContext.getParameter("SupplierName");

      // You can't get the supplierId from the request, because it's not a 
      // user enterable field.
      
	    OAMessageStyledTextBean supplierIdBean = (OAMessageStyledTextBean)webBean.findIndexedChildRecursive("SupplierId");
      String supplierId = (String)supplierIdBean.getValue(pageContext);

	    // Simply telling the transaction to commit will cause all the Entity Object validation
	    // to fire (see Lesson 4 documentation for additional information).
	    //
	    // Note: there's no reason for a developer to perform a rollback.  This is handled by
	    // the framework if errors are encountered.

      am.invokeMethod("apply");

      TransactionUnitHelper.endTransactionUnit(pageContext, "supplierCreateTxn");

      // Assuming the "commit" succeeds, we'll display a Confirmation dialog that takes
	    // the user back to the main search page.

       MessageToken[] tokens = { new MessageToken("SUPPLIER_NAME", name),
                                 new MessageToken("SUPPLIER_NUMBER", supplierId) };


       OAException confirmMessage = new OAException("AK", "FWK_TBX_T_SUPPLIER_CREATE_CONF", tokens,
                                        OAException.CONFIRMATION, null);

       // Per the UI guidelines, we want to add the confirmation message at the 
       // top of the search/results page and we want the old search criteria and
       // results to display.
       
       pageContext.putDialogMessage(confirmMessage);

       pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/tutorial/webui/SupplierSearchPG",
                                      null,
                                      OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                      null,
                                      null,
                                      true, // retain AM
                                      OAWebBeanConstants.ADD_BREAD_CRUMB_NO);
 
    }
    else if (pageContext.getParameter("Cancel") != null)
    { 
       am.invokeMethod("rollbackSupplier");   

       TransactionUnitHelper.endTransactionUnit(pageContext, "supplierCreateTxn");
       
       pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/tutorial/webui/SupplierSearchPG",
                                      null,
                                      OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                      null,
                                      null,
                                      true, // retain AM
                                      OAWebBeanConstants.ADD_BREAD_CRUMB_NO);       
    }
  
  } // end processFormRequest()

}
