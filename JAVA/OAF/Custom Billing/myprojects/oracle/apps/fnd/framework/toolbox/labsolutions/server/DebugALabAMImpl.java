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

public class DebugALabAMImpl extends OAApplicationModuleImpl 
{

  public static final String RCS_ID="$Header: DebugALabAMImpl.java 120.1 2005/06/06 09:29:22 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");
  
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public DebugALabAMImpl()
  {
  }

  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.labsolutions.server", "DebugALabAMLocal");
  }
}