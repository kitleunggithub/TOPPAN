OPTIONS(SKIP=0, BINDSIZE=100000, ERRORS=100000)
LOAD DATA
CHARACTERSET UTF8
INFILE '$FILE' "STR '\r\n'"
INTO TABLE XXCONV_CUSTOMERS
APPEND
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
CUSTOMER_NAME      
,NAME_PRONUNCIATION 
,ACCOUNT_NUMBER     
,ACCOUNT_TYPE       
,PROFILE_CLASS      
,PAYMENT_TERM       
,PRIMARY_SALES_REP  
,PRIMARY_SPLIT      
,SALES_REP2         
,SPLIT2	           
,SALES_REP3	       
,SPLIT3	           
,SALES_REP4         
,SPLIT4	           
,SALES_REP5         
,SPLIT5             
,STOCK_CODE         
,CUSTOMER_SINCE     
,CREDIT_RATING      
,CREDIT_LIMIT       
,CREDIT_PERIOD      
,STATUS             
,REMARK             
,SITE_NUMBER        
,COUNTRY_CODE       
,ADDRESS_LINE_1 "replace(:ADDRESS_LINE_1,chr(10),' ')"     
,ADDRESS_LINE_2 "replace(:ADDRESS_LINE_2,chr(10),' ')"    
,ADDRESS_LINE_3 "replace(:ADDRESS_LINE_3,chr(10),' ')"    
,ADDRESS_LINE_4 "replace(:ADDRESS_LINE_4,chr(10),' ')"    
,CITY
,COUNTY
,STATE
,PROVINCE
,POSTAL_CODE
,PURPOSE            
,LOCATION           
,PRIMARY_FLAG
,CONTACT_FIRST_NAME "replace(:CONTACT_FIRST_NAME,chr(10),' ')"
,CONTACT_MIDDLE_NAME
,CONTACT_LAST_NAME "replace(:CONTACT_LAST_NAME,chr(10),' ')"
,CONTACT_JOB_TITLE "replace(:CONTACT_JOB_TITLE,chr(10),' ')"
,CONTACT_NUMBER "replace(:CONTACT_NUMBER,chr(10),' ')"
,EMAIL
,EMAIL_PRIMARY_FLAG
,TEL_COUNTRY_CODE
,TEL_AREA_CODE "replace(:TEL_AREA_CODE,chr(10),' ')"
,TEL_PHONE_NUMBER "replace(:TEL_PHONE_NUMBER,chr(10),' ')"
,TEL_PRIMARY_FLAG           
, SEQ_NUM        RECNUM
, CREATION_DATE  SYSDATE
, REQUEST_ID     CONSTANT $P_REQUEST_ID
)