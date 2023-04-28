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
import oracle.svc.expression.ExpressionFilter;
import oracle.svc.expression.MultiValueExpression;
import oracle.svc.expression.ValueExpression;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------

/**
 * A standard expression filter for purchase order lines.
 */
public class PurchaseOrderLineFilter extends ExpressionFilter {
    public static final String RCS_ID = "$Header: PurchaseOrderLineFilter.java 120.12 2008/04/03 12:28:16 sanapart noship $";
    public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");

    public static final String QUALIFIED_NAME =
        "/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderLineFilter";

    /**
     * Used for optimizing serialization.
     */
    private static final long serialVersionUID = 1;
    private static final int BASE_ATTRIBUTE_POSITION = DataObjectImpl.ATTRIBUTE_NAMES.length;
    private static final String[] ATTRIBUTE_NAMES =
        new String[BASE_ATTRIBUTE_POSITION + 7];
    private static final int SVC_ATTR_LINE_ID = BASE_ATTRIBUTE_POSITION + 0;
    private static final int SVC_ATTR_PO_NUMBER = BASE_ATTRIBUTE_POSITION + 1;
    private static final int SVC_ATTR_LINE_NUMBER =
        BASE_ATTRIBUTE_POSITION + 2;
    private static final int SVC_ATTR_ITEM_ID = BASE_ATTRIBUTE_POSITION + 3;
    private static final int SVC_ATTR_ITEM_DESCRIPTION =
        BASE_ATTRIBUTE_POSITION + 4;
    private static final int SVC_ATTR_QUANTITY = BASE_ATTRIBUTE_POSITION + 5;
    private static final int SVC_ATTR_UNIT_PRICE = BASE_ATTRIBUTE_POSITION + 6;
    static {
        System.arraycopy(DataObjectImpl.ATTRIBUTE_NAMES, 0,
                         ATTRIBUTE_NAMES, 0, BASE_ATTRIBUTE_POSITION);
    }

    public PurchaseOrderLineFilter() {
        super();
        mAttributeNames = ATTRIBUTE_NAMES;
    }

    /**
     * Adds a <code>ValueExpression</code> for Line Id attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Purchase order line unique identifier.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addLineId(String singleValuedOperator,
                                     Number value) {
        return addValueExpression("LineId", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Line Id attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Purchase order line unique identifier.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addLineId(String multiValuedOperator,
                                          List values) {
        return addMultiValueExpression("LineId", multiValuedOperator, values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Po Number attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Purchase order unique identifier.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addPoNumber(String singleValuedOperator,
                                       Number value) {
        return addValueExpression("PoNumber", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Po Number attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Purchase order unique identifier.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addPoNumber(String multiValuedOperator,
                                            List values) {
        return addMultiValueExpression("PoNumber", multiValuedOperator,
                                       values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Line Number attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Line number which is  unique for this  purchase order.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addLineNumber(String singleValuedOperator,
                                         Number value) {
        return addValueExpression("LineNumber", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Line Number attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Line number which is  unique for this  purchase order.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addLineNumber(String multiValuedOperator,
                                              List values) {
        return addMultiValueExpression("LineNumber", multiValuedOperator,
                                       values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Item Id attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Item unique identifier.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addItemId(String singleValuedOperator,
                                     Number value) {
        return addValueExpression("ItemId", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Item Id attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Item unique identifier.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addItemId(String multiValuedOperator,
                                          List values) {
        return addMultiValueExpression("ItemId", multiValuedOperator, values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Item Description attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Item description.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addItemDescription(String singleValuedOperator,
                                              String value) {
        return addValueExpression("ItemDescription", singleValuedOperator,
                                  value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Item Description attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Item description.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addItemDescription(String multiValuedOperator,
                                                   List values) {
        return addMultiValueExpression("ItemDescription", multiValuedOperator,
                                       values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Quantity attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Item order quantity in associated unit of measure.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addQuantity(String singleValuedOperator,
                                       Number value) {
        return addValueExpression("Quantity", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Quantity attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Item order quantity in associated unit of measure.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addQuantity(String multiValuedOperator,
                                            List values) {
        return addMultiValueExpression("Quantity", multiValuedOperator,
                                       values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Unit Price attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Item price in order currency.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addUnitPrice(String singleValuedOperator,
                                        Number value) {
        return addValueExpression("UnitPrice", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Unit Price attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Item price in order currency.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addUnitPrice(String multiValuedOperator,
                                             List values) {
        return addMultiValueExpression("UnitPrice", multiValuedOperator,
                                       values);
    }
}
