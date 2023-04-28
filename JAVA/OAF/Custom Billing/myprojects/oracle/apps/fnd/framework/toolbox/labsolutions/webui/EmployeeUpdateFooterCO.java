/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.webui;

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
import oracle.apps.fnd.framework.webui.beans.form.OASubmitButtonBean;
import oracle.apps.fnd.framework.webui.beans.nav.OATrainBean;
/**
 * Controller for oracle.apps.fnd.framework.toolbox.labsolutions.webui.UpdateEmployeeFootRN 
 * region.
 */
public class EmployeeUpdateFooterCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: EmployeeUpdateFooterCO.java 120.1 2005/06/06 11:08:05 atgops1 noship $";
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

    // Figure out whether the "Submit" button should be rendered or not;
    // this should appear only on the final page (Step 3).

    OATrainBean trainBean = (OATrainBean)pageContext.getPageLayoutBean().getLocation(); 

    // You must call the following before getting the target page index.
    
    trainBean.prepareForRendering(pageContext);
    int step = trainBean.getSelectedTrainStepRenderedIndex(); 

    if (step + 1 != trainBean.getNumberOfRenderedTrainSteps())
    {
       OASubmitButtonBean submitButton = 
         (OASubmitButtonBean)webBean.findIndexedChildRecursive("Submit");      
     
        submitButton.setRendered(false);     
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

    // This button should only be displayed on the final page...
    
    if (pageContext.getParameter("Submit") != null)
    {
      am.invokeMethod("apply");

      // Indicate that the Update transaction is complete.
      TransactionUnitHelper.endTransactionUnit(pageContext, "empUpdateTxn");
      
      String employeeName = (String)pageContext.getTransactionValue("empName");

      // Assuming the "commit" succeeds, we'll display a Confirmation dialog that takes
	    // the user back to the main Employee search.
       
       MessageToken[] tokens = { new MessageToken("EMP_NAME", employeeName) };

       OAException confirmMessage = new OAException("AK", "FWK_TBX_T_EMP_UPDATE_CONFIRM", tokens);

       // The OK button will navigate the user back the summary page with the
       // root application module retained, so the original query results will
       // be cached.
       OADialogPage dialogPage = new OADialogPage(OAException.CONFIRMATION, 
                                                  confirmMessage,
                                                  null, 
                                                  pageContext.getApplicationJSP() + "?page=/oracle/apps/fnd/framework/toolbox/labsolutions/webui/EmpSearchPG&retainAM=Y", 
                                                  null);

       pageContext.redirectToDialogPage(dialogPage);
  
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
  } // end processFormRequest()
}
