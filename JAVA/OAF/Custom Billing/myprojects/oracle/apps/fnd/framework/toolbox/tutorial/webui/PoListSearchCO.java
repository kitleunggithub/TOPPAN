/*===========================================================================+
 |   Copyright (c) 2001, 2018 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import java.util.Vector;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAGraphVisualizationTemplateBean;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAQueryBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageLovInputBean;


/**
 * Controller for ...
 */
public class PoListSearchCO
  extends OAControllerImpl
{
  public static final String RCS_ID =
    "$Header: PoListSearchCO.java 120.0.12020000.3 2018/06/19 06:28:12 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
    VersionInfo.recordClassVersion(RCS_ID,
                                   "oracle.apps.fnd.framework.toolbox.tutorial.webui");

  public static final int mFileVersion = 0;

  /**
   * Layout and page setup logic for a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);

    //    Data generation logic for PO List Search Page.

    //    String availableStatus[] =
    //    { "IN_PROCESS", "REJECTED", "APPROVED", "COMPLETE", "ANY" };
    //    String c[] =
    //    { "Y", "N" };
    //    String supplierId[] =
    //    { "1", "2", "3" };
    //    String supplierSiteId[] =
    //    { "1", "2", "3", "4", "5" };
    //    String currencyCode[] =
    //    { "USD", "CAD", "GBP", "FRF", "EUR", "ESP", "DEM", "JPY", "MXP" };
    //    String buyerId[] =
    //    { "1", "2", "3", "4", "5", "6", "7" };
    //    String paymentTerms[] =
    //    { "NET_30", "NET_45", "NET_60", "IMMEDIATE" };
    //    String carrierCode[] =
    //    { "UPS", "FEDEX", "YELLOW_FREIGHT", "DHL" };
    //    String descPrefix[] =
    //    { "PONumber", "Purchase", "PO", "Order", "OrderNumber" };

    //   OATableLayoutBean table = new OATableLayoutBean();

    //    for(int i=6;i<1500;i++)
    //    {
    //        String headerID = Integer.toString(i);
    //        String desc = descPrefix[i%descPrefix.length] + " " + headerID;
    //        String status = availableStatus[i%availableStatus.length];
    //        String confirmFlag = c[i%c.length];
    //        String supplierID = supplierId[i%supplierId.length];
    //        String supplierSiteID = supplierSiteId[i%supplierSiteId.length];
    //        String currencyCo = currencyCode[i%currencyCode.length];
    //        String buyerIden = buyerId[i%buyerId.length];
    //        String paymentTerm = paymentTerms[i%paymentTerms.length];
    //        String carrier = carrierCode[i%carrierCode.length];
    //        String shipToAddress =  Integer.toString(i%5);
    //        String billToAddress = Integer.toString(i%20);
    //        String rateNumn = Integer.toString(i%40);
    //
    //        String sqlString = "fwk_tbx_seed.insert_po_header(" + headerID + ",'" + desc + "','" + status + "','" + confirmFlag + "'," +  supplierID+"," +supplierSiteID + ",'" + currencyCo +"'," +buyerIden + ",'" + paymentTerm+ "','" + carrier + "'," + shipToAddress +"," + billToAddress +","+rateNumn + ");";
    //        System.out.println(sqlString);
    //
    //        OARowLayoutBean row = new OARowLayoutBean();
    //        OAMessageStyledTextBean cell = new OAMessageStyledTextBean();
    //        cell.setText(sqlString);
    //        table.addIndexedChild(row);
    //        row.addIndexedChild(cell);
    //
    //    }

    //    for(int i=1501;i<2000;i++)
    //    {
    //      String headerID = Integer.toString(i);
    //      String desc = descPrefix[i%descPrefix.length] + " " + headerID;
    //      String status = availableStatus[i%availableStatus.length];
    //      String confirmFlag = c[i%c.length];
    //      String supplierID = supplierId[0];
    //      String supplierSiteID = supplierSiteId[i%supplierSiteId.length];
    //      String currencyCo = currencyCode[0];
    //      String buyerIden = buyerId[0];
    //      String paymentTerm = paymentTerms[0];
    //      String carrier = carrierCode[0];
    //      String shipToAddress =  Integer.toString(i%5);
    //      String billToAddress = Integer.toString(i%20);
    //      String rateNumn = Integer.toString(i%40);
    //      String sqlString = "fwk_tbx_seed.insert_po_header(" + headerID + ",'" + desc + "','" + status + "','" + confirmFlag + "'," +  supplierID+"," +supplierSiteID + ",'" + currencyCo +"'," +buyerIden + ",'" + paymentTerm+ "','" + carrier + "'," + shipToAddress +"," + billToAddress +","+rateNumn + ");";
    //      System.out.println(sqlString);
    //      OARowLayoutBean row = new OARowLayoutBean();
    //      OAMessageStyledTextBean cell = new OAMessageStyledTextBean();
    //      cell.setText(sqlString);
    //      table.addIndexedChild(row);
    //      row.addIndexedChild(cell);
    //    }
    //
    //    for(int i=2001;i<2500;i++)
    //    {
    //      String headerID = Integer.toString(i);
    //      String desc = descPrefix[i%descPrefix.length] + " " + headerID;
    //      String status = availableStatus[i%availableStatus.length];
    //      String confirmFlag = c[i%c.length];
    //      String supplierID = supplierId[0];
    //      String supplierSiteID = supplierSiteId[i%supplierSiteId.length];
    //      String currencyCo = currencyCode[1];
    //      String buyerIden = buyerId[0];
    //      String paymentTerm = paymentTerms[0];
    //      String carrier = carrierCode[2];
    //      String shipToAddress =  Integer.toString(i%5);
    //      String billToAddress = Integer.toString(i%20);
    //      String rateNumn = Integer.toString(i%40);
    //
    //      String sqlString = "fwk_tbx_seed.insert_po_header(" + headerID + ",'" + desc + "','" + status + "','" + confirmFlag + "'," +  supplierID+"," +supplierSiteID + ",'" + currencyCo +"'," +buyerIden + ",'" + paymentTerm+ "','" + carrier + "'," + shipToAddress +"," + billToAddress +","+rateNumn + ");";
    //      System.out.println(sqlString);
    //      OARowLayoutBean row = new OARowLayoutBean();
    //      OAMessageStyledTextBean cell = new OAMessageStyledTextBean();
    //      cell.setText(sqlString);
    //      table.addIndexedChild(row);
    //      row.addIndexedChild(cell);
    //    }
    //    pageContext.getPageLayoutBean().addIndexedChild(table);
    //    System.out.println("djsdfwef");


    OAGraphVisualizationTemplateBean visualization1 =
      new OAGraphVisualizationTemplateBean();
    visualization1.setComponentIdentifier("Graph1");
    visualization1.setComponentDisplayName("Number of orders per supplier");
    visualization1.setMetricAttribute(null);
    visualization1.setMetricSQLAggregateFunction("COUNT");
    visualization1.setYAxisLabel("Number Of Orders");
    Vector dimension1 = new Vector();
    dimension1.add("Supplier Name");
    dimension1.add("SUPPLIER_NAME");
    visualization1.setGroupDimensionMap(dimension1);


    OAGraphVisualizationTemplateBean visualization2 =
      new OAGraphVisualizationTemplateBean();
    visualization2.setComponentIdentifier("Graph2");
    visualization2.setComponentDisplayName("Number of Purchase Orders raised per employee");
    visualization2.setMetricAttribute(null);
    visualization2.setMetricSQLAggregateFunction("COUNT");
    visualization2.setYAxisLabel("Number Of Orders each employee raised");
    Vector dimension1_1 = new Vector();
    dimension1_1.add("Employee Name");
    dimension1_1.add("BUYER_NAME");
    visualization2.setGroupDimensionMap(dimension1_1);
    
    
    OAGraphVisualizationTemplateBean visualization3 =
      new OAGraphVisualizationTemplateBean();
    visualization3.setComponentIdentifier("Graph3");
    visualization3.setComponentDisplayName("Sum($value) of all Orders per supplier");
    visualization3.setMetricAttribute("ORDER_TOTAL");
    visualization3.setMetricSQLAggregateFunction("SUM");
    visualization3.setYAxisLabel("sum(all orders)");
    Vector dimension3_1 = new Vector();
    dimension3_1.add("Supplier Name");
    dimension3_1.add("SUPPLIER_NAME");
   visualization3.setGroupDimensionMap(dimension3_1);
    
    OAGraphVisualizationTemplateBean visualization4 =
      new OAGraphVisualizationTemplateBean();
    visualization4.setComponentIdentifier("Graph4");
    visualization4.setComponentDisplayName("Sum($value) of all Orders per Employee");
    visualization4.setMetricAttribute("ORDER_TOTAL");
    visualization4.setMetricSQLAggregateFunction("SUM");
    visualization4.setYAxisLabel("sum(all orders)");
    Vector dimension4_1 = new Vector();
    dimension4_1.add("Employee Name");
    dimension4_1.add("BUYER_NAME");
    visualization4.setGroupDimensionMap(dimension4_1);

    OAQueryBean queryBean =
      (OAQueryBean) webBean.findChildRecursive("region2");
    OAGraphVisualizationTemplateBean visualizations[] =
      new OAGraphVisualizationTemplateBean[]
      { visualization1, visualization2, visualization3 , visualization4};
    queryBean.setVisualizationTemplates(visualizations);
    
    
    


  }

  /**
   * Procedure to handle form submissions for form elements in
   * a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext,
                                 OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);
    if ("createpo".equals(pageContext.getParameter("event")))
    {
      pageContext.putSessionValue("Train", "Basic");
      pageContext.redirectImmediately("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/tutorial/webui/PoDescPG&poStep=0");
    }
  }

}
