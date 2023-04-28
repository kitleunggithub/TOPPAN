/*===========================================================================+
 |      Copyright (c) 2002, 2014 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |       27-MAY-02  L Lyons  Created.                                        |
 |                                                                           |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import oracle.jbo.Row;
import oracle.jbo.Transaction;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.ViewLinkImpl;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

import oracle.apps.fnd.framework.toolbox.poplist.server.StatusListVOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.EmpNameForIdVVOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.IdForSupplierNameVVOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.IdForSupplierSiteVVOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.IdForEmpNameVVOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.SupNameForIdVVOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.SiteNameForIdVVOImpl;


public class MultistepCreateAMImpl extends OAApplicationModuleImpl {

  public static final String RCS_ID="$Header: MultistepCreateAMImpl.java 120.5.12020000.2 2014/09/18 14:11:30 spunam ship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");


  /*
   *****************************************************************************
   * Override this method so that the Workflow context created for the declarative
   * page flow can be cleared.
   *****************************************************************************
   */
  public void beforeRelease()
  {
    super.beforeRelease();  //always remember to call this
    getOADBTransaction().clearWorkflowInfo();
    
  } // end beforeRelease()

  /*             
   *****************************************************************************
   * Creates a new purchase order line.
   *****************************************************************************
   */
  public void createLineItem()
  {
    PoLineShipFullVOImpl vo = getPoLineShipFullVO1();

    // We need to do this on a VO that has not been queried before we insert
    // our first row.  We don't want to do it for subsequent inserts.

    if (!vo.isPreparedForExecution()) 
    { 
      // Complies with the view object initialization guidelines for a detail
      // view object in a master-detail relationship.
       vo.setWhereClause("1=2"); 
       vo.executeQuery(); 
    }
    
    Row row = vo.createRow();
    vo.insertRow(row);

    // Required per OA Framework Model Coding Standard M69
    row.setNewRowState(Row.STATUS_INITIALIZED);
    
  } // end createLineItem()
   public void createSimplifiedLineItem()
   {
     PoLinesExpVOImpl vo = getPoLinesExpVO1();

     // We need to do this on a VO that has not been queried before we insert
     // our first row.  We don't want to do it for subsequent inserts.
      if (!vo.isPreparedForExecution()) 
      { 
        // Complies with the view object initialization guidelines for a detail
        // view object in a master-detail relationship.
         vo.setWhereClause("1=2"); 
         vo.executeQuery(); 
      }
         
     Row row = vo.createRow();
     vo.insertRow(row);

     // Required per OA Framework Model Coding Standard M69
     row.setNewRowState(Row.STATUS_INITIALIZED);
     
   } // end createLineItem()

  /*
   ****************************************************************************
   * Creates a new purchase order header.
   ****************************************************************************
   */
  public void createPurchaseOrder()
  {
   
    OAViewObject vo = getPoDetailsFullVO1();

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

  } // end createPurchaseOrder()

  /*
   *****************************************************************************
   * Gets the Workflow item key for the declarative page flow using the given
   * DB sequence.
   *****************************************************************************
   */
  public String getWfKey(String sequenceName)
  {
    OADBTransaction txn = getOADBTransaction(); 
    
    Number sequence = txn.getSequenceValue(sequenceName);
    String seqString = sequence.stringValue();
    
    // Now get the system date in milliseconds and concatenate this value
    // with the sequence.  Note that we opted to add the date here to
    // ensure key uniquenes instead of changing our install so that
    // any sequence numbers we generate do not exist in the Workflow tables (the
    // underlying sequence definition doesn't check for workflows created with
    // previous Toolbox patch applications, and then start with a number
    // greater than the maximum workflow item key that the Toolbox used for
    // a FWKTBX2 workflow definition.  The sequence we use is simply dropped
    // and recreated the same way all the other Toolbox sequences/data are
    // dropped/deleted and reinstalled).
    
    Date sysdate = txn.getCurrentDBDate();
    String dateString = String.valueOf(sysdate.timestampValue().getTime());

    String itemKey = seqString.concat("_").concat(dateString);

    return itemKey;

  } // end getWfKey()

  /*
   *****************************************************************************
   * Commits the transaction.
   *****************************************************************************
   */
  public void apply()
  {
    getTransaction().commit();
  }

   /*
   *****************************************************************************
   * Rolls the transaction back.
   *****************************************************************************
   */
  public void rollbackPurchaseOrder()
  {
    Transaction txn = getTransaction();

    if (txn.isDirty())
    {
      txn.rollback();
    }  
  }

//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here...
//  ---------------------------------------------------------------


  /**
   * 
   * This is the default constructor (do not remove)
   */
  public MultistepCreateAMImpl()
  {
  }







  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.tutorial.server", "MultistepCreateAMLocal");
  }










  /**
   * 
   * Container's getter for UnitsOfMeasureVO1
   */
  public OAViewObjectImpl getUnitsOfMeasureVO1()
  {
    return (OAViewObjectImpl)findViewObject("UnitsOfMeasureVO1");
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
   * Container's getter for SupplierSitesLOVVO1
   */
  public OAViewObjectImpl getSupplierSitesLOVVO1()
  {
    return (OAViewObjectImpl)findViewObject("SupplierSitesLOVVO1");
  }



  /**
   * 
   * Container's getter for IdForSupplierNameVVO1
   */
  public IdForSupplierNameVVOImpl getIdForSupplierNameVVO1()
  {
    return (IdForSupplierNameVVOImpl)findViewObject("IdForSupplierNameVVO1");
  }

  /**
   * 
   * Container's getter for IdForSupplierSiteVVO1
   */
  public IdForSupplierSiteVVOImpl getIdForSupplierSiteVVO1()
  {
    return (IdForSupplierSiteVVOImpl)findViewObject("IdForSupplierSiteVVO1");
  }

  /**
   * 
   * Container's getter for IdForEmpNameVVO1
   */
  public IdForEmpNameVVOImpl getIdForEmpNameVVO1()
  {
    return (IdForEmpNameVVOImpl)findViewObject("IdForEmpNameVVO1");
  }

  /**
   * 
   * Container's getter for EmpNameForIdVVO1
   */
  public EmpNameForIdVVOImpl getEmpNameForIdVVO1()
  {
    return (EmpNameForIdVVOImpl)findViewObject("EmpNameForIdVVO1");
  }

  /**
   * 
   * Container's getter for SupNameForIdVVO1
   */
  public SupNameForIdVVOImpl getSupNameForIdVVO1()
  {
    return (SupNameForIdVVOImpl)findViewObject("SupNameForIdVVO1");
  }

  /**
   * 
   * Container's getter for StatusListVO1
   */
  public StatusListVOImpl getStatusListVO1()
  {
    return (StatusListVOImpl)findViewObject("StatusListVO1");
  }

  /**
   * 
   * Container's getter for SiteNameForIdVVO1
   */
  public SiteNameForIdVVOImpl getSiteNameForIdVVO1()
  {
    return (SiteNameForIdVVOImpl)findViewObject("SiteNameForIdVVO1");
  }

  /**
   * 
   * Container's getter for PoDetailsFullVO1
   */
  public PoDetailsFullVOImpl getPoDetailsFullVO1()
  {
    return (PoDetailsFullVOImpl)findViewObject("PoDetailsFullVO1");
  }

  /**
   * 
   * Container's getter for PoLineShipFullVO1
   */
  public PoLineShipFullVOImpl getPoLineShipFullVO1()
  {
    return (PoLineShipFullVOImpl)findViewObject("PoLineShipFullVO1");
  }

  /**
   * 
   * Container's getter for PoHeaderEOLineEOVL1
   */
  public ViewLinkImpl getPoHeaderEOLineEOVL1()
  {
    return (ViewLinkImpl)findViewLink("PoHeaderEOLineEOVL1");
  }


  public PoLinesExpVOImpl getPoLinesExpVO1()
  {
    return (PoLinesExpVOImpl)findViewObject("PoLinesExpVO1");
  }

  /**Sample exportable method.
   */
  public void sampleMultistepCreateAMImplExportable()
  {
  }

  /**Sample exportable method.
   */
  public void sampleMultistepCreateAMImplExportable2(String testParam1)
  {
  }
}
