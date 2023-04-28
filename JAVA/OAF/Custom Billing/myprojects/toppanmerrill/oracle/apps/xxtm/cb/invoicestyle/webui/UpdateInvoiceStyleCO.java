/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package toppanmerrill.oracle.apps.xxtm.cb.invoicestyle.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.OAApplicationModule;
import java.io.Serializable;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageChoiceBean;

import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceAMImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoicestyle.server.InvoiceStyleAMImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoicestyle.server.SearchInvoiceStyleVOImpl;

/**
 * Controller for ...
 */
public class UpdateInvoiceStyleCO extends OAControllerImpl
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
    
    OAApplicationModule am = pageContext.getApplicationModule(webBean);
    System.out.println("UpdateInvoiceStyleCO: processRequest() PInvoiceStyleId = " + pageContext.getParameter("PInvoiceStyleId"));
    
    //if ("Update".equals(pageContext.getParameter(EVENT_PARAM)))
    String InvoiceStyleId = pageContext.getParameter("PInvoiceStyleId");
    
    if ((InvoiceStyleId != null) && (!("".equals(InvoiceStyleId.trim()))))
    {
        //String InvoiceStyleId = pageContext.getParameter("PInvoiceStyleId");
        Serializable[] params = { InvoiceStyleId };
        am.invokeMethod("updateRow", params);
    }
    else
    {   
        am.invokeMethod("createRow",null);
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

    //OAApplicationModule am = pageContext.getApplicationModule(webBean);
    InvoiceStyleAMImpl am=(InvoiceStyleAMImpl)pageContext.getApplicationModule(webBean);
    
    try
    {
        if (pageContext.getParameter("Save") != null)
        { 
            
            String styleNameStr = pageContext.getParameter("StyleName");
            System.out.println("UpdateInvoiceStyleCO: processRequest() StyleName = " + styleNameStr);
            
            String invoiceStyleId = am.getInvoiceStyleVO1().getCurrentRow().getAttribute("InvoiceStyleId").toString();
            System.out.println("UpdateInvoiceStyleCO: processRequest() PInvoiceStyleId = " + invoiceStyleId);
            
            if(!(styleNameStr == null || styleNameStr.trim().length() == 0)) 
            {
                SearchInvoiceStyleVOImpl vo = (SearchInvoiceStyleVOImpl)am.findViewObject("SearchInvoiceStyleVO1");
                vo.setFullSqlMode(vo.FULLSQL_MODE_AUGMENTATION);
                vo.setWhereClause(null);
                vo.setWhereClauseParams(null);
                
                int paraCount = 0;
                vo.addWhereClause(" 1=1 ");

                vo.setWhereClauseParam(paraCount++, styleNameStr.trim());
                vo.addWhereClause(" AND INVOICE_STYLE_NAME = :"+ paraCount);
                
                vo.setWhereClauseParam(paraCount++, invoiceStyleId.trim());
                vo.addWhereClause(" AND INVOICE_STYLE_ID <> :"+ paraCount);                
                vo.executeQuery();
                
                //System.out.println("getRowCount() = " + vo.getRowCount());        
                if (vo.getRowCount() >= 1) {
                    throw new OAException("Invoice Style Name ('"+styleNameStr+"') already exists", OAException.ERROR);
                }
            }            
            
        
            am.invokeMethod("apply");
            /*
            pageContext.forwardImmediately("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoicestyle/webui/SearchInvoiceStylePG",
                                                   null,
                                                   OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                                   null,
                                                   null,
                                                   false, // retain AM
                                                   OAWebBeanConstants.ADD_BREAD_CRUMB_NO);    
            */
            pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoicestyle/webui/SearchInvoiceStylePG",                                                null,
                                                    OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                                    null,                                                   
                                                    null,
                                                    false,                            
                                                    OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
                                                    OAWebBeanConstants.IGNORE_MESSAGES);                
        }
        else if (pageContext.getParameter("Back") != null)
        { 
            am.invokeMethod("rollback");
            pageContext.forwardImmediately("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoicestyle/webui/SearchInvoiceStylePG",
                                                  null,
                                                  OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                                  null,
                                                  null,
                                                  false, // retain AM
                                                  OAWebBeanConstants.ADD_BREAD_CRUMB_NO);
        }    
    }catch(Exception e)
    {
          //e.printStackTrace();
          throw new OAException(e.getMessage(), OAException.ERROR);          
    }
  }
}
