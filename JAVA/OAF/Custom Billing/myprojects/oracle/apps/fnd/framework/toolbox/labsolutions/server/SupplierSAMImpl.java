/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.server.OADBTransactionImpl;
import oracle.apps.fnd.framework.toolbox.labsolutions.Supplier;
import oracle.apps.fnd.framework.toolbox.labsolutions.SupplierFilter;
import oracle.apps.fnd.framework.toolbox.labsolutions.SupplierService;
import oracle.apps.fnd.framework.toolbox.labsolutions.SupplierSite;
import oracle.apps.fnd.framework.toolbox.labsolutions.SupplierSiteFilter;
import oracle.jbo.domain.Number;

import oracle.svc.DataCriteria;
import oracle.svc.DataObject;
import oracle.svc.DataObjectImpl;
import oracle.svc.DataProcessorService;
import oracle.svc.QueryControl;
import oracle.svc.expression.ValueExpression;
import oracle.svc.ProcessControl;
import oracle.svc.util.DataObjectFactory;
import java.util.ArrayList;
import java.util.List;
import java.lang.String;
import java.lang.Boolean;
import oracle.svc.expression.ExpressionFilter;

public class SupplierSAMImpl extends OAApplicationModuleImpl implements SupplierService
{

  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID="$Header: SupplierSAMImpl.java 120.9 2006/05/25 00:04:47 atgops1 noship $";
  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.server");

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public SupplierSAMImpl()
  {
  }

  /**   
   * Disabled the supplier. You can pass the supplier id or name.
   * @param supplierId Supplier unique identifier.This is the supplier number.
   * @param supplierName Supplier name.   
   */
  public void disableSupplier(Number supplierId, String supplierName)
  {
    setSupplierOnHold(supplierId, supplierName, Boolean.TRUE);
  } // end disableSupplier()


  /**   
   * Disables the supplier site. You can pass the supplier site id or name.
   * @param supplierId Supplier unique identifier.This is the supplier number.
   * @param supplierName Supplier name.
   * @param supplierSiteId Supplier site unique identifier.This is the supplier site number.
   * @param siteName Supplier site name.   
   */
  public void disableSupplierSite(Number supplierId, String supplierName, Number supplierSiteId, String siteName)
  {
    OADBTransactionImpl trxn = (OADBTransactionImpl)getOADBTransaction();
    DataObjectFactory fac = trxn.getDataObjectFactory();   
    DataCriteria dataCriteria = (DataCriteria)fac.createDataObject(DataCriteria.QUALIFIED_NAME);
    SupplierSiteFilter filter = (SupplierSiteFilter)fac.createDataObject(SupplierSiteFilter.QUALIFIED_NAME);
    dataCriteria.setFilter(filter);   
    if(supplierId != null)     
      filter.addSupplierId(ValueExpression.EQUAL, supplierId);
    if(supplierName != null)     
      filter.addName(ValueExpression.EQUAL, supplierName);
    if(supplierSiteId != null)     
      filter.addSupplierSiteId(ValueExpression.EQUAL, supplierSiteId);
    if(siteName != null)     
      filter.addSiteName(ValueExpression.EQUAL, siteName);
    //find the supplier with the given id or name   
    List results = getDataList("SupplierSite", dataCriteria, null);
    if (results != null && results.size() > 0)   
    {     
      for(int i=0; i<results.size(); i++)     
      {      
        SupplierSite site = (SupplierSite)results.get(i);      
        site.setPurchasingSiteFlag("N");      
        updateSuppliersite(site);
      }   
    }
  } // end disableSupplierSite()

  /**   
   * Sets the supplier on hold. You can pass the supplier id or name.
   * @param supplierId Supplier unique identifier. This is the supplier number.
   * @param supplierName Supplier name.   
   * @param onHold OnHoldFlag status.  
   */
  public void setSupplierOnHold(Number supplierId, String supplierName, Boolean onHold)
  {
    OADBTransactionImpl trxn = (OADBTransactionImpl)getOADBTransaction();
    DataObjectFactory fac = trxn.getDataObjectFactory();   
    DataCriteria dataCriteria = (DataCriteria)fac.createDataObject(DataCriteria.QUALIFIED_NAME);
    SupplierFilter filter = (SupplierFilter)fac.createDataObject(SupplierFilter.QUALIFIED_NAME);
    dataCriteria.setFilter(filter);   
    if(supplierId != null)      
      filter.addSupplierId(ValueExpression.EQUAL, supplierId);
    if(supplierName != null)      
      filter.addName(ValueExpression.EQUAL, supplierName);
    //find the supplier with the given id or name   
    List results = getDataList("Supplier", dataCriteria, null);
    if (results != null && results.size() > 0)   
    {      
      for(int i=0; i<results.size(); i++)     
      {      
        Supplier supplier = (Supplier)results.get(i);      
        String onHoldFlag = supplier.getOnHoldFlag();      
        //currently this supplier is on hold      
        if("Y".equals(onHoldFlag))      
        {       
          if(!Boolean.TRUE.equals(onHold))       
          {        
            supplier.setOnHoldFlag("N");        
            updateSupplier(supplier);      
          }      
        }      
        //currently this supplier is not on hold      
        else      
        {       
          if(Boolean.TRUE.equals(onHold))       
          {        
            supplier.setOnHoldFlag("Y");        
            updateSupplier(supplier);       
          }      
        }     
      }    
    } 
    
  }  // end setSupplierOnHold()

  /**   
   * Checks if the supplier is on hold. You can pass the supplier id or name.
   * @param supplierId Supplier unique identifier.This is the supplier number.
   * @param supplierName Supplier name.   
   * @return isOnHold Boolean value.   
   */
  public Boolean isSupplierOnHold(Number supplierId, String supplierName)
  {
    if(supplierId == null && supplierName == null)     
      throw new OAException("FND", "FND_SUPPLIER_NO_ID_NAME");
    Boolean isOnHold = null;   
    OADBTransactionImpl trxn = (OADBTransactionImpl)getOADBTransaction();
    DataObjectFactory fac = trxn.getDataObjectFactory();   
    DataCriteria dataCriteria = (DataCriteria)fac.createDataObject(DataCriteria.QUALIFIED_NAME);
    SupplierFilter filter = (SupplierFilter)fac.createDataObject(SupplierFilter.QUALIFIED_NAME);
    dataCriteria.setFilter(filter);   
    if(supplierId != null)     
      filter.addSupplierId(ValueExpression.EQUAL, supplierId);
    if(supplierName != null)     
      filter.addName(ValueExpression.EQUAL, supplierName);
    //find the supplier with the given id or name   
    List results = getDataList("Supplier", dataCriteria, null);
    if (results != null && results.size() > 0)   
    {    
      Supplier supplier = (Supplier)results.get(0);    
      if("Y".equals(supplier.getOnHoldFlag()))      
        isOnHold = Boolean.TRUE;    
      else      
        isOnHold = Boolean.FALSE;   
    }   
    return isOnHold;
  } // end isSupplierOnHold()


  

  
  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.labsolutions.server", "SupplierSAMLocal");
  }

  private List getDataList(String dataSourceName, DataCriteria dataCriteria, QueryControl queryControl)
  {
    DataObject rootSDO = queryDataSource(dataSourceName, dataCriteria, queryControl);
    return (rootSDO==null)?null:(List)rootSDO.get(dataSourceName);
  }











  private List processDataList(String dataSourceName, String operation, ProcessControl processControl, List dataList)
  {
    DataObjectFactory factory = ((OADBTransactionImpl)getOADBTransaction()).getDataObjectFactory();
    DataObject rootSDO = factory.createDataObject(DataObjectImpl.QUALIFIED_NAME);
    rootSDO.set(dataSourceName, dataList);
    DataObject ret = processDataSource(dataSourceName, operation, processControl, rootSDO);
    return (List)((ret==null)?null:ret.get(dataSourceName)); 
  }

  /**
   * 
   * Container's getter for Supplier
   */
  public SuppliersSVOImpl getSupplier()
  {
    return (SuppliersSVOImpl)findViewObject("Supplier");
  }
  /**
   * Implmentation for this method was not generated because: 
   * SVO: [SupplierSitesSVO] does not have a filter defined and which includes all primary key attributes.
   */
  public SupplierSite getSuppliersite(Number supplierSiteId, Number supplierId1)
  {
    return null;
  }

  /**
   * Deletes a SupplierSite.
   * The record is located using the primary key set on the passed data object.
   * If the primary key is not set, then the record is located using the
   * alternate key sets in the data object in sequence.
   * @param supplierSite The data object which identifies the SupplierSite.
   */
  public void deleteSuppliersite(SupplierSite supplierSite)
  {
    DataObjectFactory doFac = getDataObjectFactory();
    ArrayList data = new ArrayList();
    data.add(0, supplierSite);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierServiceRoot");
    rootObject.set("SupplierSite", data);
    DataObject resultObject = processDataSource("SupplierSite", DataProcessorService.OPERATION_DELETE, null, rootObject);
  }

  /**
   * Updates or creates a SupplierSite.
   * If the passed SupplierSite exists, it will be updated,
   * otherwise a new one is created.
   * The record is located using the primary key of the SupplierSite.
   * If the primary key is not set, then the record is located using
   * the alternate key sets defined for this data object.
   * @param supplierSite The SupplierSite data object.
   * @return The created SupplierSite data object with the primary keys populated.
   */
  public SupplierSite mergeSuppliersite(SupplierSite supplierSite)
  {
    SupplierSite result = null;
    ArrayList data = new ArrayList();
    data.add(0, supplierSite);
    DataObjectFactory doFac = getDataObjectFactory();
    ProcessControl processCtrl = (ProcessControl)doFac.createDataObject(ProcessControl.QUALIFIED_NAME);
    processCtrl.setReturnMode(ProcessControl.RETURN_KEY);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierServiceRoot");
    rootObject.set("SupplierSite", data);
    DataObject resultObject = processDataSource("SupplierSite", DataProcessorService.OPERATION_MERGE, processCtrl, rootObject);
    List results = (List)resultObject.get("SupplierSite");
    if (results != null && results.size() > 0)
    {
      result = (SupplierSite)results.get(0);
    }
    return result;
  }

  /**
   * Updates a SupplierSite.
   * The record is located using the primary key of the SupplierSite.
   * If the primary key is not set, then the record is located using
   * the alternate key sets defined for this data object.
   * @param supplierSite The SupplierSite data object.
   * @return The updated SupplierSite data object with the primary keys populated.
   */
  public SupplierSite updateSuppliersite(SupplierSite supplierSite)
  {
    SupplierSite result = null;
    ArrayList data = new ArrayList();
    data.add(0, supplierSite);
    DataObjectFactory doFac = getDataObjectFactory();
    ProcessControl processCtrl = (ProcessControl)doFac.createDataObject(ProcessControl.QUALIFIED_NAME);
    processCtrl.setReturnMode(ProcessControl.RETURN_KEY);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierServiceRoot");
    rootObject.set("SupplierSite", data);
    DataObject resultObject = processDataSource("SupplierSite", DataProcessorService.OPERATION_UPDATE, processCtrl, rootObject);
    List results = (List)resultObject.get("SupplierSite");
    if (results != null && results.size() > 0)
    {
      result = (SupplierSite)results.get(0);
    }
    return result;
  }

  /**
   * Creates a new SupplierSite.
   * @param supplierSite The SupplierSite data object.
   * @return The created SupplierSite data object with the primary keys populated.
   */
  public SupplierSite createSuppliersite(SupplierSite supplierSite)
  {
    SupplierSite result = null;
    ArrayList data = new ArrayList();
    data.add(0, supplierSite);
    DataObjectFactory doFac = getDataObjectFactory();
    ProcessControl processCtrl = (ProcessControl)doFac.createDataObject(ProcessControl.QUALIFIED_NAME);
    processCtrl.setReturnMode(ProcessControl.RETURN_KEY);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierServiceRoot");
    rootObject.set("SupplierSite", data);
    DataObject resultObject = processDataSource("SupplierSite", DataProcessorService.OPERATION_CREATE, processCtrl, rootObject);
    List results = (List)resultObject.get("SupplierSite");
    if (results != null && results.size() > 0)
    {
      result = (SupplierSite)results.get(0);
    }
    return result;
  }

  /**
   * Gets a Supplier based on its primary key attributes.
   * @param supplierId Supplier unique identifier.This is the supplier number.
   * @return The Supplier data object.
   */
  public Supplier getSupplier(Number supplierId)
  {
    Supplier result = null;
    OADBTransactionImpl trxn = (OADBTransactionImpl)getOADBTransaction();
    DataObjectFactory fac = trxn.getDataObjectFactory();
    DataCriteria dataCriteria = (DataCriteria)fac.createDataObject("/oracle/svc/DataCriteria");
    ExpressionFilter filter = (ExpressionFilter)fac.createDataObject("/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierFilter");
    dataCriteria.setFilter(filter);
    filter.addValueExpression("SupplierId", ValueExpression.EQUAL, supplierId);
    DataObject resultObject = queryDataSource("Supplier", dataCriteria, null);
    List results = (List)resultObject.get("Supplier");
    if (results != null && results.size() > 0)
    {
      result = (Supplier)results.get(0);
    }
    return result;
  }

  /**
   * Deletes a Supplier.
   * The record is located using the primary key set on the passed data object.
   * If the primary key is not set, then the record is located using the
   * alternate key sets in the data object in sequence.
   * @param supplier The data object which identifies the Supplier.
   */
  public void deleteSupplier(Supplier supplier)
  {
    DataObjectFactory doFac = getDataObjectFactory();
    ArrayList data = new ArrayList();
    data.add(0, supplier);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierServiceRoot");
    rootObject.set("Supplier", data);
    DataObject resultObject = processDataSource("Supplier", DataProcessorService.OPERATION_DELETE, null, rootObject);
  }

  /**
   * Updates or creates a Supplier.
   * If the passed Supplier exists, it will be updated,
   * otherwise a new one is created.
   * The record is located using the primary key of the Supplier.
   * If the primary key is not set, then the record is located using
   * the alternate key sets defined for this data object.
   * 
   * @param supplier The Supplier data object.
   * @return The created Supplier data object with the primary keys populated.
   */
  public Supplier mergeSupplier(Supplier supplier)
  {
    Supplier result = null;
    ArrayList data = new ArrayList();
    data.add(0, supplier);
    DataObjectFactory doFac = getDataObjectFactory();
    ProcessControl processCtrl = (ProcessControl)doFac.createDataObject(ProcessControl.QUALIFIED_NAME);
    processCtrl.setReturnMode(ProcessControl.RETURN_KEY);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierServiceRoot");
    rootObject.set("Supplier", data);
    DataObject resultObject = processDataSource("Supplier", DataProcessorService.OPERATION_MERGE, processCtrl, rootObject);
    List results = (List)resultObject.get("Supplier");
    if (results != null && results.size() > 0)
    {
      result = (Supplier)results.get(0);
    }
    return result;
  }

  /**
   * Updates a Supplier.
   * The record is located using the primary key of the Supplier.
   * If the primary key is not set, then the record is located using
   * the alternate key sets defined for this data object.
   * 
   * @param supplier The Supplier data object.
   * @return The updated Supplier data object with the primary keys populated.
   */
  public Supplier updateSupplier(Supplier supplier)
  {
    Supplier result = null;
    ArrayList data = new ArrayList();
    data.add(0, supplier);
    DataObjectFactory doFac = getDataObjectFactory();
    ProcessControl processCtrl = (ProcessControl)doFac.createDataObject(ProcessControl.QUALIFIED_NAME);
    processCtrl.setReturnMode(ProcessControl.RETURN_KEY);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierServiceRoot");
    rootObject.set("Supplier", data);
    DataObject resultObject = processDataSource("Supplier", DataProcessorService.OPERATION_UPDATE, processCtrl, rootObject);
    List results = (List)resultObject.get("Supplier");
    if (results != null && results.size() > 0)
    {
      result = (Supplier)results.get(0);
    }
    return result;
  }

  /**
   * Creates a new Supplier.
   * @param supplier The Supplier data object.
   * @return The created Supplier data object with the primary keys populated.
   */

  public Supplier createSupplier(Supplier supplier)
  {
    Supplier result = null;
    ArrayList data = new ArrayList();
    data.add(0, supplier);
    DataObjectFactory doFac = getDataObjectFactory();
    ProcessControl processCtrl = (ProcessControl)doFac.createDataObject(ProcessControl.QUALIFIED_NAME);
    processCtrl.setReturnMode(ProcessControl.RETURN_KEY);
    DataObject rootObject = doFac.createDataObject("/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierServiceRoot");
    rootObject.set("Supplier", data);
    DataObject resultObject = processDataSource("Supplier", DataProcessorService.OPERATION_CREATE, processCtrl, rootObject);
    List results = (List)resultObject.get("Supplier");
    if (results != null && results.size() > 0)
    {
      result = (Supplier)results.get(0);
    }
    return result;
  }

  /**
   * 
   * Container's getter for SupplierSite
   */
  public SupplierSitesSVOImpl getSupplierSite()
  {
    return (SupplierSitesSVOImpl)findViewObject("SupplierSite");
  }

}