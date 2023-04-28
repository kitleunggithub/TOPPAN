/*===========================================================================+
 |   Copyright (c) 2001, 2015 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.fnd.framework.toolbox.tutorial.webui;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.toolbox.tutorial.server.PoDetailsFullVOImpl;
import oracle.apps.fnd.framework.toolbox.tutorial.server.PoDetailsFullVORowImpl;
import oracle.apps.fnd.framework.toolbox.tutorial.server.PoLineShipFullVOImpl;
import oracle.apps.fnd.framework.toolbox.tutorial.server.PoLineShipFullVORowImpl;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.beans.OABodyBean;
import oracle.apps.fnd.framework.webui.beans.OADescriptiveFlexBean;
import oracle.apps.fnd.framework.webui.beans.OAScriptBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.table.OATableBean;

import oracle.cabo.ui.data.ArrayDataSet;
import oracle.cabo.ui.data.DictionaryData;

import oracle.jbo.domain.Number;
import oracle.jbo.Row;

/**
 * Controller for ...
 */
public class SimplifiedPOCreateCO extends OAControllerImpl
{
  public static final String RCS_ID =
    "$Header: SimplifiedPOCreateCO.java 120.0.12020000.4 2015/04/14 07:33:46 spunam noship $";
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
    OABodyBean bodyBean = (OABodyBean) pageContext.getRootWebBean();
//    bodyBean.setOnLoad("createMap();");
    addMapsJSLibraryAndFunctions(pageContext, webBean);

      OATableBean table =
        (OATableBean)webBean.findIndexedChildRecursive("LinesTable");

      // Configure the table to include an "Add a Row" button.  Let the Framework
      // go ahead and call create/insert on the VO when the user presses it.
       int childCount = table.getIndexedChildCount(null); 
       DictionaryData columnHeaderFormats[] = new DictionaryData[childCount];
       for (int i = 0; i < childCount; i++) 
       { 
         columnHeaderFormats[i] = new DictionaryData();
         columnHeaderFormats[i].put(CELL_NO_WRAP_FORMAT_KEY, Boolean.TRUE); 
       }
       table.setColumnHeaderFormats(new ArrayDataSet(columnHeaderFormats));
      table.setInsertable(true);
      table.setAutoInsertion(true); // we need to handle the button ourselves
      table.prepareForRendering(pageContext);

    // If isBackNavigationFired = false, we're here after a valid navigation
    // and we should proceed normally.
    // isBackNavigationFired(false /* trackFormSubmitOnly */) tracks the
    // browser back button event for non-form-submit request case as well.
    // We don't want to create a redundant new record whenever user reloads
    // the Create page, so tracking non-form-submit case as well.

    // Also, if the user navigates back to this flow by selecting the Back
    // button in the next page in the multipage flow, we don't want to do
    // anything on this page (we don't want to recreate the PO, and we don't
    // want to display a state loss error).

    if (!pageContext.isBackNavigationFired(false) &&
        (!"goto".equals(pageContext.getParameter(EVENT_PARAM))))
    {
      OAApplicationModule am = pageContext.getApplicationModule(webBean);

      TransactionUnitHelper.startTransactionUnit(pageContext, "poCreateTxn");

      if (!pageContext.isFormSubmission())
      {
        // Ask the application module to initialize an employee so the
        // user can complete it.
        am.invokeMethod("createPurchaseOrder");
      }
      
      
     
    
//      oracle.apps.fnd.framework.webui.beans.layout.OAPopupBean popup = (oracle.apps.fnd.framework.webui.beans.layout.OAPopupBean)webBean.findChildRecursive("buyercontactpopup");
//      //  popup.setShowNotch(true);
      
    } else
    {
      if (!TransactionUnitHelper.isTransactionUnitInProgress(pageContext,
                                                             "poCreateTxn",
                                                             true))
      {
        OADialogPage dialogPage = new OADialogPage(STATE_LOSS_ERROR);
        pageContext.redirectToDialogPage(dialogPage);
      }
    }
    
    OATableBean linesTable = (OATableBean)webBean.findChildRecursive("LinesTable");
    linesTable.setAttributeValue(CONTROLBAR_RENDERING_STYLE,BUTTON_FORMAT);
    
//   setDefaultValuesForFields(pageContext, webBean);
    
    
  } 

 public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
 {
   super.processFormRequest(pageContext, webBean);
   
   OAApplicationModule am = pageContext.getApplicationModule(webBean);
   
    if (ADD_ROWS_EVENT.equals(pageContext.getParameter(EVENT_PARAM)))
    {
      am.invokeMethod("createLineItem", null);
    }

   if ((pageContext.getParameter("Submit") != null))
   {
 
          TransactionUnitHelper.startTransactionUnit(pageContext, "poCreateTxn");
          
      PoDetailsFullVOImpl vo1 =
        (PoDetailsFullVOImpl)am.findViewObject("PoDetailsFullVO1");
     PoDetailsFullVORowImpl row1 = (PoDetailsFullVORowImpl) vo1.first();
     Number orderIdNum =(Number) row1.getHeaderId();

          am.invokeMethod("apply");
          
     String orderNumber = pageContext.getParameter("headerId");
     
     MessageToken[] tokens = { new MessageToken("PO_NUMBER", orderIdNum.toString()) };
     OAException message = new OAException("AK", "FWK_TBX_T_PO_UPDATE_CONFIRM", tokens,
                                           OAException.CONFIRMATION, null);
     pageContext.putDialogMessage(message);
   }
   
   else if (pageContext.getParameter("Cancel") != null)
   {
      am.invokeMethod("rollbackPurchaseOrder");  

      // Remove the "in transaction" indicator
      TransactionUnitHelper.endTransactionUnit(pageContext, "poUpdateTxn");
      
      pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/fnd/framework/toolbox/tutorial/webui/SimplifiedPOSearchPG",
                                     null,
                                     OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                     null,
                                     null,
                                     true, // retain AM
                                     OAWebBeanConstants.ADD_BREAD_CRUMB_NO);
   }

   }
   
   
   
 


  private void addMapsJSLibraryAndFunctions(OAPageContext pageContext,
                                            OAWebBean webBean)
  {
    OAScriptBean googleMapLibrary =
      (OAScriptBean)createWebBean(pageContext, SCRIPT_BEAN);
    googleMapLibrary.setSource("http://maps.google.com/maps/api/js?sensor=true");
    webBean.addIndexedChild(googleMapLibrary);


    OAScriptBean jsScript =
      (OAScriptBean)createWebBean(pageContext, SCRIPT_BEAN);


    StringBuffer jsScriptStr = new StringBuffer("");
  //    jsScriptStr.append(addTestOnLoad());
    jsScriptStr.append(addGetLocationJS());
    jsScriptStr.append(addShowPositionJS());
    jsScriptStr.append(addCreateMapCanvasJS());
    jsScriptStr.append(addPopulateAddressJS());
    jsScriptStr.append(addGetAddressLine1DetailsJS());
    jsScriptStr.append(addGetAddressLine2DetailsJS());
    jsScriptStr.append(addAddressLineConcatJS());    
    jsScriptStr.append(addPopulateAddressFieldBoxesJS());
    jsScriptStr.append(addGetAddressFieldByValueJS());
    jsScriptStr.append(addShowErrorJS());
    jsScriptStr.append(addCreateMapJS());

    jsScript.setText(jsScriptStr.toString());
    
    webBean.addIndexedChild(jsScript);
    
    OAScriptBean showMapOnLoadJS =
      (OAScriptBean)createWebBean(pageContext, SCRIPT_BEAN);
    showMapOnLoadJS.setText("createMap();");
      
    webBean.addIndexedChild(showMapOnLoadJS);
  }

  private String addGetLocationJS()
  {
    StringBuffer jsFunction =
      new StringBuffer("function getLocation(param) {" + "var x = document.getElementById(\"mapContainer\");" +
                       "if (navigator.geolocation) {" +
                      "if(param=='currentLocationInMap') "+
                       "navigator.geolocation.getCurrentPosition(createMapCanvas,showError);" +
                       "else if(param=='currentLocationDetails')"+
                       "navigator.geolocation.getCurrentPosition(populateAddress,showError);"+
                       " } else { " +
                       "x.innerHTML = \"Geolocation is not supported by this browser.\";" +
                       "}}");
    return jsFunction.toString();
  }

  private String addShowPositionJS()
  {
    StringBuffer jsFunction =
      new StringBuffer("function showPosition(position) {" +
                       "var latlon = position.coords.latitude+\",\"+position.coords.longitude;" +
                       "createMapCanvas(position);" +
                       "populateAddress(position);}");
    return jsFunction.toString();
  }


  private String addCreateMapCanvasJS()
  {
    StringBuffer jsFunction =

      new StringBuffer("function createMapCanvas(position){" +
                       "var mapcanvas = document.createElement('div');" +
                       "mapcanvas.id = 'mapcontainer';" +
                       "mapcanvas.style.height = '200px';" +
                       "mapcanvas.style.width = '300px';" +
//                       "mapcanvas.style.top = '50px';" +
                       "mapcanvas.style.left = '5px';" +
                       "var mapHolderObj = document.getElementById('mapholder');" +
                       "mapHolderObj.appendChild(mapcanvas);" +
                       "var coords = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);" +
                       "var options = {zoom: 15,center: coords, mapTypeControl: false, navigationControlOptions: { style: google.maps.NavigationControlStyle.SMALL },mapTypeId: google.maps.MapTypeId.ROADMAP  };" +
                       "var map = new google.maps.Map(document.getElementById(\"mapcontainer\"), options);" +
                       "var marker = new google.maps.Marker({position: coords, map: map,title:\'You are here!\'});}");

    return jsFunction.toString();

  }

  private String addPopulateAddressJS()
  {
    StringBuffer jsFunction =
      new StringBuffer("function populateAddress(position){" +
                       "var coords = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);" +
                       "var geocoder = new google.maps.Geocoder();" +
                       "geocoder.geocode({'latLng': coords}, function(results, status) {" +
                       "if (status == google.maps.GeocoderStatus.OK) {" +
                       "if (results[1]) {" +
                       "populateAddressFieldBoxes(results);" + "} else {" +
                       "alert('No results found');" + "}" + "} else {" +
                       "alert('Geocoder failed due to: ' + status);" +
                       "}});}");
    return jsFunction.toString();
  }

  private String addPopulateAddressFieldBoxesJS()
    {
      StringBuffer jsFunction = new StringBuffer("function populateAddressFieldBoxes(results){"+
            "var country = getAddressFieldByValue(results,'country');"+
            "var addressLine1 = getAddressLine1Details(results,country);"+   
            "document.getElementById('addressLine1').value = addressLine1;"+
            "var addressLine2 = getAddressLine2Details(results,country);"+   
            "document.getElementById('addressLine2').value = addressLine2;"+
            "document.getElementById('city').value = getAddressFieldByValue(results,'locality');"+
            "document.getElementById('state').value = getAddressFieldByValue(results,'administrative_area_level_1');"+
            "document.getElementById('country').value = country;"+
            "document.getElementById('zipCode').value = getAddressFieldByValue(results,'postal_code');"
            + "}");
          
      return jsFunction.toString();
    }
    
    private String addGetAddressLine1DetailsJS()
    {
      StringBuffer jsFunction = new StringBuffer("function getAddressLine1Details(results,country){"+
            "var addressLine = '';"+
            "if(country == 'United States'){"+    
              "var street_number = getAddressFieldByValue(results,'street_number');"+
              "var route = getAddressFieldByValue(results,'route');"+
              "addressLine = addressLineConcat(addressLine,street_number);"+  
              "addressLine = addressLineConcat(addressLine,route);"+      
            "}"+  
            "else if(country == 'India'){"+
              "var premise = getAddressFieldByValue(results,'premise');"+
              "var sublocalityLevel3 = getAddressFieldByValue(results,'sublocality_level_3');"+
              "var sublocalityLevel2 = getAddressFieldByValue(results,'sublocality_level_2');"+
              "addressLine = addressLineConcat(addressLine,premise);"+
              "addressLine = addressLineConcat(addressLine,sublocalityLevel3);"+
              "addressLine = addressLineConcat(addressLine,sublocalityLevel2);"+
            "}"+
            "return addressLine;"+  
          "}");
      return jsFunction.toString();
    }
    
    private String addGetAddressLine2DetailsJS()
    {
      StringBuffer jsFunction = new StringBuffer("function getAddressLine2Details(results,country){"+
            "var addressLine = '';"+
            "if(country == 'United States'){"+    
              "var neighborhood = getAddressFieldByValue(results,'neighborhood');"+
              "addressLine = addressLineConcat(addressLine,neighborhood);"+
            "}"+
            "else if(country == 'India'){"+
              "var sublocalityLevel1 = getAddressFieldByValue(results,'sublocality_level_1');"+   
              "addressLine = addressLineConcat(addressLine,sublocalityLevel1);"+   
            "}"+
            "return addressLine;"+  
          "}");
          return jsFunction.toString();
    }
    
    private String addAddressLineConcatJS()
    {
      StringBuffer jsFunction = new StringBuffer("function addressLineConcat(addressLine, addrComponent){"+
            "if(addressLine == ''){"+
              "addressLine = addrComponent;}"+
            "else if(addrComponent != ''){"+
              "addressLine = addressLine + ','+addrComponent;}"+
            "return addressLine;}");
          return jsFunction.toString();
    }

  private String addGetAddressFieldByValueJS()
  {
    StringBuffer jsFunction = new StringBuffer("function getAddressFieldByValue(results,addressFieldType){"+
              "var addressFieldVal = '';"+  
                "for (var i=0;i<results[0].address_components.length;i++){"+
                  "var addr = results[0].address_components[i];"+
                  "if(addr.types[0]==addressFieldType){"+
                    "addressFieldVal = addr.long_name;return addressFieldVal;}}"+
                    "if(addressFieldVal == null)addressFieldVal = '';"+
                    "return addressFieldVal;}");
    return jsFunction.toString();
  }

  private String addShowErrorJS()
  {
    StringBuffer jsFunction =
      new StringBuffer("function showError(error) {" + "var x = document.getElementById('mapContainer');" +
                       "switch(error.code) {" +
                       "case error.PERMISSION_DENIED:" +
                       "x.innerHTML = 'User denied the request for Geolocation.';" +
                       "break;" + "case error.POSITION_UNAVAILABLE:" +
                       "x.innerHTML = 'Location information is unavailable.';" +
                       "break;" + "case error.TIMEOUT:" +
                       "x.innerHTML = 'The request to get user location timed out.';" +
                       "break;" + "case error.UNKNOWN_ERROR:" +
                       "x.innerHTML = 'An unknown error occurred.';" +
                       "break;}}");
    return jsFunction.toString();
  }

  private String addTestOnLoad()
  {
    StringBuffer jsFunction = new StringBuffer("function testLoad(){ alert('Hello!');}");
    return jsFunction.toString();
  }

  private String addCreateMapJS()
    {
      StringBuffer jsFunction = new StringBuffer("function createMap(){"+          
          "getLocation('currentLocationInMap');}");
      return jsFunction.toString(); 
  
    }


}
