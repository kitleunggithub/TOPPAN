package toppanmerrill.oracle.apps.xxtm.cb.invoice.webui;

import java.util.ArrayList;
import java.util.Dictionary;

import java.util.Enumeration;

import java.util.List;

import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OADescriptiveFlexBean;
import oracle.apps.fnd.framework.webui.beans.OAImageBean;
import oracle.apps.fnd.framework.webui.beans.OAKeyFlexBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.apps.fnd.framework.webui.beans.OAWebBeanAttachment;
import oracle.apps.fnd.framework.webui.beans.OAWebBeanDataAttribute;

import oracle.apps.fnd.framework.webui.beans.message.OAMessageLovInputBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageTextInputBean;

import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;

import oracle.apps.fnd.framework.webui.beans.table.OAColumnBean;
import oracle.apps.fnd.framework.webui.beans.table.OASortableHeaderBean;

import oracle.cabo.ui.UINode;
import oracle.cabo.ui.beans.form.FormElementBean;

public class InvoiceClientUtil {
    public InvoiceClientUtil() {
    }
    
    public static void setViewOnlyRecursive(OAPageContext paramOAPageContext, OAWebBean paramOAWebBean) {
      setViewOnlyRecursiveInternal(paramOAPageContext, paramOAWebBean, false, 0, new ArrayList<String>());
    }


    public static void setViewOnlyRecursive(OAPageContext paramOAPageContext, OAWebBean paramOAWebBean, List<String> exceptList) {
      setViewOnlyRecursiveInternal(paramOAPageContext, paramOAWebBean, false, 0, exceptList);
    }

    private static void setViewOnlyRecursiveInternal(OAPageContext paramOAPageContext, OAWebBean paramOAWebBean, boolean paramBoolean, int paramInt) {
        setViewOnlyRecursiveInternal(paramOAPageContext, paramOAWebBean, false, 0, new ArrayList<String>());
    }
    
    private static void setViewOnlyRecursiveInternal(OAPageContext paramOAPageContext, OAWebBean paramOAWebBean, boolean paramBoolean, int paramInt, List<String> exceptList) {

      if (paramOAWebBean == null) return; 
      
      //System.out.println("InvoiceClientUtil.setViewOnlyRecursiveInternal checking: "+ paramOAWebBean.getID());
      boolean exceptionItem = (exceptList != null && exceptList.contains(paramOAWebBean.getID()));
      if (exceptionItem ) {
          System.out.println("InvoiceClientUtil.setViewOnlyRecursiveInternal execption: "+ paramOAWebBean.getID());
          return; 
      }
      
      if (paramOAWebBean instanceof FormElementBean) {
          
        if (paramOAWebBean instanceof OAWebBeanDataAttribute)    ((OAWebBeanDataAttribute)paramOAWebBean).setRequired("no"); 
        FormElementBean formElementBean = (FormElementBean)paramOAWebBean;
        formElementBean.setReadOnly(true);
        if (!paramBoolean) paramOAWebBean.setStyleClass("OraDataText"); 
        if (paramOAWebBean instanceof OAMessageTextInputBean) {
          ((OAMessageTextInputBean)paramOAWebBean).setTip(null);
        } else if (paramOAWebBean instanceof OAMessageLovInputBean) {
          ((OAMessageLovInputBean)paramOAWebBean).setTip(null);
        } 
      } else if (paramOAWebBean instanceof OADescriptiveFlexBean) {
        OADescriptiveFlexBean oADescriptiveFlexBean = (OADescriptiveFlexBean)paramOAWebBean;
        oADescriptiveFlexBean.setRequired("no");
        oADescriptiveFlexBean.setReadOnly(true, true, true);
        if (!paramBoolean) oADescriptiveFlexBean.setStyleClass("OraDataText"); 
      } else if (paramOAWebBean instanceof OAKeyFlexBean && !exceptionItem) {
        OAKeyFlexBean oAKeyFlexBean = (OAKeyFlexBean)paramOAWebBean;
        oAKeyFlexBean.setRequired("no");
        oAKeyFlexBean.setReadOnly(true);
        if (!paramBoolean) oAKeyFlexBean.setStyleClass("OraDataText"); 
      } else if (paramOAWebBean instanceof OAWebBeanAttachment) {
        OAWebBeanAttachment oAWebBeanAttachment = (OAWebBeanAttachment)paramOAWebBean;
        Dictionary[] arrayOfDictionary = oAWebBeanAttachment.getEntityMappings();
        if (arrayOfDictionary != null)
          for (byte b = 0; b < arrayOfDictionary.length; b++) {
            arrayOfDictionary[b].put("insertAllowed", Boolean.FALSE);
            arrayOfDictionary[b].put("deleteAllowed", Boolean.FALSE);
            arrayOfDictionary[b].put("updateAllowed", Boolean.FALSE);
          }  
      } else if (paramOAWebBean instanceof OAAdvancedTableBean) {
        OAAdvancedTableBean oAAdvancedTableBean = (OAAdvancedTableBean)paramOAWebBean;
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
            UINode uINode = paramOAWebBean.getIndexedChild(b);
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

          
      } else if (paramOAWebBean instanceof OASortableHeaderBean && !exceptionItem) {
        OASortableHeaderBean oASortableHeaderBean = (OASortableHeaderBean)paramOAWebBean;
        oASortableHeaderBean.setRequired("no");
      } 
      
      if (paramOAWebBean instanceof oracle.apps.fnd.framework.webui.beans.OAWebBeanContainer && !(paramOAWebBean instanceof oracle.apps.fnd.framework.webui.beans.nav.OAPageButtonBarBean)) {
        boolean bool = false;
        if (paramBoolean || paramOAWebBean instanceof OAColumnBean)
          bool = true; 
        int i = paramOAWebBean.getIndexedChildCount();
        for (byte b = 0; b < i; b++) {
          UINode uINode = paramOAWebBean.getIndexedChild(b);
          if (uINode instanceof OAWebBean)
            setViewOnlyRecursiveInternal(paramOAPageContext, (OAWebBean)uINode, bool, paramInt + 1, exceptList); 
        } 
        Enumeration<String> enumeration = paramOAWebBean.getChildNames();
        if (enumeration != null)
          while (enumeration.hasMoreElements()) {
            String str1 = enumeration.nextElement();
            UINode uINode = paramOAWebBean.getNamedChild(str1);
            if (uINode instanceof OAWebBean)
              setViewOnlyRecursiveInternal(paramOAPageContext, (OAWebBean)uINode, bool, paramInt + 1, exceptList); 
          }  
      } 
      
    }
 
 
    public static boolean isNull(String str){
        return (str == null || str.trim().length() == 0);
    }
    
}
