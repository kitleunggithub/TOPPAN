/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageStyledTextBean;
import oracle.apps.fnd.framework.webui.beans.nav.OATrainBean;
import oracle.apps.fnd.framework.webui.beans.nav.OANavigationBarBean;
/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.PoReviewPG 
 * page.
 */
public class PoReviewPageCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: PoReviewPageCO.java 120.2 2006/05/25 02:12:36 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.webui");

  /**
   * Layout and page setup logic for region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the AK region
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

    OAMessageStyledTextBean poNumberBean = 
        (OAMessageStyledTextBean)webBean.findIndexedChildRecursive("OrderNum");

    if (poNumberBean == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "OrderNum") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }    
        
    String poNumber = (String)poNumberBean.getValue(pageContext);

    pageContext.putTransactionValue("PO_NUMBER", poNumber);
   
    //Dynamically set Interactive Train & render Updateable Step Indicator or View-Only Step Indicator 
    //based on the value of the parameter "Train" which is got from the session
    OATrainBean train = (OATrainBean)webBean.findChildRecursive("TrainRegion");
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
  } // end processRequest()

}
