/*+===========================================================================+
  |   Copyright (c) 2006 Oracle Corporation, Redwood Shores, CA, USA          |
  |                         All rights reserved.                              |
  +===========================================================================+
  |  HISTORY                                                                  |
  +===========================================================================+*/

//javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial;
import java.lang.String;
import oracle.apps.fnd.common.VersionInfo;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.svc.DataObjectImpl;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------
/**
 * Contains the purchase order achnowledgement information. This
 * includes:
 * <ul>
 * <li>Promise Date
 * <li>Unit Price
 * <li>Shipment number
 * </ul>
 * <p>
 * <b>Primary Key Attributes:</b>
 * <ul>
 * <li>PoNumber
 * <li>LineId
 * <li>ShipmentId
 * </ul>
 * <b>Alternate Key Sets (in order of precedence):</b>
 * <ol>
 * <li>Key Set Name = ByNumbers, Key Set Attributes:
 * <ul>
 * <li>ShipmentNumber
 * <li>PoNumber
 * <li>LineNumber
 * </ul>
 * </ol>
 */

public class PurchaseOrderAcknowledgement extends DataObjectImpl 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: PurchaseOrderAcknowledgement.java 120.8 2008/04/03 07:28:14 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderAcknowledgement";


  private static final int BASE_ATTRIBUTE_POSITION = DataObjectImpl.ATTRIBUTE_NAMES.length;
  private static final String[] ATTRIBUTE_NAMES = new String[BASE_ATTRIBUTE_POSITION + 8];
  private static final String[] ATTRIBUTE_INNER_CLASS = new String[BASE_ATTRIBUTE_POSITION + 8];
  private static final int SVC_ATTR_PO_NUMBER = BASE_ATTRIBUTE_POSITION + 0;
  private static final int SVC_ATTR_CONFIRM_FLAG = BASE_ATTRIBUTE_POSITION + 1;
  private static final int SVC_ATTR_LINE_ID = BASE_ATTRIBUTE_POSITION + 2;
  private static final int SVC_ATTR_SHIPMENT_ID = BASE_ATTRIBUTE_POSITION + 3;
  private static final int SVC_ATTR_SHIPMENT_NUMBER = BASE_ATTRIBUTE_POSITION + 4;
  private static final int SVC_ATTR_PROMISE_DATE = BASE_ATTRIBUTE_POSITION + 5;
  private static final int SVC_ATTR_LINE_NUMBER = BASE_ATTRIBUTE_POSITION + 6;
  private static final int SVC_ATTR_UNIT_PRICE = BASE_ATTRIBUTE_POSITION + 7;

  static  
  {
    System.arraycopy(DataObjectImpl.ATTRIBUTE_NAMES, 0, ATTRIBUTE_NAMES, 0, BASE_ATTRIBUTE_POSITION);
    ATTRIBUTE_NAMES[SVC_ATTR_PO_NUMBER] = "PoNumber";
    ATTRIBUTE_NAMES[SVC_ATTR_CONFIRM_FLAG] = "ConfirmFlag";
    ATTRIBUTE_NAMES[SVC_ATTR_LINE_ID] = "LineId";
    ATTRIBUTE_NAMES[SVC_ATTR_SHIPMENT_ID] = "ShipmentId";
    ATTRIBUTE_NAMES[SVC_ATTR_SHIPMENT_NUMBER] = "ShipmentNumber";
    ATTRIBUTE_NAMES[SVC_ATTR_PROMISE_DATE] = "PromiseDate";
    ATTRIBUTE_NAMES[SVC_ATTR_LINE_NUMBER] = "LineNumber";
    ATTRIBUTE_NAMES[SVC_ATTR_UNIT_PRICE] = "UnitPrice";
  }

  public PurchaseOrderAcknowledgement()
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
   * Gets Confirm Flag.
   * @return Flag indicating whether the purchase order has been accepted by the supplier.
   */
  public String getConfirmFlag()
  {
    return (String)getSVCProperty(SVC_ATTR_CONFIRM_FLAG);
  }

  /**
   * Sets Confirm Flag.
   * @param value Flag indicating whether the purchase order has been accepted by the supplier.
   */
  public void setConfirmFlag(String value)
  {
    setSVCProperty(SVC_ATTR_CONFIRM_FLAG, value);
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
   * @return Shipment unique identifier.
   */
  public Number getShipmentId()
  {
    return (Number)getSVCProperty(SVC_ATTR_SHIPMENT_ID);
  }

  /**
   * Sets Shipment Id.
   * @param value Shipment unique identifier.
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
   * Gets Promise Date.
   * @return Promise Date
   */
  public Date getPromiseDate()
  {
    return (Date)getSVCProperty(SVC_ATTR_PROMISE_DATE);
  }

  /**
   * Sets Promise Date.
   * @param value Promise Date
   */
  public void setPromiseDate(Date value)
  {
    setSVCProperty(SVC_ATTR_PROMISE_DATE, value);
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
   * Gets Unit Price.
   * @return Unit Price
   */
  public Number getUnitPrice()
  {
    return (Number)getSVCProperty(SVC_ATTR_UNIT_PRICE);
  }

  /**
   * Sets Unit Price.
   * @param value Unit Price
   */
  public void setUnitPrice(Number value)
  {
    setSVCProperty(SVC_ATTR_UNIT_PRICE, value);
  }

  public void setPropertyInvokeAccessor(int index, Object value)
  {
    if (index == SVC_ATTR_PO_NUMBER)
      setPoNumber((Number)value);
    else if (index == SVC_ATTR_CONFIRM_FLAG)
      setConfirmFlag((String)value);
    else if (index == SVC_ATTR_LINE_ID)
      setLineId((Number)value);
    else if (index == SVC_ATTR_SHIPMENT_ID)
      setShipmentId((Number)value);
    else if (index == SVC_ATTR_SHIPMENT_NUMBER)
      setShipmentNumber((Number)value);
    else if (index == SVC_ATTR_PROMISE_DATE)
      setPromiseDate((Date)value);
    else if (index == SVC_ATTR_LINE_NUMBER)
      setLineNumber((Number)value);
    else if (index == SVC_ATTR_UNIT_PRICE)
      setUnitPrice((Number)value);
    else
      setSVCProperty(index, value);
  }

  public Object getPropertyInvokeAccessor(int index)
  {
    if (index == SVC_ATTR_PO_NUMBER)
      return getPoNumber();
    else if (index == SVC_ATTR_CONFIRM_FLAG)
      return getConfirmFlag();
    else if (index == SVC_ATTR_LINE_ID)
      return getLineId();
    else if (index == SVC_ATTR_SHIPMENT_ID)
      return getShipmentId();
    else if (index == SVC_ATTR_SHIPMENT_NUMBER)
      return getShipmentNumber();
    else if (index == SVC_ATTR_PROMISE_DATE)
      return getPromiseDate();
    else if (index == SVC_ATTR_LINE_NUMBER)
      return getLineNumber();
    else if (index == SVC_ATTR_UNIT_PRICE)
      return getUnitPrice();
    else
      return getSVCProperty(index);
  }
}
