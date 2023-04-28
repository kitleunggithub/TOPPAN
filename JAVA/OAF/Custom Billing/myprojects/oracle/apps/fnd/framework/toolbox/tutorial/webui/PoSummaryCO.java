/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import com.sun.java.util.collections.HashMap;
import java.io.Serializable;

import oracle.bali.share.util.BooleanUtils;

import oracle.cabo.ui.data.BoundValue;
import oracle.cabo.ui.data.bind.ConcatBoundValue;

import oracle.cabo.ui.data.DictionaryData;
import oracle.cabo.ui.data.DataObjectList;
import oracle.cabo.ui.data.bind.FixedBoundValue;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADataBoundValueViewObject;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OANavigation;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.beans.OAImageBean;
import oracle.apps.fnd.framework.webui.beans.OASwitcherBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.form.OASubmitButtonBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageStyledTextBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;
// The following illustrates correct comments for a shared region.

/**
 * Controller for shared oracle.apps.fnd.framework.toolbox.tutorial.webui.PoSummaryRN
 * region.
 */
public class PoSummaryCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: PoSummaryCO.java 120.4 2007/08/16 10:27:51 atgops1 ship $";
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

    OAApplicationModule rootAM = pageContext.getRootApplicationModule();

    if (TransactionUnitHelper.isTransactionUnitInProgress(pageContext, "poCreateTxn", false))
    { 
      rootAM.invokeMethod("rollbackPurchaseOrder");
      TransactionUnitHelper.endTransactionUnit(pageContext, "poCreateTxn");

    }
    else if (TransactionUnitHelper.isTransactionUnitInProgress(pageContext, "poUpdateTxn", false))
    { 
      rootAM.invokeMethod("rollbackPurchaseOrder");
      TransactionUnitHelper.endTransactionUnit(pageContext, "poUpdateTxn");

    }
    
    OAApplicationModule nestedAM = pageContext.getApplicationModule(webBean);
  
    OATableBean table = (OATableBean)webBean.findIndexedChildRecursive("OrdersTable");

    if (table == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "OrdersTable") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

    // The special query handling for the table is required per the coding
    // standards.
    
    Boolean executeQuery = BooleanUtils.getBoolean(false);
    Serializable[] parameters =  { executeQuery };
    Class[] paramTypes = { Boolean.class };
	  nestedAM.invokeMethod("init", parameters, paramTypes);

    // In this case, we want the content to always query when the page
    // renders, so we pass "false" to the queryData() method.  Note that
    // this will cause all VO state to be lost.
    if( !pageContext.isFormSubmission() )
    {
      table.queryData(pageContext, false);
    }
  
    // Set the purchase-order specific "control bar" select text:  
    // "Select Purchase Orders:"

    String selectPOText = pageContext.getMessage("AK", "FWK_TBX_T_SELECT_POS", null);
    table.setTableSelectionText(selectPOText);

    // Figure out how to configure this reusable module.  Calling modules can 
    // set parameter values to explicitly disable certain functions.
    
    String showDelete = pageContext.getParameter("showDelete");
    String showUpdate = pageContext.getParameter("showUpdate");
    String showApprove = pageContext.getParameter("showApprove");
    String showCreate = pageContext.getParameter("showCreate");

    if ("N".equals(showApprove))
    {
      table.setControlBarDisplayed(false); // Hide the control bar
      table.setSelectionDisplayed(false); // Hide the "Select" column
    }
    else
    {
      // Set the VO attribute that will determine whether the individual "Select"
      // checkboxes are enabled/disabled.  This is based on the PO's status.
      // Note that the value "Y" maps to the checkbox being disabled and "N"
      // means it's enabled.
      
      table.setSelectionDisabledBindingAttr("ApproveDisabled");
    }

    // We need to format the Switcher image columns so the image is centered
    // (this isn't done automatically for Switchers as it is for 
    // plain image columns).  We start by getting the table's
    // column formats.  We'll complete this step for each column
    // if it's to be displayed in the current page.

    // NOTE!!! You must call the prepareForRendering() method on the table *before* 
    // formatting columns.  Furthermore, this call must be sequenced *after* the
    // table is queried, and *after* you do any control bar manipulation.
   
    table.prepareForRendering(pageContext);   

    // Now format the order total value based on the PO's currency code.
    // "CurrencyCode" is the name of the attribute in the POSimpleSummaryVO
    // that this table is referencing.

    OAMessageStyledTextBean orderTotal = 
      (OAMessageStyledTextBean)webBean.findIndexedChildRecursive("OrderTotal");

    if (orderTotal == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "OrderTotal") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }  

    // Note that the CURRENCY_CODE must be set BEFORE you make a call to
    // getColumnFormats if you want the OAF to automatically end-align the
    // currency formatted value in a classic table.
            
    orderTotal.setAttributeValue(CURRENCY_CODE, 
        new OADataBoundValueViewObject(orderTotal, "CurrencyCode"));

    
    DataObjectList columnFormats = table.getColumnFormats();
    DictionaryData columnFormat = null;
    int childIndex = -1;

    if ("N".equals(showCreate))
    {
      //Create Button for Basic Train
      OASubmitButtonBean createButton = 
        (OASubmitButtonBean)webBean.findChildRecursive("Create");

      if (createButton == null)
      {
        MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "Create") };
        throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
      }
      createButton.setRendered(false);
      
      //Create Button for Interactive Train
      OASubmitButtonBean createITButton = 
        (OASubmitButtonBean)webBean.findChildRecursive("CreateIT");

      if (createITButton == null)
      {
        MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "CreateIT") };
        throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
      }
      createITButton.setRendered(false);

    }
    
    if ("N".equals(showDelete))
    {
      OASwitcherBean delete = 
        (OASwitcherBean)webBean.findChildRecursive("DeleteSwitcher");

      if (delete == null)
      {
        MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "DeleteSwitcher") };
        throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
      }  
      
      delete.setRendered(false);
    }
    else
    {
      childIndex = pageContext.findChildIndex(table, "DeleteSwitcher");
      columnFormat =(DictionaryData)columnFormats.getItem(childIndex);
      columnFormat.put(COLUMN_DATA_FORMAT_KEY, ICON_BUTTON_FORMAT);

    }

    if ("N".equals(showUpdate))
    {
       OASwitcherBean update = 
        (OASwitcherBean)webBean.findIndexedChildRecursive("UpdateSwitcher");

      if (update == null)
      {
        MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "UpdateSwitcher") };
        throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
      }  
      update.setRendered(false);
    }
    else
    {
      childIndex = pageContext.findChildIndex(table, "UpdateSwitcher");
      columnFormat =(DictionaryData)columnFormats.getItem(childIndex);
      columnFormat.put(COLUMN_DATA_FORMAT_KEY, ICON_BUTTON_FORMAT);
    }

    // We need to define the bound values for our "Status" composite image
    // column.

    OAImageBean statusImageBean = (OAImageBean)table.findIndexedChildRecursive("StatusImage");

    if (statusImageBean == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "StatusImage") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

/*
** Note that you may define an image bound value without specifying the APPS_MEDIA_DIRECTORY,
** however, we include this example to show you how to concatenate a fixed bound value
** with a data bound value.
*/

    // Define the OA Framework image directory 

    FixedBoundValue imageDirectory = new FixedBoundValue(APPS_MEDIA_DIRECTORY);

    // Define a binding between the image bean and the view object attribute that it
    // will reference to get the appropriate .gif image value name.
    // Note that the corresponding attribute values are obtained using a decode( ) in the
    // POSimpleSummaryVO view object. 

    OADataBoundValueViewObject statusBinding = 
       new OADataBoundValueViewObject(statusImageBean, "StatusImage");

    // Concatenate the image directory with the actual image name (as retrieved
    // from the view object attribute decode() statement)
    
    ConcatBoundValue statusCBV 
      = new ConcatBoundValue(new BoundValue[] {imageDirectory, statusBinding});
      
    // Finally tell the image bean where to get the image source attribute
    
    statusImageBean.setAttributeValue(SOURCE_ATTR, statusCBV);

    // For accessibility compliance, you always specify the alternate text for an
    // image.  Note that you should never use static text as shown (always source
    // translatable text from Message Dictionary), and ideally, the alternate
    // text should clearly indicate the status the image represents. 
    // Generally, we would recommend that you use a Switcher as shown for the 
    // Delete column to easily show different images with associated alternate
    // text, but we wanted to show how to use a bound value also in this example.

    statusImageBean.setAttributeValue(SHORT_DESC_ATTR, "Purchase order status indicator");


  } // end processRequest()


  /**
   * Procedure to handle form submissions for form elements in
   * AK region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);
    
    if (pageContext.getParameter("Approve") != null) 
    { 
      OAApplicationModule am = pageContext.getApplicationModule(webBean);
      am.invokeMethod("approvePurchaseOrder", null);

      // Now redirect back to this page so we can requery the PO in its new
      // state.
  
      pageContext.setForwardURLToCurrentPage(null, 
                                             false, // no reason to retain the AM
                                             ADD_BREAD_CRUMB_NO,
                                             IGNORE_MESSAGES);                                            
    }
    else if (pageContext.getParameter("Create") != null || pageContext.getParameter("CreateIT") != null)
    {
      //Based on the button clicked, set values in the Session to
      //distinguish between Basic Train & Interactive Train
      if (pageContext.getParameter("Create") != null)      
        pageContext.putSessionValue("Train", "Basic");
      else if (pageContext.getParameter("CreateIT") != null)
        pageContext.putSessionValue("Train", "IT");

      // For Back button support, make sure we abort any previously running
      // workflow for this page flow.
      if (OANavigation.isWorkflowInProgress(pageContext))
      {
        String oldKey = OANavigation.getItemKey(pageContext);

        if (!OANavigation.abortProcess(pageContext, "FWKTBX2", "FWKTBXPFLOW", oldKey, null, null))
        {
          // WARNING -- NEVER hard code message text like this!!
          throw new OAException("Could not abort previously running workflow process.");
        }
      }

      OAApplicationModule am = pageContext.getRootApplicationModule();
      
	    String wfKey = null;
      String nextPage = null;

      // Initialize the Workflow pageflow.
      Serializable[] parameters = { "fwk_tbx_wf_seq" };
      wfKey = (String)am.invokeMethod("getWfKey", parameters);
      
	    OANavigation.createProcess(pageContext, "FWKTBX2", "FWKTBXPFLOW", wfKey);
	    OANavigation.startProcess(pageContext, "FWKTBX2", "FWKTBXPFLOW", wfKey); 
      
      // This is the correct signature for initializing a new workflow when you're going
      // to transition to the first activity.
      nextPage = OANavigation.getNextPage(pageContext, "FWKTBX2", wfKey, null, false);
	    
      HashMap params = new HashMap(1);
      params.put("poStep", "1");
      pageContext.setForwardURL(pageContext.getApplicationJSP() + "?" + nextPage, // target page
                                null, 
                                KEEP_MENU_CONTEXT,
                                "", // No need to specify since we're keeping menu context
                                params, // Page parameters
                                true, // Be sure to retain the AM!
                                ADD_BREAD_CRUMB_NO, // Do not display breadcrumbs
                                OAException.ERROR); // Do not forward w/ errors
      
    }
    else if ("delete".equals(pageContext.getParameter(EVENT_PARAM)))
    {
      // The user has clicked a "Delete" icon so we want to display a "Warning"
      // dialog asking if she really wants to delete the PO.  Note that we 
      // configure the dialog so that pressing the "Yes" button submits to 
      // this page so we can handle the action in this processFormRequest( ) method.
      
      String poHeaderId = pageContext.getParameter("poHeaderId");
      MessageToken[] tokens = { new MessageToken("PO_NUMBER", poHeaderId) };
      OAException mainMessage = new OAException("AK", "FWK_TBX_T_PO_DELETE_WARN", tokens);

      // Note that even though we're going to make our Yes/No buttons submit a
      // form, we still need some non-null value in the constructor's Yes/No  
      // URL parameters for the buttons to render, so we just pass empty 
      // Strings for this.
      
      OADialogPage dialogPage = new OADialogPage(OAException.WARNING, 
                                                 mainMessage,
                                                 null, 
                                                 "", 
                                                 "");

     // Always use Message Dictionary for any Strings you want to display.
     
     String yes = pageContext.getMessage("AK", "FWK_TBX_T_YES", null);
     String no = pageContext.getMessage("AK", "FWK_TBX_T_NO", null);

     // We set this value so the code that handles this button press is 
     // descriptive.
     
     dialogPage.setOkButtonItemName("DeleteYesButton");

     // The following configures the Yes/No buttons to be submit buttons,
     // and makes sure that we handle the form submit in the originating
     // page (the "Purchase Orders" summary) so we can handle the "Yes"
     // button selection in this controller.
     
     dialogPage.setOkButtonToPost(true);
     dialogPage.setNoButtonToPost(true);
     dialogPage.setPostToCallingPage(true);

     // Now set our Yes/No labels instead of the default OK/Cancel.
     
     dialogPage.setOkButtonLabel(yes); 
     dialogPage.setNoButtonLabel(no); 

     // We need to keep hold of the poHeaderId, and the OADialogPage gives us a
     // convenient means of doing this.  Note that the use of the Hashtable is
     // really more appropriate for passing multiple parameters, but we've used
     // it here for illustration purposes.  See the OADialogPage javadoc for an
     // alternative when dealing with a single parameter.
     
     java.util.Hashtable formParams = new java.util.Hashtable(1); 
     formParams.put("poHeaderId", poHeaderId); 
     dialogPage.setFormParameters(formParams); 
  
     pageContext.redirectToDialogPage(dialogPage);

    }
    else if (pageContext.getParameter("DeleteYesButton") != null)
    {
      // User has confirmed that she wants to delete this purchase order.
      // Invoke a method on the AM to set the current row in the VO and 
      // call remove() on this row. 
      
      String poHeaderId = pageContext.getParameter("poHeaderId");
      Serializable[] parameters = { poHeaderId };

      OAApplicationModule am = pageContext.getApplicationModule(webBean);

      boolean rowDeleted = false;

      rowDeleted = 
        ((Boolean)am.invokeMethod("deletePurchaseOrder", parameters)).booleanValue();

      if (rowDeleted)
      {
      
        // Now, redisply the page with a confirmation message at the top.  Note
        // that the deletePurchaseOrder( ) method in the AM commits, and our code
        // won't get this far if any exceptions are thrown.
      
        MessageToken[] tokens = { new MessageToken("PO_NUMBER", poHeaderId) };
        OAException message = new OAException("AK", "FWK_TBX_T_PO_DELETE_CONF", tokens,
                                              OAException.CONFIRMATION, null);

        pageContext.putDialogMessage(message);
      }
      else // Row was not found, display a warning
      {
        // WARNING -- NEVER hard-code a message like this!
        OAException message = new OAException("This row has already been deleted.",
                                              OAException.WARNING);

        pageContext.putDialogMessage(message);
        
      }

    }
  } // end processFormRequest()

}
