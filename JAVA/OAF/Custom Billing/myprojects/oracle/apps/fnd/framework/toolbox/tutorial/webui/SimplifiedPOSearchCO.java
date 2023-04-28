/*===========================================================================+
 |   Copyright (c) 2001, 2015 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.fnd.framework.toolbox.tutorial.webui;



import java.util.Hashtable;
import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAImageBean;
import oracle.apps.fnd.framework.webui.beans.OAStaticStyledTextBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.layout.OAInfotileBean;
import oracle.apps.fnd.framework.webui.beans.layout.OATileHeaderBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;
import oracle.cabo.style.CSSStyle;
import oracle.cabo.ui.data.ArrayDataSet;
import oracle.cabo.ui.data.DictionaryData;


/**
 * Controller for SimplifiedPOSearchPG.java
 */
public class SimplifiedPOSearchCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: SimplifiedPOSearchCO.java 120.0.12020000.7 2015/05/04 16:11:40 spunam noship $";
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
    OATableBean tableContent1 = (OATableBean)webBean.findIndexedChildRecursive("ResultsTable"); 
    int childCount = tableContent1.getIndexedChildCount(null); 
    DictionaryData columnHeaderFormats[] = new DictionaryData[childCount];
    for (int i = 0; i < childCount; i++) 
    { 
      columnHeaderFormats[i] = new DictionaryData();
      columnHeaderFormats[i].put(CELL_NO_WRAP_FORMAT_KEY, Boolean.TRUE); 
    }
    tableContent1.setColumnHeaderFormats(new ArrayDataSet(columnHeaderFormats));
    tableContent1.queryData(pageContext,false); //To fetch data for table during first laod
    
     OAWebBean infotileBean=webBean.findChildRecursive("infotile1");
     OATileHeaderBean tileList=(OATileHeaderBean)(((OAInfotileBean)infotileBean).getTileHeader());
     tileList.setInitialTileId("tile3");
     
    //Add necesary inline styles for each Tile 
    //bug#20351633, added styles for the new tile and removed extra code
    OAWebBean headerContent=webBean.findChildRecursive("tileitem11");
    Hashtable props = new Hashtable();
    props.put("color","red");
    props.put("font-size","50px");
    CSSStyle style1 = new CSSStyle(props);
    ((OAStaticStyledTextBean)headerContent).setInlineStyle(headerContent, style1); 
     
    OAWebBean headerContent2=webBean.findChildRecursive("tileitem21");     
    props.put("color","green");  
    CSSStyle style2 = new CSSStyle(props);
    ((OAStaticStyledTextBean)headerContent2).setInlineStyle(headerContent2, style2); 
     
    OAWebBean headerContent3=webBean.findChildRecursive("tileitem31");     
    props.put("color","blue"); 
    CSSStyle style3 = new CSSStyle(props);
    ((OAStaticStyledTextBean)headerContent3).setInlineStyle(headerContent3, style3);
    
  //  OAWebBean headerContent4=webBean.findChildRecursive("tileitem41");     
   // props.put("color","black");    
  //  CSSStyle style4 = new CSSStyle(props);
   // ((OAStaticStyledTextBean)headerContent3).setInlineStyle(headerContent4, style4);
       
    OATableBean table = (OATableBean)pageContext.getRootWebBean().findChildRecursive("ResultsTable");
    table.setAttributeValue(CONTROLBAR_RENDERING_STYLE,BUTTON_FORMAT);
     
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
    OATableBean tableContent1 = (OATableBean)webBean.findIndexedChildRecursive("ResultsTable");
    tableContent1.queryData(pageContext,false);
    
  }

}
