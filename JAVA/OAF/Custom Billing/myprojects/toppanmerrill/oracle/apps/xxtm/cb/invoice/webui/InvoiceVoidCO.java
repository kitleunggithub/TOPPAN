/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package toppanmerrill.oracle.apps.xxtm.cb.invoice.webui;

import java.math.BigDecimal;

import java.sql.SQLException;

import java.util.ArrayList;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.apps.fnd.framework.webui.beans.layout.OASubTabLayoutBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageCheckBoxBean;

import oracle.apps.fnd.framework.webui.beans.message.OAMessageChoiceBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageTextInputBean;

import oracle.apps.fnd.framework.webui.beans.nav.OALinkBean;

import oracle.jbo.Row;

import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceVoidVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceAMImpl;

/**
 * Controller for ...
 */
public class InvoiceVoidCO extends OAControllerImpl
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
        
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        
        String customerTrxIdStr = pageContext.getParameter("CustomerTrxId");
        System.out.println("InvoiceVoidCO:  customerTrxIdStr "+customerTrxIdStr);
        
        if (InvoiceClientUtil.isNull(customerTrxIdStr)){
            customerTrxIdStr = "";
        }
        String[] customerTrxIdArray = customerTrxIdStr.split("\\|");
      
        if (customerTrxIdArray != null && customerTrxIdArray.length>0){
            InvoiceVoidVOImpl invoiceVoidVO = am.getInvoiceVoidVO1();
            
            invoiceVoidVO.setWhereClause(null);
            invoiceVoidVO.setWhereClauseParams(null);
            invoiceVoidVO.setFullSqlMode(invoiceVoidVO.FULLSQL_MODE_AUGMENTATION);
            StringBuffer query = new StringBuffer(invoiceVoidVO.getQuery()); 
            invoiceVoidVO.addWhereClause(" CUSTOMER_TRX_ID IN "+constructClause(customerTrxIdArray));
//            query.append(" AND invoice.CUSTOMER_TRX_ID IN "+constructClause(customerTrxIdArray));
            
            System.out.println("InvoiceVoidCO:  query "+query.toString());
            invoiceVoidVO.setQuery(query.toString());            
            invoiceVoidVO.executeQuery();
            
            
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
       
        if (pageContext.getParameter("SubmitForApprovalBN") != null){
            submitForApprovalVoid(pageContext, webBean);
            backToSearch(pageContext, webBean);
        }else if (pageContext.getParameter("CancelVoidBN") != null){
            unSave(pageContext, webBean);
            backToSearch(pageContext, webBean);
        }
       
    }

    private void submitForApprovalVoid(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        InvoiceVoidVOImpl invoiceVoidVO = am.getInvoiceVoidVO1();

        OAMessageChoiceBean  approvalReasonFD = (OAMessageChoiceBean ) webBean.findChildRecursive("ApprovalReasonFD");
        OAMessageTextInputBean justificationFD = (OAMessageTextInputBean) webBean.findChildRecursive("JustificationFD");
        String approvalReason = approvalReasonFD.getValue(pageContext).toString();
        String justification =justificationFD.getValue(pageContext).toString();
        Row[] invoiceVoidVOList =  invoiceVoidVO.getAllRowsInRange();
        if (invoiceVoidVOList != null){
            for (int i=0;i<invoiceVoidVOList.length;i++){
                Row invoiceVORec = invoiceVoidVOList[i];      
                String customerTrxId = invoiceVORec.getAttribute("CustomerTrxId").toString();
                am.submitForApprovalVoid(customerTrxId,approvalReason, justification );                
            }
        }
        am.getTransaction().commit(); 
        
    }


    private void unSave(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        am.getTransaction().rollback();   
    }
    
    
    private void backToSearch(OAPageContext pageContext, OAWebBean webBean){
        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/SearchInvoicePG",
                                          null,
                                          OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                          null,                                                   
                                          null,
                                          false,                            
                                          OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
                                          OAWebBeanConstants.IGNORE_MESSAGES);
       
    }


    private String constructClause(String[] customerTrxIdArray){
        StringBuffer strBufffer = new StringBuffer("");

        strBufffer.append("(");
        for(int i=0;i<customerTrxIdArray.length;i++){
            strBufffer.append(customerTrxIdArray[i]);
            if (i < customerTrxIdArray.length - 1){
                strBufffer.append(",");
            }
            
        }
        strBufffer.append(")");
        
        return strBufffer.toString();
    }
    
}
