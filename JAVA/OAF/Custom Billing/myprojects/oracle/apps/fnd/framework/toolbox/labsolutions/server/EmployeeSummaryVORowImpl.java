/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.jbo.domain.Date;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAViewRowImpl;

public class EmployeeSummaryVORowImpl extends OAViewRowImpl {


    public static final String RCS_ID="$Header: EmployeeSummaryVORowImpl.java 120.1.12010000.3 2009/08/24 11:59:36 sette ship $";
  public static final boolean RCS_ID_RECORDED =
		 VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.server");
    public static final int EMPLOYEEID = 0;                 
    public static final int EMPLOYEENAME = 1;
    public static final int EMPLOYEEEMAIL = 2;
    public static final int MANAGERNAME = 3;
    public static final int MANAGERID = 4;
    public static final int MANAGEREMAIL = 5;
    public static final int POSITIONDISPLAY = 6;
    public static final int SALARY = 7;
    public static final int EMPLOYEESTATUS = 8;
    public static final int DELETESWITCHER = 9;
    public static final int POSITIONCODE = 10;
    public static final int ENDDATE = 11;
    public static final int STARTDATE = 12;

    /**
     *
     * This is the default constructor (do not remove)
     */
  public EmployeeSummaryVORowImpl()
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
    setAttributeInternal(MANAGERNAME, value);
  }

  /**
   *
   * Gets the attribute value for EMPLOYEE_ID using the alias name ManagerId
   */
  public Number getManagerId()
  {
    return (Number)getAttributeInternal(MANAGERID);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for EMPLOYEE_ID using the alias name ManagerId
   */
  public void setManagerId(Number value)
  {
    setAttributeInternal(MANAGERID, value);
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
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case EMPLOYEEID:
            return getEmployeeId();
        case EMPLOYEENAME:
            return getEmployeeName();
        case EMPLOYEEEMAIL:
            return getEmployeeEmail();
        case MANAGERNAME:
            return getManagerName();
        case MANAGERID:
            return getManagerId();
        case MANAGEREMAIL:
            return getManagerEmail();
        case POSITIONDISPLAY:
            return getPositionDisplay();
        case SALARY:
            return getSalary();
        case EMPLOYEESTATUS:
            return getEmployeeStatus();
        case DELETESWITCHER:
            return getDeleteSwitcher();
        case POSITIONCODE:
            return getPositionCode();
        case ENDDATE:
            return getEndDate();
        case STARTDATE:
            return getStartDate();
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
        case EMPLOYEENAME:
            setEmployeeName((String)value);
            return;
        case EMPLOYEEEMAIL:
            setEmployeeEmail((String)value);
            return;
        case MANAGERNAME:
            setManagerName((String)value);
            return;
        case MANAGERID:
            setManagerId((Number)value);
            return;
        case MANAGEREMAIL:
            setManagerEmail((String)value);
            return;
        case POSITIONDISPLAY:
            setPositionDisplay((String)value);
            return;
        case SALARY:
            setSalary((Number)value);
            return;
        case EMPLOYEESTATUS:
            setEmployeeStatus((String)value);
            return;
        case DELETESWITCHER:
            setDeleteSwitcher((String)value);
            return;
        case POSITIONCODE:
            setPositionCode((String)value);
            return;
        case ENDDATE:
            setEndDate((Date)value);
            return;
        case STARTDATE:
            setStartDate((Date)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
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

    /**Gets the attribute value for the calculated attribute Salary
     */
    public Number getSalary() {
        return (Number) getAttributeInternal(SALARY);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Salary
     */
    public void setSalary(Number value) {
        setAttributeInternal(SALARY, value);
    }


    /**Gets the attribute value for EMPLOYEE_ID using the alias name EmployeeId
     */
    public Number getEmployeeId() {
        return (Number) getAttributeInternal(EMPLOYEEID);
    }

    /**Sets <code>value</code> as attribute value for EMPLOYEE_ID using the alias name EmployeeId
     */
    public void setEmployeeId(Number value) {
        setAttributeInternal(EMPLOYEEID, value);
    }


    /**Gets the attribute value for the calculated attribute PositionCode
     */
    public String getPositionCode() {
        return (String) getAttributeInternal(POSITIONCODE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute PositionCode
     */
    public void setPositionCode(String value) {
        setAttributeInternal(POSITIONCODE, value);
    }

    /**Gets the attribute value for the calculated attribute EndDate
     */
    public Date getEndDate() {
        return (Date) getAttributeInternal(ENDDATE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute EndDate
     */
    public void setEndDate(Date value) {
        setAttributeInternal(ENDDATE, value);
    }

    /**Gets the attribute value for the calculated attribute StartDate
     */
    public Date getStartDate() {
        return (Date) getAttributeInternal(STARTDATE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute StartDate
     */
    public void setStartDate(Date value) {
        setAttributeInternal(STARTDATE, value);
    }
}
