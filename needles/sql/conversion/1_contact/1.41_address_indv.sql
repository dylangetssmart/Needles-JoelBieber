USE JoelBieberSA_Needles
GO
/*
alter table [sma_MST_Address] disable trigger all
delete from [sma_MST_Address] 
DBCC CHECKIDENT ('[sma_MST_Address]', RESEED, 0);
alter table [sma_MST_Address] enable trigger all
*/
-- select distinct addr_Type from  [JoelBieberNeedles].[dbo].[multi_addresses]
-- select * from  [JoelBieberNeedles].[dbo].[multi_addresses] where addr_type not in ('Home','business', 'other')

ALTER TABLE [sma_MST_Address] DISABLE TRIGGER ALL
GO

-----------------------------------------------------------------------------
----(1)--- CONSTRUCT SMA_MST_ADDRESS FROM EXISTING SMA_MST_INDVCONTACTS
-----------------------------------------------------------------------------
 
 -- Home from IndvContacts
 INSERT INTO [sma_MST_Address]
 (
	[addnContactCtgID]
	,[addnContactID]
	,[addnAddressTypeID]
	,[addsAddressType]
	,[addsAddTypeCode]
	,[addsAddress1]
	,[addsAddress2]
	,[addsAddress3]
	,[addsStateCode]
	,[addsCity]
	,[addnZipID]
	,[addsZip]
	,[addsCounty]
	,[addsCountry]
	,[addbIsResidence]
	,[addbPrimary]
	,[adddFromDate]
	,[adddToDate]
	,[addnCompanyID]
	,[addsDepartment]
	,[addsTitle]
	,[addnContactPersonID]
	,[addsComments]
	,[addbIsCurrent]
	,[addbIsMailing]
	,[addnRecUserID]
	,[adddDtCreated]
	,[addnModifyUserID]
	,[adddDtModified]
	,[addnLevelNo]
	,[caseno]
	,[addbDeleted]
	,[addsZipExtn]
	,[saga]
)
SELECT 
	I.cinnContactCtg		as addnContactCtgID,
	I.cinnContactID			as addnContactID,
	T.addnAddTypeID			as addnAddressTypeID, 
	T.addsDscrptn			as addsAddressType,
	T.addsCode				as addsAddTypeCode,
	A.[address]				as addsAddress1,
	A.[address_2]			as addsAddress2,
	NULL					as addsAddress3,
	A.[state]				as addsStateCode,
	A.[city]				as addsCity,
	NULL					as addnZipID,
	A.[zipcode]				as addsZip,
	A.[county]				as addsCounty,
	A.[country]				as addsCountry,
	null					as addbIsResidence,
	case 
		when A.[default_addr]='Y' then 1 
		else 0
	end						as addbPrimary,
	null,null,null,null,null,null,
	case
	  when isnull(A.company,'')<>'' then (
		'Company : ' + CHAR(13) + A.company
	  )
	  else '' 		    
	end						as [addsComments],
	null,null,
	368						as addnRecUserID,
	getdate()				as adddDtCreated,
	368						as addnModifyUserID,
	getdate()				as adddDtModified,
	null,null,null,null,null
FROM [JoelBieberNeedles].[dbo].[multi_addresses] A
JOIN [sma_MST_Indvcontacts] I on I.saga = A.names_id
JOIN [sma_MST_AddressTypes] T on T.addnContactCategoryID = I.cinnContactCtg and T.addsCode='HM'
WHERE (A.[addr_type]='Home' and ( isnull(A.[address],'')<>'' or isnull(A.[address_2],'')<>'' or isnull( A.[city],'')<>'' or isnull(A.[state],'')<>'' or isnull(A.[zipcode],'')<>'' or isnull(A.[county],'')<>'' or isnull(A.[country],'')<>''))   
 
 -- Business from IndvContacts
INSERT INTO [sma_MST_Address] (
		[addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],
		[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],
		[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga]
)
SELECT 
	I.cinnContactCtg		as addnContactCtgID,
	I.cinnContactID			as addnContactID,
	T.addnAddTypeID			as addnAddressTypeID, 
	T.addsDscrptn			as addsAddressType,
	T.addsCode				as addsAddTypeCode,
	A.[address]				as addsAddress1,
	A.[address_2]			as addsAddress2,
	NULL					as addsAddress3,
	A.[state]				as addsStateCode,
	A.[city]				as addsCity,
	NULL					as addnZipID,
	A.[zipcode]				as addsZip,
	A.[county]				as addsCounty,
	A.[country]				as addsCountry,
	null					as addbIsResidence,
	case 
		when A.[default_addr]='Y' then 1 
		else 0 
	end						as addbPrimary,
	null,
	null,
	null,
	null,
	null,
	null,
	case
		when isnull(A.company,'')<>'' then (
			'Company : ' + CHAR(13) + A.company
		)	
		else '' 		    
	end						as [addsComments],
	null,null,
	368						as addnRecUserID,
	getdate()				as adddDtCreated,
	368						as addnModifyUserID,
	getdate()				as adddDtModified,
	null,
	null,
	null,
	null,
	null
FROM [JoelBieberNeedles].[dbo].[multi_addresses] A
JOIN [sma_MST_Indvcontacts] I on I.saga = A.names_id
JOIN [sma_MST_AddressTypes] T on T.addnContactCategoryID = I.cinnContactCtg and T.addsCode='WORK'
WHERE (A.[addr_type]='Business' and ( isnull(A.[address],'')<>'' or isnull(A.[address_2],'')<>'' or isnull( A.[city],'')<>'' or isnull(A.[state],'')<>'' or isnull(A.[zipcode],'')<>'' or isnull(A.[county],'')<>'' or isnull(A.[country],'')<>''))   
 
-- Other from IndvContacts
INSERT INTO [sma_MST_Address] (
		[addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],
		[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],
		[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga]
)
SELECT 
	I.cinnContactCtg		as addnContactCtgID,
	I.cinnContactID			as addnContactID,
	T.addnAddTypeID			as addnAddressTypeID, 
	T.addsDscrptn			as addsAddressType,
	T.addsCode				as addsAddTypeCode,
	A.[address]				as addsAddress1,
	A.[address_2]			as addsAddress2,
	NULL					as addsAddress3,
	A.[state]				as addsStateCode,
	A.[city]				as addsCity,
	NULL					as addnZipID,
	A.[zipcode]				as addsZip,
	A.[county]				as addsCounty,
	A.[country]				as addsCountry,
	null					as addbIsResidence,
	case when A.[default_addr]='Y' then 1
		else 0
	end						as addbPrimary,
	null,
	null,
	null,
	null,
	null,
	null,
	case
	  when isnull(A.company,'')<>'' then (
			'Company : ' + CHAR(13) + A.company
		)
	  else '' 		    
	end						as [addsComments],
	null,
	null,
	368						as addnRecUserID,
	getdate()				as adddDtCreated,
	368						as addnModifyUserID,
	getdate()				as adddDtModified,
	null,
	null,
	null,
	null,
	null
FROM [JoelBieberNeedles].[dbo].[multi_addresses] A
JOIN [sma_MST_Indvcontacts] I on I.saga = A.names_id
JOIN [sma_MST_AddressTypes] T on T.addnContactCategoryID = I.cinnContactCtg and T.addsCode='OTH'
WHERE (A.[addr_type]='Other' and ( isnull(A.[address],'')<>'' or isnull(A.[address_2],'')<>'' or isnull( A.[city],'')<>'' or isnull(A.[state],'')<>'' or isnull(A.[zipcode],'')<>'' or isnull(A.[county],'')<>'' or isnull(A.[country],'')<>''))   
 

---
ALTER TABLE [sma_MST_Address] ENABLE TRIGGER ALL
GO
---



------------- Check Uniqueness------------
-- select I.cinnContactID
-- 	 from [SA].[dbo].[sma_MST_Indvcontacts] I 
--	 inner join [SA].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
--	 group by cinnContactID
--	 having count(cinnContactID)>1

-- select O.connContactID
-- 	 from [SA].[dbo].[sma_MST_OrgContacts] O 
--	 inner join [SA].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1 
--	 group by connContactID
--	 having count(connContactID)>1

