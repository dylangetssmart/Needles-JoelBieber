use JoelBieberSA_Needles
go

/*
alter table [sma_MST_Address] disable trigger all
delete from [sma_MST_Address] 
DBCC CHECKIDENT ('[sma_MST_Address]', RESEED, 0);
alter table [sma_MST_Address] enable trigger all
*/
-- select distinct addr_Type from  [JoelBieberNeedles].[dbo].[multi_addresses]
-- select * from  [JoelBieberNeedles].[dbo].[multi_addresses] where addr_type not in ('Home','business', 'other')

alter table [sma_MST_Address] disable trigger all
go

----(APPENDIX)----
update [sma_MST_Address]
set addbPrimary = 1
from (
	select
		i.cinnContactID as cid,
		a.addnAddressID as aid,
		ROW_NUMBER() over (partition by i.cinnContactID order by a.addnAddressID asc) as rownumber
	from [sma_MST_Indvcontacts] i
	join [sma_MST_Address] a
		on a.addnContactID = i.cinnContactID
		and a.addnContactCtgID = i.cinnContactCtg
		and a.addbPrimary <> 1
	where i.cinnContactID not in (
			select
				i.cinnContactID
			from [sma_MST_Indvcontacts] i
			join [sma_MST_Address] a
				on a.addnContactID = i.cinnContactID
				and a.addnContactCtgID = i.cinnContactCtg
				and a.addbPrimary = 1
		)
) a
where a.rownumber = 1
and a.aid = addnAddressID

update [sma_MST_Address]
set addbPrimary = 1
from (
	select
		o.connContactID as cid,
		a.addnAddressID as aid,
		ROW_NUMBER() over (partition by o.connContactID order by a.addnAddressID asc) as rownumber
	from [sma_MST_OrgContacts] o
	join [sma_MST_Address] a
		on a.addnContactID = o.connContactID
		and a.addnContactCtgID = o.connContactCtg
		and a.addbPrimary <> 1
	where o.connContactID not in (
			select
				o.connContactID
			from [sma_MST_OrgContacts] o
			join [sma_MST_Address] a
				on a.addnContactID = o.connContactID
				and a.addnContactCtgID = o.connContactCtg
				and a.addbPrimary = 1
		)
) a
where a.rownumber = 1
and a.aid = addnAddressID


---
alter table [sma_MST_Address] enable trigger all
go
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

