/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.common.VersionInfo;

public class DebugLabAMImpl extends OAApplicationModuleImpl 
{

  public static final String RCS_ID="$Header: DebugLabAMImpl.java 120.1 2005/06/06 09:34:11 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public DebugLabAMImpl()
  {
  }

  public void initQuery(String employeeName, String employeeNumber)
  {
    DebugLabEmpSummaryVOImpl vo = getDebugLabEmpSummaryVO1();
    vo.initQuery(employeeName, employeeNumber);
    
  } // end initDetails()

  public void rollbackEmployee()
  {
    getTransaction().rollback();
    
  } // end rollbackEmployee()

  public void apply()
  {
    getTransaction().commit();
    
  } // end apply()

  public void createEmployee()
  {
    DebugLabEmpFullVOImpl vo = getDebugLabEmpFullVO1();
    vo.insertRow(vo.createRow());

  } // end createEmployee()

  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.labsolutions.server", "DebugAMLocal");
  }

  /**
   * 
   * Container's getter for DebugLabEmpSummaryVO1
   */
  public DebugLabEmpSummaryVOImpl getDebugLabEmpSummaryVO1()
  {
    return (DebugLabEmpSummaryVOImpl)findViewObject("DebugLabEmpSummaryVO1");
  }

  /**
   * 
   * Container's getter for DebugLabEmpFullVO1
   */
  public DebugLabEmpFullVOImpl getDebugLabEmpFullVO1()
  {
    return (DebugLabEmpFullVOImpl)findViewObject("DebugLabEmpFullVO1");
  }



}