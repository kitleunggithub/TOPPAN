/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 //javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.beans.nav.OATrainBean;
import oracle.apps.fnd.framework.webui.beans.nav.OANavigationBarBean;
import oracle.apps.fnd.framework.webui.beans.OAStaticStyledTextBean; 

/**
 * Controller for ...
 */
public class PoDescriptionPageCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: PoDescriptionPageCO.java 120.6 2006/06/18 10:26:54 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

  /**
   * Layout and page setup logic for a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);
   
    // If isBackNavigationFired = false, we're here after a valid navigation
    // and we should proceed normally.
    // isBackNavigationFired(false /* trackFormSubmitOnly */) tracks the
    // browser back button event for non-form-submit request case as well.
    // We don't want to create a redundant new record whenever user reloads
    // the Create page, so tracking non-form-submit case as well.

    // Also, if the user navigates back to this flow by selecting the Back
    // button in the next page in the multipage flow, we don't want to do
    // anything on this page (we don't want to recreate the PO, and we don't
    // want to display a state loss error).

    if (!pageContext.isBackNavigationFired(false) && 
        (!"goto".equals(pageContext.getParameter(EVENT_PARAM))))
    {    
        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        TransactionUnitHelper.startTransactionUnit(pageContext, "poCreateTxn");

        if (!pageContext.isFormSubmission())
        {
          // Ask the application module to initialize an employee so the
          // user can complete it.
          am.invokeMethod("createPurchaseOrder");
        }  
    }
    else 
    { 
      if (!TransactionUnitHelper.isTransactionUnitInProgress(pageContext, "poCreateTxn", true))
      { 
        OADialogPage dialogPage = new OADialogPage(STATE_LOSS_ERROR); 
        pageContext.redirectToDialogPage(dialogPage); 
      } 
    }

    //Dynamically set Interactive Train & render Updateable Step Indicator or View-Only Step Indicator 
    //based on the value of the parameter "Train" which is got from the session
    OATrainBean train = (OATrainBean)webBean.findChildRecursive("TrainRN");
    OANavigationBarBean navBarBasic = (OANavigationBarBean)webBean.findChildRecursive("BasicNavBar");
    OANavigationBarBean navBarIT = (OANavigationBarBean)webBean.findChildRecursive("ITNavBar");
    OAStaticStyledTextBean pageHelp = (OAStaticStyledTextBean)webBean.findChildRecursive("PageHelp");
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
      String instrTextValue = pageContext.getMessage("FND", "FWK_TBX_T_ITRAIN_INSTRUCTION", null);
      pageHelp.setText(instrTextValue);
    }    
  } // end processRequest()
}
