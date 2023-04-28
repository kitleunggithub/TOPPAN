/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAViewRowImpl;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Date;

public class LookupCodesVORowImpl extends OAViewRowImpl {

    public static final int LOOKUPTYPE = 0;
    public static final int LOOKUPCODE = 1;
    public static final int STARTDATEACTIVE = 2;
    public static final int ENDDATEACTIVE = 3;
    public static final int MEANING = 4;
    public static final int DESCRIPTION = 5;
    public static final String RCS_ID="$Header: LookupCodesVORowImpl.java 120.2 2006/07/03 23:41:17 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");
    public static final int SELECTROW = 6;

    /**
     *
     * This is the default constructor (do not remove)
     */
  public LookupCodesVORowImpl()
  {
  }

  /**
   * 
   * Gets LookupCodeEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.LookupCodeEOImpl getLookupCodeEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.LookupCodeEOImpl)getEntity(0);
  }

  /**
   * 
   * Gets the attribute value for LOOKUP_TYPE using the alias name LookupType
   */
  public String getLookupType()
  {
    return (String)getAttributeInternal(LOOKUPTYPE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LOOKUP_TYPE using the alias name LookupType
   */
  public void setLookupType(String value)
  {
    setAttributeInternal(LOOKUPTYPE, value);
  }

  /**
   * 
   * Gets the attribute value for LOOKUP_CODE using the alias name LookupCode
   */
  public String getLookupCode()
  {
    return (String)getAttributeInternal(LOOKUPCODE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LOOKUP_CODE using the alias name LookupCode
   */
  public void setLookupCode(String value)
  {
    setAttributeInternal(LOOKUPCODE, value);
  }

  /**
   * 
   * Gets the attribute value for MEANING using the alias name Meaning
   */
  public String getMeaning()
  {
    return (String)getAttributeInternal(MEANING);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for MEANING using the alias name Meaning
   */
  public void setMeaning(String value)
  {
    setAttributeInternal(MEANING, value);
  }

  /**
   * 
   * Gets the attribute value for DESCRIPTION using the alias name Description
   */
  public String getDescription()
  {
    return (String)getAttributeInternal(DESCRIPTION);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for DESCRIPTION using the alias name Description
   */
  public void setDescription(String value)
  {
    setAttributeInternal(DESCRIPTION, value);
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
        case SELECTROW:
            return getSelectRow();
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
        case SELECTROW:
            setSelectRow((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }

  /**
   * 
   * Gets the attribute value for START_DATE_ACTIVE using the alias name StartDateActive
   */
  public Date getStartDateActive()
  {
    return (Date)getAttributeInternal(STARTDATEACTIVE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for START_DATE_ACTIVE using the alias name StartDateActive
   */
  public void setStartDateActive(Date value)
  {
    setAttributeInternal(STARTDATEACTIVE, value);
  }

  /**
   * 
   * Gets the attribute value for END_DATE_ACTIVE using the alias name EndDateActive
   */
  public Date getEndDateActive()
  {
    return (Date)getAttributeInternal(ENDDATEACTIVE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for END_DATE_ACTIVE using the alias name EndDateActive
   */
  public void setEndDateActive(Date value)
  {
    setAttributeInternal(ENDDATEACTIVE, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute SelectRow
   */
  public String getSelectRow()
  {
    return (String)getAttributeInternal(SELECTROW);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute SelectRow
   */
  public void setSelectRow(String value)
  {
    setAttributeInternal(SELECTROW, value);
  }



}