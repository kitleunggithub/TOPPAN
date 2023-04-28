/*===========================================================================+
 |   Copyright (c) 2001, 2015 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.webui;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.OAStyledTextBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAFlowLayoutBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAPageLayoutBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAHeaderBean;
import oracle.apps.fnd.framework.webui.beans.nav.OASideBarBean;

/**
 * Controller for ...
 */
public class BasicStructCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: BasicStructCO.java 120.3.12020000.2 2015/12/14 08:54:53 spunam ship $";
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

    // Create a flow layout region to hold the prompt and data components.

    OAFlowLayoutBean userInfo = (OAFlowLayoutBean)createWebBean(pageContext,  
                                                                OAWebBeanConstants.FLOW_LAYOUT_BEAN,
                                                                null, "userInfo"); 
    OAStyledTextBean infoPrompt = (OAStyledTextBean)createWebBean(pageContext, 
                                                                  OAWebBeanConstants.STYLED_TEXT_BEAN,
                                                                  null, "infoPrompt"); 
    OAStyledTextBean infoText  = (OAStyledTextBean)createWebBean(pageContext, 
                                                                 OAWebBeanConstants.STYLED_TEXT_BEAN,
                                                                 null, "infoText");

    userInfo.addIndexedChild(infoPrompt); 
    userInfo.addIndexedChild(infoText); 

    // Set the content for the prompt and the user name based on the current
    // user.  Note that the prompt should be sourced from Message Dictionary and
    // not hard-coded as shown.

    infoPrompt.setText("User Name "); 
    infoText.setText(pageContext.getUserName()); 

    // Set the following styles to achieve the required look.
    // Bug 21368733 - Correcting the css classes
    infoPrompt.setCSSClass("OraPageStampLabel"); 
    infoText.setCSSClass("OraPageStampText"); 

    // Set the user info component on the page layout bean.
    OAPageLayoutBean pageLayout = (OAPageLayoutBean)webBean; 
    pageLayout.setUserInfo(userInfo); 

    //ER 4653771 : Code copied from Dev Guide for Side Navigation Bar implementation
    OASideBarBean sideBar = 
      (OASideBarBean)createWebBean(pageContext, SIDE_BAR_BEAN, null, "TbxSideBarRN");

    // We're using a header because we don't want any indentation before 
    // the start of the fields. Because we're using a simple header, we 
    // also need to add vertical spacing between the beans per the guidelines.
    OAHeaderBean search =      
    	(OAHeaderBean)createWebBean(pageContext,
    							"/oracle/apps/fnd/framework/toolbox/tutorial/webui/HomeSearchRN",
    							null, // ignore item for regions
    							true); // using JRAD
    
    sideBar.addIndexedChild(search);

    // Note that you don't have to do anything to get the correct CSS style
    // for the header text/line. This is handled for you automatically
    // by virtue of rendering a header bean on a dark background. The only 
    // thing you do have to change is the header text size, which can't be
    // changes with a CSS class. Instead, use the setSize() method that all
    // header beans have (the default layouts are header beans).
    search.setSize(2); // 2 is the smallest header size
    search.setText(pageContext, "Side Navigation Header");// Set Header Text

    // Note that you must call prepareForRendering() before setting your
    // side bar bean or it won't render.
    pageLayout.prepareForRendering(pageContext);
    pageLayout.setStart(sideBar);
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
