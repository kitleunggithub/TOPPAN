/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class PoSummaryVOImpl extends OAViewObjectImpl {

  public static final String RCS_ID="$Header: PoSummaryVOImpl.java 120.2 2006/07/04 00:56:09 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");

  public void initQuery(String status, Boolean executeQuery)
  {
    setWhereClauseParams(null); // Always reset
    setWhereClause(null);

    // Don't bother modifying the WHERE clause or binding a search
    // value if the status search criteria is null, or if we should
    // be searching for all purchase orders regardless of status.
    
    if ((status != null) && !("".equals(status)) && !("ALL".equals(status)))
    {
      setWhereClause("STATUS_CODE = :1");
      setWhereClauseParam(0, status);
    }

    if ((executeQuery != null) && (executeQuery.booleanValue()))
    {
       executeQuery();
    } 

  }
 
//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here ...
//  ---------------------------------------------------------------

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public PoSummaryVOImpl()
  {
  }
}
