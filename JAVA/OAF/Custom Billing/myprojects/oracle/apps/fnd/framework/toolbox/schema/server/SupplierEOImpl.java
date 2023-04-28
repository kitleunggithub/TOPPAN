/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |       16-APR-02  L Lyons  Created based on the Requisition prototype      |
 |                           plus inputs from the framework dev team.        |
 |                                                                           |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAAttrValException;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OARowValException;
import oracle.apps.fnd.framework.server.OADBTransaction;
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
 * DEBUG -- add comments
 *
 * EO Table:  FWK_TBX_SUPPLIERS
 * EO Child:  FWK_TBX_SUPPLIER_SITES (SupplierSiteEOImpl)
 */
public class SupplierEOImpl extends OAEntityImpl {

  // Mandatory for Applications source control
    public static final int SUPPLIERID = 0;
    public static final int NAME = 1;
    public static final int ONHOLDFLAG = 2;
    public static final int STARTDATE = 3;
    public static final int ENDDATE = 4;
    public static final int LASTUPDATEDATE = 5;
    public static final int LASTUPDATEDBY = 6;
    public static final int CREATIONDATE = 7;
    public static final int CREATEDBY = 8;
    public static final int LASTUPDATELOGIN = 9;
    public static final int ATTRIBUTECATEGORY = 10;
    public static final int ATTRIBUTE1 = 11;
    public static final int ATTRIBUTE2 = 12;
    public static final int ATTRIBUTE3 = 13;
    public static final int ATTRIBUTE4 = 14;
    public static final int ATTRIBUTE5 = 15;
    public static final int ATTRIBUTE6 = 16;
    public static final int ATTRIBUTE7 = 17;
    public static final int ATTRIBUTE8 = 18;
    public static final int ATTRIBUTE9 = 19;
    public static final int ATTRIBUTE10 = 20;
    public static final int ATTRIBUTE11 = 21;
    public static final int ATTRIBUTE12 = 22;
    public static final int ATTRIBUTE13 = 23;
    public static final int ATTRIBUTE14 = 24;
    public static final int ATTRIBUTE15 = 25;
    public static final int PURCHASEORDERHEADEREO = 26;
    public static final String RCS_ID="$Header: SupplierEOImpl.java 120.2 2006/07/03 22:26:22 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");
    public static final int SUPPLIERSITEEO = 27;

    /*
   * ***************************************************************************
   * Initializes a new supplier.
   * ***************************************************************************
   */
  public void create(AttributeList attributeList)
  {

    super.create(attributeList); 
    
    OADBTransaction transaction = getOADBTransaction();
    
    // DEFAULT: supplier id is obtained from the table's sequence
    Number supplierId = transaction.getSequenceValue("FWK_TBX_SUPPLIERS_S");
    setSupplierId(supplierId);

    // DEFAULT: start date should be set to sysdate
    setStartDate(transaction.getCurrentDBDate());

    
  }  // end create()


  /*
   *****************************************************************************
   *  Convenience method returns the SupplierEntityExpert.
   *****************************************************************************
   */
  public static SupplierEntityExpert getSupplierEntityExpert(OADBTransaction txn)
  {       
    return (SupplierEntityExpert)txn.getExpert(SupplierEOImpl.getDefinitionObject());  
    
  } // end getSupplierEntityExpert()


  /*
   * ***************************************************************************
   * Suppliers cannot be deleted. To prevent further use, an End Date should
   * be set instead.
   * ***************************************************************************
   */
  public void remove()
  { 
    throw new OARowValException(OARowValException.TYP_ENTITY_OBJECT,
                                getEntityDef().getFullName(),
                                getPrimaryKey(),
                                "AK", // Message product short name
                                "FWK_TBX_T_SUP_NO_DELETE");  // Message name
  
  }  // end remove()


  /*
   * ***************************************************************************
   * Performs entity-level validation.  This includes any validation which 
   * should be performed after the individual attributes are validated.
   * ***************************************************************************
   */
  protected void validateEntity()
  {
    super.validateEntity();
    
    Date startDate = getStartDate();
    Date endDate = getEndDate();
    
    validateStartDate(startDate);
    validateEndDate(endDate);

    // We validate the following here instead of from within an attribute because
    // we need to make sure that both values are set before we perform the test.

     if (endDate != null)
     {
        // Note that we want to truncate these values to allow for the possibility
        // that we're trying to set them to be the same day.  Calling 
        // dateValue( ) does not include time.  Were we to want the time element,
        // we would call timestampValue().  Finally, whenever comparing jbo
        // Date objects, we have to convert to long values.
        
        long endDateLong = endDate.dateValue().getTime();

        // We can assume we have a Start Date or the validation of this 
        // value would have thrown an exception.
        
        if (endDateLong < startDate.dateValue().getTime())
        {
          throw new OARowValException(OARowValException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(),
                                     getPrimaryKey(),
                                     "AK", // Message product short name
                                     "FWK_TBX_T_START_END_BAD");  // Message name
         }   
      }     
 
  } // end validateEntity()


  /*
   * ***************************************************************************
   * Sets <code>value</code> as the attribute value for SupplierId
   * 
   * Business Rules:
   * Supplier id is required.
   * Supplier id cannot be updated on a committed row.
   * Supplier id must be unique.
   * ***************************************************************************
   */
  public void setSupplierId(Number value)
  {

    // BC4J validates that this can be updated only on a new line, and that this
    // mandatory attribute is not null.  This code adds the additional check 
    // of only allowing an update if the value is null to prevent changes while 
    // the object is in memory.

   if (getSupplierId() != null)
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "SupplierId", // Attribute Name
                                   value, // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_SUP_ID_NO_UPDATE"); // Message name

    }

    if (value != null)
    {
      // Supplier id must be unique.  To verify this, you must check both the
      // entity cache and the database.  In this case, it's appropriate
      // to use findByPrimaryKey( ) because you're unlikely to get a match, and
      // and are therefore unlikely to pull a bunch of large objects into memory.

      // Note that findByPrimaryKey() is guaranteed to check all suppliers.  
      // First it checks the entity cache, then it checks the database.

      OADBTransaction transaction = getOADBTransaction();
      Object[] supplierKey = {value};
      EntityDefImpl supplierDefinition = SupplierEOImpl.getDefinitionObject();
      SupplierEOImpl supplier = 
        (SupplierEOImpl)supplierDefinition.findByPrimaryKey(transaction, new Key(supplierKey));

      if (supplier != null)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "SupplierId", // Attribute Name
                                   value, // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_SUP_ID_UNIQUE"); // Message name 
      }
    }  
    
    setAttributeInternal(SUPPLIERID, value);
    
  }  // end setSupplierId()


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for Name.
   *
   * Business rules:
   * Supplier name is required.
   * Supplier name must be unique (ignoring capitalization).
   * Supplier name cannot be changed on committed rows.
   * ***************************************************************************
   */
  public void setName(String value)
  {
    // Since this value is marked as "mandatory," the BC4J Framework will take
    // care of ensuring that it's a non-null value.  However, if it is null, we
    // don't want to proceed with any validation that could result in a NPE.
    
    if ((value != null) || (!("".equals(value.trim()))))
    {
      // Verify that the name is unique.  To do this, we must check both the entity
      // cache and the database.  We begin with the entity cache.

      com.sun.java.util.collections.Iterator supplierIterator = 
        getEntityDef().getAllEntityInstancesIterator(getDBTransaction());
    
      Number currentId = getSupplierId();
    
      while ( supplierIterator.hasNext() )
      {
        SupplierEOImpl cachedSupplier = (SupplierEOImpl)supplierIterator.next();

        String cachedName = cachedSupplier.getName();
        Number cachedId = cachedSupplier.getSupplierId();

        // We found a match for the name we're trying to set, so throw an
        // exception.  Note that we need to exclude this EO from our test.
        
        if (cachedName != null && value.equalsIgnoreCase(cachedName) && 
            cachedId.compareTo(currentId) != 0 )
        {
           throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                      getEntityDef().getFullName(), // EO name
                                      getPrimaryKey(), // EO PK
                                      "Name", // Attribute Name
                                      value, // Attribute value
                                      "AK", // Message product short name
                                      "FWK_TBX_T_SUP_DUP_NAME"); // Message name      
        }
      }  

      // Now we want to check the database for any occurences of the supplier
      // name.  The most efficient way to check this is with a validation view
      // object to which we add to a special "Validation" application module.
      // We then added a "supplierExists" method to this entity's expert.  This
      // method leverages the VAM and the VVO.

      OADBTransaction transaction = getOADBTransaction();
      SupplierEntityExpert expert = getSupplierEntityExpert(transaction);

      if (expert.supplierExists(value))
      {
          throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "Name", // Attribute Name
                                     value, // Attribute value
                                     "AK", // Message product short name
                                     "FWK_TBX_T_SUP_DUP_NAME"); // Message name
      }
    }
    
    setAttributeInternal(NAME, value);
    
  } // end setName()
  

  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for OnHoldFlag
   *****************************************************************************
   */
  public void setOnHoldFlag(String value)
  {
    // Valid values are null, Y and N

    if ((value != null) && (!("".equals(value.trim()))))
    { 
      if (!(("Y".equals(value)) || ("N".equals(value))))
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "OnHoldFlag", // Attribute Name
                                     value, // Attribute value
                                     "AK", // Message product short name
                                     "FWK_TBX_T_SUP_ONHOLD_INVALID"); // Message name

      }
    }

    setAttributeInternal(ONHOLDFLAG, value);
    
  } // end setOnHoldFlag()
  

  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for StartDate
   * 
   * Business Rules:
   * Start Date is required.
   * Cannot be earlier than sysdate.
   *****************************************************************************
   */
  public void setStartDate(Date value)
  {
    validateStartDate(value);
    setAttributeInternal(STARTDATE, value);
    
  } // end setStartDate()

  /*
   *****************************************************************************
   * Validates the start date (created as a separate method so it can be called
   * in validateEntity and setStartDate).
   *****************************************************************************
   */
   public void validateStartDate(Date value)
   {
    
      if (value != null)
      {
        OADBTransaction transaction = getOADBTransaction();

        // Note that we want to truncate these values to allow for the possibility
        // that we're trying to set them to be the same day.  Calling 
        // dateValue( ) does not include time.  Were we to want the time element,
        // we would call timestampValue().  Finally, you cannot compare 
        // oracle.jbo.domain.Date objects directly. Instead, convert the value to 
        // a long as shown.
    
        long sysdate = transaction.getCurrentDBDate().dateValue().getTime();
        long startDate = value.dateValue().getTime();

        if (startDate < sysdate)
        {
          throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "StartDate", // Attribute Name
                                     value, // Attribute value
                                     "AK", // Message product short name
                                     "FWK_TBX_T_START_DATE_PAST"); // Message name
       } 
     }
     
   } // end setStartDate();


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for EndDate
   * 
   * Business Rules:
   * This is an optional value which can be updated at any time.
   * Cannot be earlier than sysdate.
   *****************************************************************************
   */
  public void setEndDate(Date value)
  {

    validateEndDate(value);
    setAttributeInternal(ENDDATE, value);
    
  } // end setEndDate()
  

  /*
   *****************************************************************************
   * Validates the end date (created as a separate method so it can be called
   * in validateEntity and setEndDate).
   *****************************************************************************
   */
   public void validateEndDate(Date value)
   {
    
     if (value != null)
     {
       OADBTransaction transaction = getOADBTransaction();

       // Note that we want to truncate these values to allow for the possibility
       // that we're trying to set them to be the same day.  Calling 
       // dateValue( ) does not include time.  Were we to want the time element,
       // we would call timestampValue().  Finally, you cannot compare 
       // oracle.jbo.domain.Date objects directly. Instead, convert the value to 
       // a long as shown.
    
       long sysdate = transaction.getCurrentDBDate().dateValue().getTime();
       long endDate = value.dateValue().getTime();

       if (endDate < sysdate)
       {    
         throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                      getEntityDef().getFullName(), // EO name
                                      getPrimaryKey(), // EO PK
                                      "EndDate", // Attribute Name
                                      value, // Attribute value
                                      "AK", // Message product short name
                                      "FWK_TBX_T_END_DATE_PAST"); // Message name
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

  public SupplierEOImpl()
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
                    (OAEntityDefImpl)EntityDefImpl.findDefObject("oracle.apps.fnd.framework.toolbox.schema.server.SupplierEO");
        }
        return mDefinitionObject;
    }

    public Number getSupplierId()
  {
    return (Number)getAttributeInternal(SUPPLIERID);
  }

 /*
   * 
   * Gets the attribute value for Name, using the alias name Name
   */
  public String getName()
  {
    return (String)getAttributeInternal(NAME);
  }


  /*
   * 
   * Gets the attribute value for OnHoldFlag, using the alias name OnHoldFlag
   */
  public String getOnHoldFlag()
  {
    return (String)getAttributeInternal(ONHOLDFLAG);
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
        case NAME:
            return getName();
        case ONHOLDFLAG:
            return getOnHoldFlag();
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
        case SUPPLIERSITEEO:
            return getSupplierSiteEO();
        case PURCHASEORDERHEADEREO:
            return getPurchaseOrderHeaderEO();
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
        case NAME:
            setName((String)value);
            return;
        case ONHOLDFLAG:
            setOnHoldFlag((String)value);
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
   * Gets the associated entity oracle.jbo.RowIterator
   */
  public RowIterator getSupplierSiteEO()
  {
    return (RowIterator)getAttributeInternal(SUPPLIERSITEEO);
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
    public static Key createPrimaryKey(Number supplierId) {
        return new Key(new Object[]{supplierId});
    }
}
