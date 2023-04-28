/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;
import oracle.jbo.domain.Number;

public class PoDetailsFullVOImpl extends OAViewObjectImpl {

  public static final String RCS_ID="$Header: PoDetailsFullVOImpl.java 120.2 2006/07/04 00:01:04 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");

  public void initQuery(String orderNumber)
  {    
    setWhereClause(null); // Always reset
    setWhereClauseParams(null); // Always reset

    if ((orderNumber != null) && (!("".equals(orderNumber.trim()))))
    {
      // Do the following converion for type consistency.

      Number orderNum = null;
      
      try
      {
        orderNum = new Number(orderNumber);
      }  
      catch(Exception e) {}

      setWhereClause("HEADER_ID = :1");
      setWhereClauseParam(0, orderNum);
      
    }  
    
    executeQuery();
  }
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public PoDetailsFullVOImpl()
  {
  }
}
