package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.framework.server.OAViewObjectImpl;
import oracle.jbo.domain.Number;
import oracle.apps.fnd.common.VersionInfo;
//  ---------------------------------------------------------------
//  ---    File generated by Oracle Business Components for Java.
//  ---------------------------------------------------------------
// javadoc_private

public class SiteNameForIdVVOImpl extends OAViewObjectImpl {

  public static final String RCS_ID="$Header: SiteNameForIdVVOImpl.java 120.2 2006/07/03 22:03:50 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");

  public void initQuery(Number supplierId, Number supplierSiteId)
  {
    setWhereClauseParams(null); // Always reset
    setWhereClauseParam(0, supplierId);
    setWhereClauseParam(1, supplierSiteId);
    executeQuery();
  }
  
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public SiteNameForIdVVOImpl()
  {
  }
}