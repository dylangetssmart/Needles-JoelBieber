/*

	- create defendants with role = (D)-Employer
	- remove plaintiffs with role (P)-Employer
*	- ensure they are not primary plaintiffs
 

*/


--'Workplace Injury - General'
select
	*
from sma_MST_CaseType ct
where ct.cstsType = 'Workplace Injury - General'
--cstnCaseTypeID = 1775



-- how many are there?
select
	*
from JoelBieberNeedles..party_Indexed p
join sma_TRN_Cases cas
	on cas.cassCaseNumber = CONVERT(VARCHAR, p.case_id)
where role = 'employer'
-- 194


select
	cas.casnCaseID	   as CaseId,
	cas.cassCaseNumber as CaseNumber,
	cas.cassCaseName   as CaseName,
	ioci.Name		   as PlaintiffName,
	ct.cstsType		   as CaseType,
	grp.cgpsDscrptn	   as CaseGroup
--pln.plnnPlaintiffID, pln.plnnCaseID, pln.plnnContactCtg, pln.plnnContactID, pln.plnbIsPrimary, sr.sbrsDscrptn, ct.cstsType
from sma_TRN_Plaintiff pln
join sma_MST_SubRole sr
	on pln.plnnRole = sr.sbrnSubRoleId
join sma_TRN_Cases cas
	on cas.casnCaseID = pln.plnnCaseID
join sma_MST_CaseType ct
	on ct.cstnCaseTypeID = cas.casnOrgCaseTypeID
join sma_MST_CaseGroup grp
	on grp.cgpnCaseGroupID = ct.cstnGroupID
join IndvOrgContacts_Indexed ioci
	on ioci.CID = pln.plnnContactID
		and ioci.CTG = pln.plnnContactCtg
where sr.sbrsDscrptn = '(P)-Employer'
	and pln.plnbIsPrimary = 0



-- Sample Case = 230740
-- id = 24637

select
	*
from sma_TRN_Plaintiff
where plnnCaseID = 24637

select
	*
from sma_TRN_Cases cas
where cas.casnCaseID = 24637
-- casnOrgCaseTypeID
-- 1775
-- Workplace Injury - General


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
Create Defendants

*/

-- Create (D)-Employer subrole code 
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


-- Create (D)-Employer subrole
insert into [sma_MST_SubRole]
	(
	[sbrsCode], [sbrnRoleID], [sbrsDscrptn], [sbrnCaseTypeID], [sbrnRecUserID], [sbrdDtCreated], [sbrnTypeCode]
	)
	select
		null			   as [sbrscode],
		5				   as [sbrnroleid],
		'(D)-Employer'	   as [sbrsdscrptn],
		cst.cstnCaseTypeID as [sbrncasetypeid],
		368				   as [sbrnrecuserid],
		GETDATE()		   as [sbrddtcreated],
		(
			select
				code.srcnCodeId
			from sma_mst_SubRoleCode code
			where code.srcsDscrptn = '(D)-Employer'
				and code.srcnRoleID = 5
		)				   as [sbrnTypeCode]
	from sma_MST_CaseType cst
	where cst.cstnCaseTypeID = 1775


-- Insert Defendants
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
		on cas.cassCaseNumber = CONVERT(VARCHAR, p.case_id)
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




/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
Delete plaintiffs
*/


-- Are any plaintiffs with role (P)-Employer primary?
select
	pln.plnnPlaintiffID,
	pln.plnnCaseID,
	pln.plnnContactCtg,
	pln.plnnContactID,
	pln.plnbIsPrimary,
	sr.sbrsDscrptn
from sma_TRN_Plaintiff pln
join sma_MST_SubRole sr
	on pln.plnnRole = sr.sbrnSubRoleId
where sr.sbrsDscrptn = '(P)-Employer'
	and pln.plnbIsPrimary = 1
-- only 1

-- plnnPlaintiffID = 2722	
-- plnnCaseID = 5012	
-- plnnContactCtg = 2
-- plnnContactID = 11718	


delete from sma_TRN_Plaintiff
where plnnRole in (
		select
			sbrnSubRoleId
		from sma_MST_SubRole
		where sbrsDscrptn = '(P)-Employer'
	)
	and plnbIsPrimary = 0;





/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

-- check PartyRoles
select
	*
from PartyRoles pr
where pr.[Needles Roles] = 'employer'





select
	*
from [sma_MST_SubRole]
where sbrnSubRoleId = 33473
select
	*,
	grp.cgpsCode,
	grp.cgpsDscrptn
from sma_MST_CaseType smct


update subrole
set sbrnTypeCode = 389
from [sma_MST_SubRole] subrole
where sbrnSubRoleId = 33473


select
	*
from PartyRoles pr
--EMPLOYER	(D)-EMPLOYER	DEFENDANT



select
	*
from sma_MST_SubRole smsr
-- 4 = pln
-- 5 = def


select
	*
from sma_MST_SubRole smsr
where smsr.sbrsDscrptn like '%employer%'
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

select
	*
from sma_MST_SubRoleCode
select
	*
from sma_MST_SubRole smsr


select
	*
from sma_TRN_Plaintiff pln
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
Create Employer Defendant Subrole

*/

--case > casetype > subrole

select
	*
from PartyRoles pr
select
	*
from CaseTypeMixture ctm

select
	*,
	grp.cgpsCode,
	grp.cgpsDscrptn
from sma_MST_CaseType smct --where smct.cstnCaseTypeID = 1775
join sma_MST_CaseGroup grp
	on smct.cstnGroupID = grp.cgpnCaseGroupID
where smct.cstnCaseTypeID in (
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

select
	*
from sma_MST_SubRole smsr
select
	*
from sma_MST_SubRole smsr
where smsr.sbrsDscrptn like '%employer%'

select
	*
from sma_MST_SubRoleCode


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
SubRole and SubRoleCode

*/

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

-- insert (D)-Employer subrole for each applicable case type
insert into [sma_MST_SubRole]
	(
	[sbrsCode], [sbrnRoleID], [sbrsDscrptn], [sbrnCaseTypeID], [sbrnRecUserID], [sbrdDtCreated], [sbrnTypeCode]
	)
	select
		null			   as [sbrscode],
		5				   as [sbrnroleid],
		'(D)-Employer'	   as [sbrsdscrptn],
		cst.cstnCaseTypeID as [sbrncasetypeid],
		368				   as [sbrnrecuserid],
		GETDATE()		   as [sbrddtcreated],
		(
			select
				code.srcnCodeId
			from sma_mst_SubRoleCode code
			where code.srcsDscrptn = '(D)-Employer'
				and code.srcnRoleID = 5
		)				   as [sbrnTypeCode]
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







