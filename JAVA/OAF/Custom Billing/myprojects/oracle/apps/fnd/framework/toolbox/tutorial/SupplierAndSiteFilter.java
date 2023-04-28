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
import oracle.svc.expression.ExpressionFilter;
import oracle.svc.expression.MultiValueExpression;
import oracle.svc.expression.ValueExpression;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------
/**
 * This is the suppliers and supplier sites domain expression filter.
 */

public class SupplierAndSiteFilter extends ExpressionFilter 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: SupplierAndSiteFilter.java 120.9 2008/04/03 07:30:51 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/tutorial/SupplierAndSiteFilter";


  public SupplierAndSiteFilter()
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
   * @param value Supplier site unique identifier.
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
   * @param values list of Supplier site unique identifier.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addSiteName(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("SiteName", multiValuedOperator, values);
  }
}
