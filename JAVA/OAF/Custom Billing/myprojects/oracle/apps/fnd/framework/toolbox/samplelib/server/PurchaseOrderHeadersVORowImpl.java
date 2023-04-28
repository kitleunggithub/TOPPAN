/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.server;

import oracle.jbo.domain.Number;
import oracle.jbo.server.AttributeDefImpl;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAViewRowImpl;

public class PurchaseOrderHeadersVORowImpl extends OAViewRowImpl {

    public static final int HEADERID = 0;
    public static final String RCS_ID="$Header: PurchaseOrderHeadersVORowImpl.java 120.2 2006/07/03 17:20:08 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
	VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.samplelib.server");
    public static final int DESCRIPTION = 1;
    public static final int STATUSCODE = 2;
    public static final int SUPPLIERID = 3;
    public static final int SUPPLIERSITEID = 4;

    /**
     *
     * This is the default constructor (do not remove)
     */
  public PurchaseOrderHeadersVORowImpl()
  {
  }

  /**
   *
   * Gets PurchaseOrderHeaderEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderHeaderEOImpl getPurchaseOrderHeaderEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderHeaderEOImpl)getEntity(0);
  }

  /**
   *
   * Gets the attribute value for HEADER_ID using the alias name HeaderId
   */
  public Number getHeaderId()
  {
    return (Number)getAttributeInternal(HEADERID);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for HEADER_ID using the alias name HeaderId
   */
  public void setHeaderId(Number value)
  {
    setAttributeInternal(HEADERID, value);
  }

  /**
   *
   * Gets the attribute value for DESCRIPTION using the alias name Description
   */
  public String getDescription()
  {
    return (String)getAttributeInternal(DESCRIPTION);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for DESCRIPTION using the alias name Description
   */
  public void setDescription(String value)
  {
    setAttributeInternal(DESCRIPTION, value);
  }

  /**
   *
   * Gets the attribute value for STATUS_CODE using the alias name StatusCode
   */
  public String getStatusCode()
  {
    return (String)getAttributeInternal(STATUSCODE);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for STATUS_CODE using the alias name StatusCode
   */
  public void setStatusCode(String value)
  {
    setAttributeInternal(STATUSCODE, value);
  }

  /**
   *
   * Gets the attribute value for SUPPLIER_ID using the alias name SupplierId
   */
  public Number getSupplierId()
  {
    return (Number)getAttributeInternal(SUPPLIERID);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for SUPPLIER_ID using the alias name SupplierId
   */
  public void setSupplierId(Number value)
  {
    setAttributeInternal(SUPPLIERID, value);
  }

  /**
   *
   * Gets the attribute value for SUPPLIER_SITE_ID using the alias name SupplierSiteId
   */
  public Number getSupplierSiteId()
  {
    return (Number)getAttributeInternal(SUPPLIERSITEID);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for SUPPLIER_SITE_ID using the alias name SupplierSiteId
   */
  public void setSupplierSiteId(Number value)
  {
    setAttributeInternal(SUPPLIERSITEID, value);
  }
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case HEADERID:
            return getHeaderId();
        case DESCRIPTION:
            return getDescription();
        case STATUSCODE:
            return getStatusCode();
        case SUPPLIERID:
            return getSupplierId();
        case SUPPLIERSITEID:
            return getSupplierSiteId();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case HEADERID:
            setHeaderId((Number)value);
            return;
        case DESCRIPTION:
            setDescription((String)value);
            return;
        case STATUSCODE:
            setStatusCode((String)value);
            return;
        case SUPPLIERID:
            setSupplierId((Number)value);
            return;
        case SUPPLIERSITEID:
            setSupplierSiteId((Number)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }
}