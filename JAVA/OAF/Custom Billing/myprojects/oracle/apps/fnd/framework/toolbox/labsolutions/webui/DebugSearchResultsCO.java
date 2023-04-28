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
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

/**
 * Controller for ...
 */
public class DebugSearchResultsCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: DebugSearchResultsCO.java 120.1 2005/06/06 10:50:08 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");


  /**
   * Procedure to handle form submissions for form elements in
   * a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);

    if (pageContext.getParameter("Create") != null)
    {

      pageContext.putParameter("pgMode", "CR");

	    pageContext.setForwardURL("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/labsolutions/webui/DebugLabCreatePG",
                                null,
                                OAWebBeanConstants.KEEP_MENU_CONTEXT,
								                null,
								                null,
								                true, // Retain AM
								                OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
								                OAWebBeanConstants.IGNORE_MESSAGES);

    }
  }

}
