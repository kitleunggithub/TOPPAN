/*+===========================================================================+
  |   Copyright (c) 2006 Oracle Corporation, Redwood Shores, CA, USA          |
  |                         All rights reserved.                              |
  +===========================================================================+
  |  HISTORY                                                                  |
  +===========================================================================+*/

//javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial;
import java.lang.String;
import oracle.apps.fnd.common.VersionInfo;
import oracle.jbo.domain.Number;
import oracle.svc.DataObjectImpl;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------
/**
 * This is the supplier and supplier site domain data object.
 * <p>
 * <b>Primary Key Attributes:</b>
 * <ul>
 * <li>SupplierId
 * <li>SupplierSiteId
 * </ul>
 */

public class SupplierAndSite extends DataObjectImpl 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: SupplierAndSite.java 120.9 2008/04/03 07:30:33 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/tutorial/SupplierAndSite";


  private static final int BASE_ATTRIBUTE_POSITION = DataObjectImpl.ATTRIBUTE_NAMES.length;
  private static final String[] ATTRIBUTE_NAMES = new String[BASE_ATTRIBUTE_POSITION + 4];
  private static final String[] ATTRIBUTE_INNER_CLASS = new String[BASE_ATTRIBUTE_POSITION + 4];
  private static final int SVC_ATTR_SUPPLIER_ID = BASE_ATTRIBUTE_POSITION + 0;
  private static final int SVC_ATTR_NAME = BASE_ATTRIBUTE_POSITION + 1;
  private static final int SVC_ATTR_SUPPLIER_SITE_ID = BASE_ATTRIBUTE_POSITION + 2;
  private static final int SVC_ATTR_SITE_NAME = BASE_ATTRIBUTE_POSITION + 3;

  static  
  {
    System.arraycopy(DataObjectImpl.ATTRIBUTE_NAMES, 0, ATTRIBUTE_NAMES, 0, BASE_ATTRIBUTE_POSITION);
    ATTRIBUTE_NAMES[SVC_ATTR_SUPPLIER_ID] = "SupplierId";
    ATTRIBUTE_NAMES[SVC_ATTR_NAME] = "Name";
    ATTRIBUTE_NAMES[SVC_ATTR_SUPPLIER_SITE_ID] = "SupplierSiteId";
    ATTRIBUTE_NAMES[SVC_ATTR_SITE_NAME] = "SiteName";
  }

  public SupplierAndSite()
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
   * @param value Supplier unique identifier.
   */
  public void setSupplierId(Number value)
  {
    setSVCProperty(SVC_ATTR_SUPPLIER_ID, value);
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
   * @param value Supplier name.
   */
  public void setName(String value)
  {
    setSVCProperty(SVC_ATTR_NAME, value);
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
   * Gets Site Name.
   * @return Supplier site unique identifier.
   */
  public String getSiteName()
  {
    return (String)getSVCProperty(SVC_ATTR_SITE_NAME);
  }

  /**
   * Sets Site Name.
   * @param value Supplier site unique identifier.
   */
  public void setSiteName(String value)
  {
    setSVCProperty(SVC_ATTR_SITE_NAME, value);
  }

  public void setPropertyInvokeAccessor(int index, Object value)
  {
    if (index == SVC_ATTR_SUPPLIER_ID)
      setSupplierId((Number)value);
    else if (index == SVC_ATTR_NAME)
      setName((String)value);
    else if (index == SVC_ATTR_SUPPLIER_SITE_ID)
      setSupplierSiteId((Number)value);
    else if (index == SVC_ATTR_SITE_NAME)
      setSiteName((String)value);
    else
      setSVCProperty(index, value);
  }

  public Object getPropertyInvokeAccessor(int index)
  {
    if (index == SVC_ATTR_SUPPLIER_ID)
      return getSupplierId();
    else if (index == SVC_ATTR_NAME)
      return getName();
    else if (index == SVC_ATTR_SUPPLIER_SITE_ID)
      return getSupplierSiteId();
    else if (index == SVC_ATTR_SITE_NAME)
      return getSiteName();
    else
      return getSVCProperty(index);
  }
}
