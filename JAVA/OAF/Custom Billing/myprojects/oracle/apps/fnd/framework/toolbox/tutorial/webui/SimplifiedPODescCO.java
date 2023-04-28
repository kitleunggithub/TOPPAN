/*===========================================================================+
 |   Copyright (c) 2001, 2017 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import java.io.Serializable;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OADescriptiveFlexBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.form.OAFormValueBean;
import oracle.apps.fnd.framework.webui.beans.layout.OACardBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAHeaderBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAMessageComponentLayoutBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageGaugeBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageLayoutBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageStyledTextBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;

import oracle.cabo.ui.data.ArrayDataSet;
import oracle.cabo.ui.data.DataObjectList;
import oracle.cabo.ui.data.DictionaryData;

/**
 * Controller for ...
 */
public class SimplifiedPODescCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: SimplifiedPODescCO.java 120.0.12020000.6 2017/01/31 08:35:23 spunam noship $";
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

    // Get the purchase order number from the request.

    String orderNumber = pageContext.getParameter("headerId");

    // We need to set the page header text to include the po order number for reference.

    MessageToken[] tokens = { new MessageToken("PO_NUMBER", orderNumber) };

    // Always use a translated value from Message Dictionary when setting strings in
    // your controllers.

    String pageHeaderText = pageContext.getMessage("AK", "FWK_TBX_T_PO_HEADER_TEXT", tokens);

    // Set the po-specific page title (which also appears in the breadcrumbs)
    
    //((OAPageLayoutBean)webBean).setTitle(pageHeaderText);
    OACardBean card = (OACardBean)webBean.findIndexedChildRecursive("CardID");
    if(card != null){
      card.setCardtitle(pageHeaderText);
    }
    // Now we want to initialize the query for our single purchase order with all of its
    // details.  

    OAApplicationModule am = pageContext.getApplicationModule(webBean);
    Serializable[] parameters = { orderNumber };
    am.invokeMethod("initDetails", parameters); 

    // The "Order Total" prompt needs to be replaced with a message that
    // can display the currency, which is stored in a hidden field on the
    // page.  So it should look like:  Order Total (USD)

    OAMessageStyledTextBean orderTotal = 
      (OAMessageStyledTextBean)webBean.findIndexedChildRecursive("OrderTotal");

    if (orderTotal == null)
    {
      MessageToken[] errTokens = { new MessageToken("OBJECT_NAME", "OrderTotal") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", errTokens);
    }  

    // When you select the item style "Hidden" a form value bean is created.
    // Since we place the currency value on the page manually, we don't want
    // it rendering with the other fields.
    
    OAFormValueBean currency =
      (OAFormValueBean)webBean.findIndexedChildRecursive("Currency");

    if (currency == null)
    {
      MessageToken[] errTokens = { new MessageToken("OBJECT_NAME", "Currency") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", errTokens);
    }  
    
      webBean.findChildRecursive("DescRN").setAttributeValue(RESPONSIVE_ATTR,Boolean.TRUE);
    MessageToken[] currencyToken = { new MessageToken("CURRENCY_CODE", (String)currency.getValue(pageContext)) };
    String orderTotalPrompt = pageContext.getMessage("AK", "FWK_TBX_T_ORDER_TOTAL_PROMPT", currencyToken);

    orderTotal.setPrompt(orderTotalPrompt);
    
      OAMessageLayoutBean hdr=(OAMessageLayoutBean)webBean.findChildRecursive("messageLayout2");
      OAMessageGaugeBean bean = (OAMessageGaugeBean)createWebBean(pageContext,GAUGE_BEAN,null,"gauge");
      bean.setID("GaugeID");
      bean.setMinValue("0");
      bean.setMaxValue("10");
      bean.setValue("6");
      bean.setGaugeBackground("#FAD55C");
      bean.setGaugeType("statusMeter");
      //bean.setPrompt("Supplier Reliability");
      hdr.addIndexedChild(bean);
      
    //enable dff render as popup 
    OADescriptiveFlexBean flexBean =
      (OADescriptiveFlexBean)webBean.findChildRecursive("Shipping");
    if (flexBean != null)
    {
      flexBean.setRenderAsPopup(true);
    }
    //enable responsive ui
    webBean.findChildRecursive("DescRN").setAttributeValue(RESPONSIVE_ATTR, Boolean.TRUE);
  
    oracle.apps.fnd.framework.webui.beans.layout.OAPopupBean popup = (oracle.apps.fnd.framework.webui.beans.layout.OAPopupBean)webBean.findChildRecursive("buyercontactpopup");
    popup.setNotchShown(true);
    
    OATableBean lineTable = (OATableBean)webBean.findIndexedChildRecursive("ItemsTable");
    int childCount = lineTable.getIndexedChildCount(null); 
    DictionaryData columnHeaderFormats[] = new DictionaryData[childCount];
    for (int i = 0; i < childCount; i++) 
    { 
      columnHeaderFormats[i] = new DictionaryData();
      columnHeaderFormats[i].put(CELL_NO_WRAP_FORMAT_KEY, Boolean.TRUE); 
    }
    lineTable.setColumnHeaderFormats(new ArrayDataSet(columnHeaderFormats));
    lineTable.setAttributeValue(CONTROLBAR_RENDERING_STYLE,BUTTON_FORMAT);
//    lineTable.prepareForRendering(pageContext);
//    DataObjectList myColumnFormats = lineTable.getColumnFormats();
//    int columnNumber = myColumnFormats.getLength();
//    DictionaryData columnInfo = (oracle.cabo.ui.data.DictionaryData)myColumnFormats.getItem(pageContext.findChildIndex(lineTable,"LineNum"));
//    columnInfo.put(COLUMN_DATA_FORMAT_KEY,ICON_BUTTON_FORMAT);
    
    //    for(int i=0; i<columnNumber;i++)
    //    {
    //        DictionaryData columnInfo = (DictionaryData)myColumnFormats.getItem(i);
    //        columnInfo.put(COLUMN_DATA_FORMAT_KEY,ICON_BUTTON_FORMAT);
    //    }
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
    if(pageContext.getParameter("ReturnLink") != null)
    {
      String url = pageContext.getCurrentUrl();
      if(url.contains("sourcePageType=Standard")) {
        pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/tutorial/webui/POSearchCTPG",
                                       null,
                                       OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                       null,
                                       null,
                                       true, // retain AM
                                       OAWebBeanConstants.ADD_BREAD_CRUMB_NO);
      }
      else
      {
        pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/tutorial/webui/SimplifiedPOSearchPG",
                                       null,
                                       OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                       null,
                                       null,
                                       true, // retain AM
                                       OAWebBeanConstants.ADD_BREAD_CRUMB_NO);
      }
    }
  }

}
