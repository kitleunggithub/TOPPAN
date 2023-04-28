/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
// javadoc_private
package oracle.apps.fnd.framework.toolbox.poplist.server;
import oracle.apps.fnd.framework.server.OAViewRowImpl;
import oracle.jbo.server.AttributeDefImpl;
import oracle.apps.fnd.common.VersionInfo;

public class LookupTypesVORowImpl extends OAViewRowImpl {

    public static final int LOOKUPTYPE = 0;
    public static final String RCS_ID="$Header: LookupTypesVORowImpl.java 120.2 2006/07/03 15:46:43 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
    VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.poplist.server");
    public static final int DISPLAYNAME = 1;


    /**
     *
     * This is the default constructor (do not remove)
     */
  public LookupTypesVORowImpl()
  {
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute LookupType
   */
  public String getLookupType()
  {
    return (String)getAttributeInternal(LOOKUPTYPE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute LookupType
   */
  public void setLookupType(String value)
  {
    setAttributeInternal(LOOKUPTYPE, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute DisplayName
   */
  public String getDisplayName()
  {
    return (String)getAttributeInternal(DISPLAYNAME);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute DisplayName
   */
  public void setDisplayName(String value)
  {
    setAttributeInternal(DISPLAYNAME, value);
  }
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case LOOKUPTYPE:
            return getLookupType();
        case DISPLAYNAME:
            return getDisplayName();
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
        case DISPLAYNAME:
            setDisplayName((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }
}