/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.OAProcessingPage;


/**
 * Controller for (page 1)the page from where the processing page has to be displayed
 */
public class ProcessExamplePageCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: ProcessExamplePageCO.java 120.1 2005/06/06 13:08:03 atgops1 noship $";
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

    if (pageContext.getParameter("ProcessLaunch")!= null)
    {
	   // Create the processing page to display and pass it the name of the contorller
	   // that implements the process launch and navigation to the page to display after
	   // the process completes.
       OAProcessingPage page
         = new OAProcessingPage("oracle.apps.fnd.framework.toolbox.samplelib.webui.ProcessPageCO");

       // NEVER hard-code a displayed text message as shown below. Always use Message Dictionary.
       page.setConciseMessage("This is a concise message");
       page.setDetailedMessage("This is a detailed message.");

       // Displays in the page title.
       page.setProcessName("<Process Name>");

       pageContext.forwardToProcessingPage(page);
    }
  }

}
