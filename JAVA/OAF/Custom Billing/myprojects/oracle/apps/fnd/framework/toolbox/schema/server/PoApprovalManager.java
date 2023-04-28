/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |       20-APR-02  L Lyons   Created                                        |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;

public class PoApprovalManager implements ApprovalManager
{
  // Mandatory for Applications source control
  public static final String RCS_ID="$Header: PoApprovalManager.java 120.1 2005/06/06 14:19:27 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");

  public void PoApprovalManager()
  {
  }      

  public void doApprove(Approvable po) throws OAException
  {
    // ...
    // This is where your approval logic (authority checking, etc.)
    // would go.  This just gives a general idea of how you might use a helper
    // class to encapsulate complex processing logic for your EO.
    // ...

    po.setApproved();

  } // end doApprove()


  public void doReject(Approvable po) throws OAException
  {
    // Not implemented for this version of the tutorial.

  } // end doReject()

}
