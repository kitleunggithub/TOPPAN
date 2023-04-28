/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |                                                                           |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAHeaderBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.HomePG 
 * page's "Notifications" region.
 */
public class HomeNotificationsCO extends OAControllerImpl
{

  public static final String RCS_ID="$Header: HomeNotificationsCO.java 120.1 2005/06/06 17:05:09 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.webui");


  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);

// The following code is required only for 11.5.9 releases and earlier.
/*
    pageContext.putSessionValue("WFWorklistPage", 
                                "/oracle/apps/fnd/framework/toolbox/tutorial/webui/HomePG");
*/
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
