/*===========================================================================+
 |      Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 |       20-APR-02  L Lyons   Created                                        |
 +===========================================================================*/
 // javadoc_private
package oracle.apps.fnd.framework.toolbox.schema.server;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;

public class ApprovalManagerFactory
{
  // Mandatory for Applications source control
  public static final String RCS_ID="$Header: ApprovalManagerFactory.java 120.1 2005/06/06 13:21:35 atgops1 noship $";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "oracle.apps.fnd.framework.toolbox.schema.server");

  public static final int PO = 1;
  public static final int REQ =  2;
  public static final int INVOICE = 3;
  public static final int AGREEMENT = 4;

// Reason for using a factory is it gives you a single place to go to
// to get an appropriate ApprovalManager by type.  If you ever need to 
// change the ApprovalManager associated with a type, you only have to change
// it in once place. If you're using an approval manager in 10 places, and 
// you want to change it (customer implements 'MyPOApprovalManager') they've got
// one place to go to change it.

// NOTE:  DON'T EVEN THINK ABOUT using member variables in a singleton class
// like the poApprovalManager unless you have significant multithreading 
// experience and fully understand the issues with this.
  
  private static ApprovalManager mPoApprovalManager = new PoApprovalManager();

//   private static ApprovalManager mAgreeApprovalManager = new AgreementApprovalManager();    
//   private static ApprovalManager mInvApprovalManager = new InvoiceApprovalManager();
//   private static ApprovalManager mReqApprovalManager = new RequisitionApprovalManager();

  public static ApprovalManager getApprovalManager(int type)
  {
   switch (type)
	 {
	  case PO: 
	    return mPoApprovalManager;
	  case REQ:
	   // return mReqApprovalManager;
	  case INVOICE:
	   // return mInvApprovalManager;
	  default:
	   throw new OAException("AK", "FWK_TBX_T_PO_APP_MGR_UNKNOWN");
    }
    
  } // end getApprovalManager( )
}
