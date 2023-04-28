/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.server;
import oracle.apps.fnd.framework.server.OAViewRowImpl;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;
import oracle.jbo.domain.Date;

import oracle.apps.fnd.common.VersionInfo;

public class SimpleEmployeesVORowImpl extends OAViewRowImpl {
    public static final int EMPLOYEEID = 0;
    public static final int FULLNAME = 1;
    public static final int EMAILADDRESS = 2;
    public static final int SALARY = 3;
    public static final int STARTDATE = 4;
    public static final int ENDDATE = 5;
    public static final int POSITIONDISPLAY = 6;
    public static final int MANAGERID = 7;
    public static final int POSITIONCODE = 8;
    public static final int INACTIVE = 9;
    public static final String RCS_ID="$Header: SimpleEmployeesVORowImpl.java 120.2 2006/07/03 17:48:07 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.samplelib.server");
    public static final int DIRECTREPORTS = 10;

    /**
     *
     * This is the default constructor (do not remove)
     */
  public SimpleEmployeesVORowImpl()
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
   * Gets the attribute value for FULL_NAME using the alias name FullName
   */
  public String getFullName()
  {
    return (String)getAttributeInternal(FULLNAME);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for FULL_NAME using the alias name FullName
   */
  public void setFullName(String value)
  {
    setAttributeInternal(FULLNAME, value);
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
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case EMPLOYEEID:
            return getEmployeeId();
        case FULLNAME:
            return getFullName();
        case EMAILADDRESS:
            return getEmailAddress();
        case SALARY:
            return getSalary();
        case STARTDATE:
            return getStartDate();
        case ENDDATE:
            return getEndDate();
        case POSITIONDISPLAY:
            return getPositionDisplay();
        case MANAGERID:
            return getManagerId();
        case POSITIONCODE:
            return getPositionCode();
        case INACTIVE:
            return getInactive();
        case DIRECTREPORTS:
            return getDirectReports();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case EMPLOYEEID:
            setEmployeeId((Number)value);
            return;
        case FULLNAME:
            setFullName((String)value);
            return;
        case EMAILADDRESS:
            setEmailAddress((String)value);
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
        case POSITIONDISPLAY:
            setPositionDisplay((String)value);
            return;
        case MANAGERID:
            setManagerId((Number)value);
            return;
        case POSITIONCODE:
            setPositionCode((String)value);
            return;
        case INACTIVE:
            setInactive((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
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
   * Gets the associated <code>RowIterator</code> using master-detail link DirectReports
   */
  public oracle.jbo.RowIterator getDirectReports()
  {
    return (oracle.jbo.RowIterator)getAttributeInternal(DIRECTREPORTS);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute Inactive
   */
  public String getInactive()
  {
    return (String)getAttributeInternal(INACTIVE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute Inactive
   */
  public void setInactive(String value)
  {
    setAttributeInternal(INACTIVE, value);
  }





}