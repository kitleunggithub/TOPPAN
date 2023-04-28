/*===========================================================================+
 |      Copyright (c) 2001, 2018 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import java.util.Vector;

import oracle.bali.share.util.IntegerUtils;
import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OANLSServices;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class PoSimpleSummaryVOImpl extends OAViewObjectImpl
{
  // Required for Applications source control
  public static final String RCS_ID="$Header: PoSimpleSummaryVOImpl.java 120.2.12020000.3 2018/04/10 05:41:22 lmodugul ship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");


  // Initialize and execute the query
  public void initQuery(String orderNumber,
                        String created,
                        String showMyOrders,
                        Boolean executeQuery)
  {

    StringBuffer whereClause = new StringBuffer(100);
    Vector parameters = new Vector(3);
    int clauseCount = 0;
    int bindCount = 0;
  
    setWhereClauseParams(null); // Always reset

    // Note that the use of oracle-style bindings, while requiring a bit
    // more effort than the java-style binding, is REQUIRED of framework
    // code.

    if ((orderNumber != null) && (!("".equals(orderNumber.trim()))))
    {
      Number orderNum = null;
      
      try
      {
        orderNum = new Number(orderNumber);
      }  
      catch(Exception e) {}
      
      whereClause.append(" ORDER_NUMBER = :");
      whereClause.append(++bindCount);
      parameters.addElement(orderNum);
      clauseCount++;
    }

    if ((created != null) &&
        (!("".equals(created.trim()))) &&
        (!("ANY".equals(created))))
    {
      if (clauseCount > 0)
      {
        whereClause.append(" AND ");
      }  

      whereClause.append(" CREATION_DATE >= :");
      whereClause.append(++bindCount);
      whereClause.append(" - :");
      whereClause.append(++bindCount);
      parameters.addElement(getClientSysdate());
      parameters.addElement(getDaysToSubtract(created));
      clauseCount++;
    }

    if ((showMyOrders != null) && (!("".equals(showMyOrders.trim()))))
    {
      // Ordinarily, you would set this value based on the current user.
      // Since the tutorial has its own data model for users, we'll
      // set this to the seeded buyer's ID.

      if (clauseCount > 0)
      {
        whereClause.append(" AND ");   
      }
      
      whereClause.append(" BUYER_ID = :");
      whereClause.append(++bindCount);
      parameters.addElement(IntegerUtils.getInteger(6));  // 6 is the seeded buyer employee
      clauseCount++;
    }

    setWhereClause(whereClause.toString());

    if (bindCount > 0) 
    {
      Object[] params = new Object[bindCount];
      
      // The copyInto() is 1.1.8 compliant which, as of 07/04, is required by ARU
      
      parameters.copyInto(params); 
      setWhereClauseParams(params);
    }

     if ((executeQuery != null) && (executeQuery.booleanValue()))
     {
       executeQuery();
     } 

  } // end initQuery()
  

  protected java.sql.Date getClientSysdate()
  {
    OADBTransaction txn = (OADBTransaction)getApplicationModule().getTransaction();
    OANLSServices nls = txn.getOANLSServices();

    oracle.jbo.domain.Date serverDate = txn.getCurrentDBDate();
    
    java.util.Date javaClientDate = nls.getUserDate(serverDate);
    long interimDate = javaClientDate.getTime();

    return new java.sql.Date(interimDate);

  } // end getclientSysdate()

  
  protected Integer getDaysToSubtract(String created)
  {
    int days = 0;

    if ("TODAY".equals(created))
    {
      days = 0;
    }
    else if ("THIS_WEEK".equals(created))
    {
      days = 6;
    }
    else if ("LAST_30_DAYS".equals(created))
    {
      days = 29;
    }
    else if ("LAST_60_DAYS".equals(created))
    {
      days = 59;
    }
    
    return IntegerUtils.getInteger(days);
    
  }  // end getDaysToSubtract()



  /**
   * 
   * This is the default constructor (do not remove)
   */
  public PoSimpleSummaryVOImpl()
  {
  }

    /**Sample exportable method.
     */
    public void samplePoSimpleSummaryVOImplExportable() {
    }

    /**Sample exportable method.
     */
    public void samplePoSimpleSummaryVOImplExportable2(String testParam1) {
    }
}
