/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.jbo.domain.Number;
import oracle.jbo.server.ViewObjectImpl;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class EmployeeSummaryVOImpl extends OAViewObjectImpl
{

  public static final String RCS_ID="$Header: EmployeeSummaryVOImpl.java 120.1 2005/06/06 09:52:44 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
		 VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.server");

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
  /**
   *
   * This is the default constructor (do not remove)
   */
  public EmployeeSummaryVOImpl()
  {
  }
}
