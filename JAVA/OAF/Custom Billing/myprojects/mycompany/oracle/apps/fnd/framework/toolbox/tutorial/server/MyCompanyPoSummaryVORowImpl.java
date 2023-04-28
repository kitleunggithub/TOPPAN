package mycompany.oracle.apps.fnd.framework.toolbox.tutorial.server;
import oracle.apps.fnd.framework.toolbox.tutorial.server.PoSummaryVORowImpl;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;
import oracle.jbo.domain.Date;
//  ---------------------------------------------------------------
//  ---    File generated by Oracle Business Components for Java.
//  ---------------------------------------------------------------

public class MyCompanyPoSummaryVORowImpl extends PoSummaryVORowImpl 
{
;


;
  protected static final int MAXATTRCONST = oracle.jbo.server.ViewDefImpl.getMaxAttrConst("oracle.apps.fnd.framework.toolbox.tutorial.server.PoSummaryVO");
  protected static final int SUPPLIERSITEID = MAXATTRCONST;
  protected static final int SITENAME = MAXATTRCONST + 1;
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public MyCompanyPoSummaryVORowImpl()
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
   * Gets SupplierEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.SupplierEOImpl getSupplierEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.SupplierEOImpl)getEntity(1);
  }

  /**
   * 
   * Gets EmployeeEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.EmployeeEOImpl getEmployeeEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.EmployeeEOImpl)getEntity(2);
  }

  /**
   * 
   * Gets LookupCodeEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.LookupCodeEOImpl getLookupCodeEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.LookupCodeEOImpl)getEntity(3);
  }

  /**
   * 
   * Gets SupplierSiteEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.SupplierSiteEOImpl getSupplierSiteEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.SupplierSiteEOImpl)getEntity(4);
  }

  /**
   * 
   * Gets the attribute value for HEADER_ID using the alias name HeaderId
   */
  public Number getHeaderId()
  {
    return super.getHeaderId();
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for HEADER_ID using the alias name HeaderId
   */
  public void setHeaderId(Number value)
  {
    super.setHeaderId(value);
  }

  /**
   * 
   * Gets the attribute value for DESCRIPTION using the alias name Description
   */
  public String getDescription()
  {
    return super.getDescription();
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for DESCRIPTION using the alias name Description
   */
  public void setDescription(String value)
  {
    super.setDescription(value);
  }

  /**
   * 
   * Gets the attribute value for STATUS_CODE using the alias name StatusCode
   */
  public String getStatusCode()
  {
    return super.getStatusCode();
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for STATUS_CODE using the alias name StatusCode
   */
  public void setStatusCode(String value)
  {
    super.setStatusCode(value);
  }

  /**
   * 
   * Gets the attribute value for SUPPLIER_ID using the alias name SupplierId
   */
  public Number getSupplierId()
  {
    return super.getSupplierId();
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for SUPPLIER_ID using the alias name SupplierId
   */
  public void setSupplierId(Number value)
  {
    super.setSupplierId(value);
  }

  /**
   * 
   * Gets the attribute value for CURRENCY_CODE using the alias name CurrencyCode
   */
  public String getCurrencyCode()
  {
    return super.getCurrencyCode();
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for CURRENCY_CODE using the alias name CurrencyCode
   */
  public void setCurrencyCode(String value)
  {
    super.setCurrencyCode(value);
  }

  /**
   * 
   * Gets the attribute value for CREATION_DATE using the alias name CreationDate
   */
  public Date getCreationDate()
  {
    return super.getCreationDate();
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for CREATION_DATE using the alias name CreationDate
   */
  public void setCreationDate(Date value)
  {
    super.setCreationDate(value);
  }

  /**
   * 
   * Gets the attribute value for NAME using the alias name SupplierName
   */
  public String getSupplierName()
  {
    return super.getSupplierName();
  }

  /**
   * 
   * Gets the attribute value for SUPPLIER_ID using the alias name SupplierId1
   */
  public Number getSupplierId1()
  {
    return super.getSupplierId1();
  }

  /**
   * 
   * Gets the attribute value for FULL_NAME using the alias name BuyerName
   */
  public String getBuyerName()
  {
    return super.getBuyerName();
  }

  /**
   * 
   * Gets the attribute value for EMPLOYEE_ID using the alias name EmployeeId
   */
  public Number getEmployeeId()
  {
    return super.getEmployeeId();
  }

  /**
   * 
   * Gets the attribute value for BUYER_ID using the alias name BuyerId
   */
  public Number getBuyerId()
  {
    return super.getBuyerId();
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for BUYER_ID using the alias name BuyerId
   */
  public void setBuyerId(Number value)
  {
    super.setBuyerId(value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute SelectFlag
   */
  public String getSelectFlag()
  {
    return super.getSelectFlag();
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute SelectFlag
   */
  public void setSelectFlag(String value)
  {
    super.setSelectFlag(value);
  }

  /**
   * 
   * Gets the attribute value for EMAIL_ADDRESS using the alias name BuyerEmail
   */
  public String getBuyerEmail()
  {
    return super.getBuyerEmail();
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute OrderTotal
   */
  public Number getOrderTotal()
  {
    return super.getOrderTotal();
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute OrderTotal
   */
  public void setOrderTotal(Number value)
  {
    super.setOrderTotal(value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute StatusImage
   */
  public String getStatusImage()
  {
    return super.getStatusImage();
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute StatusImage
   */
  public void setStatusImage(String value)
  {
    super.setStatusImage(value);
  }

  /**
   * 
   * Gets the attribute value for MEANING using the alias name StatusDisplay
   */
  public String getStatusDisplay()
  {
    return super.getStatusDisplay();
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute DeleteImage
   */
  public String getDeleteImage()
  {
    return super.getDeleteImage();
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute DeleteImage
   */
  public void setDeleteImage(String value)
  {
    super.setDeleteImage(value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute UpdateImage
   */
  public String getUpdateImage()
  {
    return super.getUpdateImage();
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute UpdateImage
   */
  public void setUpdateImage(String value)
  {
    super.setUpdateImage(value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute ApproveDisabled
   */
  public String getApproveDisabled()
  {
    return super.getApproveDisabled();
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute ApproveDisabled
   */
  public void setApproveDisabled(String value)
  {
    super.setApproveDisabled(value);
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
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
    if (index == SUPPLIERSITEID)
    {
      return getSupplierSiteId();
    }
    if (index == SITENAME)
    {
      return getSiteName();
    }
    return super.getAttrInvokeAccessor(index, attrDef);
  }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
    if (index == SUPPLIERSITEID)
    {
      setSupplierSiteId((Number)value);
      return;
    }
    if (index == SITENAME)
    {
      setSiteName((String)value);
      return;
    }
    super.setAttrInvokeAccessor(index, value, attrDef);
    return;
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute StatusDisplay
   */
  public void setStatusDisplay(String value)
  {
    super.setStatusDisplay(value);
  }
}