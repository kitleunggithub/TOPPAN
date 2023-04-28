/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.webui;

import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.labsolutions.webui.EmployeePG 
 * page.
 */
public class EmployeeCreateCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: EmployeeCreateCO.java 120.3 2006/05/25 00:21:45 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.webui");


  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
     // Always call this first.
    super.processRequest(pageContext, webBean);

     // If isBackNavigationFired = false, we're here after a valid navigation
     // (the user selected the Create Empoyee button) and we should proceed 
     // normally and initialize a new employee.
     if (!pageContext.isBackNavigationFired(false))
     {
        // We indicate that we are starting the create transaction (this 
        // is used to ensure correct Back button behavior).
        TransactionUnitHelper.startTransactionUnit(pageContext, "empCreateTxn");
      
        // This test ensures that we don't try to create a new employee if
        // we had a JVM failover, or if a recyled application module
        // is activated after passivation.  If this things happen, BC4J will
        // be able to find the row that you created so the user can resume
        // work.
        if (!pageContext.isFormSubmission())
        {
          OAApplicationModule am = pageContext.getApplicationModule(webBean);
          am.invokeMethod("createEmployee", null);
          
          // Iniitalize the ApplicationPropertiesVO for PPR.
          am.invokeMethod("init");
        } 
      }
      else 
      { 
        if (!TransactionUnitHelper.isTransactionUnitInProgress(pageContext, "empCreateTxn", true))
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
   * region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    // Always call this first.
    super.processFormRequest(pageContext, webBean);

    OAApplicationModule am = pageContext.getApplicationModule(webBean);
    
    // Pressing the "Apply" button means the transaction should be validated
    // and committed.
    if (pageContext.getParameter("Apply") != null) 
    {
      // Generally in the tutorial application and the labs, we've illustrated
      // all BC4J interaction on the server (except for the AMs, of course).  Here,
      // we're dealing with the VO directly so the comments about the reasons
      // why we're obtaining values from the VO and not the request make sense
      // in context.  
      OAViewObject vo = (OAViewObject)am.findViewObject("EmployeeCreateVO1");
        
      // Note that we have to get this value from the VO because the EO will
      // assemble it during its validation cycle.

      // For performance reasons, we should generally be calling getEmployeeName()
      // on the EmployeeFullVORowImpl object, but we don't want to do this
      // on the cliet so we're illustrating the interface-appropriate call.  If
      // we implemented this code in the AM where it belongs, we would use the
      // other approach.
	    String employeeName = (String)vo.getCurrentRow().getAttribute("EmployeeName");

      // We need to get a String so we can pass it to the MessageToken array below.  Note
      // that we are getting this value from the VO (we could also get it from
      // the Bean as shown in the Drilldwon to Details lab) because the item style is messageStyledText, 
      // so the value isn't put on the request like a messaqeTextInput value is.
	    Number employeeNumber = (Number)vo.getCurrentRow().getAttribute("EmployeeId");
      String employeeNum = String.valueOf(employeeNumber.intValue());

	    // Simply telling the transaction to commit will cause all the Entity Object validation
	    // to fire.
	    //
	    // Note: there's no reason for a developer to perform a rollback.  This is handled by
	    // the framework if errors are encountered.
      am.invokeMethod("apply");

      // Indicate that the Create transaction is complete.
      TransactionUnitHelper.endTransactionUnit(pageContext, "empCreateTxn");
    
      // Assuming the "commit" succeeds, navigate back to the "Search" page with 
      // the user's search criteria intact and display a "Confirmation" message
      // at the top of the page.
      MessageToken[] tokens = { new MessageToken("EMP_NAME", employeeName),
                                new MessageToken("EMP_NUMBER", employeeNum) };

                                 
      OAException confirmMessage = new OAException("AK", "FWK_TBX_T_EMP_CREATE_CONFIRM", tokens,
                                       OAException.CONFIRMATION, null);

       // Per the UI guidelines, we want to add the confirmation message at the 
       // top of the search/results page and we want the old search criteria and
       // results to display.
       
       pageContext.putDialogMessage(confirmMessage);

       pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/labsolutions/webui/EmpSearchPG",
                                      null,
                                      OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                      null,
                                      null,
                                      true, // retain AM
                                      OAWebBeanConstants.ADD_BREAD_CRUMB_NO); 

 
    }
    else if (pageContext.getParameter("Cancel") != null)
    {
       am.invokeMethod("rollbackEmployee");   

       // Indicate that the Create transaction is complete.
       TransactionUnitHelper.endTransactionUnit(pageContext, "empCreateTxn");
       
       pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/labsolutions/webui/EmpSearchPG",
                                      null,
                                      OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                      null,
                                      null,
                                      true, // retain AM
                                      OAWebBeanConstants.ADD_BREAD_CRUMB_NO);    
    }
    else if ("empPositionChange".equals(pageContext.getParameter(OAWebBeanConstants.EVENT_PARAM)))
    {
      // The Position poplist PPR change event has fired.
      am.invokeMethod("handlePositionChangeEvent");
    }  
  
  }	// end processFormRequest()

}
