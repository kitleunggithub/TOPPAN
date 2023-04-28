/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.server;

import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.jbo.domain.Number;
import oracle.jbo.server.ViewLinkImpl;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.OARow;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;

import oracle.apps.fnd.framework.server.OAViewObjectImpl;

import oracle.apps.fnd.framework.OAException;

import oracle.apps.fnd.framework.toolbox.poplist.server.OrderStatusesVOImpl;
import oracle.apps.fnd.framework.toolbox.samplelib.server.LookupCodesVOImpl;

public class SampleBrowserAMImpl extends OAApplicationModuleImpl {

  public static final String RCS_ID="$Header: SampleBrowserAMImpl.java 120.10 2006/07/03 17:29:47 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
    VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.samplelib.server");

  //ER#4653823 -- Initializes Advanced Table 3
  public void initTable3VO()
  {
    EmployeesVOImpl vo = getEmployeesVO2();
    vo.initQuery();
  }
  
  public void initTreeQuery()
  {
    SimpleEmployeesVOImpl vo = getSimpleEmployeesVO1();
    vo.initQuery();
  }

  public void initLookupCodes()
  {
    LookupCodesVOImpl vo = getLookupCodesVO1();

    // Need to properly initialize this table before inserting rows.
    
    if (vo.getFetchedRowCount() == 0) 
    {
       vo.setMaxFetchSize(0); 
    }
  
  }
  
  public void initializePPRExamplePage()
  {
    // Create a null purchase order header.

    OAViewObject poVO = (OAViewObject)findViewObject("PurchaseOrderHeadersVO1");

    if (poVO != null)
    {
      if (poVO.getFetchedRowCount() == 0)
      {
        // Setting the match fetch size to 0 for an in-memory VO
        // prevents it from trying to query rows.
        poVO.setMaxFetchSize(0);

         Row row = poVO.createRow();
         poVO.insertRow(row);

         // Required per OA Framework Model Coding Standard M69
         row.setNewRowState(Row.STATUS_INITIALIZED);
      }
    }
    else
    {
     // throw exception
    }

    OAViewObject appPropsVO = (OAViewObject)findViewObject("SampleBrowserPVO1");

    if (appPropsVO != null)
    {
      // This checkes the in-memory cache (doesn't cause a database hit).
      // If the VO doesn't include a row yet, create and insert one.
      if (appPropsVO.getFetchedRowCount() == 0)
      {

        // Setting the match fetch size to 0 for an in-memory VO
        // prevents it from trying to query rows.  Calling
        // executeQuery() ensures that rows aren't lost after
        // a commit in the transaction (BC4J known issue workaround).
         appPropsVO.setMaxFetchSize(0);
         appPropsVO.executeQuery();
         appPropsVO.insertRow(appPropsVO.createRow());

        // Set the primary key value for this single-row VO.
        OARow row = (OARow)appPropsVO.first();
        row.setAttribute("RowKey", new Number(1));

      }
      // Initialize the application properties VO (and the UI) based on the
      // default PO approval value set on the underlying object.
      handlePoApproveChangeEvent();

      // Initialize the header text for the supplier sites detail table.
      handleSupplierSelectionEvent();
    }
    else
    {
     // throw exception
    }
    
    OAViewObject pprvo = getPurchaseOrderPPRVO1();
    if(pprvo != null)
    {
      pprvo.setMaxFetchSize(0);
      pprvo.insertRow(pprvo.createRow());
    }
    else
    {
      //throw Exception
    }
  }

  public void handleSupplierSelectionEvent()
  {
    OADBTransaction txn = getOADBTransaction();
    String detailTableText = null;

    // Find the selected radio button so we can mark the current row.
    OAViewObject vo = (OAViewObject)findViewObject("SuppliersVO1");

    // Get the first filtered row.
    Row masterRow = vo.getFirstFilteredRow ("SelectFlag", "Y");
    if (masterRow != null)
    {
      vo.setCurrentRow(masterRow);
      String supplierName = (String)masterRow.getAttribute("Name");

      MessageToken[] tokens = { new MessageToken("SUPPLIER_NAME", supplierName)};

      detailTableText =
        txn.getMessage("AK", "FWK_TBX_SITES_FOR_SUPPLIER", tokens);
    }
    else
    {
      // If there are no selected rows, display a default generic message.
      detailTableText = 
        txn.getMessage("AK", "FWK_TBX_SUPPLIER_SITES", null);
    }

    // Now set the text message on the DETAIL_TABLE_TEXT attribute in
    // the application properties VO.

    SampleBrowserPVOImpl appPropsVo = getSampleBrowserPVO1();
    Row appPropsRow = appPropsVo.getCurrentRow(); 

    if (appPropsRow != null)
    {
      appPropsRow.setAttribute("DetailTableText", detailTableText);    
    }
    
  } // end handleSupplierSelectionEvent()

  public void handlePoApproveChangeEvent()
  {
    // Get the special, single-row application properties and make the first
    // (only) row current.
    OAViewObject vo = (OAViewObject)findViewObject("SampleBrowserPVO1");
    OARow row = (OARow)vo.first();

    // Get the value of the view object attribute with the PO Approval
    // status.
    OAViewObject poVO = (OAViewObject)findViewObject("PurchaseOrderHeadersVO1");

    OARow poRow = (OARow)poVO.getCurrentRow();
    String status = (String)poRow.getAttribute("StatusCode");

    // Set the application property values based on the PO Approval
    // status value.
    if ("APPROVED".equals(status))
    {
       row.setAttribute("PoApproveRender", Boolean.TRUE);
       row.setAttribute("PoRejectRender", Boolean.FALSE);
       row.setAttribute("PoApproveReadOnly", Boolean.TRUE);
       row.setAttribute("PoApproveRequired", "y");
    }
    else if ("REJECTED".equals(status))
    {
       row.setAttribute("PoApproveRender", Boolean.FALSE);
       row.setAttribute("PoRejectRender", Boolean.TRUE);
    }
    else
    {
       row.setAttribute("PoApproveRender", Boolean.TRUE);
       row.setAttribute("PoRejectRender", Boolean.FALSE);
       row.setAttribute("PoApproveReadOnly", Boolean.TRUE);
       row.setAttribute("PoApproveRequired", "n");
    }
  }

  public void initDepartmentEmployees()
  {
    DepartmentEmpsVOImpl vo = getDepartmentEmpsVO1();
    
    // Need to properly initialize this table before inserting rows.
    
    if (vo.getFetchedRowCount() == 0) 
    {
       vo.setMaxFetchSize(0); 
    }
  }


  public void initializeEmployeesForInsert()
  {
    EmployeesVOImpl vo = getEmployeesVO6();
    
    // Need to properly initialize this table before inserting rows.
    if (!vo.isPreparedForExecution())
    {
       vo.initQuery();
    }
  }

  public void initializeEmployees()
  {
    EmployeesVOImpl vo = getEmployeesVO1();

    // Avoid unnecessary query execution
    if (!vo.isPreparedForExecution())
    {
       vo.initQuery();
    }
  }

  public void initTableQuery(Boolean executeQuery)
  {
    EmployeesVOImpl vo = getEmployeesVO1();
    vo.initQuery(executeQuery);
  }

  
  /**
   *
   * This is the default constructor (do not remove)
   */
  public SampleBrowserAMImpl()
  {
  }

  /**
   *
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.samplelib.server", "SampleBrowserAMLocal");
  }

  /**
   *
   * Container's getter for EmployeesVO1
   */
  public EmployeesVOImpl getEmployeesVO1()
  {
    return (EmployeesVOImpl)findViewObject("EmployeesVO1");
  }



  /**
   *
   * Container's getter for OrderStatusesVO1
   */
  public OrderStatusesVOImpl getOrderStatusesVO1()
  {
    return (OrderStatusesVOImpl)findViewObject("OrderStatusesVO1");
  }

  /**
   *
   * Container's getter for PurchaseOrderHeadersVO1
   */
  public PurchaseOrderHeadersVOImpl getPurchaseOrderHeadersVO1()
  {
    return (PurchaseOrderHeadersVOImpl)findViewObject("PurchaseOrderHeadersVO1");
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
   * Container's getter for SupplierSitesVO1
   */
  public SupplierSitesVOImpl getSupplierSitesVO1()
  {
    return (SupplierSitesVOImpl)findViewObject("SupplierSitesVO1");
  }

  /**
   *
   * Container's getter for SupplierToSiteVL1
   */
  public ViewLinkImpl getSupplierToSiteVL1()
  {
    return (ViewLinkImpl)findViewLink("SupplierToSiteVL1");
  }

  /**
   *
   * Container's getter for SampleBrowserPVO1
   */
  public SampleBrowserPVOImpl getSampleBrowserPVO1()
  {
    return (SampleBrowserPVOImpl)findViewObject("SampleBrowserPVO1");
  }

  /**
   * 
   * Container's getter for PositionsVO1
   */
  public OAViewObjectImpl getPositionsVO1()
  {
    return (OAViewObjectImpl)findViewObject("PositionsVO1");
  }

  /**
   * 
   * Container's getter for EmployeesVO2
   */
  public EmployeesVOImpl getEmployeesVO2()
  {
    return (EmployeesVOImpl)findViewObject("EmployeesVO2");
  }

  /**
   * 
   * Container's getter for EmployeesVO3
   */
  public EmployeesVOImpl getEmployeesVO3()
  {
    return (EmployeesVOImpl)findViewObject("EmployeesVO3");
  }

  /**
   * 
   * Container's getter for EmployeesVO4
   */
  public EmployeesVOImpl getEmployeesVO4()
  {
    return (EmployeesVOImpl)findViewObject("EmployeesVO4");
  }

  /**
   * 
   * Container's getter for DepartmentEmpsVO1
   */
  public DepartmentEmpsVOImpl getDepartmentEmpsVO1()
  {
    return (DepartmentEmpsVOImpl)findViewObject("DepartmentEmpsVO1");
  }
  
  /**
   * Convenience method
   * Updates the modified rows and commits the transaction.
   */
  public void updateEmployee()
  {
    getOADBTransaction().commit();  
  } //end updateEmployee()

   /**
   * Convenience method
   * Executes a rollback.
   */
  
  public void rollbackEmployee()
  {
    if( getOADBTransaction().isDirty())
    {
      getOADBTransaction().rollback();
    }
  } //end rollbackEmployee()

  /**
   * 
   * Container's getter for EmployeesVO5
   */
  public EmployeesVOImpl getEmployeesVO5()
  {
    return (EmployeesVOImpl)findViewObject("EmployeesVO5");
  }


//  /**
//   * 
//   * Container's getter for EmpToEmp1
//   */
//  public ViewLinkImpl getEmpToEmp1()
//  {
//    return (ViewLinkImpl)findViewLink("EmpToEmp1");
//  }

  /**
   * Initializes Employee details query.
   */
   
  public void initDetails(String employeeId)
  {
    SimpleEmployeesVOImpl  vo = getSimpleEmployeesVO1();
    
    if (vo == null)
    {
      MessageToken[] errTokens = { new MessageToken("OBJECT_NAME", "SimpleEmployeeVO1")};
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", errTokens);
    } 

    String[] keys = { employeeId };
    Row[] rows = vo.findByKey(new Key(keys), 1);

   // You must set the current row, or the Details page won't display any
   // data.  When you explicitly query data, you don't have to do this.
    
    if ((rows != null) && (rows.length > 0))
    {
      vo.setCurrentRow(rows[0]);
    }
   
  } // end initDetails()




  /**
   * 
   * Container's getter for SimpleEmployeesVO1
   */
  public SimpleEmployeesVOImpl getSimpleEmployeesVO1()
  {
    return (SimpleEmployeesVOImpl)findViewObject("SimpleEmployeesVO1");
  }

  /**
   * 
   * Container's getter for SimpleEmployeesVO2
   */
  public SimpleEmployeesVOImpl getSimpleEmployeesVO2()
  {
    return (SimpleEmployeesVOImpl)findViewObject("SimpleEmployeesVO2");
  }

  /**
   * 
   * Container's getter for ManagerToEmployeesVL1
   */
  public ViewLinkImpl getManagerToEmployeesVL1()
  {
    return (ViewLinkImpl)findViewLink("ManagerToEmployeesVL1");
  }


  /**
   * 
   * Container's getter for EmployeeNamesVO1
   */
  public OAViewObjectImpl getEmployeeNamesVO1()
  {
    return (OAViewObjectImpl)findViewObject("EmployeeNamesVO1");
  }

  
  /**
   * Convinience method to update the LookupCodes table
   */
   public void updateLookupCodes()
   {
     getOADBTransaction().commit(); 
   }

  /**
   * 
   * Container's getter for LookupCodesVO1
   */
  public LookupCodesVOImpl getLookupCodesVO1()
  {
    return (LookupCodesVOImpl)findViewObject("LookupCodesVO1");
  }

  /**
   * 
   * Container's getter for EmployeesVO6
   */
  public EmployeesVOImpl getEmployeesVO6()
  {
    return (EmployeesVOImpl)findViewObject("EmployeesVO6");
  }
  
  /**
   *
   * Container's getter for PurchaseOrderPPRVO1
   */
  public PurchaseOrderPPRVOImpl getPurchaseOrderPPRVO1()
  {
    return (PurchaseOrderPPRVOImpl)findViewObject("PurchaseOrderPPRVO1");
  }







  
}
