/*===========================================================================+
 |      Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY               
 |  04/25/11   cpeixoto  fix for bug 11908273                                |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import java.io.Serializable;

import oracle.bali.share.util.BooleanUtils;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAQueryUtils;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.layout.OADefaultHideShowBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;

/**
 * Controller for oracle.apps.fnd.framework.toolbox.tutorial.webui.SupplierSearchPG 
 * page's "Search" region.
 */
public class SupplierSearchCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header: SupplierSearchCO.java 120.3 2011/04/26 12:08:43 sette ship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.tutorial.webui");

  /**
   * Layout and page setup logic for AK region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the AK region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);
    
    if (TransactionUnitHelper.isTransactionUnitInProgress(pageContext, "supplierCreateTxn", false))
    { 
      OAApplicationModule am = pageContext.getApplicationModule(webBean);
      am.invokeMethod("rollbackSupplier");
      TransactionUnitHelper.endTransactionUnit(pageContext, "supplierCreateTxn");

    }

    OADefaultHideShowBean hideShowBean = 
      (OADefaultHideShowBean)webBean.findIndexedChildRecursive("HideShowRN");

    if (hideShowBean == null)
    {
      MessageToken[] tokens = { new MessageToken("OBJECT_NAME", "HideShowRN") };
      throw new OAException("AK", "FWK_TBX_OBJECT_NOT_FOUND", tokens);
    }

     // fix for bug 11908273: the following is no longer necessary
     // hideShowBean.setPartialRenderMode(PARTIAL_RENDER_MODE_NONE); 
  } // end processRequest( )


  /**
   * Procedure to handle form submissions for form elements in
   * region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);

    /*
    ** NOTE:  As of the 11.5.10 release, you still must handle hiding/showing
    ** the top-level "Go" button yourself based on the state of the hide/show
    ** content (which includes its own "Go" button).  Because of this, you
    ** must also turn off partial page rendering.
    */

    // Check to see if the "Hide/Show" link or icon was clicked.

    String hideShowEvent = pageContext.getParameter("event");

    // fix for bug 11908273: the following is no longer necessary
    /* if (("show".equals(hideShowEvent)) || ("hide".equals(hideShowEvent)))
    {
    
      // Now redirect back to this page so we can hide or show the top-level
      // "Go" button in processRequest().  NEVER make UI changes in 
      // processFormRequest().
      
      pageContext.setForwardURLToCurrentPage(null, 
                                             true, // retain the AM
                                             ADD_BREAD_CRUMB_NO,
                                             IGNORE_MESSAGES);
    }                                                                                        
    else */ if (pageContext.getParameter("Go") != null) 
    {

      OAWebBean searchFieldParent = webBean.findChildRecursive("MainSearchRN");

      // Check for selective search criteria in the manually created search
      // region. Note that you must pass the region which is a the direct parent
      // of the search fields to test.
      OAQueryUtils.checkSelectiveSearchCriteria(pageContext, searchFieldParent);
      
	    String supplierName = pageContext.getParameter("SupplierName");
      String supplierNumber = pageContext.getParameter("SupplierNum");
	    String onHoldFlag = pageContext.getParameter("OnHold");

	    // All parameters passed using invokeMethod() must be serializable.

      // Note special table query handling per the coding standards.
      Boolean executeQuery = BooleanUtils.getBoolean(false);    
	    Serializable[] parameters =  
        { supplierName, onHoldFlag, supplierNumber, executeQuery };

      Class[] paramTypes = { String.class, String.class, String.class, Boolean.class };
      OAApplicationModule am = pageContext.getRootApplicationModule();
      am.invokeMethod("initSummary", parameters, paramTypes);

      OATableBean table = (OATableBean)webBean.findChildRecursive("SuppliersTable");

      // When handling a user initiated search, we always need to execute
      // the query so we pass "false" to queryData().
      table.queryData(pageContext, false);

    }
    else if (pageContext.getParameter("Create") != null)
    {

      // Note the use of KEEP_MENU_CONTEXT as opposed to GUESS_MENU_CONTEXT.
      // Since page 2 is on the menu for securing reasons -- but doesn't have
      // a visible menu entry for the Framework to highlight -- telling the
      // Framework to "guess" which menu entry to higlight for this means it's
      // parent tab will be properly selected, but the "Lesson 4" subtab will not.
      
	    pageContext.setForwardURL("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/tutorial/webui/SupplierPG",
                                null,
                                KEEP_MENU_CONTEXT,
								                null,
								                null,
								                true, // Retain AM
								                OAWebBeanConstants.ADD_BREAD_CRUMB_YES,
								                OAWebBeanConstants.IGNORE_MESSAGES);

    }
    
  } // end processFormRequest( )

}
