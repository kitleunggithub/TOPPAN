/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.webui;

import java.io.Serializable;

import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.labsolutions.webui.EmployeePG 
 * page.
 */
public class EmployeeUpdateCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: EmployeeUpdateCO.java 120.1 2005/06/06 11:05:50 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.webui");


  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
      // Always call this first.
      super.processRequest(pageContext, webBean);

      // Put a transaction value indicating that the update transaction
      // is now in progress.
      TransactionUnitHelper.startTransactionUnit(pageContext, "empUpdateTxn");

      String empName = pageContext.getParameter("empName");
      // We'll use this at the end of the flow for a confirmation message.
      pageContext.putTransactionValue("empName", empName);
      
      String empNum = pageContext.getParameter("empNum");
      Serializable[] params = { empNum };
      
      OAApplicationModule am = pageContext.getApplicationModule(webBean);

      // For the update, since we're using the same VO as the "Details" page, we
      // can use the same initialization logic.
      am.invokeMethod("initDetails", params);

      // Iniitalize the ApplicationPropertiesVO for PPR.
      am.invokeMethod("init");

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
     
      OAViewObject vo = (OAViewObject)am.findViewObject("EmployeeFullVO1");
        
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

      // Indicate that the Update transaction is complete.
      TransactionUnitHelper.endTransactionUnit(pageContext, "empUpdateTxn");
    
      // Assuming the "commit" succeeds, navigate back to the "Search" page with 
      // the user's search criteria intact and display a "Confirmation" message
      // at the top of the page.

      MessageToken[] tokens = { new MessageToken("EMP_NAME", employeeName),
                                 new MessageToken("EMP_NUMBER", employeeNum) };

                                 
      OAException confirmMessage = new OAException("AK", "FWK_TBX_T_EMP_UPDATE_CONFIRM", tokens,
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

       // Indicate that the Update transaction is complete.
       TransactionUnitHelper.endTransactionUnit(pageContext, "empUpdateTxn");
       
       pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/labsolutions/webui/EmpSearchPG",
                                      null,
                                      OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                      null,
                                      null,
                                      true, // retain AM
                                      OAWebBeanConstants.ADD_BREAD_CRUMB_NO);    
    }
  
  }	// end processFormRequest()

}
