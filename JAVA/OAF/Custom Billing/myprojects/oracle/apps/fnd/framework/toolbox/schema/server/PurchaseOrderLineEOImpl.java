/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |       16-APR-02  L Lyons  Created based on the Requisition prototype      |
 |                           RequisitionLineEOImpl class plus inputs         |
 |                           from the Framework development team.            |
 |       23-JUN-06  RNIRMAL  Bug 5254600 - Added new FND messages            |
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
import oracle.jbo.server.TransactionEvent;

 /*
  * DEBUG -- add comments
  *
  * EO Table:  FWK_TBX_PO_LINES
  * EO Child:  FWK_TBX_PO_SHIPMENTS (PurchaseOrderShipmentEOImpl)
  */
public class PurchaseOrderLineEOImpl extends OAEntityImpl {

  // Mandatory for Applications source control
    public static final int LINEID = 0;
    public static final int HEADERID = 1;
    public static final int LINENUMBER = 2;
    public static final int ITEMID = 3;
    public static final int ITEMDESCRIPTION = 4;
    public static final int UNITOFMEASURE = 5;
    public static final int QUANTITY = 6;
    public static final int UNITPRICE = 7;
    public static final int LASTUPDATEDATE = 8;
    public static final int LASTUPDATEDBY = 9;
    public static final int CREATIONDATE = 10;
    public static final int CREATEDBY = 11;
    public static final int LASTUPDATELOGIN = 12;
    public static final int ATTRIBUTECATEGORY = 13;
    public static final int ATTRIBUTE1 = 14;
    public static final int ATTRIBUTE2 = 15;
    public static final int ATTRIBUTE3 = 16;
    public static final int ATTRIBUTE4 = 17;
    public static final int ATTRIBUTE5 = 18;
    public static final int ATTRIBUTE6 = 19;
    public static final int ATTRIBUTE7 = 20;
    public static final int ATTRIBUTE8 = 21;
    public static final int ATTRIBUTE9 = 22;
    public static final int ATTRIBUTE10 = 23;
    public static final int ATTRIBUTE11 = 24;
    public static final int ATTRIBUTE12 = 25;
    public static final int ATTRIBUTE13 = 26;
    public static final int ATTRIBUTE14 = 27;
    public static final int ATTRIBUTE15 = 28;
    public static final int LINETOTAL = 29;
    public static final int PURCHASEORDERHEADEREO = 30;
    public static final String RCS_ID="$Header: PurchaseOrderLineEOImpl.java 120.3 2006/07/03 21:23:26 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");
    public static final int PURCHASEORDERSHIPMENTEO = 31;

    /*
   *****************************************************************************
   * Stores the current maximum shipment number.  Used by the line to determine
   * what the next shipment number should be.
   *****************************************************************************
   */
  private transient Number mMaxShipNum = new Number(-1);


  /*
   ***************************************************************************** 
   * Mark all the line's shipments for deletion, then mark this line for 
   * deletion.
   *****************************************************************************
   */
  public void remove()
  {    
    // Note this is a good use of the line -> shipments association since we
    // want to call remove( ) on each shipment.
    
    RowIterator shipmentsIterator = this.getPurchaseOrderShipmentEO();

    if (shipmentsIterator != null)
    {
      PurchaseOrderShipmentEOImpl shipment = null;
      
      while (shipmentsIterator.hasNext())
      {
        shipment = (PurchaseOrderShipmentEOImpl)shipmentsIterator.next();
        shipment.remove();
      }
    }   
    super.remove(); // Must be called last in this case.
    
  } // end remove()

  
  /*
   *****************************************************************************
   * Initializes a new purchase order line.
   *****************************************************************************
   */
  public void create(AttributeList attributeList)
  {
    
	  // NOTE:  header id is automatically set by BC4J because of the 
    // composition association.

    super.create(attributeList);

    OADBTransaction transaction = (OADBTransaction)getOADBTransaction();
          
    // DEFAULT: line id
    Number lineId = transaction.getSequenceValue("FWK_TBX_PO_LINES_S");
    
    setLineId(lineId);
    
    // DEFAULT: Line number
    PurchaseOrderHeaderEOImpl headerEO = getPurchaseOrderHeaderEO();
    Number newLineNum = headerEO.getNextLineNum();
    setLineNumber(newLineNum);

    // DEFAULT:  Unit of measure
    setUnitOfMeasure("EA");

/*
** DEBUG - fully implement item/description in later version of tutorial
*/
    // DEFAULT:  hard-code item_id for the tutorial for now
    setItemId(new Number(1));

    // DEFAULT:  hard-code item_description for the tutorial for now
    setItemDescription("5 amp power supply");


  }  // end create()


  /*
   *****************************************************************************
   * Perform entity-level and cross-attribute validation.
   *****************************************************************************
   */
  protected void validateEntity()
  {
    super.validateEntity();
  }

  /*
   *****************************************************************************
   * Performs last-minute validation before the purchase order is posted to the 
   * database. This gives us the opportunity to verify that the PO line has at 
   * least one associated shipment since a PO cannot be committed without at 
   * least 1 shipment.
   *****************************************************************************
   */
  public void postChanges(TransactionEvent e)
  {    
    if(getPostState()!=STATUS_DELETED)
      checkShipmentExists();  
    super.postChanges(e);
    
  } // end postChanges()


  /*
   *****************************************************************************
   * Verify that we have at least 1 shiupment for this line.
   *****************************************************************************
   */
  private void checkShipmentExists()
  {

    // A purchase order line must have at least 1 associated shipment.
	  // To check this, we first do a manual check of the entity cache
    // If we find a shipment for this line, we're done (note that the entity cache won't
    // include EOs that are DELETED or DEAD).

    com.sun.java.util.collections.Iterator fastIterator = 
        PurchaseOrderShipmentEOImpl.getDefinitionObject().getAllEntityInstancesIterator(getDBTransaction());

    Number currentLineId = getLineId();

    while ( fastIterator.hasNext() )
    {
      PurchaseOrderShipmentEOImpl cachedShipment = 
        (PurchaseOrderShipmentEOImpl)fastIterator.next();

      Number cachedLineId = cachedShipment.getLineId();

      // If we find a match, we're done. Don't forget to look only for shipments
      // for this line... The entity cache can include shipments for other lines
      // also.
        
      if ((cachedLineId != null) && (cachedLineId.compareTo(currentLineId) == 0 ))
      {
        return;
      } 
    }

    // We haven't found any matches in the cache yet, so now we need to check
    // the database...
    
    // In this example, we're illustrating the use of the association between the 
    // line and its shipments to iterate through all the shipments.  This will
    // check both the cache and the database, and will bring all the rows
    // into the middle tier (see setLineNumber() for an example of a lightweight
    // database check that does not bring rows into the middle tier). 
    // Note that this looks only at shipments for this
    // line so we don't need to filter our results, so it is convenient.

    RowIterator shipmentsIterator = getPurchaseOrderShipmentEO();
 
    if (!(shipmentsIterator.hasNext()))
	  {
      throw new OARowValException(OARowValException.TYP_ENTITY_OBJECT,
                                  getEntityDef().getFullName(),
                                  getPrimaryKey(),
                                  "FND", // Message product short name
                                  "FWK_TBX_T_NO_SHIPMENTS");   // Message name

    }
    
  }  // end checkShipmentExists()


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for ShipmentNumber
   *
   * Business Rules
   * Required; cannot be null
   * Cannot be updated on a committed line
   * Must be unique for this purchase order
   * Must be >= 1
   *****************************************************************************
   */
  public void setLineNumber(Number value)
  {

    if (value != null)
    {
      // Verify value is > 0
    
      if (value.compareTo(0) <= 0)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "LineNumber", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_LINE_NUM_MIN"); // Message name
    
      }

      // To verify uniqueness, start by checking the entity cache.

      com.sun.java.util.collections.Iterator lineIterator = 
        getEntityDef().getAllEntityInstancesIterator(getDBTransaction());
    
      Number lineId = getLineId();
      Number headerId = getHeaderId();
    
      while ( lineIterator.hasNext() )
      {
        PurchaseOrderLineEOImpl cachedLine = 
          (PurchaseOrderLineEOImpl)lineIterator.next();

        Number cachedLineNum = cachedLine.getLineNumber();
        Number cachedLineId = cachedLine.getLineId();
        Number cachedHeaderId = cachedLine.getHeaderId();
          
        if ((cachedLineNum != null) && 
            (cachedLineNum.compareTo(value) == 0) && 
            (cachedLineId.compareTo(lineId) != 0) && // Exclude this line
            (cachedHeaderId.compareTo(headerId) == 0))
        {
           throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                    getEntityDef().getFullName(), // EO name
                                    getPrimaryKey(), // EO PK
                                    "LineNumber", // Attribute Name
                                    value, // Attribute value
                                    "FND", // Message product short name
                                    "FWK_TBX_T_LINE_NUM_UPDATE"); // Message name      
  
         }  
       }  
    
      // Didn't find a duplicate in the entity cache so now we check the database.
      // Note: don't bother with this if the header is in a NEW state since that 
      // means we won't have any lines in the database yet.

      PurchaseOrderHeaderEOImpl headerEO = getPurchaseOrderHeaderEO();

      if (headerEO.getEntityState() != STATUS_NEW)
      {

        PurchaseOrderEntityExpert poExpert = 
          PurchaseOrderHeaderEOImpl.getPurchaseOrderEntityExpert(getOADBTransaction());    
         
        PoLineNumVVOImpl valLineNumVO = 
          (PoLineNumVVOImpl)poExpert.findValidationViewObject("PoLineNumVVO1");
        
        valLineNumVO.initQuery(headerId, value);  

        // We're doing an existence check; shouldn't have any rows.

        if (valLineNumVO.hasNext())
        {
          throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "LineNumber", // Attribute Name
                                     value, // Attribute value
                                     "FND", // Message product short name
                                     "FWK_TBX_T_LINE_NUM_UNIQUE"); // Message name
        }
      }

      // If this is the largest line number for this order, this will store it for
      // reference when creating subsequent lines.
      
      headerEO.resetLineNum(value);

    }
  
    setAttributeInternal(LINENUMBER, value);   
    
  } // end setLineNumber()


////////////////////////////////////////////////////////////////////////////////
// Begin implementation of Shipment Number handling
//
// Adapted from Requisition prototype...
////////////////////////////////////////////////////////////////////////////////


  /*
   *****************************************************************************
   * Gets the maximum shipment number for this purchase order line.
   * If {@link #mMaxShipNum} has not been initialized yet, find the maximum
   * shipment number in the database.
   * <p>
   * @return maximum shipment number
   *****************************************************************************
   */
  public Number getMaxShipNum()
  {
    // mMaxShipNum is in its initial state, so we need to check and 
    // see if we have shipments in both the entity cache and in the
    // database to find the current maximum.
    
    if (mMaxShipNum == null || mMaxShipNum.equals(new Number(-1)))
    {
      Number tempNum = new Number(0);

      com.sun.java.util.collections.Iterator fastCacheIterator = 
        PurchaseOrderShipmentEOImpl.getDefinitionObject().getAllEntityInstancesIterator(getDBTransaction());
 
      while (fastCacheIterator.hasNext())
      {
        PurchaseOrderShipmentEOImpl cachedShipment = (PurchaseOrderShipmentEOImpl)fastCacheIterator.next();

        Number currentLineId = getLineId();
        Number cachedLineId = cachedShipment.getLineId();

        // If we find a match for this line, check the shipment number.  Remember
        // that the cache includes shipments for many lines.
        
        if ((cachedLineId != null) && (cachedLineId.compareTo(currentLineId) == 0 ))
        {
          if (cachedShipment.getShipmentNumber() != null)
          {
            tempNum = cachedShipment.getShipmentNumber();
          }
        }  
      }

      // Now check the database if the line EO isn't new (if it is, we haven't
      // saved it so we can't have shipments in the database)

      if (getEntityState() != STATUS_NEW)
      {     
        PurchaseOrderEntityExpert poExpert = 
          PurchaseOrderHeaderEOImpl.getPurchaseOrderEntityExpert(getOADBTransaction());   

        MaxPoShipVVOImpl maxShipVO = 
          (MaxPoShipVVOImpl)poExpert.findValidationViewObject("MaxPoShipVVO1");
        maxShipVO.initQuery(getLineId());

        if (maxShipVO != null)
        {
          if (maxShipVO.first().getAttribute(0) != null)
          {
            tempNum = (Number)maxShipVO.first().getAttribute(0);
          }
        }
      }
      
      if (tempNum.compareTo(mMaxShipNum) == 1)
      {
       setMaxShipNum(tempNum);
      }
    }
    
    return mMaxShipNum;
    
  } // end getMaxShipNum()


  /*
   *****************************************************************************
   * Increments the maximum shipment number
   * <p>
   * @return current maximum shipment number + 1
   *****************************************************************************
   */
  public Number getNextShipNum()
  {  
    Number currentMaxShipNum = getMaxShipNum(); 

    resetShipNum(currentMaxShipNum.add(new Number(1)));
    
    return mMaxShipNum;
    
  } // end getNextShipNum()


  /*
   *****************************************************************************
   * Resets the maximum shipment number whenever the newShipNum > current maximum.
   * <p>
   * @param  newShipNum  the value to be compared against the current mMaxShipNum 
   * for this purchase order line.
   *****************************************************************************
   */
  public void resetShipNum(Number newShipNum)
  {
    if (newShipNum.compareTo(getMaxShipNum()) == 1)
    {
      setMaxShipNum(newShipNum);
    } 
    
  } // end resetShipNum()


  /*
   *****************************************************************************
   * Sets the maximum shipment number for this purchase order line.
   *****************************************************************************
   */
  private void setMaxShipNum(Number shipNum)
  {
    mMaxShipNum = shipNum;
    
  } // end setMaxShipNum()


////////////////////////////////////////////////////////////////////////////////
// End implementation of Line Number handling
////////////////////////////////////////////////////////////////////////////////  


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for LineId
   *
   * Business Rules
   * Required; cannot be null
   * Cannot be updated on a committed row
   * Must be unique
   *****************************************************************************
   */
  public void setLineId(Number value)
  {
    // BC4J validates that this can be updated only on a new line, and that
    // the mandatory value cannot be null.  This code adds the additional 
    // check of only allowing an update if the value is null to prevent 
    // changes while the object is in memory.
    
    if (getLineId() != null)
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "LineId", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_LINE_ID_UPDATE"); // Message name

    }

    if (value != null)
    {

      // findByPrimaryKey() is guaranteed to check all lines.  First it checks
      // the entity cache, then it checks the database.  OK to use here since we're
      // not expecting to find a match on this sequence-generated value.

      OADBTransaction transaction = (OADBTransaction)getOADBTransaction();
      Object[] lineKey = {value};
      EntityDefImpl lineDefinition = PurchaseOrderLineEOImpl.getDefinitionObject();
      PurchaseOrderLineEOImpl line = 
        (PurchaseOrderLineEOImpl)lineDefinition.findByPrimaryKey(transaction, new Key(lineKey));

      if (line != null)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "LineId", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_LINE_ID_UNIQUE"); // Message name 
      }
    }  
    
    setAttributeInternal(LINEID, value);
    
   }  // end setLineId()
  

  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for UnitOfMeasure
   *
   * Business Rules:
   * Required; cannot be null.
   * Must be a valid UOM
   *****************************************************************************
   */
  public void setUnitOfMeasure(String value)
  {
     // BC4J will validate that this mandatory attribute is not null.
     
     if ((value != null) || (!("".equals(value.trim()))))
     {
       // For the tutorial, we have implemented UOM as a lookup code...
    
       PurchaseOrderEntityExpert poExpert = 
         PurchaseOrderHeaderEOImpl.getPurchaseOrderEntityExpert(getOADBTransaction());

       if (!(poExpert.isLookupCodeValid(value, "FWK_TBX_UNIT_OF_MEASURE")))
       {
         throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                    getEntityDef().getFullName(), // EO name
                                    getPrimaryKey(), // EO PK
                                    "PaymentTermsCode", // Attribute Name
                                    value, // Attribute value
                                    "FND", // Message product short name
                                    "FWK_TBX_T_PTC_VALID"); // Message name
       }
     }  
     
    setAttributeInternal(UNITOFMEASURE, value);
    
  } // end setUnitOfMeasure()
  
  
////////////////////////////////////////////////////////////////////////////////
// Begin implementation of Extended Line Total handling
//
// Adapted from Requisition prototype...
////////////////////////////////////////////////////////////////////////////////


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for Quantity
   * 
   * Business Rules
   * Required; cannot be null
   * Must be > 0
   *****************************************************************************
   */
  public void setQuantity(Number value)
  {
    // BC4J will validate this mandatory attribute to ensure it's not null.
    
    if (value != null)
    {
      // Verify value is > 0
    
      if ( value.compareTo(0) <= 0)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "Quantity", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_QTY_MIN"); // Message name
      }

      // Did the value change?
      
      Number oldQuant = ((getQuantity() == null) ? new Number(0) : getQuantity());
    
      if (!oldQuant.equals(value)) 
      {
        // This must be called before setAttributeInternal()
        Number delta = calcLineTotalDelta("quantity", value);
        applyDeltaToOrderTotal(delta);
      }  
    }  
    
    setAttributeInternal(QUANTITY, value);

    // Must be called after setAttributeInternal()
    
    resetLineTotal();

    // Now update the shipment quantity (in this verion of the tutorial, we
    // don't support multiple shipments for the line yet so we simply set the
    // shipment quantity to equal whatever the line's quantity is.  In the 
    // future, the ability to split line quantity across multiple shipments
    // will be implemented).

    RowIterator shipmentIterator = getPurchaseOrderShipmentEO();

    if (shipmentIterator != null)
    {
      PurchaseOrderShipmentEOImpl shipment = 
        (PurchaseOrderShipmentEOImpl)shipmentIterator.first();

      if(shipment != null)         
        shipment.setOrderQuantity(value); 

     // In this release we should have only 1 shipment.  If we have more
     // than 1, throw a "too many shipments" error.
        
     if (shipmentIterator.hasNext())
     {
        throw new OARowValException(OARowValException.TYP_ENTITY_OBJECT,
                                    getEntityDef().getFullName(),
                                    getPrimaryKey(),
                                    "FND", // Message product short name
                                    "FWK_TBX_T_MANY_SHIPMENTS");   // Message name

      }
    }    
    
  } // end setQuantity()


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for UnitPrice
   *
   * Business Rules
   * Required; cannot be null
   * Must be >= 0
   *****************************************************************************
   */
  public void setUnitPrice(Number value)
  {
    // BC4J will validate that this mandatory attribute is not null
    
    if (value != null)
    {   
      // Verify value is >= 0
    
      if (value.compareTo(0) < 0)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "UnitPrice", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_UNITPRICE_MIN"); // Message name

      }
      //Bug 5255988 - Added Maximum Limit check for UnitPrice field.
      else if (value.compareTo(10000) > 0)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "UnitPrice", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_UNITPRICE_MAX"); // Message name

      }      
      // Did the value change?
      
      Number oldPrice = ((getUnitPrice() == null) ? new Number(0) : getUnitPrice());
    
      if (!oldPrice.equals(value)) 
      {
        // This must be called before setAttributeInternal()
        
        Number delta = calcLineTotalDelta("unitPrice", value);
        applyDeltaToOrderTotal(delta);
      } 
    }  

    setAttributeInternal(UNITPRICE, value);

    // Must be called after setAttributeInternal()
    
    resetLineTotal(); 
    
  } // end setUnitPrice()

  /*
   *****************************************************************************
   * Calculate the difference between the old line total and the new.  Called
   * whenever the unit price or quantity values are set.
   *****************************************************************************
   */
  private Number calcLineTotalDelta(String changedValueType, Number newValue)
  {
    Number delta = new Number(0);

    Number oldQuantity = ((getQuantity() == null) ? new Number(0) : getQuantity());
    Number oldUnitPrice = ((getUnitPrice() == null) ? new Number(0) : getUnitPrice());
    Number oldLineTotal = null;

    oldLineTotal = (Number)oldQuantity.multiply(oldUnitPrice);

    newValue = ((newValue == null) ? new Number(0) : newValue);

    Number newLineTotal = null;
    
    if ("quantity".equals(changedValueType))
    {
       newLineTotal = (Number)newValue.multiply(oldUnitPrice); 
    } 
    else if ("unitPrice".equals(changedValueType)) 
    {
       newLineTotal = (Number)newValue.multiply(oldQuantity);
    }

    delta = (Number)newLineTotal.subtract(oldLineTotal);
    
    return delta;

  } // end calcLineTotalDelta()

  /*
   *****************************************************************************
   * Applies the new delta line total to the header's running order total.
   *****************************************************************************
   */
  private void applyDeltaToOrderTotal(Number delta)
  {
     if (!delta.equals(new Number(0)))
     {
       PurchaseOrderHeaderEOImpl hdrEO = getPurchaseOrderHeaderEO();
       hdrEO.updateOrderTotal(delta);
     }

  } // end applyDeltaToOrderTotal()

  /*
   *****************************************************************************
   * Sets the calculated line total value.
   *****************************************************************************
   */
  private void resetLineTotal()
  {
    Number quantity = ((getQuantity() == null) ? new Number(0) : getQuantity());
    Number price = ((getUnitPrice() == null) ? new Number(0) : getUnitPrice());
    
    setLineTotal(quantity.multiply(price));

  } // end resetLineTotal()
  

  /*
   ***************************************************************************** 
   * Gets the attribute value for LineTotal, using the alias name LineTotal
   *****************************************************************************
   */
  public Number getLineTotal()
  {
    Number lineTotal = (Number)getAttributeInternal(LINETOTAL); 

    // We have a row that we've queried from the database, so we need to initialize
    // the extended line total.
    
    if ((lineTotal == null) && (getEntityState()!= STATUS_NEW))
    {
      resetLineTotal();
      lineTotal = (Number)getAttributeInternal(LINETOTAL); 
    }
       
    return lineTotal;
    
  } // end getLineTotal()


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for LineTotal
   *****************************************************************************
   */
  public void setLineTotal(Number value)
  {
    setAttributeInternal(LINETOTAL, value);
    
  } // end setLineTotal()
  


////////////////////////////////////////////////////////////////////////////////
//
// End implementation of Extended Line Total handling
//
////////////////////////////////////////////////////////////////////////////////
  

  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for ItemId
   *****************************************************************************
   */
  public void setItemId(Number value)
  {

/*
** DEBUG -- add for next version of tutorial
*/    
   
    setAttributeInternal(ITEMID, value);
    
  } // end setItemId()


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for ItemDescription
   *
   * Business Rules
   * Required; cannot be null
   * If an item id is specified, this must be the item's description
   *****************************************************************************
   */
  public void setItemDescription(String value)
  {

/*
** DEBUG -- add for next version of tutorial
*/   
    setAttributeInternal(ITEMDESCRIPTION, value);
    
  } // end setItemDescription()
  

//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here
//  ---------------------------------------------------------------

  /**
   * 
   * Gets the attribute value for HeaderId, using the alias name HeaderId
   */
  public Number getHeaderId()
  {
    return (Number)getAttributeInternal(HEADERID);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for HeaderId
   */
  public void setHeaderId(Number value)
  {
    setAttributeInternal(HEADERID, value);
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
   * Gets the attribute value for LineNumber, using the alias name LineNumber
   */
  public Number getLineNumber()
  {
    return (Number)getAttributeInternal(LINENUMBER);
  }



































































  private static oracle.apps.fnd.framework.server.OAEntityDefImpl mDefinitionObject;

    /**
   * 
   * This is the default constructor (do not remove)
   */
  public PurchaseOrderLineEOImpl()
  {
  }


    /**Retrieves the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        if (mDefinitionObject == null) {
            mDefinitionObject =
                    (OAEntityDefImpl)EntityDefImpl.findDefObject("oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderLineEO");
        }
        return mDefinitionObject;
    }

    /**
     *
     * Gets the attribute value for ItemId, using the alias name ItemId
     */
    public Number getItemId()
  {
    return (Number)getAttributeInternal(ITEMID);
  }


  /**
   * 
   * Gets the attribute value for ItemDescription, using the alias name ItemDescription
   */
  public String getItemDescription()
  {
    return (String)getAttributeInternal(ITEMDESCRIPTION);
  }


  /**
   * 
   * Gets the attribute value for UnitOfMeasure, using the alias name UnitOfMeasure
   */
  public String getUnitOfMeasure()
  {
    return (String)getAttributeInternal(UNITOFMEASURE);
  }


  /**
   * 
   * Gets the attribute value for Quantity, using the alias name Quantity
   */
  public Number getQuantity()
  {
    return (Number)getAttributeInternal(QUANTITY);
  }


  /**
   * 
   * Gets the attribute value for UnitPrice, using the alias name UnitPrice
   */
  public Number getUnitPrice()
  {
    return (Number)getAttributeInternal(UNITPRICE);
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
        case LINEID:
            return getLineId();
        case HEADERID:
            return getHeaderId();
        case LINENUMBER:
            return getLineNumber();
        case ITEMID:
            return getItemId();
        case ITEMDESCRIPTION:
            return getItemDescription();
        case UNITOFMEASURE:
            return getUnitOfMeasure();
        case QUANTITY:
            return getQuantity();
        case UNITPRICE:
            return getUnitPrice();
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
        case LINETOTAL:
            return getLineTotal();
        case PURCHASEORDERSHIPMENTEO:
            return getPurchaseOrderShipmentEO();
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
        case LINEID:
            setLineId((Number)value);
            return;
        case HEADERID:
            setHeaderId((Number)value);
            return;
        case LINENUMBER:
            setLineNumber((Number)value);
            return;
        case ITEMID:
            setItemId((Number)value);
            return;
        case ITEMDESCRIPTION:
            setItemDescription((String)value);
            return;
        case UNITOFMEASURE:
            setUnitOfMeasure((String)value);
            return;
        case QUANTITY:
            setQuantity((Number)value);
            return;
        case UNITPRICE:
            setUnitPrice((Number)value);
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
        case LINETOTAL:
            setLineTotal((Number)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }



  /**
   * 
   * Gets the associated entity PurchaseOrderHeaderEOImpl
   */
  public PurchaseOrderHeaderEOImpl getPurchaseOrderHeaderEO()
  {
    return (PurchaseOrderHeaderEOImpl)getAttributeInternal(PURCHASEORDERHEADEREO);
  }

  /**
   * 
   * Sets <code>value</code> as the associated entity PurchaseOrderHeaderEOImpl
   */
  public void setPurchaseOrderHeaderEO(PurchaseOrderHeaderEOImpl value)
  {
    setAttributeInternal(PURCHASEORDERHEADEREO, value);
  }


  /**
   * 
   * Gets the associated entity oracle.jbo.RowIterator
   */
  public RowIterator getPurchaseOrderShipmentEO()
  {
    return (RowIterator)getAttributeInternal(PURCHASEORDERSHIPMENTEO);
  }


    /**Creates a Key object based on given key constituents
     */
    public static Key createPrimaryKey(Number lineId) {
        return new Key(new Object[]{lineId});
    }
}
