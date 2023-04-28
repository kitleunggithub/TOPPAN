/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.server.OADBTransactionImpl;
import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrder;
import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderFilter;
import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderAcknowledgement;
import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderLine;
import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderLineFilter;
import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderReceipt;
import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderService;
import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderShipment;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;

import oracle.svc.DataCriteria;
import oracle.svc.DataObjectImpl;
import oracle.svc.DataProcessorService;
import oracle.svc.expression.ExpressionFilter;
import oracle.svc.expression.ValueExpression;
import oracle.svc.ProcessControl;
import oracle.svc.QueryControl;
import oracle.svc.DataObject;
import oracle.svc.util.DataObjectFactory;
import java.lang.String;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;


public class PurchaseOrderSAMImpl extends OAApplicationModuleImpl implements PurchaseOrderService
{
  /**
   * Oracle Applications internal source control identifier
   */
   public static final String RCS_ID="$Header: PurchaseOrderSAMImpl.java 120.16 2006/05/25 01:29:38 atgops1 noship $";
  /**
   * Oracle Applications internal source control identifier
   */
   public static final boolean RCS_ID_RECORDED =
         VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");

  private OADBTransactionImpl getOADBTransactionImpl()
   {
     return (OADBTransactionImpl)getOADBTransaction();
   }


  public void deletePurchaseOrderLine(PurchaseOrderLine line)
  {
    if (line == null)
    {
      throw new IllegalArgumentException("Invalid parameter line : null");
    }  
    
    ArrayList data = new ArrayList();
    data.add(0, line);
    
    List result = processDataList("PurchaseOrderLine", 
                               DataProcessorService.OPERATION_DELETE, 
                               null,
                               data);
                
    
  }  // end deletePurchaseOrderLine()


  public void deletePurchaseOrderShipment(PurchaseOrderShipment shipment)
  {
    if (shipment == null)
    {
      throw new IllegalArgumentException("Invalid parameter shipment : null");
    }  
    
    ArrayList data = new ArrayList();
    data.add(0, shipment);
    
    List result = processDataList("PurchaseOrderShipment", 
                               DataProcessorService.OPERATION_DELETE, 
                               null,
                               data);
                
    
  }  // end deletePurchaseOrderShipment()


   public void approvePurchaseOrders(List poNumbers)
   {
     if(poNumbers!=null)
     {
       java.util.Iterator iter = poNumbers.iterator();
       while(iter.hasNext())
       {
         approvePurchaseOrder((Number)iter.next());
       }
     }
   }

   public void approvePurchaseOrder(Number poNumber)
   {
   
      if (poNumber == null)
      {
        throw new IllegalArgumentException("Invalid parameter poNumber : null");
      }  

      PurchaseOrdersSVOImpl vo = getPurchaseOrder();
      Number[] keys = { poNumber };
      Row[] rows = vo.findByKey(new Key(keys), 1);

      if (rows != null)
      {
        PurchaseOrdersSVORowImpl row = (PurchaseOrdersSVORowImpl)rows[0];
        row.approve();
      }

   } // end approvePurchaseOrder()


   public void receiveItems(List receipts)
   {
     if(receipts!=null)
     {
       java.util.Iterator iter = receipts.iterator();
       while(iter.hasNext())
       {
         receiveItem((PurchaseOrderReceipt)iter.next());
       }
     }
   }

   public void receiveItem(PurchaseOrderReceipt receipt)
   {

      if (receipt == null)
      {
        throw new IllegalArgumentException("Invalid parameter receipt : null");
      }  

      Number poNumber = (Number)receipt.get("PoNumber");
      Number poLine = (Number)receipt.get("LineNumber");
      Number lineId = (Number)receipt.get("LineId");
      Number poShipment = (Number)receipt.get("ShipmentNumber");
      Number shipmentId = (Number)receipt.get("ShipmentId");
      Number quantity = (Number)receipt.get("ReceiptQuantity");
      Date receiptDate = (Date)receipt.get("ReceiptDate");

  // LIZA ISSUE: add examle code
/*
      if (rows != null)
      {
        PurchaseOrderReceiptsSVORowImpl row = 
          (PurchaseOrderReceiptsSVORowImpl)rows[0];
//         row.receiveItems(quantity, receiptDate);
      }
 */     
   } // end receiveItem()


   public Number getItemPrice(Number poNumber, Number lineNumber, Number lineId)
   {
      if (poNumber == null)
      {
        throw new IllegalArgumentException("Invalid parameter poNumber : null.");
      }
      else if(lineNumber == null && lineId == null)
      {
        throw new IllegalArgumentException("Invalid parameters lineNumber : null and lineId : null. Please enter a value for atleast one parameter.");
      }

      Number price = null;

      OADBTransactionImpl trxn = getOADBTransactionImpl();
      DataObjectFactory fac = trxn.getDataObjectFactory();
      PurchaseOrderLineFilter lineFilter = (PurchaseOrderLineFilter)fac.createDataObject(PurchaseOrderLineFilter.QUALIFIED_NAME);
      lineFilter.setConjunctionOperator(ExpressionFilter.OPERATOR_AND);
      lineFilter.setNegation(new Boolean(false));
      
      lineFilter.addPoNumber(ValueExpression.EQUAL, poNumber);

      if(lineId!=null)
        lineFilter.addLineId(ValueExpression.EQUAL, lineId);
      else
        lineFilter.addLineNumber(ValueExpression.EQUAL, lineNumber);      
      
      DataCriteria dataCriteria = (DataCriteria )fac.createDataObject(DataCriteria.QUALIFIED_NAME);      
      List partialAttributes = new ArrayList();
      partialAttributes.add(new String("UnitPrice"));
      dataCriteria.setPartialAttribute(partialAttributes);
      
      dataCriteria.setFilter(lineFilter);
      List rows = getDataList("PurchaseOrderLine", dataCriteria, null);
     
      if (rows != null && rows.size() > 0)
      {
        ListIterator iterator = rows.listIterator();
        DataObject row = (DataObject)iterator.next();
        
        if (row != null)
        {
          price = (Number)row.get("UnitPrice");
        }  
      }      

      return price;  
   } // end getItemPrice

   
   public void acknowledgePurchaseOrder(PurchaseOrderAcknowledgement acknowledgement)
   {

     if (acknowledgement == null)
     {
        throw new IllegalArgumentException("Invalid parameter acknowledgement : null");
     }

     Number poNumber = (Number)acknowledgement.get("PoNumber");
     String confirmFlag = (String)acknowledgement.get("ConfirmFlag");
     Number poLine = (Number)acknowledgement.get("LineNumber");
     Number lindId = (Number)acknowledgement.get("LineId");
     Number poShipment = (Number)acknowledgement.get("ShipmentNumber");
     Number shipmentId = (Number)acknowledgement.get("ShipmentId");
     Number price = (Number)acknowledgement.get("UnitPrice");
     Date promiseDate = (Date)acknowledgement.get("PromiseDate");
     
     // LIZA ISSUE: implement this as a call to a PL/SQL ackowledge POs
     // procedure.
    
   } // end acknowledgePurchaseOrder()


  /**
   * 
   * This is the default constructor (do not remove)
   */
  public PurchaseOrderSAMImpl()
  {
  }





  //public static void main(String args[])
  //{
  //  Object descSDO = getIRepServiceDescription("oracle.apps.fnd.framework.toolbox.tutorial.server.PurchaseOrderSAM");
  //  System.out.println(descSDO);
  //  System.out.println("END!");    
  //}




  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.tutorial.server", "PurchaseOrderSAMLocal");
  }

  /**
   * 
   * Container's getter for PurchaseOrder_BuyerDomain
   */
  public OAViewObjectImpl getPurchaseOrder_BuyerDomain()
  {
    return (OAViewObjectImpl)findViewObject("PurchaseOrder_BuyerDomain");
  }

  /**
   * 
   * Container's getter for PurchaseOrder_SupplierAndSiteDomain
   */
  public OAViewObjectImpl getPurchaseOrder_SupplierAndSiteDomain()
  {
    return (OAViewObjectImpl)findViewObject("PurchaseOrder_SupplierAndSiteDomain");
  }

  /**
   * 
   * Container's getter for CarrierDomain
   */
  public OAViewObjectImpl getCarrierDomain()
  {
    return (OAViewObjectImpl)findViewObject("CarrierDomain");
  }

  /**
   * 
   * Container's getter for CurrenciesDomain
   */
  public OAViewObjectImpl getCurrenciesDomain()
  {
    return (OAViewObjectImpl)findViewObject("CurrenciesDomain");
  }

  /**
   * 
   * Container's getter for OrderStatusesDomain
   */
  public OAViewObjectImpl getOrderStatusesDomain()
  {
    return (OAViewObjectImpl)findViewObject("OrderStatusesDomain");
  }

  /**
   * 
   * Container's getter for PaymentTermsDomain
   */
  public OAViewObjectImpl getPaymentTermsDomain()
  {
    return (OAViewObjectImpl)findViewObject("PaymentTermsDomain");
  }

  /**
   * 
   * Container's getter for UnitOfMeasuresDomain
   */
  public OAViewObjectImpl getUnitOfMeasuresDomain()
  {
    return (OAViewObjectImpl)findViewObject("UnitOfMeasuresDomain");
  }

  private List getDataList(String dataSourceName, DataCriteria dataCriteria, QueryControl queryControl)
  {
    DataObject rootSDO = queryDataSource(dataSourceName, dataCriteria, queryControl);
    return (rootSDO==null)?null:(List)rootSDO.get(dataSourceName);
  }

  private List processDataList(String dataSourceName, String operation, ProcessControl processControl, List dataList)
  {
    DataObjectFactory factory = ((OADBTransactionImpl)getOADBTransaction()).getDataObjectFactory();
    DataObject rootSDO = factory.createDataObject(DataObjectImpl.QUALIFIED_NAME);
    rootSDO.set(dataSourceName, dataList);
    DataObject ret = processDataSource(dataSourceName, operation, processControl, rootSDO);
    return (List)((ret==null)?null:ret.get(dataSourceName)); 
  }

  /**
   * 
   * Container's getter for PurchaseOrderLine
   */
  public PurchaseOrderLinesSVOImpl getPurchaseOrderLine()
  {
    return (PurchaseOrderLinesSVOImpl)findViewObject("PurchaseOrderLine");
  }

  /**
   * 
   * Container's getter for PurchaseOrder
   */
  public PurchaseOrdersSVOImpl getPurchaseOrder()
  {
    return (PurchaseOrdersSVOImpl)findViewObject("PurchaseOrder");
  }

  /**
   * 
   * Container's getter for PurchaseOrderShipment
   */
  public PurchaseOrderShipmentsSVOImpl getPurchaseOrderShipment()
  {
    return (PurchaseOrderShipmentsSVOImpl)findViewObject("PurchaseOrderShipment");
  }

  /**
   * 
   * Container's getter for PurchaseOrderReceipt
   */
  public PurchaseOrderReceiptsSVOImpl getPurchaseOrderReceipt()
  {
    return (PurchaseOrderReceiptsSVOImpl)findViewObject("PurchaseOrderReceipt");
  }

  /**
   * Gets a PurchaseOrder based on its primary key attributes.
   * @param poNumber Purchase order unique identifier.The Purchase Order Number.
   * @return The PurchaseOrder data object.
   */
  public PurchaseOrder getPurchaseOrder(Number poNumber)
  {
    PurchaseOrder result = null;
    OADBTransactionImpl trxn = (OADBTransactionImpl)getOADBTransaction();
    DataObjectFactory fac = trxn.getDataObjectFactory();
    DataCriteria dataCriteria = (DataCriteria)fac.createDataObject("/oracle/svc/DataCriteria");
    ExpressionFilter filter = (ExpressionFilter)fac.createDataObject("/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderFilter");
    dataCriteria.setFilter(filter);
    filter.addValueExpression("PoNumber", ValueExpression.EQUAL, poNumber);
    DataObject resultObject = queryDataSource("PurchaseOrder", dataCriteria, null);
    List results = (List)resultObject.get("PurchaseOrder");
    if (results != null && results.size() > 0)
    {
      result = (PurchaseOrder)results.get(0);
    }
    return result;
  }

  /**
   * Deletes a PurchaseOrder.
   * The record is located using the primary key set on the passed data object.
   * If the primary key is not set, then the record is located using the
   * alternate key sets in the data object in sequence.
   * @param purchaseOrder The data object which identifies the PurchaseOrder.
   */
  public void deletePurchaseOrder(PurchaseOrder purchaseOrder)
  {
    DataObjectFactory doFac = getDataObjectFactory();
    ArrayList data = new ArrayList();
    data.add(0, purchaseOrder);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderServiceRoot");
    rootObject.set("PurchaseOrder", data);
    DataObject resultObject = processDataSource("PurchaseOrder", DataProcessorService.OPERATION_DELETE, null, rootObject);
  }

  /**
   * Updates or creates a PurchaseOrder.
   * If the passed PurchaseOrder exists, it will be updated,
   * otherwise a new one is created.
   * The record is located using the primary key of the PurchaseOrder.
   * If the primary key is not set, then the record is located using
   * the alternate key sets defined for this data object.
   * @param purchaseOrder The PurchaseOrder data object.
   * @return The created PurchaseOrder data object with the primary keys populated.
   */
  public PurchaseOrder mergePurchaseOrder(PurchaseOrder purchaseOrder)
  {
    PurchaseOrder result = null;
    ArrayList data = new ArrayList();
    data.add(0, purchaseOrder);
    DataObjectFactory doFac = getDataObjectFactory();
    ProcessControl processCtrl = (ProcessControl)doFac.createDataObject(ProcessControl.QUALIFIED_NAME);
    processCtrl.setReturnMode(ProcessControl.RETURN_KEY);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderServiceRoot");
    rootObject.set("PurchaseOrder", data);
    DataObject resultObject = processDataSource("PurchaseOrder", DataProcessorService.OPERATION_MERGE, processCtrl, rootObject);
    List results = (List)resultObject.get("PurchaseOrder");
    if (results != null && results.size() > 0)
    {
      result = (PurchaseOrder)results.get(0);
    }
    return result;
  }

  /**
   * Updates a PurchaseOrder.
   * The record is located using the primary key of the PurchaseOrder.
   * If the primary key is not set, then the record is located using
   * the alternate key sets defined for this data object.
   * @param purchaseOrder The PurchaseOrder data object.
   * @return The updated PurchaseOrder data object with the primary keys populated.
   */
  public PurchaseOrder updatePurchaseOrder(PurchaseOrder purchaseOrder)
  {
    PurchaseOrder result = null;
    ArrayList data = new ArrayList();
    data.add(0, purchaseOrder);
    DataObjectFactory doFac = getDataObjectFactory();
    ProcessControl processCtrl = (ProcessControl)doFac.createDataObject(ProcessControl.QUALIFIED_NAME);
    processCtrl.setReturnMode(ProcessControl.RETURN_KEY);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderServiceRoot");
    rootObject.set("PurchaseOrder", data);
    DataObject resultObject = processDataSource("PurchaseOrder", DataProcessorService.OPERATION_UPDATE, processCtrl, rootObject);
    List results = (List)resultObject.get("PurchaseOrder");
    if (results != null && results.size() > 0)
    {
      result = (PurchaseOrder)results.get(0);
    }
    return result;
  }

  /**
   * Creates a new PurchaseOrder.
   * @param purchaseOrder The PurchaseOrder data object.
   * @return The created PurchaseOrder data object with the primary keys populated.
   */

  public PurchaseOrder createPurchaseOrder(PurchaseOrder purchaseOrder)
  {
    PurchaseOrder result = null;
    ArrayList data = new ArrayList();
    data.add(0, purchaseOrder);
    DataObjectFactory doFac = getDataObjectFactory();
    ProcessControl processCtrl = (ProcessControl)doFac.createDataObject(ProcessControl.QUALIFIED_NAME);
    processCtrl.setReturnMode(ProcessControl.RETURN_KEY);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderServiceRoot");
    rootObject.set("PurchaseOrder", data);
    DataObject resultObject = processDataSource("PurchaseOrder", DataProcessorService.OPERATION_CREATE, processCtrl, rootObject);
    List results = (List)resultObject.get("PurchaseOrder");
    if (results != null && results.size() > 0)
    {
      result = (PurchaseOrder)results.get(0);
    }
    return result;
  }

  /**
   * 
   * Container's getter for PurchaseOrderAcknowledgement
   */
  public PurchaseOrderAcknowledgementsSVOImpl getPurchaseOrderAcknowledgement()
  {
    return (PurchaseOrderAcknowledgementsSVOImpl)findViewObject("PurchaseOrderAcknowledgement");
  }
}