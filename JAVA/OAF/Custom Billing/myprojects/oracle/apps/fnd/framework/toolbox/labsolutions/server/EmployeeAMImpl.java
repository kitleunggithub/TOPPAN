/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.jbo.Row;
import oracle.jbo.Transaction;
import oracle.jbo.RowSetIterator;
import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OARow;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class EmployeeAMImpl extends OAApplicationModuleImpl 
{

  public static final String RCS_ID="$Header: EmployeeAMImpl.java 120.3 2006/05/25 00:00:13 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.server");

  /*
   *****************************************************************************
   * Initializes the transient application properties VO.
   *****************************************************************************
   */
   public void init()
   {
   
     OAViewObject appPropsVO = (OAViewObject)findViewObject("EmployeePVO1");
     
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

         // You must create and insert a row in the VO before you can start
         // setting properties.
         appPropsVO.insertRow(appPropsVO.createRow());

         // Set the primary key value for this single-rwo VO.       
         OARow row = (OARow)appPropsVO.first();
         row.setAttribute("RowKey", new Number(1));
       }
     }  

      // Initialize the application properties VO (and the UI) based on the
      // default employee position value set on the underlying object.
      handlePositionChangeEvent();
    
   } // end init()

  /*
   *****************************************************************************
   * Handles changes of the position poplist to set the application properties
   * VO value for PPR.
   *****************************************************************************
   */
   public void handlePositionChangeEvent()
   {
     // Get the special, single-row application properties and make the first 
     // (only) row current.
     OAViewObject vo = (OAViewObject)findViewObject("EmployeePVO1");
     OARow row = (OARow)vo.first();
     
     // Get the value of the view object attribute with the position code
     OAViewObject empVO = (OAViewObject)findViewObject("EmployeeCreateVO1");   
     OARow empRow = (OARow)empVO.getCurrentRow();
     String position = (String)empRow.getAttribute("PositionCode");

     if ((position == null) || ("PRESIDENT".equals(position))) 
     {
       row.setAttribute("EmpManagerRender", Boolean.FALSE);
     }
     else
     {
       row.setAttribute("EmpManagerRender", Boolean.TRUE);
     }
     
   } // end handlePositionChangeEvent()
  

  /*
   *****************************************************************************
   * Executes a rollback including the database and the middle tier.
   *****************************************************************************
   */
  public void rollbackEmployee()
  {
    Transaction txn = getTransaction();

    // This small optimization ensures that we don't perform a middle tier
    // rollback if we don't have to.
    if (txn.isDirty())
    {
      txn.rollback();
    }  
  } // end rollbackEmployee()
  

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
   * Initializes the detail employee query.
   *****************************************************************************
   */
  public void initDetails(String employeeNumber)
  {
    EmployeeFullVOImpl vo = getEmployeeFullVO1();

    if (vo == null)
    {
      MessageToken[] errTokens = { new MessageToken("OBJECT_NAME", "EmployeeFullVO1") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", errTokens);
    }  
    
    vo.initQuery(employeeNumber);

/*
    // Since we're querying a single row with a primary key value, we 
    // can use the findByKey method which first checks the BC4J cache, 
    // and if it doesn't find a matching row, it will formulate a query using 
    // the given key and retrieve it from the database.  
    String[] keys = { employeeNumber };
    Row[] rows = vo.findByKey(new Key(keys), 1);

   // You must set the current row, or the Details page won't display any
   // data.  When you explicitly query data, you don't have to do this.
    
    if (rows != null)
    {
      vo.setCurrentRow(rows[0]);
    }
*/   
    
  } // end initDetails()
  
  /*
   ****************************************************************************
   * Creates a new employee.
   ****************************************************************************
   */
  public void createEmployee()
  {
    OAViewObject vo = (OAViewObject)getEmployeeCreateVO1(); 

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

  } // end createEmployee()

  /*
   *****************************************************************************
   * Deletes an employee.
   *****************************************************************************
   */
  public void deleteEmployee(String employeeNumber)
  {
    // First, we need to find the selected employee in our VO.
    // When we find it, we call remove( ) on the row which in turn
    // calls remove on the associated EmployeeEOImpl object.

    int empToDelete = Integer.parseInt(employeeNumber);
    
    OAViewObject vo = (OAViewObject)getEmployeeSummaryVO1(); 
    EmployeeSummaryVORowImpl row = null;

    // This tells us the number of rows that have been fetched in the
    // row set, and will not pull additional rows in like some of the
    // other "get count" methods.
    
    int fetchedRowCount = vo.getFetchedRowCount();

    // We use a separate iterator -- even though we could step through the
    // rows without it -- because we don't want to affect row currency.
    
    RowSetIterator deleteIter = vo.createRowSetIterator("deleteIter"); 

    if (fetchedRowCount > 0) 
    { 
      deleteIter.setRangeStart(0); 
      deleteIter.setRangeSize(fetchedRowCount); 

      for (int i = 0; i < fetchedRowCount; i++)
      {
        row = (EmployeeSummaryVORowImpl)deleteIter.getRowAtRangeIndex(i); 

        // For performance reasons, we generate ViewRowImpls for all
        // View Objects.  When we need to obtain an attribute value,
        // we use the named accessors instead of a generic String lookup.
        
        // Number primaryKey = (Number)row.getAttribute("EmployeeId");
        Number primaryKey = row.getEmployeeId();

        if (primaryKey.compareTo(empToDelete) == 0)
        {
            row.remove();
            getTransaction().commit(); 
            break; // only one possible selected row in this case
        }
      }
    }  

   deleteIter.closeRowSetIterator(); 

    
  } // end deleteEmployee

  /*
   *****************************************************************************
   * Queries the Positions view object used for the graph exercise.
   *****************************************************************************
   */
  public void initGraphQuery()
  {
    PositionGraphVOImpl vo = getPositionGraphVO1();
    if (vo == null)
      {
        MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "PositionGraphVO1")};
        throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
      }

    if (!vo.isPreparedForExecution())    
    {
      vo.initQuery();
    }
  }
  // end initGraphQuery()


   public void initQuery()
   {
       EmployeeFullVOImpl vo2 = getGraphEmployeeFullVO1();
       vo2.initGraphQuery(); 
   } 
   
    public EmployeeFullVOImpl getGraphEmployeeFullVO1() {
        return (EmployeeFullVOImpl)findViewObject("EmployeeFullVO1");
    }
   

//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here
//  ---------------------------------------------------------------

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public EmployeeAMImpl()
  {
  }

  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.labsolutions.server", "EmployeeAMLocal");
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
   * Container's getter for EmployeeFullVO1
   */
  public EmployeeFullVOImpl getEmployeeFullVO1()
  {
    return (EmployeeFullVOImpl)findViewObject("EmployeeFullVO1");
  }

  /**
   * 
   * Container's getter for EmployeeSummaryVO1
   */
  public OAViewObjectImpl getEmployeeSummaryVO1()
  {
    return (OAViewObjectImpl)findViewObject("EmployeeSummaryVO1");
  }

  /**
   * 
   * Container's getter for EmployeePVO1
   */
  public OAViewObjectImpl getEmployeePVO1()
  {
    return (OAViewObjectImpl)findViewObject("EmployeePVO1");
  }

  /**
   * 
   * Container's getter for PositionGraphVO1
   */
  public PositionGraphVOImpl getPositionGraphVO1()
  {
    return (PositionGraphVOImpl)findViewObject("PositionGraphVO1");
  }

  /**
   * 
   * Container's getter for EmployeeCreateVO1
   */
  public EmployeeFullVOImpl getEmployeeCreateVO1()
  {
    return (EmployeeFullVOImpl)findViewObject("EmployeeCreateVO1");
  }














}
