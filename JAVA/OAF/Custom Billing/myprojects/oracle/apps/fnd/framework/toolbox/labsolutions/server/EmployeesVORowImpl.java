/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;
import oracle.jbo.domain.Date;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAViewRowImpl;


public class EmployeesVORowImpl extends OAViewRowImpl
{

  protected static final int EMPLOYEEID = 0;
  protected static final int EMPLOYEENAME = 1;
  protected static final int EMAILADDRESS = 2;
  protected static final int MANAGERNAME = 3;
  protected static final int MANAGERID = 4;
  protected static final int FIRSTNAME = 5;
  protected static final int LASTNAME = 6;
  protected static final int SALARY = 7;
  protected static final int STARTDATE = 8;
  protected static final int ENDDATE = 9;
  protected static final int MANAGEREMAIL = 10;
  protected static final int POSITIONDISPLAY = 11;
  protected static final int EMPLOYEESTATUS = 12;
  protected static final int DELETESWITCHER = 13;
  public static final String RCS_ID="$Header: EmployeesVORowImpl.java 120.1 2005/06/06 09:59:28 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.server");

  /**
   *
   * This is the default constructor (do not remove)
   */
  public EmployeesVORowImpl()
  {
  }

  /**
   *
   * Gets EmployeeEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.EmployeeEOImpl getEmployeeEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.EmployeeEOImpl)getEntity(0);
  }

  /**
   *
   * Gets EmployeeEO1 entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.EmployeeEOImpl getEmployeeEO1()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.EmployeeEOImpl)getEntity(1);
  }

  /**
   *
   * Gets the attribute value for EMPLOYEE_ID using the alias name EmployeeId
   */
  public Number getEmployeeId()
  {
    return (Number)getAttributeInternal(EMPLOYEEID);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for EMPLOYEE_ID using the alias name EmployeeId
   */
  public void setEmployeeId(Number value)
  {
    setAttributeInternal(EMPLOYEEID, value);
  }



  /**
   *
   * Gets the attribute value for EMAIL_ADDRESS using the alias name EmailAddress
   */
  public String getEmailAddress()
  {
    return (String)getAttributeInternal(EMAILADDRESS);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for EMAIL_ADDRESS using the alias name EmailAddress
   */
  public void setEmailAddress(String value)
  {
    setAttributeInternal(EMAILADDRESS, value);
  }




  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case EMPLOYEEID:
        return getEmployeeId();
      case EMPLOYEENAME:
        return getEmployeeName();
      case EMAILADDRESS:
        return getEmailAddress();
      case MANAGERNAME:
        return getManagerName();
      case MANAGERID:
        return getManagerId();
      case FIRSTNAME:
        return getFirstName();
      case LASTNAME:
        return getLastName();
      case SALARY:
        return getSalary();
      case STARTDATE:
        return getStartDate();
      case ENDDATE:
        return getEndDate();
      case MANAGEREMAIL:
        return getManagerEmail();
      case POSITIONDISPLAY:
        return getPositionDisplay();
      case EMPLOYEESTATUS:
        return getEmployeeStatus();
      case DELETESWITCHER:
        return getDeleteSwitcher();
      default:
        return super.getAttrInvokeAccessor(index, attrDef);
      }
  }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case EMPLOYEEID:
        setEmployeeId((Number)value);
        return;
      case EMPLOYEENAME:
        setEmployeeName((String)value);
        return;
      case EMAILADDRESS:
        setEmailAddress((String)value);
        return;
      case MANAGERNAME:
        setManagerName((String)value);
        return;
      case MANAGERID:
        setManagerId((Number)value);
        return;
      case FIRSTNAME:
        setFirstName((String)value);
        return;
      case LASTNAME:
        setLastName((String)value);
        return;
      case SALARY:
        setSalary((Number)value);
        return;
      case STARTDATE:
        setStartDate((Date)value);
        return;
      case ENDDATE:
        setEndDate((Date)value);
        return;
      case MANAGEREMAIL:
        setManagerEmail((String)value);
        return;
      case POSITIONDISPLAY:
        setPositionDisplay((String)value);
        return;
      case EMPLOYEESTATUS:
        setEmployeeStatus((String)value);
        return;
      case DELETESWITCHER:
        setDeleteSwitcher((String)value);
        return;
      default:
        super.setAttrInvokeAccessor(index, value, attrDef);
        return;
      }
  }

  /**
   *
   * Gets the attribute value for FULL_NAME using the alias name ManagerName
   */
  public String getManagerName()
  {
    return (String)getAttributeInternal(MANAGERNAME);
  }

  public void setManagerName(String value)
  {
  }

  /**
   *
   * Gets the attribute value for EMPLOYEE_ID using the alias name ManagerId
   */
  public Number getManagerId()
  {
    return (Number)getAttributeInternal(MANAGERID);
  }

  public void setManagerId(Number value)
  {
  }

  /**
   *
   * Gets the attribute value for FIRST_NAME using the alias name FirstName
   */
  public String getFirstName()
  {
    return (String)getAttributeInternal(FIRSTNAME);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for FIRST_NAME using the alias name FirstName
   */
  public void setFirstName(String value)
  {
    setAttributeInternal(FIRSTNAME, value);
  }

  /**
   *
   * Gets the attribute value for LAST_NAME using the alias name LastName
   */
  public String getLastName()
  {
    return (String)getAttributeInternal(LASTNAME);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for LAST_NAME using the alias name LastName
   */
  public void setLastName(String value)
  {
    setAttributeInternal(LASTNAME, value);
  }

  /**
   *
   * Gets the attribute value for SALARY using the alias name Salary
   */
  public Number getSalary()
  {
    return (Number)getAttributeInternal(SALARY);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for SALARY using the alias name Salary
   */
  public void setSalary(Number value)
  {
    setAttributeInternal(SALARY, value);
  }

  /**
   *
   * Gets the attribute value for START_DATE using the alias name StartDate
   */
  public Date getStartDate()
  {
    return (Date)getAttributeInternal(STARTDATE);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for START_DATE using the alias name StartDate
   */
  public void setStartDate(Date value)
  {
    setAttributeInternal(STARTDATE, value);
  }

  /**
   *
   * Gets the attribute value for END_DATE using the alias name EndDate
   */
  public Date getEndDate()
  {
    return (Date)getAttributeInternal(ENDDATE);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for END_DATE using the alias name EndDate
   */
  public void setEndDate(Date value)
  {
    setAttributeInternal(ENDDATE, value);
  }

  /**
   *
   * Gets the attribute value for EMAIL_ADDRESS using the alias name ManagerEmail
   */
  public String getManagerEmail()
  {
    return (String)getAttributeInternal(MANAGEREMAIL);
  }

  public void setManagerEmail(String value)
  {
  }

  /**
   *
   * Gets the attribute value for the calculated attribute PositionDisplay
   */
  public String getPositionDisplay()
  {
    return (String)getAttributeInternal(POSITIONDISPLAY);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for the calculated attribute PositionDisplay
   */
  public void setPositionDisplay(String value)
  {
    setAttributeInternal(POSITIONDISPLAY, value);
  }

  /**
   *
   * Gets the attribute value for the calculated attribute EmployeeStatus
   */
  public String getEmployeeStatus()
  {
    return (String)getAttributeInternal(EMPLOYEESTATUS);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for the calculated attribute EmployeeStatus
   */
  public void setEmployeeStatus(String value)
  {
    setAttributeInternal(EMPLOYEESTATUS, value);
  }

  /**
   *
   * Gets the attribute value for the calculated attribute DeleteSwitcher
   */
  public String getDeleteSwitcher()
  {
    return (String)getAttributeInternal(DELETESWITCHER);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for the calculated attribute DeleteSwitcher
   */
  public void setDeleteSwitcher(String value)
  {
    setAttributeInternal(DELETESWITCHER, value);
  }

  /**
   *
   * Gets the attribute value for FULL_NAME using the alias name EmployeeName
   */
  public String getEmployeeName()
  {
    return (String)getAttributeInternal(EMPLOYEENAME);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for FULL_NAME using the alias name EmployeeName
   */
  public void setEmployeeName(String value)
  {
    setAttributeInternal(EMPLOYEENAME, value);
  }



}