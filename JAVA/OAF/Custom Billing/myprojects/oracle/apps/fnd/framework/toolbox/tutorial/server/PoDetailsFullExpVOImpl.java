/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class PoDetailsFullExpVOImpl extends OAViewObjectImpl 
{
  // Mandatory for Applications source control.
  public static final String RCS_ID="$Header: PoDetailsFullExpVOImpl.java 120.1 2005/06/06 15:37:16 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");

  public void initQuery(String orderNumber)
  {
    if ((orderNumber != null) && (!("".equals(orderNumber.trim()))))
    {
      if (isSearchCriteriaNew(orderNumber))
      {
        // Do the following converion for type consistency.
        Number orderNum = null;
        try
        {
          orderNum = new Number(orderNumber);
        }  
        catch(Exception e) {}
        setWhereClauseParams(null); // Always reset

        setWhereClauseParam(0, orderNum);

        executeQuery();
      
      }  
    }
  }

  private boolean isSearchCriteriaNew(String orderNumber)
  {
     boolean isNew = true;
     
     // Get the orderNum parameter currently stored in the VO. 
     Object[] parameters = getWhereClauseParams();

     if (parameters.length > 0)
     {
       // BC4J stores these things as Strings when passivation is enabled;
       // as typed objects when not. 
       String orderNumParam = parameters[0].toString();

       if (orderNumber.compareTo(orderNumParam) == 0)
       {
           isNew = false;
       }
     }  

     return isNew;
     
  } // end isSearchCriteriaNew()  
  
//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here...
//  ---------------------------------------------------------------

  
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public PoDetailsFullExpVOImpl()
  {
  }
}
