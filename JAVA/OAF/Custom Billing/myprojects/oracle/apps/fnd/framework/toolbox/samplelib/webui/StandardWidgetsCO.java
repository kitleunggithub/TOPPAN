/*===========================================================================+
 |   Copyright (c) 2001, 2003 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.samplelib.webui;

import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.form.OADefaultListBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageLayoutBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageRadioButtonBean;

/**
 * Controller for ...
 */
public class StandardWidgetsCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: StandardWidgetsCO.java 120.1 2005/06/06 13:12:25 atgops1 noship $";
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
    
     OAApplicationModule am = pageContext.getApplicationModule(webBean);
     am.invokeMethod("initializeEmployees");

     // Create the list bean (be sure to give it a name).
     OADefaultListBean list = 
      (OADefaultListBean)createWebBean(pageContext,
                                      OAWebBeanConstants.DEFAULT_LIST_BEAN,
                                      null, "positionsList");  

    // Specify the view object that you will use to populate the list bean values.
    list.setListViewObjectDefinitionName("oracle.apps.fnd.framework.toolbox.poplist.server.PositionsVO");    
   
    // Specify the display and internal value attributes in the associated view object.
    list.setListValueAttribute("LookupCode"); 
    list.setListDisplayAttribute("Meaning"); 

    // Configure the list box to allow selection of multiple values.
    list.setMultiple(true);

    // Even though you created the component with an ID, you must explicitly 
    // make this call to setName().
    list.setName("posList");

    // Get the declaratively defined messageLayout region that will contain this component.
    OAMessageLayoutBean listBoxLayout = 
      (OAMessageLayoutBean)webBean.findChildRecursive("ListBoxLayout");
    listBoxLayout.addIndexedChild(list);

    // Make sure the prompt on the messageLayout region used for the set of
    // checkboxes is vertically aligned to the top.
    OAMessageLayoutBean checkBoxLayout = 
      (OAMessageLayoutBean)webBean.findChildRecursive("CheckboxSetLayout");
    checkBoxLayout.setVAlign(OAWebBeanConstants.V_ALIGN_TOP);

    // Configure the radio buttons as a group by 1) assinging them all the
    // same name and 2) assigning values to each radio button.
    OAMessageRadioButtonBean appleButton = 
      (OAMessageRadioButtonBean)webBean.findChildRecursive("GroupButtonOne");
    appleButton.setName("fruitRadioGroup");
    appleButton.setValue("APPLES");

    OAMessageRadioButtonBean orangeButton = 
      (OAMessageRadioButtonBean)webBean.findChildRecursive("GroupButtonTwo");
    orangeButton.setName("fruitRadioGroup");
    orangeButton.setValue("ORANGES");

    OAMessageRadioButtonBean grapeButton = 
      (OAMessageRadioButtonBean)webBean.findChildRecursive("GroupButtonThree");
    grapeButton.setName("fruitRadioGroup");
    grapeButton.setValue("GRAPES");

    OAMessageRadioButtonBean plumButton = 
      (OAMessageRadioButtonBean)webBean.findChildRecursive("GroupButtonFour");
    plumButton.setName("fruitRadioGroup");
    plumButton.setValue("PLUMS");

    // Configure the combined fields with a single prompt so any client side
    // validation errors for the poplist or the field are displayed for the
    // messageLayoutBean prompt as if this were a single component.
    OAMessageLayoutBean msgLayout = 
      (OAMessageLayoutBean)webBean.findIndexedChildRecursive("CombinedFieldsLayout");   
    msgLayout.setLabeledNodeID("CombinedPoplist CombinedTextField");
    
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

    if ("SF".equals(pageContext.getParameter(OAWebBeanConstants.EVENT_PARAM)))
    {
      String fixedValue = pageContext.getParameter("FixedValue");
      String boundValue = pageContext.getParameter("BoundValue");
    }

    OADefaultListBean list = 
      (OADefaultListBean)webBean.findChildRecursive("positionsList");
    String name = list.getName();
    String[] selectedValues = pageContext.getParameterValues(name);

    String radioGroupValue = pageContext.getParameter("fruitRadioGroup");


  }

}
