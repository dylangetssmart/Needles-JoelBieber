/* ###################################################################################
description: update contact email addresses
steps:
	-
usage_instructions:
	-
dependencies:
	- 
notes:
	-
######################################################################################
*/

use [JohnSalazar_SA]
go

/*
alter table [sma_MST_EmailWebsite] disable trigger all
delete from [sma_MST_EmailWebsite] 
DBCC CHECKIDENT ('[sma_MST_EmailWebsite]', RESEED, 0);
alter table [sma_MST_EmailWebsite] enable trigger all
*/

---
alter table [sma_MST_EmailWebsite] disable trigger all
go

---------------------------------------------------------------------
----- (1/3) CONSTRUCT SMA_MST_EMAILWEBSITE FOR INDIVIDUAL -
---------------------------------------------------------------------

-- Email
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID], [cewnContactID], [cewsEmailWebsiteFlag], [cewsEmailWebSite], [cewbDefault], [cewnRecUserID], [cewdDtCreated], [cewnModifyUserID], [cewdDtModified], [cewnLevelNo], [saga]
	)
	select
		c.cinnContactCtg as cewncontactctgid,
		c.cinnContactID	 as cewncontactid,
		'E'				 as cewsemailwebsiteflag,
		n.email			 as cewsemailwebsite,
		null			 as cewbdefault,
		368				 as cewnrecuserid,
		GETDATE()		 as cewddtcreated,
		368				 as cewnmodifyuserid,
		GETDATE()		 as cewddtmodified,
		null			 as cewnlevelno,
		1				 as saga -- indicate email
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	where ISNULL(email, '') <> ''


-- Work Email
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID], [cewnContactID], [cewsEmailWebsiteFlag], [cewsEmailWebSite], [cewbDefault], [cewnRecUserID], [cewdDtCreated], [cewnModifyUserID], [cewdDtModified], [cewnLevelNo], [saga]
	)
	select
		c.cinnContactCtg as cewncontactctgid,
		c.cinnContactID	 as cewncontactid,
		'E'				 as cewsemailwebsiteflag,
		n.email_work	 as cewsemailwebsite,
		null			 as cewbdefault,
		368				 as cewnrecuserid,
		GETDATE()		 as cewddtcreated,
		368				 as cewnmodifyuserid,
		GETDATE()		 as cewddtmodified,
		null			 as cewnlevelno,
		2				 as saga -- indicate email_work
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	where ISNULL(email_work, '') <> ''


-- Other Email
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID], [cewnContactID], [cewsEmailWebsiteFlag], [cewsEmailWebSite], [cewbDefault], [cewnRecUserID], [cewdDtCreated], [cewnModifyUserID], [cewdDtModified], [cewnLevelNo], [saga]
	)
	select
		c.cinnContactCtg as cewncontactctgid,
		c.cinnContactID	 as cewncontactid,
		'E'				 as cewsemailwebsiteflag,
		n.other_email	 as cewsemailwebsite,
		null			 as cewbdefault,
		368				 as cewnrecuserid,
		GETDATE()		 as cewddtcreated,
		368				 as cewnmodifyuserid,
		GETDATE()		 as cewddtmodified,
		null			 as cewnlevelno,
		3				 as saga -- indicate other_email
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	where ISNULL(other_email, '') <> ''


-- Website
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID], [cewnContactID], [cewsEmailWebsiteFlag], [cewsEmailWebSite], [cewbDefault], [cewnRecUserID], [cewdDtCreated], [cewnModifyUserID], [cewdDtModified], [cewnLevelNo], [saga]
	)
	select
		c.cinnContactCtg as cewncontactctgid,
		c.cinnContactID	 as cewncontactid,
		'W'				 as cewsemailwebsiteflag,
		n.website		 as cewsemailwebsite,
		null			 as cewbdefault,
		368				 as cewnrecuserid,
		GETDATE()		 as cewddtcreated,
		368				 as cewnmodifyuserid,
		GETDATE()		 as cewddtmodified,
		null			 as cewnlevelno,
		4				 as saga -- indicate website
	from [JohnSalazar_Needles].[dbo].[names] n
	join [sma_MST_IndvContacts] c
		on c.saga = n.names_id
	where ISNULL(website, '') <> ''

---------------------------------------
-- Insert [sma_MST_EmailWebsite] from [staff]
---------------------------------------
insert into [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID], [cewnContactID], [cewsEmailWebsiteFlag], [cewsEmailWebSite], [cewbDefault], [cewnRecUserID], [cewdDtCreated], [cewnModifyUserID], [cewdDtModified], [cewnLevelNo], [saga]
	)
	select
		ic.cinnContactCtg as cewncontactctgid,
		ic.cinnContactID	 as cewncontactid,
		'E'				 as cewsemailwebsiteflag,
		s.email			 as cewsemailwebsite,
		null			 as cewbdefault,
		368				 as cewnrecuserid,
		GETDATE()		 as cewddtcreated,
		368				 as cewnmodifyuserid,
		GETDATE()		 as cewddtmodified,
		null,
		1				 as saga -- indicate email
	from [JohnSalazar_Needles].[dbo].[staff] s
	join [sma_MST_IndvContacts] ic
		on ic.saga_char = s.staff_code
	--on c.cinsGrade = s.staff_code
	where ISNULL(email, '') <> ''