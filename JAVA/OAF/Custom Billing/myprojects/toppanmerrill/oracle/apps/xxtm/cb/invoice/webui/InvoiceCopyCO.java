/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package toppanmerrill.oracle.apps.xxtm.cb.invoice.webui;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.apps.fnd.framework.webui.beans.layout.OASubTabLayoutBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageChoiceBean;

import oracle.jbo.Row;

import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceTrxTypeLovVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.InvoiceVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.PrimaryProductTypeLovVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceAMImpl;

/**
 * Controller for ...
 */
public class InvoiceCopyCO extends OAControllerImpl
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
      
      //testing
      if (isNull(customerTrxId)) customerTrxId = "1001";
      
      if (customerTrxId != null){
            
          InvoiceVOImpl invoiceVo = am.getInvoiceVO1();
          if (invoiceVo != null){
              invoiceVo.setWhereClause(null);
              invoiceVo.setWhereClauseParams(null);
              
              invoiceVo.setWhereClause(" CUSTOMER_TRX_ID = :1 ");
              invoiceVo.setWhereClauseParam(0,customerTrxId );
              invoiceVo.executeQuery();
              System.out.println("InvoiceCopyCO: InvoiceVOImpl " +invoiceVo.getRowCount());
              
              if (invoiceVo.getRowCount() >0){
                  invoiceRow = invoiceVo.first();
              }
              
          }                
          
          
          InvoiceTrxTypeLovVOImpl invoiceTrxTypeLovVo = am.getInvoiceTrxTypeLovVO1();
          if (invoiceTrxTypeLovVo != null && invoiceRow != null  ){
              invoiceTrxTypeLovVo.setWhereClause(null);
              invoiceTrxTypeLovVo.setWhereClauseParams(null);
              
              
              int paraCount = 0;
              invoiceTrxTypeLovVo.addWhereClause(" NAME IN ('TM FINANCIAL INV', 'TM DEPOSIT INV', 'TM MEAL INV' ) AND TYPE='INV'  ");
              
              
              invoiceTrxTypeLovVo.setWhereClauseParam(paraCount++, invoiceRow.getAttribute("OrgId") );
              invoiceTrxTypeLovVo.addWhereClause(" AND ORG_ID =:"+paraCount);

              invoiceTrxTypeLovVo.setWhereClauseParam(paraCount++, invoiceRow.getAttribute("SetOfBooksId") );
              invoiceTrxTypeLovVo.addWhereClause(" AND SET_OF_BOOKS_ID =:"+paraCount);
                            
              invoiceTrxTypeLovVo.executeQuery();
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
    
      if (pageContext.getParameter("CopyBN") != null){
          copy(pageContext, webBean);
      }else if (pageContext.getParameter("CancelCopyBN") != null){
          unSave(pageContext, webBean);
          backToSearch(pageContext, webBean);
      }
    
  }


    private void copy(OAPageContext pageContext, OAWebBean webBean){
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        String customerTrxId = am.getInvoiceVO1().getCurrentRow().getAttribute("CustomerTrxId").toString();
        
        OAMessageChoiceBean transactionTypeFD = (OAMessageChoiceBean)webBean.findChildRecursive("TransactionTypeFD");
        String customerTrxTypeId = transactionTypeFD.getValue(pageContext).toString();
        System.out.println("InvoiceCopyCO: customerTrxTypeId :"+customerTrxTypeId);
        String newCustromerTrxId =  am.copy(customerTrxId, customerTrxTypeId);
        
        System.out.println("InvoiceCopyCO:newCustromerTrxId :"+newCustromerTrxId);

        pageContext.setForwardURL("OA.jsp?page=/toppanmerrill/oracle/apps/xxtm/cb/invoice/webui/InvoiceDetailPG&"+"CustomerTrxId="+newCustromerTrxId+"&NewlyCreated=Y&"+OASubTabLayoutBean.OA_SELECTED_SUBTAB_IDX+"=0",
                                          null,
                                          OAWebBeanConstants.KEEP_MENU_CONTEXT,                            
                                          null,                                                   
                                          null,
                                          true,                            
                                          OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
                                          OAWebBeanConstants.IGNORE_MESSAGES);

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


    private boolean isNull(String str){
        return (str == null || str.trim().length() == 0);
    }
}
