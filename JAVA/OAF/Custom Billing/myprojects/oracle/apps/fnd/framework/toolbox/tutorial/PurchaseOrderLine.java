/*+===========================================================================+
  |   Copyright (c) 2006 Oracle Corporation, Redwood Shores, CA, USA          |
  |                         All rights reserved.                              |
  +===========================================================================+
  |  HISTORY                                                                  |
  +===========================================================================+*/

//javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial;
import java.lang.String;
import java.util.List;
import oracle.apps.fnd.common.VersionInfo;
import oracle.jbo.domain.Number;
import oracle.svc.DataObjectImpl;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------
/**
 * A data object representing a purchase order line document.
 * <p>
 * <b>Primary Key Attributes:</b>
 * <ul>
 * <li>LineId
 * </ul>
 * <b>Alternate Key Sets (in order of precedence):</b>
 * <ol>
 * <li>Key Set Name = ByNumber, Key Set Attributes:
 * <ul>
 * <li>PoNumber
 * <li>LineNumber
 * </ul>
 * </ol>
 */

public class PurchaseOrderLine extends DataObjectImpl 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: PurchaseOrderLine.java 120.12 2008/04/03 07:28:37 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderLine";


  private static final int BASE_ATTRIBUTE_POSITION = DataObjectImpl.ATTRIBUTE_NAMES.length;
  private static final String[] ATTRIBUTE_NAMES = new String[BASE_ATTRIBUTE_POSITION + 9];
  private static final String[] ATTRIBUTE_INNER_CLASS = new String[BASE_ATTRIBUTE_POSITION + 9];
  private static final int SVC_ATTR_LINE_ID = BASE_ATTRIBUTE_POSITION + 0;
  private static final int SVC_ATTR_PO_NUMBER = BASE_ATTRIBUTE_POSITION + 1;
  private static final int SVC_ATTR_LINE_NUMBER = BASE_ATTRIBUTE_POSITION + 2;
  private static final int SVC_ATTR_ITEM_ID = BASE_ATTRIBUTE_POSITION + 3;
  private static final int SVC_ATTR_ITEM_DESCRIPTION = BASE_ATTRIBUTE_POSITION + 4;
  private static final int SVC_ATTR_UNIT_OF_MEASURE = BASE_ATTRIBUTE_POSITION + 5;
  private static final int SVC_ATTR_QUANTITY = BASE_ATTRIBUTE_POSITION + 6;
  private static final int SVC_ATTR_UNIT_PRICE = BASE_ATTRIBUTE_POSITION + 7;
  private static final int SVC_ATTR_PURCHASE_ORDER_SHIPMENT = BASE_ATTRIBUTE_POSITION + 8;

  static  
  {
    System.arraycopy(DataObjectImpl.ATTRIBUTE_NAMES, 0, ATTRIBUTE_NAMES, 0, BASE_ATTRIBUTE_POSITION);
    ATTRIBUTE_NAMES[SVC_ATTR_LINE_ID] = "LineId";
    ATTRIBUTE_NAMES[SVC_ATTR_PO_NUMBER] = "PoNumber";
    ATTRIBUTE_NAMES[SVC_ATTR_LINE_NUMBER] = "LineNumber";
    ATTRIBUTE_NAMES[SVC_ATTR_ITEM_ID] = "ItemId";
    ATTRIBUTE_NAMES[SVC_ATTR_ITEM_DESCRIPTION] = "ItemDescription";
    ATTRIBUTE_NAMES[SVC_ATTR_UNIT_OF_MEASURE] = "UnitOfMeasure";
    ATTRIBUTE_NAMES[SVC_ATTR_QUANTITY] = "Quantity";
    ATTRIBUTE_NAMES[SVC_ATTR_UNIT_PRICE] = "UnitPrice";
    ATTRIBUTE_NAMES[SVC_ATTR_PURCHASE_ORDER_SHIPMENT] = "PurchaseOrderShipment";
    ATTRIBUTE_INNER_CLASS[SVC_ATTR_PURCHASE_ORDER_SHIPMENT] = "oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderShipment";
  }

  public PurchaseOrderLine()
  {
    super();
    mAttributeNames = ATTRIBUTE_NAMES;
    mAttributeInnerClasses = ATTRIBUTE_INNER_CLASS;
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
   * @param value Purchase order line unique identifier. The purchase order line id.
   */
  public void setLineId(Number value)
  {
    setSVCProperty(SVC_ATTR_LINE_ID, value);
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
   * Gets Line Number.
   * @return Line number which is  unique for this  purchase order.
   */
  public Number getLineNumber()
  {
    return (Number)getSVCProperty(SVC_ATTR_LINE_NUMBER);
  }

  /**
   * Sets Line Number.
   * @param value Line number which is  unique for this  purchase order. The purchase order line number
   */
  public void setLineNumber(Number value)
  {
    setSVCProperty(SVC_ATTR_LINE_NUMBER, value);
  }

  /**
   * Gets Item Id.
   * @return Item unique identifier.
   */
  public Number getItemId()
  {
    return (Number)getSVCProperty(SVC_ATTR_ITEM_ID);
  }

  /**
   * Sets Item Id.
   * @param value Item unique identifier.
   */
  public void setItemId(Number value)
  {
    setSVCProperty(SVC_ATTR_ITEM_ID, value);
  }

  /**
   * Gets Item Description.
   * @return Item description.
   */
  public String getItemDescription()
  {
    return (String)getSVCProperty(SVC_ATTR_ITEM_DESCRIPTION);
  }

  /**
   * Sets Item Description.
   * @param value Item description.
   */
  public void setItemDescription(String value)
  {
    setSVCProperty(SVC_ATTR_ITEM_DESCRIPTION, value);
  }

  /**
   * Gets Unit Of Measure.
   * @return Item quantity unit of measure.
   */
  public String getUnitOfMeasure()
  {
    return (String)getSVCProperty(SVC_ATTR_UNIT_OF_MEASURE);
  }

  /**
   * Sets Unit Of Measure.
   * @param value Item quantity unit of measure.
   */
  public void setUnitOfMeasure(String value)
  {
    setSVCProperty(SVC_ATTR_UNIT_OF_MEASURE, value);
  }

  /**
   * Gets Quantity.
   * @return Item order quantity in associated unit of measure.
   */
  public Number getQuantity()
  {
    return (Number)getSVCProperty(SVC_ATTR_QUANTITY);
  }

  /**
   * Sets Quantity.
   * @param value Item order quantity in associated unit of measure.
   */
  public void setQuantity(Number value)
  {
    setSVCProperty(SVC_ATTR_QUANTITY, value);
  }

  /**
   * Gets Unit Price.
   * @return Item price in order currency.
   */
  public Number getUnitPrice()
  {
    return (Number)getSVCProperty(SVC_ATTR_UNIT_PRICE);
  }

  /**
   * Sets Unit Price.
   * @param value Item price in order currency.
   */
  public void setUnitPrice(Number value)
  {
    setSVCProperty(SVC_ATTR_UNIT_PRICE, value);
  }

  /**
   * Gets Purchase Order Shipments.
   * @return Purchase Order Shipments
   */
  public List getPurchaseOrderShipment()
  {
    return (List)getSVCProperty(SVC_ATTR_PURCHASE_ORDER_SHIPMENT);
  }

  /**
   * Sets Purchase Order Shipments.
   * @param value Purchase Order Shipments
   */
  public void setPurchaseOrderShipment(List value)
  {
    setSVCProperty(SVC_ATTR_PURCHASE_ORDER_SHIPMENT, value);
  }

  public void setPropertyInvokeAccessor(int index, Object value)
  {
    if (index == SVC_ATTR_LINE_ID)
      setLineId((Number)value);
    else if (index == SVC_ATTR_PO_NUMBER)
      setPoNumber((Number)value);
    else if (index == SVC_ATTR_LINE_NUMBER)
      setLineNumber((Number)value);
    else if (index == SVC_ATTR_ITEM_ID)
      setItemId((Number)value);
    else if (index == SVC_ATTR_ITEM_DESCRIPTION)
      setItemDescription((String)value);
    else if (index == SVC_ATTR_UNIT_OF_MEASURE)
      setUnitOfMeasure((String)value);
    else if (index == SVC_ATTR_QUANTITY)
      setQuantity((Number)value);
    else if (index == SVC_ATTR_UNIT_PRICE)
      setUnitPrice((Number)value);
    else if (index == SVC_ATTR_PURCHASE_ORDER_SHIPMENT)
      setPurchaseOrderShipment((List)value);
    else
      setSVCProperty(index, value);
  }

  public Object getPropertyInvokeAccessor(int index)
  {
    if (index == SVC_ATTR_LINE_ID)
      return getLineId();
    else if (index == SVC_ATTR_PO_NUMBER)
      return getPoNumber();
    else if (index == SVC_ATTR_LINE_NUMBER)
      return getLineNumber();
    else if (index == SVC_ATTR_ITEM_ID)
      return getItemId();
    else if (index == SVC_ATTR_ITEM_DESCRIPTION)
      return getItemDescription();
    else if (index == SVC_ATTR_UNIT_OF_MEASURE)
      return getUnitOfMeasure();
    else if (index == SVC_ATTR_QUANTITY)
      return getQuantity();
    else if (index == SVC_ATTR_UNIT_PRICE)
      return getUnitPrice();
    else if (index == SVC_ATTR_PURCHASE_ORDER_SHIPMENT)
      return getPurchaseOrderShipment();
    else
      return getSVCProperty(index);
  }
}
