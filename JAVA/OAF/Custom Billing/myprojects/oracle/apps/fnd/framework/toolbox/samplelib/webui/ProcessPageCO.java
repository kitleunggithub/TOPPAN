/*===========================================================================+
 |   Copyright (c) 2001, 2014 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.jbo.common.Diagnostic;

/**
 * Developer's Controller for doing the background process.
 */
public class ProcessPageCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: ProcessPageCO.java 120.1.12020000.2 2014/03/03 09:02:38 spunam ship $";
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

    // This is where you would start your process... this is just junk code so
    // we can bring up the processing page.
    for (long i= 0; i < 100; i++) 
    {
      for (long j = 0; j < 100; j++)
      {
        Diagnostic.println(""+12345678.8970/1234356537.998 * 24536478590.786);
      }
    }
    
    // Finally, navigate to the page to display when processing completes. In this
    // example we show a Confirmation dialog (a common scenario following processing).
    // You could also forward to a page with a "Confirmation" message.
    // NOTE: for convenience, creating this without a message.  You should never do this.
    // Note that we release the root "UI" application module so we can correctly
    // handle any subsequent "Back" button navigation and attempts to resubmit
    // the process.
       
       pageContext.releaseRootApplicationModule();
       pageContext.redirectToDialogPage(OAException.CONFIRMATION, 
                                                null,
                                                null, 
                                                "OA.jsp?page=/oracle/apps/fnd/framework/toolbox/samplelib/webui/SampleBrowserPG", 
                                                null,false);
        
  }
}
