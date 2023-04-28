/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.webui;

import java.io.Serializable;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

/**
 * Controller for ...
 */
public class EmployeeDescriptionCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: EmployeeDescriptionCO.java 120.1 2005/06/06 10:56:54 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

  /**
   * Layout and page setup logic for a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    // Always call this first.
    super.processRequest(pageContext, webBean);

    // This test checks for valid navigation from the Update icon.
    // It also checks to see if the user navigated to this page
    // using the OANavigationBarBean Back button (in this case, when we have a
    // valid navigation back to this page from a subsequent page within the
    // multistep transaction, we don't want to reinitialize the employee
    // and lose the user's work).
    if (!pageContext.isBackNavigationFired(false) &&
          (!"goto".equals(pageContext.getParameter(EVENT_PARAM))))
    {

        // We are indicating that we are at the state of the Update transaction.
        TransactionUnitHelper.startTransactionUnit(pageContext, "empUpdateTxn");

        // We'll use this at the end of the flow for a confirmation message.
        String empName = pageContext.getParameter("empName");
        pageContext.putTransactionValue("empName", empName);

        String empNum = pageContext.getParameter("empNum");
        Serializable[] params = { empNum };
        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        // For the update, since we're using the same VO as the "Details" page, we
        // can use the same initialization logic.
        am.invokeMethod("initDetails", params);

    }
    else
    {
      // Guard agains the user being able to perform a form submit on this page
      // after the transaction is completed.  If the user navigates back to this
      // page using the browser Back button after successfully committing, the
      // OA Framework will detect this navigation and step through processRequest()
      // first when the user tries to perform any action that causes the
      // form to be submitted.  This will display a state loss error dialog
      // if this happens.
      if (!TransactionUnitHelper.isTransactionUnitInProgress(pageContext, "empUpdateTxn", true))
      {
        // Please use a custom message for the dialog page! The more explicit,
        // the better.
        OADialogPage dialogPage = new OADialogPage(STATE_LOSS_ERROR);
        pageContext.redirectToDialogPage(dialogPage);
      } 
    }
  } // end processRequest()
}
