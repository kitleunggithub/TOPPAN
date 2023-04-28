/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

/**
 * Controller for ...
 */
public class EmployeeReviewCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: EmployeeReviewCO.java 120.1 2005/06/06 11:03:36 atgops1 noship $";
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

    // Guard agains the user being able to perform a form submit on this page
    // after the transaction is completed.  If the user navigates back to this
    // page using the browser Back button after successfully committing, the
    // OA Framework will detect this navigation and step through processRequest()
    // first when the user tries to perform any action that causes the
    // form to be submitted.  This will display a state loss error dialog
    // if this happens.
    if (!TransactionUnitHelper.isTransactionUnitInProgress(pageContext, "empUpdateTxn", true))
    { 
       // Please use a custom message for the dialog page!
       OADialogPage dialogPage = new OADialogPage(STATE_LOSS_ERROR); 
       pageContext.redirectToDialogPage(dialogPage); 
     }

  } // end processRequest()

}
