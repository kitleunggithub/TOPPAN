/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

/**
 * Controller for FWK_TBX_T_LSN7_1PAGE region
 */
public class PoSummaryCreateMainCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: PoSummaryCreateMainCO.java 120.1 2005/06/06 17:31:46 atgops1 noship $";
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

    // Set page context parameter values to configure the reusable "Orders" region
    // to only show the "Create Purchase Order" action.
    
    pageContext.putParameter("showUpdate", "N");
    pageContext.putParameter("showApprove", "N");
    pageContext.putParameter("showDelete", "N");

    // Set a page context parameter telling the shared "Order Summary" region
    // to query purchase orders in all statuses.  This just simulates how you
    // might execute different queries on a "black box" shared region.

    pageContext.putParameter("queryStatus", "ALL");
   
  }

}
