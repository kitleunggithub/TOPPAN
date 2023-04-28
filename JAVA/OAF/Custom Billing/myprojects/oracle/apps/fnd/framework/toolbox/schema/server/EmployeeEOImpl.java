/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAAttrValException;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OARowValException;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.server.OAEntityDefImpl;
import oracle.apps.fnd.framework.server.OAEntityImpl;

import oracle.jbo.AttributeList;
import oracle.jbo.Key;
import oracle.jbo.RowIterator;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.server.EntityDefImpl;

public class EmployeeEOImpl extends OAEntityImpl {

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
    public static final int EMPLOYEEEO1 = 33;
    public static final int PURCHASEORDERHEADEREO = 34;
    public static final String RCS_ID="$Header: EmployeeEOImpl.java 120.2 2006/07/03 18:23:49 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");
    public static final int MANAGERIDEMPLOYEEEO1 = 35;


    /*
   *****************************************************************************
   *  Convenience method returns the EmployeeEntityExpert.
   *****************************************************************************
   */
  public static EmployeeEntityExpert getEmployeeEntityExpert(OADBTransaction txn)
  {
    return (EmployeeEntityExpert)txn.getExpert(EmployeeEOImpl.getDefinitionObject());

  } // end getEmployeeEntityExpert()

  /*
   *****************************************************************************
   * Add attribute defaulting logic here.
   *****************************************************************************
   */
  public void create(AttributeList attributeList)
  {

    super.create(attributeList);

    OADBTransaction transaction = getOADBTransaction();

    Number employeeId = transaction.getSequenceValue("FWK_TBX_EMPLOYEES_S");
    setEmployeeId(employeeId);

    // Start date should be set to sysdate

    setStartDate(transaction.getCurrentDBDate());

  } // end create()

  /*
   *****************************************************************************
   * Add entity delete logic here.
   *****************************************************************************
   */
  public void remove()
  {
    super.remove();

  } // end remove()

  /*
   *****************************************************************************
   * Add entity-level and cross-attribute validation here.
   *****************************************************************************
   */
  protected void validateEntity()
  {
    super.validateEntity();

    // Check to see that manager id is specified unless the employee
    // is the "President," in which case it's OK for this to be null.

    if (getManagerId() == null)
    {
      if (!("PRESIDENT".equals(getPositionCode())))
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "ManagerId", // Attribute Name
                                   getManagerId(), // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_EMP_MANAGER_REQUIRED"); // Message name
      }
    }


    // Validate the start and end dates.

    Date startDate = getStartDate();
    Date endDate = getEndDate();

    // The start date can be entered only when the object is new.  You don't
    // want to call this validation when updating a row.

    if (getEntityState() == STATUS_NEW)
    {
      validateStartDate(startDate);
    }  
    
    validateEndDate(endDate);

    // We validate the following here instead of from within an attribute because
    // we need to make sure that both values are set before we perform the test.

     if (endDate != null)
     {
        // Note that we want to truncate these values to allow for the possibility
        // that we're trying to set them to be the same day.  Calling
        // dateValue( ) does not include time.  Were we to want the time element,
        // we would call timestampValue().  Finally, whenever comparing jbo
        // Date objects, we have to convert to long values.

        long endDateLong = endDate.dateValue().getTime();

        // We can assume we have a Start Date or the validation of this
        // value would have thrown an exception.

        if (endDateLong < startDate.dateValue().getTime())
        {
          throw new OARowValException(OARowValException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(),
                                     getPrimaryKey(),
                                     "AK", // Message product short name
                                     "FWK_TBX_T_START_END_BAD");  // Message name
         }
      }

  } // end validateEntity()


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for EmployeeId
   *****************************************************************************
   */
  public void setEmployeeId(Number value)
  {
    // BC4J validates that this can be updated only on a new line, and that this
    // mandatory attribute is not null.  This code adds the additional check
    // of only allowing an update if the value is null to prevent changes while
    // the object is in memory.

   if (getEmployeeId() != null)
    {
      throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "EmployeeId", // Attribute Name
                                   value, // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_EMP_ID_NO_UPDATE"); // Message name

    }

    if (value != null)
    {
      // Employee id must be unique.  To verify this, you must check both the
      // entity cache and the database.  In this case, it's appropriate
      // to use findByPrimaryKey( ) because you're unlikely to get a match, and
      // and are therefore unlikely to pull a bunch of large objects into memory.

      // Note that findByPrimaryKey() is guaranteed to check all employees.
      // First it checks the entity cache, then it checks the database.

      OADBTransaction transaction = getOADBTransaction();
      Object[] employeeKey = {value};
      EntityDefImpl empDefinition = EmployeeEOImpl.getDefinitionObject();
      EmployeeEOImpl employee =
        (EmployeeEOImpl)empDefinition.findByPrimaryKey(transaction, new Key(employeeKey));

      if (employee != null)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "EmployeeId", // Attribute Name
                                   value, // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_EMP_ID_UNIQUE"); // Message name
      }
    }

    setAttributeInternal(EMPLOYEEID, value);

  } // end setEmployeeId()

  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for LastName
   *****************************************************************************
   */
  public void setLastName(String value)
  {
    // BC4J will handle making sure this value is not null.  We still need to
    // check before trying to set the full name, however.

    if ((value != null) || (!("".equals(value.trim()))))
    {
       String oldLastName = getLastName();

       if (oldLastName == null)
       {
        oldLastName = "";
       }

       // If we're dealing with a new last name value, update the full name.

       if (value.compareTo(oldLastName) != 0)
       {
         String firstName = getFirstName();

         if (firstName == null)
         {
           firstName = "";
         }

         setFullName(value.concat(", ").concat(firstName));
       }
     }
    setAttributeInternal(LASTNAME, value);

  } // end setLastName()


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for FirstName
   *****************************************************************************
   */
  public void setFirstName(String value)
  {
    // BC4J will handle making sure this value is not null.  We still need to
    // check before trying to set the full name, however.

    if ((value != null) || (!("".equals(value.trim()))))
    {
       String oldFirstName = getFirstName();

       if (oldFirstName == null)
       {
        oldFirstName = "";
       }

       // If we're dealing with a new last name value, update the full name.

       if (value.compareTo(oldFirstName) != 0)
       {
         String lastName = getLastName();

         if (lastName == null)
         {
           lastName = "";
         }

         setFullName(lastName.concat(", ").concat(value));
       }
     }

    setAttributeInternal(FIRSTNAME, value);

  } // end setFirstName()


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for StartDate
   *****************************************************************************
   */
  public void setStartDate(Date value)
  {
    validateStartDate(value);
    setAttributeInternal(STARTDATE, value);

  } // end setStartDate()

  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for EndDate
   *****************************************************************************
   */
  public void setEndDate(Date value)
  {
    validateEndDate(value);
    setAttributeInternal(ENDDATE, value);

  } // end setEndDate()

 /*
  ****************************************************************************** 
  * Verifies that the employee's Start Date is valid.
  *
  * Business Rules:
  * Start Date is required.
  * Cannot be earlier than sysdate.
  ******************************************************************************
  */
  protected void validateStartDate(Date value)
  {
    // BC4J ensures that this mandatory attribute has a non-null value.

    if (value != null)
    {
      OADBTransaction transaction = getOADBTransaction();

      // Note that we want to truncate these values to allow for the possibility
      // that we're trying to set them to be the same day.  Calling
      // dateValue( ) does not include time.  Were we to want the time element,
      // we would call timestampValue().  Finally, you cannot compare
      // oracle.jbo.domain.Date objects directly. Instead, convert the value to
      // a long as shown.

      long sysdate = transaction.getCurrentDBDate().dateValue().getTime();
      long startDate = value.dateValue().getTime();

      if (startDate < sysdate)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "StartDate", // Attribute Name
                                   value, // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_START_DATE_PAST"); // Message name
      }
    }

  } // end validateStartDate()


 /*
  ******************************************************************************
  * Verifies that the employee's End Date is valid.
  *
  * Business Rules:
  * This is an optional value which can be updated at any time.
  * Cannot be earlier than sysdate.
  ******************************************************************************
  */
  protected void validateEndDate(Date value)
  {
    // If a value has been set, validate it.

    if (value != null)
    {
      OADBTransaction transaction = getOADBTransaction();

      // Note that we want to truncate these values to allow for the possibility
      // that we're trying to set them to be the same day.  Calling
      // dateValue( ) does not include time.  Were we to want the time element,
      // we would call timestampValue().  Finally, you cannot compare
      // oracle.jbo.domain.Date objects directly. Instead, convert the value to
      // a long as shown.

      long sysdate = transaction.getCurrentDBDate().dateValue().getTime();
      long endDate = value.dateValue().getTime();

      if (endDate < sysdate)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "EndDate", // Attribute Name
                                     value, // Attribute value
                                     "AK", // Message product short name
                                     "FWK_TBX_T_END_DATE_PAST"); // Message name
      }
    }
  } // end validateEndDate()


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for Salary
   *****************************************************************************
   */
  public void setSalary(Number value)
  {
    if (value != null)
    {
      // Verify value is > 0

      if (value.compareTo(0) <= 0)
      {
        throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                   getEntityDef().getFullName(), // EO name
                                   getPrimaryKey(), // EO PK
                                   "Salary", // Attribute Name
                                   value, // Attribute value
                                   "AK", // Message product short name
                                   "FWK_TBX_T_EMP_SALARY_REQUIRED"); // Message name

      }
      setAttributeInternal(SALARY, value);
    }
  } // end setSalary()


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for PositionCode
   *****************************************************************************
   */
  public void setPositionCode(String value)
  {
    // BC4J ensures that this mandatory attribute is non-null

    if ((value != null) || (!("".equals(value.trim()))))
    {

      EmployeeEntityExpert expert = getEmployeeEntityExpert(getOADBTransaction());

      if (!(expert.isPositionValid(value)))
      {
          throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "PositionCode", // Attribute Name
                                     value, // Attribute value
                                     "AK", // Message product short name
                                     "FWK_TBX_T_EMP_POSITION_INVALID"); // Message name
      }
    }

    setAttributeInternal(POSITIONCODE, value);

  } // end setPositionCode()


  /*
   *****************************************************************************
   * Sets <code>value</code> as the attribute value for ManagerId
   *****************************************************************************
   */
  public void setManagerId(Number value)
  {
    if (value != null)
    {
      EmployeeEntityExpert expert = getEmployeeEntityExpert(getOADBTransaction());

      if (!(expert.isEmployeeActive(value)))
      {
          throw new OAAttrValException(OAException.TYP_ENTITY_OBJECT,
                                     getEntityDef().getFullName(), // EO name
                                     getPrimaryKey(), // EO PK
                                     "ManagerId", // Attribute Name
                                     value, // Attribute value
                                     "AK", // Message product short name
                                     "FWK_TBX_T_EMP_MGR_INACTIVE"); // Message name
      }
    }

    setAttributeInternal(MANAGERID, value);

  } // end setManagerId()


//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here
//  ---------------------------------------------------------------












































  private static oracle.apps.fnd.framework.server.OAEntityDefImpl mDefinitionObject;

  /**
   *
   * This is the default constructor (do not remove)
   */
  public EmployeeEOImpl()
  {
  }


    /**Retrieves the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        if (mDefinitionObject == null) {
            mDefinitionObject =
                    (OAEntityDefImpl)EntityDefImpl.findDefObject("oracle.apps.fnd.framework.toolbox.schema.server.EmployeeEO");
        }
        return mDefinitionObject;
    }

    /**
     *
     * Sets <code>value</code> as the attribute value for FullName
     */
    public void setFullName(String value)
  {
    setAttributeInternal(FULLNAME, value);

  } // end setLastName()



  /**
   *
   * Gets the attribute value for EmployeeId, using the alias name EmployeeId
   */
  public Number getEmployeeId()
  {
    return (Number)getAttributeInternal(EMPLOYEEID);
  }

  /**
   *
   * Gets the attribute value for Title, using the alias name Title
   */
  public String getTitle()
  {
    return (String)getAttributeInternal(TITLE);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Title
   */
  public void setTitle(String value)
  {
    setAttributeInternal(TITLE, value);
  }

  /**
   *
   * Gets the attribute value for FirstName, using the alias name FirstName
   */
  public String getFirstName()
  {
    return (String)getAttributeInternal(FIRSTNAME);
  }

  /**
   *
   * Gets the attribute value for MiddleNames, using the alias name MiddleNames
   */
  public String getMiddleNames()
  {
    return (String)getAttributeInternal(MIDDLENAMES);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for MiddleNames
   */
  public void setMiddleNames(String value)
  {
    setAttributeInternal(MIDDLENAMES, value);
  }

  /**
   *
   * Gets the attribute value for LastName, using the alias name LastName
   */
  public String getLastName()
  {
    return (String)getAttributeInternal(LASTNAME);
  }


  /**
   *
   * Gets the attribute value for FullName, using the alias name FullName
   */
  public String getFullName()
  {
    return (String)getAttributeInternal(FULLNAME);
  }


  /**
   *
   * Gets the attribute value for EmailAddress, using the alias name EmailAddress
   */
  public String getEmailAddress()
  {
    return (String)getAttributeInternal(EMAILADDRESS);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for EmailAddress
   */
  public void setEmailAddress(String value)
  {
    setAttributeInternal(EMAILADDRESS, value);
  }

  /**
   *
   * Gets the attribute value for ManagerId, using the alias name ManagerId
   */
  public Number getManagerId()
  {
    return (Number)getAttributeInternal(MANAGERID);
  }


  /**
   *
   * Gets the attribute value for PositionCode, using the alias name PositionCode
   */
  public String getPositionCode()
  {
    return (String)getAttributeInternal(POSITIONCODE);
  }


  /**
   *
   * Gets the attribute value for Salary, using the alias name Salary
   */
  public Number getSalary()
  {
    return (Number)getAttributeInternal(SALARY);
  }


  /**
   *
   * Gets the attribute value for StartDate, using the alias name StartDate
   */
  public Date getStartDate()
  {
    return (Date)getAttributeInternal(STARTDATE);
  }

  /**
   *
   * Gets the attribute value for EndDate, using the alias name EndDate
   */
  public Date getEndDate()
  {
    return (Date)getAttributeInternal(ENDDATE);
  }



  /**
   *
   * Gets the attribute value for LastUpdateDate, using the alias name LastUpdateDate
   */
  public Date getLastUpdateDate()
  {
    return (Date)getAttributeInternal(LASTUPDATEDATE);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for LastUpdateDate
   */
  public void setLastUpdateDate(Date value)
  {
    setAttributeInternal(LASTUPDATEDATE, value);
  }

  /**
   *
   * Gets the attribute value for LastUpdatedBy, using the alias name LastUpdatedBy
   */
  public Number getLastUpdatedBy()
  {
    return (Number)getAttributeInternal(LASTUPDATEDBY);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for LastUpdatedBy
   */
  public void setLastUpdatedBy(Number value)
  {
    setAttributeInternal(LASTUPDATEDBY, value);
  }

  /**
   *
   * Gets the attribute value for CreationDate, using the alias name CreationDate
   */
  public Date getCreationDate()
  {
    return (Date)getAttributeInternal(CREATIONDATE);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for CreationDate
   */
  public void setCreationDate(Date value)
  {
    setAttributeInternal(CREATIONDATE, value);
  }

  /**
   *
   * Gets the attribute value for CreatedBy, using the alias name CreatedBy
   */
  public Number getCreatedBy()
  {
    return (Number)getAttributeInternal(CREATEDBY);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for CreatedBy
   */
  public void setCreatedBy(Number value)
  {
    setAttributeInternal(CREATEDBY, value);
  }

  /**
   *
   * Gets the attribute value for LastUpdateLogin, using the alias name LastUpdateLogin
   */
  public Number getLastUpdateLogin()
  {
    return (Number)getAttributeInternal(LASTUPDATELOGIN);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for LastUpdateLogin
   */
  public void setLastUpdateLogin(Number value)
  {
    setAttributeInternal(LASTUPDATELOGIN, value);
  }

  /**
   *
   * Gets the attribute value for AttributeCategory, using the alias name AttributeCategory
   */
  public String getAttributeCategory()
  {
    return (String)getAttributeInternal(ATTRIBUTECATEGORY);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for AttributeCategory
   */
  public void setAttributeCategory(String value)
  {
    setAttributeInternal(ATTRIBUTECATEGORY, value);
  }

  /**
   *
   * Gets the attribute value for Attribute1, using the alias name Attribute1
   */
  public String getAttribute1()
  {
    return (String)getAttributeInternal(ATTRIBUTE1);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute1
   */
  public void setAttribute1(String value)
  {
    setAttributeInternal(ATTRIBUTE1, value);
  }

  /**
   *
   * Gets the attribute value for Attribute2, using the alias name Attribute2
   */
  public String getAttribute2()
  {
    return (String)getAttributeInternal(ATTRIBUTE2);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute2
   */
  public void setAttribute2(String value)
  {
    setAttributeInternal(ATTRIBUTE2, value);
  }

  /**
   *
   * Gets the attribute value for Attribute3, using the alias name Attribute3
   */
  public String getAttribute3()
  {
    return (String)getAttributeInternal(ATTRIBUTE3);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute3
   */
  public void setAttribute3(String value)
  {
    setAttributeInternal(ATTRIBUTE3, value);
  }

  /**
   *
   * Gets the attribute value for Attribute4, using the alias name Attribute4
   */
  public String getAttribute4()
  {
    return (String)getAttributeInternal(ATTRIBUTE4);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute4
   */
  public void setAttribute4(String value)
  {
    setAttributeInternal(ATTRIBUTE4, value);
  }

  /**
   *
   * Gets the attribute value for Attribute5, using the alias name Attribute5
   */
  public String getAttribute5()
  {
    return (String)getAttributeInternal(ATTRIBUTE5);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute5
   */
  public void setAttribute5(String value)
  {
    setAttributeInternal(ATTRIBUTE5, value);
  }

  /**
   *
   * Gets the attribute value for Attribute6, using the alias name Attribute6
   */
  public String getAttribute6()
  {
    return (String)getAttributeInternal(ATTRIBUTE6);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute6
   */
  public void setAttribute6(String value)
  {
    setAttributeInternal(ATTRIBUTE6, value);
  }

  /**
   *
   * Gets the attribute value for Attribute7, using the alias name Attribute7
   */
  public String getAttribute7()
  {
    return (String)getAttributeInternal(ATTRIBUTE7);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute7
   */
  public void setAttribute7(String value)
  {
    setAttributeInternal(ATTRIBUTE7, value);
  }

  /**
   *
   * Gets the attribute value for Attribute8, using the alias name Attribute8
   */
  public String getAttribute8()
  {
    return (String)getAttributeInternal(ATTRIBUTE8);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute8
   */
  public void setAttribute8(String value)
  {
    setAttributeInternal(ATTRIBUTE8, value);
  }

  /**
   *
   * Gets the attribute value for Attribute9, using the alias name Attribute9
   */
  public String getAttribute9()
  {
    return (String)getAttributeInternal(ATTRIBUTE9);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute9
   */
  public void setAttribute9(String value)
  {
    setAttributeInternal(ATTRIBUTE9, value);
  }

  /**
   *
   * Gets the attribute value for Attribute10, using the alias name Attribute10
   */
  public String getAttribute10()
  {
    return (String)getAttributeInternal(ATTRIBUTE10);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute10
   */
  public void setAttribute10(String value)
  {
    setAttributeInternal(ATTRIBUTE10, value);
  }

  /**
   *
   * Gets the attribute value for Attribute11, using the alias name Attribute11
   */
  public String getAttribute11()
  {
    return (String)getAttributeInternal(ATTRIBUTE11);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute11
   */
  public void setAttribute11(String value)
  {
    setAttributeInternal(ATTRIBUTE11, value);
  }

  /**
   *
   * Gets the attribute value for Attribute12, using the alias name Attribute12
   */
  public String getAttribute12()
  {
    return (String)getAttributeInternal(ATTRIBUTE12);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute12
   */
  public void setAttribute12(String value)
  {
    setAttributeInternal(ATTRIBUTE12, value);
  }

  /**
   *
   * Gets the attribute value for Attribute13, using the alias name Attribute13
   */
  public String getAttribute13()
  {
    return (String)getAttributeInternal(ATTRIBUTE13);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute13
   */
  public void setAttribute13(String value)
  {
    setAttributeInternal(ATTRIBUTE13, value);
  }

  /**
   *
   * Gets the attribute value for Attribute14, using the alias name Attribute14
   */
  public String getAttribute14()
  {
    return (String)getAttributeInternal(ATTRIBUTE14);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute14
   */
  public void setAttribute14(String value)
  {
    setAttributeInternal(ATTRIBUTE14, value);
  }

  /**
   *
   * Gets the attribute value for Attribute15, using the alias name Attribute15
   */
  public String getAttribute15()
  {
    return (String)getAttributeInternal(ATTRIBUTE15);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for Attribute15
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
        case MANAGERIDEMPLOYEEEO1:
            return getManagerIdEmployeeEO1();
        case EMPLOYEEEO1:
            return getEmployeeEO1();
        case PURCHASEORDERHEADEREO:
            return getPurchaseOrderHeaderEO();
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
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }






  /**
   * 
   * Gets the associated entity EmployeeEOImpl
   */
  public RowIterator getEmployeeEO1()
  {
    return (RowIterator)getAttributeInternal(EMPLOYEEEO1);
  }

  /**
   * 
   * Sets <code>value</code> as the associated entity EmployeeEOImpl
   */
  public void setEmployeeEO1(EmployeeEOImpl value)
  {
    setAttributeInternal(EMPLOYEEEO1, value);
  }

  /**
   * 
   * Gets the associated entity EmployeeEOImpl
   */
  public EmployeeEOImpl getManagerIdEmployeeEO1()
  {
    return (EmployeeEOImpl)getAttributeInternal(MANAGERIDEMPLOYEEEO1);
  }

  /**
   * 
   * Sets <code>value</code> as the associated entity EmployeeEOImpl
   */
  public void setManagerIdEmployeeEO1(EmployeeEOImpl value)
  {
    setAttributeInternal(MANAGERIDEMPLOYEEEO1, value);
  }


  /**
   * 
   * Gets the associated entity oracle.jbo.RowIterator
   */
  public RowIterator getPurchaseOrderHeaderEO()
  {
    return (RowIterator)getAttributeInternal(PURCHASEORDERHEADEREO);
  }


    /**Creates a Key object based on given key constituents
     */
    public static Key createPrimaryKey(Number employeeId) {
        return new Key(new Object[]{employeeId});
    }
}
