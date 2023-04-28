/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;

import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADataBoundValueViewObject;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAHeaderBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;

/**
 * Controller for ...
 */
public class PartialPageExampleCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: PartialPageExampleCO.java 120.1 2005/06/06 13:05:47 atgops1 noship $";
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

   OAHeaderBean sitesHeader =
     (OAHeaderBean)webBean.findChildRecursive("SupplierSitesHeader");

   sitesHeader.setAttributeValue(OAWebBeanConstants.TEXT_ATTR,
        new OADataBoundValueViewObject(sitesHeader, "DetailTableText",
                                              "SampleBrowserPVO1"));

    OAApplicationModule am =
      (OAApplicationModule)pageContext.getApplicationModule(webBean);
    am.invokeMethod("initializePPRExamplePage");

    OATableBean table = (OATableBean)webBean.findChildRecursive("SuppliersTable");

    // Mark this table for querying by the OAF, but don't reexecute the query 
    // needlessly (passing "true" to queryData() ensures that the OAF does 
    // not execute the query if the VO has already been queried).  Since we 
    // are querying only a small number of seeded suppliers, we don't need to 
    // worry about picking up new suppliers in the query.
    table.queryData(pageContext, true);
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

    OAApplicationModule am =
        (OAApplicationModule)pageContext.getApplicationModule(webBean);

    String event = pageContext.getParameter("event");

    // If the user changes the value of the po approval poplist, call the
    // event hanlder in the AM to set the appropriate ApplicationsPropertiesVO
    // values.
    if ("approveList".equals(event))
    {
       am.invokeMethod("handlePoApproveChangeEvent");
    }
    else if ("supplierSelect".equals(event))
    {
       am.invokeMethod("handleSupplierSelectionEvent");
    }

  }

}
