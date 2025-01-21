/* ###################################################################################
description: Handle all operations related to [sma_MST_IndvContacts]
steps:
	- insert from staff
usage_instructions:
	-
dependencies:
	- 
notes:
	-
source: [staff]
target: [sma_MST_IndvContacts]
saga: saga_char
*/

use JoelBieberSA_Needles
go

alter table [sma_MST_IndvContacts] disable trigger all
go

/* --------------------------------------------------------------------------------------------------------------
- Insert from [staff]
*/
insert into [sma_MST_IndvContacts]
	(
	[cinsPrefix],
	[cinsSuffix],
	[cinsFirstName],
	[cinsMiddleName],
	[cinsLastName],
	[cinsHomePhone],
	[cinsWorkPhone],
	[cinsSSNNo],
	[cindBirthDate],
	[cindDateOfDeath],
	[cinnGender],
	[cinsMobile],
	[cinsComments],
	[cinnContactCtg],
	[cinnContactTypeID],
	[cinnRecUserID],
	[cindDtCreated],
	[cinbStatus],
	[cinbPreventMailing],
	[cinsNickName],
	[saga],
	[source_id_1],
	[source_id_2],
	[source_id_3]
	)
	select
		LEFT(s.prefix, 20)											 as [cinsprefix],
		LEFT(s.suffix, 10)											 as [cinssuffix],
		LEFT(ISNULL(first_name, dbo.get_firstword(s.full_name)), 30) as [cinsfirstname],
		LEFT(s.middle_name, 100)									 as [cinsmiddlename],
		LEFT(ISNULL(last_name, dbo.get_lastword(s.full_name)), 40)	 as [cinslastname],
		null														 as [cinshomephone],
		LEFT(s.phone_number, 20)									 as [cinsworkphone],
		null														 as [cinsssnno],
		null														 as [cindbirthdate],
		null														 as [cinddateofdeath],
		case s.sex
			when 'M'
				then 1
			when 'F'
				then 2
			else 0
		end															 as [cinngender],
		LEFT(s.mobil_phone, 20)										 as [cinsmobile],
		null														 as [cinscomments],
		1															 as [cinncontactctg],
		(
			select
				octnOrigContactTypeID
			from sma_MST_OriginalContactTypes
			where octsDscrptn = 'General'
				and octnContactCtgID = 1
		)															 as [cinncontacttypeid],
		368															 as [cinnrecuserid],
		GETDATE()													 as [cinddtcreated],
		1															 as [cinbstatus],
		0															 as [cinbpreventmailing],
		CONVERT(VARCHAR(15), s.full_name)							 as [cinsnickname],
		null														 as [saga],
		s.staff_code												 as [source_id_1],
		'needles'													 as [source_id_2],
		'staff'														 as [source_id_3]
	from [JoelBieberNeedles].[dbo].[staff] s
	left join [sma_MST_IndvContacts] ic
		on ic.source_id_1 = s.staff_code
	where cinnContactID is null
go

alter table [sma_MST_IndvContacts] enable trigger all
go