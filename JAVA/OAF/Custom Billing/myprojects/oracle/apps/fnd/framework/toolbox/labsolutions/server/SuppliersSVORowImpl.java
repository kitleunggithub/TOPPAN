/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;
import oracle.jbo.domain.Date;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.server.OAViewRowImpl;

public class SuppliersSVORowImpl extends OAViewRowImpl 
{

  protected static final int SUPPLIERID = 0;
  protected static final int NAME = 1;
  protected static final int ONHOLDFLAG = 2;
  protected static final int STARTDATE = 3;
  protected static final int ENDDATE = 4;
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID="$Header: SuppliersSVORowImpl.java 120.4 2006/05/25 00:13:20 atgops1 noship $";
  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.server");



  /**
   * 
   * This is the default constructor (do not remove)
   */
  public SuppliersSVORowImpl()
  {
  }

  /**
   * 
   * Gets SupplierEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.SupplierEOImpl getSupplierEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.SupplierEOImpl)getEntity(0);
  }










  //  Generated method. Do not modify.

  //  Generated method. Do not modify.



}