/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |       16-APR-02  L Lyons  Created based on the Requisition prototype      |
 |                           RequisitionDistributionEOImpl class plus inputs |
 |                           from the Framework development team.            |
 |       23-JUN-06  RNIRMAL  Bug 5254600 - Added new FND messages            |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAAttrValException;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.server.OAEntityDefImpl;
import oracle.apps.fnd.framework.server.OAEntityImpl;

import oracle.jbo.AttributeList;
import oracle.jbo.Key;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.server.EntityDefImpl;

public class PurchaseOrderShipmentEOImpl extends OAEntityImpl {

  // Mandatory for Applications source control
    public static final int SHIPMENTID = 0;
    public static final int LINEID = 1;
    public static final int SHIPMENTNUMBER = 2;
    public static final int NEEDBYDATE = 3;
    public static final int RECEIPTQUANTITY = 4;
    public static final int ORDERQUANTITY = 5;
    public static final int SHIPTOADDRESSID = 6;
    public static final int LASTUPDATEDATE = 7;
    public static final int LASTUPDATEDBY = 8;
    public static final int CREATIONDATE = 9;
    public static final int CREATEDBY = 10;
    public static final int LASTUPDATELOGIN = 11;
    public static final int ATTRIBUTECATEGORY = 12;
    public static final int ATTRIBUTE1 = 13;
    public static final int ATTRIBUTE2 = 14;
    public static final int ATTRIBUTE3 = 15;
    public static final int ATTRIBUTE4 = 16;
    public static final int ATTRIBUTE5 = 17;
    public static final int ATTRIBUTE6 = 18;
    public static final int ATTRIBUTE7 = 19;
    public static final int ATTRIBUTE8 = 20;
    public static final int ATTRIBUTE9 = 21;
    public static final int ATTRIBUTE10 = 22;
    public static final int ATTRIBUTE11 = 23;
    public static final int ATTRIBUTE12 = 24;
    public static final int ATTRIBUTE13 = 25;
    public static final int ATTRIBUTE14 = 26;
    public static final int ATTRIBUTE15 = 27;
    public static final int RECEIPTDATE = 28;
    public static final int PROMISEDATE = 29;
    public static final String RCS_ID="$Header: PurchaseOrderShipmentEOImpl.java 120.7 2006/07/15 12:41:06 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");
    public static final int PURCHASEORDERLINEEO = 30;


    protected void doDML(int operation, oracle.jbo.server.TransactionEvent e)
  {    
    //add a condition not to remove the shipment that has receiptDate earlier than today
    if(operation == DML_DELETE)
    {
      Date receiptDate = getReceiptDate();
      if(receiptDate != null)
      {
        long today = getOADBTransaction().getCurrentDBDate().dateValue().getTime();
        long receiptDateVal = receiptDate.dateValue().getTime();
        if(receiptDateVal < today)
          throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                       getEntityDef().getFullName(), // EO name
                                       getPrimaryKey(), // EO PK
                                       "ReceiptDate", // Attribute Name
                                       receiptDate, // Attribute value
                                       "FND", // Message product short name
                                       "FWK_TBX_T_SHIPMENT_DELETE"); // Message name
      }
    }
    super.doDML(operation, e);
    
  } // end postChanges()

  /*
   *****************************************************************************
   * Deletes the shipment.
   *****************************************************************************
   */
  public void remove()
  {
    super.remove();
    
  } // end remove()


  /*
   *****************************************************************************
   * Initializes a new shipment
   *****************************************************************************
   */
  public void create(AttributeList attributeList)
  {

    super.create(attributeList);

    OADBTransaction transaction = (OADBTransaction)getOADBTransaction();
    
    // DEFAULT: shipment id
    Number shipmentId = transaction.getSequenceValue("FWK_TBX_PO_SHIPMENTS_S");
    setShipmentId(shipmentId);

    // DEFAULT: Shipment number
    PurchaseOrderLineEOImpl lineEO = getPurchaseOrderLineEO(); 
    Number newShipNum = lineEO.getNextShipNum();
    setShipmentNumber(newShipNum);


    // DEFAULT:  Ship-to address from the order header
    Number shipToAddressId = 
    lineEO.getPurchaseOrderHeaderEO().getShipToAddressId();
    setShipToAddressId(shipToAddressId);     

  } // end create()

  /*
   ****************************************************************************** 
   * Receives items.
   *
   * Business Rules:
   *****************************************************************************
   */
   public void receiveItems(Date receiptDate,
                            Number receiptQuantity)
   {
     setReceiptDate(receiptDate);
     setReceiptQuantity(receiptQuantity);
   }

  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for ReceiptDate.
   *
   * Business Rules:
   * If receipt date is not specified, this defaults to today's date.
   * Receipt date cannot be > 2 weeks after today's date.
   *****************************************************************************
   */
   public void setReceiptDate(Date value)
   {
      OADBTransaction transaction = (OADBTransaction)getOADBTransaction();
      Date sysdate = transaction.getCurrentDBDate();

      if (value != null)
      {
        // Note that we want to truncate these values to allow for the possibility
        // that we're trying to set them to be the same day.  Calling 
        // dateValue( ) does not include time.  Were we to want the time element,
        // we would call timestampValue().  Finally, you cannot compare 
        // oracle.jbo.domain.Date objects directly. Instead, convert the value to 
        // a long as shown.
    
        long today = transaction.getCurrentDBDate().dateValue().getTime();
        long receiptDate = value.dateValue().getTime();

        // Here, we add the milliseconds equivalent to 14 days to get the
        // maximum acceptable receipt date.
        long maxReceiptDate = today + (14 * (24*60*60*1000));

        if (receiptDate > maxReceiptDate)
        {
          throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                       getEntityDef().getFullName(), // EO name
                                       getPrimaryKey(), // EO PK
                                       "ReceiptDate", // Attribute Name
                                       value, // Attribute value
                                       "FND", // Message product short name
                                       "FWK_TBX_T_RECEIPTDATE"); // Message name
        }
     
      }
      else
      {
        value = sysdate;
      }
     
     setAttributeInternal(RECEIPTDATE, value);  
     
   } // end setReceiptDate

  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for ReceiptQuantity.
   *
   * Business Rules:
   * Receipt quantity must be > 0.
   * Receipt quantity cannopt exceed the outstanding order quantity by > 10%.
   *****************************************************************************
   */
   public void setReceiptQuantity(Number value)
   {
     
     if ((value == null) || (value.compareTo(0) <= 0))
     {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "ReceiptQuantity", // Attribute Name
                                     value, // Attribute value
                                     "FND", // Message product short name
                                     "FWK_TBX_T_RECEIPT_QTY_MIN"); // Message name
      
     }
     else
     {
        Number orderQuantity = getOrderQuantity();
        Number currentReceipts = getReceiptQuantity();
        if(orderQuantity!=null && currentReceipts!=null)
        {
          Number netQuantity  = orderQuantity.subtract(currentReceipts);
        
          // Verify that receiptQuantity <= the outstanding order quantity.
          if (value.compareTo(netQuantity.add(netQuantity.multiply(.10))) > 0)
          {
            throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "ReceiptQuantity", // Attribute Name
                                     value, // Attribute value
                                     "FND", // Message product short name
                                     "FWK_TBX_T_RECEIPT_QTY_MAX"); // Message name
          }
        }  
        
     }
     setAttributeInternal(RECEIPTQUANTITY, value); 
   }
 
  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for ShipmentId
   *
   * Business Rules:
   * Shipment id is required.
   * Shipment id cannot be updated on a committed row.
   * Shipment id must be unique.
   *****************************************************************************
   */
  public void setShipmentId(Number value)
  {
    // BC4J validates that this can be updated only on a new line, and that this
    // mandatory attribute is not null.  This code adds the additional check 
    // of only allowing an update if the value is null to prevent changes while 
    // the object is in memory.
    
    if (getShipmentId() != null)
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "ShipmentId", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_SHIPMENT_ID_UPDATE"); // Message name
    }

    if (value != null)
    {

      // findByPrimaryKey() is guaranteed to check all shipments.  First it checks
      // the entity cache, then it checks the database.  Although this will pull
      // in the entity for any matches it finds (if in the database) it's OK to
      // use it for PK checking since we don't expect to find a match.

      OADBTransaction transaction = (OADBTransaction)getOADBTransaction();
      Object[] shipmentKey = {value};
      EntityDefImpl shipDefinition = PurchaseOrderShipmentEOImpl.getDefinitionObject();
      PurchaseOrderShipmentEOImpl shipment = 
        (PurchaseOrderShipmentEOImpl)shipDefinition.findByPrimaryKey(transaction, new Key(shipmentKey));

      if (shipment != null)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "ShipmentId", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_SHIPMENT_ID_UNIQUE"); // Message name 
      }
    }  

    setAttributeInternal(SHIPMENTID, value);
    
  } // end setShipmentId()


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for ShipmentNumber
   *
   * Business Rules:
   * Shipment number is required
   * Cannot be updated on a committed row
   * Must be unique within the context of the parent PO line
   * Must be >= 1
   *****************************************************************************
   */
  public void setShipmentNumber(Number value)
  {
    // BC4J ensures that this mandatory attribute is not null.
    
    if (value != null)
    {
      // Value must >= 1
    
      if (value.compareTo(0) <= 0)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "ShipmentNumber", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_SHIPMENTNUM_MIN"); // Message name
    
      }

      // To verify uniqueness, start by checking the entity cache.

      com.sun.java.util.collections.Iterator shipmentIterator = 
        getEntityDef().getAllEntityInstancesIterator(getDBTransaction());
    
      Number lineId = getLineId();
      Number shipmentId = getShipmentId();
    
      while ( shipmentIterator.hasNext() )
      {
        PurchaseOrderShipmentEOImpl cachedShipment = 
          (PurchaseOrderShipmentEOImpl)shipmentIterator.next();

        Number cachedShipNum = cachedShipment.getShipmentNumber();
        Number cachedLineId = cachedShipment.getLineId();
        Number cachedShipmentId = cachedShipment.getShipmentId();
          
        if ((cachedShipNum != null) && 
            (cachedShipNum.compareTo(value) == 0) && 
            (cachedLineId.compareTo(lineId) == 0) &&
            (cachedShipmentId.compareTo(shipmentId) != 0)) // Ignore this shipment
         {
          throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "ShipmentNumber", // Attribute Name
                                     value, // Attribute value
                                     "FND", // Message product short name
                                     "FWK_TBX_T_SHIPMENTNUM_UPDATE"); // Message name      
 
          }
        }  
    
      // Didn't find a duplicate in the entity cache so now we check the database.
      // Note: don't bother with this if the line is in a NEW state since that 
      // means we won't have any shipments in the database yet.

      PurchaseOrderLineEOImpl lineEO = getPurchaseOrderLineEO();

      if (lineEO.getEntityState() != STATUS_NEW)
      {
        PurchaseOrderEntityExpert poExpert = 
          PurchaseOrderHeaderEOImpl.getPurchaseOrderEntityExpert(getOADBTransaction());

        PoShipNumVVOImpl valShipNumVO = 
          (PoShipNumVVOImpl)poExpert.findValidationViewObject("PoShipNumVVO1");
        
        valShipNumVO.initQuery(lineId, value);  

        // We're doing an existence check; shouldn't have any rows.
    
        if (valShipNumVO.hasNext())
        {
          throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "ShipmentNumber", // Attribute Name
                                     value, // Attribute value
                                     "FND", // Message product short name
                                     "FWK_TBX_T_SHIPMENTNUM_UNIQUE"); // Message name
        }
      } 
      
      // If this is the largest shipment number for this line, store it for reference
      // on the line.
      
      lineEO.resetShipNum(value);

    }
   
    setAttributeInternal(SHIPMENTNUMBER, value);
    
  } // end setShipmentNumber()


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for NeedByDate
   * 
   * Business Rules
   * Need-By Date is optional
   * If specified, this must be >= sysdate
   *****************************************************************************
   */
  public void setNeedByDate(Date value)
  {

    if (value != null)
    {
    
      OADBTransaction transaction = (OADBTransaction)getOADBTransaction();

      // Note that we want to truncate these values to allow for the possibility
      // that we're trying to set them to be the same day.  Calling 
      // dateValue( ) does not include time.  Were we to want the time element,
      // we would call timestampValue().  Finally, you cannot compare 
      // oracle.jbo.domain.Date objects directly. Instead, convert the value to 
      // a long as shown.
    
      long sysdate = transaction.getCurrentDBDate().dateValue().getTime();
      long needByDate = value.dateValue().getTime();

      if (needByDate < sysdate)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "NeedByDate", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_NEEDBYDATE"); // Message name

      }
    }  

    setAttributeInternal(NEEDBYDATE, value);
    
  } // end setNeedByDate()


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for OrderQuantity
   *
   * Business Rules
   * Quantity is required
   * Must be > 0
   * Sum of all shipment order quantities must equal the parent line quantity
   *****************************************************************************
   */
  public void setOrderQuantity(Number value)
  {
    // BC4J ensures that this mandatory attribute is not null.
    
    if (value != null)
    {
      if (value.compareTo(0) <= 0)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "OrderQuantity", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_ORDERQTY_MIN"); // Message name

      }
    }  
    
    setAttributeInternal(ORDERQUANTITY, value);
    
  } // end setOrderQuantity()



  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for ShipToAddressId
   *****************************************************************************
   */
  public void setShipToAddressId(Number value)
  {
  
   // BC4J ensures that this mandatory attribute is not null.

   // Since the first release of the tutorial does not involve adding
   // multiple shipments, validation supporting a user-entered ship-to address
   // is not included yet (also, since the ability to change the ship-to address
   // on the header isn't exposed either, we can just set this when the row is
   // initialized -- see create()).

    setAttributeInternal(SHIPTOADDRESSID, value);
    
  } // end setShipToAddressId()


//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here...
//  ---------------------------------------------------------------




















  private static oracle.apps.fnd.framework.server.OAEntityDefImpl mDefinitionObject;

    /**
   * 
   * This is the default constructor (do not remove)
   */
  public PurchaseOrderShipmentEOImpl()
  {
  }


    /**Retrieves the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        if (mDefinitionObject == null) {
            mDefinitionObject =
                    (OAEntityDefImpl)EntityDefImpl.findDefObject("oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderShipmentEO");
        }
        return mDefinitionObject;
    }

    /**
     *
     * Gets the attribute value for ShipmentId, using the alias name ShipmentId
     */
    public Number getShipmentId()
  {
    return (Number)getAttributeInternal(SHIPMENTID);
  }

  /**
   * 
   * Gets the attribute value for LineId, using the alias name LineId
   */
  public Number getLineId()
  {
    return (Number)getAttributeInternal(LINEID);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for LineId
   */
  public void setLineId(Number value)
  {
    setAttributeInternal(LINEID, value);
  }

  /**
   * 
   * Gets the attribute value for ShipmentNumber, using the alias name ShipmentNumber
   */
  public Number getShipmentNumber()
  {
    return (Number)getAttributeInternal(SHIPMENTNUMBER);
  }


  /**
   * 
   * Gets the attribute value for NeedByDate, using the alias name NeedByDate
   */
  public Date getNeedByDate()
  {
    return (Date)getAttributeInternal(NEEDBYDATE);
  }


  /**
   * 
   * Gets the attribute value for ReceiptQuantity, using the alias name ReceiptQuantity
   */
  public Number getReceiptQuantity()
  {
    return (Number)getAttributeInternal(RECEIPTQUANTITY);
  }


  /**
   * 
   * Gets the attribute value for OrderQuantity, using the alias name OrderQuantity
   */
  public Number getOrderQuantity()
  {
    return (Number)getAttributeInternal(ORDERQUANTITY);
  }

  /**
   * 
   * Gets the attribute value for ShipToAddressId, using the alias name ShipToAddressId
   */
  public Number getShipToAddressId()
  {
    return (Number)getAttributeInternal(SHIPTOADDRESSID);
  }


  /**
   * 
   * Gets the attribute value for LastUpdateDate, using the alias name LastUpdateDate
   */
  public Date getLastUpdateDate()
  {
    return (Date)getAttributeInternal(LASTUPDATEDATE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for LastUpdateDate
   */
  public void setLastUpdateDate(Date value)
  {
    setAttributeInternal(LASTUPDATEDATE, value);
  }

  /**
   * 
   * Gets the attribute value for LastUpdatedBy, using the alias name LastUpdatedBy
   */
  public Number getLastUpdatedBy()
  {
    return (Number)getAttributeInternal(LASTUPDATEDBY);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for LastUpdatedBy
   */
  public void setLastUpdatedBy(Number value)
  {
    setAttributeInternal(LASTUPDATEDBY, value);
  }

  /**
   * 
   * Gets the attribute value for CreationDate, using the alias name CreationDate
   */
  public Date getCreationDate()
  {
    return (Date)getAttributeInternal(CREATIONDATE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for CreationDate
   */
  public void setCreationDate(Date value)
  {
    setAttributeInternal(CREATIONDATE, value);
  }

  /**
   * 
   * Gets the attribute value for CreatedBy, using the alias name CreatedBy
   */
  public Number getCreatedBy()
  {
    return (Number)getAttributeInternal(CREATEDBY);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for CreatedBy
   */
  public void setCreatedBy(Number value)
  {
    setAttributeInternal(CREATEDBY, value);
  }

  /**
   * 
   * Gets the attribute value for LastUpdateLogin, using the alias name LastUpdateLogin
   */
  public Number getLastUpdateLogin()
  {
    return (Number)getAttributeInternal(LASTUPDATELOGIN);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for LastUpdateLogin
   */
  public void setLastUpdateLogin(Number value)
  {
    setAttributeInternal(LASTUPDATELOGIN, value);
  }

  /**
   * 
   * Gets the attribute value for AttributeCategory, using the alias name AttributeCategory
   */
  public String getAttributeCategory()
  {
    return (String)getAttributeInternal(ATTRIBUTECATEGORY);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for AttributeCategory
   */
  public void setAttributeCategory(String value)
  {
    setAttributeInternal(ATTRIBUTECATEGORY, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute1, using the alias name Attribute1
   */
  public String getAttribute1()
  {
    return (String)getAttributeInternal(ATTRIBUTE1);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute1
   */
  public void setAttribute1(String value)
  {
    setAttributeInternal(ATTRIBUTE1, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute2, using the alias name Attribute2
   */
  public String getAttribute2()
  {
    return (String)getAttributeInternal(ATTRIBUTE2);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute2
   */
  public void setAttribute2(String value)
  {
    setAttributeInternal(ATTRIBUTE2, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute3, using the alias name Attribute3
   */
  public String getAttribute3()
  {
    return (String)getAttributeInternal(ATTRIBUTE3);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute3
   */
  public void setAttribute3(String value)
  {
    setAttributeInternal(ATTRIBUTE3, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute4, using the alias name Attribute4
   */
  public String getAttribute4()
  {
    return (String)getAttributeInternal(ATTRIBUTE4);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute4
   */
  public void setAttribute4(String value)
  {
    setAttributeInternal(ATTRIBUTE4, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute5, using the alias name Attribute5
   */
  public String getAttribute5()
  {
    return (String)getAttributeInternal(ATTRIBUTE5);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute5
   */
  public void setAttribute5(String value)
  {
    setAttributeInternal(ATTRIBUTE5, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute6, using the alias name Attribute6
   */
  public String getAttribute6()
  {
    return (String)getAttributeInternal(ATTRIBUTE6);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute6
   */
  public void setAttribute6(String value)
  {
    setAttributeInternal(ATTRIBUTE6, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute7, using the alias name Attribute7
   */
  public String getAttribute7()
  {
    return (String)getAttributeInternal(ATTRIBUTE7);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute7
   */
  public void setAttribute7(String value)
  {
    setAttributeInternal(ATTRIBUTE7, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute8, using the alias name Attribute8
   */
  public String getAttribute8()
  {
    return (String)getAttributeInternal(ATTRIBUTE8);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute8
   */
  public void setAttribute8(String value)
  {
    setAttributeInternal(ATTRIBUTE8, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute9, using the alias name Attribute9
   */
  public String getAttribute9()
  {
    return (String)getAttributeInternal(ATTRIBUTE9);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute9
   */
  public void setAttribute9(String value)
  {
    setAttributeInternal(ATTRIBUTE9, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute10, using the alias name Attribute10
   */
  public String getAttribute10()
  {
    return (String)getAttributeInternal(ATTRIBUTE10);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute10
   */
  public void setAttribute10(String value)
  {
    setAttributeInternal(ATTRIBUTE10, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute11, using the alias name Attribute11
   */
  public String getAttribute11()
  {
    return (String)getAttributeInternal(ATTRIBUTE11);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute11
   */
  public void setAttribute11(String value)
  {
    setAttributeInternal(ATTRIBUTE11, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute12, using the alias name Attribute12
   */
  public String getAttribute12()
  {
    return (String)getAttributeInternal(ATTRIBUTE12);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute12
   */
  public void setAttribute12(String value)
  {
    setAttributeInternal(ATTRIBUTE12, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute13, using the alias name Attribute13
   */
  public String getAttribute13()
  {
    return (String)getAttributeInternal(ATTRIBUTE13);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute13
   */
  public void setAttribute13(String value)
  {
    setAttributeInternal(ATTRIBUTE13, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute14, using the alias name Attribute14
   */
  public String getAttribute14()
  {
    return (String)getAttributeInternal(ATTRIBUTE14);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Attribute14
   */
  public void setAttribute14(String value)
  {
    setAttributeInternal(ATTRIBUTE14, value);
  }

  /**
   * 
   * Gets the attribute value for Attribute15, using the alias name Attribute15
   */
  public String getAttribute15()
  {
    return (String)getAttributeInternal(ATTRIBUTE15);
  }

  /**
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
        case SHIPMENTID:
            return getShipmentId();
        case LINEID:
            return getLineId();
        case SHIPMENTNUMBER:
            return getShipmentNumber();
        case NEEDBYDATE:
            return getNeedByDate();
        case RECEIPTQUANTITY:
            return getReceiptQuantity();
        case ORDERQUANTITY:
            return getOrderQuantity();
        case SHIPTOADDRESSID:
            return getShipToAddressId();
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
        case RECEIPTDATE:
            return getReceiptDate();
        case PROMISEDATE:
            return getPromiseDate();
        case PURCHASEORDERLINEEO:
            return getPurchaseOrderLineEO();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case SHIPMENTID:
            setShipmentId((Number)value);
            return;
        case LINEID:
            setLineId((Number)value);
            return;
        case SHIPMENTNUMBER:
            setShipmentNumber((Number)value);
            return;
        case NEEDBYDATE:
            setNeedByDate((Date)value);
            return;
        case RECEIPTQUANTITY:
            setReceiptQuantity((Number)value);
            return;
        case ORDERQUANTITY:
            setOrderQuantity((Number)value);
            return;
        case SHIPTOADDRESSID:
            setShipToAddressId((Number)value);
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
        case RECEIPTDATE:
            setReceiptDate((Date)value);
            return;
        case PROMISEDATE:
            setPromiseDate((Date)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }



  /**
   * 
   * Gets the associated entity PurchaseOrderLineEOImpl
   */
  public PurchaseOrderLineEOImpl getPurchaseOrderLineEO()
  {
    return (PurchaseOrderLineEOImpl)getAttributeInternal(PURCHASEORDERLINEEO);
  }

  /**
   * 
   * Sets <code>value</code> as the associated entity PurchaseOrderLineEOImpl
   */
  public void setPurchaseOrderLineEO(PurchaseOrderLineEOImpl value)
  {
    setAttributeInternal(PURCHASEORDERLINEEO, value);
  }


  /**
   * 
   * Gets the attribute value for ReceiptDate, using the alias name ReceiptDate
   */
  public Date getReceiptDate()
  {
    return (Date)getAttributeInternal(RECEIPTDATE);
  }


  /**
   * 
   * Gets the attribute value for PromiseDate, using the alias name PromiseDate
   */
  public Date getPromiseDate()
  {
    return (Date)getAttributeInternal(PROMISEDATE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for PromiseDate
   */
  public void setPromiseDate(Date value)
  {
    setAttributeInternal(PROMISEDATE, value);
  }


    /**Creates a Key object based on given key constituents
     */
    public static Key createPrimaryKey(Number shipmentId) {
        return new Key(new Object[]{shipmentId});
    }
}
