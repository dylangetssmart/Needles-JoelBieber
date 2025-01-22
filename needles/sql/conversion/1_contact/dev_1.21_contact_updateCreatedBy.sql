/*
update user created by and modified by now that users exist

*/
SELECT * FROM sma_MST_IndvContacts 
SELECT * FROM sma_MST_Users smu

update sma_MST_IndvContacts
set cinnRecUserID = (
	select u.usrnUserID
	from sma_MST_Users u
	join sma_MST_IndvContacts indv
	on indv.cinnContactID = u.usrnContactID	
)
--case
--	when cte.contact_type = 'Clerk'
--		then (
--				select
--					octnOrigContactTypeID
--				from [dbo].[sma_MST_OriginalContactTypes]
--				where octsDscrptn = 'Law Clerk'
--					and octnContactCtgID = 1
--			)
--end
from sma_MST_IndvContacts ind
join JoelBieberNeedles..names n
on n.names_id = ind.saga
--join cte_indv_contacts cte
--	on indv.saga = cte.names_id

-----------------------------------------------------------------------------------------------
-- update org

;with cte_org_contacts
as
(
	select
		names_id as names_id,
		'Court' as contact_type
	from JoelBieberNeedles..user_case_data ucd
	join JoelBieberNeedles..user_case_fields ucf
		on ucf.field_title = 'Court'
	join JoelBieberNeedles..user_case_name ucn
		on ucn.ref_num = ucf.field_num
		and ucd.casenum = ucn.casenum
	join JoelBieberNeedles..names n
		on n.names_id = ucn.user_name
	where ISNULL(ucd.COURT, '') <> ''

)

update sma_MST_OrgContacts
set connContactTypeID =
--case
--	when cte.contact_type = 'Court'
--		then (
--				select
--					octnOrigContactTypeID
--				from [dbo].[sma_MST_OriginalContactTypes]
--				where octsDscrptn = 'Court'
--					and octnContactCtgID = 1
--			)
--end
from sma_MST_OrgContacts org
join cte_org_contacts cte
	on org.saga = cte.names_id
