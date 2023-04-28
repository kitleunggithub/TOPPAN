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
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.server.EntityDefImpl;

public class LookupCodeTLEOImpl extends OAEntityImpl {
    public static final int LOOKUPTYPE = 0;
    public static final int LOOKUPCODE = 1;
    public static final int MEANING = 2;
    public static final int LANGUAGE = 3;
    public static final int SOURCELANG = 4;
    public static final int DESCRIPTION = 5;

    public static final String RCS_ID="$Header: LookupCodeTLEOImpl.java 120.5 2006/07/03 19:46:14 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");
    public static final int LOOKUPCODEEO = 6;


    private static oracle.apps.fnd.framework.server.OAEntityDefImpl mDefinitionObject;

  /**
   * 
   * This is the default constructor (do not remove)
   */
  public LookupCodeTLEOImpl()
  {
  }


    /**Retrieves the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        if (mDefinitionObject == null) {
            mDefinitionObject =
                    (OAEntityDefImpl)EntityDefImpl.findDefObject("oracle.apps.fnd.framework.toolbox.schema.server.LookupCodeTLEO");
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

  /**
   * 
   * Gets the attribute value for Language, using the alias name Language
   */
  public String getLanguage()
  {
    return (String)getAttributeInternal(LANGUAGE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for Language
   */
  public void setLanguage(String value)
  {
    setAttributeInternal(LANGUAGE, value);
  }

  /**
   * 
   * Gets the attribute value for SourceLang, using the alias name SourceLang
   */
  public String getSourceLang()
  {
    return (String)getAttributeInternal(SOURCELANG);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for SourceLang
   */
  public void setSourceLang(String value)
  {
    setAttributeInternal(SOURCELANG, value);
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
//   setAttributeInternal(LASTUPDATEDATE, value);
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
        case MEANING:
            return getMeaning();
        case LANGUAGE:
            return getLanguage();
        case SOURCELANG:
            return getSourceLang();
        case DESCRIPTION:
            return getDescription();
        case LOOKUPCODEEO:
            return getLookupCodeEO();
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
        case MEANING:
            setMeaning((String)value);
            return;
        case LANGUAGE:
            setLanguage((String)value);
            return;
        case SOURCELANG:
            setSourceLang((String)value);
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
   * Gets the associated entity LookupCodeEOImpl
   */
  public LookupCodeEOImpl getLookupCodeEO()
  {
    return (LookupCodeEOImpl)getAttributeInternal(LOOKUPCODEEO);
  }

  /**
   * 
   * Sets <code>value</code> as the associated entity LookupCodeEOImpl
   */
  public void setLookupCodeEO(LookupCodeEOImpl value)
  {
    setAttributeInternal(LOOKUPCODEEO, value);
  }


    /**Creates a Key object based on given key constituents
     */
    public static Key createPrimaryKey(String lookupType, String lookupCode,
                                       String language) {
        return new Key(new Object[]{lookupType, lookupCode, language});
    }
}
