/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.jbo.domain.Number;
import oracle.jbo.domain.Date;
import oracle.jbo.server.AttributeDefImpl;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAViewRowImpl;

public class EmployeeFullVORowImpl extends OAViewRowImpl
{
  protected static final int EMPLOYEEID = 0;
  protected static final int FIRSTNAME = 1;
  protected static final int LASTNAME = 2;
  protected static final int EMPLOYEENAME = 3;
  protected static final int EMPLOYEEEMAIL = 4;
  protected static final int MANAGERID = 5;
  protected static final int POSITIONCODE = 6;
  protected static final int SALARY = 7;
  protected static final int STARTDATE = 8;
  protected static final int ENDDATE = 9;
  protected static final int MANAGERNAME = 10;
  protected static final int EMPLOYEEID1 = 11;
  protected static final int MANAGEREMAIL = 12;
  protected static final int POSITIONDISPLAY = 13;
  protected static final int BONUS = 14;
	public static final String RCS_ID="$Header: EmployeeFullVORowImpl.java 120.1 2005/06/06 09:50:17 atgops1 noship $";
	public static final boolean RCS_ID_RECORDED =
		 VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.server");



  /**
   *
   * This is the default constructor (do not remove)
   */
  public EmployeeFullVORowImpl()
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

  /**
   *
   * Gets the attribute value for EMAIL_ADDRESS using the alias name EmployeeEmail
   */
  public String getEmployeeEmail()
  {
    return (String)getAttributeInternal(EMPLOYEEEMAIL);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for EMAIL_ADDRESS using the alias name EmployeeEmail
   */
  public void setEmployeeEmail(String value)
  {
    setAttributeInternal(EMPLOYEEEMAIL, value);
  }

  /**
   *
   * Gets the attribute value for MANAGER_ID using the alias name ManagerId
   */
  public Number getManagerId()
  {
    return (Number)getAttributeInternal(MANAGERID);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for MANAGER_ID using the alias name ManagerId
   */
  public void setManagerId(Number value)
  {
    setAttributeInternal(MANAGERID, value);
  }

  /**
   *
   * Gets the attribute value for POSITION_CODE using the alias name PositionCode
   */
  public String getPositionCode()
  {
    return (String)getAttributeInternal(POSITIONCODE);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for POSITION_CODE using the alias name PositionCode
   */
  public void setPositionCode(String value)
  {
    setAttributeInternal(POSITIONCODE, value);
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
   * Gets the attribute value for FULL_NAME using the alias name ManagerName
   */
  public String getManagerName()
  {
    return (String)getAttributeInternal(MANAGERNAME);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for FULL_NAME using the alias name ManagerName
   */
  public void setManagerName(String value)
  {
    // For a reference EO, we don't actually want to set the value after it is
    // selected from the LOV.  By setting the manager id on the driving EO, 
    // the correct manager name value will automatically fault in for the
    // reference EO.
    
    setAttributeInternal(MANAGERNAME, value);
  }

  /**
   *
   * Gets the attribute value for EMPLOYEE_ID using the alias name EmployeeId1
   */
  public Number getEmployeeId1()
  {
    return (Number)getAttributeInternal(EMPLOYEEID1);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for EMPLOYEE_ID using the alias name EmployeeId1
   */
  public void setEmployeeId1(Number value)
  {
    setAttributeInternal(EMPLOYEEID1, value);
  }

  /**
   *
   * Gets the attribute value for EMAIL_ADDRESS using the alias name ManagerEmail
   */
  public String getManagerEmail()
  {
    return (String)getAttributeInternal(MANAGEREMAIL);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for EMAIL_ADDRESS using the alias name ManagerEmail
   */
  public void setManagerEmail(String value)
  {
    setAttributeInternal(MANAGEREMAIL, value);
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

  /**Gets the attribute value for the calculated attribute bonus
   */
  public String getbonus()
  {
    return (String) getAttributeInternal(BONUS);
  }

  /**Sets <code>value</code> as the attribute value for the calculated attribute bonus
   */
  public void setbonus(String value)
  {
    setAttributeInternal(BONUS, value);
  }
  
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case EMPLOYEEID:
        return getEmployeeId();
      case FIRSTNAME:
        return getFirstName();
      case LASTNAME:
        return getLastName();
      case EMPLOYEENAME:
        return getEmployeeName();
      case EMPLOYEEEMAIL:
        return getEmployeeEmail();
      case MANAGERID:
        return getManagerId();
      case POSITIONCODE:
        return getPositionCode();
      case SALARY:
        return getSalary();
      case STARTDATE:
        return getStartDate();
      case ENDDATE:
        return getEndDate();
      case MANAGERNAME:
        return getManagerName();
      case EMPLOYEEID1:
        return getEmployeeId1();
      case MANAGEREMAIL:
        return getManagerEmail();
      case POSITIONDISPLAY:
        return getPositionDisplay();
      case BONUS:
        return getbonus();
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
      case FIRSTNAME:
        setFirstName((String)value);
        return;
      case LASTNAME:
        setLastName((String)value);
        return;
      case EMPLOYEENAME:
        setEmployeeName((String)value);
        return;
      case EMPLOYEEEMAIL:
        setEmployeeEmail((String)value);
        return;
      case MANAGERID:
        setManagerId((Number)value);
        return;
      case POSITIONCODE:
        setPositionCode((String)value);
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
      case MANAGERNAME:
        setManagerName((String)value);
        return;
      case EMPLOYEEID1:
        setEmployeeId1((Number)value);
        return;
      case MANAGEREMAIL:
        setManagerEmail((String)value);
        return;
      case POSITIONDISPLAY:
        setPositionDisplay((String)value);
        return;
      case BONUS:
        setbonus((String)value);   
        return;
      default:
        super.setAttrInvokeAccessor(index, value, attrDef);
        return;
      }
  }
}