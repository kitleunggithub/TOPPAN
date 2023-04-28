/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package toppanmerrill.oracle.apps.xxtm.cb.invoice.webui;

import java.lang.Object;

import java.math.BigDecimal;

import java.sql.SQLException;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import java.util.Set;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OARow;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAImageBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.apps.fnd.framework.webui.beans.form.OASubmitButtonBean;
import oracle.apps.fnd.framework.webui.beans.layout.OASubTabLayoutBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageCheckBoxBean;

import oracle.apps.fnd.framework.webui.beans.message.OAMessageChoiceBean;

import oracle.apps.fnd.framework.webui.beans.message.OAMessageLovInputBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageTextInputBean;

import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;
import oracle.apps.fnd.framework.webui.beans.table.OAColumnBean;

import oracle.cabo.ui.UINode;

import oracle.jbo.Row;

import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.GLPeriodNameLovVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceApprovalActivityVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceChangeActivityVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceAuditVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceCombineReqDtlVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceCombineReqVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceEOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceLineVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceSalesRepSplitsVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.PrimaryProductTypeLovVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceAMImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceVOImpl;

/**
 * Controller for ...
 */
public class InvoiceDetailCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header$";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

  public static final String  STATUS_CREATED = "Created";
  public static final String  STATUS_OUT_FOR_REVIEW = "Out For Review";
  public static final String  STATUS_INVOICED = "Invoiced";
  public static final String  STATUS_CREATED_RI = "Created RI";
  public static final String  STATUS_PENDING_APPROVAL_CM_RI = "Pending Approval CM & RI";
  public static final String  STATUS_PENDING_APPROVAL_COMBINE = "Pending Approval Combine";
  public static final String  STATUS_PENDING_APPROVAL_UNCOMBINE = "Pending Approval Uncombine";
  public static final String  STATUS_PENDING_APPROVAL_VOID = "Pending Approval Void";
  public static final String  STATUS_PENDING_CM = "Pending CM";    
  public static final String  STATUS_PENDING_MGR_REVIEW = "Pending Manager Review";    
  public static final String  STATUS_PENDING_INVOICED = "Pending Invoiced";    
  public static final String  STATUS_VOID = "Void";
    
    
  /**
   * Layout and page setup logic for a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    
    super.processRequest(pageContext, webBean);
    
    OAMessageChoiceBean invoiceStyleBN = (OAMessageChoiceBean)webBean.findChildRecursive("InvoiceStyleFD");  
    invoiceStyleBN.setPickListCacheEnabled(false);      
    
    Row invoiceRow = null;
    //pageContext.activateWarnAboutChanges();
      
    SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
      
    
    String readOnly = pageContext.getParameter("ReadOnly") ;
    String newlyCreated = pageContext.getParameter("NewlyCreated");
    String customerTrxId = pageContext.getParameter("CustomerTrxId");
    String customerTrxTypeType = null;
    String currentStatus = null;
    String invoiceClass = null;
    Object revisedCustomerTrxId = null;
    
    if (!InvoiceClientUtil.isNull(readOnly)){
        pageContext.putSessionValue("InvoiceDetailReadOnly",readOnly);
    }else{
        readOnly = (String)pageContext.getSessionValue("InvoiceDetailReadOnly");
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
    System.out.println("InvoiceDetailCO: CustomerTrxId: "+customerTrxId);
    
    //for testing 
    if (InvoiceClientUtil.isNull(customerTrxId)) customerTrxId = "1001";
    
    if (!InvoiceClientUtil.isNull(customerTrxId)){
          
        InvoiceVOImpl invoiceVo = am.getInvoiceVO1();
        if (invoiceVo != null){
            invoiceVo.setWhereClause(null);
            invoiceVo.setWhereClauseParams(null);
            
            invoiceVo.setWhereClause(" CUSTOMER_TRX_ID = :1 ");
            invoiceVo.setWhereClauseParam(0,customerTrxId );
            invoiceVo.executeQuery();
            System.out.println("InvoiceDetailCO: InvoiceVOImpl " +invoiceVo.getRowCount());
            
            if (invoiceVo.getRowCount() >0){
                invoiceRow = invoiceVo.first();
            }
            
            currentStatus = (String)invoiceRow.getAttribute("CurrentStatus");
            customerTrxTypeType = (String)invoiceRow.getAttribute("CustTrxTypeType");
            invoiceClass =  (String)invoiceRow.getAttribute("InvoiceClass");
            revisedCustomerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("RevisedCustomerTrxId");
            System.out.println("InvoiceDetailCO: InvoiceVOImpl " +currentStatus);
            
            if (newlyCreatedFlag){
                invoiceRow.setAttribute("CurrentStatus","Created");
            }
        }          

        InvoiceSalesRepSplitsVOImpl invoiceSalesRepVo = am.getInvoiceSalesRepSplitsVO1();          
        if (invoiceSalesRepVo != null){
            System.out.println("InvoiceDetailCO: processRequest.InvoiceSalesRepSplitsVOImpl " +invoiceSalesRepVo.getRowCount());
        }

        
        InvoiceLineVOImpl invoiceLineVo = am.getInvoiceLineVO1();
        if (invoiceLineVo != null){
            System.out.println("InvoiceDetailCO: processRequest.InvoiceLineVOImpl " +invoiceLineVo.getRowCount());
        }


        InvoiceChangeActivityVOImpl invoiceChangeActivityVo = am.getInvoiceChangeActivityVO1();
        if (invoiceChangeActivityVo != null){
            System.out.println("InvoiceDetailCO: processRequest.invoiceChangeActivityVo " +invoiceChangeActivityVo.getRowCount());
        }
        
        InvoiceApprovalActivityVOImpl invoiceApprovalActivityVo = am.getInvoiceApprovalActivityVO1();
        if (invoiceApprovalActivityVo != null){
            System.out.println("InvoiceDetailCO: processRequest.invoiceApprovalActivityVo " +invoiceApprovalActivityVo.getRowCount());
        }
        
        InvoiceAuditVOImpl invoicAuditVo = am.getInvoiceAuditVO1();
        if (invoicAuditVo != null){
            System.out.println("InvoiceDetailCO: processRequest.InvoiceAuditVOImpl " +invoicAuditVo.getRowCount());
        }
        
        
        PrimaryProductTypeLovVOImpl primaryProductTypeLovVo = am.getPrimaryProductTypeLovVO1();
        if (primaryProductTypeLovVo != null && invoiceRow != null  ){
            primaryProductTypeLovVo.setWhereClause(null);
            primaryProductTypeLovVo.setWhereClauseParams(null);
            primaryProductTypeLovVo.addWhereClause(" ORG_ID =:1 ");
            primaryProductTypeLovVo.setWhereClauseParam(0, invoiceRow.getAttribute("OrgId").toString());
            primaryProductTypeLovVo.executeQuery();
        }
        
//        GLPeriodNameLovVOImpl glPeriodNameLovVO = am.getGLPeriodNameLovVO1();
//        if (glPeriodNameLovVO != null && invoiceRow != null  ){
//            glPeriodNameLovVO.setWhereClause(null);
//            glPeriodNameLovVO.setWhereClauseParams(null);
//            glPeriodNameLovVO.addWhereClause(" SET_OF_BOOKS_ID =:1 ");
//            glPeriodNameLovVO.setWhereClauseParam(0, invoiceRow.getAttribute("SetOfBooksId").toString());
//            glPeriodNameLovVO.executeQuery();
//        }
          
          
        OAMessageCheckBoxBean invoiceDisplayLevel1FD = (OAMessageCheckBoxBean) webBean.findChildRecursive("InvoiceDisplayLevel1FD");
        OAMessageCheckBoxBean InvoiceDisplayLevel2FD = (OAMessageCheckBoxBean) webBean.findChildRecursive("InvoiceDisplayLevel2FD");
        OAMessageCheckBoxBean invoiceDisplayLevel3FD = (OAMessageCheckBoxBean) webBean.findChildRecursive("InvoiceDisplayLevel3FD");
        OAMessageCheckBoxBean invoicePreliminaryFD = (OAMessageCheckBoxBean) webBean.findChildRecursive("InvoicePreliminaryFD");
        OAMessageCheckBoxBean invoiceDisplaySalespersonFD = (OAMessageCheckBoxBean) webBean.findChildRecursive("InvoiceDisplaySalespersonFD");
        OAMessageCheckBoxBean invoiceDisplayLevel1TotalFD = (OAMessageCheckBoxBean) webBean.findChildRecursive("InvoiceDisplayLevel1TotalFD");
        OAMessageCheckBoxBean invoiceDisplayLevel2TotalFD = (OAMessageCheckBoxBean) webBean.findChildRecursive("InvoiceDisplayLevel2TotalFD");
        OAMessageCheckBoxBean invoiceDisplayLevel3TotalFD = (OAMessageCheckBoxBean) webBean.findChildRecursive("InvoiceDisplayLevel3TotalFD");
        
        if (invoiceDisplayLevel1FD != null) invoiceDisplayLevel1FD.setLabel("Display Level 1");
        if (InvoiceDisplayLevel2FD != null) InvoiceDisplayLevel2FD.setLabel("Display Level 2");
        if (invoiceDisplayLevel3FD != null) invoiceDisplayLevel3FD.setLabel("Display Level 3");
        if (invoicePreliminaryFD != null) invoicePreliminaryFD.setLabel("Preliminary");
        if (invoiceDisplaySalespersonFD != null) invoiceDisplaySalespersonFD.setLabel("Display Salesperson");
        if (invoiceDisplayLevel1TotalFD != null) invoiceDisplayLevel1TotalFD.setLabel("Display Level 1 Total");
        if (invoiceDisplayLevel2TotalFD != null) invoiceDisplayLevel2TotalFD.setLabel("Display Level 2 Total");
        if (invoiceDisplayLevel3TotalFD != null) invoiceDisplayLevel3TotalFD.setLabel("Display Level 3 Total");
         
    }     
    

    OASubmitButtonBean saveBN = (OASubmitButtonBean) webBean.findChildRecursive("SaveBN");
    OASubmitButtonBean submitToReviewBN = (OASubmitButtonBean) webBean.findChildRecursive("SubmitToReviewBN");  
    OASubmitButtonBean submitToMgrReviewBN = (OASubmitButtonBean) webBean.findChildRecursive("SubmitToMgrReviewBN");  
    OASubmitButtonBean submitToARBN = (OASubmitButtonBean) webBean.findChildRecursive("SubmitToARBN");
    OASubmitButtonBean reviseBN = (OASubmitButtonBean) webBean.findChildRecursive("ReviseBN");
    OASubmitButtonBean voidBN = (OASubmitButtonBean) webBean.findChildRecursive("VoidBN");
    OASubmitButtonBean approveBN = (OASubmitButtonBean) webBean.findChildRecursive("ApproveBN");
    OASubmitButtonBean rejectBN = (OASubmitButtonBean) webBean.findChildRecursive("RejectBN");
    OASubmitButtonBean auditBN = (OASubmitButtonBean) webBean.findChildRecursive("AuditBN");
    OASubmitButtonBean printBN = (OASubmitButtonBean) webBean.findChildRecursive("PrintBN");
    OASubmitButtonBean backToSearchBN = (OASubmitButtonBean) webBean.findChildRecursive("BackToSearchBN");
//    System.out.println("saveBN.getName() "+saveBN.getName());
//    System.out.println("saveBN.getID() "+saveBN.getID());
    
    //buttons
    if (readOnlyFlag){
        if (saveBN != null)saveBN.setRendered(false);
        if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
        if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
        if (submitToARBN != null)submitToARBN.setRendered(false);
        if (reviseBN != null)reviseBN.setRendered(false);
        if (voidBN != null)voidBN.setRendered(false);
        if (approveBN != null)approveBN.setRendered(false);
        if (rejectBN != null)rejectBN.setRendered(false);
        if (auditBN != null)auditBN.setRendered(false);
        if (printBN != null)printBN.setRendered(true);
        if (backToSearchBN != null)backToSearchBN.setRendered(true);
    }else{
        if (newlyCreatedFlag){
            if (saveBN != null)saveBN.setRendered(true);
            if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
            if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
            if (submitToARBN != null)submitToARBN.setRendered(false);            
            if (reviseBN != null)reviseBN.setRendered(false);
            if (voidBN != null)voidBN.setRendered(false);
            if (approveBN != null)approveBN.setRendered(false);
            if (rejectBN != null)rejectBN.setRendered(false);            
            if (auditBN != null)auditBN.setRendered(false);
            if (printBN != null)printBN.setRendered(false);
            if (backToSearchBN != null)backToSearchBN.setRendered(true);
            
        }else{
            
            if (currentStatus != null){
                if (STATUS_CREATED.equals(currentStatus)){
                    if (saveBN != null)saveBN.setRendered(true);
                    if (submitToReviewBN != null & isBillerFlag)submitToReviewBN.setRendered(true);
                    if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                    if (submitToARBN != null )submitToARBN.setRendered(false);
                    if (reviseBN != null)reviseBN.setRendered(false);
                    if (voidBN != null & isBillerFlag)voidBN.setRendered(true);
                    if (approveBN != null)approveBN.setRendered(false);
                    if (rejectBN != null)rejectBN.setRendered(false);                    
                    if (auditBN != null)auditBN.setRendered(true);
                    if (printBN != null)printBN.setRendered(true);
                    if (backToSearchBN != null)backToSearchBN.setRendered(true);                
                }else if (STATUS_CREATED_RI.equals(currentStatus)){
                    if (saveBN != null)saveBN.setRendered(true);
                    if (submitToReviewBN != null & isBillerFlag)submitToReviewBN.setRendered(true);
                    if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                    if (submitToARBN != null )submitToARBN.setRendered(false);
                    if (reviseBN != null)reviseBN.setRendered(false);
                    if (voidBN != null & isBillerFlag)voidBN.setRendered(true);
                    if (approveBN != null)approveBN.setRendered(false);
                    if (rejectBN != null)rejectBN.setRendered(false);                    
                    if (auditBN != null)auditBN.setRendered(true);
                    if (printBN != null)printBN.setRendered(true);
                    if (backToSearchBN != null)backToSearchBN.setRendered(true);                                 
                }else if (STATUS_OUT_FOR_REVIEW.equals(currentStatus)){                
                    if (revisedCustomerTrxId == null){
                        if (saveBN != null)saveBN.setRendered(true);
                        if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                        if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                        if (submitToARBN != null & isBillerFlag)submitToARBN.setRendered(true);
                        if (reviseBN != null)reviseBN.setRendered(false);
                        if (voidBN != null)voidBN.setRendered(true);                    
                        if (approveBN != null)approveBN.setRendered(false);
                        if (rejectBN != null)rejectBN.setRendered(false);                    
                        if (auditBN != null)auditBN.setRendered(true);
                        if (printBN != null)printBN.setRendered(true);
                        if (backToSearchBN != null)backToSearchBN.setRendered(true);
                    }else if (revisedCustomerTrxId != null && !InvoiceClientUtil.isNull(revisedCustomerTrxId.toString()) ){
                        if (saveBN != null)saveBN.setRendered(true);
                        if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                        if (submitToMgrReviewBN != null & isBillerFlag)submitToMgrReviewBN.setRendered(true);
                        if (submitToARBN != null)submitToARBN.setRendered(false);
                        if (reviseBN != null)reviseBN.setRendered(false);
                        if (voidBN != null)voidBN.setRendered(false);                    
                        if (approveBN != null)approveBN.setRendered(false);
                        if (rejectBN != null)rejectBN.setRendered(false);                    
                        if (auditBN != null)auditBN.setRendered(true);
                        if (printBN != null)printBN.setRendered(true);
                        if (backToSearchBN != null)backToSearchBN.setRendered(true);                    
                    }
                }else if (STATUS_PENDING_MGR_REVIEW.equals(currentStatus)){
                     if (revisedCustomerTrxId == null){
                         if (saveBN != null)saveBN.setRendered(false);
                         if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                         if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                         if (submitToARBN != null)submitToARBN.setRendered(false);
                         if (reviseBN != null)reviseBN.setRendered(false);
                         if (voidBN != null)voidBN.setRendered(false);                    
                         if (approveBN != null)approveBN.setRendered(false);
                         if (rejectBN != null)rejectBN.setRendered(false);                    
                         if (auditBN != null)auditBN.setRendered(false);
                         if (printBN != null)printBN.setRendered(false);
                         if (backToSearchBN != null)backToSearchBN.setRendered(false);
                     }else if (revisedCustomerTrxId != null && !InvoiceClientUtil.isNull(revisedCustomerTrxId.toString()) ){
                         if (saveBN != null)saveBN.setRendered(true);
                         if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                         if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                         if (submitToARBN != null & isManagerFlag)submitToARBN.setRendered(true);
                         if (reviseBN != null)reviseBN.setRendered(false);
                         if (voidBN != null)voidBN.setRendered(false);                    
                         if (approveBN != null)approveBN.setRendered(false);
                         if (rejectBN != null)rejectBN.setRendered(false);                    
                         if (auditBN != null)auditBN.setRendered(true);
                         if (printBN != null)printBN.setRendered(true);
                         if (backToSearchBN != null)backToSearchBN.setRendered(true);                    
                     }                                
                }else if (STATUS_INVOICED.equals(currentStatus)){    
                
                    if (customerTrxTypeType.equals("CM")){
                        if (saveBN != null)saveBN.setRendered(false);
                        if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                        if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                        if (submitToARBN != null)submitToARBN.setRendered(false);
                        if (reviseBN != null )reviseBN.setRendered(false);
                        if (voidBN != null)voidBN.setRendered(false);                    
                        if (approveBN != null)approveBN.setRendered(false);
                        if (rejectBN != null)rejectBN.setRendered(false);                    
                        if (auditBN != null)auditBN.setRendered(false);
                        if (printBN != null)printBN.setRendered(true);
                        if (backToSearchBN != null)backToSearchBN.setRendered(true);                        
                    }else if (customerTrxTypeType.equals("INV")){
                        if (saveBN != null)saveBN.setRendered(true);
                        if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                        if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                        if (submitToARBN != null)submitToARBN.setRendered(false);
                        if (reviseBN != null  & isBillerFlag )reviseBN.setRendered(true);
                        if (voidBN != null)voidBN.setRendered(false);                    
                        if (approveBN != null)approveBN.setRendered(false);
                        if (rejectBN != null)rejectBN.setRendered(false);                    
                        if (auditBN != null)auditBN.setRendered(true);
                        if (printBN != null)printBN.setRendered(true);
                        if (backToSearchBN != null)backToSearchBN.setRendered(true);
                    }
                }else if (STATUS_VOID.equals(currentStatus)){
                    if (saveBN != null)saveBN.setRendered(false);
                    if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                    if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                    if (submitToARBN != null)submitToARBN.setRendered(false);
                    if (reviseBN != null)reviseBN.setRendered(false);
                    if (voidBN != null)voidBN.setRendered(false);                                        
                    if (approveBN != null)approveBN.setRendered(false);
                    if (rejectBN != null)rejectBN.setRendered(false);                    
                    if (auditBN != null)auditBN.setRendered(false);
                    if (printBN != null)printBN.setRendered(true);
                    if (backToSearchBN != null)backToSearchBN.setRendered(true);
                
                }else if (STATUS_PENDING_APPROVAL_CM_RI.equals(currentStatus)){
                    if (saveBN != null)saveBN.setRendered(false);
                    if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                    if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                    if (submitToARBN != null)submitToARBN.setRendered(false);
                    if (reviseBN != null)reviseBN.setRendered(false);
                    if (voidBN != null)voidBN.setRendered(false);                         
                    if (approveBN != null  & isManagerFlag)approveBN.setRendered(true);
                    if (rejectBN != null & isManagerFlag)rejectBN.setRendered(true);
                    if (auditBN != null)auditBN.setRendered(false);
                    if (printBN != null)printBN.setRendered(true);
                    if (backToSearchBN != null)backToSearchBN.setRendered(true);
                    
                }else if (STATUS_PENDING_APPROVAL_COMBINE.equals(currentStatus)){
                    if (saveBN != null)saveBN.setRendered(false);
                    if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                    if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                    if (submitToARBN != null)submitToARBN.setRendered(false);
                    if (reviseBN != null)reviseBN.setRendered(false);
                    if (voidBN != null)voidBN.setRendered(false);                         
                    if (approveBN != null)approveBN.setRendered(false);
                    if (rejectBN != null)rejectBN.setRendered(false);
                    if (auditBN != null)auditBN.setRendered(false);
                    if (printBN != null)printBN.setRendered(true);
                    if (backToSearchBN != null)backToSearchBN.setRendered(true);
                    
                }else if (STATUS_PENDING_APPROVAL_UNCOMBINE.equals(currentStatus)){
                    if (saveBN != null)saveBN.setRendered(false);
                    if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                    if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                    if (submitToARBN != null)submitToARBN.setRendered(false);
                    if (reviseBN != null)reviseBN.setRendered(false);
                    if (voidBN != null)voidBN.setRendered(false);                         
                    if (approveBN != null)approveBN.setRendered(false);
                    if (rejectBN != null)rejectBN.setRendered(false);
                    if (auditBN != null)auditBN.setRendered(false);
                    if (printBN != null)printBN.setRendered(true);
                    if (backToSearchBN != null)backToSearchBN.setRendered(true);
                    
                }else if (STATUS_PENDING_APPROVAL_VOID.equals(currentStatus)){
                    if (saveBN != null)saveBN.setRendered(false);
                    if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                    if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                    if (submitToARBN != null)submitToARBN.setRendered(false);
                    if (reviseBN != null)reviseBN.setRendered(false);
                    if (voidBN != null)voidBN.setRendered(false);                         
                    if (approveBN != null && isManagerFlag )approveBN.setRendered(true);
                    if (rejectBN != null  && isManagerFlag )rejectBN.setRendered(true);
                    if (auditBN != null)auditBN.setRendered(false);
                    if (printBN != null)printBN.setRendered(true);
                    if (backToSearchBN != null)backToSearchBN.setRendered(true);
                    
                }else if (STATUS_PENDING_CM.equals(currentStatus)){
                    if (saveBN != null)saveBN.setRendered(false);
                    if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                    if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                    if (submitToARBN != null)submitToARBN.setRendered(false);
                    if (reviseBN != null)reviseBN.setRendered(false);
                    if (voidBN != null)voidBN.setRendered(false);                         
                    if (approveBN != null && isManagerFlag )approveBN.setRendered(false);
                    if (rejectBN != null && isManagerFlag )rejectBN.setRendered(false);
                    if (auditBN != null)auditBN.setRendered(false);
                    if (printBN != null)printBN.setRendered(true);
                    if (backToSearchBN != null)backToSearchBN.setRendered(true);
                    
                }else if (STATUS_PENDING_INVOICED.equals(currentStatus)){
                    if (saveBN != null)saveBN.setRendered(false);
                    if (submitToReviewBN != null)submitToReviewBN.setRendered(false);
                    if (submitToMgrReviewBN != null)submitToMgrReviewBN.setRendered(false);
                    if (submitToARBN != null)submitToARBN.setRendered(false);
                    if (reviseBN != null)reviseBN.setRendered(false);
                    if (voidBN != null)voidBN.setRendered(false);                         
                    if (approveBN != null && isManagerFlag )approveBN.setRendered(false);
                    if (rejectBN != null && isManagerFlag )rejectBN.setRendered(false);
                    if (auditBN != null)auditBN.setRendered(false);
                    if (printBN != null)printBN.setRendered(true);
                    if (backToSearchBN != null)backToSearchBN.setRendered(true);
                    
                 }       
            }
        }
    }
    
    //fields
    if (readOnlyFlag){
      InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);
    }else if (STATUS_INVOICED.equals(currentStatus) ){
        if (customerTrxTypeType.equals("INV")){
            if (isBillerFlag){
                System.out.println("InvoiceDetailCO:  isBillerFlag " +isBillerFlag);
                List<String> exceptionList = new ArrayList<String>();
                exceptionList.add(new String("ActiveBillerFD"));
                exceptionList.add(new String("BillerRemarkFD"));
                exceptionList.add(new String("BillerRemark2FD"));
                InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean, exceptionList);    
                /*
                OAMessageChoiceBean activeBillerFD = (OAMessageChoiceBean) webBean.findChildRecursive("ActiveBillerFD");
                
                activeBillerFD.setReadOnly(false);
                OAMessageTextInputBean billerRemarkFD = (OAMessageTextInputBean) webBean.findChildRecursive("BillerRemarkFD");
                billerRemarkFD.setReadOnly(false);
                */
            }else if (isManagerFlag){
                System.out.println("InvoiceDetailCO:  isManagerFlag " +isManagerFlag);
                List<String> exceptionList = new ArrayList<String>();
                exceptionList.add("InvoiceSalesRepTE");
                InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean, exceptionList);    
            
                /*
                OAAdvancedTableBean invoiceSalesRepTE = (OAAdvancedTableBean)webBean.findChildRecursive("InvoiceSalesRepTE");;
                UINode uINode1 = invoiceSalesRepTE.getTableActions();
                if (uINode1 != null && uINode1 instanceof OAWebBean) {
                  ((OAWebBean)uINode1).setRendered(true);
                } 
                UINode uINode2 = invoiceSalesRepTE.getFooter();
                if (uINode2 != null && uINode2 instanceof OAWebBean) {
                  ((OAWebBean)uINode2).setRendered(true);
                } 
                 UINode uINode3 = oAAdvancedTableBean.getTableSelection();
                 if (uINode3 != null && uINode3 instanceof OAWebBean) {
                   ((OAWebBean)uINode3).setRendered(false);
                 } 
                  
                int i = invoiceSalesRepTE.getIndexedChildCount();
                for (byte b = 0; b < i; b++) {
                    UINode uINode = oAAdvancedTableBean.getIndexedChild(b);
                    if (uINode instanceof OAColumnBean){
                        System.out.println(uINode.getClass().getName());
                        OAColumnBean col = (OAColumnBean)uINode;
                        int j = col.getIndexedChildCount();
                        for (int c = 0; c < j; c++) {
                            UINode uINodeTemp = col.getIndexedChild(c);
                            System.out.println(uINodeTemp.getClass().getName());
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
                */
            
            }else{
                InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);    
            }
        }else{
            InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);    
        }
    
    }else if (STATUS_VOID.equals(currentStatus) ){
        InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);
    }else if (STATUS_PENDING_APPROVAL_VOID.equals(currentStatus) ){
        InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);
    }else if (STATUS_PENDING_APPROVAL_COMBINE.equals(currentStatus) ){
        InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);
    }else if (STATUS_PENDING_APPROVAL_UNCOMBINE.equals(currentStatus) ){
        InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);
    }else if (STATUS_PENDING_APPROVAL_CM_RI.equals(currentStatus) ){
        InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);
    }else if (STATUS_PENDING_CM.equals(currentStatus)){
        InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);
    }else if (STATUS_PENDING_INVOICED.equals(currentStatus)){
        InvoiceClientUtil.setViewOnlyRecursive(pageContext, webBean);
    }
    
    if ("P".equals(invoiceClass)){
        OAMessageLovInputBean billToCustomerNumberFD = (OAMessageLovInputBean) webBean.findChildRecursive("BillToCustomerNumberFD");
        if (billToCustomerNumberFD != null) billToCustomerNumberFD.setReadOnly(true);
        
        OAMessageTextInputBean billToCustomerNameFD = (OAMessageTextInputBean) webBean.findChildRecursive("BillToCustomerNameFD");
        if (billToCustomerNameFD != null) billToCustomerNameFD.setReadOnly(true);
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
        InvoiceVOImpl invoiceVo = am.getInvoiceVO1();            
        InvoiceLineVOImpl invoiceLineVO = am.getInvoiceLineVO1();        
        InvoiceSalesRepSplitsVOImpl invoiceSalesRepSplitsVO =  am.getInvoiceSalesRepSplitsVO1();          
        
        if (invoiceSalesRepSplitsVO != null){
          System.out.println("InvoiceDetailCO: processFormRequest.InvoiceSalesRepSplitsVOImpl " +invoiceSalesRepSplitsVO.getRowCount());
        }

        if (invoiceLineVO != null){
          System.out.println("InvoiceDetailCO: processFormRequest.InvoiceLineVOImpl " +invoiceLineVO.getRowCount());
        }
      
        if (pageContext.getParameter("SaveBN") != null){
            save(pageContext, webBean);
            refresh(pageContext, webBean);
            
        }else if (pageContext.getParameter("SubmitToReviewBN") != null){
            submitToReview(pageContext, webBean);
            refresh(pageContext, webBean);
            
        }else if (pageContext.getParameter("SubmitToMgrReviewBN") != null){
            submitToMgrReview(pageContext, webBean);
            refresh(pageContext, webBean);

        }else if (pageContext.getParameter("SubmitToARBN") != null){
            submitToAR(pageContext, webBean);
            refresh(pageContext, webBean);
            
        }else if (pageContext.getParameter("VoidBN") != null){
            performVoid(pageContext, webBean);     
            
        }else if (pageContext.getParameter("ReviseBN") != null){
            performRevise(pageContext, webBean);

        }else if (pageContext.getParameter("ApproveBN") != null){
            performApprove(pageContext, webBean);     
            refresh(pageContext, webBean);           
        }else if (pageContext.getParameter("RejectBN") != null){                
            performReject(pageContext, webBean);           
            refresh(pageContext, webBean);           
        }else if (pageContext.getParameter("AuditBN") != null){
            performAudit(pageContext, webBean);     
            
            String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
            pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceDetailPG&"+OASubTabLayoutBean.OA_SELECTED_SUBTAB_IDX+"=4&CustomerTrxId="+customerTrxId,
                                              null,
                                              OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                              null,                                                   
                                              null,
                                              true,                            
                                              OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
                                              OAWebBeanConstants.IGNORE_MESSAGES);
            
        }else if (pageContext.getParameter("PrintBN") != null){
            this.performPrint(pageContext, webBean);     
            refresh(pageContext, webBean);           
            
        }else if (pageContext.getParameter("BackToSearchBN") != null){
            this.unSave(pageContext, webBean);
            this.backToSearch(pageContext, webBean);

        }else if ("addRows".equals(pageContext.getParameter(EVENT_PARAM))){
            if ("InvoiceLineTE".equals(pageContext.getParameter(SOURCE_PARAM)) || "InvoiceLineAddBN".equals(pageContext.getParameter(SOURCE_PARAM))){
                this.addInvoiceLineRow(pageContext, webBean);
            }else if ("InvoiceSalesRepTE".equals(pageContext.getParameter(SOURCE_PARAM)) || "InvoiceSalesRepAddBN".equals(pageContext.getParameter(SOURCE_PARAM))){
                this.addInvoiceSalesRepRow(pageContext, webBean);
            }
        }else if ("resetRows".equals(pageContext.getParameter(EVENT_PARAM))){            
            if ("InvoiceSalesRepTE".equals(pageContext.getParameter(SOURCE_PARAM)) || "InvoiceSalesRepResetBN".equals(pageContext.getParameter(SOURCE_PARAM))){        
                this.resetInvoiceSalesRepRow(pageContext, webBean);
                this.refresh(pageContext, webBean);
            }
        }else if ("DeleteInvoiceLine".equals(pageContext.getParameter(EVENT_PARAM))){
            String invoiceLineId = pageContext.getParameter("InvoiceLineId");
        
            String rowRef = pageContext.getParameter(OAWebBeanConstants.EVENT_SOURCE_ROW_REFERENCE);
            OARow row = (OARow)am.findRowByRef(rowRef);
            row.remove();
            
        }else if ("DeleteInvoiceSalesRepSplits".equals(pageContext.getParameter(EVENT_PARAM))){
            String invoiceSalesRepSplitsId = pageContext.getParameter("InvoiceSalesRepSplitsId");
            
            String rowRef = pageContext.getParameter(OAWebBeanConstants.EVENT_SOURCE_ROW_REFERENCE);
            OARow row = (OARow)am.findRowByRef(rowRef);
            row.remove();

            
        }else{
            //refresh(pageContext, webBean);
        }
    }

    private void refresh(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceDetailPG&CustomerTrxId="+customerTrxId+"&NewlyCreated=N",
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
        checkSalesRep(pageContext, webBean);
        calculateLineAmt(pageContext, webBean);        
        am.getTransaction().commit();   
    }

    private void unSave(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        am.getTransaction().rollback();   
    }
    
    private void submitToReview(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
        am.submitToReview(customerTrxId);
        am.getTransaction().commit(); 
        
    }

    private void submitToMgrReview(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
        am.submitToMgrReview(customerTrxId);
        am.getTransaction().commit();
        
        am.triggerMgrReviewWF(customerTrxId);
        am.getTransaction().commit();
        
    }


    private void submitToAR(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
        checkSubmitToAR(pageContext, webBean);
        am.checkTrxGLPeriod(customerTrxId);
        am.checkPaymentTerm(customerTrxId);
        am.submitToAR(customerTrxId);
        am.getTransaction().commit(); 
    }
    
    private void performVoid(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
        
        
        String status = am.getInvoiceVO1().getCurrentRow().getAttribute("CurrentStatus").toString();
        String custTrxTypeType = am.getInvoiceVO1().getCurrentRow().getAttribute("CustTrxTypeType").toString();
        Object revisedCustomerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("RevisedCustomerTrxId");

        
        if (STATUS_INVOICED.equals(status) 
            || STATUS_PENDING_APPROVAL_CM_RI.equals(status)
            || STATUS_PENDING_APPROVAL_COMBINE.equals(status)  
            || STATUS_PENDING_APPROVAL_UNCOMBINE.equals(status)  
            || STATUS_PENDING_APPROVAL_VOID.equals(status) 
            || STATUS_PENDING_CM.equals(status) 
            || STATUS_PENDING_INVOICED.equals(status) 
            || STATUS_VOID.equals(status) )            
            {
            throw new OAException("Invalid Invoice Status", OAException.ERROR);   
        }
        if ("CM".equals(custTrxTypeType)){
            throw new OAException("Credit Memo is not allowed", OAException.ERROR);   
        }                                        
        if (revisedCustomerTrxId != null && !InvoiceClientUtil.isNull(revisedCustomerTrxId.toString()) ){
            throw new OAException("Rebill Invoice is not allowed", OAException.ERROR);   
        }                                        

        
        StringBuffer customerTrxIdStrList = new StringBuffer(customerTrxId);
        customerTrxIdStrList.append("|");
        
        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceVoidPG&CustomerTrxId="+customerTrxIdStrList.toString(),
                                              null,
                                              OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                              null,                                                   
                                              null,
                                              true,                            
                                              OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
                                              OAWebBeanConstants.IGNORE_MESSAGES);
        
    }    

    private void performRevise(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
        
        String status = am.getInvoiceVO1().getCurrentRow().getAttribute("CurrentStatus").toString();
        String custTrxTypeType = am.getInvoiceVO1().getCurrentRow().getAttribute("CustTrxTypeType").toString();

        if (!STATUS_INVOICED.equals(status)){
            throw new OAException("Invalid Invoice Status", OAException.ERROR);   
        }
        
        if ("CM".equals(custTrxTypeType)){
            throw new OAException("Credit Memo is not allowed", OAException.ERROR);   
        }                                        
        
        am.checkTrxForRevise(customerTrxId);                
        
        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceRevisePG&CustomerTrxId="+customerTrxId.toString(),
                                              null,
                                              OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                              null,                                                   
                                              null,
                                              true,                            
                                              OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
                                              OAWebBeanConstants.IGNORE_MESSAGES);
        
    }    
    
    private void performApprove(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
        String currentStatus = am.getInvoiceVO1().getCurrentRow().getAttribute("CurrentStatus").toString();
        if (STATUS_PENDING_APPROVAL_VOID.equals(currentStatus)){
            am.approveVoid(customerTrxId);
        }else if(STATUS_PENDING_APPROVAL_CM_RI.equals(currentStatus)){
            am.approveRevise(customerTrxId);
        }
        am.getTransaction().commit(); 
    }    

    private void performReject(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
        String currentStatus = am.getInvoiceVO1().getCurrentRow().getAttribute("CurrentStatus").toString();
        if (STATUS_PENDING_APPROVAL_VOID.equals(currentStatus)){
            am.rejectVoid(customerTrxId);
        }else if(STATUS_PENDING_APPROVAL_CM_RI.equals(currentStatus)){
            am.rejectRevise(customerTrxId);
        }
        am.getTransaction().commit(); 
    }    

    
    private void performAudit(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
        am.performAudit(customerTrxId);
        am.getTransaction().commit(); 
    }

    private void performPrint(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        try{
        
            String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
            am.performPrint(customerTrxId);
        }catch(Exception e){
            e.printStackTrace();
            throw new OAException(e.getMessage(), OAException.ERROR);       
        }finally{
            am.getTransaction().commit(); 
        }
        throw new OAException("Concurrent Request(s) Submitted",OAException.INFORMATION);
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
    
    private void calculateLineAmt(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        InvoiceVOImpl invoiceVo = am.getInvoiceVO1();
        InvoiceLineVOImpl invoiceLineVo = am.getInvoiceLineVO1();
        Row[] invoiceLineVOList =  invoiceLineVo.getAllRowsInRange();
        if (invoiceLineVOList != null){
            BigDecimal totalAmount = new BigDecimal(0);
            for (int i=0;i<invoiceLineVOList.length;i++){
                Row invoiceLineVORec = invoiceLineVOList[i];          
                oracle.jbo.domain.Number qtyStr = (oracle.jbo.domain.Number)invoiceLineVORec.getAttribute("QuantitySell");
                oracle.jbo.domain.Number priceStr = (oracle.jbo.domain.Number)invoiceLineVORec.getAttribute("UnitSell");
                oracle.jbo.domain.Number amountStr = (oracle.jbo.domain.Number)invoiceLineVORec.getAttribute("SellAmount");
                
                BigDecimal qty = (qtyStr == null)? new BigDecimal(0):qtyStr.bigDecimalValue();
                BigDecimal price = (priceStr == null)? new BigDecimal(0):priceStr.bigDecimalValue();
                BigDecimal oldAmount =  (amountStr == null)? new BigDecimal(0):amountStr.bigDecimalValue();
                
                BigDecimal amount = qty.multiply(price);
                
                totalAmount = totalAmount.add(amount);
                System.out.println("InvoiceDetailCO: save() line Amount" +amount.toString());
                if (amount.compareTo(oldAmount) != 0){
                    try{
                        invoiceLineVORec.setAttribute("SellAmount", new oracle.jbo.domain.Number(amount));
                    }catch(SQLException sqle){
                        sqle.printStackTrace();
                        throw OAException.wrapperException(sqle);
                    }
                }
            }
            try{
                invoiceVo.getCurrentRow().setAttribute("TotalLineAmount", new oracle.jbo.domain.Number(totalAmount));
                
                System.out.println("InvoiceDetailCO: save() total Amount" +totalAmount.toString());
                
            }catch(SQLException sqle){
                sqle.printStackTrace();
                throw OAException.wrapperException(sqle);
            }
            
        }    
    }
    
    private void checkSalesRep(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        InvoiceSalesRepSplitsVOImpl  salesRepVO = am.getInvoiceSalesRepSplitsVO1();
        
        List<String> salesRepTrxIdList = new ArrayList<String>();
        List<String> primarySalesRepTrxIdList = new ArrayList<String>();
        
        Row[] salesRepVOList =  salesRepVO.getAllRowsInRange();
        for (int i=0;i<salesRepVOList.length;i++){
            Row salesRepVORec = salesRepVOList[i];          
            String salesRepId = salesRepVORec.getAttribute("SalesrepId").toString();
            if (!InvoiceClientUtil.isNull(salesRepId)) salesRepTrxIdList.add(salesRepId);
            
            String primaryFlag = salesRepVORec.getAttribute("PrimaryFlag").toString();
            if ("Y".equals(primaryFlag)){
                if (!InvoiceClientUtil.isNull(salesRepId)) primarySalesRepTrxIdList.add(salesRepId);
            }
        }
        /*
        Set<String> salesRepIdSet = new HashSet<String>(salesRepTrxIdList);
        if(salesRepIdSet.size() < salesRepTrxIdList.size()){
            throw new OAException("Duplicated Sales Rep", OAException.ERROR);   
        }        
         */
        if (primarySalesRepTrxIdList.size() != 1){
            throw new OAException("Only 1 Primary Sales Rep is required/allowed", OAException.ERROR);               
        }
        
    }
    
    private void addInvoiceLineRow(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        InvoiceVOImpl invoiceVo = am.getInvoiceVO1();            
        InvoiceLineVOImpl invoiceLineVO = am.getInvoiceLineVO1();        
    
        Row row = invoiceLineVO.createRow();
        oracle.jbo.domain.Number invoiceLineId = am.getOADBTransaction().getSequenceValue("XXBS_CUSTOMER_TRX_LINE_S");
        
        row.setAttribute("CustomerTrxLineId",invoiceLineId);
        row.setAttribute("CustomerTrxId",invoiceVo.getCurrentRow().getAttribute("CustomerTrxId"));
        row.setAttribute("ProjectId",invoiceVo.getCurrentRow().getAttribute("OriginalProjectId"));
        row.setAttribute("OrgId",invoiceVo.getCurrentRow().getAttribute("OrgId"));
        row.setAttribute("ProjectOrgId",invoiceVo.getCurrentRow().getAttribute("PrimaryProjectOrgId"));
        row.setAttribute("ProductTypeId",invoiceVo.getCurrentRow().getAttribute("PrimaryProductTypeId"));
        row.setAttribute("ProjectNumber",invoiceVo.getCurrentRow().getAttribute("ProjectNumber"));
        row.setAttribute("LineType","Line");
        row.setAttribute("SellAmount", new oracle.jbo.domain.Number(0));
        row.setNewRowState(Row.STATUS_NEW);
        invoiceLineVO.last();                        
        invoiceLineVO.next();                        
        invoiceLineVO.insertRow(row);
                
    }
 
    private void addInvoiceSalesRepRow(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        InvoiceVOImpl invoiceVo = am.getInvoiceVO1();            
        InvoiceSalesRepSplitsVOImpl invoiceSalesRepSplitsVO =  am.getInvoiceSalesRepSplitsVO1();          
    
        Row row = invoiceSalesRepSplitsVO.createRow();
        oracle.jbo.domain.Number repSplitId = am.getOADBTransaction().getSequenceValue("XXBS_REP_SPLITS_S");
        
        row.setAttribute("RepSplitId",repSplitId);
        row.setAttribute("CustomerTrxId",invoiceVo.getCurrentRow().getAttribute("CustomerTrxId"));
        row.setNewRowState(Row.STATUS_NEW);
        invoiceSalesRepSplitsVO.last();         
        invoiceSalesRepSplitsVO.next();
        invoiceSalesRepSplitsVO.insertRow(row);
        
    }    
    
    private void resetInvoiceSalesRepRow(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        InvoiceVOImpl invoiceVo = am.getInvoiceVO1();            
        try{
        
            String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
            am.resetDefaultSalesRep(customerTrxId);
        }catch(Exception e){
            e.printStackTrace();
            throw new OAException(e.getMessage(), OAException.ERROR);       
        }finally{
            am.getTransaction().commit(); 
        }        
    }      
    
    private void checkSubmitToAR(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        InvoiceVOImpl invoiceVo = am.getInvoiceVO1();            
        Object projectCompleteDate= am.getInvoiceVO1().getCurrentRow().getAttribute("ProjectCompleteDate");
        if (projectCompleteDate == null){
            throw new OAException("Please fill in Project Completion Date", OAException.ERROR);       
        }
    }
}
