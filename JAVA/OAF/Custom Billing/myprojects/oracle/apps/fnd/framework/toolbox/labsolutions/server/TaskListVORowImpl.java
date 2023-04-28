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

public class TaskListVORowImpl extends OAViewRowImpl 
{

  public static final String RCS_ID="$Header: TaskListVORowImpl.java 120.1 2005/06/06 10:36:29 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

  protected static final int PROJECTID = 0;
  protected static final int NAME = 1;
  protected static final int STARTDATE = 2;
  protected static final int COMPLETIONDATE = 3;
  protected static final int STARTFROM = 4;
  protected static final int TASKTYPE = 5;
  protected static final int ENDTO = 6;
  protected static final int TEXTRIGHT = 7;
  protected static final int TASKDETAILSVO = 8;
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public TaskListVORowImpl()
  {
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute ProjectId
   */
  public Number getProjectId()
  {
    return (Number)getAttributeInternal(PROJECTID);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute ProjectId
   */
  public void setProjectId(Number value)
  {
    setAttributeInternal(PROJECTID, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute Name
   */
  public String getName()
  {
    return (String)getAttributeInternal(NAME);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute Name
   */
  public void setName(String value)
  {
    setAttributeInternal(NAME, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute StartDate
   */
  public Date getStartDate()
  {
    return (Date)getAttributeInternal(STARTDATE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute StartDate
   */
  public void setStartDate(Date value)
  {
    setAttributeInternal(STARTDATE, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute CompletionDate
   */
  public Date getCompletionDate()
  {
    return (Date)getAttributeInternal(COMPLETIONDATE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute CompletionDate
   */
  public void setCompletionDate(Date value)
  {
    setAttributeInternal(COMPLETIONDATE, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute StartFrom
   */
  public Date getStartFrom()
  {
    return (Date)getAttributeInternal(STARTFROM);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute StartFrom
   */
  public void setStartFrom(Date value)
  {
    setAttributeInternal(STARTFROM, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute TaskType
   */
  public String getTaskType()
  {
    return (String)getAttributeInternal(TASKTYPE);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute TaskType
   */
  public void setTaskType(String value)
  {
    setAttributeInternal(TASKTYPE, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute EndTo
   */
  public Date getEndTo()
  {
    return (Date)getAttributeInternal(ENDTO);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute EndTo
   */
  public void setEndTo(Date value)
  {
    setAttributeInternal(ENDTO, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute TextRight
   */
  public String getTextRight()
  {
    return (String)getAttributeInternal(TEXTRIGHT);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute TextRight
   */
  public void setTextRight(String value)
  {
    setAttributeInternal(TEXTRIGHT, value);
  }
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case PROJECTID:
        return getProjectId();
      case NAME:
        return getName();
      case STARTDATE:
        return getStartDate();
      case COMPLETIONDATE:
        return getCompletionDate();
      case STARTFROM:
        return getStartFrom();
      case TASKTYPE:
        return getTaskType();
      case ENDTO:
        return getEndTo();
      case TEXTRIGHT:
        return getTextRight();
      case TASKDETAILSVO:
        return getTaskDetailsVO();
      default:
        return super.getAttrInvokeAccessor(index, attrDef);
      }
  }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case PROJECTID:
        setProjectId((Number)value);
        return;
      case NAME:
        setName((String)value);
        return;
      case STARTDATE:
        setStartDate((Date)value);
        return;
      case COMPLETIONDATE:
        setCompletionDate((Date)value);
        return;
      case STARTFROM:
        setStartFrom((Date)value);
        return;
      case TASKTYPE:
        setTaskType((String)value);
        return;
      case ENDTO:
        setEndTo((Date)value);
        return;
      case TEXTRIGHT:
        setTextRight((String)value);
        return;
      default:
        super.setAttrInvokeAccessor(index, value, attrDef);
        return;
      }
  }

  /**
   * 
   * Gets the associated <code>RowIterator</code> using master-detail link TaskDetailsVO
   */
  public oracle.jbo.RowIterator getTaskDetailsVO()
  {
    return (oracle.jbo.RowIterator)getAttributeInternal(TASKDETAILSVO);
  }


}
