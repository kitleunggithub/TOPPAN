/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAEntityExpert;

/*
* Provides access to common validation utilities.
*/
public class SupplierEntityExpert extends OAEntityExpert
{
  // Mandatory for Applications source control
  public static final String RCS_ID="$Header: SupplierEntityExpert.java 120.1 2005/06/06 15:03:25 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");


  /*
   *****************************************************************************
   * Returns true if the given supplier name exists (case insensitive).
   *****************************************************************************
   */
  public boolean supplierExists(String supplierName)
  {
     boolean exists = false;
     
     SupplierNameVVOImpl vvo = 
       (SupplierNameVVOImpl)findValidationViewObject("SupplierNameVVO1");
     vvo.initQuery(supplierName);

     if (vvo.hasNext())
     {
        exists = true;
     }

     return exists;
     
  } // end supplierExists()

  /*
   *****************************************************************************
   * Returns true if the given supplier is currently active.
   *****************************************************************************
   */
  public boolean isSupplierActive(Number supplierId)
  {
    boolean isActive = false;
    
	  // Note that we want to use a cached, declaratively defined VO instead of creating
	  // one from a SQL statement which is far less performant.

    SupplierIdVVOImpl supplierVO = 
      (SupplierIdVVOImpl)findValidationViewObject("SupplierIdVVO1");
    supplierVO.initQuery(supplierId);

     // We're just doing a simple existance check.  If we don't find a match, 
     // return false.

     if (supplierVO.hasNext())
     {
       isActive = true;
     }
     
     return isActive;
     
  } // end isSupplierActive()


  /*
   *****************************************************************************
   * Returns true if the given supplier is currently active and not on
   * purchasing hold.
   *****************************************************************************
   */
  public boolean isSupplierValidForPurchasing(Number supplierId)
  {
    boolean isValid = false;
    
	  // Note that we want to use a cached, declaratively defined VO instead of creating
	  // one from a SQL statement which is far less performant.

    SupplierIdPoVVOImpl vvo = 
      (SupplierIdPoVVOImpl)findValidationViewObject("SupplierIdPoVVO1");
    vvo.initQuery(supplierId);

     // We're just doing a simple existance check.  If we don't find a match, 
     // return false.

     if (vvo.hasNext())
     {
       isValid = true;
     }
    
     return isValid;
     
  } // end isSupplierValidForPurchasing()

  
  /*
   *****************************************************************************
   * Returns true if the supplierSiteId is associated with supplierId
   * and the site is currently active.
   *****************************************************************************
   */
  public boolean isSiteActive(Number supplierId, Number supplierSiteId)
  {
    boolean isActive = false;
    
	  // Note that we want to use a cached, declaratively defined VO instead of creating
	  // one from a SQL statement which is far less performant.

    SiteIdVVOImpl vvo = (SiteIdVVOImpl)findValidationViewObject("SiteIdVVO1");
    vvo.initQuery(supplierSiteId, supplierId);

     // We're just doing a simple existance check.  If we don't find a match, 
     // return false.

     if (vvo.hasNext())
     {
       isActive = true;
     }
     
     return isActive;
  
  } // end isSiteActive()


  /*
   *****************************************************************************
   * Returns true if supplierSiteId is associated with supplierId, the site
   * is currently active and it is a "Purchasing" enabled site.
   *****************************************************************************
   */
  public boolean isSiteValidForPurchasing(Number supplierId, Number supplierSiteId)
  {
    boolean isValid = false;
       
	  // Note that we want to use a cached, declaratively defined VO instead of creating
	  // one from a SQL statement which is far less performant.

    SiteIdPoVVOImpl vvo = (SiteIdPoVVOImpl)findValidationViewObject("SiteIdPoVVO1");
    vvo.initQuery(supplierSiteId, supplierId);

     // We're just doing a simple existance check.  If we don't find a match, 
     // return false.

     if (vvo.hasNext())
     {
       isValid = true;
     }

     return isValid;
  
  } // end isSiteValidForPurchasing()

}
