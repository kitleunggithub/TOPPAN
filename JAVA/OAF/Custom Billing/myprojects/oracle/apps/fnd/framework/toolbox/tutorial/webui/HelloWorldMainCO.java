/*===========================================================================+
 |      Copyright (c) 2001, 2016 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.nav.OALinkBean;
import oracle.apps.fnd.framework.webui.beans.nav.OATabBarBean;


/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.HelloWorldPG
 * page.
 */
public class HelloWorldMainCO extends OAControllerImpl
{
  // Required for Applications source control
  public static final String RCS_ID="$Header: HelloWorldMainCO.java 120.1.12020000.3 2016/02/02 02:05:51 spunam ship $";
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
  }

  /**
   * Procedure to handle form submissions for form elements in
   * region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);

    if (pageContext.getParameter("Go") != null)
    {
      // NEVER hard-code a message like this in your application.  This is just
      // shown for the sake of simplicity in this first lesson.  In the next
      // lessons you'll learn how to define translateable messages.

      String userContent = pageContext.getParameter("HelloName");
      String message = "Hello, " + userContent + "!";
      
      // Added code to test for the type cast of first and second level menus to OATabBarBean 
      // and OALinkBean respectively.
      OATabBarBean oaTabBarBean = (OATabBarBean)pageContext.getPageLayoutBean().getTabs();
      // Bug 21074917 - adsaxena - The code below works only when there are tabs on the page.
      // When Hello World page is run standalone this code throws a NullPointerException.
      // Added null check to handle this case.
      if(oaTabBarBean != null)
      {
        int selectedIndex = oaTabBarBean.getSelectedIndex();
        OALinkBean child  = (OALinkBean) oaTabBarBean.getIndexedChild(null,selectedIndex);
      }
      
      throw new OAException(message, OAException.INFORMATION);

    }
  }

}
