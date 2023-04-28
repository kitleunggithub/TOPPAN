/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.server;

import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.AttributeDefImpl;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAViewRowImpl;

public class SupplierSitesVORowImpl extends OAViewRowImpl {

    public static final int SUPPLIERID = 0;
    public static final String RCS_ID="$Header: SupplierSitesVORowImpl.java 120.2 2006/07/03 17:59:19 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
    VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.samplelib.server");
    public static final int SUPPLIERSITEID = 1;
    public static final int SITENAME = 2;
    public static final int PURCHASINGSITEFLAG = 3;
    public static final int STARTDATE = 4;
    public static final int ENDDATE = 5;
    public static final int SUPPLIERSVO = 6;


    /**
     *
     * This is the default constructor (do not remove)
     */
  public SupplierSitesVORowImpl()
  {
  }

  /**
   *
   * Gets SupplierSiteEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.SupplierSiteEOImpl getSupplierSiteEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.SupplierSiteEOImpl)getEntity(0);
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

  /**
   *
   * Gets the attribute value for SITE_NAME using the alias name SiteName
   */
  public String getSiteName()
  {
    return (String)getAttributeInternal(SITENAME);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for SITE_NAME using the alias name SiteName
   */
  public void setSiteName(String value)
  {
    setAttributeInternal(SITENAME, value);
  }

  /**
   *
   * Gets the attribute value for PURCHASING_SITE_FLAG using the alias name PurchasingSiteFlag
   */
  public String getPurchasingSiteFlag()
  {
    return (String)getAttributeInternal(PURCHASINGSITEFLAG);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for PURCHASING_SITE_FLAG using the alias name PurchasingSiteFlag
   */
  public void setPurchasingSiteFlag(String value)
  {
    setAttributeInternal(PURCHASINGSITEFLAG, value);
  }

  /**
   *
   * Gets the attribute value for START_DATE using the alias name StartDate
   */
  public Date getStartDate()
  {
    return (Date)getAttributeInternal(STARTDATE);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for START_DATE using the alias name StartDate
   */
  public void setStartDate(Date value)
  {
    setAttributeInternal(STARTDATE, value);
  }

  /**
   *
   * Gets the attribute value for END_DATE using the alias name EndDate
   */
  public Date getEndDate()
  {
    return (Date)getAttributeInternal(ENDDATE);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for END_DATE using the alias name EndDate
   */
  public void setEndDate(Date value)
  {
    setAttributeInternal(ENDDATE, value);
  }
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case SUPPLIERID:
            return getSupplierId();
        case SUPPLIERSITEID:
            return getSupplierSiteId();
        case SITENAME:
            return getSiteName();
        case PURCHASINGSITEFLAG:
            return getPurchasingSiteFlag();
        case STARTDATE:
            return getStartDate();
        case ENDDATE:
            return getEndDate();
        case SUPPLIERSVO:
            return getSuppliersVO();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case SUPPLIERID:
            setSupplierId((Number)value);
            return;
        case SUPPLIERSITEID:
            setSupplierSiteId((Number)value);
            return;
        case SITENAME:
            setSiteName((String)value);
            return;
        case PURCHASINGSITEFLAG:
            setPurchasingSiteFlag((String)value);
            return;
        case STARTDATE:
            setStartDate((Date)value);
            return;
        case ENDDATE:
            setEndDate((Date)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }

  /**
   *
   * Gets the associated <code>Row</code> using master-detail link SuppliersVO
   */
  public oracle.jbo.Row getSuppliersVO()
  {
    return (oracle.jbo.Row)getAttributeInternal(SUPPLIERSVO);
  }
}