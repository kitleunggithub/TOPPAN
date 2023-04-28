/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |       27-MAY-02  L Lyons  Created.                                        |
 |                                                                           |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.server;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class HomeAMImpl extends OAApplicationModuleImpl {

  public static final String RCS_ID="$Header: HomeAMImpl.java 120.2 2006/07/03 23:30:07 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");

  /*
   *****************************************************************************
   * Initializes the purchase order query.
   *****************************************************************************
   */
  public void initPOSummary(String orderNumber,
                            String created,
                            String showMyOrders,
                            Boolean executeQuery)
  {
    PoSimpleSummaryVOImpl vo = getPoSimpleSummaryVO1();

    if (vo == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "PoSimpleSummaryVO1") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

    // Per Back Button guidelines, never do a blind query without first checking
    // to see if it's necessary.
    
    if (!vo.isPreparedForExecution())
    {
      vo.initQuery(orderNumber, created, showMyOrders, executeQuery);
    }  
    
  }  // end initPOSummary()

//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here...
//  ---------------------------------------------------------------


  /**
   * 
   * This is the default constructor (do not remove)
   */
  public HomeAMImpl()
  {
  }



  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.tutorial.server", "HomeAMLocal");
  }


  /**
   * 
   * Container's getter for HomeSearchObjectsVO1
   */
  public OAViewObjectImpl getHomeSearchObjectsVO1()
  {
    return (OAViewObjectImpl)findViewObject("HomeSearchObjectsVO1");
  }

  /**
   * 
   * Container's getter for PoSimpleSummaryVO1
   */
  public PoSimpleSummaryVOImpl getPoSimpleSummaryVO1()
  {
    return (PoSimpleSummaryVOImpl)findViewObject("PoSimpleSummaryVO1");
  }
}
