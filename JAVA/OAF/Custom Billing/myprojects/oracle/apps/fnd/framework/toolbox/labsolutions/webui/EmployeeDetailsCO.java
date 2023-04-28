/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.webui;

import java.io.Serializable;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAPageLayoutBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.labsolutions.webui.EmpDetailsPG 
 * page.
 */
public class EmployeeDetailsCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: EmployeeDetailsCO.java 120.1 2005/06/06 10:59:11 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.labsolutions.webui");

  /**
   * Layout and page setup logic for region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    // Always call this first.
    super.processRequest(pageContext, webBean);

    // Get the employee number from the request.
    String employeeNumber = pageContext.getParameter("empNum");
    String employeeName = pageContext.getParameter("empName");

    // We need to set the page header text to include the employee name for reference.
    MessageToken[] tokens = { new MessageToken("EMP_NAME", employeeName) };

    // Always use a translated value from Applications Message Dictionary when 
    // setting Strings for display in your controllers.
    String pageHeaderText = pageContext.getMessage("AK", "FWK_TBX_T_EMP_HEADER_TEXT", tokens);

    // Set the employee-specific page title (which also appears in the breadcrumbs)
    ((OAPageLayoutBean)webBean).setTitle(pageHeaderText);
     
    // Now we want to initialize the query for our single purchase order with all of its
	  // details.  
    OAApplicationModule am = pageContext.getApplicationModule(webBean);
    Serializable[] parameters = { employeeNumber };
    am.invokeMethod("initDetails", parameters); 


  } // end processRequest()  
 
}
