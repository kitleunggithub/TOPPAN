/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.fnd.framework.toolbox.samplelib.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.form.OAInlineDatePickerBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageDateFieldBean;

/**
 * Controller for ...
 */
public class DatePickerCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header$";
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
    
      OAInlineDatePickerBean inlineDatePicker = (OAInlineDatePickerBean) createWebBean(pageContext, INLINE_DATEPICKER_BEAN);
      inlineDatePicker.setID("DatePicker1");
      OAMessageDateFieldBean dateField = (OAMessageDateFieldBean)webBean.findIndexedChildRecursive("DateItem1");
      dateField.setPickerId("DatePicker1");
      webBean.addIndexedChild(inlineDatePicker);
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
  }

}
