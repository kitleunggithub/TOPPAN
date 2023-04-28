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
import java.util.List;

public class PurchaseOrdersSVORowImpl extends OAViewRowImpl {

    public static final int PONUMBER = 0;
    public static final int DESCRIPTION = 1;
    public static final int STATUSCODE = 2;
    public static final int SUPPLIERID = 3;
    public static final int SUPPLIERSITEID = 4;
    public static final int CURRENCYCODE = 5;
    public static final int BUYERID = 6;
    public static final int PAYMENTTERMSCODE = 7;
    public static final int CARRIERCODE = 8;
    public static final int RATE = 9;
    public static final int BUYERNAME = 10;
    public static final int EMPLOYEEID = 11;
    public static final int SUPPLIERNAME = 12;
    public static final int SUPPLIERID1 = 13;
    public static final int SUPPLIERSITENAME = 14;
    public static final int SUPPLIERSITEID1 = 15;
    public static final int SUPPLIERATTACHMENTS = 16;
    public static final int POATTACHMENTS = 17;
    public static final int HEADERATTRIBUTECATEGORY = 18;
    public static final int HEADERATTRIBUTE1 = 19;
    public static final int HEADERATTRIBUTE2 = 20;
    public static final int HEADERATTRIBUTE3 = 21;
    public static final int HEADERATTRIBUTE4 = 22;
    public static final int HEADERATTRIBUTE5 = 23;
    public static final int HEADERATTRIBUTE6 = 24;
    public static final int HEADERATTRIBUTE7 = 25;
    public static final int HEADERATTRIBUTE8 = 26;
    public static final int HEADERATTRIBUTE9 = 27;
    public static final int HEADERATTRIBUTE10 = 28;
    public static final int HEADERATTRIBUTE11 = 29;
    public static final int HEADERATTRIBUTE12 = 30;
    public static final int HEADERATTRIBUTE13 = 31;
    public static final int HEADERATTRIBUTE14 = 32;
    public static final int HEADERATTRIBUTE15 = 33;
    public static final int DYNAMICATTRIBUTEGROUPS = 34;
    public static final int SECURITYVAL = 35;
    public static final int KFF1_ANCHORATTRIBUTE = 36;

    /**
     * Oracle Applications internal source control identifier
     */
   public static final String RCS_ID="$Header: PurchaseOrdersSVORowImpl.java 120.9 2006/07/04 01:59:48 atgops1 noship $";
  /**
   * Oracle Applications internal source control identifier
   */
   public static final boolean RCS_ID_RECORDED =
         VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");
    public static final int PURCHASEORDERLINE = 37;


    /**
     *
     * This is the default constructor (do not remove)
     */
  public PurchaseOrdersSVORowImpl()
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
   * Gets the attribute value for CARRIER_CODE using the alias name CarrierCode
   */
  public String getCarrierCode()
  {
    return (String)getAttributeInternal(CARRIERCODE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for SUPPLIER_SITE_ID using the alias name SupplierSiteId1
   */
  public void setSupplierSiteId1(Number value)
  {
    setAttributeInternal(SUPPLIERSITEID1, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE_CATEGORY using the alias name HeaderAttributeCategory
   */
  public String getHeaderAttributeCategory()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTECATEGORY);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE_CATEGORY using the alias name HeaderAttributeCategory
   */
  public void setHeaderAttributeCategory(String value)
  {
    setAttributeInternal(HEADERATTRIBUTECATEGORY, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE1 using the alias name HeaderAttribute1
   */
  public String getHeaderAttribute1()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE1);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE1 using the alias name HeaderAttribute1
   */
  public void setHeaderAttribute1(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE1, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE2 using the alias name HeaderAttribute2
   */
  public String getHeaderAttribute2()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE2);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE2 using the alias name HeaderAttribute2
   */
  public void setHeaderAttribute2(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE2, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE3 using the alias name HeaderAttribute3
   */
  public String getHeaderAttribute3()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE3);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE3 using the alias name HeaderAttribute3
   */
  public void setHeaderAttribute3(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE3, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE4 using the alias name HeaderAttribute4
   */
  public String getHeaderAttribute4()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE4);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE4 using the alias name HeaderAttribute4
   */
  public void setHeaderAttribute4(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE4, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE5 using the alias name HeaderAttribute5
   */
  public String getHeaderAttribute5()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE5);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE5 using the alias name HeaderAttribute5
   */
  public void setHeaderAttribute5(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE5, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE6 using the alias name HeaderAttribute6
   */
  public String getHeaderAttribute6()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE6);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE6 using the alias name HeaderAttribute6
   */
  public void setHeaderAttribute6(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE6, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE7 using the alias name HeaderAttribute7
   */
  public String getHeaderAttribute7()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE7);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE7 using the alias name HeaderAttribute7
   */
  public void setHeaderAttribute7(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE7, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE8 using the alias name HeaderAttribute8
   */
  public String getHeaderAttribute8()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE8);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE8 using the alias name HeaderAttribute8
   */
  public void setHeaderAttribute8(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE8, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE9 using the alias name HeaderAttribute9
   */
  public String getHeaderAttribute9()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE9);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE9 using the alias name HeaderAttribute9
   */
  public void setHeaderAttribute9(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE9, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE10 using the alias name HeaderAttribute10
   */
  public String getHeaderAttribute10()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE10);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE10 using the alias name HeaderAttribute10
   */
  public void setHeaderAttribute10(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE10, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE11 using the alias name HeaderAttribute11
   */
  public String getHeaderAttribute11()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE11);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE11 using the alias name HeaderAttribute11
   */
  public void setHeaderAttribute11(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE11, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE12 using the alias name HeaderAttribute12
   */
  public String getHeaderAttribute12()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE12);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE12 using the alias name HeaderAttribute12
   */
  public void setHeaderAttribute12(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE12, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE13 using the alias name HeaderAttribute13
   */
  public String getHeaderAttribute13()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE13);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE13 using the alias name HeaderAttribute13
   */
  public void setHeaderAttribute13(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE13, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE14 using the alias name HeaderAttribute14
   */
  public String getHeaderAttribute14()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE14);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE14 using the alias name HeaderAttribute14
   */
  public void setHeaderAttribute14(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE14, value);
  }

  /**
   * 
   * Gets the attribute value for ATTRIBUTE15 using the alias name HeaderAttribute15
   */
  public String getHeaderAttribute15()
  {
    return (String)getAttributeInternal(HEADERATTRIBUTE15);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ATTRIBUTE15 using the alias name HeaderAttribute15
   */
  public void setHeaderAttribute15(String value)
  {
    setAttributeInternal(HEADERATTRIBUTE15, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute DynamicAttributeGroups
   */
  public List getDynamicAttributeGroups()
  {
    return (List)getAttributeInternal(DYNAMICATTRIBUTEGROUPS);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute DynamicAttributeGroups
   */
  public void setDynamicAttributeGroups(List value)
  {
    setAttributeInternal(DYNAMICATTRIBUTEGROUPS, value);
  }

  /**
   * 
   * Gets the attribute value for HEADER_ID using the alias name PoNumber
   */
  public Number getPoNumber()
  {
    return (Number)getAttributeInternal(PONUMBER);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for HEADER_ID using the alias name PoNumber
   */
  public void setPoNumber(Number value)
  {
    setAttributeInternal(PONUMBER, value);
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
   * Sets <code>value</code> as attribute value for CARRIER_CODE using the alias name CarrierCode
   */
  public void setCarrierCode(String value)
  {
    setAttributeInternal(CARRIERCODE, value);
  }

  /**
   * 
   * Gets the attribute value for RATE using the alias name Rate
   */
  public Number getRate()
  {
    return (Number)getAttributeInternal(RATE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for RATE using the alias name Rate
   */
  public void setRate(Number value)
  {
    setAttributeInternal(RATE, value);
  }

  /**
   * 
   * Gets the attribute value for FULL_NAME using the alias name BuyerName
   */
  public String getBuyerName()
  {
    return (String)getAttributeInternal(BUYERNAME);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for FULL_NAME using the alias name BuyerName
   */
  public void setBuyerName(String value)
  {
    setAttributeInternal(BUYERNAME, value);
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
   * Gets the attribute value for NAME using the alias name SupplierName
   */
  public String getSupplierName()
  {
    return (String)getAttributeInternal(SUPPLIERNAME);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for NAME using the alias name SupplierName
   */
  public void setSupplierName(String value)
  {
    setAttributeInternal(SUPPLIERNAME, value);
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
   * Gets the attribute value for SITE_NAME using the alias name SupplierSiteName
   */
  public String getSupplierSiteName()
  {
    return (String)getAttributeInternal(SUPPLIERSITENAME);
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
   * Gets the attribute value for the calculated attribute SupplierAttachments
   */
  public List getSupplierAttachments()
  {
    return (List)getAttributeInternal(SUPPLIERATTACHMENTS);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute SupplierAttachments
   */
  public void setSupplierAttachments(List value)
  {
    setAttributeInternal(SUPPLIERATTACHMENTS, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute POAttachments
   */
  public List getPOAttachments()
  {
    return (List)getAttributeInternal(POATTACHMENTS);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute POAttachments
   */
  public void setPOAttachments(List value)
  {
    setAttributeInternal(POATTACHMENTS, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute SecurityVal
   */
  public Number getSecurityVal()
  {
    return (Number)getAttributeInternal(SECURITYVAL);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute SecurityVal
   */
  public void setSecurityVal(Number value)
  {
    setAttributeInternal(SECURITYVAL, value);
  }

  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case PONUMBER:
            return getPoNumber();
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
        case RATE:
            return getRate();
        case BUYERNAME:
            return getBuyerName();
        case EMPLOYEEID:
            return getEmployeeId();
        case SUPPLIERNAME:
            return getSupplierName();
        case SUPPLIERID1:
            return getSupplierId1();
        case SUPPLIERSITENAME:
            return getSupplierSiteName();
        case SUPPLIERSITEID1:
            return getSupplierSiteId1();
        case SUPPLIERATTACHMENTS:
            return getSupplierAttachments();
        case POATTACHMENTS:
            return getPOAttachments();
        case HEADERATTRIBUTECATEGORY:
            return getHeaderAttributeCategory();
        case HEADERATTRIBUTE1:
            return getHeaderAttribute1();
        case HEADERATTRIBUTE2:
            return getHeaderAttribute2();
        case HEADERATTRIBUTE3:
            return getHeaderAttribute3();
        case HEADERATTRIBUTE4:
            return getHeaderAttribute4();
        case HEADERATTRIBUTE5:
            return getHeaderAttribute5();
        case HEADERATTRIBUTE6:
            return getHeaderAttribute6();
        case HEADERATTRIBUTE7:
            return getHeaderAttribute7();
        case HEADERATTRIBUTE8:
            return getHeaderAttribute8();
        case HEADERATTRIBUTE9:
            return getHeaderAttribute9();
        case HEADERATTRIBUTE10:
            return getHeaderAttribute10();
        case HEADERATTRIBUTE11:
            return getHeaderAttribute11();
        case HEADERATTRIBUTE12:
            return getHeaderAttribute12();
        case HEADERATTRIBUTE13:
            return getHeaderAttribute13();
        case HEADERATTRIBUTE14:
            return getHeaderAttribute14();
        case HEADERATTRIBUTE15:
            return getHeaderAttribute15();
        case DYNAMICATTRIBUTEGROUPS:
            return getDynamicAttributeGroups();
        case SECURITYVAL:
            return getSecurityVal();
        case KFF1_ANCHORATTRIBUTE:
            return getKFF1_AnchorAttribute();
        case PURCHASEORDERLINE:
            return getPurchaseOrderLine();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case PONUMBER:
            setPoNumber((Number)value);
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
        case RATE:
            setRate((Number)value);
            return;
        case BUYERNAME:
            setBuyerName((String)value);
            return;
        case EMPLOYEEID:
            setEmployeeId((Number)value);
            return;
        case SUPPLIERNAME:
            setSupplierName((String)value);
            return;
        case SUPPLIERID1:
            setSupplierId1((Number)value);
            return;
        case SUPPLIERSITEID1:
            setSupplierSiteId1((Number)value);
            return;
        case SUPPLIERATTACHMENTS:
            setSupplierAttachments((List)value);
            return;
        case POATTACHMENTS:
            setPOAttachments((List)value);
            return;
        case HEADERATTRIBUTECATEGORY:
            setHeaderAttributeCategory((String)value);
            return;
        case HEADERATTRIBUTE1:
            setHeaderAttribute1((String)value);
            return;
        case HEADERATTRIBUTE2:
            setHeaderAttribute2((String)value);
            return;
        case HEADERATTRIBUTE3:
            setHeaderAttribute3((String)value);
            return;
        case HEADERATTRIBUTE4:
            setHeaderAttribute4((String)value);
            return;
        case HEADERATTRIBUTE5:
            setHeaderAttribute5((String)value);
            return;
        case HEADERATTRIBUTE6:
            setHeaderAttribute6((String)value);
            return;
        case HEADERATTRIBUTE7:
            setHeaderAttribute7((String)value);
            return;
        case HEADERATTRIBUTE8:
            setHeaderAttribute8((String)value);
            return;
        case HEADERATTRIBUTE9:
            setHeaderAttribute9((String)value);
            return;
        case HEADERATTRIBUTE10:
            setHeaderAttribute10((String)value);
            return;
        case HEADERATTRIBUTE11:
            setHeaderAttribute11((String)value);
            return;
        case HEADERATTRIBUTE12:
            setHeaderAttribute12((String)value);
            return;
        case HEADERATTRIBUTE13:
            setHeaderAttribute13((String)value);
            return;
        case HEADERATTRIBUTE14:
            setHeaderAttribute14((String)value);
            return;
        case HEADERATTRIBUTE15:
            setHeaderAttribute15((String)value);
            return;
        case DYNAMICATTRIBUTEGROUPS:
            setDynamicAttributeGroups((List)value);
            return;
        case SECURITYVAL:
            setSecurityVal((Number)value);
            return;
        case KFF1_ANCHORATTRIBUTE:
            setKFF1_AnchorAttribute((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }

  /**
   * 
   * Gets the attribute value for $none$ using the alias name KFF1_AnchorAttribute
   */
  public String getKFF1_AnchorAttribute()
  {
    return (String)getAttributeInternal(KFF1_ANCHORATTRIBUTE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for $none$ using the alias name KFF1_AnchorAttribute
   */
  public void setKFF1_AnchorAttribute(String value)
  {
    setAttributeInternal(KFF1_ANCHORATTRIBUTE, value);
  }

  public void approve()
  {
    getPurchaseOrderHeaderEO().approve();
  }

  /**
   * 
   * Gets the associated <code>RowIterator</code> using master-detail link PurchaseOrderLine
   */
  public oracle.jbo.RowIterator getPurchaseOrderLine()
  {
    return (oracle.jbo.RowIterator)getAttributeInternal(PURCHASEORDERLINE);
  }
}
