<?xml version="1.0" encoding="UTF-8"?>
<!-- +======================================================================+ -->
<!-- |    Copyright (c) 2005, 2013 Oracle and/or its affiliates.           | -->
<!-- |                         All rights reserved.                         | -->
<!-- |                           Version 12.0.0                             | -->
<!-- +======================================================================+ -->
<!--  $Header: IBY_ISO_CT_CORE_V3_USTD.xsl 120.0.12020000.3 2013/11/07 17:02:22 sgogula noship $   -->
<!--  $Header: XXAP_IBY_HSBC_ACH.xsl       1.0              2020/12/14 00:00:00 dsah    noship $   -->
<!--  dbdrv: exec java oracle/apps/xdo/oa/util XDOLoader.class java &phase=dat checkfile:~PROD:patch/115/publisher/templates:IBY_ISO_CT_CORE_V3_USTD.xsl UPLOAD -DB_USERNAME &un_apps -DB_PASSWORD &pw_apps -JDBC_CONNECTION &jdbc_db_addr -LOB_TYPE TEMPLATE -APPS_SHORT_NAME IBY -LOB_CODE IBY_ISO_CT_001.001.03_USTRD -LANGUAGE en -XDO_FILE_TYPE XSL-XML -FILE_NAME &fullpath:~PROD:patch/115/publisher/templates:IBY_ISO_CT_CORE_V3_USTD.xsl -->

<!-- 
==================================================================================================================
* Customizations
*   Used for HSBCNet payment (ICO)
*
* Change History
* 10/12/2020 DASH Henry Wong       Initial Version
* 
*
======================================================================================================================
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template name="BANK_INSTRUCTIONS">
    <xsl:param name="NODE"/>
    <xsl:for-each select="$NODE/Extend">
      <xsl:if test="Name='BANK_INSTRUCTION'">
        <xsl:value-of select="substring(Value,1,140)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <xsl:output omit-xml-declaration="no"/>
  <xsl:output method="xml"/>
  <xsl:key name="contacts-by-LogicalGroupReference" match="OutboundPayment" use="PaymentNumber/LogicalGroupReference" />
  <xsl:template match="OutboundPaymentInstruction">
    <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="instrid" select="PaymentInstructionInfo/InstructionReferenceNumber"/>

    <Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

      <CstmrCdtTrfInitn>
        <!-- Group Header start -->
		<GrpHdr>
          <MsgId>
            <xsl:value-of select="$instrid"/>
          </MsgId>
          <CreDtTm>
            <xsl:value-of select="PaymentInstructionInfo/InstructionCreationDate"/>
          </CreDtTm>
          <Authstn>
            <Cd>ILEV</Cd>
          </Authstn>
          <NbOfTxs>
            <xsl:value-of select="InstructionTotals/PaymentCount"/>
          </NbOfTxs>
          <CtrlSum>
            <xsl:value-of select="format-number(sum(OutboundPayment/PaymentAmount/Value), '##0.00')" />
          </CtrlSum>
          <InitgPty>
            <Id>
              <OrgId>
                <Othr>
                  <Id>ABC20320001</Id>
                </Othr>
              </OrgId>
            </Id>
          </InitgPty>
        </GrpHdr>
        <!-- Group Header end -->
        <!-- Payment Information Start -->
        <xsl:for-each select="OutboundPayment[count(. | key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference)[1]) = 1]">
          <xsl:sort select="PaymentNumber/LogicalGroupReference"/>
          <PmtInf>
            <PmtInfId>
              <xsl:value-of select="$instrid"/>
            </PmtInfId>
            <PmtMtd>TRF</PmtMtd>
            <BtchBookg>
              <xsl:choose>
                <xsl:when test="contains(/OutboundPaymentInstruction/PaymentProcessProfile/BatchBookingFlag,'N')">
                  <xsl:text>false</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>true</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </BtchBookg>
            <NbOfTxs>
              <xsl:value-of select="count(key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference))" />
            </NbOfTxs>
            <CtrlSum>
              <xsl:value-of select="format-number(sum(key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference)/PaymentAmount/Value),'#.00')" />
            </CtrlSum>
			
            <PmtTpInf>
			  <!-- copy InstrPrty from HSBC sample TT xml file -->
			  <InstrPrty>NORM</InstrPrty>
              <SvcLvl> <!-- copy from example -->
                <Cd>URGP</Cd>
              </SvcLvl>
            </PmtTpInf>
		    <!-- ok --> 	
            <ReqdExctnDt>
              <xsl:value-of select="PaymentDate"/>
            </ReqdExctnDt>
      
	  
            <Dbtr>
			  <!-- Debit Name OK -->
              <Nm>
                <xsl:choose>
                  <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME'])=0) and not(translate(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME']/Value,$lower,$upper) = 'NA') and not(DocumentPayable/Extend[Name='ALT_BANK_AC_NAME']/Value='Y')">
                    <xsl:value-of select="substring(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME']/Value,1,140)" />
                  </xsl:when>
                  <xsl:when test="(DocumentPayable/Extend[Name='ALT_BANK_AC_NAME']/Value='Y')">
                    <xsl:value-of select="substring(BankAccount/AlternateBankAccountName,1,140)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="substring(Payer/Name,1,140)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </Nm>
			  
              <!-- Debit Address  -->
              <PstlAdr>
				<!--  StrtNm is address 1 + address 2 to be add -->
				<xsl:if	test="not(Payer/Address/AddressLine1='') or not(Payer/Address/AddressLine2='')">
					<StrtNm>
						<xsl:value-of select="normalize-space(substring(concat(concat(Payer/Address/AddressLine1,' '),Payer/Address/AddressLine2),1,70))"/>
					</StrtNm>
				</xsl:if>
				
										
				<xsl:if	test="not(Payer/Address/PostalCode='')">
					  <PstCd>
						<xsl:value-of select="substring(Payer/Address/PostalCode,1,16)"/>
					  </PstCd>
				</xsl:if>	

				<!--  TwnNm is address 3 + address 4 to be add -->
				<xsl:if	test="not(Payer/Address/AddressLine3='') or not(Payer/Address/AddressLine4='')">
					<TwnNm>
						<xsl:value-of select="normalize-space(substring(concat(concat(Payer/Address/AddressLine3,' '),Payer/Address/AddressLine4),1,70))"/>
					</TwnNm>
				</xsl:if>
				
				<xsl:if	test="not(Payer/Address/City='')">
				  <CtrySubDvsn>
					<xsl:value-of select="substring(Payer/Address/City,1,35)"/>
				  </CtrySubDvsn>
				</xsl:if>					
				
				<xsl:if	test="not(Payer/Address/Country='')">
					<Ctry>
					   <xsl:value-of select="substring(Payer/Address/Country,1,2)"/>
					</Ctry>
				</xsl:if>				
                <!-- Include check for if PROVINCE does not exist in file -->
				<!--
                <xsl:if test="not(Payer/Address/County='') or not(Payer/Address/State='') or ((Payer/Address/Province) and not (Payer/Address/Province=''))">
                  <CtrySubDvsn>
                    <xsl:choose>
                      <xsl:when test="not(Payer/Address/State='')">
                        <xsl:value-of select="Payer/Address/State"/>
                      </xsl:when>
                      <xsl:when test="(Payer/Address/Province) and not (Payer/Address/Province='')">
                        <xsl:value-of select="Payer/Address/Province"/>
                      </xsl:when>
                      <xsl:when test="not(Payer/Address/County='')">
                        <xsl:value-of select="Payer/Address/County"/>
                      </xsl:when>
                    </xsl:choose>
                  </CtrySubDvsn>
                </xsl:if>
				-->
              </PstlAdr>
              <!-- Debtor Address  END -->
             </Dbtr>
			<!-- Debtor Account -->    
            <DbtrAcct>
              <Id>
                <xsl:if test="not(BankAccount/IBANNumber='')">
                  <IBAN>
                    <xsl:value-of select="BankAccount/IBANNumber"/>
                  </IBAN>
                </xsl:if>
                <!-- if no IBAN, use bank account number-->
                <xsl:if test="(BankAccount/IBANNumber='')">
                  <Othr>
                    <Id>
                      <xsl:value-of select="concat(BankAccount/BranchNumber,BankAccount/BankAccountNumber)"/>
                    </Id>
                  </Othr>
                </xsl:if>
              </Id>
          
              <!-- ONLY include for SEPA transactions -->
              <xsl:if test="not(BankAccount/BankAccountType/Code='') and not(ServiceLevel/FormatValue='SEPA')">
                <Tp>
                  <Cd>
                    <xsl:value-of select="BankAccount/BankAccountType/Code"/>
                  </Cd>
                </Tp>
              </xsl:if>
			  
              <Ccy>
                <xsl:value-of select="BankAccount/BankAccountCurrency/Code"/>
              </Ccy>
            </DbtrAcct>
            <!-- Debtor Account END -->    
			
			<!-- Debtor Agent -->    
            <DbtrAgt>
              <FinInstnId>
                <xsl:if test="not(BankAccount/SwiftCode='')">
                  <BIC>
                    <xsl:value-of select="BankAccount/SwiftCode"/>
                  </BIC>
                </xsl:if>

                <!-- MRL REMOVE xsl:if test="(BankAccount/SwiftCode='')"-->
				<!--
                  <xsl:if test="not(BankAccount/BankNumber='')">
                    <ClrSysMmbId>
                      <MmbId>
                        <xsl:value-of select="BankAccount/BankNumber"/>
                      </MmbId>
                    </ClrSysMmbId>
                  </xsl:if>
				-->
                <!-- MRL REMOVE /xsl:if -->
                <xsl:if test="not(BankAccount/BankAddress/Country='')">
                  <PstlAdr>
                    <Ctry>
                      <xsl:value-of select="BankAccount/BankAddress/Country"/>
                    </Ctry>
                  </PstlAdr>
                </xsl:if>
              </FinInstnId>
            </DbtrAgt>
            <!-- Debtor Agent END -->     

            <!-- Charge Bearer END -->     
            <xsl:for-each select="key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference)">
              <CdtTrfTxInf>
                <xsl:variable name="paymentdetails" select="PaymentDetails"/>
                <PmtId>
                  <InstrId>
                    <xsl:value-of select="PaymentNumber/PaymentReferenceNumber" />
                  </InstrId>
                  <EndToEndId>
                    <xsl:value-of select="PaymentNumber/PaymentReferenceNumber" />
                  </EndToEndId>
                </PmtId>
                <Amt>
                  <InstdAmt>
                    <xsl:attribute name="Ccy">
                      <xsl:value-of select="PaymentAmount/Currency/Code"/>
                    </xsl:attribute>
                    <xsl:value-of select="format-number(PaymentAmount/Value,'#.00')"/>
                  </InstdAmt>
                </Amt>
				<ChrgBr>DEBT</ChrgBr>

                <CdtrAgt>
                  <FinInstnId>
					<xsl:if test="not(PayeeBankAccount/SwiftCode='')">
					  <BIC>
						<xsl:value-of select="PayeeBankAccount/SwiftCode"/>
					  </BIC>
					</xsl:if>
                    <PstlAdr>
                      <Ctry><xsl:value-of select="PayeeBankAccount/BankAddress/Country"/></Ctry>
                    </PstlAdr>
                  </FinInstnId>
                </CdtrAgt>               

                <Cdtr>
				
                  <Nm>
                    <!-- <xsl:value-of select="substring(translate(Payee/Name,'òáéíúñü', 'oaeiunu'),1,20)"/> 20210531 Show Payee Bank Account Name rahter than Payee Name -->
					<!-- <xsl:value-of select="substring(PayeeBankAccount/BankAccountName,1,140)"/> 20210615 if back account name is null show payee name-->
					<xsl:choose>
						<xsl:when test="not(string(PayeeBankAccount/BankAccountName))">
							<xsl:value-of select="substring(Payee/Name,1,140)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring(PayeeBankAccount/BankAccountName,1,140)" />
						</xsl:otherwise>
					</xsl:choose>						
                  </Nm>
                  <PstlAdr>
						<!--  StrtNm is address 1 + address 2 to be add -->
						<xsl:if	test="not(Payee/Address/AddressLine1='') or not(Payee/Address/AddressLine2='')">
							<StrtNm>
								<xsl:value-of select="normalize-space(substring(concat(concat(Payee/Address/AddressLine1,' '),Payee/Address/AddressLine2),1,70))"/>
							</StrtNm>
						</xsl:if>
						
												
						<xsl:if	test="not(Payee/Address/PostalCode='')">
							  <PstCd>
								<xsl:value-of select="substring(Payee/Address/PostalCode,1,16)"/>
							  </PstCd>
						</xsl:if>	

						<!--  TwnNm is address 3 + address 4 to be add -->
						<xsl:if	test="not(Payee/Address/AddressLine3='') or not(Payee/Address/AddressLine4='')">
							<TwnNm>
								<xsl:value-of select="normalize-space(substring(concat(concat(Payee/Address/AddressLine3,' '),Payee/Address/AddressLine4),1,70))"/>
							</TwnNm>
						</xsl:if>
						
						<xsl:if	test="not(Payee/Address/City='')">
						  <CtrySubDvsn>
							<xsl:value-of select="substring(Payee/Address/City,1,35)"/>
						  </CtrySubDvsn>
						</xsl:if>					
						
						<xsl:if	test="not(Payee/Address/Country='')">
							<Ctry>
							   <xsl:value-of select="substring(Payee/Address/Country,1,2)"/>
							</Ctry>
						</xsl:if>
                  </PstlAdr>
                </Cdtr>

                <CdtrAcct> <!-- ok -->
				  <Id>
				    <Othr>
					  <Id>
					    <xsl:value-of select="concat(substring(PayeeBankAccount/BranchNumber,4,3),PayeeBankAccount/BankAccountNumber)"/>
					  </Id>
					</Othr>
				  </Id>
                </CdtrAcct>
				<xsl:if	test="not(Payee/ContactInfo/ContactLocators/EmailAddress='')">
					<RltdRmtInf>             
						   <RmtLctnMtd>EMAL</RmtLctnMtd>             
						   <RmtLctnElctrncAdr>
									<xsl:value-of select="Payee/ContactInfo/ContactLocators/EmailAddress"/>
						   </RmtLctnElctrncAdr>
					</RltdRmtInf> 
					<RmtInf>
							<Ustrd> <!-- Related Remittance Information .. TBC --> 
									<xsl:value-of select="substring(Extend/XXALL_INVOICES_PAID,1,140)"/>
							</Ustrd>
					</RmtInf>
				</xsl:if>					

              </CdtTrfTxInf>
            </xsl:for-each>
          </PmtInf>
        </xsl:for-each>
		<!-- Payment Information End -->
      </CstmrCdtTrfInitn>
    </Document>
  </xsl:template>

</xsl:stylesheet>
