/*===========================================================================+
 |   Copyright (c) 2001, 2015 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.webui;

import java.io.Serializable;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageTextInputBean;
import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;

import oracle.bali.share.util.BooleanUtils;


/**
 * Controller for AdvTablePG.
 */
public class AdvTablePageCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: AdvTablePageCO.java 120.4.12020000.2 2015/09/21 06:09:50 spunam ship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

  /**
   * Layout and page setup logic for a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);

    // The special query handling for the table is required per the coding
    // standards.

    OAApplicationModule am = pageContext.getApplicationModule(webBean);
 
    Boolean executeQuery = BooleanUtils.getBoolean(false);
    Serializable[] parameters =  { executeQuery };
    Class[] paramTypes = { Boolean.class };
    am.invokeMethod("initTableQuery", parameters, paramTypes);
      OAMessageTextInputBean   Salary = (OAMessageTextInputBean)webBean.findChildRecursive("Salary");
         if(Salary!=null) {
           Salary.setAttributeValue(CURRENCY_CODE,"USD");  
         }

    OAAdvancedTableBean table = 
      (OAAdvancedTableBean)webBean.findChildRecursive("TableRN");

    if (table == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "TableRN") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

    // We pass "true" to the queryData() method because we don't want it to
    // unconditionally execute the query if the VO has already been queried.
    // In an updateable VO, unconditional query execution would cause the loss
    // of VO state (including user-entered data).  See View Objects in Detail ->
    // Initialization guidelines for additional information.
    table.queryData(pageContext, true);

    // QueryData for the second AdvancedTable (LookupCodes) on the page
    OAAdvancedTableBean table2 = 
      (OAAdvancedTableBean)webBean.findChildRecursive("Table2RN");
      
    table2.queryData(pageContext, true);


    // Initialize the VO associated with the second table for inserts.
    am.invokeMethod("initLookupCodes");

    //ER#4653823 : Initialize the VO associated with the third table
    am.invokeMethod("initTable3VO");
  }

  /**
   * Procedure to handle form submissions for form elements in
   * a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);

    OAApplicationModule am = pageContext.getApplicationModule(webBean);

    // Handle the submit button press actions.
    if (pageContext.getParameter("SomeAction") != null)
    {
      // am.invokeMethod("<someActionHandler>");

    }
       // bug 10198957 blash
       else if (pageContext.getParameter("saveEmp") != null)
       {
       am.invokeMethod("updateEmployee");
    }
    
  }

}
