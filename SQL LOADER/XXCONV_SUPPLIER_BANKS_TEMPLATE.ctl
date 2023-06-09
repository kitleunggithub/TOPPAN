OPTIONS(SKIP=0, BINDSIZE=100000, ERRORS=100000)
LOAD DATA
CHARACTERSET UTF8
INFILE '$FILE' "STR '\r\n'"
INTO TABLE XXCONV_SUPPLIER_BANKS
APPEND
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
 VENDOR_NUMBER	    
,VENDOR_NAME	    
,VENDOR_SITE_CODE	        
,START_DATE				DATE 'DD-MON-YYYY'	        
,END_DATE	        	DATE 'DD-MON-YYYY'
,PRIORITY	        
,COUNTRY_CODE        
,ALLOW_INT_PAYMENTS  
,BANK_NAME           
,BANK_NAME_ALT
,BANK_NUMBER             
,BRANCH_NAME
,BRANCH_NAME_ALT	        
,BRANCH_NUMBER           
,BIC          
,BRANCH_TYPE           
,BANK_ACCOUNT_NUM         
,BANK_ACCOUNT_NAME       
,BANK_ACCOUNT_CURRENCY
,BANK_ACCOUNT_TYPE   
,ACCOUNT_OWNERS
,PRIMARY
,OWNER_END_DATE			DATE 'DD-MON-YYYY'
, SEQ_NUM        RECNUM
, CREATION_DATE  SYSDATE
, REQUEST_ID     CONSTANT $P_REQUEST_ID
)
