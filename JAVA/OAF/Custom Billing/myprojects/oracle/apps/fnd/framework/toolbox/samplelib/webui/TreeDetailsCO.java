/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.webui;

import oracle.cabo.ui.UINode;
import oracle.cabo.ui.beans.nav.LinkBean;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAPageLayoutBean;
import oracle.apps.fnd.framework.OAApplicationModule;
import java.io.Serializable;

/**
 * Controller for ...
 */
public class TreeDetailsCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: TreeDetailsCO.java 120.1 2005/06/06 13:14:41 atgops1 noship $";
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

    OAPageLayoutBean pageLayout = pageContext.getPageLayoutBean(); 
    pageLayout.prepareForRendering(pageContext); 
 
    UINode tabBar = pageLayout.getTabs(); 
 
    int childCount = 0; 
    if( tabBar != null ) 
    { 
      childCount = 
        tabBar.getIndexedChildCount(pageContext.getRenderingContext()); 
    } 
    
    for( int i=0; i<childCount; i++) 
    { 
      LinkBean child = 
        (LinkBean) tabBar.getIndexedChild(pageContext.getRenderingContext(), i); 
      if( child != null ) 
      { 
        child.setTargetFrame("_top"); 
      } 
    } 

    OAApplicationModule am = pageContext.getApplicationModule(webBean);

    // Get the employeeId parameter from the URL
    String employeeId = pageContext.getParameter("employeeId");
    Serializable[] parameters = { employeeId };
    am.invokeMethod("initDetails", parameters);
    
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
