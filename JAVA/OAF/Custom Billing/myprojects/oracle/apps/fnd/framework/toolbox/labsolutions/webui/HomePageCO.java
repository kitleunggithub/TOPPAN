/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |                                                                           |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.OAStaticStyledTextBean;
import oracle.apps.fnd.framework.webui.beans.layout.OABulletedListBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAContentContainerBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAPageLayoutBean;


/**
 * Controller for oracle.apps.fnd.framework.toolbox.labsolutions.webui.HomePG 
 * page.
 */
public class HomePageCO extends OAControllerImpl
{

  public static final String RCS_ID="$Header: HomePageCO.java 120.1 2005/06/06 11:19:17 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.webui");


  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    // Always call this first.
    super.processRequest(pageContext, webBean);
    
    // Add the content container on the right side of the page.
    
/*
** DEBUG -- is there any way to set the width of the "end" to be 25% of the page?
** the UI guidelines say content containers should ideally be between 25% - 33% of the page
** width, and should expand.  You can also set an absolute width.
*/
    String CONTAINER_WIDTH = "220";
    
    // Get translated strings for content container text
    String ancillaryHeaderText = pageContext.getMessage("AK", "FWK_TBX_T_ANCILLARY_GENERAL", null);
    String ancillaryIntroText = pageContext.getMessage("AK", "FWK_TBX_T_INTRO_GENERAL", null);

    // Create the "Ancillary Content" container
    OAContentContainerBean ancillaryContentContainer = 
      (OAContentContainerBean)createWebBean(pageContext, CONTENT_CONTAINER_BEAN, null, "ancillary");
    ancillaryContentContainer.setBackground(BACKGROUND_LIGHT);
    ancillaryContentContainer.setIcon(APPS_MEDIA_DIRECTORY + "bullseyeicon_cctitle.gif"); 
    ancillaryContentContainer.setText(ancillaryHeaderText);

    ancillaryContentContainer.setWidth(CONTAINER_WIDTH); 
    
    // Add the bulleted list to the "Ancillary Content" container
    OABulletedListBean bulletList = 
      (OABulletedListBean)createWebBean(pageContext, BULLETED_LIST_BEAN, null, "bulletList");
    bulletList.setRows(Integer.MAX_VALUE); // Never split the bullet list into 2 columns

    String yahooText = pageContext.getMessage("AK", "FWK_TBX_T_VISIT_YAHOO", null);
    String bulletText = pageContext.getMessage("AK", "FWK_TBX_T_BULLET_GENERAL", null);

    String yahooUrl = "http://www.yahoo.com";
    
    OAStaticStyledTextBean bulletTextOne = 
      (OAStaticStyledTextBean)createWebBean(pageContext, STATIC_STYLED_TEXT_BEAN, null, "textOne");
    bulletTextOne.setText(pageContext, yahooText);
    bulletTextOne.setCSSClass("OraLinkText");
    bulletTextOne.setDestination(yahooUrl); 
    bulletList.addIndexedChild(bulletTextOne);

    OAStaticStyledTextBean bulletTextTwo = 
      (OAStaticStyledTextBean)createWebBean(pageContext, STATIC_STYLED_TEXT_BEAN, null, "textTwo");
    bulletTextTwo.setText(pageContext, yahooText);
    bulletTextTwo.setCSSClass("OraLinkText");
    bulletTextTwo.setDestination(yahooUrl); 
    bulletList.addIndexedChild(bulletTextTwo);

    OAStaticStyledTextBean bulletTextThree = 
      (OAStaticStyledTextBean)createWebBean(pageContext, STATIC_STYLED_TEXT_BEAN, null, "textThree");
    bulletTextThree.setText(pageContext, yahooText);
    bulletTextThree.setCSSClass("OraLinkText");
    bulletTextThree.setDestination(yahooUrl); 
    bulletList.addIndexedChild(bulletTextThree);

    OAStaticStyledTextBean bulletTextFour = 
      (OAStaticStyledTextBean)createWebBean(pageContext, STATIC_STYLED_TEXT_BEAN, null, "textFour");
    bulletTextFour.setText(pageContext, bulletText);
    bulletTextFour.setCSSClass("OraLinkText");
    bulletTextFour.setDestination(yahooUrl); 
    bulletList.addIndexedChild(bulletTextFour);

    ancillaryContentContainer.addIndexedChild(bulletList);

    // Add the content containers to their stack layout, and add the stack
    // layout as the named "end" child on the page layout.
    OAPageLayoutBean pageLayoutBean = pageContext.getPageLayoutBean();
    pageLayoutBean.setEnd(ancillaryContentContainer);

  
  } // end processRequest()
  

}
