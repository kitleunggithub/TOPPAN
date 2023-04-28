/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |       16-APR-02  L Lyons  Created based on the Requisition prototype      |
 |                           RequisitionHeaderEOImpl class plus inputs       |
 |                           from the Framework development team.            |
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
 * EO Table:  FWK_TBX_PO_HEADERS
 * EO Child:  FWK_TBX_PO_LINES (PurchaseOrderLineEOImpl)
 */
public class PurchaseOrderHeaderEOImpl extends OAEntityImpl implements Approvable
{
  // Mandatory for Applications source control
    public static final int HEADERID = 0;
    public static final int DESCRIPTION = 1;
    public static final int STATUSCODE = 2;
    public static final int SUPPLIERID = 3;
    public static final int SUPPLIERSITEID = 4;
    public static final int CURRENCYCODE = 5;
    public static final int BUYERID = 6;
    public static final int PAYMENTTERMSCODE = 7;
    public static final int CARRIERCODE = 8;
    public static final int SHIPTOADDRESSID = 9;
    public static final int BILLTOADDRESSID = 10;
    public static final int RATE = 11;
    public static final int LASTUPDATEDATE = 12;
    public static final int LASTUPDATEDBY = 13;
    public static final int CREATIONDATE = 14;
    public static final int CREATEDBY = 15;
    public static final int LASTUPDATELOGIN = 16;
    public static final int ATTRIBUTECATEGORY = 17;
    public static final int ATTRIBUTE1 = 18;
    public static final int ATTRIBUTE2 = 19;
    public static final int ATTRIBUTE3 = 20;
    public static final int ATTRIBUTE4 = 21;
    public static final int ATTRIBUTE5 = 22;
    public static final int ATTRIBUTE6 = 23;
    public static final int ATTRIBUTE7 = 24;
    public static final int ATTRIBUTE8 = 25;
    public static final int ATTRIBUTE9 = 26;
    public static final int ATTRIBUTE10 = 27;
    public static final int ATTRIBUTE11 = 28;
    public static final int ATTRIBUTE12 = 29;
    public static final int ATTRIBUTE13 = 30;
    public static final int ATTRIBUTE14 = 31;
    public static final int ATTRIBUTE15 = 32;
    public static final int ORDERTOTAL = 33;
    public static final int CONFIRMFLAG = 34;
    public static final int KFF1_ANCHORATTRIBUTE = 35;
    public static final int PURCHASEORDERLINEEO = 36;
    public static final int EMPLOYEEEO = 37;
    public static final int SUPPLIEREO = 38;
    public static final String RCS_ID="$Header: PurchaseOrderHeaderEOImpl.java 120.8 2006/07/15 12:36:00 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");
    public static final int SUPPLIERSITEEO = 39;
    public static final int MAXLINENUM = 40;


    /*
   *****************************************************************************
   * Contains the greatest line number based on all the order lines
   * belonging to this Header. This variable contains a default value of
   * -1 to indicate that the variable has not yet been initialized.
   * <p>
   * @see  #getMaxLineNum  getMaxLineNum()
   *****************************************************************************
   */
   //Bug#5258692. Below transient attribute is removed from this class. If 
   //passivation is enabled, its value will be defaulted to -1 everytime 
  //activation happens. This causes AttrValException in 'Add Another Row' 
  //operations. Hence, a transient EO Attribute is used instead of this.
  //private transient Number mMaxLineNum = new Number(-1);
  

  /*
   *****************************************************************************
   *  Marks all the lines for deletion, then mark the header for deletion.
   *  You can delete a purchase order only if it is "In Process" or "Rejected."
   *****************************************************************************
   */
  public void remove()
  {
    String status = getStatusCode();
    
    if (("IN_PROCESS".equals(status)) || ("REJECTED".equals(status)))
    {    
      // Note this is a good use of the header -> liness association since we
      // want to call remove( ) on each line.

      RowIterator linesIterator = getPurchaseOrderLineEO();

      if (linesIterator != null)
      {
        PurchaseOrderLineEOImpl line = null;
      
        while (linesIterator.hasNext())
        {
          line = (PurchaseOrderLineEOImpl)linesIterator.next();
          line.remove();
        }
      }   
      super.remove();  // Must be called last in this case.
    }
    else 
    {
      throw new OARowValException(OARowValException.TYP_ENTITY_OBJECT,
                                  getEntityDef().getFullName(),
                                  getPrimaryKey(),
                                  "AK", // Message product short name
                                  "FWK_TBX_T_PO_NO_DELETE"); // Message name
    }

  } // end remove()


  /*
   *****************************************************************************
   * Initializes a new purchase order header.
   *****************************************************************************
   */
  public void create(AttributeList attributeList)
  {
    
	super.create(attributeList);

    OADBTransaction transaction = (OADBTransaction)getOADBTransaction();
    
    // DEFAULT: HeaderId
    Number headerId = transaction.getSequenceValue("FWK_TBX_PO_HEADERS_S");   
    setHeaderId(headerId);

    // DEFAULT: StatusCode
    setStatusCode("IN_PROCESS");

    // DEFAULT:  buyerId (hard-code for tutorial to make data entry easier)
//    setBuyerId(new Number(6));

    // DEFAULT: starting line number
    setMaxLineNum(new Number(0));

    // DEFAULT:  set required bill-to and ship-to addresses.  For simplicity, the
	  // tutorial doesn't currently surface these to the user, so we will just 
	  // hard-code this for now with seeded values.  Ordinarily, these would default 
	  // based on some Purchasing system defaults.

    setBillToAddressId(new Number(7)); // Bill to "HQ"
	  setShipToAddressId(new Number(8)); // Ship to "Manufacturing"

    // DEFAULT:  set the currency code to "USD" for the first release of the 
	  // tutorial.  We don't yet support foreign currency POs.
    setCurrencyCode("USD");

 
  } // end create()


  /*
   *****************************************************************************
   *  Convenience method returns the PurchaseOrderEntityExpert.
   *****************************************************************************
   */
  public static PurchaseOrderEntityExpert getPurchaseOrderEntityExpert(OADBTransaction txn)
  {       
    return (PurchaseOrderEntityExpert)txn.getExpert(PurchaseOrderHeaderEOImpl.getDefinitionObject());  
    
  } // end getPurchaseOrderEntityExpert()
    

  /*
   *****************************************************************************
   * Performs entity-level validation including cross-attribute validation that
   * is not appropriately performed in a single attribute setter.
   *****************************************************************************
   */
  protected void validateEntity()
  {
    super.validateEntity();

    // If our supplier value has changed, verify that the order is in an "IN_PROCESS"
    // or "REJECTED" state.  Changes to the supplier in any other state are disallowed.  
    // Note that these checks for supplier and site are both performed here
    // because they are doing cross-attribute validation.

    String status = getStatusCode();

    if ((("APPROVED").equals(status)) || ("COMPLETED".equals(status)))
    {
      // Start by getting the original value and comparing it to the current
      // value.  Changes at this point are invalid.
      
      Number oldSupplierId = (Number)getPostedAttribute(SUPPLIERID);
      Number currentSupplierId = getSupplierId();

      if (oldSupplierId.compareTo(currentSupplierId) != 0)
      {
       throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "SupplierId", // Attribute Name
                                   currentSupplierId, // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_PO_SUPPLIER_NOUPDATE"); // Message name
      }

      // If our supplier site has changed, verify that the order is in an "IN_PROCESS"
      // state.  Changes to the supplier site in any other state are disallowed.
      
      Number oldSiteId = (Number)getPostedAttribute(SUPPLIERSITEID);
      Number currentSiteId = getSupplierSiteId();

      if (oldSiteId.compareTo(currentSiteId) != 0)
      {
  
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "SupplierId", // Attribute Name
                                   currentSiteId, // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_PO_SUPSITE_NOUPDATE"); // Message name
      }
    }  
   

    // Verify that our supplier site is valid for the supplier and make sure it is
	  // an active "Purchasing" site.

    SupplierEntityExpert supplierExpert = 
      SupplierEOImpl.getSupplierEntityExpert(getOADBTransaction());

    if (!(supplierExpert.isSiteValidForPurchasing(getSupplierId(), getSupplierSiteId())))
	  {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "SupplierSiteId", // Attribute Name
                                   getSupplierSiteId(), // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_PO_SUPSITE_INVALID"); // Message name
    }

  } // end validateEntity();



  /*
   *****************************************************************************
   * Performs last-minute validation before the purchase order is posted to the 
   * database. This gives us the opportunity to verify that the PO has at least one 
   * associated line since a PO cannot be committed without at least 1 line.
   *****************************************************************************
   */
  public void postChanges(TransactionEvent e)
  {
    if(getPostState()!=STATUS_DELETED)
      checkLineExists();
    super.postChanges(e);
    
  } // end postChanges()


  /*
   *****************************************************************************
   *	Ensures that the purchase order has at least one associated line.
   *****************************************************************************
   */
  private void checkLineExists()
  { 
    // A purchase order header must have at least 1 associated line.
	  // To check this, we first do a manual check of the entity cache
    // If we find a line for this header, we're done (note that the entity cache won't
    // include EOs that are DELETED or DEAD).

    com.sun.java.util.collections.Iterator fastIterator = 
        PurchaseOrderLineEOImpl.getDefinitionObject().getAllEntityInstancesIterator(getDBTransaction());

    Number currentHeaderId = getHeaderId();

    while ( fastIterator.hasNext() )
    {
      PurchaseOrderLineEOImpl cachedLine = (PurchaseOrderLineEOImpl)fastIterator.next();

      Number cachedHeaderId = cachedLine.getHeaderId();

      // If we find a match, we're done. Don't forget to look ONLY for lines
      // for this header... The entity cache can include lines for other headers
      // also.
        
      if ((cachedHeaderId != null) && (cachedHeaderId.compareTo(currentHeaderId) == 0 ))
      {
        return;
      } 
    }

    // We haven't found any matches in the cache yet, so now we need to check
    // the database...
    
    // In this example, we're illustrating the use of the association between the 
    // header and its lines to iterate through all the shipments.  This will
    // check both the cache and the database, and will bring all the rows
    // into the middle tier.
    // Note that this looks only at lines for this
    // header so we don't need to filter our results, so it is convenient.

    RowIterator linesIterator = getPurchaseOrderLineEO();
 
    if (!(linesIterator.hasNext()))
	  {
      throw new OARowValException(OARowValException.TYP_ENTITY_OBJECT,
                                  getEntityDef().getFullName(),
                                  getPrimaryKey(),
                                  "AK", // Message product short name
                                  "FWK_TBX_T_PO_NO_LINES");   // Message name

    }
    
  }  // end checkLineExists()


////////////////////////////////////////////////////////////////////////////////
// Start of Approval Handling
////////////////////////////////////////////////////////////////////////////////


  /*
   *****************************************************************************
   * Tries to approve the purchase order.  Performs validation to determine
   * whether moving to an "Approved" state is appropriate based on the
   * current state.
   *****************************************************************************
   */
  public void approve()
  {
    ApprovalManager mgr = 
      ApprovalManagerFactory.getApprovalManager(ApprovalManagerFactory.PO);
      
    try
    {
      mgr.doApprove(this);  
    }
    catch (OAException e)
    {      
      String messageName = e.getMessageName();
      String productCode = e.getProductCode();
      
      throw new OARowValException(OARowValException.TYP_ENTITY_OBJECT,
                                  getEntityDef().getFullName(),
                                  getPrimaryKey(),
                                  productCode, // Message product short name
                                  messageName); // Message name

    }
  } // end approve()


  /*
   *****************************************************************************
   * Tries to reject the purchase order.  Performs validation to determine
   * whether moving to an "Approved" state is appropriate based on the
   * current state.
   *****************************************************************************
   */
  public void reject()
  {
    ApprovalManager mgr = 
      ApprovalManagerFactory.getApprovalManager(ApprovalManagerFactory.PO);
    mgr.doReject(this);  

  } // end reject()


  /*
   *****************************************************************************
   * Returns the approval state of the purchase order.
   *****************************************************************************
   */
  public String getApprovalStatus()
  {
    return getStatusCode();

  } // end getApprovalStatus()


  /*
   *****************************************************************************
   * Updates the purchase order to "Approved" if this is valid
   * state transition.
   *****************************************************************************
   */
  public void setApproved() 
  {
    setStatusCode("APPROVED");
    
  } // end setApproved()


  /*
   *****************************************************************************
   * Updates the purchase order to "Rejected" if this is a valid
   * state transition.
   *****************************************************************************
   */
  public void setRejected() 
  {
    setStatusCode("REJECTED");
    
  } // end setRejected()


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for StatusCode
   *****************************************************************************
   */
  public void setStatusCode(String value)
  {
    // BC4J ensures that this mandatory value is non-null.

    if ((value != null) || (!("".equals(value.trim()))))
    {
      // Make sure that we are doing a valid state transition.
       
      checkStateTransition(value);
    
      PurchaseOrderEntityExpert poExpert = 
        getPurchaseOrderEntityExpert(getOADBTransaction());

      if (!(poExpert.isLookupCodeValid(value, "FWK_TBX_ORDER_STATUS")))
       {
         throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                    getEntityDef().getFullName(), // EO name
                                    getPrimaryKey(), // EO PK
                                    "StatusCode", // Attribute Name
                                    value, // Attribute value
                                    "AK", // Message product short name
                                    "FWK_TBX_T_PO_STATCODE_INVALID"); // Message name
       }
    } 
	  
    setAttributeInternal(STATUSCODE, value);
    
  } // end setStatusCode()

 /*
  ******************************************************************************
  * Checks whether the transition from the current state to a new state is
  * valid.
  ******************************************************************************
  */
 private void checkStateTransition(String newState)
 {
   // Note: this is a simplified illustration of what is potentially very
   // complex.  Like the approval handling, this is a candidate for 
   // implementation by a helper class -- particularly if the the state
   // checks can be shared by multiple related EO types.  Note if 
   // you did something like this, you wouldn't include low-level attribute
   // exceptions as we've done below.
   
   String currentState = getStatusCode();

   if ("APPROVED".equals(newState))
   {
     // Check good states first; most common case.
     
     if (("IN_PROCESS".equals(currentState)) ||
        ("REJECTED".equals(currentState)))
     {
       return;
     }
     if ("COMPLETE".equals(currentState))
     {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                    getEntityDef().getFullName(), // EO name
                                    getPrimaryKey(), // EO PK
                                    "StatusCode", // Attribute Name
                                    newState, // Attribute value
                                    "AK", // Message product short name
                                    "FWK_TBX_T_PO_APP_COMP"); // Message name
     }
     else if ("APPROVED".equals(currentState))
     {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                    getEntityDef().getFullName(), // EO name
                                    getPrimaryKey(), // EO PK
                                    "StatusCode", // Attribute Name
                                    newState, // Attribute value
                                    "AK", // Message product short name
                                    "FWK_TBX_T_PO_APP_APP"); // Message name  
     }
   }
   
   // Note that similar code would have to be written for all possible
   // state transitions. This is all we need for the simple tutorial as is.
   
 } // end checkStateTransition()

////////////////////////////////////////////////////////////////////////////////
// End of Approval Handling
////////////////////////////////////////////////////////////////////////////////

  /*
   *****************************************************************************
   * Sets the PO Header Id.
   *
   * Business Rules:
   * Required; cannot be null.
   * Cannot be updated on a committed row.
   *****************************************************************************
   */
  public void setHeaderId(Number value)
  {
    // BC4J validates that this can be updated only on a new line.  This
    // adds the additional check of only allowing an update if the value
    // is null to prevent changes while the object is in memory.

    //Bug 5254600 - Added new message FWK_TBX_T_HEADER_ID_UPDATE
    if (getHeaderId() != null)
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "HeaderId", // Attribute Name
                                   value, // Attribute value
                                   "FND", // Message product short name
                                   "FWK_TBX_T_HEADER_ID_UPDATE"); // Message name
    }

    if (value != null)
    {

      OADBTransaction transaction = (OADBTransaction)getOADBTransaction();

      // findByPrimaryKey() is guaranteed to first check the entity cache, then check
	    // the database.  This is an appropriate use of this method because finding a 
	    // match would be the exception rather than the rule so we're not worried 
      // about pulling entities into the middle tier.
    
      Object[] headerKey = {value};
      EntityDefImpl hdrDef = PurchaseOrderHeaderEOImpl.getDefinitionObject();
      PurchaseOrderHeaderEOImpl hdrEO = 
        (PurchaseOrderHeaderEOImpl)hdrDef.findByPrimaryKey(transaction, new Key(headerKey));

      if (hdrEO != null)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "HeaderId", // Attribute Name
                                   value, // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_PO_ID_UNIQUE"); // Message name
 
      }
    }
    
    setAttributeInternal(HEADERID, value);
    
  } // end setHeaderId()


  /*
   *****************************************************************************
   * Sets the supplier id.
   *
   * Business Rules:
   * Required; value cannot be null.
   * Can only be changed on a PO with an IN_PROCESS  or REJECTED state.
   * Must be an active supplier, not on Purchasing hold.
   *****************************************************************************
   */
  public void setSupplierId(Number value)
  {
    if (value != null)
    {
      // Test to see if the supplier Id is valid.  To do this, we call a special
	    // check on the Supplier Entity Objects "Expert" singleton.

      SupplierEntityExpert supplierExpert = 
        SupplierEOImpl.getSupplierEntityExpert(getOADBTransaction());
      
      if (!(supplierExpert.isSupplierValidForPurchasing(value)))
	    {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "SupplierId", // Attribute Name
                                   value, // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_PO_SUPPLIER_INVALID"); // Message name
      }
    }  
     
    setAttributeInternal(SUPPLIERID, value);
    
  } // end setSupplierId()
  


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for SupplierSiteId
   * 
   * Business Rules
   * Required; cannot be null.
   * Can only be changed on a PO whose state is IN_PROCESS or REJECTED
   * Must be an active "Purchasing" site
   *****************************************************************************
   */
  public void setSupplierSiteId(Number value)
  {
    // BC4J ensures this mandatory attribute is non-null.

    setAttributeInternal(SUPPLIERSITEID, value);
    
  } // end setSupplierSiteId()


////////////////////////////////////////////////////////////////////////////////
// Begin implementation of Line Number handling
//
// Adapted from Requisition prototype...
////////////////////////////////////////////////////////////////////////////////


  /*
   *****************************************************************************
   * Gets the maximum lineNum for this purchase order header.
   * If {@link #mMaxLineNum} has not been initialized yet, find the maximum
   * line number in the database.
   * <p>
   * @return maximum line number
   *****************************************************************************
   */
  public Number getMaxLineNum()
  {
    OADBTransaction transaction = (OADBTransaction)getOADBTransaction();

    // mMaxLineNum is in its initial state, so we need to check and 
    // see if we have lines in both the entity cache and in the
    // database to find the current maximum.

    Number mMaxLineNum = (Number)getAttributeInternal(MAXLINENUM);
    if (mMaxLineNum == null || mMaxLineNum.equals(new Number(-1)))
    {
      Number tempNum = new Number(0);

      com.sun.java.util.collections.Iterator fastCacheIterator = 
        PurchaseOrderLineEOImpl.getDefinitionObject().getAllEntityInstancesIterator(getDBTransaction());
 
      while (fastCacheIterator.hasNext())
      {
        PurchaseOrderLineEOImpl cachedLine = (PurchaseOrderLineEOImpl)fastCacheIterator.next();

        Number currentHeaderId = getHeaderId();
        Number cachedHeaderId = cachedLine.getHeaderId();

        // If we find a match for this line, check the shipment number.  Remember
        // that the cache includes shipments for many lines.
        
        if ((cachedHeaderId != null) && (cachedHeaderId.compareTo(currentHeaderId) == 0 ))
        {
          tempNum = cachedLine.getLineNumber();  

          // resetLineNum( ) will test the value to see if it's the current max,
          // and if it is, set it on our private EO transient attribute.
        
          if (tempNum != null)
          {
            resetLineNum(tempNum);
          }
        }
      }  

      // Now check the database if the header EO isn't new (if it is, we haven't
      // saved it so we can't have a line in the database)

      if (getEntityState() != STATUS_NEW)
      {     
        PurchaseOrderEntityExpert poExpert = getPurchaseOrderEntityExpert(transaction);
 
        MaxPoLineVVOImpl maxLineVO = 
          (MaxPoLineVVOImpl)poExpert.findValidationViewObject("MaxPoLineVVO1");
        maxLineVO.initQuery(getHeaderId());

        if (maxLineVO != null)
        {
          tempNum = (Number)maxLineVO.first().getAttribute(0);
          
          if (tempNum != null)
          {
            resetLineNum(tempNum);
          }
        }
      }
    }
    
    return (Number)getAttributeInternal(MAXLINENUM);
  
  } // end getMaxLineNum()


  /*
   *****************************************************************************
   * Increments the maximum lineNum.
   * <p>
   * @return current maximum lineNum + 1
   *****************************************************************************
   */
  public Number getNextLineNum()
  {  
    Number currentMaxLineNum = getMaxLineNum(); 

    resetLineNum(currentMaxLineNum.add(new Number(1)));
    
    return getMaxLineNum();
    
  } // end getNextLineNum()


  /*
   *****************************************************************************
   * Resets the maximum line number whenever newLineNum > mMaxLineNum.
   * <p>
   * @param  newLineNum  the value to be compared against the current 
   * mMaxLineNum for this purchase order.
   *****************************************************************************
   */
  public void resetLineNum(Number newLineNum)
  {
    Number mMaxLineNum = (Number)getAttributeInternal(MAXLINENUM);
    
    if (newLineNum.compareTo(mMaxLineNum) == 1)
    {
      setMaxLineNum(newLineNum);
    } 
    
  } // end resetLineNum()


 /*
  ******************************************************************************
  * Sets the maximum line number for this purchase order header.
  * <p>
  * @param  lineNum the maximum line found based on all po lines for this header
  ******************************************************************************
  */
  private void setMaxLineNum(Number lineNum)
  {
     setAttributeInternal(MAXLINENUM, lineNum);
    
  } // end setMaxLineNum()


////////////////////////////////////////////////////////////////////////////////
// End implementation of Line Number handling
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// Begin implementation of Order Total handling
//
// Adapted from the Requisition prototype
////////////////////////////////////////////////////////////////////////////////

  /*
   *****************************************************************************
   * Gets the attribute value for OrderTotal.  If an Order Total has not been
   * calculated yet for the Entity Object, this will initialize the value
   * by summing the product of line quantity and price in the database.
   *****************************************************************************
   */
  public Number getOrderTotal()
  {   
    Number orderTotal = (Number)getAttributeInternal(ORDERTOTAL);

    if (orderTotal == null)
    {

     // Get the sume of price * quantity for all lines in the database

     PurchaseOrderEntityExpert poExpert = getPurchaseOrderEntityExpert(getOADBTransaction());
     
      OrderTotalVVOImpl orderTotalVO = 
        (OrderTotalVVOImpl)poExpert.findValidationViewObject("OrderTotalVVO1");
      orderTotalVO.initQuery(getHeaderId());

      if (orderTotalVO != null)
      {
        orderTotal = (Number)orderTotalVO.first().getAttribute(0);
      }

      // If we don't have any lines yet (for some odd reason!) it's valid to
      // set the order total to 0.
      
      if (orderTotal == null)
      {
        orderTotal = new Number(0);
      }

      // Update our transient OrderTotal value.
      
      //setOrderTotal(orderTotal);
    }

    return orderTotal;
    
  } // end getOrderTotal()


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for OrderTotal
   *****************************************************************************
   */
  public void setOrderTotal(Number value)
  {
    setAttributeInternal(ORDERTOTAL, value);
    
  } // end setOrderTotal()


  /*
   *****************************************************************************
   * Adds a line total change to the order total.  Called by the lines
   * whenver their line total (UnitPrice * Quantity) changes.
   *****************************************************************************
   */
  public void updateOrderTotal(Number deltaValue)
  {
    // A line tells us what its net change is whenever its price or 
    // quantity values are changed.  We simply add this value to
    // our transient total.
    
    if (deltaValue != null)
    {
      Number currentTotal = getOrderTotal();
      
      if (currentTotal == null)
      {
        currentTotal = new Number(0);
      }
      
      setOrderTotal(currentTotal.add(deltaValue));
    }
    
  } // end updateOrderTotal()


////////////////////////////////////////////////////////////////////////////////
// End implementation of Order Total handling
////////////////////////////////////////////////////////////////////////////////


 /*
  ******************************************************************************
  * Ensures that value is not null before assigning it to BuyerId.
  * <p>
  * @param  value the value to be assigned to BuyerId
  *
  * Business Rules
  * Required; cannot be null
  * OK to update on a committed row
  * Employee must be currently active
  ******************************************************************************
  */  
  public void setBuyerId(Number value)
  {

    // BC4J ensures that this mandatory attribute has a non-null value.

    if (value != null)
    {
   
      // Now check to see if the buyer id value is valid.

      EmployeeEntityExpert employeeExpert = 
        EmployeeEOImpl.getEmployeeEntityExpert(getOADBTransaction());
      
      if (!(employeeExpert.isEmployeeActive(value)))
	    {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "BuyerId", // Attribute Name
                                   value, // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_PO_BUYER_INVALID"); // Message name
      }
    }
     
    setAttributeInternal(BUYERID, value);
    
  } // end setBuyerId()


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for PaymentTermsCode
   *
   * Business Rules
   * Required; cannot be null
   * Must be a valid payment terms code
   *****************************************************************************
   */
  public void setPaymentTermsCode(String value)
  {
    // BC4J ensures that this mandatory value is not null

    if ((value != null) || (!("".equals(value.trim()))))
    {
       // Now verify that the value is valid.
    
       PurchaseOrderEntityExpert poExpert = 
         getPurchaseOrderEntityExpert(getOADBTransaction());
      
       if (!(poExpert.isLookupCodeValid(value, "FWK_TBX_PAYMENT_TERMS")))
       {
         throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                    getEntityDef().getFullName(), // EO name
                                    getPrimaryKey(), // EO PK
                                    "PaymentTermsCode", // Attribute Name
                                    value, // Attribute value
                                    "AK", // Message product short name
                                    "FWK_TBX_T_PO_PAYTERMS_INVALID"); // Message name
       }
    }
    
    setAttributeInternal(PAYMENTTERMSCODE, value);
    
  } // end setPaymentTermsCode()


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for CarrierCode
   *
   * Business Rules:
   * Required; cannot be null.
   * Must be a valid carrier code.
   *****************************************************************************
   */
  public void setCarrierCode(String value)
  {
    // BC4J ensures that this mandatory attribute is non-null

    if ((value != null) || (!("".equals(value.trim()))))
    {   
       // Verify that the value is valid.
     
       PurchaseOrderEntityExpert poExpert = getPurchaseOrderEntityExpert(getOADBTransaction());

       if (!(poExpert.isLookupCodeValid(value, "FWK_TBX_CARRIER")))
       {
         throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                    getEntityDef().getFullName(), // EO name
                                    getPrimaryKey(), // EO PK
                                    "CarrierCode", // Attribute Name
                                    value, // Attribute value
                                    "AK", // Message product short name
                                    "FWK_TBX_T_PO_CARRIER_INVALID"); // Message name
       }
    }
    setAttributeInternal(CARRIERCODE, value);
    
  } // end setCarrierCode()


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for CurrencyCode
   *
   * Business Rules
   * Required; cannot be null
   * Cannot be updated on a committed row
   *****************************************************************************
   */
  public void setCurrencyCode(String value)
  {
    // BC4J ensures that this mandatory value is non-null.  It also ensures that
    // it is not updated on a committed row.

    if ((value != null) || (!("".equals(value.trim()))))
    {
      // Verify that the value is valid.
     
      PurchaseOrderEntityExpert poExpert = getPurchaseOrderEntityExpert(getOADBTransaction());

      if (!(poExpert.isLookupCodeValid(value, "FWK_TBX_CURRENCY")))
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                    getEntityDef().getFullName(), // EO name
                                    getPrimaryKey(), // EO PK
                                    "CurrencyCode", // Attribute Name
                                    value, // Attribute value
                                    "AK", // Message product short name
                                    "FWK_TBX_T_PO_CURRENCY_INVALID"); // Message name
      }
    }
    
    setAttributeInternal(CURRENCYCODE, value);
    
  } // end setCurrencyCode()


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for ShipToAddressId
   *
   * Business Rules:
   * Required; cannot be null
   * Must be a valid ship-to address
   *****************************************************************************
   */
  public void setShipToAddressId(Number value)
  {
    // BC4J ensures that this mandatory value is non-null.
    
	  // Since this is hard-coded for the first release of the tutorial we don't
	  // include any validation logic.
	  // If we wanted to include validation, it would follow the same model that
	  // we use for buyerId, only it would be calling an "Address" expert.

    setAttributeInternal(SHIPTOADDRESSID, value);
    
  } // end setShipToAddressId()


  /*
   ***************************************************************************** 
   * Sets <code>value</code> as the attribute value for BillToAddressId
   *
   * Business Rules:
   * Required; cannot be null
   * Must be a valid bill-to address
   *****************************************************************************
   */
  public void setBillToAddressId(Number value)
  {
    // BC4J ensures that this mandatory value is non-null.
    
	  // Since this is hard-coded for the first release of the tutorial we don't
	  // include any validation logic.
	  // If we wanted to include validation, it would follow the same model that
	  // we use for buyerId, only it would be calling an "Address" expert. 

    setAttributeInternal(BILLTOADDRESSID, value);
    
  } // end setBillToAddressId()

  
//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here...
//  ---------------------------------------------------------------



















































  private static oracle.apps.fnd.framework.server.OAEntityDefImpl mDefinitionObject;

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public PurchaseOrderHeaderEOImpl()
  {
  }


    /**Retrieves the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        if (mDefinitionObject == null) {
            mDefinitionObject =
                    (OAEntityDefImpl)EntityDefImpl.findDefObject("oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderHeaderEO");
        }
        return mDefinitionObject;
    }

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
   * Gets the attribute value for StatusCode, using the alias name StatusCode
   */
  public String getStatusCode()
  {
    return (String)getAttributeInternal(STATUSCODE);
  }


 /**
   * 
   * Gets the attribute value for SupplierId, using the alias name SupplierId
   */
  public Number getSupplierId()
  {
    return (Number)getAttributeInternal(SUPPLIERID);
  }


  /**
   * 
   * Gets the attribute value for SupplierSiteId, using the alias name SupplierSiteId
   */
  public Number getSupplierSiteId()
  {
    return (Number)getAttributeInternal(SUPPLIERSITEID);
  }


  /**
   * 
   * Gets the attribute value for CurrencyCode, using the alias name CurrencyCode
   */
  public String getCurrencyCode()
  {
    return (String)getAttributeInternal(CURRENCYCODE);
  }

  /**
   * 
   * Gets the attribute value for BuyerId, using the alias name BuyerId
   */
  public Number getBuyerId()
  {
    return (Number)getAttributeInternal(BUYERID);
  }

  /**
   * 
   * Gets the attribute value for Description, using the alias name Description
   */
  public String getDescription()
  {
    return (String)getAttributeInternal(DESCRIPTION);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Description
   */
  public void setDescription(String value)
  {
    setAttributeInternal(DESCRIPTION, value);
  }

  /**
   * 
   * Gets the attribute value for PaymentTermsCode, using the alias name PaymentTermsCode
   */
  public String getPaymentTermsCode()
  {
    return (String)getAttributeInternal(PAYMENTTERMSCODE);
  }


  /**
   * 
   * Gets the attribute value for CarrierCode, using the alias name CarrierCode
   */
  public String getCarrierCode()
  {
    return (String)getAttributeInternal(CARRIERCODE);
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
   * Gets the attribute value for BillToAddressId, using the alias name BillToAddressId
   */
  public Number getBillToAddressId()
  {
    return (Number)getAttributeInternal(BILLTOADDRESSID);
  }

  /**
   * 
   * Gets the attribute value for Rate, using the alias name Rate
   */
  public Number getRate()
  {
    return (Number)getAttributeInternal(RATE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Rate
   */
  public void setRate(Number value)
  {
    setAttributeInternal(RATE, value);
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
        case SHIPTOADDRESSID:
            return getShipToAddressId();
        case BILLTOADDRESSID:
            return getBillToAddressId();
        case RATE:
            return getRate();
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
        case ORDERTOTAL:
            return getOrderTotal();
        case CONFIRMFLAG:
            return getConfirmFlag();
        case KFF1_ANCHORATTRIBUTE:
            return getKFF1_AnchorAttribute();
        case PURCHASEORDERLINEEO:
            return getPurchaseOrderLineEO();
        case EMPLOYEEEO:
            return getEmployeeEO();
        case SUPPLIEREO:
            return getSupplierEO();
        case SUPPLIERSITEEO:
            return getSupplierSiteEO();
        case MAXLINENUM:
            return getMaxLineNum();
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
        case SHIPTOADDRESSID:
            setShipToAddressId((Number)value);
            return;
        case BILLTOADDRESSID:
            setBillToAddressId((Number)value);
            return;
        case RATE:
            setRate((Number)value);
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
        case ORDERTOTAL:
            setOrderTotal((Number)value);
            return;
        case CONFIRMFLAG:
            setConfirmFlag((String)value);
            return;
        case KFF1_ANCHORATTRIBUTE:
            setKFF1_AnchorAttribute((String)value);
            return;
        case MAXLINENUM:
            setMaxLineNum((Number)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }



  /**
   * 
   * Gets the associated entity oracle.jbo.RowIterator
   */
  public RowIterator getPurchaseOrderLineEO()
  {
    return (RowIterator)getAttributeInternal(PURCHASEORDERLINEEO);
  }


  /**
   * 
   * Gets the associated entity SupplierEOImpl
   */
  public SupplierEOImpl getSupplierEO()
  {
    return (SupplierEOImpl)getAttributeInternal(SUPPLIEREO);
  }

  /**
   * 
   * Sets <code>value</code> as the associated entity SupplierEOImpl
   */
  public void setSupplierEO(SupplierEOImpl value)
  {
    setAttributeInternal(SUPPLIEREO, value);
  }


  /**
   * 
   * Gets the associated entity EmployeeEOImpl
   */
  public EmployeeEOImpl getEmployeeEO()
  {
    return (EmployeeEOImpl)getAttributeInternal(EMPLOYEEEO);
  }

  /**
   * 
   * Sets <code>value</code> as the associated entity EmployeeEOImpl
   */
  public void setEmployeeEO(EmployeeEOImpl value)
  {
    setAttributeInternal(EMPLOYEEEO, value);
  }


  /**
   * 
   * Gets the associated entity SupplierSiteEOImpl
   */
  public SupplierSiteEOImpl getSupplierSiteEO()
  {
    return (SupplierSiteEOImpl)getAttributeInternal(SUPPLIERSITEEO);
  }

  /**
   * 
   * Sets <code>value</code> as the associated entity SupplierSiteEOImpl
   */
  public void setSupplierSiteEO(SupplierSiteEOImpl value)
  {
    setAttributeInternal(SUPPLIERSITEEO, value);
  }


  /**
   * 
   * Gets the attribute value for ConfirmFlag, using the alias name ConfirmFlag
   */
  public String getConfirmFlag()
  {
    return (String)getAttributeInternal(CONFIRMFLAG);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for ConfirmFlag
   */
  public void setConfirmFlag(String value)
  {
    setAttributeInternal(CONFIRMFLAG, value);
  }


  /**
   * 
   * Gets the attribute value for KFF1_AnchorAttribute, using the alias name KFF1_AnchorAttribute
   */
  public String getKFF1_AnchorAttribute()
  {
    return (String)getAttributeInternal(KFF1_ANCHORATTRIBUTE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for KFF1_AnchorAttribute
   */
  public void setKFF1_AnchorAttribute(String value)
  {
    setAttributeInternal(KFF1_ANCHORATTRIBUTE, value);
  }


    /**Creates a Key object based on given key constituents
     */
    public static Key createPrimaryKey(Number headerId) {
        return new Key(new Object[]{headerId});
    }
}
