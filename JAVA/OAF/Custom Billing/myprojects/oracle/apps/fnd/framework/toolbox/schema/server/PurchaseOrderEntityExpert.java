/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.server.OAEntityExpert;

/*
* Provides access to common validation utitilities. 
*/
public class PurchaseOrderEntityExpert extends OAEntityExpert
{
  // Mandatory for Applications source control
  public static final String RCS_ID="$Header: PurchaseOrderEntityExpert.java 120.1 2005/06/06 14:35:50 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");

  /*
   *****************************************************************************
   *  Returns true if the given lookupCode and lookupType are valid.
   *****************************************************************************
   */
  public boolean isLookupCodeValid(String lookupCode, String lookupType)
  {
    boolean isValid = false;
    
	  // Note that we want to use a cached, declaratively defined VO instead of 
    // creating one programmatically from a SQL statement which is far less 
    // performant.

     LookupCodeVVOImpl lookupVO = 
       (LookupCodeVVOImpl)findValidationViewObject("LookupCodeVVO1");
     lookupVO.initQuery(lookupCode, lookupType);

     // We're just doing a simple existance check.  

     if (lookupVO.hasNext())
     {
       isValid = true;
     }

     return isValid;

  } // end isLookupCodeValid()

}
