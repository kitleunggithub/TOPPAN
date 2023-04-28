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
import oracle.jbo.domain.Date;

public class ItemSummaryVORowImpl extends OAViewRowImpl 
{
  public static final String RCS_ID="$Header: ItemSummaryVORowImpl.java 120.1 2005/06/06 10:11:12 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");
  protected static final int ITEMID = 0;


  protected static final int ITEMDESCRIPTION = 1;
  protected static final int STARTDATEACTIVE = 2;
  protected static final int ENDDATEACTIVE = 3;
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public ItemSummaryVORowImpl()
  {
  }

  /**
   * 
   * Gets ItemFlexfieldEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.ItemFlexfieldEOImpl getItemFlexfieldEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.ItemFlexfieldEOImpl)getEntity(0);
  }

  /**
   * 
   * Gets the attribute value for ITEM_ID using the alias name ItemId
   */
  public Number getItemId()
  {
    return (Number)getAttributeInternal(ITEMID);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ITEM_ID using the alias name ItemId
   */
  public void setItemId(Number value)
  {
    setAttributeInternal(ITEMID, value);
  }

  /**
   * 
   * Gets the attribute value for ITEM_DESCRIPTION using the alias name ItemDescription
   */
  public String getItemDescription()
  {
    return (String)getAttributeInternal(ITEMDESCRIPTION);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for ITEM_DESCRIPTION using the alias name ItemDescription
   */
  public void setItemDescription(String value)
  {
    setAttributeInternal(ITEMDESCRIPTION, value);
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
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case ITEMID:
        return getItemId();
      case ITEMDESCRIPTION:
        return getItemDescription();
      case STARTDATEACTIVE:
        return getStartDateActive();
      case ENDDATEACTIVE:
        return getEndDateActive();
      default:
        return super.getAttrInvokeAccessor(index, attrDef);
      }
  }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case ITEMID:
        setItemId((Number)value);
        return;
      case ITEMDESCRIPTION:
        setItemDescription((String)value);
        return;
      case STARTDATEACTIVE:
        setStartDateActive((Date)value);
        return;
      case ENDDATEACTIVE:
        setEndDateActive((Date)value);
        return;
      default:
        super.setAttrInvokeAccessor(index, value, attrDef);
        return;
      }
  }
}
