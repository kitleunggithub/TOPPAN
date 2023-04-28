/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package toppanmerrill.oracle.apps.xxtm.cb.invoice.webui;

import java.sql.Date;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchCombineReqVOImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceAMImpl;
import toppanmerrill.oracle.apps.xxtm.cb.invoice.server.SearchInvoiceVOImpl;

/**
 * Controller for ...
 */
public class SearchCombineReqCO extends OAControllerImpl
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
      super.processFormRequest(pageContext, webBean);
      
      String readOnly = pageContext.getParameter("ReadOnly");
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
          
      }       
    
  }

    private void search(OAPageContext pageContext, OAWebBean webBean){
    
        String requestNumField = pageContext.getParameter("RequestNumField");
        String requestStatusField = pageContext.getParameter("RequestStatusField");
        String parentTransactionNumField = pageContext.getParameter("ParentTransactionNumField");
        String childTransactionNumField = pageContext.getParameter("ChildTransactionNumField");
        
        SearchInvoiceAMImpl am=(SearchInvoiceAMImpl)pageContext.getApplicationModule(webBean);
        SearchCombineReqVOImpl vo = (SearchCombineReqVOImpl)am.getSearchCombineReqVO1();
        vo.setFullSqlMode(vo.FULLSQL_MODE_AUGMENTATION);
        vo.setWhereClause(null);
        vo.setWhereClauseParams(null);
          

        
        int paraCount = 0;
        vo.addWhereClause(" 1=1 ");
        

        // for testing command out
        vo.setWhereClauseParam(paraCount++, pageContext.getProfile("ORG_ID") );
        vo.addWhereClause(" AND ORG_ID =:"+paraCount);
        
        
        if(!InvoiceClientUtil.isNull(requestNumField))
        {
            vo.setWhereClauseParam(paraCount++, requestNumField.trim());
            vo.addWhereClause("AND COMBINE_REQ_NUMBER LIKE :"+ paraCount);
        }          
        if(!InvoiceClientUtil.isNull(requestStatusField))
        {
            vo.setWhereClauseParam(paraCount++, requestStatusField);
            vo.addWhereClause("AND STATUS =:"+ paraCount);
        }     
        if(!InvoiceClientUtil.isNull(parentTransactionNumField))
        {
            vo.setWhereClauseParam(paraCount++, parentTransactionNumField.trim());
            vo.addWhereClause("AND PARENT_TRX_NUMBER LIKE :"+ paraCount); 
        }           
        if(!InvoiceClientUtil.isNull(childTransactionNumField))
        {
           vo.setWhereClauseParam(paraCount++, childTransactionNumField.trim());
           vo.addWhereClause("AND CHILD_TRX_NUMBER LIKE :"+paraCount);
        }     

//        if (vo.getOrderByClause() != null && vo.getOrderByClause().length() > 0){
//            vo.setOrderByClause("COMBINE_REQ_NUMBER DESC");
//        }
        vo.executeQuery();     
        
    }
    
    
}
