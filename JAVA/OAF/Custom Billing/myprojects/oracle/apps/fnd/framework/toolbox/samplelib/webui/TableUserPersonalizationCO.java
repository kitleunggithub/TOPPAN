/*===========================================================================+
 |   Copyright (c) 2001, 2018 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.fnd.framework.toolbox.samplelib.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;

/**
 * Controller for ...
 */
public class TableUserPersonalizationCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: TableUserPersonalizationCO.java 120.0.12020000.3 2018/10/16 06:02:48 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.samplelib.webui");

  /**
   * Layout and page setup logic for a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);
    
    OAAdvancedTableBean table = (OAAdvancedTableBean)  webBean.findChildRecursive("TableRN");
    table.queryData(pageContext, true);
    
    OATableBean classicTable = (OATableBean)  webBean.findChildRecursive("classicTableRN");
    classicTable.queryData(pageContext, true);
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
  }

}
