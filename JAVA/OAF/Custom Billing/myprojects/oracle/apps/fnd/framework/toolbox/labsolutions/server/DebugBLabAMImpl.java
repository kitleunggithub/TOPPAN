/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;

public class DebugBLabAMImpl extends OAApplicationModuleImpl 
{

  public static final String RCS_ID="$Header: DebugBLabAMImpl.java 120.1 2005/06/06 09:31:46 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public DebugBLabAMImpl()
  {
  }

  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.labsolutions.server", "DebugBLabAMLocal");
  }
}