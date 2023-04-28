/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAEntityDefImpl;
import oracle.apps.fnd.framework.server.OAEntityImpl;

import oracle.jbo.AttributeList;
import oracle.jbo.Key;
import oracle.jbo.RowIterator;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.server.EntityDefImpl;

public class LookupCodeEOImpl extends OAEntityImpl {
    public static final int LOOKUPTYPE = 0;
    public static final int LOOKUPCODE = 1;
    public static final int STARTDATEACTIVE = 2;
    public static final int ENDDATEACTIVE = 3;
    public static final int MEANING = 4;
    public static final int DESCRIPTION = 5;

    public static final String RCS_ID="$Header: LookupCodeEOImpl.java 120.5 2006/07/03 19:40:09 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");
    public static final int OA_TL_ENTITIES = 6;


    private static oracle.apps.fnd.framework.server.OAEntityDefImpl mDefinitionObject;

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public LookupCodeEOImpl()
  {
  }


    /**Retrieves the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        if (mDefinitionObject == null) {
            mDefinitionObject =
                    (OAEntityDefImpl)EntityDefImpl.findDefObject("oracle.apps.fnd.framework.toolbox.schema.server.LookupCodeEO");
        }
        return mDefinitionObject;
    }

    /**
     *
     * Add attribute defaulting logic in this method.
     */
    public void create(AttributeList attributeList)
  {
    super.create(attributeList);
  }

  /**
   * 
   * Add entity remove logic in this method.
   */
  public void remove()
  {
    super.remove();
  }

  /**
   * 
   * Gets the attribute value for LookupType, using the alias name LookupType
   */
  public String getLookupType()
  {
    return (String)getAttributeInternal(LOOKUPTYPE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for LookupType
   */
  public void setLookupType(String value)
  {
    setAttributeInternal(LOOKUPTYPE, value);
  }

  /**
   * 
   * Gets the attribute value for LookupCode, using the alias name LookupCode
   */
  public String getLookupCode()
  {
    return (String)getAttributeInternal(LOOKUPCODE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for LookupCode
   */
  public void setLookupCode(String value)
  {
    setAttributeInternal(LOOKUPCODE, value);
  }

  /**
   * 
   * Gets the attribute value for Meaning, using the alias name Meaning
   */
  public String getMeaning()
  {
    return (String)getAttributeInternal(MEANING);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Meaning
   */
  public void setMeaning(String value)
  {
    setAttributeInternal(MEANING, value);
  }

// NOTE: the associated Toolbox table does not have WHO columns, so these are simply
// stubs so the class will compile.  Real tables would, of course, include
// WHO columns.  

  /**
   *
   * Gets the attribute value for LastUpdateDate, using the alias name LastUpdateDate
   */
  public Date getLastUpdateDate()
  {
//    return (Date)getAttributeInternal(LASTUPDATEDATE);
    return null;
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for LastUpdateDate
   */
  public void setLastUpdateDate(Date value)
  {
//    setAttributeInternal(LASTUPDATEDATE, value);
  }

  /**
   *
   * Gets the attribute value for LastUpdatedBy, using the alias name LastUpdatedBy
   */
  public Number getLastUpdatedBy()
  {
//    return (Number)getAttributeInternal(LASTUPDATEDBY);
    return null;
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for LastUpdatedBy
   */
  public void setLastUpdatedBy(Number value)
  {
//    setAttributeInternal(LASTUPDATEDBY, value);
  }

  /**
   *
   * Gets the attribute value for CreationDate, using the alias name CreationDate
   */
  public Date getCreationDate()
  {
//    return (Date)getAttributeInternal(CREATIONDATE);
    return null;
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for CreationDate
   */
  public void setCreationDate(Date value)
  {
//    setAttributeInternal(CREATIONDATE, value);
  }

  /**
   *
   * Gets the attribute value for CreatedBy, using the alias name CreatedBy
   */
  public Number getCreatedBy()
  {
//    return (Number)getAttributeInternal(CREATEDBY);
    return null;
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for CreatedBy
   */
  public void setCreatedBy(Number value)
  {
//    setAttributeInternal(CREATEDBY, value);
  }

  /**
   *
   * Gets the attribute value for LastUpdateLogin, using the alias name LastUpdateLogin
   */
  public Number getLastUpdateLogin()
  {
//    return (Number)getAttributeInternal(LASTUPDATELOGIN);
    return null;
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for LastUpdateLogin
   */
  public void setLastUpdateLogin(Number value)
  {
//    setAttributeInternal(LASTUPDATELOGIN, value);
  }
  
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case LOOKUPTYPE:
            return getLookupType();
        case LOOKUPCODE:
            return getLookupCode();
        case STARTDATEACTIVE:
            return getStartDateActive();
        case ENDDATEACTIVE:
            return getEndDateActive();
        case MEANING:
            return getMeaning();
        case DESCRIPTION:
            return getDescription();
        case OA_TL_ENTITIES:
            return getOA_TL_ENTITIES();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case LOOKUPTYPE:
            setLookupType((String)value);
            return;
        case LOOKUPCODE:
            setLookupCode((String)value);
            return;
        case STARTDATEACTIVE:
            setStartDateActive((Date)value);
            return;
        case ENDDATEACTIVE:
            setEndDateActive((Date)value);
            return;
        case MEANING:
            setMeaning((String)value);
            return;
        case DESCRIPTION:
            setDescription((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }


  /**
   * 
   * Gets the attribute value for Description, using the alias name Description
   */
  public String getDescription()
  {
    return (String)getAttributeInternal(DESCRIPTION);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Description
   */
  public void setDescription(String value)
  {
    setAttributeInternal(DESCRIPTION, value);
  }




  /**
   * 
   * Gets the associated entity oracle.jbo.RowIterator
   */
  public RowIterator getOA_TL_ENTITIES()
  {
    return (RowIterator)getAttributeInternal(OA_TL_ENTITIES);
  }




  /**
   * 
   * Gets the attribute value for StartDateActive, using the alias name StartDateActive
   */
  public Date getStartDateActive()
  {
    return (Date)getAttributeInternal(STARTDATEACTIVE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for StartDateActive
   */
  public void setStartDateActive(Date value)
  {
    setAttributeInternal(STARTDATEACTIVE, value);
  }

  /**
   * 
   * Gets the attribute value for EndDateActive, using the alias name EndDateActive
   */
  public Date getEndDateActive()
  {
    return (Date)getAttributeInternal(ENDDATEACTIVE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for EndDateActive
   */
  public void setEndDateActive(Date value)
  {
    setAttributeInternal(ENDDATEACTIVE, value);
  }


    /**Creates a Key object based on given key constituents
     */
    public static Key createPrimaryKey(String lookupType, String lookupCode) {
        return new Key(new Object[]{lookupType, lookupCode});
    }
}
