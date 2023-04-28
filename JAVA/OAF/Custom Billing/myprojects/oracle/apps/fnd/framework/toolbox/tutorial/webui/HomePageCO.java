/*===========================================================================+
 |      Copyright (c) 2001, 2017 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |                                                                           |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.OAStaticStyledTextBean;
import oracle.apps.fnd.framework.webui.beans.OAImageBean;
import oracle.apps.fnd.framework.webui.beans.layout.OABulletedListBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAContentContainerBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAHeaderBean;
import oracle.apps.fnd.framework.webui.beans.layout.OATableLayoutBean;
import oracle.apps.fnd.framework.webui.beans.layout.OARowLayoutBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAStackLayoutBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAPageLayoutBean;
import oracle.apps.fnd.framework.webui.beans.layout.OACellFormatBean;
import oracle.apps.fnd.framework.webui.beans.nav.OASideNavBean;


/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.HomePG 
 * page.
 */
public class HomePageCO extends OAControllerImpl
{

  public static final String RCS_ID="$Header: HomePageCO.java 120.4.12020000.3 2017/04/27 08:31:11 spunam ship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.webui");


  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);

    // Add the content containers on the right side of the page.
    
    layoutContentContainers(pageContext, webBean);

    // Add the "side nav" on the left side of the page.
    
    layoutSideNav(pageContext, webBean);

  } // end processRequest()


  private void layoutSideNav(OAPageContext pageContext, OAWebBean webBean)
  {
    OASideNavBean sideNav = 
      (OASideNavBean)createWebBean(pageContext, SIDE_NAV_BEAN, null, "hpSideNav");

    // We're using a header instead of a default single column
    // because we don't want any indentation before the start of the fields.
    // Because we're using a simple header, we also need to add vertical spacing
    // between the beans per the guidelines.  
    
    OAHeaderBean search =
      (OAHeaderBean)createWebBean(pageContext, 
                                        "/oracle/apps/fnd/framework/toolbox/tutorial/webui/HomeSearchRN", 
                                        null, // ignore item for regions
                                        true); // using JRAD
     
    OAHeaderBean quickLinks =
     (OAHeaderBean)createWebBean(pageContext, 
                                              "/oracle/apps/fnd/framework/toolbox/tutorial/webui/HomeLinksRN", 
                                              null, // ignore item for regions
                                              true); // using JRAD

    sideNav.addIndexedChild(search);
    sideNav.addIndexedChild(quickLinks);

    String quickLinksText = pageContext.getMessage("AK", "FWK_TBX_T_QUICK_LINKS", null);
    String searchText = pageContext.getMessage("AK", "FWK_TBX_T_SEARCH", null);

    // Note that you don't have to do anything to get the correct CSS style
    // for the header text/line.  This is handled for you automatically
    // by virtue of rendering a header bean on a dark background.  The only 
    // thing you do have to change is the header text size, which can't be
    // changes with a CSS class.  Instead, use the setSize() method that all
    // header beans have (the default layouts are header beans).

    search.setSize(2); // 2 is the smallest header size
    search.setText(pageContext, searchText);
    
    quickLinks.setSize(2); // 2 is the smallest header size
    quickLinks.setText(pageContext, quickLinksText);

    // Note that you must call prepareForRendering() before setting your
    // side nav bean or it won't render.
    
    OAPageLayoutBean pageLayoutBean = pageContext.getPageLayoutBean();
    pageLayoutBean.prepareForRendering(pageContext);
    pageLayoutBean.setStart(sideNav);
    
  } // end layoutSideNav()


  private void layoutContentContainers(OAPageContext pageContext, OAWebBean webBean)
  {
  
/*
** LIZA DEBUG -- is there any way to set the width of the "end" to be 25% of the page?
** the UI guidelines say content containers should ideally be between 25% - 33% of the page
** width, and should expand.  You can also set an absolute width.
*/
    String CONTAINER_WIDTH = "220";
    
    // Get translated strings for content container text

    String ancillaryHeaderText = pageContext.getMessage("AK", "FWK_TBX_T_ANCILLARY_GENERAL", null);
    String ancillaryIntroText = pageContext.getMessage("AK", "FWK_TBX_T_INTRO_GENERAL", null);

    // Create the layout to which the content containers will be added
    
    OAStackLayoutBean rightContent = 
      (OAStackLayoutBean)createWebBean(pageContext, STACK_LAYOUT_BEAN, null, "ccStackLayout");

    // Create the "Ancillary Content" container
    
    OAContentContainerBean ancillaryContentContainer = 
      (OAContentContainerBean)createWebBean(pageContext, CONTENT_CONTAINER_BEAN, null, "ccAncillary");
    ancillaryContentContainer.setBackground(BACKGROUND_LIGHT);
    ancillaryContentContainer.setIcon(APPS_MEDIA_DIRECTORY + "bullseyeicon_cctitle.gif"); 
    ancillaryContentContainer.setText(ancillaryHeaderText);

    ancillaryContentContainer.setWidth(CONTAINER_WIDTH); 
    
    // Add the bulleted list to the "Ancillary Content" container
    
    OABulletedListBean bulletList = 
      (OABulletedListBean)createWebBean(pageContext, BULLETED_LIST_BEAN, null, "ccBulletList");
    bulletList.setRows(Integer.MAX_VALUE); // Never split the bullet list into 2 columns

    String yahooText = pageContext.getMessage("AK", "FWK_TBX_T_VISIT_YAHOO", null);
    String bulletText = pageContext.getMessage("AK", "FWK_TBX_T_BULLET_GENERAL", null);

    String yahooUrl = "http://www.yahoo.com";
    doBulletRow(pageContext, bulletList, yahooText, yahooUrl, "row1");
    doBulletRow(pageContext, bulletList, bulletText, yahooUrl, "row2");
    doBulletRow(pageContext, bulletList, bulletText, yahooUrl, "row3");
    doBulletRow(pageContext, bulletList, bulletText, yahooUrl, "row4");

    ancillaryContentContainer.addIndexedChild(bulletList);

    String moreContentHeaderText = pageContext.getMessage("AK", "FWK_TBX_T_MORE_CONTENT", null);
    OAContentContainerBean moreContentContainer = 
      (OAContentContainerBean)createWebBean(pageContext, CONTENT_CONTAINER_BEAN, null, "ccMore");
    moreContentContainer.setBackground(BACKGROUND_LIGHT);
    moreContentContainer.setText(moreContentHeaderText);
    moreContentContainer.setWidth(CONTAINER_WIDTH);

    // Create the "More Content" container
    
    doMoreLayout(pageContext, moreContentContainer);

    // Add the content containers to their stack layout, and add the stack
    // layout as the named "end" child on the page layout.

    rightContent.addIndexedChild(ancillaryContentContainer);

    // At present, there isn't a clear UI guideline stipulating space between
    // two content containers, so we'll use the standard spacer between buttons
    // and fields since it's just a bit bigger than the standard space between
    // fields -- and looks better. 
    
    rightContent.addIndexedChild(createWebBean(pageContext, BUTTON_SPACER_ROW_BEAN, null, "ccSpacer"));
    rightContent.addIndexedChild(moreContentContainer);
    
    OAPageLayoutBean pageLayoutBean = pageContext.getPageLayoutBean();
    pageLayoutBean.setEnd(rightContent);

  } // end layoutContentContainers()


  private void doMoreLayout(OAPageContext pageContext, OAWebBean webBean)
  {
    OATableLayoutBean table = 
      (OATableLayoutBean)createWebBean(pageContext, TABLE_LAYOUT_BEAN, null, "moreTableLayout");
    webBean.addIndexedChild(table);

    String bubbleLabelOne = pageContext.getMessage("AK", "FWK_TBX_T_BUBBLE_LABEL_ONE", null);
    String bubbleLabelTwo = pageContext.getMessage("AK", "FWK_TBX_T_BUBBLE_LABEL_TWO", null);
    String bubbleLabelThree = pageContext.getMessage("AK", "FWK_TBX_T_BUBBLE_LABEL_THREE", null);

    // Define the content region that displays to the right of the "dots" graphic.
    OAStackLayoutBean dotsContent = 
      (OAStackLayoutBean)createWebBean(pageContext, STACK_LAYOUT_BEAN, null, "ccDotsStack");

    String linkLabel = pageContext.getMessage("AK", "FWK_TBX_T_LINK_GENERAL", null);

    OAStaticStyledTextBean link = 
      (OAStaticStyledTextBean)createWebBean(pageContext, STATIC_STYLED_TEXT_BEAN, null, null);
    link.setText(pageContext, linkLabel);
    link.setCSSClass("OraLinkText");
    link.setDestination("http://www.yahoo.com");

    // In real life, each of these links would of course be different...
    
    dotsContent.addIndexedChild(link);
    dotsContent.addIndexedChild(link);

    // Now construct the content row by row

    doBubbleRow(pageContext, table, bubbleLabelOne, "row1");
    doDotsRow(pageContext, table, dotsContent, "row1");
    doBubbleRow(pageContext, table, bubbleLabelTwo, "row2");
    doDotsRow(pageContext, table, dotsContent, "row2");
    doBubbleRow(pageContext, table, bubbleLabelThree, "row3");
    doDotsRow(pageContext, table, dotsContent, "row3");
    

  } // end doMoreLayout()
  


  private void doBulletRow(OAPageContext pageContext, 
                             OAWebBean parentBean, 
                             String text, 
                             String url,
                             String linkId)
  {
  
    OAStaticStyledTextBean bulletText = 
      (OAStaticStyledTextBean)createWebBean(pageContext, STATIC_STYLED_TEXT_BEAN, null, "linkText" + linkId);
    bulletText.setText(pageContext, text);
    bulletText.setCSSClass("OraLinkText");
    bulletText.setDestination(url); 
    parentBean.addIndexedChild(bulletText);
    
  } // end doBulletRow()


  private void doDotsRow(OAPageContext pageContext, 
                           OAWebBean parentBean, 
                           OAWebBean content, 
                           String rowId)
  {
    String IMAGE_SIZE = "23"; // image is 23 x 23
    String SPACER_SIZE = "8";
    
    OARowLayoutBean row = 
      (OARowLayoutBean)createWebBean(pageContext, ROW_LAYOUT_BEAN, null, "dotsRow" + rowId);
    parentBean.addIndexedChild(row);

    OACellFormatBean imageCell = 
      (OACellFormatBean)createWebBean(pageContext, CELL_FORMAT_BEAN, null, "dotsImageCell" + rowId);
    OACellFormatBean spaceCell = 
      (OACellFormatBean)createWebBean(pageContext, CELL_FORMAT_BEAN, null, "dotsSpaceCell" + rowId);
    OACellFormatBean contentCell = 
      (OACellFormatBean)createWebBean(pageContext, CELL_FORMAT_BEAN, null, "dotsContentCell" + rowId);

    row.addIndexedChild(imageCell);
    row.addIndexedChild(spaceCell);
    row.addIndexedChild(contentCell);

    imageCell.setHAlign(H_ALIGN_CENTER); 
    imageCell.setVAlign(V_ALIGN_TOP);  
    imageCell.setWidth(IMAGE_SIZE); // image is 23 x 23
    OAImageBean dots = (OAImageBean)createWebBean(pageContext, IMAGE_BEAN, null, "dotsImage" + rowId);
    dots.setSource(APPS_MEDIA_DIRECTORY + "cc_dotsprocess.gif");
    dots.setShortDesc("Dot Image");
    dots.setHeight("35");
    dots.setWidth("8");

    imageCell.addIndexedChild(dots);
    spaceCell.setWidth(SPACER_SIZE);

    contentCell.setVAlign(V_ALIGN_TOP);
    contentCell.addIndexedChild(content);

  } // end doDotsRow()


  private void doBubbleRow(OAPageContext pageContext, 
                             OAWebBean parentBean, 
                             String text,
                             String rowId)
  {
    String IMAGE_SIZE = "23"; // image is 23 x 23
    String SPACER_SIZE = "8";
    
    OARowLayoutBean row = 
      (OARowLayoutBean)createWebBean(pageContext, ROW_LAYOUT_BEAN, null, "bubbleRow" + rowId);
    parentBean.addIndexedChild(row);

    OACellFormatBean imageCell = 
      (OACellFormatBean)createWebBean(pageContext, CELL_FORMAT_BEAN, null, "bubImageCell" + rowId);
    OACellFormatBean spaceCell = 
      (OACellFormatBean)createWebBean(pageContext, CELL_FORMAT_BEAN, null, "bubSpaceCell" + rowId);
    OACellFormatBean textCell = 
      (OACellFormatBean)createWebBean(pageContext, CELL_FORMAT_BEAN, null, "subTextCell" +rowId);

    row.addIndexedChild(imageCell);
    row.addIndexedChild(spaceCell);
    row.addIndexedChild(textCell);

    imageCell.setHAlign(H_ALIGN_CENTER); 
    imageCell.setWidth(IMAGE_SIZE); 
    OAImageBean bubble = (OAImageBean)createWebBean(pageContext, IMAGE_BEAN, null, "bubImage" + rowId);
    bubble.setSource(APPS_MEDIA_DIRECTORY + "cc_bubbleprocess.gif"); 
    bubble.setShortDesc("Bubble Image");
    bubble.setHeight(IMAGE_SIZE);
    bubble.setWidth(IMAGE_SIZE);
    imageCell.addIndexedChild(bubble);

    spaceCell.setWidth(SPACER_SIZE); 

    OAStaticStyledTextBean label = 
      (OAStaticStyledTextBean)createWebBean(pageContext, STATIC_STYLED_TEXT_BEAN, null, "bubText" +rowId);
    label.setText(pageContext, text);
    // The smallest subheader on a light background per the UI guidelines.
    label.setCSSClass("OraLightHeaderSubSub"); 

    textCell.addIndexedChild(label);

  } // end doBubbleRow()

}
