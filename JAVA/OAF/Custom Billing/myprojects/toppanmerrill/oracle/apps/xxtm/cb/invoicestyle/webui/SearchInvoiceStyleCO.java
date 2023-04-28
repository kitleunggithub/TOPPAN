/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package toppanmerrill.oracle.apps.xxtm.cb.invoicestyle.webui;

import java.sql.Date;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.apps.fnd.framework.webui.beans.message.OAMessageChoiceBean;

import toppanmerrill.oracle.apps.xxtm.cb.invoicestyle.server.InvoiceStyleAMImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoicestyle.server.SearchInvoiceStyleVOImpl;

/**
 * Controller for ...
 */
public class SearchInvoiceStyleCO extends OAControllerImpl
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
    
    OAMessageChoiceBean languageBN = (OAMessageChoiceBean)webBean.findChildRecursive("Language");  
    languageBN.setPickListCacheEnabled(false); 
    
    /*
    OAQueryBean queryBean = (OAQueryBean)webBean.findChildRecursive("QueryRN");
    queryBean.clearSearchPersistenceCache(pageContext);    
    */
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
    
    System.out.println("SearchInvoiceStyleCO: processFormRequest() Event Param = " + pageContext.getParameter(EVENT_PARAM));
    System.out.println("SearchInvoiceStyleCO: processFormRequest() New Param = " + pageContext.getParameter("New"));  
    
    if (pageContext.getParameter("GoBN") != null){
        this.search(pageContext, webBean);
    }
    else if (pageContext.getParameter("New") != null){    
        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoicestyle/webui/UpdateInvoiceStylePG",
                                         null,
                                         OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                         null,                                                   
                                         null,
                                         true,                            
                                         OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
                                         OAWebBeanConstants.IGNORE_MESSAGES);        
        }
    else if ("Update".equals(pageContext.getParameter(EVENT_PARAM)))
    //else if (pageContext.getParameter("Update") != null)
    {
        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoicestyle/webui/UpdateInvoiceStylePG",
                                         null,
                                         OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                         null,                                                   
                                         null,
                                         true,                            
                                         OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
                                         OAWebBeanConstants.IGNORE_MESSAGES);
    }else{
        search(pageContext, webBean);
    }
  }

    private void search(OAPageContext pageContext, OAWebBean webBean){
    
        String styleNameStr = pageContext.getParameter("StyleName");
        String languageStr = pageContext.getParameter("Language");
        String statusStr = pageContext.getParameter("Status");
        
        InvoiceStyleAMImpl am=(InvoiceStyleAMImpl)pageContext.getApplicationModule(webBean);
        SearchInvoiceStyleVOImpl vo = (SearchInvoiceStyleVOImpl)am.findViewObject("SearchInvoiceStyleVO1");
        //vo.clearCache();
        vo.setFullSqlMode(vo.FULLSQL_MODE_AUGMENTATION);
        vo.setWhereClause(null);
        vo.setWhereClauseParams(null);
        
        int paraCount = 0;
        vo.addWhereClause(" 1=1 ");

        if(!(styleNameStr == null || styleNameStr.trim().length() == 0)) 
        {
        vo.setWhereClauseParam(paraCount++, styleNameStr.trim());
        vo.addWhereClause(" AND INVOICE_STYLE_NAME LIKE :"+ paraCount);
        }     

        if(!(languageStr == null || languageStr.trim().length() == 0)) 
        {
        vo.setWhereClauseParam(paraCount++, languageStr.trim());
        vo.addWhereClause(" AND LANGUAGE = :"+ paraCount);
        }
        
        if(!(statusStr == null || statusStr.trim().length() == 0)) 
        {
        vo.setWhereClauseParam(paraCount++, statusStr.trim());
        vo.addWhereClause(" AND Status = :"+ paraCount);
        }        
        
        vo.executeQuery();     
    }

}
