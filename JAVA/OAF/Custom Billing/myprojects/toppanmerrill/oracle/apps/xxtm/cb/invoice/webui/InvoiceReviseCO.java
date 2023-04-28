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

import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceReviseVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceVoidVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceAMImpl;

/**
 * Controller for ...
 */
public class InvoiceReviseCO extends OAControllerImpl
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
        Row invoiceRow = null;
        
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        
        String customerTrxId = pageContext.getParameter("CustomerTrxId");
        System.out.println("InvoiceReviseCO:  customerTrxId "+customerTrxId);
        
      
        if (!InvoiceClientUtil.isNull(customerTrxId)){
            InvoiceReviseVOImpl invoiceReviseVO = am.getInvoiceReviseVO1();
            
            invoiceReviseVO.setWhereClause(null);
            invoiceReviseVO.setWhereClauseParams(null);
            
            invoiceReviseVO.setWhereClause(" CUSTOMER_TRX_ID = :1 ");
            invoiceReviseVO.setWhereClauseParam(0,customerTrxId );
                        
            invoiceReviseVO.executeQuery();
            
            if (invoiceReviseVO.getRowCount() >0){
                invoiceRow = invoiceReviseVO.first();
            }
            
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
            submitForApprovalRevise(pageContext, webBean);
            backToSearch(pageContext, webBean);
        }else if (pageContext.getParameter("CancelReviseBN") != null){
            unSave(pageContext, webBean);
            backToSearch(pageContext, webBean);
        }
       
    }

    private void submitForApprovalRevise(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        InvoiceReviseVOImpl invoiceReviseVO = am.getInvoiceReviseVO1();

        OAMessageChoiceBean  approvalReasonFD = (OAMessageChoiceBean ) webBean.findChildRecursive("ApprovalReasonFD");
        OAMessageTextInputBean justificationFD = (OAMessageTextInputBean) webBean.findChildRecursive("JustificationFD");
        OAMessageTextInputBean invoiceReviseNumFD = (OAMessageTextInputBean) webBean.findChildRecursive("InvoiceReviseNumFD");
        String approvalReason = approvalReasonFD.getValue(pageContext).toString();
        String justification =justificationFD.getValue(pageContext).toString();
        int reviseToNum = 1;
        try{
            reviseToNum = Integer.parseInt(invoiceReviseNumFD.getValue(pageContext).toString());
        }catch(Exception e){
            e.printStackTrace();
            throw new OAException("Invalid Number for 'Revise to Invoice(s)' ", OAException.ERROR);   
        }
        if (reviseToNum <= 0 || reviseToNum > 50){
            throw new OAException("Invalid Number for 'Revise to Invoice(s)' ", OAException.ERROR);   
        }
        
        String customerTrxId = invoiceReviseVO.getCurrentRow().getAttribute("CustomerTrxId").toString();
        am.checkTrxForRevise(customerTrxId);                
//        am.submitForApprovalRevise(customerTrxId, 1 , approvalReason, justification );          
        am.submitForApprovalRevise(customerTrxId, reviseToNum , approvalReason, justification );          
        
        /*
         Row[] invoiceReviseVOList =  invoiceReviseVO.getAllRowsInRange();
        if (invoiceReviseVOList != null){
            for (int i=0;i<invoiceReviseVOList.length;i++){
                Row invoiceVORec = invoiceReviseVOList[i];      
                String customerTrxId = invoiceVORec.getAttribute("CustomerTrxId").toString();
                am.submitForApprovalRevise(customerTrxId,approvalReason, justification );                
            }
        }
        */
        am.getTransaction().commit(); 
        
    }


    private void unSave(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        am.getTransaction().rollback();   
    }
    
    
    private void backToDetail(OAPageContext pageContext, OAWebBean webBean){
        Row invoiceRow = null;
        String customerTrxId = null;
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        InvoiceReviseVOImpl invoiceReviseVO = am.getInvoiceReviseVO1();
        if (invoiceReviseVO.getCurrentRow() != null){
            invoiceRow = invoiceReviseVO.getCurrentRow();
        }else{
            invoiceRow = invoiceReviseVO.first();
        }
        
        if (invoiceRow !=null) customerTrxId = invoiceRow.getAttribute("CustomerTrxId").toString();
        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceDetailPG&CustomerTrxId="+customerTrxId+"&"+OASubTabLayoutBean.OA_SELECTED_SUBTAB_IDX+"=0",
                                          null,
                                          OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                          null,                                                   
                                          null,
                                          false,                            
                                          OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
                                          OAWebBeanConstants.IGNORE_MESSAGES);
       
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


    
}
