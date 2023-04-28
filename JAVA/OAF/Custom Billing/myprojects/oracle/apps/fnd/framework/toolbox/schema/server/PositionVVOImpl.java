package oracle.apps.fnd.framework.toolbox.schema.server;
// javadoc_private

import oracle.apps.fnd.framework.server.OAViewObjectImpl;
import oracle.apps.fnd.common.VersionInfo;

public class PositionVVOImpl extends OAViewObjectImpl {

  public static final String RCS_ID="$Header: PositionVVOImpl.java 120.2 2006/07/03 21:02:33 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");

 public void initQuery(String positionCode)
 {
   setWhereClauseParams(null); // Always reset
   setWhereClauseParam(0, positionCode);
   executeQuery();

 }

 //  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here
//  ---------------------------------------------------------------


  /**
   *
   * This is the default constructor (do not remove)
   */
  public PositionVVOImpl()
  {
  }
}
