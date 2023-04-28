/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package toppanmerrill.oracle.apps.xxtm.cb.invoice.webui;

import java.sql.Date;

import java.text.DateFormat;

import java.text.SimpleDateFormat;

import java.util.ArrayList;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OARow;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAImageBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.apps.fnd.framework.webui.beans.form.OASubmitButtonBean;
import oracle.apps.fnd.framework.webui.beans.layout.OASubTabLayoutBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageLovInputBean;
import oracle.apps.fnd.framework.webui.beans.nav.OALinkBean;
import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;
import oracle.apps.fnd.framework.webui.beans.table.OAColumnBean;

import oracle.cabo.ui.UINode;

import oracle.jbo.Row;

import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceAMImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceVOImpl;

/**
 * Controller for ...
 */
public class SearchInvoiceCO extends OAControllerImpl
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
    

        checkUIReadyOnly(pageContext, webBean);
        OALinkBean invoiceArTrxNumberLK  = (OALinkBean)webBean.findChildRecursive("InvoiceArTrxNumberLK");
        invoiceArTrxNumberLK.setDestination(invoiceArTrxNumberLK.getDestination()+"&"+OASubTabLayoutBean.OA_SELECTED_SUBTAB_IDX+"=0");
        System.out.println("SearchInvoiceCO: invoiceArTrxNumberLK.getDestination "+invoiceArTrxNumberLK.getDestination());
     
     

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
        

        if (pageContext.getParameter("GoBN") != null){
            this.search(pageContext, webBean);
            checkUIReadyOnly(pageContext, webBean);
        }else if (pageContext.getParameter("CopyBN") != null){
            this.checkSingleSelection(pageContext, webBean);
            this.performCopy(pageContext, webBean);
            
        }else if (pageContext.getParameter("CombineBN") != null){
            this.checkSingleSelection(pageContext, webBean);
            this.performCombine(pageContext, webBean);
                
        }else if (pageContext.getParameter("UncombineBN") != null){
            this.checkSingleSelection(pageContext, webBean);
            this.performUnCombine(pageContext, webBean);
            
        }else if (pageContext.getParameter("VoidBN") != null){
            this.checkSelection(pageContext, webBean);
            this.performVoid(pageContext, webBean);
                
        }else if (pageContext.getParameter("ReviseBN") != null){
            this.checkSingleSelection(pageContext, webBean);
            this.performRevise(pageContext, webBean);
                    
        }else if (pageContext.getParameter("PrintBN") != null){
             this.checkSelection(pageContext, webBean);
             this.performPrint(pageContext, webBean);
                
            
        }else{
            search(pageContext, webBean);
            checkUIReadyOnly(pageContext, webBean);
        }
        
        
    }
    
     private void search(OAPageContext pageContext, OAWebBean webBean){
     
         String projectNumStr = pageContext.getParameter("ProjectNumField");
         String projectNameStr = pageContext.getParameter("ProjectNameField");
         String activeBillerId = pageContext.getParameter("ActiveBillerField");
         String customerNum = pageContext.getParameter("CustomerNumField");
         String customerName = pageContext.getParameter("CustomerNameField");
         String primarySalesRepId = pageContext.getParameter("PrimarySalesRepField");
         String transactionNum = pageContext.getParameter("TransactionNumField");
         String transactionDateFrom = pageContext.getParameter("TransactionDateFromField");
         String transactionDateTo = pageContext.getParameter("TransactionDateToField");
         String status =  pageContext.getParameter("StatusField");
         
         SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
         SearchInvoiceVOImpl vo = (SearchInvoiceVOImpl)am.findViewObject("SearchInvoiceVO1");
         vo.setFullSqlMode(vo.FULLSQL_MODE_AUGMENTATION);
         vo.setWhereClause(null);
         vo.setWhereClauseParams(null);
           

         
         int paraCount = 0;
         vo.addWhereClause(" 1=1 ");
         

         // for testing command out
         vo.setWhereClauseParam(paraCount++, pageContext.getProfile("ORG_ID") );
         vo.addWhereClause(" AND ORG_ID =:"+paraCount);
         
         
         if(!InvoiceClientUtil.isNull(projectNumStr))
         {
             vo.setWhereClauseParam(paraCount++, projectNumStr.trim());
             vo.addWhereClause(" AND PROJECT_NUMBER LIKE :"+ paraCount);
         }          
         if(!InvoiceClientUtil.isNull(projectNameStr))
         {
             vo.setWhereClauseParam(paraCount++, projectNameStr.trim());
             vo.addWhereClause(" AND PROJECT_NAME LIKE :"+ paraCount);
         }     
         if(!InvoiceClientUtil.isNull(activeBillerId))
         {
             vo.setWhereClauseParam(paraCount++, activeBillerId.trim());
             vo.addWhereClause(" AND ACTIVE_BILLER_ID =:"+ paraCount); 
         }           
         if(!InvoiceClientUtil.isNull(customerNum))
         {
            vo.setWhereClauseParam(paraCount++, customerNum.trim());
            vo.addWhereClause(" AND CUSTOMER_NO LIKE :"+paraCount);
         }     
         if(!InvoiceClientUtil.isNull(customerName))
         {
            vo.setWhereClauseParam(paraCount++, customerName.trim());
            vo.addWhereClause(" AND CUSTOMER_NAME LIKE :"+paraCount);
          
         }     
         if(!InvoiceClientUtil.isNull(primarySalesRepId))
         {
           vo.setWhereClauseParam(paraCount++, primarySalesRepId);
           vo.addWhereClause(" AND PRIMAY_SALESREP_ID =:"+paraCount);           
         }           
         if(!InvoiceClientUtil.isNull(transactionNum))
         {
           vo.setWhereClauseParam(paraCount++, transactionNum.trim());
           vo.addWhereClause(" AND AR_TRX_NUMBER LIKE :"+paraCount);
         }        
         if(!InvoiceClientUtil.isNull(transactionDateFrom))
         {
           try{ 
             Date date = pageContext.getOANLSServices().stringToDate(transactionDateFrom.trim());
             System.out.println("SearchInvoiceCO: from date "+date);
               
             vo.setWhereClauseParam(paraCount++, date);
             vo.addWhereClause(" AND TRUNC(TRX_DATE) >= TRUNC(:"+paraCount+") "); 
             
           }catch(Exception e){
               e.printStackTrace();
           }
         }        
         if(!InvoiceClientUtil.isNull(transactionDateTo))
         {
             try{ 
                 Date date = pageContext.getOANLSServices().stringToDate(transactionDateTo.trim());
                 System.out.println("SearchInvoiceCO: to date "+date);
                 
                 vo.setWhereClauseParam(paraCount++, date);
                 vo.addWhereClause(" AND TRUNC(TRX_DATE) <= TRUNC(:"+paraCount+") ");   
                 
             }catch(Exception e){
                 e.printStackTrace();
             }                              
           
         }       
         if(!InvoiceClientUtil.isNull(status))
         {
           vo.setWhereClauseParam(paraCount++, status);
           vo.addWhereClause(" AND CURRENT_STATUS =:"+paraCount);
           
         }  
         
//         if (vo.getOrderByClause() != null && vo.getOrderByClause().length() > 0){
//             vo.setOrderByClause("AR_TRX_NUMBER DESC");
//         }
       
//        System.out.println("SearchInvoiceCO: "+vo.getQuery());
        vo.executeQuery();     
         
     }
    
    private void performCopy(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am = (SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        SearchInvoiceVOImpl vo = (SearchInvoiceVOImpl)am.findViewObject("SearchInvoiceVO1");
    
        Row[] rows = vo.getAllRowsInRange();
        for (int i=0;i<rows.length;i++){
            OARow row = (OARow)rows[i];
            if (row.getAttribute("Selected") !=null &&  row.getAttribute("Selected").equals("Y")){
                if (row.getAttribute("CustomerTrxId") != null){
                    String customerTrxId = row.getAttribute("CustomerTrxId").toString();
                    System.out.println("CustomerTrxId selected: "+customerTrxId);
                    String trxTypeName = row.getAttribute("TrxTypeName").toString();
                    String invoiceClass = row.getAttribute("InvoiceClass").toString();
                    if (!"TM FINANCIAL INV".equals(trxTypeName)){
                        throw new OAException("Invalid Transaction Type", OAException.ERROR);   
                    }
                    if (!"N".equals(invoiceClass)){
                        throw new OAException("Invalid Invoice Class", OAException.ERROR);   
                    }                    
                    pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceCopyPG&CustomerTrxId="+customerTrxId,
                                                          null,
                                                          OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                                          null,                                                   
                                                          null,
                                                          true,                            
                                                          OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
                                                          OAWebBeanConstants.IGNORE_MESSAGES);
                                                
                    
                }
            }
         }    
    }
    
    
    private void performCombine(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am = (SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        SearchInvoiceVOImpl vo = (SearchInvoiceVOImpl)am.findViewObject("SearchInvoiceVO1");
    
        Row[] rows = vo.getAllRowsInRange();
        for (int i=0;i<rows.length;i++){
            OARow row = (OARow)rows[i];
            if (row.getAttribute("Selected") !=null &&  row.getAttribute("Selected").equals("Y")){
                if (row.getAttribute("CustomerTrxId") != null){
                    String customerTrxId = row.getAttribute("CustomerTrxId").toString();
                    System.out.println("SearchInvoiceCO: CustomerTrxId selected: "+customerTrxId);
                    String invoiceClass = row.getAttribute("InvoiceClass").toString();
                    String status = row.getAttribute("CurrentStatus").toString();
                    String customerName = row.getAttribute("CustomerName").toString();
                    String trxTypeName = row.getAttribute("TrxTypeName").toString();
                    //String revisedCustomerTrxId = row.getAttribute("RevisedCustomerTrxId").toString();
                    Object revisedCustomerTrxId = row.getAttribute("RevisedCustomerTrxId");
                    
                    if (!"N".equals(invoiceClass)){
                        throw new OAException("Invalid Invoice Class", OAException.ERROR);   
                    }
                    if (!"TM FINANCIAL INV".equals(trxTypeName)){
                        throw new OAException("Invalid Transaction Type", OAException.ERROR);   
                    }                    
                    if (!STATUS_CREATED.equals(status) && !STATUS_OUT_FOR_REVIEW.equals(status)){
                        throw new OAException("Invalid Invoice Status", OAException.ERROR);   
                    }
                    if (revisedCustomerTrxId != null && !InvoiceClientUtil.isNull(revisedCustomerTrxId.toString()) ){
                        throw new OAException("Rebill Invoice is not allowed", OAException.ERROR);   
                    }                                                            
                    if ("Default Customer".equals(customerName)){
                        throw new OAException("Default Customer is not allowed", OAException.ERROR);   
                    }                    
                    
                    am.checkParentForCombine(customerTrxId);
                    
                    String newCombineReqId = am.createCombineReq(customerTrxId);
                    System.out.println("SearchInvoiceCO: createCombineReq:" +newCombineReqId);
                    
                    pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceCombinePG&NewlyCreated=Y&CombineReqId="+newCombineReqId,
                                                          null,
                                                          OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                                          null,                                                   
                                                          null,
                                                          true,                            
                                                          OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
                                                          OAWebBeanConstants.IGNORE_MESSAGES);
                                                
                    
                }
            }
         }    
    }    
    
    private void performUnCombine(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am = (SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        SearchInvoiceVOImpl vo = (SearchInvoiceVOImpl)am.findViewObject("SearchInvoiceVO1");
    
        Row[] rows = vo.getAllRowsInRange();
        for (int i=0;i<rows.length;i++){
            OARow row = (OARow)rows[i];
            if (row.getAttribute("Selected") !=null &&  row.getAttribute("Selected").equals("Y")){
                if (row.getAttribute("CustomerTrxId") != null){
                    String customerTrxId = row.getAttribute("CustomerTrxId").toString();
                    System.out.println("SearchInvoiceCO: CustomerTrxId selected: "+customerTrxId);
                    String invoiceClass = row.getAttribute("InvoiceClass").toString();
                    String status = row.getAttribute("CurrentStatus").toString();
                    String trxTypeName = row.getAttribute("TrxTypeName").toString();
                    //String revisedCustomerTrxId = row.getAttribute("RevisedCustomerTrxId").toString();
                    Object revisedCustomerTrxId = row.getAttribute("RevisedCustomerTrxId");
                    
                    if (!"P".equals(invoiceClass)){
                        throw new OAException("Invalid Invoice Class", OAException.ERROR);   
                    }
                    if (!STATUS_CREATED.equals(status) && !STATUS_OUT_FOR_REVIEW.equals(status)){
                        throw new OAException("Invalid Invoice Status", OAException.ERROR);   
                    }
                    if (!"TM FINANCIAL INV".equals(trxTypeName)){
                        throw new OAException("Invalid Transaction Type", OAException.ERROR);   
                    }                                        
                    if (revisedCustomerTrxId != null && !InvoiceClientUtil.isNull(revisedCustomerTrxId.toString()) ){
                        throw new OAException("Rebill Invoice is not allowed", OAException.ERROR);   
                    }                                        
                    
                    am.checkParentForCombine(customerTrxId);
                    
                    String newCombineReqId = am.createUncombineReq(customerTrxId);
                    System.out.println("SearchInvoiceCO: createCombineReq:" +newCombineReqId);
                    
                    pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceCombinePG&NewlyCreated=Y&CombineReqId="+newCombineReqId,
                                                          null,
                                                          OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                                          null,                                                   
                                                          null,
                                                          true,                            
                                                          OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
                                                          OAWebBeanConstants.IGNORE_MESSAGES);
                                                
                    
                }
            }
         }    
    }        
    
    private void performRevise(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        SearchInvoiceVOImpl vo = (SearchInvoiceVOImpl)am.findViewObject("SearchInvoiceVO1");

        Row[] rows = vo.getAllRowsInRange();
        for (int i=0;i<rows.length;i++){
            OARow row = (OARow)rows[i];
            if (row.getAttribute("Selected") !=null &&  row.getAttribute("Selected").equals("Y")){
                if (row.getAttribute("CustomerTrxId") != null){
                    String customerTrxId = row.getAttribute("CustomerTrxId").toString();
                    System.out.println("SearchInvoiceCO: CustomerTrxId selected: "+customerTrxId);
                    String status = row.getAttribute("CurrentStatus").toString();
                    String trxTypeType = row.getAttribute("TrxTypeType").toString();

                    if (!STATUS_INVOICED.equals(status)){
                        throw new OAException("Invalid Invoice Status", OAException.ERROR);   
                    }
                    
                    if ("CM".equals(trxTypeType)){
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
            }
         }    
    }    
        

    private void performVoid(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        SearchInvoiceVOImpl vo = (SearchInvoiceVOImpl)am.findViewObject("SearchInvoiceVO1");
        StringBuffer customerTrxIdStrList = new StringBuffer("");
        
        Row[] rows = vo.getAllRowsInRange();
        int selectedCount = 0;
        for (int i=0;i<rows.length;i++){
            OARow row = (OARow)rows[i];
            if (row.getAttribute("Selected") !=null &&  row.getAttribute("Selected").equals("Y")){
            
                String status = row.getAttribute("CurrentStatus").toString();
                String trxTypeType = row.getAttribute("TrxTypeType").toString();
                Object revisedCustomerTrxId = row.getAttribute("RevisedCustomerTrxId");

                
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
                if ("CM".equals(trxTypeType)){
                    throw new OAException("Credit Memo is not allowed", OAException.ERROR);   
                }                                        
                if (revisedCustomerTrxId != null && !InvoiceClientUtil.isNull(revisedCustomerTrxId.toString()) ){
                    throw new OAException("Rebill Invoice is not allowed", OAException.ERROR);   
                }                                        
                

                customerTrxIdStrList.append(row.getAttribute("CustomerTrxId"));
                customerTrxIdStrList.append("|");
            }
        }    
        
        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceVoidPG&CustomerTrxId="+customerTrxIdStrList.toString(),
                                              null,
                                              OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                              null,                                                   
                                              null,
                                              true,                            
                                              OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
                                              OAWebBeanConstants.IGNORE_MESSAGES);
        
    }    
    

    private void performPrint(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        SearchInvoiceVOImpl vo = (SearchInvoiceVOImpl)am.findViewObject("SearchInvoiceVO1");
        StringBuffer customerTrxIdStrList = new StringBuffer("");
        
        Row[] rows = vo.getAllRowsInRange();
        int selectedCount = 0;
        for (int i=0;i<rows.length;i++){
            OARow row = (OARow)rows[i];
            if (row.getAttribute("Selected") !=null &&  row.getAttribute("Selected").equals("Y") && row.getAttribute("CustomerTrxId") != null){
                String customerTrxId  = row.getAttribute("CustomerTrxId").toString();
                try{
                    am.performPrint(customerTrxId);
                }catch(Exception e){
                    e.printStackTrace();
                }finally{
                    am.getTransaction().commit(); 
                }
            }
        }    
        throw new OAException("Concurrent Request(s) Submitted",OAException.INFORMATION);
                
    }    
    
    private void checkSingleSelection(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        SearchInvoiceVOImpl vo = (SearchInvoiceVOImpl)am.findViewObject("SearchInvoiceVO1");
        
        Row[] rows = vo.getAllRowsInRange();
        int selectedCount = 0;
        for (int i=0;i<rows.length;i++){
            OARow row = (OARow)rows[i];
            if (row.getAttribute("Selected") !=null &&  row.getAttribute("Selected").equals("Y")){
                selectedCount++;
            }
          }    
    
        if (selectedCount != 1){
            throw new OAException("Please select one record.", OAException.ERROR);   
        }
        
    }
    
    private void checkSelection(OAPageContext pageContext, OAWebBean webBean){
    
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        SearchInvoiceVOImpl vo = (SearchInvoiceVOImpl)am.findViewObject("SearchInvoiceVO1");
        
        Row[] rows = vo.getAllRowsInRange();
        int selectedCount = 0;
        for (int i=0;i<rows.length;i++){
            OARow row = (OARow)rows[i];
            if (row.getAttribute("Selected") !=null &&  row.getAttribute("Selected").equals("Y")){
                selectedCount++;
            }
          }    
    
        if (selectedCount < 1){
            throw new OAException("Please select record(s).", OAException.ERROR);   
        }
        
    }
    
    
    private void checkUIReadyOnly(OAPageContext pageContext, OAWebBean webBean){
        String readOnly = pageContext.getParameter("ReadOnly");
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

        if (readOnlyFlag){
            OAAdvancedTableBean oAAdvancedTableBean = (OAAdvancedTableBean)webBean.findChildRecursive("SearchInvoiceResultTE");;
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
        }else{
            OASubmitButtonBean copyBN = (OASubmitButtonBean) webBean.findChildRecursive("CopyBN");
            OASubmitButtonBean combineBN = (OASubmitButtonBean) webBean.findChildRecursive("CombineBN");  
            OASubmitButtonBean uncombineBN = (OASubmitButtonBean) webBean.findChildRecursive("UncombineBN");
            OASubmitButtonBean reviseBN = (OASubmitButtonBean) webBean.findChildRecursive("ReviseBN");
            OASubmitButtonBean voidBN  = (OASubmitButtonBean) webBean.findChildRecursive("VoidBN");
            OASubmitButtonBean printBN  = (OASubmitButtonBean) webBean.findChildRecursive("PrintBN");

            if (isBillerFlag){
                if (copyBN != null)copyBN.setRendered(true);
                if (combineBN != null)combineBN.setRendered(true);
                if (uncombineBN != null)uncombineBN.setRendered(true);
                if (reviseBN != null)reviseBN.setRendered(true);
                if (voidBN != null)voidBN.setRendered(true);
            }else{
                if (copyBN != null)copyBN.setRendered(false);
                if (combineBN != null)combineBN.setRendered(false);
                if (uncombineBN != null)uncombineBN.setRendered(false);
                if (reviseBN != null)reviseBN.setRendered(false);
                if (voidBN != null)voidBN.setRendered(false);
            }
            if (printBN != null)printBN.setRendered(true);
            
            
        }

                
    }
}
