/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class DebugLabEmpFullVOImpl extends OAViewObjectImpl 
{
  public static final String RCS_ID="$Header: DebugLabEmpFullVOImpl.java 120.1 2005/06/06 09:36:32 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public DebugLabEmpFullVOImpl()
  {
  }

   // Initialize and execute the query.

  public void initQuery(String employeeNumber)
  {
    if ((employeeNumber != null) && (!("".equals(employeeNumber.trim()))))
    {
      // Do the following converion for type consistency.

      Number empNum = null;

      try
      {
        empNum = new Number(employeeNumber);
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
  } // end initQuery()
}