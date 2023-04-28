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
 * The Buyers domain
 * <p>
 * <b>Primary Key Attributes:</b>
 * <ul>
 * <li>EmployeeId
 * </ul>
 */

public class Buyer extends DataObjectImpl 
{
  /**
   * Oracle Applications internal source control identifier
   */
  public static final String RCS_ID = "$Header: Buyer.java 120.10 2008/04/03 07:27:14 atgops1 ship $";


  /**
   * Oracle Applications internal source control identifier
   */
  public static final boolean RCS_ID_RECORDED = VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial");


  /**
   * Used for optimizing serialization.
   */
  private static final long serialVersionUID = 1;


  public static final String QUALIFIED_NAME = "/oracle/apps/fnd/framework/toolbox/tutorial/Buyer";


  private static final int BASE_ATTRIBUTE_POSITION = DataObjectImpl.ATTRIBUTE_NAMES.length;
  private static final String[] ATTRIBUTE_NAMES = new String[BASE_ATTRIBUTE_POSITION + 2];
  private static final String[] ATTRIBUTE_INNER_CLASS = new String[BASE_ATTRIBUTE_POSITION + 2];
  private static final int SVC_ATTR_EMPLOYEE_ID = BASE_ATTRIBUTE_POSITION + 0;
  private static final int SVC_ATTR_FULL_NAME = BASE_ATTRIBUTE_POSITION + 1;

  static  
  {
    System.arraycopy(DataObjectImpl.ATTRIBUTE_NAMES, 0, ATTRIBUTE_NAMES, 0, BASE_ATTRIBUTE_POSITION);
    ATTRIBUTE_NAMES[SVC_ATTR_EMPLOYEE_ID] = "EmployeeId";
    ATTRIBUTE_NAMES[SVC_ATTR_FULL_NAME] = "FullName";
  }

  public Buyer()
  {
    super();
    mAttributeNames = ATTRIBUTE_NAMES;
    mAttributeInnerClasses = ATTRIBUTE_INNER_CLASS;
  }

  /**
   * Gets Employee Id.
   * @return Employee Id
   */
  public Number getEmployeeId()
  {
    return (Number)getSVCProperty(SVC_ATTR_EMPLOYEE_ID);
  }

  /**
   * Sets Employee Id.
   * @param value Employee Id
   */
  public void setEmployeeId(Number value)
  {
    setSVCProperty(SVC_ATTR_EMPLOYEE_ID, value);
  }

  /**
   * Gets Full Name.
   * @return Full Name
   */
  public String getFullName()
  {
    return (String)getSVCProperty(SVC_ATTR_FULL_NAME);
  }

  /**
   * Sets Full Name.
   * @param value Full Name
   */
  public void setFullName(String value)
  {
    setSVCProperty(SVC_ATTR_FULL_NAME, value);
  }

  public void setPropertyInvokeAccessor(int index, Object value)
  {
    if (index == SVC_ATTR_EMPLOYEE_ID)
      setEmployeeId((Number)value);
    else if (index == SVC_ATTR_FULL_NAME)
      setFullName((String)value);
    else
      setSVCProperty(index, value);
  }

  public Object getPropertyInvokeAccessor(int index)
  {
    if (index == SVC_ATTR_EMPLOYEE_ID)
      return getEmployeeId();
    else if (index == SVC_ATTR_FULL_NAME)
      return getFullName();
    else
      return getSVCProperty(index);
  }
}
