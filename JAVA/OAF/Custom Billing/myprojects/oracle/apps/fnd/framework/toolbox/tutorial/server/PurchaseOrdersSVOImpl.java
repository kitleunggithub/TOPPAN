/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderFilter;

import oracle.svc.DataObject;
import oracle.svc.expression.Expression;
import oracle.svc.expression.ValueExpression;



public class PurchaseOrdersSVOImpl extends OAViewObjectImpl {
  /**
   * Oracle Applications internal source control identifier
   */
   public static final String RCS_ID="$Header: PurchaseOrdersSVOImpl.java 120.8 2006/07/04 01:54:36 atgops1 noship $";
  /**
   * Oracle Applications internal source control identifier
   */
   public static final boolean RCS_ID_RECORDED =
         VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");


  /**
   * 
   * This is the default constructor (do not remove)
   */
  public PurchaseOrdersSVOImpl()
  {
  }

  /**
   * Handling SQL fragment for proxy filter attribute: "SupplierStartDate"
   */
  protected SQLFilterExpression createSQLFilterExpression (DataObject filter, Expression expr, int startingBindParamIndex)
  {
    // Inner query for SupplierStartDate
    if (filter instanceof PurchaseOrderFilter && expr instanceof ValueExpression)
    {
      ValueExpression valExpr = (ValueExpression)expr;
      String attrName = valExpr.getAttributeName();
      if("SupplierStartDate".equals(attrName))
      {
        StringBuffer sqlStr = new StringBuffer();

        //Construct inner query
        sqlStr.append("PurchaseOrderHeaderEO.supplier_id in (select supplier_id from FWK_TBX_SUPPLIERS where ");


        //Construct SQL Expression string for start_date
        SQLFilterExpression sqlExpr = createSQLFilterExpression ("start_date", valExpr.getOperator(), valExpr.getValue(), startingBindParamIndex);
        sqlStr.append(sqlExpr.getSQLExpression());
        sqlStr.append(")");
        
        return new SQLFilterExpression(sqlStr.toString(), sqlExpr.getBindParameters());
      }
    }
    return super.createSQLFilterExpression(filter, expr,startingBindParamIndex);
  }   
}