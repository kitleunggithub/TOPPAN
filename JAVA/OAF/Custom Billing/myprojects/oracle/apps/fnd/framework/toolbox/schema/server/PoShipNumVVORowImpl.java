package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.framework.server.OAViewRowImpl;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;
import oracle.apps.fnd.common.VersionInfo;
//  ---------------------------------------------------------------
//  ---    File generated by Oracle Business Components for Java.
//  ---------------------------------------------------------------
// javadoc_private

public class PoShipNumVVORowImpl extends OAViewRowImpl {

    public static final int MAXSHIPMENTNUMBER = 0;
    public static final String RCS_ID="$Header: PoShipNumVVORowImpl.java 120.2 2006/07/03 20:56:24 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");


    /**
     *
     * This is the default constructor (do not remove)
     */
  public PoShipNumVVORowImpl()
  {
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute MaxShipmentNumber
   */
  public Number getMaxShipmentNumber()
  {
    return (Number)getAttributeInternal(MAXSHIPMENTNUMBER);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute MaxShipmentNumber
   */
  public void setMaxShipmentNumber(Number value)
  {
    setAttributeInternal(MAXSHIPMENTNUMBER, value);
  }
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case MAXSHIPMENTNUMBER:
            return getMaxShipmentNumber();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case MAXSHIPMENTNUMBER:
            setMaxShipmentNumber((Number)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }
}
