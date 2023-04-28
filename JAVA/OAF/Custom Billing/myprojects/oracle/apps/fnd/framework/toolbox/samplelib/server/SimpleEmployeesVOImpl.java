/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.server;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;
import oracle.apps.fnd.common.VersionInfo;

public class SimpleEmployeesVOImpl extends OAViewObjectImpl {

  public static final String RCS_ID="$Header: SimpleEmployeesVOImpl.java 120.2 2006/07/03 17:42:56 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.samplelib.server");

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public SimpleEmployeesVOImpl()
  {
  }

  public void initQuery()
  {
    setWhereClause("POSITION_CODE = 'PRESIDENT'");
    executeQuery();
  }
}