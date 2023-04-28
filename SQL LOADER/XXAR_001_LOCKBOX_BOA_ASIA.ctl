--
--FILENAME        XXAR_001_LOCKBOX_BOA_ASIA.ctl
--
--DESCRIPTION     SQL Loader script to load data file from BOA Bank into
--		   		  XXAR_PAYMENTS_INTERFACE
--
--
--
--USAGE           sqlldr userid/password @FILENAME
--
--CALLED BY
--
--NOTES
--
--HISTORY
--
-- Modified 8/20/2015 Jill Dileva
-- Changes for R12 and to make more consistent with rest of Lockbox proceses
-- Loading data into XXAR_PAYMENTS_INTERFACE not XXAR_BOA_PAYMENTS_INTERFACE

-- Loads BOA Bank Lockbox flat file
-- Format similar to BAI standard
-- CTL file based on Oracle's standard ardeft.ctl

LOAD DATA
REPLACE

-- Type 1 - Transmission Header

INTO TABLE XXAR_PAYMENTS_INTERFACE
WHEN RECORD_TYPE = '1'
 (TRANSMISSION_ID		CONSTANT '1',
 TRANSMISSION_RECORD_ID RECNUM,
 INPUT_STRING			POSITION(01:80) CHAR,
 RECORD_TYPE			POSITION(01:01) CHAR,
-- ORIGINATION			constant '6055',
 -- bank account number needs to stored and then replace it with origination number 6055 
 ORIGINATION			POSITION(04:11) CHAR,
-- DEPOSIT_DATE			BLANKS,
 --"to_char(sysdate,'RRMMDD')",
 --POSITION(12:17) DATE 'RRMMDD' 
--					NULLIF DEPOSIT_DATE=BLANKS,
--YDEPOSIT_TIME		    POSITION(18:21) CHAR,
-- DEPOSIT_TIME		    BLANKS,
 --"to_char(sysdate,'HHMM')",
 CREATION_DATE			sysdate,
 CREATED_BY				CONSTANT '-1',
 LAST_UPDATE_DATE		sysdate,
 LAST_UPDATED_BY		CONSTANT '-1')

-- Type 2 - Lockbox Header

INTO TABLE XXAR_PAYMENTS_INTERFACE
WHEN RECORD_TYPE = '2'
 (TRANSMISSION_ID		CONSTANT '1',--amish
 TRANSMISSION_RECORD_ID RECNUM,
 INPUT_STRING			POSITION(01:80) CHAR,
 RECORD_TYPE                  	POSITION(01:01) CHAR,
 --store bank account number and then replace it with lockbox number later
 LOCKBOX_NUMBER					POSITION(06:09) CHAR,
 DESTINATION_ACCOUNT            POSITION(02:11) CHAR,
 CREATION_DATE			sysdate,
 CREATED_BY				CONSTANT '-1',
 LAST_UPDATE_DATE		sysdate,
 LAST_UPDATED_BY		CONSTANT '-1')

-- Type 5 - Batch Header

INTO TABLE XXAR_PAYMENTS_INTERFACE
WHEN RECORD_TYPE = '5'
 (TRANSMISSION_ID		CONSTANT '1',
 TRANSMISSION_RECORD_ID RECNUM,
 INPUT_STRING			POSITION(01:80) CHAR,
 RECORD_TYPE			POSITION(01:01) CHAR,
 BATCH_NAME				POSITION(02:04) CHAR,
 LOCKBOX_NUMBER			POSITION(05:11) CHAR "SUBSTR(:LOCKBOX_NUMBER,8,4)",
-- DEPOSIT_DATE			POSITION(12:17) DATE 'RRMMDD' 
--					      NULLIF DEPOSIT_DATE=BLANKS,
-- ATTRIBUTE1				POSITION(18:22) CHAR,
 CREATION_DATE			sysdate, --amish
 CREATED_BY				CONSTANT '-1',
 LAST_UPDATE_DATE		sysdate,
 LAST_UPDATED_BY		CONSTANT '-1')

-- Type 6 - Detail Record

INTO TABLE XXAR_PAYMENTS_INTERFACE
WHEN RECORD_TYPE = '6'
 (TRANSMISSION_ID		CONSTANT '1',
 TRANSMISSION_RECORD_ID RECNUM,
 INPUT_STRING			POSITION(01:80) CHAR,
 RECORD_TYPE			POSITION(01:01) CHAR,
 BATCH_NAME			POSITION(02:04) CHAR,
 ITEM_NUMBER			POSITION(05:07) CHAR,
 REMITTANCE_AMOUNT		POSITION(08:17) CHAR,
 TRANSIT_ROUTING_NUMBER 	POSITION(18:26) CHAR,
 ACCOUNT			POSITION(27:36) CHAR,
 CHECK_NUMBER			POSITION(37:46) CHAR,
 --bank not sending receipt date
 --RECEIPT_DATE			POSITION(44:49) DATE 'RRMMDD'
--					NULLIF RECEIPT_DATE=BLANKS,
 --tid will be sent here for 34 char
 ATTRIBUTE2                     POSITION(66:90) CHAR,--amish tid
 CREATION_DATE			sysdate,
 CREATED_BY				CONSTANT '-1',
 LAST_UPDATE_DATE		sysdate,
 LAST_UPDATED_BY		CONSTANT '-1')

-- Type 4 - Overflow

INTO TABLE XXAR_PAYMENTS_INTERFACE
WHEN RECORD_TYPE = '4'
 (TRANSMISSION_ID		CONSTANT '1',
 TRANSMISSION_RECORD_ID RECNUM,
 INPUT_STRING			POSITION(01:80) CHAR,
 RECORD_TYPE			POSITION(01:01) CHAR,
 BATCH_NAME			POSITION(02:04) CHAR,
 ITEM_NUMBER			POSITION(05:07) CHAR,
 OVERFLOW_SEQUENCE		POSITION(09:10) CHAR,
 OVERFLOW_INDICATOR		POSITION(11:11) CHAR,
 INVOICE1			POSITION(12:27) CHAR,
 AMOUNT_APPLIED1	POSITION(28:37) CHAR,
-- INVOICE2			POSITION(34:45) CHAR,
-- AMOUNT_APPLIED2	POSITION(46:55) CHAR,
-- INVOICE3			POSITION(56:67) CHAR,
-- AMOUNT_APPLIED3	POSITION(68:77) CHAR,
 CREATION_DATE			sysdate,
 CREATED_BY				CONSTANT '-1',
 LAST_UPDATE_DATE		sysdate,
 LAST_UPDATED_BY		CONSTANT '-1')

-- Type 7 - Batch Trailer

INTO TABLE XXAR_PAYMENTS_INTERFACE
WHEN RECORD_TYPE = '7'
 (TRANSMISSION_ID		CONSTANT '1',
 TRANSMISSION_RECORD_ID RECNUM,
 INPUT_STRING			POSITION(01:80) CHAR,
 RECORD_TYPE			POSITION(01:01) CHAR,
 BATCH_NAME			POSITION(02:04) CHAR,
 --batch item '000' constant i ssent by the bank which is not needed
 LOCKBOX_NUMBER			POSITION(08:14) CHAR,
 DEPOSIT_DATE			POSITION(15:20) DATE 'RRMMDD'
					NULLIF DEPOSIT_DATE=BLANKS,
 BATCH_RECORD_COUNT		POSITION(21:23) CHAR,
 BATCH_AMOUNT			POSITION(24:33) CHAR,
 CREATION_DATE			sysdate,
 CREATED_BY				CONSTANT '-1',
 LAST_UPDATE_DATE		sysdate,
 LAST_UPDATED_BY		CONSTANT '-1')

-- Type 8 - Lockbox Trailer

INTO TABLE XXAR_PAYMENTS_INTERFACE
WHEN RECORD_TYPE = '8'
 (TRANSMISSION_ID		CONSTANT '1',
 TRANSMISSION_RECORD_ID RECNUM,
 INPUT_STRING			POSITION(01:80) CHAR,
 RECORD_TYPE			POSITION(01:01) CHAR,
 --bank sends batch number and constant item number '000' not needed
 LOCKBOX_NUMBER			POSITION(08:14) CHAR,
 DEPOSIT_DATE			POSITION(15:20) DATE 'RRMMDD'
					NULLIF DEPOSIT_DATE=BLANKS,
 LOCKBOX_RECORD_COUNT		POSITION(21:24) CHAR,
 LOCKBOX_AMOUNT			POSITION(25:34) CHAR ,
 --ignoring TM and MDT amount 
 CREATION_DATE			sysdate,
 CREATED_BY				CONSTANT '-1',
 LAST_UPDATE_DATE		sysdate,
 LAST_UPDATED_BY		CONSTANT '-1')

-- Type 9 - Transmission Trailer

INTO TABLE XXAR_PAYMENTS_INTERFACE
WHEN RECORD_TYPE = '9'
 (TRANSMISSION_ID		CONSTANT '1',
 TRANSMISSION_RECORD_ID RECNUM,
 INPUT_STRING			POSITION(01:80) CHAR,
 RECORD_TYPE			POSITION(01:01) CHAR,
 TRANSMISSION_RECORD_COUNT	POSITION(02:07) CHAR,
 CREATION_DATE			sysdate,
 CREATED_BY				CONSTANT '-1',
 LAST_UPDATE_DATE		sysdate,
 LAST_UPDATED_BY		CONSTANT '-1')
