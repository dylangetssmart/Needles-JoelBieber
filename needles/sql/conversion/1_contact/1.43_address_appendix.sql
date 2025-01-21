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

----(APPENDIX)----
UPDATE [sma_MST_Address] SET addbPrimary=1
FROM ( 
	SELECT 
		I.cinnContactID	as CID,
		A.addnAddressID as AID,
		ROW_NUMBER() OVER(PARTITION BY I.cinnContactID ORDER BY A.addnAddressID ASC) as RowNumber
	FROM [sma_MST_Indvcontacts] I 
	JOIN [sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary<>1 
	WHERE I.cinnContactID not in ( 
			SELECT I.cinnContactID
			FROM [sma_MST_Indvcontacts] I 
			JOIN [sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
			)
) A 
WHERE A.RowNumber=1
and A.AID=addnAddressID

UPDATE [sma_MST_Address] 
SET addbPrimary=1
FROM
( 
	 SELECT 
		O.connContactID	as CID,
		A.addnAddressID as AID,
		ROW_NUMBER() OVER(PARTITION BY O.connContactID ORDER BY A.addnAddressID ASC) as RowNumber
	 FROM [sma_MST_OrgContacts] O 
	 JOIN [sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary<>1 
	 WHERE O.connContactID NOT IN ( 
			 SELECT O.connContactID
			 FROM [sma_MST_OrgContacts] O 
			 JOIN [sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1 
			)
) A 
WHERE A.RowNumber=1
and A.AID=addnAddressID

 
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

