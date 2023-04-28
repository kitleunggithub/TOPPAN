/*+===========================================================================+
  |   Copyright (c) 2006 Oracle Corporation, Redwood Shores, CA, USA          |
  |                         All rights reserved.                              |
  +===========================================================================+
  |  HISTORY                                                                  |
  +===========================================================================+*/

//javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions;
import java.lang.String;
import oracle.apps.fnd.common.VersionInfo;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.svc.DataObjectImpl;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------
/**
 * This is the Supplier Site document value object.
 * <p>
 * <b>Primary Key Attributes:</b>
 * <ul>
 * <li>SupplierSiteId
 * </ul>
 * <b>Alternate Key Sets (in order of precedence):</b>
 * <ol>
 * <li>Key Set Name = ByName, Key Set Attributes:
 * <ul>
 * <li>SiteName
 * <li>Name
 * </ul>
 * </ol>
 */

public class SupplierSite extends DataObjectImpl 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: SupplierSite.java 120.9 2008/04/03 07:25:16 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/labsolutions/SupplierSite";


  private static final int BASE_ATTRIBUTE_POSITION = DataObjectImpl.ATTRIBUTE_NAMES.length;
  private static final String[] ATTRIBUTE_NAMES = new String[BASE_ATTRIBUTE_POSITION + 10];
  private static final String[] ATTRIBUTE_INNER_CLASS = new String[BASE_ATTRIBUTE_POSITION + 10];
  private static final int SVC_ATTR_SUPPLIER_ID = BASE_ATTRIBUTE_POSITION + 0;
  private static final int SVC_ATTR_SUPPLIER_SITE_ID = BASE_ATTRIBUTE_POSITION + 1;
  private static final int SVC_ATTR_SITE_NAME = BASE_ATTRIBUTE_POSITION + 2;
  private static final int SVC_ATTR_PURCHASING_SITE_FLAG = BASE_ATTRIBUTE_POSITION + 3;
  private static final int SVC_ATTR_PAYMENT_TERMS_CODE = BASE_ATTRIBUTE_POSITION + 4;
  private static final int SVC_ATTR_CARRIER_CODE = BASE_ATTRIBUTE_POSITION + 5;
  private static final int SVC_ATTR_ADDRESS_ID = BASE_ATTRIBUTE_POSITION + 6;
  private static final int SVC_ATTR_START_DATE = BASE_ATTRIBUTE_POSITION + 7;
  private static final int SVC_ATTR_END_DATE = BASE_ATTRIBUTE_POSITION + 8;
  private static final int SVC_ATTR_NAME = BASE_ATTRIBUTE_POSITION + 9;

  static  
  {
    System.arraycopy(DataObjectImpl.ATTRIBUTE_NAMES, 0, ATTRIBUTE_NAMES, 0, BASE_ATTRIBUTE_POSITION);
    ATTRIBUTE_NAMES[SVC_ATTR_SUPPLIER_ID] = "SupplierId";
    ATTRIBUTE_NAMES[SVC_ATTR_SUPPLIER_SITE_ID] = "SupplierSiteId";
    ATTRIBUTE_NAMES[SVC_ATTR_SITE_NAME] = "SiteName";
    ATTRIBUTE_NAMES[SVC_ATTR_PURCHASING_SITE_FLAG] = "PurchasingSiteFlag";
    ATTRIBUTE_NAMES[SVC_ATTR_PAYMENT_TERMS_CODE] = "PaymentTermsCode";
    ATTRIBUTE_NAMES[SVC_ATTR_CARRIER_CODE] = "CarrierCode";
    ATTRIBUTE_NAMES[SVC_ATTR_ADDRESS_ID] = "AddressId";
    ATTRIBUTE_NAMES[SVC_ATTR_START_DATE] = "StartDate";
    ATTRIBUTE_NAMES[SVC_ATTR_END_DATE] = "EndDate";
    ATTRIBUTE_NAMES[SVC_ATTR_NAME] = "Name";
  }

  public SupplierSite()
  {
    super();
    mAttributeNames = ATTRIBUTE_NAMES;
    mAttributeInnerClasses = ATTRIBUTE_INNER_CLASS;
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
   * @param value Supplier unique identifier. This is the supplier id.
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
   * @param value Supplier site unique identifier. This is the supplier site id.
   */
  public void setSupplierSiteId(Number value)
  {
    setSVCProperty(SVC_ATTR_SUPPLIER_SITE_ID, value);
  }

  /**
   * Gets Site Name.
   * @return Supplier site name.
   */
  public String getSiteName()
  {
    return (String)getSVCProperty(SVC_ATTR_SITE_NAME);
  }

  /**
   * Sets Site Name.
   * @param value Supplier site name. This is the supplier site name.
   */
  public void setSiteName(String value)
  {
    setSVCProperty(SVC_ATTR_SITE_NAME, value);
  }

  /**
   * Gets Purchasing Site Flag.
   * @return Flag indicating whether purchase orders may be placed for this site.
   */
  public String getPurchasingSiteFlag()
  {
    return (String)getSVCProperty(SVC_ATTR_PURCHASING_SITE_FLAG);
  }

  /**
   * Sets Purchasing Site Flag.
   * @param value Flag indicating whether purchase orders may be placed for this site.
   */
  public void setPurchasingSiteFlag(String value)
  {
    setSVCProperty(SVC_ATTR_PURCHASING_SITE_FLAG, value);
  }

  /**
   * Gets Payment Terms Code.
   * @return Negotiated payment terms for this site.
   */
  public String getPaymentTermsCode()
  {
    return (String)getSVCProperty(SVC_ATTR_PAYMENT_TERMS_CODE);
  }

  /**
   * Sets Payment Terms Code.
   * @param value Negotiated payment terms for this site.
   */
  public void setPaymentTermsCode(String value)
  {
    setSVCProperty(SVC_ATTR_PAYMENT_TERMS_CODE, value);
  }

  /**
   * Gets Carrier Code.
   * @return Negotiated carrier for this site.
   */
  public String getCarrierCode()
  {
    return (String)getSVCProperty(SVC_ATTR_CARRIER_CODE);
  }

  /**
   * Sets Carrier Code.
   * @param value Negotiated carrier for this site.
   */
  public void setCarrierCode(String value)
  {
    setSVCProperty(SVC_ATTR_CARRIER_CODE, value);
  }

  /**
   * Gets Address Id.
   * @return Default shipping address unique identifier.
   */
  public Number getAddressId()
  {
    return (Number)getSVCProperty(SVC_ATTR_ADDRESS_ID);
  }

  /**
   * Sets Address Id.
   * @param value Default shipping address unique identifier.
   */
  public void setAddressId(Number value)
  {
    setSVCProperty(SVC_ATTR_ADDRESS_ID, value);
  }

  /**
   * Gets Start Date.
   * @return Site activation start date.
   */
  public Date getStartDate()
  {
    return (Date)getSVCProperty(SVC_ATTR_START_DATE);
  }

  /**
   * Sets Start Date.
   * @param value Site activation start date.
   */
  public void setStartDate(Date value)
  {
    setSVCProperty(SVC_ATTR_START_DATE, value);
  }

  /**
   * Gets End Date.
   * @return Date after which site is disabled.
   */
  public Date getEndDate()
  {
    return (Date)getSVCProperty(SVC_ATTR_END_DATE);
  }

  /**
   * Sets End Date.
   * @param value Date after which site is disabled.
   */
  public void setEndDate(Date value)
  {
    setSVCProperty(SVC_ATTR_END_DATE, value);
  }

  /**
   * Gets Name.
   * @return Supplier name.
   */
  public String getName()
  {
    return (String)getSVCProperty(SVC_ATTR_NAME);
  }

  /**
   * Sets Name.
   * @param value Supplier name. This is the supplier name.
   */
  public void setName(String value)
  {
    setSVCProperty(SVC_ATTR_NAME, value);
  }

  public void setPropertyInvokeAccessor(int index, Object value)
  {
    if (index == SVC_ATTR_SUPPLIER_ID)
      setSupplierId((Number)value);
    else if (index == SVC_ATTR_SUPPLIER_SITE_ID)
      setSupplierSiteId((Number)value);
    else if (index == SVC_ATTR_SITE_NAME)
      setSiteName((String)value);
    else if (index == SVC_ATTR_PURCHASING_SITE_FLAG)
      setPurchasingSiteFlag((String)value);
    else if (index == SVC_ATTR_PAYMENT_TERMS_CODE)
      setPaymentTermsCode((String)value);
    else if (index == SVC_ATTR_CARRIER_CODE)
      setCarrierCode((String)value);
    else if (index == SVC_ATTR_ADDRESS_ID)
      setAddressId((Number)value);
    else if (index == SVC_ATTR_START_DATE)
      setStartDate((Date)value);
    else if (index == SVC_ATTR_END_DATE)
      setEndDate((Date)value);
    else if (index == SVC_ATTR_NAME)
      setName((String)value);
    else
      setSVCProperty(index, value);
  }

  public Object getPropertyInvokeAccessor(int index)
  {
    if (index == SVC_ATTR_SUPPLIER_ID)
      return getSupplierId();
    else if (index == SVC_ATTR_SUPPLIER_SITE_ID)
      return getSupplierSiteId();
    else if (index == SVC_ATTR_SITE_NAME)
      return getSiteName();
    else if (index == SVC_ATTR_PURCHASING_SITE_FLAG)
      return getPurchasingSiteFlag();
    else if (index == SVC_ATTR_PAYMENT_TERMS_CODE)
      return getPaymentTermsCode();
    else if (index == SVC_ATTR_CARRIER_CODE)
      return getCarrierCode();
    else if (index == SVC_ATTR_ADDRESS_ID)
      return getAddressId();
    else if (index == SVC_ATTR_START_DATE)
      return getStartDate();
    else if (index == SVC_ATTR_END_DATE)
      return getEndDate();
    else if (index == SVC_ATTR_NAME)
      return getName();
    else
      return getSVCProperty(index);
  }
}
