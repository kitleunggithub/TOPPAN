/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import com.sun.java.util.collections.HashMap;

import oracle.bali.share.util.IntegerUtils;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OANavigation;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.form.OASubmitButtonBean;
import oracle.apps.fnd.framework.webui.beans.nav.OANavigationBarBean;
import oracle.apps.fnd.framework.webui.beans.nav.OATrainBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.CreatePoFootRN 
 * region.
 */
public class CreatePoFooterCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: CreatePoFooterCO.java 120.2 2006/05/25 01:55:42 atgops1 noship $";
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

    if (pageContext.getSessionValue("Train").equals("Basic"))
    {
      OANavigationBarBean navBeanBasic = 
        (OANavigationBarBean)webBean.findChildRecursive("BasicNavBar");

      if (navBeanBasic == null)
      {
        MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "NavBar") };
        throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
      }

      // Determine which page we're on so we can set the selected value.  Each 
      // time we navigate to and within the flow, the URL includes a parameter
      // telling us what page we're on.
      int step = Integer.parseInt(pageContext.getParameter("poStep"));
    
      navBeanBasic.setValue(step);

      // Figure out whether the "Submit" button should be rendered or not;
      // this should appear only on the final page (Step 3).    
      OASubmitButtonBean submitButton = 
        (OASubmitButtonBean)webBean.findIndexedChildRecursive("Submit");
      
      if (submitButton == null)
      {
        MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "Submit") };
        throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
      }
    
      if (step != 3)
      {
        submitButton.setRendered(false);     
      }    
    }
    else if (pageContext.getSessionValue("Train").equals("IT"))
    {
      // The OATrainBean is a named component of the page layout, so we have
      // a special way of getting a handle to it (we can't "find" it like
      // we do for normal, indexed children that would be below the current
      // region in the hierarchy).
      OATrainBean trainBean = 
        (OATrainBean)pageContext.getPageLayoutBean().getLocation();  

      // You must call the following before getting the target page index.
      trainBean.prepareForRendering(pageContext);
      int step = trainBean.getSelectedTrainStepRenderedIndex(); 
      if (step + 1 != trainBean.getNumberOfRenderedTrainSteps())
      {
        OASubmitButtonBean submitButton = 
          (OASubmitButtonBean)webBean.findIndexedChildRecursive("Submit"); 
        submitButton.setRendered(false); 
      }
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

    // The Submit button should only be displayed on the final page...
    
    if (pageContext.getParameter("Submit") != null && pageContext.getSessionValue("Train").equals("Basic"))
    {
      // Simply telling the transaction to commit will cause all the Entity Object validation
	    // to fire.

      // Note that you must commit *before* asking WF for the next page, because
      // asking for the next page at this point will transition the WF to a 
      // completed state, which means you won't be able to navigate back
      // if there are errors during the commit processing.

      am.invokeMethod("apply");

      TransactionUnitHelper.endTransactionUnit(pageContext, "poCreateTxn");
      
      // Don't forget to call this even on the last page so the activity associated with 
      // this page completes and the Workflow transitions appropriately.

      String nextPage = OANavigation.getNextPage(pageContext);

      // For the final page, Workflow should be returning null -- and the user
      // can select the "Submit" button only on the last page.  Something's
      // wrong.
      
      if (nextPage != null)  
      {
        throw new OAException("AK", "FWK_TBX_T_WF_UNEXPECTED_TRANS"); 
      }
      else  // we've just completed the flow
      {

      // Assuming the "commit" succeeds, we'll display a Confirmation dialog that takes
	    // the user back to the main "Purchase Orders".

       String poNumber = (String)pageContext.getTransactionValue("PO_NUMBER");
       
       MessageToken[] tokens = { new MessageToken("PO_NUMBER", poNumber),
                                 new MessageToken("PO_APPROVER", pageContext.getUserName()) };

       OAException confirmMessage = new OAException("AK", "FWK_TBX_T_PO_CREATE_CONFIRM", tokens);
       
       OADialogPage dialogPage = new OADialogPage(OAException.CONFIRMATION, 
                                                  confirmMessage,
                                                  null, 
                                                  pageContext.getApplicationJSP() + "?OAFunc=FWK_TOOLBOX_PO_SUMMARY_CR&retainAM=Y", 
                                                  null);
                                                  
       pageContext.redirectToDialogPage(dialogPage);
       
      }  
    }
    else if (pageContext.getParameter("Submit") != null && pageContext.getSessionValue("Train").equals("IT"))
    {
      // Simply telling the transaction to commit will cause all the Entity Object validation
	    // to fire.
      am.invokeMethod("apply");

      TransactionUnitHelper.endTransactionUnit(pageContext, "poCreateTxn");
      
      // Assuming the "commit" succeeds, we'll display a Confirmation dialog that takes
	    // the user back to the main "Purchase Orders".
       String poNumber = (String)pageContext.getTransactionValue("PO_NUMBER");
       
       MessageToken[] tokens = { new MessageToken("PO_NUMBER", poNumber),
                                 new MessageToken("PO_APPROVER", pageContext.getUserName()) };

       OAException confirmMessage = new OAException("AK", "FWK_TBX_T_PO_CREATE_CONFIRM", tokens);
       
       OADialogPage dialogPage = new OADialogPage(OAException.CONFIRMATION, 
                                                  confirmMessage,
                                                  null, 
                                                  pageContext.getApplicationJSP() + "?OAFunc=FWK_TOOLBOX_PO_SUMMARY_CR&retainAM=Y", 
                                                  null);
                                                  
       pageContext.redirectToDialogPage(dialogPage);    
    }
    else if ("goto".equals(pageContext.getParameter(EVENT_PARAM)) &&
             "BasicNavBar".equals(pageContext.getParameter(SOURCE_PARAM)) )
    {
      int currentStep = Integer.parseInt(pageContext.getParameter("poStep"));

      // Note that the OANavigationBean publishes a "goto" event paremeter when 
      // either the Back or Next button is pressed.  You need to determine which way to 
      // go based on the related "value" parameter.
      //
      // Also note the check of "source" above to ensure we're dealing with the
      // page-level navigation here and not table-level navigation which is 
      // implemented with the same Bean configured differently.
      int target = Integer.parseInt(pageContext.getParameter("value"));

      String workflowResult;

      if (target < currentStep)
      {
        workflowResult = "PREVIOUS";
      }
      else 
      {
        workflowResult = "NEXT";
      }  

      String nextPage = OANavigation.getNextPage(pageContext, workflowResult);  

      if (nextPage != null)
      { 
        HashMap params = new HashMap(1);
        params.put("poStep", IntegerUtils.getInteger(target));
        pageContext.setForwardURL(pageContext.getApplicationJSP() + "?" + nextPage, // target page
                                  null,
                                  KEEP_MENU_CONTEXT,
                                  "", // No need to specify since we're keeping menu context
                                  params, // Page parameters
                                  true, // Be sure to retain the AM!
                                  ADD_BREAD_CRUMB_NO, // Do not display breadcrumbs
                                  OAException.ERROR); // Do not forward w/ errors
       }
      else
      {
        throw new OAException("AK", "FWK_TBX_T_WF_NO_NEXT_PAGE");
      }  
    } 
    else if (pageContext.getParameter("Cancel") != null)
    {
     
       am.invokeMethod("rollbackPurchaseOrder");   

       // Remove the "in transaction" indicator
       TransactionUnitHelper.endTransactionUnit(pageContext, "poCreateTxn");
       
       pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/tutorial/webui/PoSummaryCreatePG",
                                      null,
                                      OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                      null,
                                      null,
                                      true, // retain AM
                                      OAWebBeanConstants.ADD_BREAD_CRUMB_NO);       
    }
  } // end processFormRequest()
}
