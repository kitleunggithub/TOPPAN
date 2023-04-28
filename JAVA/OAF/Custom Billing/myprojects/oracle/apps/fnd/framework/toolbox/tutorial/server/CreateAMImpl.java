/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import oracle.jbo.Row;
import oracle.jbo.Transaction;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;


public class CreateAMImpl extends OAApplicationModuleImpl {
  public static final String RCS_ID="$Header: CreateAMImpl.java 120.2 2006/07/03 23:21:10 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");

  /*
   *****************************************************************************
   * Commits the transaction
   *****************************************************************************
   */
  public void apply()
  {
    getTransaction().commit();
  } // end apply()

  /*
   *****************************************************************************
   * Executes a rollback including the database and the middle tier.
   *****************************************************************************
   */
  public void rollbackSupplier()
  {
    Transaction txn = getTransaction();

    if (txn.isDirty())
    {
      txn.rollback();
    }  
  } // end rollback;

  /*
   *****************************************************************************
   * Creates a new supplier.
   *****************************************************************************
   */
  public void createSupplier()
  {
    OAViewObject vo = getSuppliersVO1();

    // We need to do this on a VO that has not been queried before we insert
    // our first row.  We don't want to do it for subsequent inserts.
    if (vo.getFetchedRowCount() == 0) 
    {
      vo.setMaxFetchSize(0);
    } 

    Row row = vo.createRow();
    vo.insertRow(row);

    // Required per OA Framework Model Coding Standard M69
    row.setNewRowState(Row.STATUS_INITIALIZED);
    
  } // end createSupplier()
  

  /*
   *****************************************************************************
   * Returns "Y" if the given view instance flag has been queried, "N" otherwise.
   *****************************************************************************
   */
  public String isVOQueried(String viewInstanceName)
  {
    OAViewObject vo = (OAViewObject)findViewObject(viewInstanceName);

    if (vo == null)
    {
        MessageToken[] tokens = { new MessageToken("OBJECT_NAME", viewInstanceName) };
        throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

    return (vo.isPreparedForExecution()) ? "Y" : "N";

  } // end isVOQueried()
  
  /*
   *****************************************************************************
   * Initializes the supplier query.
   *****************************************************************************
   */
  public void initSummary(String supplierName, 
                          String onHoldFlag, 
                          String supplierNumber,
                          Boolean executeQuery)
  {

    SupplierSummaryVOImpl vo = getSupplierSummaryVO1();
           
    if (vo == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "SupplierSummaryVO1") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }
  
    vo.initQuery(supplierName, onHoldFlag, supplierNumber, executeQuery);
    
  } // end initSummary()
  

//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here...
//  ---------------------------------------------------------------

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public CreateAMImpl()
  {
  }


  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.tutorial.server", "CreateAMLocal");
  }



  /**
   * 
   * Container's getter for SuppliersVO1
   */
  public SuppliersVOImpl getSuppliersVO1()
  {
    return (SuppliersVOImpl)findViewObject("SuppliersVO1");
  }

  /**
   * 
   * Container's getter for YesNoVO1
   */
  public OAViewObjectImpl getYesNoVO1()
  {
    return (OAViewObjectImpl)findViewObject("YesNoVO1");
  }

  /**
   * 
   * Container's getter for SupplierSummaryVO1
   */
  public SupplierSummaryVOImpl getSupplierSummaryVO1()
  {
    return (SupplierSummaryVOImpl)findViewObject("SupplierSummaryVO1");
  }



}
