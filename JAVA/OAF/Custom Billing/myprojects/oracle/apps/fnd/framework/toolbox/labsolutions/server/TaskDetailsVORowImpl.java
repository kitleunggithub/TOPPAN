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

public class TaskDetailsVORowImpl extends OAViewRowImpl 
{

  public static final String RCS_ID="$Header: TaskDetailsVORowImpl.java 120.1 2005/06/06 10:31:52 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

  protected static final int PROJECTID = 0;
  protected static final int TOPTASKID = 1;
  protected static final int TASKID = 2;
  protected static final int TASKNUMBER = 3;
  protected static final int TASKNAME = 4;
  protected static final int STARTFROM = 5;
  protected static final int ENDTO = 6;
  protected static final int TEXTRIGHT = 7;
  protected static final int TASKTYPE = 8;
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public TaskDetailsVORowImpl()
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
   * Gets the attribute value for the calculated attribute TopTaskId
   */
  public Number getTopTaskId()
  {
    return (Number)getAttributeInternal(TOPTASKID);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute TopTaskId
   */
  public void setTopTaskId(Number value)
  {
    setAttributeInternal(TOPTASKID, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute TaskId
   */
  public Number getTaskId()
  {
    return (Number)getAttributeInternal(TASKID);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute TaskId
   */
  public void setTaskId(Number value)
  {
    setAttributeInternal(TASKID, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute TaskNumber
   */
  public String getTaskNumber()
  {
    return (String)getAttributeInternal(TASKNUMBER);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute TaskNumber
   */
  public void setTaskNumber(String value)
  {
    setAttributeInternal(TASKNUMBER, value);
  }

  /**
   * 
   * Gets the attribute value for the calculated attribute TaskName
   */
  public String getTaskName()
  {
    return (String)getAttributeInternal(TASKNAME);
  }

  /**
   * 
   * Sets <code>value</code> as the attribute value for the calculated attribute TaskName
   */
  public void setTaskName(String value)
  {
    setAttributeInternal(TASKNAME, value);
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
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case PROJECTID:
        return getProjectId();
      case TOPTASKID:
        return getTopTaskId();
      case TASKID:
        return getTaskId();
      case TASKNUMBER:
        return getTaskNumber();
      case TASKNAME:
        return getTaskName();
      case STARTFROM:
        return getStartFrom();
      case ENDTO:
        return getEndTo();
      case TEXTRIGHT:
        return getTextRight();
      case TASKTYPE:
        return getTaskType();
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
      case TOPTASKID:
        setTopTaskId((Number)value);
        return;
      case TASKID:
        setTaskId((Number)value);
        return;
      case TASKNUMBER:
        setTaskNumber((String)value);
        return;
      case TASKNAME:
        setTaskName((String)value);
        return;
      case STARTFROM:
        setStartFrom((Date)value);
        return;
      case ENDTO:
        setEndTo((Date)value);
        return;
      case TEXTRIGHT:
        setTextRight((String)value);
        return;
      case TASKTYPE:
        setTaskType((String)value);
        return;
      default:
        super.setAttrInvokeAccessor(index, value, attrDef);
        return;
      }
  }
}
