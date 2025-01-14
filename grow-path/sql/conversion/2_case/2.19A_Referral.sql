


/*



Non-Attorney Referral = Other Referral Name > sma_TRN_OtherReferral

Internet = Advertising Source > sma_TRN_PdAdvt
Advertisement = Advertising Source > sma_TRN_PdAdvt

Attorney Referral = Referring Attorney > sma_TRN_LawyerReferral
Attorney Referral = Referring Law Firm > sma_TRN_LawyerReferral


- caseid
- ioc.cid
- ioc.ctg
- ioc.aid

*/

------------------------------------------------------------
--use ShinerLitify
--GO

--litify_tso_Source_Type_Name__c


--litify_pm__Matter__c





--SELECT
--	lpsc.litify_tso_Source_Type_Name__c
--   ,COUNT(*) AS Count
--FROM ShinerLitify..litify_pm__Source__c lpsc
--GROUP BY lpsc.litify_tso_Source_Type_Name__c
--ORDER BY Count DESC;


-------------------------------------------------------------


USE ShinerSA
GO


-------------------------------------
--INSERT ADVERTISEMENT SOURCES
-------------------------------------
INSERT INTO sma_TRN_PdAdvt
	(
	advnCaseID
   ,advnSrcContactCtg
   ,advnSrcContactID
   ,advnSrcAddressID
   ,advnSubTypeID
   ,advnPlaintiffID
   ,advdDateTime
   ,advdRetainedDt
   ,advnFeeStruID
   ,advsComments
   ,advnRecUserID
   ,advdDtCreated
   ,advnModifyUserID
   ,advdDtModified
   ,advnRecordSource
	)
	SELECT
		cas.casnCaseID AS advnCaseID
	   ,ioc.CTG		   AS advnSrcContactCtg
	   ,ioc.CID		   AS advnSrcContactID
	   ,ioc.AID		   AS advnSrcAddressID
	   ,NULL		   AS advnSubTypeID
	   ,-1			   AS advnPlaintiffID
	   ,NULL		   AS advdDateTime
	   ,NULL		   AS advdRetainedDt
	   ,NULL		   AS advnFeeStruID
	   ,''			   AS advsComments
	   ,368			   AS advnRecUserID
	   ,GETDATE()	   AS advdDtCreated
	   ,NULL		   AS advnModifyUserID
	   ,NULL		   AS advdDtModified
	   ,0			   AS advnRecordSource
	--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
	FROM ShinerLitify..litify_pm__Matter__c m
	JOIN sma_TRN_Cases cas
		ON cas.saga_char = m.Id
	JOIN ShinerLitify..[litify_pm__Source__c] s
		ON m.litify_pm__Source__c = s.Id
	JOIN IndvOrgContacts_Indexed ioc
		ON ioc.saga_char = s.Id
	WHERE s.litify_tso_Source_Type_Name__c IN ('Advertisement', 'Internet')

--select * From sma_TRN_PdAdvt
------------------------------------
--ATTORNEY REFERRALS
------------------------------------
INSERT INTO sma_TRN_LawyerReferral
	(
	lwrnCaseID
   ,lwrnRefLawFrmContactID
   ,lwrnRefLawFrmAddressId
   ,lwrnAttContactID
   ,lwrnAttAddressID
   ,lwrnPlaintiffID
   ,lwrsComments
   ,lwrnUserID
   ,lwrdDtCreated
	)
	SELECT
		cas.casnCaseID AS lwrnCaseID
	   ,CASE
			WHEN ioc.CTG = 2
				THEN ioc.CID
			ELSE NULL
		END			   AS lwrnRefLawFrmContactID
	   ,CASE
			WHEN ioc.CTG = 2
				THEN ioc.AID
			ELSE NULL
		END			   AS lwrnRefLawFrmAddressId
	   ,CASE
			WHEN ioc.CTG = 1
				THEN ioc.CID
			ELSE NULL
		END			   AS lwrnAttContactID
	   ,CASE
			WHEN ioc.CTG = 1
				THEN ioc.AID
			ELSE NULL
		END			   AS lwrnAttAddressID
	   ,-1			   AS lwrnPlaintiffID
	   ,''			   AS lwrscomments
	   ,368			   AS lwrnuserid
	   ,GETDATE()	   AS lwrddtcreated
	--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
	FROM ShinerLitify..litify_pm__Matter__c m
	JOIN sma_TRN_Cases cas
		ON cas.saga_char = m.Id
	JOIN ShinerLitify..[litify_pm__Source__c] s
		ON m.litify_pm__Source__c = s.Id
	JOIN IndvOrgContacts_Indexed ioc
		ON ioc.saga_char = s.Id
	WHERE s.litify_tso_Source_Type_Name__c IN ('', 'Attorney Referral')

------------------------
--OTHER REFERRALS
------------------------
INSERT INTO sma_TRN_OtherReferral
	(
	otrnCaseID
   ,otrnRefContactCtg
   ,otrnRefContactID
   ,otrnRefAddressID
   ,otrnPlaintiffID
   ,otrsComments
   ,otrnUserID
   ,otrdDtCreated
	)
	SELECT
		cas.casnCaseID AS otrnCaseID
	   ,ioc.CTG		   AS otrnRefContactCtg
	   ,ioc.CID		   AS otrnRefContactID
	   ,ioc.AID		   AS otrnRefAddressID
	   ,-1			   AS otrnPlaintiffID
	   ,''			   AS otrsComments
	   ,368			   AS otrnUserID
	   ,GETDATE()	   AS otrdDtCreated
	--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
	FROM ShinerLitify..litify_pm__Matter__c m
	JOIN sma_TRN_Cases cas
		ON cas.saga_char = m.Id
	JOIN ShinerLitify..[litify_pm__Source__c] s
		ON m.litify_pm__Source__c = s.Id
	JOIN IndvOrgContacts_Indexed ioc
		ON ioc.saga_char = s.Id
	WHERE s.litify_tso_Source_Type_Name__c IN ('Non-Attorney Referral', 'Other')
GO


------------------------
--OTHER REFERRALS From Role
------------------------
INSERT INTO sma_TRN_OtherReferral
	(
	otrnCaseID
   ,otrnRefContactCtg
   ,otrnRefContactID
   ,otrnRefAddressID
   ,otrnPlaintiffID
   ,otrsComments
   ,otrnUserID
   ,otrdDtCreated
	)
	SELECT
		cas.casnCaseID AS otrnCaseID
	   ,ioc.CTG		   AS otrnRefContactCtg
	   ,ioc.CID		   AS otrnRefContactID
	   ,ioc.AID		   AS otrnRefAddressID
	   ,-1			   AS otrnPlaintiffID
	   ,''			   AS otrsComments
	   ,368			   AS otrnUserID
	   ,GETDATE()	   AS otrdDtCreated
	--select m.id,s.name, s.litify_tso_Source_Type_Name__c, s.*
	from ShinerLitify..litify_pm__Role__c lprc
	JOIN sma_TRN_Cases cas
	ON lprc.litify_pm__Matter__c = cas.saga_char
	JOIN IndvOrgContacts_Indexed ioc
	ON ioc.SAGA_char = lprc.litify_pm__Party__c
	WHERE litify_pm__role__c IN ('Referral')
GO