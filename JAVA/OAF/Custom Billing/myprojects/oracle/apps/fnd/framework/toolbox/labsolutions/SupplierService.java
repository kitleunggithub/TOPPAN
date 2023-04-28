//javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions;
import oracle.apps.fnd.common.VersionInfo;
import oracle.svc.DataProcessorService;
import oracle.apps.fnd.framework.toolbox.labsolutions.Supplier;
import oracle.jbo.domain.Number;
import oracle.apps.fnd.framework.toolbox.labsolutions.SupplierSite;
import java.lang.String;
import java.lang.Boolean;
import oracle.svc.DataObject;
import oracle.svc.DataCriteria;
import oracle.svc.QueryControl;
import oracle.svc.ProcessControl;
/**
 * This is the SupplierService. <i>This is a sample JavaDoc</i>
 * <p>
 * Using this service you can perfrom operations on a supplier such as:
 * <ul>
 * <li> Query
 * <li> Create
 * <li> Update
 * <li> Merge
 * <li> Delete
 * </ul>
 */

public interface SupplierService extends DataProcessorService 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: SupplierService.java 120.10 2008/04/03 07:24:52 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions");


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierService";


  /**
   * Creates a new Supplier.
   * @param supplier The Supplier data object.
   * @return The created Supplier data object with the primary keys populated.
   */
  public Supplier createSupplier(Supplier supplier);

  /**
   * Updates a Supplier.
   * The record is located using the primary key of the Supplier.
   * If the primary key is not set, then the record is located using
   * the alternate key sets defined for this data object.
   * 
   * @param supplier The Supplier data object.
   * @return The updated Supplier data object with the primary keys populated.
   */
  public Supplier updateSupplier(Supplier supplier);

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
  public Supplier mergeSupplier(Supplier supplier);

  /**
   * Deletes a Supplier.
   * The record is located using the primary key set on the passed data object.
   * If the primary key is not set, then the record is located using the
   * alternate key sets in the data object in sequence.
   * @param supplier The data object which identifies the Supplier.
   */
  public void deleteSupplier(Supplier supplier);

  /**
   * Gets a Supplier based on its primary key attributes.
   * @param supplierId Supplier unique identifier.This is the supplier number.
   * @return The Supplier data object.
   */
  public Supplier getSupplier(Number supplierId);

  /**
   * Creates a new SupplierSite.
   * @param supplierSite The SupplierSite data object.
   * @return The created SupplierSite data object with the primary keys populated.
   */
  public SupplierSite createSuppliersite(SupplierSite supplierSite);

  /**
   * Updates a SupplierSite.
   * The record is located using the primary key of the SupplierSite.
   * If the primary key is not set, then the record is located using
   * the alternate key sets defined for this data object.
   * @param supplierSite The SupplierSite data object.
   * @return The updated SupplierSite data object with the primary keys populated.
   */
  public SupplierSite updateSuppliersite(SupplierSite supplierSite);

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
  public SupplierSite mergeSuppliersite(SupplierSite supplierSite);

  /**
   * Deletes a SupplierSite.
   * The record is located using the primary key set on the passed data object.
   * If the primary key is not set, then the record is located using the
   * alternate key sets in the data object in sequence.
   * @param supplierSite The data object which identifies the SupplierSite.
   */
  public void deleteSuppliersite(SupplierSite supplierSite);

  /**
   * Gets a SupplierSite based on its primary key attributes.
   * @param supplierSiteId Supplier site unique identifier.This is the supplier site id.
   * @param supplierId1 Supplier unique identifier.
   * @return The SupplierSite data object.
   */
  public SupplierSite getSuppliersite(Number supplierSiteId, Number supplierId1);

  /**
   * Sets the supplier on hold. You can pass the supplier id or name.
   * @param supplierId A Number object
   * @param supplierName A String object
   * @param supplierSiteId A Number object
   * @param siteName A String object
   */
  public void disableSupplierSite(Number supplierId, String supplierName, Number supplierSiteId, String siteName);

  /**
   * Sets the supplier on hold. You can pass the supplier id or name.
   * @param supplierId The supplier name.
   * @param supplierName If true, the supplier will be put on hold, otherwise the hold 
   * is released.
   * @param onHold A Boolean object
   */
  public void setSupplierOnHold(Number supplierId, String supplierName, Boolean onHold);

  /**
   * Checks if the supplier is on hold. You can pass the supplier id or name.
   * @param supplierId The supplier id.
   * @param supplierName The supplier name.
   * @return true if the supplier is on hold.
   */
  public Boolean isSupplierOnHold(Number supplierId, String supplierName);

  /**
   * Disabled the supplier. You can pass the supplier id or name.
   * @param supplierId Supplier id.
   * @param supplierName A String object
   */
  public void disableSupplier(Number supplierId, String supplierName);

  /**
   * Gets root data object containing a list of data objects from the data source based on criteria.
   * <p>
   * These are the supported data sources:
   * <ul>
   * <li>Supplier: </li>
   * <ul>
   * <li>Data Object: {@link Supplier Supplier}</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>{@link SupplierFilter SupplierFilter}</li>
   * </ul>
   * </ul>
   * <li>SupplierSite: </li>
   * <ul>
   * <li>Data Object: {@link SupplierSite SupplierSite}</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>{@link SupplierSiteFilter SupplierSiteFilter}</li>
   * </ul>
   * </ul>
   * </ul>
   * 
   * @param dataSourceName The name of the data source to query.
   * @param dataCriteria The {@link DataCriteria DataCriteria} for filtering, paging, and
   * sorting the returned data objects.
   * @param queryControl The {@link QueryControl QueryControl} object that contain the control switches for query.
   * @return A root data object containg a list of data objects that statisfy the criteria.
   */
  public DataObject queryDataSource(String dataSourceName, DataCriteria dataCriteria, QueryControl queryControl);

  /**
   * Processes a root data object containing a list of data objects applied to a data source.
   * <p>
   * Data Source Names: 
   * <ul>
   * <li>Supplier: </li>
   * <ul>
   * <li>Data Object: {@link Supplier Supplier}</li>
   * <li>Allowed operations: {@link DataProcessorService#OPERATION_CREATE Create}, {@link DataProcessorService#OPERATION_UPDATE Update}, {@link DataProcessorService#OPERATION_MERGE Merge}, {@link DataProcessorService#OPERATION_DELETE Delete}</li>
   * </ul>
   * <li>SupplierSite: </li>
   * <ul>
   * <li>Data Object: {@link SupplierSite SupplierSite}</li>
   * <li>Allowed operations: {@link DataProcessorService#OPERATION_CREATE Create}, {@link DataProcessorService#OPERATION_UPDATE Update}, {@link DataProcessorService#OPERATION_MERGE Merge}, {@link DataProcessorService#OPERATION_DELETE Delete}</li>
   * </ul>
   * </ul>
   * 
   * @param dataSourceName The name of the data source to process.
   * @param operation The opertion to perform. Can be one of the following:
   * <ul>
   * <li>{@link #OPERATION_CREATE Create}
   * <li>{@link #OPERATION_UPDATE Update}
   * <li>{@link #OPERATION_DELETE Delete}
   * <li>{@link #OPERATION_MERGE Merge}
   * </ul>
   * @param processControl control the post control object. If null, a default control object
   * will be used with the following settings:
   * return mode set to {@link ProcessControl#RETURN_NONE RETURN_NONE} and
   * exeception return mode set to {@link ProcessControl#RETURN_KEY RETURN_KEY}
   * @param supplierServiceRoot The root data object containing a list of data objects to be processed.
   * @return returns a root data object with one of the following:
   * <ul>
   * <li>a list of fully populated data objects if return mode in control is {@link ProcessControl#RETURN_FULL RETURN_FULL}</li>
   * <li>a list of data objects with just primary keys if return mode in control is {@link ProcessControl#RETURN_KEY RETURN_KEY}</li>
   * <li>an empty list if return mode in control is {@link ProcessControl#RETURN_NONE RETURN_NONE}</li>
   * </ul>
   */
  public DataObject processDataSource(String dataSourceName, String operation, ProcessControl processControl, DataObject supplierServiceRoot);
}
