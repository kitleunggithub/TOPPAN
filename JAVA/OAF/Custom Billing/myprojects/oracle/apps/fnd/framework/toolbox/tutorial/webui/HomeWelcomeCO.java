/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
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
import oracle.apps.fnd.framework.webui.beans.OAImageBean;
import oracle.apps.fnd.framework.webui.beans.OAStyledTextBean;
import oracle.apps.fnd.framework.webui.beans.layout.OATableLayoutBean;
import oracle.apps.fnd.framework.webui.beans.layout.OARowLayoutBean;
import oracle.apps.fnd.framework.webui.beans.layout.OASpacerBean;
import oracle.apps.fnd.framework.webui.beans.layout.OACellFormatBean;
													   
/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.HomePG 
 * page's "Welcome" region.
 */
public class HomeWelcomeCO extends OAControllerImpl
{

  public static final String RCS_ID="$Header: HomeWelcomeCO.java 120.1 2005/06/06 17:11:53 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.framework.toolbok.tutorial.webui");


  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {

//////////////////////////////////////////////////////////////////////////////
//
// NOTE: the following manual layout is intended to show how you can do
// something like this in your page.  This particular "Welcome" layout is
// no longer a BLAF standard because it takes up too much space.
//
// Also note that this code violates coding standards by reusing the same
// component for different purposes.
//
//////////////////////////////////////////////////////////////////////////////

    super.processRequest(pageContext, webBean);

    String userName = pageContext.getUserName();

    String welcomeText = pageContext.getMessage("AK", "FWK_TBX_T_WELCOME", null);
    String productText = pageContext.getMessage("AK", "FWK_TBX_T_WELCOME_TO_PRODUCT", null);

    //Create beans for layout
    OATableLayoutBean tableLayout = 
      (OATableLayoutBean)createWebBean(pageContext, TABLE_LAYOUT_BEAN, null, "mainLayout");

    OARowLayoutBean row = 
      (OARowLayoutBean)createWebBean(pageContext, ROW_LAYOUT_BEAN, null, "mainRow");
    OACellFormatBean cell = 
      (OACellFormatBean)createWebBean(pageContext, CELL_FORMAT_BEAN, null, "mainCell");
    OAStyledTextBean styledText = 
      (OAStyledTextBean)createWebBean(pageContext, STYLED_TEXT_BEAN, null, "welcomeText");
    // Note that when images are added to your pages, you should always set the height and
    // width properties.  In this case, I'm skipping it because I don't know what this
    // image size is 
    OAImageBean image = (OAImageBean)createWebBean(pageContext, IMAGE_BEAN, null, "welcomeImage");
    OASpacerBean spacer = (OASpacerBean)createWebBean(pageContext, SPACER_BEAN, null, "mainSpacer");

    //Create first row of layout
    cell.setColumnSpan(2);
    spacer.setWidth(15);
    cell.addIndexedChild(spacer);
    styledText.setText(pageContext, welcomeText + " ");
    styledText.setStyleClass("ItrHomeWelcome");
    cell.addIndexedChild(styledText);
    styledText = (OAStyledTextBean)createWebBean(pageContext, STYLED_TEXT_BEAN, null, "textTwo");
    styledText.setText(pageContext, userName);
    styledText.setStyleClass("ItrHomeUser");
    cell.addIndexedChild(styledText);
    row.addIndexedChild(cell);
    tableLayout.addRowLayout(row);

    //Create second row 
    row = (OARowLayoutBean)createWebBean(pageContext, ROW_LAYOUT_BEAN, null, "rowTwo");
    cell = (OACellFormatBean)createWebBean(pageContext, CELL_FORMAT_BEAN, null, "cellOne");
    styledText = (OAStyledTextBean)createWebBean(pageContext, STYLED_TEXT_BEAN, null, "textThree");
    cell.setWidth("120");
    cell.setHeight("30");
    cell.setRowSpan(2);
    cell.setVAlign(V_ALIGN_BOTTOM); // Always use constants where possible
    cell.setHAlign(H_ALIGN_END); 
    image.setWidth(12);
    image.setHeight("30");
    image.setSource(APPS_MEDIA_DIRECTORY + "beigecorner.gif"); 
    image.setShortDesc("");
    cell.addIndexedChild(image);
    row.addIndexedChild(cell);
    cell = (OACellFormatBean)createWebBean(pageContext, CELL_FORMAT_BEAN, null, "cellThree");
    cell.setVAlign(V_ALIGN_BOTTOM); 
    styledText.setText(pageContext, productText);
    styledText.setStyleClass("ItrHomeTo");
    cell.addIndexedChild(styledText);
    row.addIndexedChild(cell);
    tableLayout.addRowLayout(row);

    // Create third row
    row = (OARowLayoutBean)createWebBean(pageContext, ROW_LAYOUT_BEAN, null, "rowThree");
    cell = (OACellFormatBean)createWebBean(pageContext, CELL_FORMAT_BEAN, null, "cellFour");
    image = (OAImageBean)createWebBean(pageContext, IMAGE_BEAN, null, "line");
    cell.setWidth("80%");
    cell.setHeight("1");
    cell.setVAlign(V_ALIGN_BOTTOM); 
    image.setWidth("100%");
    image.setHeight("1");
    image.setSource(APPS_MEDIA_DIRECTORY + "1pixelbeige.gif");	
    image.setShortDesc("");
    cell.addIndexedChild(image);
    row.addIndexedChild(cell);
    tableLayout.addRowLayout(row);

    // Now add the "welcome" layout to the page.
    webBean.addIndexedChild(tableLayout);

  } // end processRequest()

}
