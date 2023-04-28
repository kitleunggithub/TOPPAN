package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.framework.server.OAViewRowImpl;
import oracle.jbo.server.AttributeDefImpl;
import oracle.apps.fnd.common.VersionInfo;
//  ---------------------------------------------------------------
//  ---    File generated by Oracle Business Components for Java.
//  ---------------------------------------------------------------
// javadoc_private

public class PositionVVORowImpl extends OAViewRowImpl {

    public static final int LOOKUPCODE = 0;
    public static final String RCS_ID="$Header: PositionVVORowImpl.java 120.2 2006/07/03 21:07:39 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");


    /**
     *
     * This is the default constructor (do not remove)
     */
  public PositionVVORowImpl()
  {
  }

  /**
   *
   * Gets the attribute value for the calculated attribute LookupCode
   */
  public String getLookupCode()
  {
    return (String)getAttributeInternal(LOOKUPCODE);
  }

  /**
   *
   * Sets <code>value</code> as the attribute value for the calculated attribute LookupCode
   */
  public void setLookupCode(String value)
  {
    setAttributeInternal(LOOKUPCODE, value);
  }
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case LOOKUPCODE:
            return getLookupCode();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case LOOKUPCODE:
            setLookupCode((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }
}
