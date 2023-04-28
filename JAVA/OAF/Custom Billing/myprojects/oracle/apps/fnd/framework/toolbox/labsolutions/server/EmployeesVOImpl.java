/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import java.util.Vector;

import oracle.jbo.domain.Number;
import oracle.jbo.server.ViewObjectImpl;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class EmployeesVOImpl extends OAViewObjectImpl
{

  public static final String RCS_ID="$Header: EmployeesVOImpl.java 120.1 2005/06/06 09:57:15 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.server");

  // Initialize and execute the query.

  public void initQuery(String employeeName, String employeeNumber)
  {
    // Note that the use of oracle-style bindings, while requiring a bit
    // more effort than the java-style binding, is REQUIRED of framework
    // code.

    StringBuffer whereClause = new StringBuffer(100);
    Vector parameters = new Vector(2);
    int clauseCount = 0;
    int bindCount = 0;

    setWhereClauseParams(null); // Always reset
    setWhereClause(null);

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

      whereClause.append(" EMPLOYEE_ID = :");
      whereClause.append(++bindCount);
      parameters.addElement(empNum);
      clauseCount++;
    }

    if ((employeeName != null) && (!("".equals(employeeName.trim()))))
    {
      if (clauseCount > 0)
      {
        whereClause.append(" AND ");
      }

      whereClause.append(" EMPLOYEE_NAME LIKE :");
      whereClause.append(++bindCount);
      parameters.addElement(employeeName+"%");
      clauseCount++;
    }

    setWhereClause(whereClause.toString());

    if (bindCount > 0)
    {
      Object[] params = new Object[bindCount];

      // the copyInto() is 1.1.8 compliant which, as of 7/02, is required by ARU

      parameters.copyInto(params);
      setWhereClauseParams(params);
    }

    executeQuery();

  } // end initQuery()

//  ---------------------------------------------------------------
//  ---    Unodified, generated code from here.
//  ---------------------------------------------------------------

  /**
   *
   * This is the default constructor (do not remove)
   */
  public EmployeesVOImpl()
  {
  }
}
