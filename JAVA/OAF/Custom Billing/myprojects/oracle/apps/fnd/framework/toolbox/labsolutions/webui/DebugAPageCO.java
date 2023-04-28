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
public class DebugAPageCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: DebugAPageCO.java 120.1 2005/06/06 10:41:07 atgops1 noship $";
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

    boolean isNew = pageContext.isAMStateNew();
    String bVal = (String)pageContext.getTransactionValue("BPageVal");
    String aVal = (String)pageContext.getTransactionValue("APageVal");

    if (aVal == null)
    {
      pageContext.putTransactionValue("APageVal", "A");
    }  
  }

  /**
   * Procedure to handle form submissions for form elements in
   * a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);

    if (pageContext.getParameter("PageBRetain") != null)
    {

	    pageContext.setForwardURL("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/labsolutions/webui/DebugBPG",
                                null,
                                OAWebBeanConstants.KEEP_MENU_CONTEXT,
								                null,
								                null,
								                true, // Retain AM
								                OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
								                OAWebBeanConstants.IGNORE_MESSAGES);
      
    }
    else if (pageContext.getParameter("PageBNoRetain") != null)
    {
      pageContext.setForwardURL("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/labsolutions/webui/DebugBPG",
                                null,
                                OAWebBeanConstants.KEEP_MENU_CONTEXT,
								                null,
								                null,
								                false, // Do not retain AM
								                OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
								                OAWebBeanConstants.IGNORE_MESSAGES);
    }
  }

}
