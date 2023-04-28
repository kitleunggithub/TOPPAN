/*+===========================================================================+
  |   Copyright (c) 2006 Oracle Corporation, Redwood Shores, CA, USA          |
  |                         All rights reserved.                              |
  +===========================================================================+
  |  HISTORY                                                                  |
  +===========================================================================+*/

//javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial;
import java.lang.String;
import java.util.List;
import oracle.apps.fnd.common.VersionInfo;
import oracle.jbo.domain.Number;
import oracle.svc.DataObjectImpl;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------
/**
 * The data object representing a purchase order document.
 * <p>
 * <b>Primary Key Attributes:</b>
 * <ul>
 * <li>PoNumber
 * </ul>
 * <b>Alternate Key Sets (in order of precedence):</b>
 * <ol>
 * <li>Key Set Name = ByDesc, Key Set Attributes:
 * <ul>
 * <li>Description
 * </ul>
 * </ol>
 */

public class PurchaseOrder extends DataObjectImpl 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: PurchaseOrder.java 120.12 2008/04/03 07:27:51 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/tutorial/PurchaseOrder";


  private static final int BASE_ATTRIBUTE_POSITION = DataObjectImpl.ATTRIBUTE_NAMES.length;
  private static final String[] ATTRIBUTE_NAMES = new String[BASE_ATTRIBUTE_POSITION + 19];
  private static final String[] ATTRIBUTE_INNER_CLASS = new String[BASE_ATTRIBUTE_POSITION + 19];
  private static final int SVC_ATTR_PO_NUMBER = BASE_ATTRIBUTE_POSITION + 0;
  private static final int SVC_ATTR_DESCRIPTION = BASE_ATTRIBUTE_POSITION + 1;
  private static final int SVC_ATTR_STATUS_CODE = BASE_ATTRIBUTE_POSITION + 2;
  private static final int SVC_ATTR_SUPPLIER_ID = BASE_ATTRIBUTE_POSITION + 3;
  private static final int SVC_ATTR_SUPPLIER_SITE_ID = BASE_ATTRIBUTE_POSITION + 4;
  private static final int SVC_ATTR_CURRENCY_CODE = BASE_ATTRIBUTE_POSITION + 5;
  private static final int SVC_ATTR_BUYER_ID = BASE_ATTRIBUTE_POSITION + 6;
  private static final int SVC_ATTR_PAYMENT_TERMS_CODE = BASE_ATTRIBUTE_POSITION + 7;
  private static final int SVC_ATTR_CARRIER_CODE = BASE_ATTRIBUTE_POSITION + 8;
  private static final int SVC_ATTR_RATE = BASE_ATTRIBUTE_POSITION + 9;
  private static final int SVC_ATTR_BUYER_NAME = BASE_ATTRIBUTE_POSITION + 10;
  private static final int SVC_ATTR_SUPPLIER_NAME = BASE_ATTRIBUTE_POSITION + 11;
  private static final int SVC_ATTR_SUPPLIER_SITE_NAME = BASE_ATTRIBUTE_POSITION + 12;
  private static final int SVC_ATTR_SUPPLIER_ATTACHMENTS = BASE_ATTRIBUTE_POSITION + 13;
  private static final int SVC_ATTR_POATTACHMENTS = BASE_ATTRIBUTE_POSITION + 14;
  private static final int SVC_ATTR_DYNAMIC_ATTRIBUTE_GROUPS = BASE_ATTRIBUTE_POSITION + 15;
  private static final int SVC_ATTR_KFF1_ANCHOR_ATTRIBUTE = BASE_ATTRIBUTE_POSITION + 16;
  private static final int SVC_ATTR_PURCHASE_ORDER_LINE = BASE_ATTRIBUTE_POSITION + 17;

  static  
  {
    System.arraycopy(DataObjectImpl.ATTRIBUTE_NAMES, 0, ATTRIBUTE_NAMES, 0, BASE_ATTRIBUTE_POSITION);
    ATTRIBUTE_NAMES[SVC_ATTR_PO_NUMBER] = "PoNumber";
    ATTRIBUTE_NAMES[SVC_ATTR_DESCRIPTION] = "Description";
    ATTRIBUTE_NAMES[SVC_ATTR_STATUS_CODE] = "StatusCode";
    ATTRIBUTE_NAMES[SVC_ATTR_SUPPLIER_ID] = "SupplierId";
    ATTRIBUTE_NAMES[SVC_ATTR_SUPPLIER_SITE_ID] = "SupplierSiteId";
    ATTRIBUTE_NAMES[SVC_ATTR_CURRENCY_CODE] = "CurrencyCode";
    ATTRIBUTE_NAMES[SVC_ATTR_BUYER_ID] = "BuyerId";
    ATTRIBUTE_NAMES[SVC_ATTR_PAYMENT_TERMS_CODE] = "PaymentTermsCode";
    ATTRIBUTE_NAMES[SVC_ATTR_CARRIER_CODE] = "CarrierCode";
    ATTRIBUTE_NAMES[SVC_ATTR_RATE] = "Rate";
    ATTRIBUTE_NAMES[SVC_ATTR_BUYER_NAME] = "BuyerName";
    ATTRIBUTE_NAMES[SVC_ATTR_SUPPLIER_NAME] = "SupplierName";
    ATTRIBUTE_NAMES[SVC_ATTR_SUPPLIER_SITE_NAME] = "SupplierSiteName";
    ATTRIBUTE_NAMES[SVC_ATTR_SUPPLIER_ATTACHMENTS] = "SupplierAttachments";
    ATTRIBUTE_INNER_CLASS[SVC_ATTR_SUPPLIER_ATTACHMENTS] = "oracle.apps.fnd.framework.svc.AttachedDocument";
    ATTRIBUTE_NAMES[SVC_ATTR_POATTACHMENTS] = "POAttachments";
    ATTRIBUTE_INNER_CLASS[SVC_ATTR_POATTACHMENTS] = "oracle.apps.fnd.framework.svc.AttachedDocument";
    ATTRIBUTE_NAMES[SVC_ATTR_DYNAMIC_ATTRIBUTE_GROUPS] = "DynamicAttributeGroups";
    ATTRIBUTE_INNER_CLASS[SVC_ATTR_DYNAMIC_ATTRIBUTE_GROUPS] = "oracle.svc.dag.DynamicAttributeGroup";
    ATTRIBUTE_NAMES[SVC_ATTR_KFF1_ANCHOR_ATTRIBUTE] = "KFF1_AnchorAttribute";
    ATTRIBUTE_NAMES[SVC_ATTR_PURCHASE_ORDER_LINE] = "PurchaseOrderLine";
    ATTRIBUTE_INNER_CLASS[SVC_ATTR_PURCHASE_ORDER_LINE] = "oracle.apps.fnd.framework.toolbox.tutorial.PurchaseOrderLine";
  }

  public PurchaseOrder()
  {
    super();
    mAttributeNames = ATTRIBUTE_NAMES;
    mAttributeInnerClasses = ATTRIBUTE_INNER_CLASS;
  }

  /**
   * Gets Po Number.
   * @return Purchase order unique identifier.
   */
  public Number getPoNumber()
  {
    return (Number)getSVCProperty(SVC_ATTR_PO_NUMBER);
  }

  /**
   * Sets Po Number.
   * @param value Purchase order unique identifier. The Purchase Order Number.
   */
  public void setPoNumber(Number value)
  {
    setSVCProperty(SVC_ATTR_PO_NUMBER, value);
  }

  /**
   * Gets Description.
   * @return A brief description of the purchase order.
   */
  public String getDescription()
  {
    return (String)getSVCProperty(SVC_ATTR_DESCRIPTION);
  }

  /**
   * Sets Description.
   * @param value A brief description of the purchase order.
   */
  public void setDescription(String value)
  {
    setSVCProperty(SVC_ATTR_DESCRIPTION, value);
  }

  /**
   * Gets Status Code.
   * @return Internal purchase order processing state.
   */
  public String getStatusCode()
  {
    return (String)getSVCProperty(SVC_ATTR_STATUS_CODE);
  }

  /**
   * Sets Status Code.
   * @param value Internal purchase order processing state.
   */
  public void setStatusCode(String value)
  {
    setSVCProperty(SVC_ATTR_STATUS_CODE, value);
  }

  /**
   * Gets Supplier Id.
   * @return Supplier unique identifier.
   */
  public Number getSupplierId()
  {
    return (Number)getSVCProperty(SVC_ATTR_SUPPLIER_ID);
  }

  /**
   * Sets Supplier Id.
   * @param value Supplier unique identifier.
   */
  public void setSupplierId(Number value)
  {
    setSVCProperty(SVC_ATTR_SUPPLIER_ID, value);
  }

  /**
   * Gets Supplier Site Id.
   * @return Supplier site unique identifier.
   */
  public Number getSupplierSiteId()
  {
    return (Number)getSVCProperty(SVC_ATTR_SUPPLIER_SITE_ID);
  }

  /**
   * Sets Supplier Site Id.
   * @param value Supplier site unique identifier.
   */
  public void setSupplierSiteId(Number value)
  {
    setSVCProperty(SVC_ATTR_SUPPLIER_SITE_ID, value);
  }

  /**
   * Gets Currency Code.
   * @return ISO standard currency code.
   */
  public String getCurrencyCode()
  {
    return (String)getSVCProperty(SVC_ATTR_CURRENCY_CODE);
  }

  /**
   * Sets Currency Code.
   * @param value ISO standard currency code.
   */
  public void setCurrencyCode(String value)
  {
    setSVCProperty(SVC_ATTR_CURRENCY_CODE, value);
  }

  /**
   * Gets Buyer Id.
   * @return Buyer unique identifier.
   */
  public Number getBuyerId()
  {
    return (Number)getSVCProperty(SVC_ATTR_BUYER_ID);
  }

  /**
   * Sets Buyer Id.
   * @param value Buyer unique identifier.
   */
  public void setBuyerId(Number value)
  {
    setSVCProperty(SVC_ATTR_BUYER_ID, value);
  }

  /**
   * Gets Payment Terms Code.
   * @return Purchase order payment terms.
   */
  public String getPaymentTermsCode()
  {
    return (String)getSVCProperty(SVC_ATTR_PAYMENT_TERMS_CODE);
  }

  /**
   * Sets Payment Terms Code.
   * @param value Purchase order payment terms.
   */
  public void setPaymentTermsCode(String value)
  {
    setSVCProperty(SVC_ATTR_PAYMENT_TERMS_CODE, value);
  }

  /**
   * Gets Carrier Code.
   * @return Designated purchase order carrier.
   */
  public String getCarrierCode()
  {
    return (String)getSVCProperty(SVC_ATTR_CARRIER_CODE);
  }

  /**
   * Sets Carrier Code.
   * @param value Designated purchase order carrier.
   */
  public void setCarrierCode(String value)
  {
    setSVCProperty(SVC_ATTR_CARRIER_CODE, value);
  }

  /**
   * Gets Rate.
   * @return Exchange rate for foreign currency.
   */
  public Number getRate()
  {
    return (Number)getSVCProperty(SVC_ATTR_RATE);
  }

  /**
   * Sets Rate.
   * @param value Exchange rate for foreign currency.
   */
  public void setRate(Number value)
  {
    setSVCProperty(SVC_ATTR_RATE, value);
  }

  /**
   * Gets Buyer Name.
   * @return Buyer Name.
   */
  public String getBuyerName()
  {
    return (String)getSVCProperty(SVC_ATTR_BUYER_NAME);
  }

  /**
   * Sets Buyer Name.
   * @param value Buyer Name.
   */
  public void setBuyerName(String value)
  {
    setSVCProperty(SVC_ATTR_BUYER_NAME, value);
  }

  /**
   * Gets Supplier Name.
   * @return Supplier name.
   */
  public String getSupplierName()
  {
    return (String)getSVCProperty(SVC_ATTR_SUPPLIER_NAME);
  }

  /**
   * Sets Supplier Name.
   * @param value Supplier name.
   */
  public void setSupplierName(String value)
  {
    setSVCProperty(SVC_ATTR_SUPPLIER_NAME, value);
  }

  /**
   * Gets Supplier Site Name.
   * @return Supplier site unique identifier.
   */
  public String getSupplierSiteName()
  {
    return (String)getSVCProperty(SVC_ATTR_SUPPLIER_SITE_NAME);
  }

  /**
   * Sets Supplier Site Name.
   * @param value Supplier site unique identifier.
   */
  public void setSupplierSiteName(String value)
  {
    setSVCProperty(SVC_ATTR_SUPPLIER_SITE_NAME, value);
  }

  /**
   * Gets Supplier Attachments.
   * @return SupplierAttachments
   */
  public List getSupplierAttachments()
  {
    return (List)getSVCProperty(SVC_ATTR_SUPPLIER_ATTACHMENTS);
  }

  /**
   * Sets Supplier Attachments.
   * @param value SupplierAttachments
   */
  public void setSupplierAttachments(List value)
  {
    setSVCProperty(SVC_ATTR_SUPPLIER_ATTACHMENTS, value);
  }

  /**
   * Gets POAttachments.
   * @return POAttachments
   */
  public List getPOAttachments()
  {
    return (List)getSVCProperty(SVC_ATTR_POATTACHMENTS);
  }

  /**
   * Sets POAttachments.
   * @param value POAttachments
   */
  public void setPOAttachments(List value)
  {
    setSVCProperty(SVC_ATTR_POATTACHMENTS, value);
  }

  /**
   * Gets Dynamic Attribute Groups.
   * @return DynamicAttributeGroups
   */
  public List getDynamicAttributeGroups()
  {
    return (List)getSVCProperty(SVC_ATTR_DYNAMIC_ATTRIBUTE_GROUPS);
  }

  /**
   * Sets Dynamic Attribute Groups.
   * @param value DynamicAttributeGroups
   */
  public void setDynamicAttributeGroups(List value)
  {
    setSVCProperty(SVC_ATTR_DYNAMIC_ATTRIBUTE_GROUPS, value);
  }

  /**
   * Gets KFF1_Anchor Attribute.
   * @return KFF1_Anchor Attribute
   */
  public String getKFF1_AnchorAttribute()
  {
    return (String)getSVCProperty(SVC_ATTR_KFF1_ANCHOR_ATTRIBUTE);
  }

  /**
   * Sets KFF1_Anchor Attribute.
   * @param value KFF1_Anchor Attribute
   */
  public void setKFF1_AnchorAttribute(String value)
  {
    setSVCProperty(SVC_ATTR_KFF1_ANCHOR_ATTRIBUTE, value);
  }

  /**
   * Gets Purchase Order Lines.
   * @return Purchase Order Lines
   */
  public List getPurchaseOrderLine()
  {
    return (List)getSVCProperty(SVC_ATTR_PURCHASE_ORDER_LINE);
  }

  /**
   * Sets Purchase Order Lines.
   * @param value Purchase Order Lines
   */
  public void setPurchaseOrderLine(List value)
  {
    setSVCProperty(SVC_ATTR_PURCHASE_ORDER_LINE, value);
  }

  public void setPropertyInvokeAccessor(int index, Object value)
  {
    if (index == SVC_ATTR_PO_NUMBER)
      setPoNumber((Number)value);
    else if (index == SVC_ATTR_DESCRIPTION)
      setDescription((String)value);
    else if (index == SVC_ATTR_STATUS_CODE)
      setStatusCode((String)value);
    else if (index == SVC_ATTR_SUPPLIER_ID)
      setSupplierId((Number)value);
    else if (index == SVC_ATTR_SUPPLIER_SITE_ID)
      setSupplierSiteId((Number)value);
    else if (index == SVC_ATTR_CURRENCY_CODE)
      setCurrencyCode((String)value);
    else if (index == SVC_ATTR_BUYER_ID)
      setBuyerId((Number)value);
    else if (index == SVC_ATTR_PAYMENT_TERMS_CODE)
      setPaymentTermsCode((String)value);
    else if (index == SVC_ATTR_CARRIER_CODE)
      setCarrierCode((String)value);
    else if (index == SVC_ATTR_RATE)
      setRate((Number)value);
    else if (index == SVC_ATTR_BUYER_NAME)
      setBuyerName((String)value);
    else if (index == SVC_ATTR_SUPPLIER_NAME)
      setSupplierName((String)value);
    else if (index == SVC_ATTR_SUPPLIER_SITE_NAME)
      setSupplierSiteName((String)value);
    else if (index == SVC_ATTR_SUPPLIER_ATTACHMENTS)
      setSupplierAttachments((List)value);
    else if (index == SVC_ATTR_POATTACHMENTS)
      setPOAttachments((List)value);
    else if (index == SVC_ATTR_DYNAMIC_ATTRIBUTE_GROUPS)
      setDynamicAttributeGroups((List)value);
    else if (index == SVC_ATTR_KFF1_ANCHOR_ATTRIBUTE)
      setKFF1_AnchorAttribute((String)value);
    else if (index == SVC_ATTR_PURCHASE_ORDER_LINE)
      setPurchaseOrderLine((List)value);
    else
      setSVCProperty(index, value);
  }

  public Object getPropertyInvokeAccessor(int index)
  {
    if (index == SVC_ATTR_PO_NUMBER)
      return getPoNumber();
    else if (index == SVC_ATTR_DESCRIPTION)
      return getDescription();
    else if (index == SVC_ATTR_STATUS_CODE)
      return getStatusCode();
    else if (index == SVC_ATTR_SUPPLIER_ID)
      return getSupplierId();
    else if (index == SVC_ATTR_SUPPLIER_SITE_ID)
      return getSupplierSiteId();
    else if (index == SVC_ATTR_CURRENCY_CODE)
      return getCurrencyCode();
    else if (index == SVC_ATTR_BUYER_ID)
      return getBuyerId();
    else if (index == SVC_ATTR_PAYMENT_TERMS_CODE)
      return getPaymentTermsCode();
    else if (index == SVC_ATTR_CARRIER_CODE)
      return getCarrierCode();
    else if (index == SVC_ATTR_RATE)
      return getRate();
    else if (index == SVC_ATTR_BUYER_NAME)
      return getBuyerName();
    else if (index == SVC_ATTR_SUPPLIER_NAME)
      return getSupplierName();
    else if (index == SVC_ATTR_SUPPLIER_SITE_NAME)
      return getSupplierSiteName();
    else if (index == SVC_ATTR_SUPPLIER_ATTACHMENTS)
      return getSupplierAttachments();
    else if (index == SVC_ATTR_POATTACHMENTS)
      return getPOAttachments();
    else if (index == SVC_ATTR_DYNAMIC_ATTRIBUTE_GROUPS)
      return getDynamicAttributeGroups();
    else if (index == SVC_ATTR_KFF1_ANCHOR_ATTRIBUTE)
      return getKFF1_AnchorAttribute();
    else if (index == SVC_ATTR_PURCHASE_ORDER_LINE)
      return getPurchaseOrderLine();
    else
      return getSVCProperty(index);
  }
}
