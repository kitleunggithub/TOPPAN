/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class SuppliersVOImpl extends OAViewObjectImpl {

  public static final String RCS_ID="$Header: SuppliersVOImpl.java 120.2 2006/07/03 18:05:27 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
	 VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.samplelib.server");


  public void initQuery(Boolean executeQuery)
  {
    executeQuery();
  }

  /**
   *
   * This is the default constructor (do not remove)
   */
  public SuppliersVOImpl()
  {
  }
}