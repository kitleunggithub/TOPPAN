/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |       20-APR-02  L Lyons  Created                                         |
 |                                                                           |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.common.VersionInfo;

public interface ApprovalManager
{
  // Mandatory for Applications source control
  public static final String RCS_ID="$Header: ApprovalManager.java 120.1 2005/06/06 13:21:29 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");

  public void doApprove(Approvable obj);

  public void doReject(Approvable obj);

}
