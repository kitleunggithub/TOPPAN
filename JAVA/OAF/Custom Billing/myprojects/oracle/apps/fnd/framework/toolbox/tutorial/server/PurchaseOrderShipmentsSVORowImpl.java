/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;
import oracle.apps.fnd.framework.server.OAViewRowImpl;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;
import oracle.jbo.domain.Date;

import oracle.apps.fnd.common.VersionInfo;

public class PurchaseOrderShipmentsSVORowImpl extends OAViewRowImpl {

    public static final int SHIPMENTID = 0;
    public static final int LINEID = 1;
    public static final int SHIPMENTNUMBER = 2;
    public static final int NEEDBYDATE = 3;
    public static final int RECEIPTQUANTITY = 4;
    public static final int ORDERQUANTITY = 5;
    public static final int RECEIPTDATE = 6;
    public static final int LINENUMBER = 7;
    public static final int LINEID1 = 8;

    /**
     * Oracle Applications internal source control identifier
     */
   public static final String RCS_ID="$Header: PurchaseOrderShipmentsSVORowImpl.java 120.5 2006/07/04 01:47:15 atgops1 noship $";
  /**
   * Oracle Applications internal source control identifier
   */
   public static final boolean RCS_ID_RECORDED =
         VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");
    public static final int PURCHASEORDERLINE = 9;

    /**
     *
     * This is the default constructor (do not remove)
     */
  public PurchaseOrderShipmentsSVORowImpl()
  {
  }

  /**
   * 
   * Gets PurchaseOrderShipmentEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderShipmentEOImpl getPurchaseOrderShipmentEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderShipmentEOImpl)getEntity(0);
  }














  //  Generated method. Do not modify.

  //  Generated method. Do not modify.


  /**
   * 
   * Gets PurchaseOrderLineEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderLineEOImpl getPurchaseOrderLineEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderLineEOImpl)getEntity(1);
  }






  /**
   * 
   * Gets PurchaseOrderLine entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderLineEOImpl getPurchaseOrderLine()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderLineEOImpl)getEntity(1);
  }

  /**
   * 
   * Gets the attribute value for SHIPMENT_ID using the alias name ShipmentId
   */
  public Number getShipmentId()
  {
    return (Number)getAttributeInternal(SHIPMENTID);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for SHIPMENT_ID using the alias name ShipmentId
   */
  public void setShipmentId(Number value)
  {
    setAttributeInternal(SHIPMENTID, value);
  }

  /**
   * 
   * Gets the attribute value for LINE_ID using the alias name LineId
   */
  public Number getLineId()
  {
    return (Number)getAttributeInternal(LINEID);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LINE_ID using the alias name LineId
   */
  public void setLineId(Number value)
  {
    setAttributeInternal(LINEID, value);
  }

  /**
   * 
   * Gets the attribute value for SHIPMENT_NUMBER using the alias name ShipmentNumber
   */
  public Number getShipmentNumber()
  {
    return (Number)getAttributeInternal(SHIPMENTNUMBER);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for SHIPMENT_NUMBER using the alias name ShipmentNumber
   */
  public void setShipmentNumber(Number value)
  {
    setAttributeInternal(SHIPMENTNUMBER, value);
  }

  /**
   * 
   * Gets the attribute value for NEED_BY_DATE using the alias name NeedByDate
   */
  public Date getNeedByDate()
  {
    return (Date)getAttributeInternal(NEEDBYDATE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for NEED_BY_DATE using the alias name NeedByDate
   */
  public void setNeedByDate(Date value)
  {
    setAttributeInternal(NEEDBYDATE, value);
  }

  /**
   * 
   * Gets the attribute value for RECEIPT_QUANTITY using the alias name ReceiptQuantity
   */
  public Number getReceiptQuantity()
  {
    return (Number)getAttributeInternal(RECEIPTQUANTITY);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for RECEIPT_QUANTITY using the alias name ReceiptQuantity
   */
  public void setReceiptQuantity(Number value)
  {
    setAttributeInternal(RECEIPTQUANTITY, value);
  }

  /**
   * 
   * Gets the attribute value for ORDER_QUANTITY using the alias name OrderQuantity
   */
  public Number getOrderQuantity()
  {
    return (Number)getAttributeInternal(ORDERQUANTITY);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ORDER_QUANTITY using the alias name OrderQuantity
   */
  public void setOrderQuantity(Number value)
  {
    setAttributeInternal(ORDERQUANTITY, value);
  }

  /**
   * 
   * Gets the attribute value for RECEIPT_DATE using the alias name ReceiptDate
   */
  public Date getReceiptDate()
  {
    return (Date)getAttributeInternal(RECEIPTDATE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for RECEIPT_DATE using the alias name ReceiptDate
   */
  public void setReceiptDate(Date value)
  {
    setAttributeInternal(RECEIPTDATE, value);
  }

  /**
   * 
   * Gets the attribute value for LINE_NUMBER using the alias name LineNumber
   */
  public Number getLineNumber()
  {
    return (Number)getAttributeInternal(LINENUMBER);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LINE_NUMBER using the alias name LineNumber
   */
  public void setLineNumber(Number value)
  {
    setAttributeInternal(LINENUMBER, value);
  }

  /**
   * 
   * Gets the attribute value for LINE_ID using the alias name LineId1
   */
  public Number getLineId1()
  {
    return (Number)getAttributeInternal(LINEID1);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LINE_ID using the alias name LineId1
   */
  public void setLineId1(Number value)
  {
    setAttributeInternal(LINEID1, value);
  }
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case SHIPMENTID:
            return getShipmentId();
        case LINEID:
            return getLineId();
        case SHIPMENTNUMBER:
            return getShipmentNumber();
        case NEEDBYDATE:
            return getNeedByDate();
        case RECEIPTQUANTITY:
            return getReceiptQuantity();
        case ORDERQUANTITY:
            return getOrderQuantity();
        case RECEIPTDATE:
            return getReceiptDate();
        case LINENUMBER:
            return getLineNumber();
        case LINEID1:
            return getLineId1();
        case PURCHASEORDERLINE:
            return getPurchaseOrderLine();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case SHIPMENTID:
            setShipmentId((Number)value);
            return;
        case LINEID:
            setLineId((Number)value);
            return;
        case SHIPMENTNUMBER:
            setShipmentNumber((Number)value);
            return;
        case NEEDBYDATE:
            setNeedByDate((Date)value);
            return;
        case RECEIPTQUANTITY:
            setReceiptQuantity((Number)value);
            return;
        case ORDERQUANTITY:
            setOrderQuantity((Number)value);
            return;
        case RECEIPTDATE:
            setReceiptDate((Date)value);
            return;
        case LINENUMBER:
            setLineNumber((Number)value);
            return;
        case LINEID1:
            setLineId1((Number)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }





















  //  Generated method. Do not modify.

  //  Generated method. Do not modify.


}