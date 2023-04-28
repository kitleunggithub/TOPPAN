/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.jbo.server.ViewLinkImpl;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;


public class GanttAMImpl extends OAApplicationModuleImpl 
{

  public static final String RCS_ID="$Header: GanttAMImpl.java 120.1 2005/06/06 10:04:09 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");
  public void initGanttQuery()
  {
    TaskListVOImpl vo = getTaskListVO1();
    if (vo == null)
      {
        MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "TaskListVO1")};
        throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
      }

    if (!vo.isPreparedForExecution())
    {
      vo.initQuery();
    }
  }
  // end initGanttQuery()
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public GanttAMImpl()
  {
  }

  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.labsolutions.server", "GanttAMLocal");
  }

  /**
   * 
   * Container's getter for TaskListVO1
   */
  public TaskListVOImpl getTaskListVO1()
  {
    return (TaskListVOImpl)findViewObject("TaskListVO1");
  }

  /**
   * 
   * Container's getter for TaskDetailsVO1
   */
  public OAViewObjectImpl getTaskDetailsVO1()
  {
    return (OAViewObjectImpl)findViewObject("TaskDetailsVO1");
  }

  /**
   * 
   * Container's getter for TaskDetailsVO2
   */
  public OAViewObjectImpl getTaskDetailsVO2()
  {
    return (OAViewObjectImpl)findViewObject("TaskDetailsVO2");
  }

  /**
   * 
   * Container's getter for TaskToDetailsVL1
   */
  public ViewLinkImpl getTaskToDetailsVL1()
  {
    return (ViewLinkImpl)findViewLink("TaskToDetailsVL1");
  }



}
