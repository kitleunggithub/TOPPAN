/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.webui;

import java.io.Serializable;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.webui.beans.OAKeyFlexBean;

import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

/**
 * Controller for ...
 */
public class ItemDetailsCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: ItemDetailsCO.java 120.1 2005/06/06 11:21:36 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

  /**
   * Layout and page setup logic for a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    // Always call this first.
    super.processRequest(pageContext, webBean);

    // Get the itemNumber parameter from the URL
    String itemNumber = pageContext.getParameter("itemNumber");
  
    // Now we want to initialize the query for our single item
    // with all of its details. 
    OAApplicationModule am = pageContext.getApplicationModule(webBean);
    Serializable[] parameters = { itemNumber };
    am.invokeMethod("initDetails", parameters);

    OAKeyFlexBean flexBean = (OAKeyFlexBean)webBean.findIndexedChildRecursive("KeyFF");
    flexBean.setStructureCode("FWK Item Flexfield"); 
    flexBean.setCCIDAttributeName("FwkitemId"); 
    flexBean.mergeSegmentsWithParent(pageContext);

    // Now check to see if our "Results" VO has been queried so we can set the 
    // region header text accordingly.

    Serializable[] params = { "ItemDetailsVO1" };
    if ("Y".equals(am.invokeMethod("isVOQueried", params)))
    {
      flexBean.setRendered(true); // Render Key FF only after VO Queried
    }
  } // end processRequest()

}
