/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAEntityExpert;

/**
* Provides access to common validation utitilities. 
*/
public class EmployeeEntityExpert extends OAEntityExpert
{
  // Mandatory for Applications source control
  public static final String RCS_ID="$Header: EmployeeEntityExpert.java 120.1 2005/06/06 13:23:44 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");

  /*
   *****************************************************************************
   * Returns true if the given employee is currently active and false if not.
   *****************************************************************************
   */
  public boolean isEmployeeActive(Number employeeId)
  {
    boolean isActive = false;
    
	  // Note that we want to use a cached, declaratively defined VO instead of creating
	  // one from a SQL statement which is far less performant.

    EmployeeVVOImpl empVO = 
      (EmployeeVVOImpl)findValidationViewObject("EmployeeVVO1");
    empVO.initQuery(employeeId);

    // We're just doing a simple existance check.  If we don't find a match, return false.

    if (empVO.hasNext())
    {
      isActive = true;
    }

    return isActive;

  } // end isEmployeeActive()
  
  /*
   *****************************************************************************
   * Returns true if the given position is valid.
   *****************************************************************************
   */
  public boolean isPositionValid(String position)
  {
    boolean isActive = false;
    
	  // Note that we want to use a cached, declaratively defined VO instead of creating
	  // one from a SQL statement which is far less performant.

    PositionVVOImpl positionVO = 
      (PositionVVOImpl)findValidationViewObject("PositionVVO1");
    positionVO.initQuery(position);

    // We're just doing a simple existance check.  If we don't find a match, return false.

    if (positionVO.hasNext())
    {
      isActive = true;
    }

    return isActive;

  } // end isPositionValid()

}
