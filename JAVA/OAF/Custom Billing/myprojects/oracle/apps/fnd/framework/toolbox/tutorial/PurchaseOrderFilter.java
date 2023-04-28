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
import oracle.apps.fnd.framework.svc.AttachedDocumentFilter;

import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;

import oracle.svc.DataObjectImpl;
import oracle.svc.expression.ChildExpression;
import oracle.svc.expression.ExpressionFilter;
import oracle.svc.expression.MultiValueExpression;
import oracle.svc.expression.ValueExpression;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------

/**
 * This is the Purchase Order Expression Filter. This is the default filter.
 */
public class PurchaseOrderFilter extends ExpressionFilter {
    public static final String RCS_ID = "$Header: PurchaseOrderFilter.java 120.17 2008/04/03 12:26:48 sanapart noship $";
    public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");

    public static final String QUALIFIED_NAME =
        "/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderFilter";

    /**
     * Used for optimizing serialization.
     */
    private static final long serialVersionUID = 1;
    private static final int BASE_ATTRIBUTE_POSITION = DataObjectImpl.ATTRIBUTE_NAMES.length;
    private static final String[] ATTRIBUTE_NAMES =
        new String[BASE_ATTRIBUTE_POSITION + 12];
    private static final int SVC_ATTR_PO_NUMBER = BASE_ATTRIBUTE_POSITION + 0;
    private static final int SVC_ATTR_DESCRIPTION =
        BASE_ATTRIBUTE_POSITION + 1;
    private static final int SVC_ATTR_STATUS_CODE =
        BASE_ATTRIBUTE_POSITION + 2;
    private static final int SVC_ATTR_SUPPLIER_ID =
        BASE_ATTRIBUTE_POSITION + 3;
    private static final int SVC_ATTR_SUPPLIER_SITE_ID =
        BASE_ATTRIBUTE_POSITION + 4;
    private static final int SVC_ATTR_BUYER_ID = BASE_ATTRIBUTE_POSITION + 5;
    private static final int SVC_ATTR_BUYER_NAME = BASE_ATTRIBUTE_POSITION + 6;
    private static final int SVC_ATTR_SUPPLIER_NAME =
        BASE_ATTRIBUTE_POSITION + 7;
    private static final int SVC_ATTR_SUPPLIER_SITE_NAME =
        BASE_ATTRIBUTE_POSITION + 8;
    private static final int SVC_ATTR_SUPPLIER_ATTACHMENTS =
        BASE_ATTRIBUTE_POSITION + 9;
    private static final int SVC_ATTR_POATTACHMENTS =
        BASE_ATTRIBUTE_POSITION + 10;
    private static final int SVC_ATTR_SUPPLIER_START_DATE =
        BASE_ATTRIBUTE_POSITION + 11;
    static {
        System.arraycopy(DataObjectImpl.ATTRIBUTE_NAMES, 0,
                         ATTRIBUTE_NAMES, 0, BASE_ATTRIBUTE_POSITION);
    }

    public PurchaseOrderFilter() {
        super();
        mAttributeNames = ATTRIBUTE_NAMES;
    }

    /**
     * Adds a <code>ValueExpression</code> for Po Number attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Purchase order unique identifier. Developer documentation goes here.
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
     * @param values list of Purchase order unique identifier. Developer documentation goes here.
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
     * Adds a <code>ValueExpression</code> for Description attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value A brief description of the purchase order.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addDescription(String singleValuedOperator,
                                          String value) {
        return addValueExpression("Description", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Description attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of A brief description of the purchase order.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addDescription(String multiValuedOperator,
                                               List values) {
        return addMultiValueExpression("Description", multiValuedOperator,
                                       values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Status Code attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Internal purchase order processing state.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addStatusCode(String singleValuedOperator,
                                         String value) {
        return addValueExpression("StatusCode", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Status Code attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Internal purchase order processing state.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addStatusCode(String multiValuedOperator,
                                              List values) {
        return addMultiValueExpression("StatusCode", multiValuedOperator,
                                       values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Supplier Id attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Supplier unique identifier.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addSupplierId(String singleValuedOperator,
                                         Number value) {
        return addValueExpression("SupplierId", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Supplier Id attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Supplier unique identifier.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addSupplierId(String multiValuedOperator,
                                              List values) {
        return addMultiValueExpression("SupplierId", multiValuedOperator,
                                       values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Supplier Site Id attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Supplier site unique identifier.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addSupplierSiteId(String singleValuedOperator,
                                             Number value) {
        return addValueExpression("SupplierSiteId", singleValuedOperator,
                                  value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Supplier Site Id attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Supplier site unique identifier.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addSupplierSiteId(String multiValuedOperator,
                                                  List values) {
        return addMultiValueExpression("SupplierSiteId", multiValuedOperator,
                                       values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Buyer Id attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Buyer unique identifier.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addBuyerId(String singleValuedOperator,
                                      Number value) {
        return addValueExpression("BuyerId", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Buyer Id attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Buyer unique identifier.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addBuyerId(String multiValuedOperator,
                                           List values) {
        return addMultiValueExpression("BuyerId", multiValuedOperator, values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Buyer Name attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Buyer Name.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addBuyerName(String singleValuedOperator,
                                        String value) {
        return addValueExpression("BuyerName", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Buyer Name attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Buyer Name.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addBuyerName(String multiValuedOperator,
                                             List values) {
        return addMultiValueExpression("BuyerName", multiValuedOperator,
                                       values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Supplier Name attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Supplier name.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addSupplierName(String singleValuedOperator,
                                           String value) {
        return addValueExpression("SupplierName", singleValuedOperator, value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Supplier Name attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Supplier name.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addSupplierName(String multiValuedOperator,
                                                List values) {
        return addMultiValueExpression("SupplierName", multiValuedOperator,
                                       values);
    }

    /**
     * Adds a <code>ValueExpression</code> for Supplier Site Name attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Supplier site unique identifier.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addSupplierSiteName(String singleValuedOperator,
                                               String value) {
        return addValueExpression("SupplierSiteName", singleValuedOperator,
                                  value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Supplier Site Name attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Supplier site unique identifier.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addSupplierSiteName(String multiValuedOperator,
                                                    List values) {
        return addMultiValueExpression("SupplierSiteName", multiValuedOperator,
                                       values);
    }

    /**
     * Adds a <code>ChildExpression</code> for Supplier Attachments attribute .
     * @param value SupplierAttachments
     * @return the created <code>ChildExpression</code>.
     */
    public ChildExpression addSupplierAttachments(AttachedDocumentFilter value) {
        return addChildExpression("SupplierAttachments", value);
    }

    /**
     * Adds a <code>ChildExpression</code> for POAttachments attribute .
     * @param value POAttachments
     * @return the created <code>ChildExpression</code>.
     */
    public ChildExpression addPOAttachments(AttachedDocumentFilter value) {
        return addChildExpression("POAttachments", value);
    }

    /**
     * Adds a <code>ValueExpression</code> for Supplier Start Date attribute .
     * @param singleValuedOperator accepts operators that work against a single argument ( {@link ValueExpression#EQUAL EQUAL}, {@link ValueExpression#GREATER_THAN GREATER_THAN}, {@link ValueExpression#LIKE LIKE}, etc)
     * @param value Supplier Start Date. The supplier start date.
     * This will allow us to query by the supplier start date even though
     * its not on the PurchaseOrder data object.
     * @return the created <code>ValueExpression</code>.
     * @see ValueExpression
     */
    public ValueExpression addSupplierStartDate(String singleValuedOperator,
                                                Date value) {
        return addValueExpression("SupplierStartDate", singleValuedOperator,
                                  value);
    }

    /**
     * Adds a <code>MultiValueExpression</code> for Supplier Start Date attribute .
     * @param multiValuedOperator accepts operators that work against multiple arguments ( {@link MultiValueExpression#IN IN}and {@link MultiValueExpression#BETWEEN BETWEEN})
     * @param values list of Supplier Start Date. The supplier start date.
     * This will allow us to query by the supplier start date even though
     * its not on the PurchaseOrder data object.
     * @return the created <code>MultiValueExpression</code>.
     * @see MultiValueExpression
     *
     */
    public MultiValueExpression addSupplierStartDate(String multiValuedOperator,
                                                     List values) {
        return addMultiValueExpression("SupplierStartDate",
                                       multiValuedOperator, values);
    }
}
