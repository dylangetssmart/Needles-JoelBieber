SELECT * FROM PartyRoles pr
--EMPLOYER	(D)-EMPLOYER	DEFENDANT



SELECT * FROM sma_MST_SubRole smsr
-- 4 = pln
-- 5 = def


SELECT * FROM sma_MST_SubRole smsr where smsr.sbrsDscrptn like '%employer%'
--33008
--33046
--33089
--33094
--33138
--33167
--33189
--33198
--33209
--33236
--33286

SELECT * FROM sma_MST_SubRoleCode
SELECT * FROM sma_MST_SubRole smsr


SELECT *
FROM sma_TRN_Plaintiff pln
where pln.plnnRole in (
'33008',
'33046',
'33089',
'33094',
'33138',
'33167',
'33189',
'33198',
'33209',
'33236',
'33286'
)


select
				sbrnSubRoleId
			from sma_MST_SubRole s
			inner join sma_MST_SubRoleCode c
				on c.srcnCodeId = s.sbrnTypeCode
				and c.srcsDscrptn = '(P)-Default Role'
			where s.sbrnCaseTypeID = cas.casnOrgCaseTypeID


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
Sample Case = 230740
id = 24637
*/

SELECT * FROM sma_TRN_Plaintiff
where plnnCaseID = 24637

SELECT * FROM sma_TRN_Cases cas
where  cas.casnCaseID = 24637
-- casnOrgCaseTypeID
-- 1775
-- Workplace Injury - General


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
Create Employer Defendant Subrole

*/

--case > casetype > subrole

SELECT * FROM PartyRoles pr
SELECT * FROM CaseTypeMixture ctm

SELECT *, grp.cgpsCode, grp.cgpsDscrptn FROM sma_MST_CaseType smct --where smct.cstnCaseTypeID = 1775
join sma_MST_CaseGroup grp
on smct.cstnGroupID = grp.cgpnCaseGroupID
where smct.cstnCaseTypeID in(
1781,
1701,
383,
1601,
1590,
1780,
1685,
1787,
1775,
1782,
1690)

SELECT * FROM sma_MST_SubRole smsr
SELECT * FROM sma_MST_SubRole smsr where smsr.sbrsDscrptn like '%employer%'

SELECT * FROM sma_MST_SubRoleCode


-- insert (D)-Employer subrole for each applicable case type
insert into [sma_MST_SubRole]
	(
	[sbrsCode],
	[sbrnRoleID],
	[sbrsDscrptn],
	[sbrnCaseTypeID],
	[sbrnRecUserID],
	[sbrdDtCreated]
	)
	select
		null		   as [sbrscode],
		5	   as [sbrnroleid],
		'(D)-Employer'	   as [sbrsdscrptn],
		cst.cstnCaseTypeID as [sbrncasetypeid],
		368	   as [sbrnrecuserid],
		GETDATE()	   as [sbrddtcreated]
	from sma_MST_CaseType cst
	where cst.cstnCaseTypeID = 1775

	--left join sma_mst_subrole s
	--	on cst.cstnCaseTypeID = s.sbrncasetypeid
	--		or s.sbrncasetypeid = 1
	--join [CaseTypeMixture] mix
	--	on mix.matcode = cst.cstsCode
	--where VenderCaseType = (
	--		select
	--			VenderCaseType
	--		from conversion.office
	--	)
	--	and ISNULL(mix.[SmartAdvocate Case Type], '') = ''


insert into [sma_MST_SubRoleCode]
	(
	srcsDscrptn, srcnRoleID
	)
	select
		'(D)-Employer',
		5
	except
	select
		srcsDscrptn,
		srcnRoleID
	from [sma_MST_SubRoleCode]

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- add defendants


SELECT distinct role FROM JoelBieberNeedles..party_Indexed p order by role




insert into [sma_TRN_Defendants]
	(
	[defnCaseID], [defnContactCtgID], [defnContactID], [defnAddressID], [defnSubRole], [defbIsPrimary], [defbCounterClaim], [defbThirdParty], [defsThirdPartyRole], [defnPriority], [defdFrmDt], [defdToDt], [defnRecUserID], [defdDtCreated], [defnModifyUserID], [defdDtModified], [defnLevelNo], [defsMarked], [saga], [saga_party], [source_id], [source_db], [source_ref]
	)
	select
		casnCaseID		as [defncaseid],
		acio.CTG		as [defncontactctgid],
		acio.CID		as [defncontactid],
		acio.AID		as [defnaddressid],
		sbrnSubRoleId   as [defnsubrole],
		1				as [defbisprimary],
		null			as [defbCounterClaim],
		null			as [defbThirdParty],
		null			as [defsThirdPartyRole],
		null			as [defnPriority],
		null			as [defdFrmDt],
		null			as [defdToDt],
		368				as [defnrecuserid],
		GETDATE()		as [defddtcreated],
		null			as [defnmodifyuserid],
		null			as [defddtmodified],
		null			as [defnlevelno],
		null			as [defsMarked],
		null			as [saga],
		p.TableIndex	as [saga_party],
		null			as [source_id],
		'needles'		as [source_db],
		'party_indexed' as [source_ref]
	--select *
	from JoelBieberNeedles.[dbo].[party_indexed] p
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = convert(varchar, p.case_id)
	join IndvOrgContacts_Indexed acio
		on acio.SAGA = p.party_id
	join [PartyRoles] pr
		on pr.[Needles Roles] = p.[role]
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrsDscrptn = [SA Roles]
			and s.sbrnRoleID = 5
	--where p.case_id = 230740
	where pr.[Needles Roles] = 'EMPLOYER'
		and cas.casnCaseID = 24637


SELECT * FROM JoelBieberNeedles..party_Indexed p where role = 'employer' and case_id = 230740
SELECT * FROM PartyRoles pr
select * from [sma_MST_SubRole] where sbrnSubRoleId = 33473
SELECT *, grp.cgpsCode, grp.cgpsDscrptn FROM sma_MST_CaseType smct 


UPDATE subrole 
set sbrnTypeCode = 389
from [sma_MST_SubRole] subrole
where sbrnSubRoleId = 33473