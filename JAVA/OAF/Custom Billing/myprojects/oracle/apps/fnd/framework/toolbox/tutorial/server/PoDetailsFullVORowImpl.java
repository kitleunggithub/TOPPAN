/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;
import oracle.apps.fnd.framework.server.OAViewRowImpl;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;
import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.toolbox.poplist.server.StatusListVOImpl;
import oracle.apps.fnd.framework.toolbox.poplist.server.StatusListVORowImpl;

public class PoDetailsFullVORowImpl extends OAViewRowImpl {
    public static final int HEADERID = 0;
    public static final int DESCRIPTION = 1;
    public static final int STATUSCODE = 2;
    public static final int SUPPLIERID = 3;
    public static final int SUPPLIERSITEID = 4;
    public static final int CURRENCYCODE = 5;
    public static final int BUYERID = 6;
    public static final int PAYMENTTERMSCODE = 7;
    public static final int CARRIERCODE = 8;
    public static final int ORDERTOTAL = 9;
    public static final int CONFIRMFLAG = 10;
    public static final int FULLNAME = 11;
    public static final int EMPLOYEEID = 12;
    public static final int NAME = 13;
    public static final int SUPPLIERID1 = 14;
    public static final int SITENAME = 15;
    public static final int SUPPLIERSITEID1 = 16;
    public static final int BUYEREMAIL = 17;
    public static final int STATUSDISPLAY = 18;
    public static final String RCS_ID="$Header: PoDetailsFullVORowImpl.java 120.2 2006/07/04 00:06:07 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");
    public static final int POLINESHIPFULLVO = 19;

    /**
     *
     * This is the default constructor (do not remove)
     */
  public PoDetailsFullVORowImpl()
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
   * Gets EmployeeEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.EmployeeEOImpl getEmployeeEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.EmployeeEOImpl)getEntity(1);
  }

  /**
   * 
   * Gets SupplierEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.SupplierEOImpl getSupplierEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.SupplierEOImpl)getEntity(2);
  }

  /**
   * 
   * Gets SupplierSiteEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.SupplierSiteEOImpl getSupplierSiteEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.SupplierSiteEOImpl)getEntity(3);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute StatusDisplay
   */
  public String getStatusDisplay()
  {
    String statusDisplay = (String)getAttributeInternal(STATUSDISPLAY);

    if ((statusDisplay == null) || ("".equals(statusDisplay.trim())))
    {
      String statusCode = getStatusCode();

      if ((statusCode != null) && (!("".equals(statusCode.trim()))))
      {
        // Use a cached copy of the VO.
        
        StatusListVOImpl vo = 
          (StatusListVOImpl)getApplicationModule().findViewObject("StatusListVO1");
        vo.initQuery(statusCode);

        // For performance reasons, we generate ViewRowImpls for all
        // View Objects.  When we need to obtain an attribute value,
        // we use the named accessors instead of a generic String lookup.
      
        // statusDisplay = (String)vo.first().getAttribute("Meaning");
        StatusListVORowImpl row = (StatusListVORowImpl)vo.first();
        statusDisplay = row.getMeaning();
        
      }
    }  
      
    return statusDisplay;  

    
  } // end getStatusDisplay()

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

  /**
   * 
   * Gets the attribute value for CURRENCY_CODE using the alias name CurrencyCode
   */
  public String getCurrencyCode()
  {
    return (String)getAttributeInternal(CURRENCYCODE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for CURRENCY_CODE using the alias name CurrencyCode
   */
  public void setCurrencyCode(String value)
  {
    setAttributeInternal(CURRENCYCODE, value);
  }

  /**
   * 
   * Gets the attribute value for BUYER_ID using the alias name BuyerId
   */
  public Number getBuyerId()
  {
    return (Number)getAttributeInternal(BUYERID);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for BUYER_ID using the alias name BuyerId
   */
  public void setBuyerId(Number value)
  {
    setAttributeInternal(BUYERID, value);
  }

  /**
   * 
   * Gets the attribute value for PAYMENT_TERMS_CODE using the alias name PaymentTermsCode
   */
  public String getPaymentTermsCode()
  {
    return (String)getAttributeInternal(PAYMENTTERMSCODE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for PAYMENT_TERMS_CODE using the alias name PaymentTermsCode
   */
  public void setPaymentTermsCode(String value)
  {
    setAttributeInternal(PAYMENTTERMSCODE, value);
  }

  /**
   * 
   * Gets the attribute value for CARRIER_CODE using the alias name CarrierCode
   */
  public String getCarrierCode()
  {
    return (String)getAttributeInternal(CARRIERCODE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for CARRIER_CODE using the alias name CarrierCode
   */
  public void setCarrierCode(String value)
  {
    setAttributeInternal(CARRIERCODE, value);
  }

  /**
   * 
   * Gets the attribute value for ORDERTOTAL using the alias name OrderTotal
   */
  public Number getOrderTotal()
  {
    return (Number)getAttributeInternal(ORDERTOTAL);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ORDERTOTAL using the alias name OrderTotal
   */
  public void setOrderTotal(Number value)
  {
    setAttributeInternal(ORDERTOTAL, value);
  }

  /**
   * 
   * Gets the attribute value for CONFIRM_FLAG using the alias name ConfirmFlag
   */
  public String getConfirmFlag()
  {
    return (String)getAttributeInternal(CONFIRMFLAG);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for CONFIRM_FLAG using the alias name ConfirmFlag
   */
  public void setConfirmFlag(String value)
  {
    setAttributeInternal(CONFIRMFLAG, value);
  }

  /**
   * 
   * Gets the attribute value for FULL_NAME using the alias name FullName
   */
  public String getFullName()
  {
    return (String)getAttributeInternal(FULLNAME);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for FULL_NAME using the alias name FullName
   */
  public void setFullName(String value)
  {
    setAttributeInternal(FULLNAME, value);
  }

  /**
   * 
   * Gets the attribute value for EMPLOYEE_ID using the alias name EmployeeId
   */
  public Number getEmployeeId()
  {
    return (Number)getAttributeInternal(EMPLOYEEID);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for EMPLOYEE_ID using the alias name EmployeeId
   */
  public void setEmployeeId(Number value)
  {
    setAttributeInternal(EMPLOYEEID, value);
  }

  /**
   * 
   * Gets the attribute value for NAME using the alias name Name
   */
  public String getName()
  {
    return (String)getAttributeInternal(NAME);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for NAME using the alias name Name
   */
  public void setName(String value)
  {
    setAttributeInternal(NAME, value);
  }

  /**
   * 
   * Gets the attribute value for SUPPLIER_ID using the alias name SupplierId1
   */
  public Number getSupplierId1()
  {
    return (Number)getAttributeInternal(SUPPLIERID1);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for SUPPLIER_ID using the alias name SupplierId1
   */
  public void setSupplierId1(Number value)
  {
    setAttributeInternal(SUPPLIERID1, value);
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
   * Gets the attribute value for SUPPLIER_SITE_ID using the alias name SupplierSiteId1
   */
  public Number getSupplierSiteId1()
  {
    return (Number)getAttributeInternal(SUPPLIERSITEID1);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for SUPPLIER_SITE_ID using the alias name SupplierSiteId1
   */
  public void setSupplierSiteId1(Number value)
  {
    setAttributeInternal(SUPPLIERSITEID1, value);
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
        case CURRENCYCODE:
            return getCurrencyCode();
        case BUYERID:
            return getBuyerId();
        case PAYMENTTERMSCODE:
            return getPaymentTermsCode();
        case CARRIERCODE:
            return getCarrierCode();
        case ORDERTOTAL:
            return getOrderTotal();
        case CONFIRMFLAG:
            return getConfirmFlag();
        case FULLNAME:
            return getFullName();
        case EMPLOYEEID:
            return getEmployeeId();
        case NAME:
            return getName();
        case SUPPLIERID1:
            return getSupplierId1();
        case SITENAME:
            return getSiteName();
        case SUPPLIERSITEID1:
            return getSupplierSiteId1();
        case BUYEREMAIL:
            return getBuyerEmail();
        case STATUSDISPLAY:
            return getStatusDisplay();
        case POLINESHIPFULLVO:
            return getPoLineShipFullVO();
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
        case CURRENCYCODE:
            setCurrencyCode((String)value);
            return;
        case BUYERID:
            setBuyerId((Number)value);
            return;
        case PAYMENTTERMSCODE:
            setPaymentTermsCode((String)value);
            return;
        case CARRIERCODE:
            setCarrierCode((String)value);
            return;
        case ORDERTOTAL:
            setOrderTotal((Number)value);
            return;
        case CONFIRMFLAG:
            setConfirmFlag((String)value);
            return;
        case FULLNAME:
            setFullName((String)value);
            return;
        case EMPLOYEEID:
            setEmployeeId((Number)value);
            return;
        case NAME:
            setName((String)value);
            return;
        case SUPPLIERID1:
            setSupplierId1((Number)value);
            return;
        case SITENAME:
            setSiteName((String)value);
            return;
        case SUPPLIERSITEID1:
            setSupplierSiteId1((Number)value);
            return;
        case BUYEREMAIL:
            setBuyerEmail((String)value);
            return;
        case STATUSDISPLAY:
            setStatusDisplay((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }

  /**
   * 
   * Gets the attribute value for EMAIL_ADDRESS using the alias name BuyerEmail
   */
  public String getBuyerEmail()
  {
    return (String)getAttributeInternal(BUYEREMAIL);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for EMAIL_ADDRESS using the alias name BuyerEmail
   */
  public void setBuyerEmail(String value)
  {
    setAttributeInternal(BUYEREMAIL, value);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute StatusDisplay
   */
  public void setStatusDisplay(String value)
  {
    setAttributeInternal(STATUSDISPLAY, value);
  }

  /**
   * 
   * Gets the associated <code>RowIterator</code> using master-detail link PoLineShipFullVO
   */
  public oracle.jbo.RowIterator getPoLineShipFullVO()
  {
    return (oracle.jbo.RowIterator)getAttributeInternal(POLINESHIPFULLVO);
  }
}
