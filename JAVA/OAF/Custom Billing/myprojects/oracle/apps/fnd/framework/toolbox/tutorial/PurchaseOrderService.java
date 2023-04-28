//javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial;
import oracle.apps.fnd.common.VersionInfo;
import oracle.svc.DataProcessorService;
import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrder;
import oracle.jbo.domain.Number;
import java.util.List;
import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderReceipt;
import oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderAcknowledgement;
import oracle.svc.DataObject;
import java.lang.String;
import oracle.svc.DataCriteria;
import oracle.svc.QueryControl;
import oracle.svc.ProcessControl;
/**
 * This is the Purchase Orders Service. This a tutorial Service.
 */

public interface PurchaseOrderService extends DataProcessorService 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: PurchaseOrderService.java 120.14 2008/04/03 07:29:23 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrderService";


  /**
   * Creates a new PurchaseOrder.
   * @param purchaseOrder The PurchaseOrder data object.
   * @return The created PurchaseOrder data object with the primary keys populated.
   */
  public PurchaseOrder createPurchaseOrder(PurchaseOrder purchaseOrder);

  /**
   * Updates a PurchaseOrder.
   * The record is located using the primary key of the PurchaseOrder.
   * If the primary key is not set, then the record is located using
   * the alternate key sets defined for this data object.
   * @param purchaseOrder The PurchaseOrder data object.
   * @return The updated PurchaseOrder data object with the primary keys populated.
   */
  public PurchaseOrder updatePurchaseOrder(PurchaseOrder purchaseOrder);

  /**
   * Updates or creates a PurchaseOrder.
   * If the passed PurchaseOrder exists, it will be updated,
   * otherwise a new one is created.
   * The record is located using the primary key of the PurchaseOrder.
   * If the primary key is not set, then the record is located using
   * the alternate key sets defined for this data object.
   * @param purchaseOrder The PurchaseOrder data object.
   * @return The created PurchaseOrder data object with the primary keys populated.
   */
  public PurchaseOrder mergePurchaseOrder(PurchaseOrder purchaseOrder);

  /**
   * Deletes a PurchaseOrder.
   * The record is located using the primary key set on the passed data object.
   * If the primary key is not set, then the record is located using the
   * alternate key sets in the data object in sequence.
   * @param purchaseOrder The data object which identifies the PurchaseOrder.
   */
  public void deletePurchaseOrder(PurchaseOrder purchaseOrder);

  /**
   * Gets a PurchaseOrder based on its primary key attributes.
   * @param poNumber Purchase order unique identifier.The Purchase Order Number.
   * @return The PurchaseOrder data object.
   */
  public PurchaseOrder getPurchaseOrder(Number poNumber);

  /**
   * Approves a list of purchase orders.
   * @param poNumbers A list of purchase order numbers.
   */
  public void approvePurchaseOrders(List poNumbers);

  /**
   * Receives a single purchaser order.
   * @param receipt The PurchaseOrder data object.
   */
  public void receiveItem(PurchaseOrderReceipt receipt);

  /**
   * Returns the price of a specific item. 
   * You can pass either the line number or the line id.
   * @param poNumber Purchase order unique identifier.
   * Purchase order number.
   * @param lineNumber Line number which is  unique for this  purchase order.
   * Purchase order line number.
   * @param lineId Purchase order line unique identifier.
   * Purchase order Line id.
   * @return The item price.
   */
  public Number getItemPrice(Number poNumber, Number lineNumber, Number lineId);

  /**
   * approves a single purchase order.
   * @param poNumber Purchase order unique identifier.
   * Purchase order number.
   */
  public void approvePurchaseOrder(Number poNumber);

  /**
   * Acknoledges a purchase order.
   * @param acknowledgement The PurchaseOrderAcknowledgement data object. 
   */
  public void acknowledgePurchaseOrder(PurchaseOrderAcknowledgement acknowledgement);

  /**
   * Receives a list of items.
   * @param receipts List of PurchaseOrderItem data objects.
   */
  public void receiveItems(List receipts);

  /**
   * Gets root data object containing a list of data objects from the data source based on criteria.
   * <p>
   * These are the supported data sources:
   * <ul>
   * <li>PurchaseOrderLine: </li>
   * <ul>
   * <li>Data Object: {@link PurchaseOrderLine PurchaseOrderLine}</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>{@link PurchaseOrderLineFilter PurchaseOrderLineFilter}</li>
   * </ul>
   * </ul>
   * <li>PurchaseOrder: </li>
   * <ul>
   * <li>Data Object: {@link PurchaseOrder PurchaseOrder}</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>{@link PurchaseOrderFilter PurchaseOrderFilter}</li>
   * </ul>
   * </ul>
   * <li>PurchaseOrderShipment: </li>
   * <ul>
   * <li>Data Object: {@link PurchaseOrderShipment PurchaseOrderShipment}</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>{@link PurchaseOrderShipmentFilter PurchaseOrderShipmentFilter}</li>
   * </ul>
   * </ul>
   * <li>PurchaseOrder_BuyerDomain: </li>
   * <ul>
   * <li>Data Object: {@link Buyer Buyer}</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>{@link BuyerFilter BuyerFilter}</li>
   * </ul>
   * </ul>
   * <li>PurchaseOrder_SupplierAndSiteDomain: </li>
   * <ul>
   * <li>Data Object: {@link SupplierAndSite SupplierAndSite}</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>{@link SupplierAndSiteFilter SupplierAndSiteFilter}</li>
   * </ul>
   * </ul>
   * <li>CarrierDomain: </li>
   * <ul>
   * <li>Data Object: /oracle/apps/fnd/framework/toolbox/tutorial/CarrierDomain</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>/oracle/apps/fnd/framework/toolbox/tutorial/CarrierDomainFilter</li>
   * </ul>
   * </ul>
   * <li>CurrenciesDomain: </li>
   * <ul>
   * <li>Data Object: /oracle/apps/fnd/framework/toolbox/tutorial/CurrencyDomain</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>/oracle/apps/fnd/framework/toolbox/tutorial/CurrencyDomainFilter</li>
   * </ul>
   * </ul>
   * <li>OrderStatusesDomain: </li>
   * <ul>
   * <li>Data Object: /oracle/apps/fnd/framework/toolbox/tutorial/OrderStatusDomain</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>/oracle/apps/fnd/framework/toolbox/tutorial/OrderStatusDomainFilter</li>
   * </ul>
   * </ul>
   * <li>PaymentTermsDomain: </li>
   * <ul>
   * <li>Data Object: /oracle/apps/fnd/framework/toolbox/tutorial/PaymentTermDomain</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>/oracle/apps/fnd/framework/toolbox/tutorial/PaymentTermDomainFilter</li>
   * </ul>
   * </ul>
   * <li>UnitOfMeasuresDomain: </li>
   * <ul>
   * <li>Data Object: /oracle/apps/fnd/framework/toolbox/tutorial/UnitOfMeasureDomain</li>
   * <li>Filter Data Objects: </li>
   * <ul>
   * <li>/oracle/apps/fnd/framework/toolbox/tutorial/UnitOfMeasureDomainFilter</li>
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
   * <li>PurchaseOrderLine: </li>
   * <ul>
   * <li>Data Object: {@link PurchaseOrderLine PurchaseOrderLine}</li>
   * <li>Allowed operations: {@link DataProcessorService#OPERATION_CREATE Create}, {@link DataProcessorService#OPERATION_UPDATE Update}, {@link DataProcessorService#OPERATION_MERGE Merge}, {@link DataProcessorService#OPERATION_DELETE Delete}</li>
   * </ul>
   * <li>PurchaseOrder: </li>
   * <ul>
   * <li>Data Object: {@link PurchaseOrder PurchaseOrder}</li>
   * <li>Allowed operations: {@link DataProcessorService#OPERATION_CREATE Create}, {@link DataProcessorService#OPERATION_UPDATE Update}, {@link DataProcessorService#OPERATION_MERGE Merge}, {@link DataProcessorService#OPERATION_DELETE Delete}</li>
   * </ul>
   * <li>PurchaseOrderShipment: </li>
   * <ul>
   * <li>Data Object: {@link PurchaseOrderShipment PurchaseOrderShipment}</li>
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
   * @param purchaseOrderServiceRoot The root data object containing a list of data objects to be processed.
   * @return returns a root data object with one of the following:
   * <ul>
   * <li>a list of fully populated data objects if return mode in control is {@link ProcessControl#RETURN_FULL RETURN_FULL}</li>
   * <li>a list of data objects with just primary keys if return mode in control is {@link ProcessControl#RETURN_KEY RETURN_KEY}</li>
   * <li>an empty list if return mode in control is {@link ProcessControl#RETURN_NONE RETURN_NONE}</li>
   * </ul>
   */
  public DataObject processDataSource(String dataSourceName, String operation, ProcessControl processControl, DataObject purchaseOrderServiceRoot);
}
