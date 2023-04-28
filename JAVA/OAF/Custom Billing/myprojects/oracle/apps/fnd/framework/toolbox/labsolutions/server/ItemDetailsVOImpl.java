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
import oracle.jbo.domain.Number;
import oracle.apps.fnd.framework.OAException;

public class ItemDetailsVOImpl extends OAViewObjectImpl 
{

  public static final String RCS_ID="$Header: ItemDetailsVOImpl.java 120.1 2005/06/06 10:06:35 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");
  public void initQuery(String itemNumber)
  {
     if ((itemNumber != null) && 
         (!("".equals(itemNumber.trim()))))
     {

       // Do the following conversion for type consistency.
       Number itemNum = null;
   
       try
       {
         itemNum = new Number(itemNumber);
       } 
       catch(Exception e) 
       {
         throw new OAException("AK", "FWK_TBX_INVALID_EMP_NUMBER");
       }
       setWhereClause("ITEM_ID = :1");
       setWhereClauseParams(null); // Always reset
       setWhereClauseParam(0, itemNum);
       executeQuery();
   
     }
   } // end initQuery()
   
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public ItemDetailsVOImpl()
  {
  }
}
