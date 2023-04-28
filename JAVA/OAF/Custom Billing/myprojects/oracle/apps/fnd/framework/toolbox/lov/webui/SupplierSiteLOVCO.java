/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.lov.webui;

import java.util.Dictionary;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

/**
 * Controller for FWK_TBX_SUPPLIER_SITES_LOV region
 */
public class SupplierSiteLOVCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: SupplierSiteLOVCO.java 120.4 2006/05/25 00:25:48 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.lov.webui");

  /**
   * Layout and page setup logic for AK region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the AK region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);

    Dictionary passiveCriteriaItems = pageContext.getLovCriteriaItems();
    String supplierName = (String) passiveCriteriaItems.get("SupplierName");

    // Note: supplierName should not be null since it is defined as required 
    // passive criteria. Raise exception if null. The OA Framework typically 
    // handles this itself and generates a generic error message at the top 
    // of the Supplier Site LOV page if there is no supplier name.

    if (supplierName == null || ("".equals(supplierName)))
    {
      throw new OAException ("AK", "FWK_TBX_T_PO_SUP_BEFORE_SITE");
    }
/*
 * 
 * The following code was needed in pre-11.5.10 versions of the Toolbox when
 * the SupplierName field could have a partial value (and the corresponding
 * supplier id value would be null unless the user explicitly invoked the
 * supplier LOV.  In 11.5.10, with auto-validation, the supplier id is always
 * populated if the user leaves the supplier field with a valid value.
 * 
    // If supplierName is not null, go find the supplierId corresponding to this.

    OAApplicationModule am = pageContext.getApplicationModule(webBean);

    OAViewObject vo = (OAViewObject)am.findViewObject("IdForSupplierNameVVO1");

    if (vo == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "IdForSupplierNameVVO1") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

	  Serializable[] params  = { supplierName };
	  vo.invokeMethod("initQuery", params);

    Number supplierId;
    OARow row = (OARow)vo.first(); // Will make first row current in result set

    // We had an invalid supplier name
    if (row == null)
    {
      throw new OAException("AK", "FWK_TBX_T_LOV_FIELD_INVALID");
    }
    // We had multiple matches for the supplier name
    else if (vo.hasNext())
	  {
	    throw new OAException("AK", "FWK_TBX_T_LOV_TOO_MANY_MATCHES");
    }
	  else
	  {
      supplierId = (Number)row.getAttribute(0);

      // You have only one supplierId corresponding to the supplierName entered by the user
      OAViewObject lovVo = (OAViewObject)am.findViewObject("SupplierSitesLOVVO1");

      if (lovVo == null)
      {
        MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "SupplierSitesLOVVO1") };
        throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
      }

      lovVo.setWhereClause (null); // clean up from previous invokation
      lovVo.setWhereClauseParams (null); // clean up from previous invokation.
      lovVo.setWhereClause("SUPPLIER_ID = :1");
      lovVo.setWhereClauseParam(0, supplierId);
    }
*/

    // IMPORTANT: DO NOT EXECUTE THE VO QUERY! The LOV code will do this 
    // automatically for you.

  }

}
