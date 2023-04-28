/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package toppanmerrill.oracle.apps.xxtm.cb.invoice.webui;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import java.util.Set;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OARow;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAImageBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.form.OASubmitButtonBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageLovInputBean;
import oracle.apps.fnd.framework.webui.beans.nav.OANavigationBarBean;
import oracle.apps.fnd.framework.webui.beans.nav.OATrainBean;

import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;
import oracle.apps.fnd.framework.webui.beans.table.OAColumnBean;

import oracle.cabo.ui.UINode;

import oracle.jbo.Row;

import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceCombineReqDtlVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceCombineReqVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceSalesRepSplitsVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceAMImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceLovVOImpl;

/**
 * Controller for ...
 */
public class InvoiceCombineCO extends OAControllerImpl
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
        
        Row combineReqRow = null;
        String status = null;
        String reqType = null;
        String readOnly = pageContext.getParameter("ReadOnly");
        String newlyCreated = pageContext.getParameter("NewlyCreated");
        
        if (!InvoiceClientUtil.isNull(readOnly)){
            pageContext.putSessionValue("InvoiceCombineReadOnly",readOnly);
        }else{
            readOnly = (String)pageContext.getSessionValue("InvoiceCombineReadOnly");
        }
        boolean isInquiryFlag = pageContext.getResponsibilityName().contains("Inquiry");
        boolean isBillerFlag = pageContext.getResponsibilityName().contains("Biller");
        boolean isManagerFlag = pageContext.getResponsibilityName().contains("Manager");
        boolean isSysAdminFlag = pageContext.getResponsibilityName().contains("Sysadmin");    
        if (isInquiryFlag){
            readOnly = "Y";
        }
        
        boolean readOnlyFlag = (!InvoiceClientUtil.isNull(readOnly) && readOnly.equals("Y")) ? true : false;
        boolean newlyCreatedFlag = (!InvoiceClientUtil.isNull(newlyCreated) && newlyCreated.equals("Y")) ? true : false;
        
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String pageURL = pageContext.getCurrentUrl ();
        int lastIndex  = pageURL.lastIndexOf('/');;
        String finalPageNameStr = pageURL.substring(lastIndex + 1, pageURL.indexOf("&"));
          //pageContext.writeDiagnostics(this,"Final Page Name -->" + finalPageNameStr,1);    
        System.out.println("InvoiceCombineCO: finalPageNameStr "+finalPageNameStr);
        System.out.println("InvoiceCombineCO: readOnlyFlag "+readOnlyFlag);
        System.out.println("InvoiceCombineCO: newlyCreatedFlag "+newlyCreatedFlag);
        //if (!isNull(finalPageNameStr) && finalPageNameStr.equals("InvoiceCombinePG")){
        
            String combineReqId = pageContext.getParameter("CombineReqId");
            System.out.println("InvoiceCombineCO: CombineReqId: "+combineReqId);
            
            //testing
            if (InvoiceClientUtil.isNull(combineReqId)) combineReqId = "1";
            
            InvoiceCombineReqVOImpl combineReqVO = am.getInvoiceCombineReqVO1();
            
            
            if (combineReqVO != null){
                combineReqVO.setWhereClause(null);
                combineReqVO.setWhereClauseParams(null);
                
                combineReqVO.setWhereClause(" COMBINE_REQ_ID = :1 ");
                combineReqVO.setWhereClauseParam(0,combineReqId );
                combineReqVO.executeQuery();
                System.out.println("InvoiceCombineCO: InvoiceCombineReqVOImpl " +combineReqVO.getRowCount());
                
                if (combineReqVO.getRowCount() >0){
                    combineReqRow = combineReqVO.first();
                    
                    
                    if (newlyCreatedFlag){
                        combineReqRow.setAttribute("Status","Created");
                    }
                    status = (String)combineReqRow.getAttribute("Status");
                    reqType = (String)combineReqRow.getAttribute("ReqType");
                    
                }
                
                InvoiceCombineReqDtlVOImpl combineReqDtlVO =  am.getInvoiceCombineReqDtlVO1();
                if (combineReqDtlVO != null){
                    System.out.println("InvoiceCombineCO: processRequest.InvoiceCombineReqDtlVOImpl " +combineReqDtlVO.getRowCount());
                }

                
//                pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceCombinePG1&NewlyCreated=Y",
//                                                  null,
//                                                  OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
//                                                  null,                                                   
//                                                  null,
//                                                  true,                            
//                                                  OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
//                                                  OAWebBeanConstants.IGNORE_MESSAGES);
                
            }else{
                throw new OAException("Combine Request is not found", OAException.ERROR);            
            }
//        }else{
//            System.out.println("InvoiceCombineCO: not start from InvoiceCombinePG");
//        }


        SearchInvoiceLovVOImpl  searchInvoiceLovVO = am.getSearchInvoiceLovVO1();

        if (searchInvoiceLovVO != null && combineReqRow != null  ){
            searchInvoiceLovVO.setWhereClause(null);
            searchInvoiceLovVO.setWhereClauseParams(null);
            searchInvoiceLovVO.addWhereClause(" CURRENT_STATUS IN ('Created','Out For Review')");
            searchInvoiceLovVO.addWhereClause(" AND ORG_ID =:1 ");
            searchInvoiceLovVO.setWhereClauseParam(0, pageContext.getProfile("ORG_ID"));
            searchInvoiceLovVO.addWhereClause(" AND CUSTOMER_TRX_ID != :2 ");
            searchInvoiceLovVO.setWhereClauseParam(1,combineReqRow.getAttribute("ParentCustomerTrxId"));
            searchInvoiceLovVO.addWhereClause(" AND TRX_TYPE_NAME = 'TM FINANCIAL INV' ");
            
            
//            searchInvoiceLovVO.executeQuery();
        }



        OASubmitButtonBean saveBN = (OASubmitButtonBean) webBean.findChildRecursive("SaveBN");
        OASubmitButtonBean cancelBN = (OASubmitButtonBean) webBean.findChildRecursive("CancelBN");  
        OASubmitButtonBean submitForApprovalBN = (OASubmitButtonBean) webBean.findChildRecursive("SubmitForApprovalBN");
        OASubmitButtonBean approveBN = (OASubmitButtonBean) webBean.findChildRecursive("ApproveBN");
        OASubmitButtonBean rejectBN = (OASubmitButtonBean) webBean.findChildRecursive("RejectBN");
        OASubmitButtonBean backToSearchBN  = (OASubmitButtonBean) webBean.findChildRecursive("BackToSearchBN");
         

 //buttons
        if (readOnlyFlag){
            if(saveBN != null)saveBN.setRendered(false);
            if(cancelBN != null)cancelBN.setRendered(false);
            if(submitForApprovalBN != null)submitForApprovalBN.setRendered(false);
            if(approveBN != null)approveBN.setRendered(false);          
            if(rejectBN != null)rejectBN.setRendered(false);          
            if(backToSearchBN != null)backToSearchBN.setRendered(true);
        }else{    
            
            if (newlyCreatedFlag){
                if(cancelBN != null)cancelBN.setRendered(true);
            }else{
                if(backToSearchBN != null)backToSearchBN.setRendered(true);
            }
            
            if ("Created".equals(status)){
                if(saveBN != null)saveBN.setRendered(true);
                if (!newlyCreatedFlag){
                    if(submitForApprovalBN != null && isBillerFlag) submitForApprovalBN.setRendered(true);
                    
                }
            }else if ("Pending Approval Combine".equals(status)){
                if(saveBN != null)saveBN.setRendered(true);
                if(approveBN !=null && isManagerFlag) approveBN.setRendered(true);
                if(rejectBN !=null && isManagerFlag) rejectBN.setRendered(true);
            }else if ("Pending Approval Uncombine".equals(status)){
                if(saveBN != null) saveBN.setRendered(true);
                if(approveBN != null && isManagerFlag) approveBN.setRendered(true);
                if(rejectBN !=null && isManagerFlag) rejectBN.setRendered(true);
            }else if ("Approved".equals(status)){
                InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);
            }else if ("Rejected".equals(status)){
                InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);
            }
        }
        
//fields
        if (readOnlyFlag){
          InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);
        }else{
            if ("Uncombine".equals(reqType)){
                
                OAAdvancedTableBean oAAdvancedTableBean = (OAAdvancedTableBean)webBean.findChildRecursive("CombineReqChildInvoiceTH");;
                UINode uINode1 = oAAdvancedTableBean.getTableActions();
                if (uINode1 != null && uINode1 instanceof OAWebBean) {
                  ((OAWebBean)uINode1).setRendered(false);
                } 
                UINode uINode2 = oAAdvancedTableBean.getFooter();
                if (uINode2 != null && uINode2 instanceof OAWebBean) {
                  ((OAWebBean)uINode2).setRendered(false);
                } 
                UINode uINode3 = oAAdvancedTableBean.getTableSelection();
                if (uINode3 != null && uINode3 instanceof OAWebBean) {
                  ((OAWebBean)uINode3).setRendered(false);
                } 
                  
                int i = oAAdvancedTableBean.getIndexedChildCount();
                for (byte b = 0; b < i; b++) {
                    UINode uINode = oAAdvancedTableBean.getIndexedChild(b);
                    if (uINode instanceof OAColumnBean){
                        //System.out.println(uINode.getClass().getName());
                        OAColumnBean col = (OAColumnBean)uINode;
                        int j = col.getIndexedChildCount();
                        for (int c = 0; c < j; c++) {
                            UINode uINodeTemp = col.getIndexedChild(c);
                            //System.out.println(uINodeTemp.getClass().getName());
                            if (uINodeTemp instanceof OAImageBean){
                                OAImageBean imageBean = (OAImageBean)uINodeTemp;
                                if (imageBean.getSource() != null && imageBean.getSource().endsWith("deleteicon_enabled.gif")){
                                    col.setRendered(false);
                                    break;
                                }
                            }
                        }
                    }
                }
                
                OAMessageLovInputBean childTransactionNumFD = (OAMessageLovInputBean)webBean.findChildRecursive("ChildTransactionNumFD");
                childTransactionNumFD.setReadOnly(true);
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
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        
        if (pageContext.getParameter("SaveBN") != null){
            this.save(pageContext, webBean);
            this.refresh(pageContext, webBean);
        }else if (pageContext.getParameter("CancelBN") != null){
            this.unSave(pageContext, webBean);
            this.backToSearchInvoice(pageContext, webBean);
        }else if (pageContext.getParameter("SubmitForApprovalBN") != null){
            this.submitForApproval(pageContext, webBean);
            this.refresh(pageContext, webBean);
        }else if (pageContext.getParameter("ApproveBN") != null){
            this.approve(pageContext, webBean);
            this.refresh(pageContext, webBean);
        }else if (pageContext.getParameter("RejectBN") != null){
            this.reject(pageContext, webBean);
            this.refresh(pageContext, webBean);            
        }else if (pageContext.getParameter("BackToSearchBN") != null){
            this.unSave(pageContext, webBean);
            this.backToSearch(pageContext, webBean);            
        }else if ("addRows".equals(pageContext.getParameter(EVENT_PARAM))){
            if ("CombineReqChildInvoiceTH".equals(pageContext.getParameter(SOURCE_PARAM)) || "CombineReqChildInvoiceAddBN".equals(pageContext.getParameter(SOURCE_PARAM))){
                
                InvoiceCombineReqVOImpl combineReqVO = am.getInvoiceCombineReqVO1();
                InvoiceCombineReqDtlVOImpl combineReqDtlVO =  am.getInvoiceCombineReqDtlVO1();
                
                Row row = combineReqDtlVO.createRow();
                
                oracle.jbo.domain.Number combineReqDtlId = am.getOADBTransaction().getSequenceValue("XXBS_COMBINE_REQ_DTL_S");
                
                row.setAttribute("CombineReqDtlId",combineReqDtlId);
                row.setAttribute("CombineReqId",combineReqVO.getCurrentRow().getAttribute("CombineReqId"));
                
                row.setNewRowState(Row.STATUS_NEW);
                combineReqDtlVO.last();                        
                combineReqDtlVO.next();                        
                combineReqDtlVO.insertRow(row);
            }
        }else if ("DeleteCombineReqChildInvoice".equals(pageContext.getParameter(EVENT_PARAM))){
            String invoiceLineId = pageContext.getParameter("CombineReqDtlId");
        
            String rowRef = pageContext.getParameter(OAWebBeanConstants.EVENT_SOURCE_ROW_REFERENCE);
            OARow row = (OARow)am.findRowByRef(rowRef);
            row.remove();
        
        
        }

    }

    private void refresh(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String combineReqId = am.getInvoiceCombineReqVO1().getCurrentRow().getAttribute("CombineReqId").toString();
        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceCombinePG&CombineReqId="+combineReqId+"&NewlyCreated=N",
                                          null,
                                          OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                          null,                                                   
                                          null,
                                          true,                            
                                          OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
                                          OAWebBeanConstants.IGNORE_MESSAGES);
        
    }


    private void save(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);        
        checkChildInvoice(pageContext, webBean);
        checkDuplicatedInvoice(pageContext, webBean);
        am.getTransaction().commit();   
    }

    private void unSave(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        am.getTransaction().rollback();   
    }
    
    private void backToSearch(OAPageContext pageContext, OAWebBean webBean){
        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/SearchCombineReqPG",
                                          null,
                                          OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                          null,                                                   
                                          null,
                                          false,                            
                                          OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
                                          OAWebBeanConstants.IGNORE_MESSAGES);
       
    
    }
    
    private void checkChildInvoice(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        InvoiceCombineReqVOImpl  combineReqVO = am.getInvoiceCombineReqVO1();
        InvoiceCombineReqDtlVOImpl  combineReqDtlVO = am.getInvoiceCombineReqDtlVO1();
        String reqType = combineReqVO.getCurrentRow().getAttribute("ReqType").toString();
//        if ("Combine".equals(reqType)){
            Row[] combineReqDtlVOList =  combineReqDtlVO.getAllRowsInRange();
            if(combineReqDtlVOList == null || combineReqDtlVOList.length <=0){
                throw new OAException("No Child Invoices", OAException.ERROR);   
            }        
//        }
    }
    
    private void checkDuplicatedInvoice(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        InvoiceCombineReqVOImpl  combineReqVO = am.getInvoiceCombineReqVO1();
        InvoiceCombineReqDtlVOImpl  combineReqDtlVO = am.getInvoiceCombineReqDtlVO1();
        String reqType = combineReqVO.getCurrentRow().getAttribute("ReqType").toString();
        
        if ("Combine".equals(reqType)){
            List<String> custTrxIdList = new ArrayList<String>();
            String parentId = combineReqVO.getCurrentRow().getAttribute("ParentCustomerTrxId").toString();
            if (parentId != null){
                custTrxIdList.add(parentId);
            }
            Row[] combineReqDtlVOList =  combineReqDtlVO.getAllRowsInRange();
            for (int i=0;i<combineReqDtlVOList.length;i++){
                Row combineReqDtlVORec = combineReqDtlVOList[i];          
                String childId = combineReqDtlVORec.getAttribute("ChildCustomerTrxId").toString();
                if (!InvoiceClientUtil.isNull(childId)) custTrxIdList.add(childId);
            }
            Set<String> custTrxIdSet = new HashSet<String>(custTrxIdList);
            if(custTrxIdSet.size() < custTrxIdList.size()){
                throw new OAException("Duplicated Child Invoices", OAException.ERROR);   
            }        
        }
    }
    
    private void backToSearchInvoice(OAPageContext pageContext, OAWebBean webBean){
        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/SearchInvoicePG",
                                          null,
                                          OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                          null,                                                   
                                          null,
                                          false,                            
                                          OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
                                          OAWebBeanConstants.IGNORE_MESSAGES);
       
    }

    
    private void submitForApproval(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String combineReqId = am.getInvoiceCombineReqVO1().getCurrentRow().getAttribute("CombineReqId").toString();
        String approvalReason = am.getInvoiceCombineReqVO1().getCurrentRow().getAttribute("ApprovalReason").toString();
        String justification = am.getInvoiceCombineReqVO1().getCurrentRow().getAttribute("Justification").toString();
        String reqType = am.getInvoiceCombineReqVO1().getCurrentRow().getAttribute("ReqType").toString();
        
        if ("Combine".equals(reqType)){
            am.submitApprovalCombineReq(combineReqId, approvalReason, justification);
            am.getTransaction().commit();             
        }else if ("Uncombine".equals(reqType)){
            am.submitApprovalUncombineReq(combineReqId, approvalReason, justification);
            am.getTransaction().commit(); 
        }
    }
    
    private void approve(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String combineReqId = am.getInvoiceCombineReqVO1().getCurrentRow().getAttribute("CombineReqId").toString();
        String reqType = am.getInvoiceCombineReqVO1().getCurrentRow().getAttribute("ReqType").toString();
        
        if ("Combine".equals(reqType)){
            am.approveCombineReq(combineReqId);
            am.getTransaction().commit();             
        }else if ("Uncombine".equals(reqType)){
            am.approveUncombineReq(combineReqId);
            am.getTransaction().commit(); 
        }

    }
    
    private void reject(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String combineReqId = am.getInvoiceCombineReqVO1().getCurrentRow().getAttribute("CombineReqId").toString();
        String reqType = am.getInvoiceCombineReqVO1().getCurrentRow().getAttribute("ReqType").toString();
        
        if ("Combine".equals(reqType)){
            am.rejectCombineReq(combineReqId);
            am.getTransaction().commit();             
        }else if ("Uncombine".equals(reqType)){
            am.rejectUncombineReq(combineReqId);
            am.getTransaction().commit(); 
        }
        
    }    
}
