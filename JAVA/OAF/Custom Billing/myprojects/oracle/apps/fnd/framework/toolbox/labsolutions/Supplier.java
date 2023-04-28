/*+===========================================================================+
  |   Copyright (c) 2006 Oracle Corporation, Redwood Shores, CA, USA          |
  |                         All rights reserved.                              |
  +===========================================================================+
  |  HISTORY                                                                  |
  +===========================================================================+*/

//javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions;
import java.lang.String;
import java.util.List;
import oracle.apps.fnd.common.VersionInfo;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.svc.DataObjectImpl;
 //   --------------------------------------------------------
 //   ---    File generated automatically. Do not modify!    --
 //   --------------------------------------------------------
/**
 * This is the Supplier document value object.
 * <p>
 * <b>Primary Key Attributes:</b>
 * <ul>
 * <li>SupplierId
 * </ul>
 * <b>Alternate Key Sets (in order of precedence):</b>
 * <ol>
 * <li>Key Set Name = ByName, Key Set Attributes:
 * <ul>
 * <li>Name
 * </ul>
 * </ol>
 */

public class Supplier extends DataObjectImpl 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: Supplier.java 120.9 2008/04/03 07:24:07 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/labsolutions/Supplier";


  private static final int BASE_ATTRIBUTE_POSITION = DataObjectImpl.ATTRIBUTE_NAMES.length;
  private static final String[] ATTRIBUTE_NAMES = new String[BASE_ATTRIBUTE_POSITION + 6];
  private static final String[] ATTRIBUTE_INNER_CLASS = new String[BASE_ATTRIBUTE_POSITION + 6];
  private static final int SVC_ATTR_SUPPLIER_ID = BASE_ATTRIBUTE_POSITION + 0;
  private static final int SVC_ATTR_NAME = BASE_ATTRIBUTE_POSITION + 1;
  private static final int SVC_ATTR_ON_HOLD_FLAG = BASE_ATTRIBUTE_POSITION + 2;
  private static final int SVC_ATTR_START_DATE = BASE_ATTRIBUTE_POSITION + 3;
  private static final int SVC_ATTR_END_DATE = BASE_ATTRIBUTE_POSITION + 4;
  private static final int SVC_ATTR_SUPPLIER_SITE = BASE_ATTRIBUTE_POSITION + 5;

  static  
  {
    System.arraycopy(DataObjectImpl.ATTRIBUTE_NAMES, 0, ATTRIBUTE_NAMES, 0, BASE_ATTRIBUTE_POSITION);
    ATTRIBUTE_NAMES[SVC_ATTR_SUPPLIER_ID] = "SupplierId";
    ATTRIBUTE_NAMES[SVC_ATTR_NAME] = "Name";
    ATTRIBUTE_NAMES[SVC_ATTR_ON_HOLD_FLAG] = "OnHoldFlag";
    ATTRIBUTE_NAMES[SVC_ATTR_START_DATE] = "StartDate";
    ATTRIBUTE_NAMES[SVC_ATTR_END_DATE] = "EndDate";
    ATTRIBUTE_NAMES[SVC_ATTR_SUPPLIER_SITE] = "SupplierSite";
    ATTRIBUTE_INNER_CLASS[SVC_ATTR_SUPPLIER_SITE] = "oracle.apps.fnd.framework.toolbox.labsolutions.SupplierSite";
  }

  public Supplier()
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
   * @param value Supplier unique identifier. This is the supplier number.
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
   * @param value Supplier name. This is the supplier name.
   */
  public void setName(String value)
  {
    setSVCProperty(SVC_ATTR_NAME, value);
  }

  /**
   * Gets On Hold Flag.
   * @return Flag indicating whether supplier is on hold.
   */
  public String getOnHoldFlag()
  {
    return (String)getSVCProperty(SVC_ATTR_ON_HOLD_FLAG);
  }

  /**
   * Sets On Hold Flag.
   * @param value Flag indicating whether supplier is on hold.
   */
  public void setOnHoldFlag(String value)
  {
    setSVCProperty(SVC_ATTR_ON_HOLD_FLAG, value);
  }

  /**
   * Gets Start Date.
   * @return Supplier activation start date.
   */
  public Date getStartDate()
  {
    return (Date)getSVCProperty(SVC_ATTR_START_DATE);
  }

  /**
   * Sets Start Date.
   * @param value Supplier activation start date.
   */
  public void setStartDate(Date value)
  {
    setSVCProperty(SVC_ATTR_START_DATE, value);
  }

  /**
   * Gets End Date.
   * @return Date after which supplier is disabled.
   */
  public Date getEndDate()
  {
    return (Date)getSVCProperty(SVC_ATTR_END_DATE);
  }

  /**
   * Sets End Date.
   * @param value Date after which supplier is disabled.
   */
  public void setEndDate(Date value)
  {
    setSVCProperty(SVC_ATTR_END_DATE, value);
  }

  /**
   * Gets Supplier Sites.
   * @return Supplier Sites
   */
  public List getSupplierSite()
  {
    return (List)getSVCProperty(SVC_ATTR_SUPPLIER_SITE);
  }

  /**
   * Sets Supplier Sites.
   * @param value Supplier Sites
   */
  public void setSupplierSite(List value)
  {
    setSVCProperty(SVC_ATTR_SUPPLIER_SITE, value);
  }

  public void setPropertyInvokeAccessor(int index, Object value)
  {
    if (index == SVC_ATTR_SUPPLIER_ID)
      setSupplierId((Number)value);
    else if (index == SVC_ATTR_NAME)
      setName((String)value);
    else if (index == SVC_ATTR_ON_HOLD_FLAG)
      setOnHoldFlag((String)value);
    else if (index == SVC_ATTR_START_DATE)
      setStartDate((Date)value);
    else if (index == SVC_ATTR_END_DATE)
      setEndDate((Date)value);
    else if (index == SVC_ATTR_SUPPLIER_SITE)
      setSupplierSite((List)value);
    else
      setSVCProperty(index, value);
  }

  public Object getPropertyInvokeAccessor(int index)
  {
    if (index == SVC_ATTR_SUPPLIER_ID)
      return getSupplierId();
    else if (index == SVC_ATTR_NAME)
      return getName();
    else if (index == SVC_ATTR_ON_HOLD_FLAG)
      return getOnHoldFlag();
    else if (index == SVC_ATTR_START_DATE)
      return getStartDate();
    else if (index == SVC_ATTR_END_DATE)
      return getEndDate();
    else if (index == SVC_ATTR_SUPPLIER_SITE)
      return getSupplierSite();
    else
      return getSVCProperty(index);
  }
}
