/*+===========================================================================+
  |   Copyright (c) 2006 Oracle Corporation, Redwood Shores, CA, USA          |
  |                         All rights reserved.                              |
  +===========================================================================+
  |  HISTORY                                                                  |
  +===========================================================================+*/

//javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial;
import java.util.List;
import oracle.apps.fnd.common.VersionInfo;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.svc.expression.ExpressionFilter;
import oracle.svc.expression.MultiValueExpression;
import oracle.svc.expression.ValueExpression;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------
/**
 * This is an expression filter for purchase order shipments.
 */

public class PurchaseOrderShipmentFilter extends ExpressionFilter 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: PurchaseOrderShipmentFilter.java 120.8 2008/04/03 07:30:09 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderShipmentFilter";


  public PurchaseOrderShipmentFilter()
  {
    super();
  }

  /**
   * Adds a <code>ValueExpression</code> for Shipment Id attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Shipment unique identifier.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addShipmentId(String singleValuedOperator, Number value)
  {
    return addValueExpression("ShipmentId", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Shipment Id attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Shipment unique identifier.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addShipmentId(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("ShipmentId", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Line Id attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Purchase order line unique identifier.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addLineId(String singleValuedOperator, Number value)
  {
    return addValueExpression("LineId", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Line Id attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Purchase order line unique identifier.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addLineId(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("LineId", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Shipment Number attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Shipment number which is unique for this purchase order.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addShipmentNumber(String singleValuedOperator, Number value)
  {
    return addValueExpression("ShipmentNumber", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Shipment Number attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Shipment number which is unique for this purchase order.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addShipmentNumber(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("ShipmentNumber", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Need By Date attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Date by which line items are required.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addNeedByDate(String singleValuedOperator, Date value)
  {
    return addValueExpression("NeedByDate", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Need By Date attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Date by which line items are required.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addNeedByDate(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("NeedByDate", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Receipt Quantity attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Quantity of goods/services received for this shipment.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addReceiptQuantity(String singleValuedOperator, Number value)
  {
    return addValueExpression("ReceiptQuantity", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Receipt Quantity attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Quantity of goods/services received for this shipment.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addReceiptQuantity(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("ReceiptQuantity", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Order Quantity attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Number of items to be delivered on this shipment.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addOrderQuantity(String singleValuedOperator, Number value)
  {
    return addValueExpression("OrderQuantity", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Order Quantity attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Number of items to be delivered on this shipment.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addOrderQuantity(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("OrderQuantity", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Receipt Date attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Date on which line items were received.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addReceiptDate(String singleValuedOperator, Date value)
  {
    return addValueExpression("ReceiptDate", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Receipt Date attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Date on which line items were received.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addReceiptDate(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("ReceiptDate", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Line Number attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Line number which is  unique for this  purchase order.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addLineNumber(String singleValuedOperator, Number value)
  {
    return addValueExpression("LineNumber", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Line Number attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Line number which is  unique for this  purchase order.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addLineNumber(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("LineNumber", multiValuedOperator, values);
  }
}
