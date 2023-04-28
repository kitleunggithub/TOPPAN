/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.webui;

import java.io.Serializable;

import oracle.cabo.ui.data.BoundValue;
import oracle.cabo.ui.data.DictionaryData;
import oracle.cabo.ui.data.DataObjectList;
import oracle.cabo.ui.data.bind.ConcatBoundValue;
import oracle.cabo.ui.data.bind.FixedBoundValue;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADataBoundValueViewObject;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAImageBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.labsolutions.webui.EmpSearchPG 
 * page's "Results" region.
 */
public class EmployeeResultsCO extends OAControllerImpl
{
  // Required for Applications source control
  public static final String RCS_ID="$Header: EmployeeResultsCO.java 120.4 2010/12/10 13:24:50 sette ship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.webui");

  /**
   * Layout and page setup logic for region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    // Always call this first.
    super.processRequest(pageContext, webBean);

    OAApplicationModule am = pageContext.getApplicationModule(webBean);

    // The following checks to see if the user navigated back to this page
    // without taking an action that cleared an "in transaction" indicator.
    // If so, we want to rollback any changes that she abandoned to ensure they
    // aren't left lingering in the BC4J cache to cause problems with 
    // subsequent transactions.  For example, if the user navigates to the 
    // Create Employee page where you start a "create" transaction unit, 
    // then navigates back to this page using the browser Back button and
    // selects the Create Employee button again, the OA Framework detects this
    // Back button navigation and steps through processRequest() to this code
    // is executed before you try to create another new employee.
    if (TransactionUnitHelper.isTransactionUnitInProgress(pageContext, "empCreateTxn", false))
    { 
      am.invokeMethod("rollbackEmployee");
      TransactionUnitHelper.endTransactionUnit(pageContext, "empCreateTxn");
    }
    else if (TransactionUnitHelper.isTransactionUnitInProgress(pageContext, "empUpdateTxn", false))
    { 
      am.invokeMethod("rollbackEmployee");
      TransactionUnitHelper.endTransactionUnit(pageContext, "empUpdateTxn");
    }

    OATableBean table = (OATableBean)webBean;

    // Implement the bound value for the Status Image.

    OAImageBean statusImageBean = (OAImageBean)table.findIndexedChildRecursive("EmpStatus");

    if (statusImageBean == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "EmpStatus") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

    // Define the OA Framework image directory.
    FixedBoundValue imageDirectory = new FixedBoundValue(APPS_MEDIA_DIRECTORY);

    // Define a binding between the image bean and the view object attribute that it
    // will reference to get the appropriate .gif image value name.
    // Note that the corresponding attribute values are obtained using a decode( ) in the
    // EmployeeFullVO view object. 
    OADataBoundValueViewObject statusBinding = 
       new OADataBoundValueViewObject(statusImageBean, "EmployeeStatus");

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
    // text, but we wanted to show how to use a bound value also in this lab.
    statusImageBean.setAttributeValue(SHORT_DESC_ATTR, "Employee status indicator");

    // We need to format the Switcher image column so the image is centered
    // (this isn't done automatically for Switchers as it is for 
    // plain image columns).  We start by getting the table's
    // column formats.  
    
    // NOTE!!! You must call the prepareForRendering() method on the table *before* 
    // formatting columns.  Furthermore, this call must be sequenced *after* the
    // table is queried, and *after* you do any control bar manipulation.
    table.prepareForRendering(pageContext);   
    
    DataObjectList columnFormats = table.getColumnFormats();
    DictionaryData columnFormat = null;
    int childIndex = pageContext.findChildIndex(table, "DeleteSwitcher");
    columnFormat =(DictionaryData)columnFormats.getItem(childIndex);
    columnFormat.put(COLUMN_DATA_FORMAT_KEY, ICON_BUTTON_FORMAT);
 
  } // end processRequest()


    /**
   * Procedure to handle form submissions for form elements in
   * region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    // Always call this first.
    super.processFormRequest(pageContext, webBean);
    
    if (pageContext.getParameter("Create") != null)
    {

      // Navigate to the "Create Employee" page while retaining the AM.
      // Note the use of KEEP_MENU_CONTEXT as opposed to GUESS_MENU_CONTEXT (we
      // want to keep the Employees tab highlighted).
	    pageContext.setForwardURL("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/labsolutions/webui/EmployeePG",
                                null,
                                OAWebBeanConstants.KEEP_MENU_CONTEXT,
								                null,
								                null,
								                true, // Retain AM
								                OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
								                OAWebBeanConstants.IGNORE_MESSAGES);

    }
    else if ("update".equals(pageContext.getParameter(EVENT_PARAM)))
    { 
      
      // The user has clicked an "Update" icon so we want to navigate to the first
      // step of the multistep "Update Employee" flow. Again, we want to keep
      // the Employees tab highlighted, but we don't want to show breadcrumbs
      // since they never should render in the same page with a train.
     	pageContext.setForwardURL("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/labsolutions/webui/EmpDescPG",
                                null,
                                OAWebBeanConstants.KEEP_MENU_CONTEXT,
								                null,
								                null,
								                true, // Retain AM
								                OAWebBeanConstants.ADD_BREAD_CRUMB_NO, // Do not display breadcrums
								                OAWebBeanConstants.IGNORE_MESSAGES);

    }
    else if ("delete".equals(pageContext.getParameter(EVENT_PARAM)))
    {
      
      // The user has clicked a "Delete" icon so we want to display a "Warning"
      // dialog asking if she really wants to delete the employee.  Note that we 
      // configure the dialog so that pressing the "Yes" button submits to 
      // this page so we can handle the action in this processFormRequest( ) method.
      String employeeNumber = pageContext.getParameter("empNum");
      String employeeName = pageContext.getParameter("empName");
           
      MessageToken[] tokens = { new MessageToken("EMP_NAME", employeeName) };
      OAException mainMessage = new OAException("AK", "FWK_TBX_T_EMP_DELETE_WARN", tokens);

      // Note that even though we're going to make our Yes/No buttons submit a
      // form, we still need some non-null value in the constructor's Yes/No  
      // URL parameters for the buttons to render, so we just pass empty 
      // Strings for this.
      
      OADialogPage dialogPage = new OADialogPage(OAException.WARNING, 
                                                 mainMessage,
                                                 null, 
                                                 "", 
                                                 "");

     // Always use Applications Message Dictionary for any Strings you want to 
     // display in your page.  Note that any text that you set declaratively
     // in the OA Extension is directly translatable.
     String yes = pageContext.getMessage("AK", "FWK_TBX_T_YES", null);
     String no = pageContext.getMessage("AK", "FWK_TBX_T_NO", null);

     // We set this value so the code that handles this button press is 
     // descriptive.
     dialogPage.setOkButtonItemName("DeleteYesButton");

     // The following configures the Yes/No buttons to be submit buttons,
     // and makes sure that we handle the form submit in the originating
     // page (the "Employees" summary) so we can handle the "Yes"
     // button selection in this controller.
     dialogPage.setOkButtonToPost(true);
     dialogPage.setNoButtonToPost(true);
     dialogPage.setPostToCallingPage(true);

     // Now set our Yes/No labels instead of the default OK/Cancel.
     dialogPage.setOkButtonLabel(yes); 
     dialogPage.setNoButtonLabel(no); 

     // We need to keep hold of the employeeId, and the OADialogPage gives us a
     // convenient means of doing this.  Note that the use of the Hashtable is
     // really more appropriate for passing multiple parameters, but we've used
     // it here for illustration purposes.  See the OADialogPage javadoc for an
     // alternative when dealing with a single parameter.
     java.util.Hashtable formParams = new java.util.Hashtable(1); 
     formParams.put("empNum", employeeNumber); 
     formParams.put("empName", employeeName);
     dialogPage.setFormParameters(formParams); 
  
     pageContext.redirectToDialogPage(dialogPage);

    }
    else if (pageContext.getParameter("DeleteYesButton") != null)
    {   
      
      // User has confirmed that she wants to delete this employee.
      // Invoke a method on the AM to set the current row in the VO and 
      // call remove() on this row. 
      String employeeNumber = pageContext.getParameter("empNum");
      String employeeName = pageContext.getParameter("empName");
      Serializable[] parameters = { employeeNumber };

      OAApplicationModule am = pageContext.getApplicationModule(webBean);

      am.invokeMethod("deleteEmployee", parameters);
      
      // Now, redisplay the page with a confirmation message at the top.  Note
      // that the deletePurchaseOrder( ) method in the AM commits, and our code
      // won't get this far if any exceptions are thrown.
      
      MessageToken[] tokens = { new MessageToken("EMP_NAME", employeeName) };
      OAException message = new OAException("AK", "FWK_TBX_T_EMP_DELETE_CONFIRM", tokens,
                                            OAException.CONFIRMATION, null);

      pageContext.putDialogMessage(message);

    }    
    else if (pageContext.getParameter("Save") != null ) {
      OAApplicationModule am = pageContext.getApplicationModule(webBean);
      am.invokeMethod("apply");
    }
  } // end processFormRequest()
}
