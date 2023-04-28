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

import oracle.jbo.Key;
import oracle.jbo.Row;

import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

import oracle.jbo.server.ViewLinkImpl;
import oracle.apps.fnd.framework.toolbox.poplist.server.StatusListVOImpl;

public class SearchAMImpl extends OAApplicationModuleImpl {

  public static final String RCS_ID="$Header: SearchAMImpl.java 120.2 2006/07/04 02:06:04 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.server");

  /*
   *****************************************************************************
   * Returns "Y" if the given view instance flag has been queried, "N" otherwise.
   *****************************************************************************
  */
  public String isVOQueried(String viewInstanceName)
  {
    OAViewObject vo = (OAViewObject)findViewObject(viewInstanceName);

    if (vo == null)
    {
        MessageToken[] tokens = { new MessageToken("OBJECT_NAME", viewInstanceName) };
        throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

    return (vo.isPreparedForExecution()) ? "Y" : "N";
    
  } // end isVOQueried()

  /*
   *****************************************************************************
   * Initializes the detail purchase order query.
   *****************************************************************************
   */
  public void initDetails(String orderNumber)
  {
    OAViewObjectImpl vo = getPoDetailsFullExpVO1();
       
    if (vo == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "PoDetailsFullExpVO1") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

    //  Convert the incoming String parameter to a Number.
    Number orderNum = null;
    
    try
    {
      orderNum = new Number(orderNumber);
    }
    catch(Exception e) {}

    // First, construct an oracle.jbo.Key object as required in the findByKey constructor
    // Javadoc.  Then, call findByKey indicating that we're looking for a single
    // row.  BC4J tries to find the entity object(s) for this row in its cache, and failing
    // that, will query from the database using the given key.

    Number[] keys = { orderNum };
    Row[] rows = vo.findByKey(new Key(keys), 1);

    // You must set the current row, or the Details page won't display any
    // data. When you explicitly query data, you don't have to do this 
    // because the OA Framework automatically invokes vo.first() in the 
    // result set, thereby establishing a current row.

    if ((rows != null) && (rows.length > 0))
    {
      vo.setCurrentRow(rows[0]);
    }
 
  } // end initDetails()

  /*
   *****************************************************************************
   * Initializes the summary PO query.
   *****************************************************************************
   */
  public void initSummary(String orderNumber, 
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
  
    vo.initQuery(orderNumber, created, showMyOrders, executeQuery);
    
  } // end initSummary()


//  ---------------------------------------------------------------
//  ---    Unmodified, generated code from here.
//  ---------------------------------------------------------------

  
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public SearchAMImpl()
  {
  }



  /**
   * 
   * Container's getter for PoHeaderToLinesVL
   */
  public ViewLinkImpl getPoHeaderToLinesVL()
  {
    return (ViewLinkImpl)findViewLink("PoHeaderToLinesVL");
  }

  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.tutorial.server", "SearchAMLocal");
  }

  /**
   * 
   * Container's getter for PoDetailsFullExpVO1
   */
  public OAViewObjectImpl getPoDetailsFullExpVO1()
  {
    return (OAViewObjectImpl)findViewObject("PoDetailsFullExpVO1");
  }

  /**
   * 
   * Container's getter for CreatedListVO1
   */
  public OAViewObjectImpl getCreatedListVO1()
  {
    return (OAViewObjectImpl)findViewObject("CreatedListVO1");
  }

  /**
   * 
   * Container's getter for StatusListVO1
   */
  public StatusListVOImpl getStatusListVO1()
  {
    return (StatusListVOImpl)findViewObject("StatusListVO1");
  }

  /**
   * 
   * Container's getter for PoSimpleSummaryVO1
   */
  public PoSimpleSummaryVOImpl getPoSimpleSummaryVO1()
  {
    return (PoSimpleSummaryVOImpl)findViewObject("PoSimpleSummaryVO1");
  }

  /**
   * 
   * Container's getter for PoLinesExpVO1
   */
  public PoLinesExpVOImpl getPoLinesExpVO1()
  {
    return (PoLinesExpVOImpl)findViewObject("PoLinesExpVO1");
  }
}
