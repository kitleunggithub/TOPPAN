/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |                                                                           |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import java.io.Serializable;

import oracle.bali.share.util.BooleanUtils;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.layout.OAHeaderBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.HomePG 
 * page's "Orders" region.
 */
public class HomePurchaseOrdersCO extends OAControllerImpl
{

  public static final String RCS_ID="$Header: HomePurchaseOrdersCO.java 120.1 2005/06/06 17:09:42 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.webui");


  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);

    // Want the header title to display at the appropriate size for the home page.
	  // This cannot be controlled by the CSS; must call the following method.

    ((OAHeaderBean)webBean).setSize(1);

    // Make sure the table renders correctly for a Home page.

    OATableBean poTable = (OATableBean)webBean.findIndexedChildRecursive("PoTable");

    if (poTable == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "PoTable") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }
    
    poTable.setTableNavigationDisplayed(false);	 // Don't display table navigation

    // Autoquery table.  Same as "show my PO's" but limit the time to the last 30 days
    
    OAApplicationModule am = pageContext.getApplicationModule(webBean);

    // The special query handling for the table is required per the coding
    // standards.
    
    Boolean executeQuery = BooleanUtils.getBoolean(false);
    Serializable[] parameters =  { null, "LAST_30_DAYS", "Y", executeQuery };
    Class[] paramTypes = { String.class, String.class, String.class, Boolean.class };
	  am.invokeMethod("initPOSummary", parameters, paramTypes);

    // Since we are querying a small number of rows, the table is view only,
    // and we always want to see the latest data, pass "false" to queryData()
    // so the OAF automatically requeries every time the page renders.
    poTable.queryData(pageContext, false);
 
  } // end processRequest()


  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);

    if (pageContext.getParameter("PoFullList") != null)
    {

      // Note that this lesson doesn't actually pass any parameters
      // to the target page, so it doesn't actually implement the
      // autoquery.  To make this work, you would need to pass 
      // something that the target controller could look at in processRequest() to 
      // determine whether it should autoquery.  If you do this,
      // you need to make sure the page doesn't autoquery every
      // time you redirect to it since any parameters that you
      // pass here will still be on the request when doing jsp
      // forwards.
      
	    pageContext.setForwardURL("FWK_TOOLBOX_PO_SEARCH",
                                GUESS_MENU_CONTEXT,
								                null,
								                null,
								                false, // Do not retain AM
								                ADD_BREAD_CRUMB_NO,
								                OAWebBeanConstants.IGNORE_MESSAGES);
    }


  } // end processFormRequest()

}
