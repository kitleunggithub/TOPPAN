/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |                                                                           |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAHeaderBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.labsolutions.webui.HomePG 
 * page's "Notifications" region.
 */
public class HomeNotificationsCO extends OAControllerImpl
{

  public static final String RCS_ID="$Header: HomeNotificationsCO.java 120.1 2005/06/06 11:14:52 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.webui");


  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    // Always call this first.
    super.processRequest(pageContext, webBean);

    // Required by shared Worklist component.
    pageContext.putParameter("WFHomeWorklist", "Y");

    // Want the header title to display at the appropriate size for the home page.
	  // This cannot be controlled by the CSS; must call the following method.
    ((OAHeaderBean)webBean).setSize(1);

  } // end processRequest()


  // Note that the Worklist does it's own "Full List" button handling.

  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);

  } // end processFormRequest()

}
