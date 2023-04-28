/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.labsolutions.webui;

import oracle.jbo.domain.Number;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

/**
 * Controller for ...
 */
public class DebugLabCreateCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: DebugLabCreateCO.java 120.1 2005/06/06 10:45:40 atgops1 noship $";
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

     String pageMode = pageContext.getParameter("pgMode");

      if ("CR".equals(pageMode))
      {

        OAApplicationModule am = pageContext.getApplicationModule(webBean);
        am.invokeMethod("rollbackEmployee");
        am.invokeMethod("createEmployee");

      }
      else
      {

        OADialogPage dialogPage = new OADialogPage(STATE_LOSS_ERROR);
        pageContext.redirectToDialogPage(dialogPage);

      }
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

    if (pageContext.getParameter("Apply") != null)
    {

      OAViewObject vo = (OAViewObject)am.findViewObject("DebugLabEmpFullVO1");
	    String employeeName = (String)vo.getCurrentRow().getAttribute("EmployeeName");
	    Number employeeNumber = (Number)vo.getCurrentRow().getAttribute("EmployeeId");
      String employeeNum = String.valueOf(employeeNumber.intValue());

      am.invokeMethod("apply");

      MessageToken[] tokens = { new MessageToken("EMP_NAME", employeeName),
                                 new MessageToken("EMP_NUMBER", employeeNum) };


       OAException confirmMessage = new OAException("AK", "FWK_TBX_T_EMP_CREATE_CONFIRM", tokens,
                                       OAException.CONFIRMATION, null);

       pageContext.putDialogMessage(confirmMessage);                 


    }
  }

}
