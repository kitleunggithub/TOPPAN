/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.common.MessageToken;
import oracle.jbo.Key;
import oracle.jbo.Row;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.server.OAViewObjectImpl;

public class FlexfieldAMImpl extends OAApplicationModuleImpl 
{

  public static final String RCS_ID="$Header: FlexfieldAMImpl.java 120.1 2005/06/06 10:01:50 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");
  /*****************************************************************************
  * Initializes the item details query.
  *****************************************************************************
  */
  public void initDetails(String itemNumber)
  {
    ItemDetailsVOImpl vo = getItemDetailsVO1();
    if (vo == null)
    {
      MessageToken[] errTokens = { new MessageToken("OBJECT_NAME", "ItemDetailsVO1")};
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", errTokens);
    } 

    // First, construct an oracle.jbo.Key object as required in the Key constructor
    // Javadoc.  Then, call findByKey indicating that we're looking for a single
    // row.  BC4J tries to find the entity object(s) for this row in its cache, and failing
    // that, will query from the database using the given key.

    String[] keys = { itemNumber };
    Row[] rows = vo.findByKey(new Key(keys), 1);

    // You must set the current row, or the Details page won't display any
    // data. When you explicitly query data, you don't have to do this 
    // because the OA Framework automatically invokes vo.first() in the 
    // result set, thereby establishing a current row.

    if (rows != null)
    {
      vo.setCurrentRow(rows[0]);
    }
   
  } // end initDetails()
  
  public String isVOQueried(String viewUsageName)
  {
    OAViewObject vo = (OAViewObject)findViewObject(viewUsageName);
    if (vo == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", viewUsageName)};
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

    return (vo.isPreparedForExecution()) ? "Y" : "N";
           
  } // end isVOQueried(}
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public FlexfieldAMImpl()
  {
  }

  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.fnd.framework.toolbox.labsolutions.server", "FlexfieldAMLocal");
  }

  /**
   * 
   * Container's getter for ItemSummaryVO1
   */
  public OAViewObjectImpl getItemSummaryVO1()
  {
    return (OAViewObjectImpl)findViewObject("ItemSummaryVO1");
  }

  /**
   * 
   * Container's getter for ItemDetailsVO1
   */
  public ItemDetailsVOImpl getItemDetailsVO1()
  {
    return (ItemDetailsVOImpl)findViewObject("ItemDetailsVO1");
  }
}
