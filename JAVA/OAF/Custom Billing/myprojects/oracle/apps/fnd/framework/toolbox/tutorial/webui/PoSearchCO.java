/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import java.io.Serializable;

import oracle.bali.share.util.BooleanUtils;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAQueryUtils;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.PoSearchPG 
 * page's "Search" region.
 */
public class PoSearchCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: PoSearchCO.java 120.1 2005/06/06 17:27:23 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.webui");


  /**
   * Procedure to handle form submissions for form elements in
   * region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);

    // Pressing the Go button causes the search to be executed.

    if (pageContext.getParameter("Go") != null)
    {

      // Check for selective search criteria in the manually created search
      // region. Note that you must pass the region which is a the direct parent
      // of the search fields to test.
      OAQueryUtils.checkSelectiveSearchCriteria(pageContext, webBean);
      
	    String orderNumber = pageContext.getParameter("SearchOrder");
	    String created = pageContext.getParameter("Created");
	    String showMyOrders = pageContext.getParameter("MyOrders");

      OAApplicationModule am = (OAApplicationModule)pageContext.getApplicationModule(webBean);

      // All parameters passed using invokeMethod() must be serializable.

      // Note the following is required for viw object initialization standards
      // around tables.
      Boolean executeQuery = BooleanUtils.getBoolean(false);
	    Serializable[] parameters =  { orderNumber, created, showMyOrders, executeQuery };
      Class[] paramTypes = { String.class, String.class, String.class, Boolean.class };
      am.invokeMethod("initSummary", parameters, paramTypes);

      OAAdvancedTableBean table = 
        (OAAdvancedTableBean)webBean.findChildRecursive("ResultsTable");

      // When handling a user initiated search, we always need to execute
      // the query so we pass "false" to queryData().
      table.queryData(pageContext, false);
    }
  } // end processFormRequest();

}
