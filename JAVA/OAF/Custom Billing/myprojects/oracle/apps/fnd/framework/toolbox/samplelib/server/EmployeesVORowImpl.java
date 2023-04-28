/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.server;

import oracle.jbo.domain.Number;
import oracle.jbo.domain.Date;
import oracle.jbo.server.AttributeDefImpl;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAViewRowImpl;

public class EmployeesVORowImpl extends OAViewRowImpl {

    public static final int EMPLOYEEID = 0;
    public static final int TITLE = 1;
    public static final int FIRSTNAME = 2;
    public static final int MIDDLENAMES = 3;
    public static final int LASTNAME = 4;
    public static final int FULLNAME = 5;
    public static final int EMAILADDRESS = 6;
    public static final int MANAGERID = 7;
    public static final int POSITIONCODE = 8;
    public static final int SALARY = 9;
    public static final int STARTDATE = 10;
    public static final int ENDDATE = 11;
    public static final int LASTUPDATEDATE = 12;
    public static final int LASTUPDATEDBY = 13;
    public static final int CREATIONDATE = 14;
    public static final int CREATEDBY = 15;
    public static final int LASTUPDATELOGIN = 16;
    public static final int ATTRIBUTECATEGORY = 17;
    public static final int ATTRIBUTE1 = 18;
    public static final int ATTRIBUTE2 = 19;
    public static final int ATTRIBUTE3 = 20;
    public static final int ATTRIBUTE4 = 21;
    public static final int ATTRIBUTE5 = 22;
    public static final int ATTRIBUTE6 = 23;
    public static final int ATTRIBUTE7 = 24;
    public static final int ATTRIBUTE8 = 25;
    public static final int ATTRIBUTE9 = 26;
    public static final int ATTRIBUTE10 = 27;
    public static final int ATTRIBUTE11 = 28;
    public static final int ATTRIBUTE12 = 29;
    public static final int ATTRIBUTE13 = 30;
    public static final int ATTRIBUTE14 = 31;
    public static final int ATTRIBUTE15 = 32;
    public static final int MANAGERNAME = 33;
    public static final int EMPLOYEE_ID1 = 34;
    public static final int POSITIONDISPLAY = 35;
    public static final int DETAILFLAG = 36;
    protected static final int EMPLOYEESVO = 37;
  public static final String RCS_ID="$Header: EmployeesVORowImpl.java 120.4 2006/07/03 16:56:54 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
    VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.samplelib.server");



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
   * Gets the attribute value for TITLE using the alias name Title
   */
  public String getTitle()
  {
    return (String)getAttributeInternal(TITLE);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for TITLE using the alias name Title
   */
  public void setTitle(String value)
  {
    setAttributeInternal(TITLE, value);
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
   * Gets the attribute value for MIDDLE_NAMES using the alias name MiddleNames
   */
  public String getMiddleNames()
  {
    return (String)getAttributeInternal(MIDDLENAMES);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for MIDDLE_NAMES using the alias name MiddleNames
   */
  public void setMiddleNames(String value)
  {
    setAttributeInternal(MIDDLENAMES, value);
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
   * Gets the attribute value for LAST_UPDATE_DATE using the alias name LastUpdateDate
   */
  public Date getLastUpdateDate()
  {
    return (Date)getAttributeInternal(LASTUPDATEDATE);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for LAST_UPDATE_DATE using the alias name LastUpdateDate
   */
  public void setLastUpdateDate(Date value)
  {
    setAttributeInternal(LASTUPDATEDATE, value);
  }

  /**
   *
   * Gets the attribute value for LAST_UPDATED_BY using the alias name LastUpdatedBy
   */
  public Number getLastUpdatedBy()
  {
    return (Number)getAttributeInternal(LASTUPDATEDBY);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for LAST_UPDATED_BY using the alias name LastUpdatedBy
   */
  public void setLastUpdatedBy(Number value)
  {
    setAttributeInternal(LASTUPDATEDBY, value);
  }

  /**
   *
   * Gets the attribute value for CREATION_DATE using the alias name CreationDate
   */
  public Date getCreationDate()
  {
    return (Date)getAttributeInternal(CREATIONDATE);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for CREATION_DATE using the alias name CreationDate
   */
  public void setCreationDate(Date value)
  {
    setAttributeInternal(CREATIONDATE, value);
  }

  /**
   *
   * Gets the attribute value for CREATED_BY using the alias name CreatedBy
   */
  public Number getCreatedBy()
  {
    return (Number)getAttributeInternal(CREATEDBY);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for CREATED_BY using the alias name CreatedBy
   */
  public void setCreatedBy(Number value)
  {
    setAttributeInternal(CREATEDBY, value);
  }

  /**
   *
   * Gets the attribute value for LAST_UPDATE_LOGIN using the alias name LastUpdateLogin
   */
  public Number getLastUpdateLogin()
  {
    return (Number)getAttributeInternal(LASTUPDATELOGIN);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for LAST_UPDATE_LOGIN using the alias name LastUpdateLogin
   */
  public void setLastUpdateLogin(Number value)
  {
    setAttributeInternal(LASTUPDATELOGIN, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE_CATEGORY using the alias name AttributeCategory
   */
  public String getAttributeCategory()
  {
    return (String)getAttributeInternal(ATTRIBUTECATEGORY);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE_CATEGORY using the alias name AttributeCategory
   */
  public void setAttributeCategory(String value)
  {
    setAttributeInternal(ATTRIBUTECATEGORY, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE1 using the alias name Attribute1
   */
  public String getAttribute1()
  {
    return (String)getAttributeInternal(ATTRIBUTE1);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE1 using the alias name Attribute1
   */
  public void setAttribute1(String value)
  {
    setAttributeInternal(ATTRIBUTE1, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE2 using the alias name Attribute2
   */
  public String getAttribute2()
  {
    return (String)getAttributeInternal(ATTRIBUTE2);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE2 using the alias name Attribute2
   */
  public void setAttribute2(String value)
  {
    setAttributeInternal(ATTRIBUTE2, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE3 using the alias name Attribute3
   */
  public String getAttribute3()
  {
    return (String)getAttributeInternal(ATTRIBUTE3);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE3 using the alias name Attribute3
   */
  public void setAttribute3(String value)
  {
    setAttributeInternal(ATTRIBUTE3, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE4 using the alias name Attribute4
   */
  public String getAttribute4()
  {
    return (String)getAttributeInternal(ATTRIBUTE4);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE4 using the alias name Attribute4
   */
  public void setAttribute4(String value)
  {
    setAttributeInternal(ATTRIBUTE4, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE5 using the alias name Attribute5
   */
  public String getAttribute5()
  {
    return (String)getAttributeInternal(ATTRIBUTE5);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE5 using the alias name Attribute5
   */
  public void setAttribute5(String value)
  {
    setAttributeInternal(ATTRIBUTE5, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE6 using the alias name Attribute6
   */
  public String getAttribute6()
  {
    return (String)getAttributeInternal(ATTRIBUTE6);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE6 using the alias name Attribute6
   */
  public void setAttribute6(String value)
  {
    setAttributeInternal(ATTRIBUTE6, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE7 using the alias name Attribute7
   */
  public String getAttribute7()
  {
    return (String)getAttributeInternal(ATTRIBUTE7);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE7 using the alias name Attribute7
   */
  public void setAttribute7(String value)
  {
    setAttributeInternal(ATTRIBUTE7, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE8 using the alias name Attribute8
   */
  public String getAttribute8()
  {
    return (String)getAttributeInternal(ATTRIBUTE8);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE8 using the alias name Attribute8
   */
  public void setAttribute8(String value)
  {
    setAttributeInternal(ATTRIBUTE8, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE9 using the alias name Attribute9
   */
  public String getAttribute9()
  {
    return (String)getAttributeInternal(ATTRIBUTE9);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE9 using the alias name Attribute9
   */
  public void setAttribute9(String value)
  {
    setAttributeInternal(ATTRIBUTE9, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE10 using the alias name Attribute10
   */
  public String getAttribute10()
  {
    return (String)getAttributeInternal(ATTRIBUTE10);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE10 using the alias name Attribute10
   */
  public void setAttribute10(String value)
  {
    setAttributeInternal(ATTRIBUTE10, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE11 using the alias name Attribute11
   */
  public String getAttribute11()
  {
    return (String)getAttributeInternal(ATTRIBUTE11);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE11 using the alias name Attribute11
   */
  public void setAttribute11(String value)
  {
    setAttributeInternal(ATTRIBUTE11, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE12 using the alias name Attribute12
   */
  public String getAttribute12()
  {
    return (String)getAttributeInternal(ATTRIBUTE12);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE12 using the alias name Attribute12
   */
  public void setAttribute12(String value)
  {
    setAttributeInternal(ATTRIBUTE12, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE13 using the alias name Attribute13
   */
  public String getAttribute13()
  {
    return (String)getAttributeInternal(ATTRIBUTE13);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE13 using the alias name Attribute13
   */
  public void setAttribute13(String value)
  {
    setAttributeInternal(ATTRIBUTE13, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE14 using the alias name Attribute14
   */
  public String getAttribute14()
  {
    return (String)getAttributeInternal(ATTRIBUTE14);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE14 using the alias name Attribute14
   */
  public void setAttribute14(String value)
  {
    setAttributeInternal(ATTRIBUTE14, value);
  }

  /**
   *
   * Gets the attribute value for ATTRIBUTE15 using the alias name Attribute15
   */
  public String getAttribute15()
  {
    return (String)getAttributeInternal(ATTRIBUTE15);
  }

  /**
   *
   * Sets <code>value</code> as attribute value for ATTRIBUTE15 using the alias name Attribute15
   */
  public void setAttribute15(String value)
  {
    setAttributeInternal(ATTRIBUTE15, value);
  }
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case EMPLOYEEID:
            return getEmployeeId();
        case TITLE:
            return getTitle();
        case FIRSTNAME:
            return getFirstName();
        case MIDDLENAMES:
            return getMiddleNames();
        case LASTNAME:
            return getLastName();
        case FULLNAME:
            return getFullName();
        case EMAILADDRESS:
            return getEmailAddress();
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
        case LASTUPDATEDATE:
            return getLastUpdateDate();
        case LASTUPDATEDBY:
            return getLastUpdatedBy();
        case CREATIONDATE:
            return getCreationDate();
        case CREATEDBY:
            return getCreatedBy();
        case LASTUPDATELOGIN:
            return getLastUpdateLogin();
        case ATTRIBUTECATEGORY:
            return getAttributeCategory();
        case ATTRIBUTE1:
            return getAttribute1();
        case ATTRIBUTE2:
            return getAttribute2();
        case ATTRIBUTE3:
            return getAttribute3();
        case ATTRIBUTE4:
            return getAttribute4();
        case ATTRIBUTE5:
            return getAttribute5();
        case ATTRIBUTE6:
            return getAttribute6();
        case ATTRIBUTE7:
            return getAttribute7();
        case ATTRIBUTE8:
            return getAttribute8();
        case ATTRIBUTE9:
            return getAttribute9();
        case ATTRIBUTE10:
            return getAttribute10();
        case ATTRIBUTE11:
            return getAttribute11();
        case ATTRIBUTE12:
            return getAttribute12();
        case ATTRIBUTE13:
            return getAttribute13();
        case ATTRIBUTE14:
            return getAttribute14();
        case ATTRIBUTE15:
            return getAttribute15();
        case MANAGERNAME:
            return getManagerName();
        case EMPLOYEE_ID1:
            return getEmployee_id1();
        case POSITIONDISPLAY:
            return getPositionDisplay();
        case DETAILFLAG:
            return getDetailFlag();
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
        case TITLE:
            setTitle((String)value);
            return;
        case FIRSTNAME:
            setFirstName((String)value);
            return;
        case MIDDLENAMES:
            setMiddleNames((String)value);
            return;
        case LASTNAME:
            setLastName((String)value);
            return;
        case FULLNAME:
            setFullName((String)value);
            return;
        case EMAILADDRESS:
            setEmailAddress((String)value);
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
        case LASTUPDATEDATE:
            setLastUpdateDate((Date)value);
            return;
        case LASTUPDATEDBY:
            setLastUpdatedBy((Number)value);
            return;
        case CREATIONDATE:
            setCreationDate((Date)value);
            return;
        case CREATEDBY:
            setCreatedBy((Number)value);
            return;
        case LASTUPDATELOGIN:
            setLastUpdateLogin((Number)value);
            return;
        case ATTRIBUTECATEGORY:
            setAttributeCategory((String)value);
            return;
        case ATTRIBUTE1:
            setAttribute1((String)value);
            return;
        case ATTRIBUTE2:
            setAttribute2((String)value);
            return;
        case ATTRIBUTE3:
            setAttribute3((String)value);
            return;
        case ATTRIBUTE4:
            setAttribute4((String)value);
            return;
        case ATTRIBUTE5:
            setAttribute5((String)value);
            return;
        case ATTRIBUTE6:
            setAttribute6((String)value);
            return;
        case ATTRIBUTE7:
            setAttribute7((String)value);
            return;
        case ATTRIBUTE8:
            setAttribute8((String)value);
            return;
        case ATTRIBUTE9:
            setAttribute9((String)value);
            return;
        case ATTRIBUTE10:
            setAttribute10((String)value);
            return;
        case ATTRIBUTE11:
            setAttribute11((String)value);
            return;
        case ATTRIBUTE12:
            setAttribute12((String)value);
            return;
        case ATTRIBUTE13:
            setAttribute13((String)value);
            return;
        case ATTRIBUTE14:
            setAttribute14((String)value);
            return;
        case ATTRIBUTE15:
            setAttribute15((String)value);
            return;
        case MANAGERNAME:
            setManagerName((String)value);
            return;
        case EMPLOYEE_ID1:
            setEmployee_id1((Number)value);
            return;
        case POSITIONDISPLAY:
            setPositionDisplay((String)value);
            return;
        case DETAILFLAG:
            setDetailFlag((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
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
   * Gets the attribute value for EMPLOYEE_ID using the alias name Employee_id1
   */
  public Number getEmployee_id1()
  {
    return (Number)getAttributeInternal(EMPLOYEE_ID1);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for EMPLOYEE_ID using the alias name Employee_id1
   */
  public void setEmployee_id1(Number value)
  {
    setAttributeInternal(EMPLOYEE_ID1, value);
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
   * Gets the attribute value for the calculated attribute DetailFlag
   */
  public String getDetailFlag()
  {
    return (String)getAttributeInternal(DETAILFLAG);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute DetailFlag
   */
  public void setDetailFlag(String value)
  {
    setAttributeInternal(DETAILFLAG, value);
  }

  /**
   * 
   * Gets the associated <code>RowIterator</code> using master-detail link EmployeesVO
   */
  public oracle.jbo.RowIterator getEmployeesVO()
  {
    return (oracle.jbo.RowIterator)getAttributeInternal(EMPLOYEESVO);
  }














}