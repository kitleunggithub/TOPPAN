/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.table.OAAddTableRowBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;
import oracle.apps.fnd.framework.webui.beans.nav.OATrainBean;
import oracle.apps.fnd.framework.webui.beans.nav.OANavigationBarBean;
/**
 * Controller for 
 */
public class PoLinesPageCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: PoLinesPageCO.java 120.3 2006/05/25 02:08:19 atgops1 noship $";
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

    if (!TransactionUnitHelper.isTransactionUnitInProgress(pageContext, "poCreateTxn", true))
    { 
       // Please use a custom message for the dialog page!
       OADialogPage dialogPage = new OADialogPage(STATE_LOSS_ERROR); 
       pageContext.redirectToDialogPage(dialogPage); 
     }

    OATableBean table = 
      (OATableBean)webBean.findIndexedChildRecursive("LinesTable");
    
    // Configure the table to include an "Add a Row" button.  Let the Framework
    // go ahead and call create/insert on the VO when the user presses it.
    
    table.setInsertable(true);
    table.setAutoInsertion(false); // we need to handle the button ourselves
    table.prepareForRendering(pageContext);

    // Instead of displaying the default "Add Another Row" we want to display
    // a button label that is a bit more precise for the UI.

    String buttonLabel = 
      pageContext.getMessage("AK", "FWK_TBX_T_ADD_ANOTHER_ITEM", null);
    OAAddTableRowBean addRow = (OAAddTableRowBean)table.getNamedChild(null,COLUMN_FOOTER_CHILD);
    addRow.setText(buttonLabel);

    //Dynamically set Interactive Train & render Updateable Step Indicator or View-Only Step Indicator 
    //based on the value of the parameter "Train" which is got from the session
    OATrainBean train = (OATrainBean)webBean.findChildRecursive("TrainRN");
    OANavigationBarBean navBarBasic = (OANavigationBarBean)webBean.findChildRecursive("BasicNavBar");
    OANavigationBarBean navBarIT = (OANavigationBarBean)webBean.findChildRecursive("ITNavBar");
    if (pageContext.getSessionValue("Train").equals("Basic"))
    {
      train.setAllowInteraction(false);
      navBarBasic.setRendered(true);
      navBarIT.setRendered(false);
    }
    else if (pageContext.getSessionValue("Train").equals("IT"))
    {
      train.setAllowInteraction(true);
      navBarBasic.setRendered(false);
      navBarIT.setRendered(true);
    }  
  }

    /**
   * Procedure to handle form submissions for form elements in
   * region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);

    if (ADD_ROWS_EVENT.equals(pageContext.getParameter(EVENT_PARAM)))
    {
      OAApplicationModule am = pageContext.getApplicationModule(webBean);
      am.invokeMethod("createLineItem", null); 
    }
  } // end processFormRequest()
}
