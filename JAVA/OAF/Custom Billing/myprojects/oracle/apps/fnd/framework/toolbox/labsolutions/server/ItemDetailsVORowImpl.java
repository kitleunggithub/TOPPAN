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

public class ItemDetailsVORowImpl extends OAViewRowImpl 
{
  public static final String RCS_ID="$Header: ItemDetailsVORowImpl.java 120.1 2005/06/06 10:08:52 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");
  protected static final int ITEMID = 0;


  protected static final int ITEMDESCRIPTION = 1;
  protected static final int FWKITEMID = 2;
  protected static final int FWKITEMSTRUCTUREID = 3;
  protected static final int STARTDATEACTIVE = 4;
  protected static final int ENDDATEACTIVE = 5;
  protected static final int ATTRIBUTECATEGORY = 6;
  protected static final int ATTRIBUTE1 = 7;
  protected static final int ATTRIBUTE2 = 8;
  protected static final int ATTRIBUTE3 = 9;
  protected static final int ATTRIBUTE4 = 10;
  protected static final int ATTRIBUTE5 = 11;
  protected static final int ATTRIBUTE6 = 12;
  protected static final int ATTRIBUTE7 = 13;
  protected static final int ATTRIBUTE8 = 14;
  protected static final int ATTRIBUTE9 = 15;
  protected static final int ATTRIBUTE10 = 16;
  protected static final int ATTRIBUTE11 = 17;
  protected static final int ATTRIBUTE12 = 18;
  protected static final int ATTRIBUTE13 = 19;
  protected static final int ATTRIBUTE14 = 20;
  protected static final int ATTRIBUTE15 = 21;
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public ItemDetailsVORowImpl()
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
   * Gets the attribute value for FWKITEM_ID using the alias name FwkitemId
   */
  public Number getFwkitemId()
  {
    return (Number)getAttributeInternal(FWKITEMID);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for FWKITEM_ID using the alias name FwkitemId
   */
  public void setFwkitemId(Number value)
  {
    setAttributeInternal(FWKITEMID, value);
  }

  /**
   * 
   * Gets the attribute value for FWKITEM_STRUCTURE_ID using the alias name FwkitemStructureId
   */
  public Number getFwkitemStructureId()
  {
    return (Number)getAttributeInternal(FWKITEMSTRUCTUREID);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for FWKITEM_STRUCTURE_ID using the alias name FwkitemStructureId
   */
  public void setFwkitemStructureId(Number value)
  {
    setAttributeInternal(FWKITEMSTRUCTUREID, value);
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
    switch (index)
      {
      case ITEMID:
        return getItemId();
      case ITEMDESCRIPTION:
        return getItemDescription();
      case FWKITEMID:
        return getFwkitemId();
      case FWKITEMSTRUCTUREID:
        return getFwkitemStructureId();
      case STARTDATEACTIVE:
        return getStartDateActive();
      case ENDDATEACTIVE:
        return getEndDateActive();
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
      case FWKITEMID:
        setFwkitemId((Number)value);
        return;
      case FWKITEMSTRUCTUREID:
        setFwkitemStructureId((Number)value);
        return;
      case STARTDATEACTIVE:
        setStartDateActive((Date)value);
        return;
      case ENDDATEACTIVE:
        setEndDateActive((Date)value);
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
}
