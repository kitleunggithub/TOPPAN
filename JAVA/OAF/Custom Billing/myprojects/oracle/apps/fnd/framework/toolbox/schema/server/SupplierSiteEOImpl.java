/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |       16-APR-02  L Lyons  Created based on the Requisition prototype      |
 |                           plus inputs from the framework dev team.        |
 |       23-JUN-06  RNIRMAL  Bug 5254600 - Added new FND messages            |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAAttrValException;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OARowValException;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.server.OADBTransactionImpl;
import oracle.apps.fnd.framework.server.OAEntityDefImpl;
import oracle.apps.fnd.framework.server.OAEntityImpl;

import oracle.jbo.AttributeList;
import oracle.jbo.Key;
import oracle.jbo.RowIterator;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.server.EntityDefImpl;

/*
 * NOTE:  this class has not been implemented for this initial lesson 
 * publication.  Any code shown below is incomplete and should not be used
 * as a reference.
 *
 * EO Table:  FWK_TBX_SUPPLIER_SITES
 * EO Parent: FWK_TBX_SUPPLIERS (SupplierEOImpl)
 */
public class SupplierSiteEOImpl extends OAEntityImpl {

  // Mandatory for Applications source control
    public static final int SUPPLIERID = 0;
    public static final int SUPPLIERSITEID = 1;
    public static final int SITENAME = 2;
    public static final int PAYMENTTERMSCODE = 3;
    public static final int CARRIERCODE = 4;
    public static final int PURCHASINGSITEFLAG = 5;
    public static final int ADDRESSID = 6;
    public static final int STARTDATE = 7;
    public static final int ENDDATE = 8;
    public static final int LASTUPDATEDATE = 9;
    public static final int LASTUPDATEDBY = 10;
    public static final int CREATIONDATE = 11;
    public static final int CREATEDBY = 12;
    public static final int LASTUPDATELOGIN = 13;
    public static final int ATTRIBUTECATEGORY = 14;
    public static final int ATTRIBUTE1 = 15;
    public static final int ATTRIBUTE2 = 16;
    public static final int ATTRIBUTE3 = 17;
    public static final int ATTRIBUTE4 = 18;
    public static final int ATTRIBUTE5 = 19;
    public static final int ATTRIBUTE6 = 20;
    public static final int ATTRIBUTE7 = 21;
    public static final int ATTRIBUTE8 = 22;
    public static final int ATTRIBUTE9 = 23;
    public static final int ATTRIBUTE10 = 24;
    public static final int ATTRIBUTE11 = 25;
    public static final int ATTRIBUTE12 = 26;
    public static final int ATTRIBUTE13 = 27;
    public static final int ATTRIBUTE14 = 28;
    public static final int ATTRIBUTE15 = 29;
    public static final int PURCHASEORDERHEADEREO = 30;
    public static final String RCS_ID="$Header: SupplierSiteEOImpl.java 120.4 2006/07/03 23:06:36 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");
    public static final int SUPPLIEREO = 31;


    ////////////////////////////////////////////////////////////////////////////////
//
// NOTE:  this class has not been implemented for this initial lesson 
// publication.  Any code shown below is incomplete and should not be used
// as a reference.
//
////////////////////////////////////////////////////////////////////////////////

/*
 * DEBUG -- add comments about initialization
 */
  public void create(AttributeList attributeList)
  {
    // The supplier id is set automatically in super.create()
    // because of the composition association.
    
    super.create(attributeList);

    OADBTransactionImpl transaction = (OADBTransactionImpl)getOADBTransaction();
    
    try
    {
      // DEFAULT: supplier site
      Number supplierSiteId = transaction.getSequenceValue("FWK_TBX_SUPPLIER_SITES_S");
      setSupplierSiteId(supplierSiteId);
      
      // DEFAULT: start date should be set to sysdate
      setStartDate(transaction.getCurrentDBDate());

      // DEFAULT:  make this a purchasing site
      setPurchasingSiteFlag("Y");

    }
    catch (Exception e)
    {
      throw new OARowValException(OARowValException.TYP_ENTITY_OBJECT,
                                  getEntityDef().getFullName(),
                                  getPrimaryKey(),
                                  "FND", // Message product short name
                                  "FWK_TBX_T_SUP_SITE_ID_INVALID");  // Message name
    }
  } // end create()

  /*
   * Supplier sites can never be deleted.
   */
  public void remove()
  {
    // super.remove();
    throw new OARowValException(OARowValException.TYP_ENTITY_OBJECT,
                                getEntityDef().getFullName(),
                                getPrimaryKey(),
                                "AK", // Message product short name
                                "FWK_TBX_T_SUPSITE_NO_DELETE");   // Message name   
  } // end remove()

  /*
   *
   * DEBUG -- add comments about x-entity validation.
   * See open questions on row/attribute validation in SupplierEOImpl
   */
  protected void validateEntity()
  {
    try
    {
      validateStartDate(getStartDate());
      validateEndDate(getEndDate());
    }
    catch(Exception e)
    {
      throw new OARowValException(OARowValException.TYP_ENTITY_OBJECT,
                                  getEntityDef().getFullName(),
                                  getPrimaryKey(),
                                  "FND", // Message product short name
                                  "FWK_TBX_T_DATE_INVALID");  // Message name    
    }
  } // end validateEntity()

 /*
  * 
  * Sets <code>value</code> as the attribute value for SupplierSiteId
  */
  public void setSupplierSiteId(Number value)
  {
    // Cannot be null.
    // Must be a unique value.
    // Cannot be updated on committed rows.

    if (this.getEntityState() != STATUS_NEW)
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "SupplierSiteId", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_SUP_SITE_ID_UPDATE"); // Message name
    }

    if (value == null)
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "SupplierSiteId", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_SUP_SITE_ID_NULL"); // Message name
    }

    // findByPrimaryKey() is guaranteed to check all supplier sites.  First it checks
    // the entity cache, then it checks the database.

    OADBTransactionImpl transaction = (OADBTransactionImpl)getOADBTransaction();
    Object[] supplierSiteKey = {value};
    EntityDefImpl supplierSiteDefinition = SupplierSiteEOImpl.getDefinitionObject();
    SupplierSiteEOImpl supplierSite = (SupplierSiteEOImpl)supplierSiteDefinition.findByPrimaryKey(transaction, new Key(supplierSiteKey));

    if (supplierSite != null)
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "SupplierSiteId", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_SUP_SITE_ID_UNIQUE"); // Message name 
    }  
    
    setAttributeInternal(SUPPLIERSITEID, value);
    
  } // end setSupplierSiteId()

  /*
   * 
   * Sets <code>value</code> as the attribute value for SiteName
   */
  public void setSiteName(String value)
  {
    // Cannot be null.
    // Must be a unqiue name for this supplier (ignore capitlization)

    if ((value == null) || ("".equals(value.trim())))
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "SiteName", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_SITE_NAME_NULL"); // Message name

    }

    // To verify uniqueness, start by checking the entity cache.

    com.sun.java.util.collections.Iterator siteIterator = 
          getEntityDef().getAllEntityInstancesIterator(getDBTransaction());
          
    // oracle.jbo.server.java.util.Iterator supplierIterator = 
    //     getEntityDef().getAllEntityInstances(getDBTransaction());
    
    Number supplierId = getSupplierId();
    Number supplierSiteId = getSupplierSiteId();
    
    while ( siteIterator.hasNext() )
    {
      SupplierSiteEOImpl cachedSite = (SupplierSiteEOImpl)siteIterator.next();

      // Only check rows in valid state
        
      if ( cachedSite.getEntityState() != STATUS_DELETED && 
           cachedSite.getEntityState() != STATUS_DEAD )
      {
        String cachedName = cachedSite.getSiteName();
        Number cachedSupplierId = cachedSite.getSupplierId();
        Number cachedSiteId = cachedSite.getSupplierSiteId();
          
        if ((cachedName != null) && 
            (value.equalsIgnoreCase(cachedName)) && 
            (cachedSupplierId.compareTo(supplierId) == 0) &&
            (cachedSiteId.compareTo(supplierSiteId) == 0))
          {
            throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                        getEntityDef().getFullName(), // EO name
                                        getPrimaryKey(), // EO PK
                                        "SiteName", // Attribute Name
                                        value, // Attribute value
                                        "FND", // Message product short name
                                        "FWK_TBX_T_SITE_NAME_UNIQUE"); // Message name      
          }
        }
      }  
    
    // Didn't find a duplicate in the entity cache so now we check the database.
/*
** DEBUG add based on decision on how we want to present this to developers.
*/

    OADBTransactionImpl transaction = (OADBTransactionImpl)getOADBTransaction();
    OAApplicationModuleImpl vam;

/*
    try
    {
      vam = (OAApplicationModuleImpl)transaction.findApplicationModule("SupplierSiteVAM");
    }
    catch (Exception e)
    {
      vam = (OAApplicationModuleImpl)transaction.createApplicationModule("SupplierSiteVAM");
    }

    OAViewObjectImpl valNameVo = (OAViewObjectImpl)vam.findViewObject("ValidateSupplierSiteName");
//    valNameVo.initQuery(value);

    if (valNameVo.hasNext())
    {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "SiteName", // Attribute Name
                                     value, // Attribute value
                                     "AK", // Message product short name
                                     "DEBUG -- add message"); // Message name
    }
*/        
    setAttributeInternal(SITENAME, value);
    
  } // end setSiteName()

  /*
   * 
   * Sets <code>value</code> as the attribute value for PurchasingSiteFlag
   */
  public void setPurchasingSiteFlag(String value)
  {
    // Cannot be null.
    // Valid values are "Y" and "N"
    
    if ((value == null) || ("".equals(value.trim())))
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "PurchasingSiteFlag", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_PUR_SITE_FLAG_NULL"); // Message name
    }
    else if ((!("Y".equals(value))) && (!("N".equals(value))))
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "PurchasingSiteFlag", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_PUR_SITE_FLAG_VALUES"); // Message name
    }
    
    setAttributeInternal(PURCHASINGSITEFLAG, value);
    
  } // end setPurchasingSiteFlag()

  /*
   * 
   * Sets <code>value</code> as the attribute value for PaymentTermsCode
   */
  public void setPaymentTermsCode(String value)
  {
    // Optional.  Simple lookup code validation.
    // Lookup Type:  FWK_TBX_PAYMENT_TERMS
/*
** DEBUG add validation once implementation strategy is decided.
*/
    setAttributeInternal(PAYMENTTERMSCODE, value);
    
  } // end setPaymentTermsCode()

  /*
   * 
   * Sets <code>value</code> as the attribute value for CarrierCode
   */
  public void setCarrierCode(String value)
  {
    // Optional.  Simple lookup code validation.
    // Lookup Type:  FWK_TBX_CARRIER
/*
** DEBUG add validation once implementation strategy is decided.
*/    
    setAttributeInternal(CARRIERCODE, value);
    
  } // end setCarrierCode()

  /*
   * 
   * Sets <code>value</code> as the attribute value for AddressId
   */
  public void setAddressId(Number value)
  {
    // Required; cannot be null.
    // Simple reference entity validation

    if (value == null)
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "AddressId", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_ADDRESS_ID_NULL"); // Message name
    }

/*
** DEBUG add validation once implementation strategy is decided.
*/    
    
    setAttributeInternal(ADDRESSID, value);
    
  } // end setAddressId()


 /*
   * 
   * Sets <code>value</code> as the attribute value for StartDate
   */
  public void setStartDate(Date value)
  {
    // Required; cannot be null
    // Must be >= trunc(sysdate)
    
    validateStartDate(value);
    setAttributeInternal(STARTDATE, value);
    
  } // end setStartDate()

  /*
   * 
   * Sets <code>value</code> as the attribute value for EndDate
   */
  public void setEndDate(Date value)
  {
    // Optional, can be null.
    // If specified, must be >= trunc(sysdate)
    // Must be >= start date.
    
    validateEndDate(value);
    setAttributeInternal(ENDDATE, value);
    
  } // end setEndDate()

 /*
 * DEBUG -- add comment need this to avoid writing the same validation logic
 * on the field and in the entity validation.  Also, both the supplier and the
 * supplier site require the same start/end validation, how do you recommend
 * implementing this kind of shared utility?
 */  
  private void validateStartDate(Date value)
  {
    // Start date cannot be null.
    // Start date must be >= trunc(sysdate)

    OADBTransactionImpl transaction = (OADBTransactionImpl)getOADBTransaction();

    // You cannot compare oracle.jbo.domain.Date objects directly. Instead,
    // convert the value to a long as shown.
    
    long sysdate = transaction.getCurrentDBDate().timestampValue().getTime();
    long startDate = value.timestampValue().getTime();

    if (value == null) 
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "StartDate", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_START_DATE_NULL"); // Message name
    }
    else if (startDate < sysdate)
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "StartDate", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_START_DATE_INVALID"); // Message name
    }
  } // end validateStartDate()

 /*
 * DEBUG -- add comment need this to avoid writing the same validation logic
 * on the field and in the entity validation.  Also, both the supplier and the
 * supplier site require the same start/end validation, how do you recommend
 * implementing this kind of shared utility?
 */  
  private void validateEndDate(Date value)
  {
    // If start date is specified, must be >= trunc(start date)
    // Must be >= trunc(sysdate)
    // OK to be null

    if (value != null)
    {
      OADBTransactionImpl transaction = (OADBTransactionImpl)getOADBTransaction();

      // You cannot compare oracle.jbo.domain.Date objects directly. Instead,
      // convert the value to a long as shown.

      long sysdate = transaction.getCurrentDBDate().timestampValue().getTime();
      long endDate = value.timestampValue().getTime();
      
      if (endDate < sysdate)
      {    
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "EndDate", // Attribute Name
                                     value, // Attribute value
                                     "FND", // Message product short name
                                     "FWK_TBX_T_END_DATE_INVALID"); // Message name
      }
      else if (getStartDate() != null)
      {
        if (endDate < getStartDate().timestampValue().getTime())
        {
          throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                       getEntityDef().getFullName(), // EO name
                                       getPrimaryKey(), // EO PK
                                       "EndDate", // Attribute Name
                                       value, // Attribute value
                                       "FND", // Message product short name
                                       "FWK_TBX_T_END_DATE_START_DATE"); // Message name
        }
      }
    }
  } // end validateEndDate()


//  ---------------------------------------------------------------
//  ---    Unmodified generated code from here...
//  ---------------------------------------------------------------

  /*
   * 
   * This is the default constructor (do not remove)
   */















  private static oracle.apps.fnd.framework.server.OAEntityDefImpl mDefinitionObject;

  public SupplierSiteEOImpl()
  {
  }


    /*
   *
   * Retrieves the definition object for this instance class.
   */

  /*
   *
   * Gets the attribute value for SupplierId, using the alias name SupplierId
   */

    /**Retrieves the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        if (mDefinitionObject == null) {
            mDefinitionObject =
                    (OAEntityDefImpl)EntityDefImpl.findDefObject("oracle.apps.fnd.framework.toolbox.schema.server.SupplierSiteEO");
        }
        return mDefinitionObject;
    }

    public Number getSupplierId()
  {
    return (Number)getAttributeInternal(SUPPLIERID);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for SupplierId
   */
  public void setSupplierId(Number value)
  {
    setAttributeInternal(SUPPLIERID, value);
  }

  /*
   * 
   * Gets the attribute value for SupplierSiteId, using the alias name SupplierSiteId
   */
  public Number getSupplierSiteId()
  {
    return (Number)getAttributeInternal(SUPPLIERSITEID);
  }

  /*
   * 
   * Gets the attribute value for SiteName, using the alias name SiteName
   */
  public String getSiteName()
  {
    return (String)getAttributeInternal(SITENAME);
  }

  /*
   * 
   * Gets the attribute value for PaymentTermsCode, using the alias name PaymentTermsCode
   */
  public String getPaymentTermsCode()
  {
    return (String)getAttributeInternal(PAYMENTTERMSCODE);
  }


  /*
   * 
   * Gets the attribute value for CarrierCode, using the alias name CarrierCode
   */
  public String getCarrierCode()
  {
    return (String)getAttributeInternal(CARRIERCODE);
  }


  /*
   * 
   * Gets the attribute value for PurchasingSiteFlag, using the alias name PurchasingSiteFlag
   */
  public String getPurchasingSiteFlag()
  {
    return (String)getAttributeInternal(PURCHASINGSITEFLAG);
  }

  /*
   * 
   * Gets the attribute value for AddressId, using the alias name AddressId
   */
  public Number getAddressId()
  {
    return (Number)getAttributeInternal(ADDRESSID);
  }


  /*
   * 
   * Gets the attribute value for StartDate, using the alias name StartDate
   */
  public Date getStartDate()
  {
    return (Date)getAttributeInternal(STARTDATE);
  }


  /*
   * 
   * Gets the attribute value for EndDate, using the alias name EndDate
   */
  public Date getEndDate()
  {
    return (Date)getAttributeInternal(ENDDATE);
  }


  /*
   * 
   * Gets the attribute value for LastUpdateDate, using the alias name LastUpdateDate
   */
  public Date getLastUpdateDate()
  {
    return (Date)getAttributeInternal(LASTUPDATEDATE);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for LastUpdateDate
   */
  public void setLastUpdateDate(Date value)
  {
    setAttributeInternal(LASTUPDATEDATE, value);
  }

  /*
   * 
   * Gets the attribute value for LastUpdatedBy, using the alias name LastUpdatedBy
   */
  public Number getLastUpdatedBy()
  {
    return (Number)getAttributeInternal(LASTUPDATEDBY);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for LastUpdatedBy
   */
  public void setLastUpdatedBy(Number value)
  {
    setAttributeInternal(LASTUPDATEDBY, value);
  }

  /*
   * 
   * Gets the attribute value for CreationDate, using the alias name CreationDate
   */
  public Date getCreationDate()
  {
    return (Date)getAttributeInternal(CREATIONDATE);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for CreationDate
   */
  public void setCreationDate(Date value)
  {
    setAttributeInternal(CREATIONDATE, value);
  }

  /*
   * 
   * Gets the attribute value for CreatedBy, using the alias name CreatedBy
   */
  public Number getCreatedBy()
  {
    return (Number)getAttributeInternal(CREATEDBY);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for CreatedBy
   */
  public void setCreatedBy(Number value)
  {
    setAttributeInternal(CREATEDBY, value);
  }

  /*
   * 
   * Gets the attribute value for LastUpdateLogin, using the alias name LastUpdateLogin
   */
  public Number getLastUpdateLogin()
  {
    return (Number)getAttributeInternal(LASTUPDATELOGIN);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for LastUpdateLogin
   */
  public void setLastUpdateLogin(Number value)
  {
    setAttributeInternal(LASTUPDATELOGIN, value);
  }

  /*
   * 
   * Gets the attribute value for AttributeCategory, using the alias name AttributeCategory
   */
  public String getAttributeCategory()
  {
    return (String)getAttributeInternal(ATTRIBUTECATEGORY);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for AttributeCategory
   */
  public void setAttributeCategory(String value)
  {
    setAttributeInternal(ATTRIBUTECATEGORY, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute1, using the alias name Attribute1
   */
  public String getAttribute1()
  {
    return (String)getAttributeInternal(ATTRIBUTE1);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute1
   */
  public void setAttribute1(String value)
  {
    setAttributeInternal(ATTRIBUTE1, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute2, using the alias name Attribute2
   */
  public String getAttribute2()
  {
    return (String)getAttributeInternal(ATTRIBUTE2);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute2
   */
  public void setAttribute2(String value)
  {
    setAttributeInternal(ATTRIBUTE2, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute3, using the alias name Attribute3
   */
  public String getAttribute3()
  {
    return (String)getAttributeInternal(ATTRIBUTE3);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute3
   */
  public void setAttribute3(String value)
  {
    setAttributeInternal(ATTRIBUTE3, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute4, using the alias name Attribute4
   */
  public String getAttribute4()
  {
    return (String)getAttributeInternal(ATTRIBUTE4);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute4
   */
  public void setAttribute4(String value)
  {
    setAttributeInternal(ATTRIBUTE4, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute5, using the alias name Attribute5
   */
  public String getAttribute5()
  {
    return (String)getAttributeInternal(ATTRIBUTE5);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute5
   */
  public void setAttribute5(String value)
  {
    setAttributeInternal(ATTRIBUTE5, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute6, using the alias name Attribute6
   */
  public String getAttribute6()
  {
    return (String)getAttributeInternal(ATTRIBUTE6);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute6
   */
  public void setAttribute6(String value)
  {
    setAttributeInternal(ATTRIBUTE6, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute7, using the alias name Attribute7
   */
  public String getAttribute7()
  {
    return (String)getAttributeInternal(ATTRIBUTE7);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute7
   */
  public void setAttribute7(String value)
  {
    setAttributeInternal(ATTRIBUTE7, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute8, using the alias name Attribute8
   */
  public String getAttribute8()
  {
    return (String)getAttributeInternal(ATTRIBUTE8);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute8
   */
  public void setAttribute8(String value)
  {
    setAttributeInternal(ATTRIBUTE8, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute9, using the alias name Attribute9
   */
  public String getAttribute9()
  {
    return (String)getAttributeInternal(ATTRIBUTE9);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute9
   */
  public void setAttribute9(String value)
  {
    setAttributeInternal(ATTRIBUTE9, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute10, using the alias name Attribute10
   */
  public String getAttribute10()
  {
    return (String)getAttributeInternal(ATTRIBUTE10);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute10
   */
  public void setAttribute10(String value)
  {
    setAttributeInternal(ATTRIBUTE10, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute11, using the alias name Attribute11
   */
  public String getAttribute11()
  {
    return (String)getAttributeInternal(ATTRIBUTE11);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute11
   */
  public void setAttribute11(String value)
  {
    setAttributeInternal(ATTRIBUTE11, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute12, using the alias name Attribute12
   */
  public String getAttribute12()
  {
    return (String)getAttributeInternal(ATTRIBUTE12);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute12
   */
  public void setAttribute12(String value)
  {
    setAttributeInternal(ATTRIBUTE12, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute13, using the alias name Attribute13
   */
  public String getAttribute13()
  {
    return (String)getAttributeInternal(ATTRIBUTE13);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute13
   */
  public void setAttribute13(String value)
  {
    setAttributeInternal(ATTRIBUTE13, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute14, using the alias name Attribute14
   */
  public String getAttribute14()
  {
    return (String)getAttributeInternal(ATTRIBUTE14);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute14
   */
  public void setAttribute14(String value)
  {
    setAttributeInternal(ATTRIBUTE14, value);
  }

  /*
   * 
   * Gets the attribute value for Attribute15, using the alias name Attribute15
   */
  public String getAttribute15()
  {
    return (String)getAttributeInternal(ATTRIBUTE15);
  }

  /*
   * 
   * Sets <code>value</code> as the attribute value for Attribute15
   */
  public void setAttribute15(String value)
  {
    setAttributeInternal(ATTRIBUTE15, value);
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
        case PAYMENTTERMSCODE:
            return getPaymentTermsCode();
        case CARRIERCODE:
            return getCarrierCode();
        case PURCHASINGSITEFLAG:
            return getPurchasingSiteFlag();
        case ADDRESSID:
            return getAddressId();
        case STARTDATE:
            return getStartDate();
        case ENDDATE:
            return getEndDate();
        case LASTUPDATEDATE:
            return getLastUpdateDate();
        case LASTUPDATEDBY:
            return getLastUpdatedBy();
        case CREATIONDATE:
            return getCreationDate();
        case CREATEDBY:
            return getCreatedBy();
        case LASTUPDATELOGIN:
            return getLastUpdateLogin();
        case ATTRIBUTECATEGORY:
            return getAttributeCategory();
        case ATTRIBUTE1:
            return getAttribute1();
        case ATTRIBUTE2:
            return getAttribute2();
        case ATTRIBUTE3:
            return getAttribute3();
        case ATTRIBUTE4:
            return getAttribute4();
        case ATTRIBUTE5:
            return getAttribute5();
        case ATTRIBUTE6:
            return getAttribute6();
        case ATTRIBUTE7:
            return getAttribute7();
        case ATTRIBUTE8:
            return getAttribute8();
        case ATTRIBUTE9:
            return getAttribute9();
        case ATTRIBUTE10:
            return getAttribute10();
        case ATTRIBUTE11:
            return getAttribute11();
        case ATTRIBUTE12:
            return getAttribute12();
        case ATTRIBUTE13:
            return getAttribute13();
        case ATTRIBUTE14:
            return getAttribute14();
        case ATTRIBUTE15:
            return getAttribute15();
        case PURCHASEORDERHEADEREO:
            return getPurchaseOrderHeaderEO();
        case SUPPLIEREO:
            return getSupplierEO();
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
        case PAYMENTTERMSCODE:
            setPaymentTermsCode((String)value);
            return;
        case CARRIERCODE:
            setCarrierCode((String)value);
            return;
        case PURCHASINGSITEFLAG:
            setPurchasingSiteFlag((String)value);
            return;
        case ADDRESSID:
            setAddressId((Number)value);
            return;
        case STARTDATE:
            setStartDate((Date)value);
            return;
        case ENDDATE:
            setEndDate((Date)value);
            return;
        case LASTUPDATEDATE:
            setLastUpdateDate((Date)value);
            return;
        case LASTUPDATEDBY:
            setLastUpdatedBy((Number)value);
            return;
        case CREATIONDATE:
            setCreationDate((Date)value);
            return;
        case CREATEDBY:
            setCreatedBy((Number)value);
            return;
        case LASTUPDATELOGIN:
            setLastUpdateLogin((Number)value);
            return;
        case ATTRIBUTECATEGORY:
            setAttributeCategory((String)value);
            return;
        case ATTRIBUTE1:
            setAttribute1((String)value);
            return;
        case ATTRIBUTE2:
            setAttribute2((String)value);
            return;
        case ATTRIBUTE3:
            setAttribute3((String)value);
            return;
        case ATTRIBUTE4:
            setAttribute4((String)value);
            return;
        case ATTRIBUTE5:
            setAttribute5((String)value);
            return;
        case ATTRIBUTE6:
            setAttribute6((String)value);
            return;
        case ATTRIBUTE7:
            setAttribute7((String)value);
            return;
        case ATTRIBUTE8:
            setAttribute8((String)value);
            return;
        case ATTRIBUTE9:
            setAttribute9((String)value);
            return;
        case ATTRIBUTE10:
            setAttribute10((String)value);
            return;
        case ATTRIBUTE11:
            setAttribute11((String)value);
            return;
        case ATTRIBUTE12:
            setAttribute12((String)value);
            return;
        case ATTRIBUTE13:
            setAttribute13((String)value);
            return;
        case ATTRIBUTE14:
            setAttribute14((String)value);
            return;
        case ATTRIBUTE15:
            setAttribute15((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }



  /*
   * 
   * Gets the associated entity SupplierEOImpl
   */
  public SupplierEOImpl getSupplierEO()
  {
    return (SupplierEOImpl)getAttributeInternal(SUPPLIEREO);
  }

  /*
   * 
   * Sets <code>value</code> as the associated entity SupplierEOImpl
   */
  public void setSupplierEO(SupplierEOImpl value)
  {
    setAttributeInternal(SUPPLIEREO, value);
  }


  /**
   * 
   * Gets the associated entity oracle.jbo.RowIterator
   */
  public RowIterator getPurchaseOrderHeaderEO()
  {
    return (RowIterator)getAttributeInternal(PURCHASEORDERHEADEREO);
  }


    /*
   *
   * Creates a Key object based on given key constituents
   */

    /**Creates a Key object based on given key constituents
     */
    public static Key createPrimaryKey(Number supplierSiteId) {
        return new Key(new Object[]{supplierSiteId});
    }
}
