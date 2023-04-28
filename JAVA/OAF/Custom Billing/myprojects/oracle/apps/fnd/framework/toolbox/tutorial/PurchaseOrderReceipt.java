/*+===========================================================================+
  |   Copyright (c) 2006 Oracle Corporation, Redwood Shores, CA, USA          |
  |                         All rights reserved.                              |
  +===========================================================================+
  |  HISTORY                                                                  |
  +===========================================================================+*/

//javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial;
import oracle.apps.fnd.common.VersionInfo;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.svc.DataObjectImpl;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------
/**
 * A data object representing a purchase order receipt document.
 * <p>
 * <b>Primary Key Attributes:</b>
 * <ul>
 * <li>PoNumber
 * <li>LineId
 * <li>ShipmentId
 * </ul>
 * <b>Alternate Key Sets (in order of precedence):</b>
 * <ol>
 * <li>Key Set Name = ByNumber, Key Set Attributes:
 * <ul>
 * <li>PoNumber
 * <li>LineNumber
 * <li>ShipmentNumber
 * </ul>
 * </ol>
 */

public class PurchaseOrderReceipt extends DataObjectImpl 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: PurchaseOrderReceipt.java 120.8 2008/04/03 07:29:00 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderReceipt";


  private static final int BASE_ATTRIBUTE_POSITION = DataObjectImpl.ATTRIBUTE_NAMES.length;
  private static final String[] ATTRIBUTE_NAMES = new String[BASE_ATTRIBUTE_POSITION + 9];
  private static final String[] ATTRIBUTE_INNER_CLASS = new String[BASE_ATTRIBUTE_POSITION + 9];
  private static final int SVC_ATTR_PO_NUMBER = BASE_ATTRIBUTE_POSITION + 0;
  private static final int SVC_ATTR_LINE_ID = BASE_ATTRIBUTE_POSITION + 1;
  private static final int SVC_ATTR_SHIPMENT_ID = BASE_ATTRIBUTE_POSITION + 2;
  private static final int SVC_ATTR_SHIPMENT_NUMBER = BASE_ATTRIBUTE_POSITION + 3;
  private static final int SVC_ATTR_LINE_NUMBER = BASE_ATTRIBUTE_POSITION + 4;
  private static final int SVC_ATTR_NEED_BY_DATE = BASE_ATTRIBUTE_POSITION + 5;
  private static final int SVC_ATTR_RECEIPT_QUANTITY = BASE_ATTRIBUTE_POSITION + 6;
  private static final int SVC_ATTR_ORDER_QUANTITY = BASE_ATTRIBUTE_POSITION + 7;
  private static final int SVC_ATTR_RECEIPT_DATE = BASE_ATTRIBUTE_POSITION + 8;

  static  
  {
    System.arraycopy(DataObjectImpl.ATTRIBUTE_NAMES, 0, ATTRIBUTE_NAMES, 0, BASE_ATTRIBUTE_POSITION);
    ATTRIBUTE_NAMES[SVC_ATTR_PO_NUMBER] = "PoNumber";
    ATTRIBUTE_NAMES[SVC_ATTR_LINE_ID] = "LineId";
    ATTRIBUTE_NAMES[SVC_ATTR_SHIPMENT_ID] = "ShipmentId";
    ATTRIBUTE_NAMES[SVC_ATTR_SHIPMENT_NUMBER] = "ShipmentNumber";
    ATTRIBUTE_NAMES[SVC_ATTR_LINE_NUMBER] = "LineNumber";
    ATTRIBUTE_NAMES[SVC_ATTR_NEED_BY_DATE] = "NeedByDate";
    ATTRIBUTE_NAMES[SVC_ATTR_RECEIPT_QUANTITY] = "ReceiptQuantity";
    ATTRIBUTE_NAMES[SVC_ATTR_ORDER_QUANTITY] = "OrderQuantity";
    ATTRIBUTE_NAMES[SVC_ATTR_RECEIPT_DATE] = "ReceiptDate";
  }

  public PurchaseOrderReceipt()
  {
    super();
    mAttributeNames = ATTRIBUTE_NAMES;
    mAttributeInnerClasses = ATTRIBUTE_INNER_CLASS;
  }

  /**
   * Gets Po Number.
   * @return Purchase order unique identifier.
   */
  public Number getPoNumber()
  {
    return (Number)getSVCProperty(SVC_ATTR_PO_NUMBER);
  }

  /**
   * Sets Po Number.
   * @param value Purchase order unique identifier.
   */
  public void setPoNumber(Number value)
  {
    setSVCProperty(SVC_ATTR_PO_NUMBER, value);
  }

  /**
   * Gets Line Id.
   * @return Purchase order line unique identifier.
   */
  public Number getLineId()
  {
    return (Number)getSVCProperty(SVC_ATTR_LINE_ID);
  }

  /**
   * Sets Line Id.
   * @param value Purchase order line unique identifier.
   */
  public void setLineId(Number value)
  {
    setSVCProperty(SVC_ATTR_LINE_ID, value);
  }

  /**
   * Gets Shipment Id.
   * @return Shipment Id
   */
  public Number getShipmentId()
  {
    return (Number)getSVCProperty(SVC_ATTR_SHIPMENT_ID);
  }

  /**
   * Sets Shipment Id.
   * @param value Shipment Id
   */
  public void setShipmentId(Number value)
  {
    setSVCProperty(SVC_ATTR_SHIPMENT_ID, value);
  }

  /**
   * Gets Shipment Number.
   * @return Shipment Number
   */
  public Number getShipmentNumber()
  {
    return (Number)getSVCProperty(SVC_ATTR_SHIPMENT_NUMBER);
  }

  /**
   * Sets Shipment Number.
   * @param value Shipment Number
   */
  public void setShipmentNumber(Number value)
  {
    setSVCProperty(SVC_ATTR_SHIPMENT_NUMBER, value);
  }

  /**
   * Gets Line Number.
   * @return Line Number
   */
  public Number getLineNumber()
  {
    return (Number)getSVCProperty(SVC_ATTR_LINE_NUMBER);
  }

  /**
   * Sets Line Number.
   * @param value Line Number
   */
  public void setLineNumber(Number value)
  {
    setSVCProperty(SVC_ATTR_LINE_NUMBER, value);
  }

  /**
   * Gets Need By Date.
   * @return Need By Date
   */
  public Date getNeedByDate()
  {
    return (Date)getSVCProperty(SVC_ATTR_NEED_BY_DATE);
  }

  /**
   * Sets Need By Date.
   * @param value Need By Date
   */
  public void setNeedByDate(Date value)
  {
    setSVCProperty(SVC_ATTR_NEED_BY_DATE, value);
  }

  /**
   * Gets Receipt Quantity.
   * @return Receipt Quantity
   */
  public Number getReceiptQuantity()
  {
    return (Number)getSVCProperty(SVC_ATTR_RECEIPT_QUANTITY);
  }

  /**
   * Sets Receipt Quantity.
   * @param value Receipt Quantity
   */
  public void setReceiptQuantity(Number value)
  {
    setSVCProperty(SVC_ATTR_RECEIPT_QUANTITY, value);
  }

  /**
   * Gets Order Quantity.
   * @return Order Quantity
   */
  public Number getOrderQuantity()
  {
    return (Number)getSVCProperty(SVC_ATTR_ORDER_QUANTITY);
  }

  /**
   * Sets Order Quantity.
   * @param value Order Quantity
   */
  public void setOrderQuantity(Number value)
  {
    setSVCProperty(SVC_ATTR_ORDER_QUANTITY, value);
  }

  /**
   * Gets Receipt Date.
   * @return Receipt Date
   */
  public Date getReceiptDate()
  {
    return (Date)getSVCProperty(SVC_ATTR_RECEIPT_DATE);
  }

  /**
   * Sets Receipt Date.
   * @param value Receipt Date
   */
  public void setReceiptDate(Date value)
  {
    setSVCProperty(SVC_ATTR_RECEIPT_DATE, value);
  }

  public void setPropertyInvokeAccessor(int index, Object value)
  {
    if (index == SVC_ATTR_PO_NUMBER)
      setPoNumber((Number)value);
    else if (index == SVC_ATTR_LINE_ID)
      setLineId((Number)value);
    else if (index == SVC_ATTR_SHIPMENT_ID)
      setShipmentId((Number)value);
    else if (index == SVC_ATTR_SHIPMENT_NUMBER)
      setShipmentNumber((Number)value);
    else if (index == SVC_ATTR_LINE_NUMBER)
      setLineNumber((Number)value);
    else if (index == SVC_ATTR_NEED_BY_DATE)
      setNeedByDate((Date)value);
    else if (index == SVC_ATTR_RECEIPT_QUANTITY)
      setReceiptQuantity((Number)value);
    else if (index == SVC_ATTR_ORDER_QUANTITY)
      setOrderQuantity((Number)value);
    else if (index == SVC_ATTR_RECEIPT_DATE)
      setReceiptDate((Date)value);
    else
      setSVCProperty(index, value);
  }

  public Object getPropertyInvokeAccessor(int index)
  {
    if (index == SVC_ATTR_PO_NUMBER)
      return getPoNumber();
    else if (index == SVC_ATTR_LINE_ID)
      return getLineId();
    else if (index == SVC_ATTR_SHIPMENT_ID)
      return getShipmentId();
    else if (index == SVC_ATTR_SHIPMENT_NUMBER)
      return getShipmentNumber();
    else if (index == SVC_ATTR_LINE_NUMBER)
      return getLineNumber();
    else if (index == SVC_ATTR_NEED_BY_DATE)
      return getNeedByDate();
    else if (index == SVC_ATTR_RECEIPT_QUANTITY)
      return getReceiptQuantity();
    else if (index == SVC_ATTR_ORDER_QUANTITY)
      return getOrderQuantity();
    else if (index == SVC_ATTR_RECEIPT_DATE)
      return getReceiptDate();
    else
      return getSVCProperty(index);
  }
}
