/*
update user created by and modified by now that users exist

*/

--select * from sma_MST_IndvContacts
--select * from sma_MST_Users smu

use JoelBieberSA_Needles
go

update sma_MST_IndvContacts
set cinnRecUserID = (
	select
		u.usrnUserID
	from sma_MST_Users u
	join sma_MST_IndvContacts indv
		on indv.cinnContactID = u.usrnContactID
)
from sma_MST_IndvContacts ind
join JoelBieberNeedles..names n
	on n.names_id = ind.saga


-----------------------------------------------------------------------------------------------
-- update org

--;with cte_org_contacts
--as
--(
--	select
--		names_id as names_id,
--		'Court' as contact_type
--	from JoelBieberNeedles..user_case_data ucd
--	join JoelBieberNeedles..user_case_fields ucf
--		on ucf.field_title = 'Court'
--	join JoelBieberNeedles..user_case_name ucn
--		on ucn.ref_num = ucf.field_num
--		and ucd.casenum = ucn.casenum
--	join JoelBieberNeedles..names n
--		on n.names_id = ucn.user_name
--	where ISNULL(ucd.COURT, '') <> ''

--)

--update sma_MST_OrgContacts
--set connContactTypeID =
----case
----	when cte.contact_type = 'Court'
----		then (
----				select
----					octnOrigContactTypeID
----				from [dbo].[sma_MST_OriginalContactTypes]
----				where octsDscrptn = 'Court'
----					and octnContactCtgID = 1
----			)
----end
--from sma_MST_OrgContacts org
--join cte_org_contacts cte
--	on org.saga = cte.names_id
