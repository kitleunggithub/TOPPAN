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
 * The Buyers domain filter
 */

public class BuyerFilter extends ExpressionFilter 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: BuyerFilter.java 120.9 2008/04/03 07:27:33 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/tutorial/BuyerFilter";


  public BuyerFilter()
  {
    super();
  }

  /**
   * Adds a <code>ValueExpression</code> for Employee Id attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Employee Id
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addEmployeeId(String singleValuedOperator, Number value)
  {
    return addValueExpression("EmployeeId", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Employee Id attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Employee Id
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addEmployeeId(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("EmployeeId", multiValuedOperator, values);
  }

  /**
   * Adds a <code>ValueExpression</code> for Full Name attribute .
   * @param singleValuedOperator accepts operators that work against a single argument ({@link oracle.svc.expression.ValueExpression#EQUAL EQUAL}, {@link oracle.svc.expression.ValueExpression#GREATER_THAN GREATER_THAN}, {@link oracle.svc.expression.ValueExpression#LIKE LIKE}, etc)
   * @param value Full Name
   * @return the created <code>ValueExpression</code>.
   * @see oracle.svc.expression.ValueExpression
   */
  public ValueExpression addFullName(String singleValuedOperator, String value)
  {
    return addValueExpression("FullName", singleValuedOperator, value);
  }

  /**
   * Adds a <code>MultiValueExpression</code> for Full Name attribute .
   * @param multiValuedOperator accepts operators that work against multiple arguments ({@link oracle.svc.expression.MultiValueExpression#IN IN} and {@link oracle.svc.expression.MultiValueExpression#BETWEEN BETWEEN})
   * @param values list of Full Name
   * @return the created <code>MultiValueExpression</code>.
   * @see oracle.svc.expression.MultiValueExpression
   */
  public MultiValueExpression addFullName(String multiValuedOperator, List values)
  {
    return addMultiValueExpression("FullName", multiValuedOperator, values);
  }
}
