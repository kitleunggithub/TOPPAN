/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |       27-MAY-02  L Lyons  Created.                                        |
 |                                                                           |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import oracle.jbo.RowSetIterator;
import oracle.jbo.Row;
import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class PoSummaryAMImpl extends OAApplicationModuleImpl {
  // Required for Applications source control
  public static final String RCS_ID="$Header: PoSummaryAMImpl.java 120.6 2006/07/04 00:50:04 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");

  /*
   *****************************************************************************
   * Deletes a purchase order.
   *****************************************************************************
   */
  public Boolean deletePurchaseOrder(String poHeaderId)
  {

    boolean rowFound = false;
    RowSetIterator deleteIter = null;
    
    try
    {
      // First, we need to find the selected purchase order in our VO.
      // When we find it, we call remove( ) on the row which in turn
      // calls remove on the associated PurchaseOrderHeaderEOImpl object.

      int poToDelete = Integer.parseInt(poHeaderId);
    
      OAViewObject vo = getPoSummaryVO1(); 
      PoSummaryVORowImpl row = null;

      // This tells us the number of rows that have been fetched in the
      // row set, and will not pull additional rows in like some of the
      // other "get count" methods.
    
      int fetchedRowCount = vo.getFetchedRowCount();

      // We use a separate iterator -- even though we could step through the
      // rows without it -- because we don't want to affect row currency.

      // This deliberately illustrates the use of an iterator.  There are also
      // convenience methods for getting rows that have certain values.  See
      // the "approve" method below for an example.
    
      deleteIter = vo.createRowSetIterator("deleteIter"); 

      if (fetchedRowCount > 0) 
      { 
        deleteIter.setRangeStart(0); 
        deleteIter.setRangeSize(fetchedRowCount); 

        for (int i = 0; i < fetchedRowCount; i++) 
        { 
          row = (PoSummaryVORowImpl)deleteIter.getRowAtRangeIndex(i); 

          // For performance reasons, we generate ViewRowImpls for all
          // View Objects.  When we need to obtain an attribute value,
          // we use the named accessors instead of a generic String lookup.
        
          // BAD CODE EXAMPLE:  Number primaryKey = (Number)row.getAttribute("HeaderId");
          // GOOD CODE EXAMPLE:
          Number primaryKey = row.getHeaderId();

           if (primaryKey.compareTo(poToDelete) == 0)
           {
              row.remove();
              rowFound = true;
              getTransaction().commit();
              break; // only one possible selected row in this case
           } 
        } 
      } 
    }
    finally
    {
      // Always close your iterators even if there are errors.  So, enclose
      // this in a finally block.
      deleteIter.closeRowSetIterator(); 
    }
    
   return (rowFound? Boolean.TRUE : Boolean.FALSE);
    
  } // end deletePurchaseOrder()


  /*
   ****************************************************************************
   * Steps through the POSimpleSummaryVO to look for selected rows.  For
   * each selected row, this calls the approve( ) method on the 
   * PurchaseOrderHeaderEOImpl class.
   *****************************************************************************
   */
  public void approvePurchaseOrder( )
  {

    // To call a custom method on an Entity Object you should add a wrapper
    // in the VO's *RowImpl class (see PoSimpleSumaryVORowImpl).
    
    PoSummaryVOImpl vo = getPoSummaryVO1(); 
    Row[] rows = vo.getFilteredRows("SelectFlag", "Y");

    // getFilteredRows returns a zero-length array if it finds no matches.
    if (rows.length == 0)
    {
      throw new OAException("AK", "FWK_TBX_T_SELECT_FOR_APPROVE");      
    }
    else
    {
       PoSummaryVORowImpl row = null;
       
       for (int i = 0; i < rows.length; i++)
       {
         // For every row with a selected checkbox, we want call
         // the approve( ) wrapper on the POSimpleSummaryVORowImpl which
         // in turn calls the approve ) method on the PurchaseOrderHeaderEOImpl.
      
         row = (PoSummaryVORowImpl)rows[i]; 
         row.approve();

       }
       
       getTransaction().commit();
    }  

  } // end approvePurchaseOrder()

  /*
   *****************************************************************************
   * Initializes the PO summary query.
   *****************************************************************************
   */
  public void init(Boolean executeQuery)
  {
     PoSummaryVOImpl vo = getPoSummaryVO1();

     if (vo == null)
     {
       MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "PoSummaryVO1") };
       throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
     }   

    // Follows Back Button standard of never performing a blind query without
    // checking to see if this is necessary.
    
    if (!vo.isPreparedForExecution())
    {
      vo.initQuery("ALL", executeQuery);
    }  
    
  } // end init()


//  ---------------------------------------------------------------
//  ---    Generated code from here...
//  ---------------------------------------------------------------

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public PoSummaryAMImpl()
  {
    
  }


  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.tutorial.server", "PoSummaryAMLocal");
  }








  /**
   * 
   * Container's getter for CarriersVO1
   */
  public OAViewObjectImpl getCarriersVO1()
  {
    return (OAViewObjectImpl)findViewObject("CarriersVO1");
  }

  /**
   * 
   * Container's getter for PaymentTermsVO1
   */
  public OAViewObjectImpl getPaymentTermsVO1()
  {
    return (OAViewObjectImpl)findViewObject("PaymentTermsVO1");
  }

  /**
   * 
   * Container's getter for PoSummaryVO1
   */
  public PoSummaryVOImpl getPoSummaryVO1()
  {
    return (PoSummaryVOImpl)findViewObject("PoSummaryVO1");
  }


}
