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
import oracle.jbo.domain.Number;
import oracle.svc.expression.ExpressionFilter;
import oracle.svc.expression.MultiValueExpression;
import oracle.svc.expression.ValueExpression;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------
/**
 * This is a supplier filter. Its an expression filter.
 */

public class SupplierFilter extends ExpressionFilter 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: SupplierFilter.java 120.7 2008/04/03 07:24:30 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierFilter";


  public SupplierFilter()
  {
    super();
  }

  /**
   * Adds a <code>ValueExpression</code> for Supplier Id attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Supplier unique identifier. Use it to filter by supplier id.
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
   * @param values list of Supplier unique identifier. Use it to filter by supplier id.
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
   * @param value Supplier name. Use it to filter by supplier name.
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
   * @param values list of Supplier name. Use it to filter by supplier name.
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addName(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("Name", multiValuedOperator, values);
  }
}
