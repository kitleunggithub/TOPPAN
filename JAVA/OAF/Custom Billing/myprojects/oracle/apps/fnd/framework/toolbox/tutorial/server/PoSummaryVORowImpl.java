/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;
import oracle.jbo.domain.Date;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OARowValException;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.server.OAViewRowImpl;

import oracle.apps.fnd.framework.toolbox.schema.server.EmployeeEOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderHeaderEOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.SupplierEOImpl;

public class PoSummaryVORowImpl extends OAViewRowImpl {

    public static final int HEADERID = 0;
    public static final int DESCRIPTION = 1;
    public static final int STATUSCODE = 2;
    public static final int SUPPLIERID = 3;
    public static final int CURRENCYCODE = 4;
    public static final int CREATIONDATE = 5;
    public static final int SUPPLIERNAME = 6;
    public static final int SUPPLIERID1 = 7;
    public static final int BUYERNAME = 8;
    public static final int EMPLOYEEID = 9;
    public static final int BUYERID = 10;
    public static final int SELECTFLAG = 11;
    public static final int BUYEREMAIL = 12;
    public static final int ORDERTOTAL = 13;
    public static final int STATUSIMAGE = 14;
    public static final int STATUSDISPLAY = 15;
    public static final int DELETEIMAGE = 16;
    public static final int UPDATEIMAGE = 17;
    public static final String RCS_ID="$Header: PoSummaryVORowImpl.java 120.2 2006/07/04 01:01:16 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");
    public static final int APPROVEDISABLED = 18;


    /**
     * Approves the purchase order associated with this row.
     */
  public void approve()
  {
    // Whenver you write custom methods on the VO Row that call custom methods
    // on the Entity Object you need to do a manual mapping as shown below
    // to correctly handle the entity exceptions.
    
    try
    {
      getPurchaseOrderHeaderEO().approve();
    }
    catch(OARowValException e)
    {
      OAViewObject[] vos = { (OAViewObject)getViewObject() };
      e.doEntityToVOMapping(getApplicationModule(), vos);
      throw e;
    }
  }

//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here ...
//  ---------------------------------------------------------------

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public PoSummaryVORowImpl()
  {
  }

  /**
   * 
   * Gets PurchaseOrderHeaderEO entity object.
   */
  public PurchaseOrderHeaderEOImpl getPurchaseOrderHeaderEO()
  {
    return (PurchaseOrderHeaderEOImpl)getEntity(0);
  }

  /**
   * 
   * Gets SupplierEO entity object.
   */
  public SupplierEOImpl getSupplierEO()
  {
    return (SupplierEOImpl)getEntity(1);
  }

  /**
   * 
   * Gets EmployeeEO entity object.
   */
  public EmployeeEOImpl getEmployeeEO()
  {
    return (EmployeeEOImpl)getEntity(2);
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
   * Gets the attribute value for CREATION_DATE using the alias name CreationDate
   */
  public Date getCreationDate()
  {
    return (Date)getAttributeInternal(CREATIONDATE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for CREATION_DATE using the alias name CreationDate
   */
  public void setCreationDate(Date value)
  {
    setAttributeInternal(CREATIONDATE, value);
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
   * Gets the attribute value for SUPPLIER_ID using the alias name SupplierId1
   */
  public Number getSupplierId1()
  {
    return (Number)getAttributeInternal(SUPPLIERID1);
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
   * Gets the attribute value for EMPLOYEE_ID using the alias name EmployeeId
   */
  public Number getEmployeeId()
  {
    return (Number)getAttributeInternal(EMPLOYEEID);
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
   * Gets the attribute value for the calculated attribute SelectFlag
   */
  public String getSelectFlag()
  {
    return (String)getAttributeInternal(SELECTFLAG);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute SelectFlag
   */
  public void setSelectFlag(String value)
  {
    setAttributeInternal(SELECTFLAG, value);
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
   * Gets the attribute value for the calculated attribute OrderTotal
   */
  public Number getOrderTotal()
  {
    return (Number)getAttributeInternal(ORDERTOTAL);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute OrderTotal
   */
  public void setOrderTotal(Number value)
  {
    setAttributeInternal(ORDERTOTAL, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute StatusImage
   */
  public String getStatusImage()
  {
    return (String)getAttributeInternal(STATUSIMAGE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute StatusImage
   */
  public void setStatusImage(String value)
  {
    setAttributeInternal(STATUSIMAGE, value);
  }



  /**
   * 
   * Gets the attribute value for the calculated attribute DeleteImage
   */
  public String getDeleteImage()
  {
    return (String)getAttributeInternal(DELETEIMAGE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute DeleteImage
   */
  public void setDeleteImage(String value)
  {
    setAttributeInternal(DELETEIMAGE, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute UpdateImage
   */
  public String getUpdateImage()
  {
    return (String)getAttributeInternal(UPDATEIMAGE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute UpdateImage
   */
  public void setUpdateImage(String value)
  {
    setAttributeInternal(UPDATEIMAGE, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute ApproveDisabled
   */
  public String getApproveDisabled()
  {
    return (String)getAttributeInternal(APPROVEDISABLED);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute ApproveDisabled
   */
  public void setApproveDisabled(String value)
  {
    setAttributeInternal(APPROVEDISABLED, value);
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
        case CURRENCYCODE:
            return getCurrencyCode();
        case CREATIONDATE:
            return getCreationDate();
        case SUPPLIERNAME:
            return getSupplierName();
        case SUPPLIERID1:
            return getSupplierId1();
        case BUYERNAME:
            return getBuyerName();
        case EMPLOYEEID:
            return getEmployeeId();
        case BUYERID:
            return getBuyerId();
        case SELECTFLAG:
            return getSelectFlag();
        case BUYEREMAIL:
            return getBuyerEmail();
        case ORDERTOTAL:
            return getOrderTotal();
        case STATUSIMAGE:
            return getStatusImage();
        case STATUSDISPLAY:
            return getStatusDisplay();
        case DELETEIMAGE:
            return getDeleteImage();
        case UPDATEIMAGE:
            return getUpdateImage();
        case APPROVEDISABLED:
            return getApproveDisabled();
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
        case CURRENCYCODE:
            setCurrencyCode((String)value);
            return;
        case CREATIONDATE:
            setCreationDate((Date)value);
            return;
        case BUYERID:
            setBuyerId((Number)value);
            return;
        case SELECTFLAG:
            setSelectFlag((String)value);
            return;
        case ORDERTOTAL:
            setOrderTotal((Number)value);
            return;
        case STATUSIMAGE:
            setStatusImage((String)value);
            return;
        case DELETEIMAGE:
            setDeleteImage((String)value);
            return;
        case UPDATEIMAGE:
            setUpdateImage((String)value);
            return;
        case APPROVEDISABLED:
            setApproveDisabled((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }





  /**
   * 
   * Gets the attribute value for the calculated attribute StatusDisplay
   */
  public String getStatusDisplay()
  {
    return (String)getAttributeInternal(STATUSDISPLAY);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute StatusDisplay
   */
  public void setStatusDisplay(String value)
  {
    setAttributeInternal(STATUSDISPLAY, value);
  }
}
