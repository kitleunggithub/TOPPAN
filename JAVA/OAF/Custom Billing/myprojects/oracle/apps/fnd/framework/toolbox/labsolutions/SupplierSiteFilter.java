/*+===========================================================================+
  |   Copyright (c) 2006 Oracle Corporation, Redwood Shores, CA, USA          |
  |                         All rights reserved.                              |
  +===========================================================================+
  |  HISTORY                                                                  |
  +===========================================================================+*/

//javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions;
import java.lang.String;
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
 * This is supplier site filter.
 */

public class SupplierSiteFilter extends ExpressionFilter 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: SupplierSiteFilter.java 120.7 2008/04/03 07:25:39 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierSiteFilter";


  public SupplierSiteFilter()
  {
    super();
  }

  /**
   * Adds a <code>ValueExpression</code> for Supplier Id attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Supplier unique identifier.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addSupplierId(String singleValuedOperator, Number value)
  {
    return addValueExpression("SupplierId", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Supplier Id attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Supplier unique identifier.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addSupplierId(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("SupplierId", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Supplier Site Id attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Supplier site unique identifier.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addSupplierSiteId(String singleValuedOperator, Number value)
  {
    return addValueExpression("SupplierSiteId", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Supplier Site Id attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Supplier site unique identifier.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addSupplierSiteId(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("SupplierSiteId", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Site Name attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Supplier site name.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addSiteName(String singleValuedOperator, String value)
  {
    return addValueExpression("SiteName", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Site Name attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Supplier site name.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addSiteName(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("SiteName", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Purchasing Site Flag attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Flag indicating whether purchase orders may be placed for this site.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addPurchasingSiteFlag(String singleValuedOperator, String value)
  {
    return addValueExpression("PurchasingSiteFlag", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Purchasing Site Flag attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Flag indicating whether purchase orders may be placed for this site.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addPurchasingSiteFlag(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("PurchasingSiteFlag", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Payment Terms Code attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Negotiated payment terms for this site.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addPaymentTermsCode(String singleValuedOperator, String value)
  {
    return addValueExpression("PaymentTermsCode", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Payment Terms Code attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Negotiated payment terms for this site.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addPaymentTermsCode(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("PaymentTermsCode", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Carrier Code attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Negotiated carrier for this site.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addCarrierCode(String singleValuedOperator, String value)
  {
    return addValueExpression("CarrierCode", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Carrier Code attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Negotiated carrier for this site.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addCarrierCode(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("CarrierCode", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Address Id attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Default shipping address unique identifier.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addAddressId(String singleValuedOperator, Number value)
  {
    return addValueExpression("AddressId", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Address Id attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Default shipping address unique identifier.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addAddressId(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("AddressId", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Start Date attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Site activation start date.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addStartDate(String singleValuedOperator, Date value)
  {
    return addValueExpression("StartDate", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Start Date attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Site activation start date.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addStartDate(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("StartDate", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for End Date attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Date after which site is disabled.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addEndDate(String singleValuedOperator, Date value)
  {
    return addValueExpression("EndDate", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for End Date attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Date after which site is disabled.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addEndDate(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("EndDate", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Name attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Supplier name.
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addName(String singleValuedOperator, String value)
  {
    return addValueExpression("Name", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Name attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Supplier name.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addName(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("Name", multiValuedOperator, values);
  }
}
