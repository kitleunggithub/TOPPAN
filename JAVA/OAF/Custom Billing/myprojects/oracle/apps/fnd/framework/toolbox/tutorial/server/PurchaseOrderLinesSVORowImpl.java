/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;
import oracle.apps.fnd.framework.server.OAViewRowImpl;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.VersionInfo;

public class PurchaseOrderLinesSVORowImpl extends OAViewRowImpl {

    public static final int LINEID = 0;
    public static final int PONUMBER = 1;
    public static final int LINENUMBER = 2;
    public static final int ITEMID = 3;
    public static final int ITEMDESCRIPTION = 4;
    public static final int UNITOFMEASURE = 5;
    public static final int QUANTITY = 6;
    public static final int UNITPRICE = 7;
    public static final int PURCHASEORDER = 8;

    /**
     * Oracle Applications internal source control identifier
     */
   public static final String RCS_ID="$Header: PurchaseOrderLinesSVORowImpl.java 120.5 2006/07/04 01:24:39 atgops1 noship $";
  /**
   * Oracle Applications internal source control identifier
   */
   public static final boolean RCS_ID_RECORDED =
         VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");
    public static final int PURCHASEORDERSHIPMENT = 9;

    /**
     *
     * This is the default constructor (do not remove)
     */
  public PurchaseOrderLinesSVORowImpl()
  {
  }

  /**
   * 
   * Gets PurchaseOrderLineEO entity object.
   */
  public oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderLineEOImpl getPurchaseOrderLineEO()
  {
    return (oracle.apps.fnd.framework.toolbox.schema.server.PurchaseOrderLineEOImpl)getEntity(0);
  }

  /**
   * 
   * Gets the attribute value for LINE_ID using the alias name LineId
   */
  public Number getLineId()
  {
    return (Number)getAttributeInternal(LINEID);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LINE_ID using the alias name LineId
   */
  public void setLineId(Number value)
  {
    setAttributeInternal(LINEID, value);
  }

  /**
   * 
   * Gets the attribute value for HEADER_ID using the alias name PoNumber
   */
  public Number getPoNumber()
  {
    return (Number)getAttributeInternal(PONUMBER);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for HEADER_ID using the alias name PoNumber
   */
  public void setPoNumber(Number value)
  {
    setAttributeInternal(PONUMBER, value);
  }

  /**
   * 
   * Gets the attribute value for LINE_NUMBER using the alias name LineNumber
   */
  public Number getLineNumber()
  {
    return (Number)getAttributeInternal(LINENUMBER);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LINE_NUMBER using the alias name LineNumber
   */
  public void setLineNumber(Number value)
  {
    setAttributeInternal(LINENUMBER, value);
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
   * Gets the attribute value for UNIT_OF_MEASURE using the alias name UnitOfMeasure
   */
  public String getUnitOfMeasure()
  {
    return (String)getAttributeInternal(UNITOFMEASURE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for UNIT_OF_MEASURE using the alias name UnitOfMeasure
   */
  public void setUnitOfMeasure(String value)
  {
    setAttributeInternal(UNITOFMEASURE, value);
  }

  /**
   * 
   * Gets the attribute value for QUANTITY using the alias name Quantity
   */
  public Number getQuantity()
  {
    return (Number)getAttributeInternal(QUANTITY);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for QUANTITY using the alias name Quantity
   */
  public void setQuantity(Number value)
  {
    setAttributeInternal(QUANTITY, value);
  }

  /**
   * 
   * Gets the attribute value for UNIT_PRICE using the alias name UnitPrice
   */
  public Number getUnitPrice()
  {
    return (Number)getAttributeInternal(UNITPRICE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for UNIT_PRICE using the alias name UnitPrice
   */
  public void setUnitPrice(Number value)
  {
    setAttributeInternal(UNITPRICE, value);
  }

  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case LINEID:
            return getLineId();
        case PONUMBER:
            return getPoNumber();
        case LINENUMBER:
            return getLineNumber();
        case ITEMID:
            return getItemId();
        case ITEMDESCRIPTION:
            return getItemDescription();
        case UNITOFMEASURE:
            return getUnitOfMeasure();
        case QUANTITY:
            return getQuantity();
        case UNITPRICE:
            return getUnitPrice();
        case PURCHASEORDERSHIPMENT:
            return getPurchaseOrderShipment();
        case PURCHASEORDER:
            return getPurchaseOrder();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
        switch (index) {
        case LINEID:
            setLineId((Number)value);
            return;
        case PONUMBER:
            setPoNumber((Number)value);
            return;
        case LINENUMBER:
            setLineNumber((Number)value);
            return;
        case ITEMID:
            setItemId((Number)value);
            return;
        case ITEMDESCRIPTION:
            setItemDescription((String)value);
            return;
        case UNITOFMEASURE:
            setUnitOfMeasure((String)value);
            return;
        case QUANTITY:
            setQuantity((Number)value);
            return;
        case UNITPRICE:
            setUnitPrice((Number)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }

  /**
   * 
   * Gets the associated <code>Row</code> using master-detail link PurchaseOrder
   */
  public oracle.jbo.Row getPurchaseOrder()
  {
    return (oracle.jbo.Row)getAttributeInternal(PURCHASEORDER);
  }

  /**
   * 
   * Gets the associated <code>RowIterator</code> using master-detail link PurchaseOrderShipment
   */
  public oracle.jbo.RowIterator getPurchaseOrderShipment()
  {
    return (oracle.jbo.RowIterator)getAttributeInternal(PURCHASEORDERSHIPMENT);
  }

















  //  Generated method. Do not modify.

  //  Generated method. Do not modify.





}