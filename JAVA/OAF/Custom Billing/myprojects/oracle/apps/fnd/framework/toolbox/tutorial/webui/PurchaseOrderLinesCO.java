/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import oracle.cabo.ui.data.DictionaryData;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;
/**
 * Controller for FWK_TBX_T_LSN6_ITEMS
 */
public class PurchaseOrderLinesCO extends OAControllerImpl
{
  // Required for Applications source control
  public static final String RCS_ID="$Header: PurchaseOrderLinesCO.java 120.1 2005/06/06 17:38:29 atgops1 noship $";
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

    OATableBean table = (OATableBean)webBean.findIndexedChildRecursive("ItemsTable");

    if (table == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "ItemsTable") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }
    // This must be called afer the query is executed, and before the table
    // formatting.
    
    table.prepareForRendering(pageContext);

    // Now set the table style to use row banding for every other row. Note that
    // this must be called after prepareForRendering() which must be called whenever
    // you need to do any table formatting.

    DictionaryData tableFormat = new DictionaryData();
    tableFormat.put(TABLE_BANDING_KEY, ROW_BANDING);
    table.setTableFormat(tableFormat);

    } // end processRequest()

}
