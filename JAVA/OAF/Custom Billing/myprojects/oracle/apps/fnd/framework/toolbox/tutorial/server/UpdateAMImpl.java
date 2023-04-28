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

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.Transaction;
import oracle.jbo.domain.Number;
import oracle.jbo.server.ViewLinkImpl;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.toolbox.poplist.server.StatusListVOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.IdForSupplierNameVVOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.IdForSupplierSiteVVOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.SupNameForIdVVOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.SiteNameForIdVVOImpl;
import oracle.apps.fnd.framework.toolbox.schema.server.EmpNameForIdVVOImpl;


public class UpdateAMImpl extends OAApplicationModuleImpl {

  public static final String RCS_ID="$Header: UpdateAMImpl.java 120.2 2006/07/04 02:42:59 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");

  /*
   *****************************************************************************
   * Commits the transaction.
   *****************************************************************************
   */
  public void apply()
  {
    getTransaction().commit();
  } // end apply()

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

  /*
   *****************************************************************************
   * Initializes the purchase order query.
   *****************************************************************************
   */
  public Boolean init(String orderNumber)
  {
    boolean rowFound = false;
    
    PoDetailsFullVOImpl vo = getPoDetailsFullVO1();

    if (vo == null)
    {
      MessageToken[] errTokens = { new MessageToken("OBJECT_NAME", "PoDetailsFullVO1") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", errTokens);
    }  

   Number orderNum = null;
    
    try
    {
      orderNum = new Number(orderNumber);
    }
    catch(Exception e) {}

    // First, construct an oracle.jbo.Key object as required in the findByKey constructor
    // Javadoc.  Then, call findByKey indicating that we're looking for a single
    // row.  BC4J tries to find the entity object(s) for this row in its cache, and failing
    // that, will query from the database using the given key.

    Number[] keys = { orderNum };
    Row[] rows = vo.findByKey(new Key(keys), 1);

    // You must set the current row, or the Details page won't display any
    // data. When you explicitly query data, you don't have to do this 
    // because the OA Framework automatically invokes vo.first() in the 
    // result set, thereby establishing a current row.

    if ((rows != null) && (rows.length > 0))
    {
      vo.setCurrentRow(rows[0]);
      rowFound = true;
    }

    return new Boolean(rowFound);
    
  } // end init()
  

//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here
//  ---------------------------------------------------------------

  
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public UpdateAMImpl()
  {
  }



  /**
   * 
   * Container's getter for IdForSupplierNameVVO
   */
  public IdForSupplierNameVVOImpl ValIdForSupplierNameVVO()
  {
    return (IdForSupplierNameVVOImpl)findViewObject("IdForSupplierNameVVO1");
  }







  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.tutorial.server", "UpdateAMLocal");
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
   * Container's getter for SupNameForIdVVO1
   */
  public SupNameForIdVVOImpl getSupNameForIdVVO1()
  {
    return (SupNameForIdVVOImpl)findViewObject("SupNameForIdVVO1");
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
   * Container's getter for EmpNameForIdVVO1
   */
  public EmpNameForIdVVOImpl getEmpNameForIdVVO1()
  {
    return (EmpNameForIdVVOImpl)findViewObject("EmpNameForIdVVO1");
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


}
