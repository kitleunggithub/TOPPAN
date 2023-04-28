/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.lov.server;

import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;
import oracle.apps.fnd.common.VersionInfo;

public class LabSolutionsLOVAMImpl extends OAApplicationModuleImpl {
  public static final String RCS_ID="$Header: LabSolutionsLOVAMImpl.java 120.2 2006/07/03 14:53:52 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.lov.server");

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public LabSolutionsLOVAMImpl()
  {
  }


  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.lov.server", "LabSolutionsLOVAMLocal");
  }

  /**
   * 
   * Container's getter for EmployeeNamesVO1
   */
  public OAViewObjectImpl getEmployeeNamesVO1()
  {
    return (OAViewObjectImpl)findViewObject("EmployeeNamesVO1");
  }
}
