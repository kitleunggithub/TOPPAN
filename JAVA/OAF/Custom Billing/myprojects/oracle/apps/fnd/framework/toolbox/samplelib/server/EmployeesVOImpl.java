/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.server;

import oracle.jbo.domain.Number;
import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class EmployeesVOImpl extends OAViewObjectImpl {

  public static final String RCS_ID="$Header: EmployeesVOImpl.java 120.2 2006/07/03 16:51:52 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
    VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.samplelib.server");

  /**
   *
   * This is the default constructor (do not remove)
   */
  public EmployeesVOImpl()
  {
  }

  public void initQuery(Boolean executeQuery)
  {
    // Check the executeQuery parameter and explicitly execute
    // the query if needed.  

    if ((executeQuery != null) && (executeQuery.booleanValue()))
    {
       executeQuery();
    }   
    
  }

  public void initQuery()
  {
    executeQuery();
  }

  /**
  * Convinience method.
  * This method queries the VO with supplied EmployeeId. 
  */
  public void detailsQuery(String EmployeeId)
    {
     if ((EmployeeId != null) && 
         (!("".equals(EmployeeId.trim()))))
     {

       // Do the following conversion for type consistency.
       Number empNum = null;
   
       try
       {
         empNum = new Number(EmployeeId);
       } 
       catch(Exception e) 
       {
         throw new OAException("AK", "FWK_TBX_INVALID_EMP_NUMBER");
       }
       setWhereClause("EMPLOYEE_ID = :1");
       setWhereClauseParams(null); // Always reset
       setWhereClauseParam(0, empNum);
       executeQuery();
   
     }
  }
}