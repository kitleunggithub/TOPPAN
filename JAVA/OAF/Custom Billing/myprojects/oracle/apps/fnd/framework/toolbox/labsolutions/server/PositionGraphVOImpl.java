/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;
import oracle.apps.fnd.common.VersionInfo;

public class PositionGraphVOImpl extends OAViewObjectImpl 
{

  public static final String RCS_ID="$Header: PositionGraphVOImpl.java 120.1 2005/06/06 10:13:29 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");
  public void initQuery()
  {
    executeQuery();
    
  } // end initQuery()
  
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public PositionGraphVOImpl()
  {
  }

}
