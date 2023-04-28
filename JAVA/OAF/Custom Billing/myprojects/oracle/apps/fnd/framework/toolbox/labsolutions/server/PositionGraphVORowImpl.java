/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;
import oracle.apps.fnd.framework.server.OAViewRowImpl;
import oracle.apps.fnd.common.VersionInfo;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;

public class PositionGraphVORowImpl extends OAViewRowImpl 
{
  public static final String RCS_ID="$Header: PositionGraphVORowImpl.java 120.1 2005/06/06 10:15:45 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");
  protected static final int POSITIONCODE = 0;


  protected static final int COUNTPOSITIONCODE = 1;
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public PositionGraphVORowImpl()
  {
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute PositionCode
   */
  public String getPositionCode()
  {
    return (String)getAttributeInternal(POSITIONCODE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute PositionCode
   */
  public void setPositionCode(String value)
  {
    setAttributeInternal(POSITIONCODE, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute CountPositionCode
   */
  public Number getCountPositionCode()
  {
    return (Number)getAttributeInternal(COUNTPOSITIONCODE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute CountPositionCode
   */
  public void setCountPositionCode(Number value)
  {
    setAttributeInternal(COUNTPOSITIONCODE, value);
  }
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case POSITIONCODE:
        return getPositionCode();
      case COUNTPOSITIONCODE:
        return getCountPositionCode();
      default:
        return super.getAttrInvokeAccessor(index, attrDef);
      }
  }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case POSITIONCODE:
        setPositionCode((String)value);
        return;
      case COUNTPOSITIONCODE:
        setCountPositionCode((Number)value);
        return;
      default:
        super.setAttrInvokeAccessor(index, value, attrDef);
        return;
      }
  }
}
