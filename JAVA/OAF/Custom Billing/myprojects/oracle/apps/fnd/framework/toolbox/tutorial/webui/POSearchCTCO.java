/*===========================================================================+
 |   Copyright (c) 2001, 2015 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import java.io.Serializable;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAQueryUtils;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;

import oracle.bali.share.util.BooleanUtils;

import oracle.cabo.ui.data.ArrayDataSet;
import oracle.cabo.ui.data.DictionaryData;


/**
 * Controller for ...
 */
public class POSearchCTCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: POSearchCTCO.java 120.0.12020000.3 2015/04/14 07:36:33 spunam noship $";
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
      OATableBean table = (OATableBean)webBean.findIndexedChildRecursive("ResultsTable");
      int childCount = table.getIndexedChildCount(null); 
      DictionaryData columnHeaderFormats[] = new DictionaryData[childCount];
      for (int i = 0; i < childCount; i++) 
      { 
        columnHeaderFormats[i] = new DictionaryData();
        columnHeaderFormats[i].put(CELL_NO_WRAP_FORMAT_KEY, Boolean.TRUE); 
      }
      table.setColumnHeaderFormats(new ArrayDataSet(columnHeaderFormats));
      table.setRefreshEnabled(false);
      table.queryData(pageContext,false);
      table.setAttributeValue(CONTROLBAR_RENDERING_STYLE,BUTTON_FORMAT);
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

        OATableBean table = 
          (OATableBean)webBean.findChildRecursive("ResultsTable");

        // When handling a user initiated search, we always need to execute
        // the query so we pass "false" to queryData().
        table.queryData(pageContext, false);
      }
  }

}
