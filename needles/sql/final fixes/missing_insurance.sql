/*

1. gather missing insurance records (insured = null)
2. insert to sma_TRN_InsuranceCoverage ic
	- but not where ic.saga exists

*/


--select
--	*
--from conversion.insurance_contacts_helper ich
--where caseid = 23242
---- missing insurance_id = 57356

--select
--	*
--from JoelBieberNeedles..insurance_Indexed ii
--where case_num = 229350

--select
--	ii.insurance_id,
--	ii.insured,
--	ioci.CID,
--	ioci.Name
--from JoelBieberNeedles..insurance_Indexed ii
--join IndvOrgContacts_Indexed ioci
--	on ioci.SAGA = ii.party_id
--where case_num = 229350

--select
--	*
--from IndvOrgContacts_Indexed ioci
--where ioci.SAGA in (69358,
--	104930,
--	22045)


--select
--	*
--from sma_TRN_Plaintiff stp
--where stp.plnnCaseID = 23242
---- plnnPlaintiffID = 31460

--select
--	*
--from conversion.multi_party_helper
--where plnnPlaintiffID = 31460


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
how many insurance records are missing?
presumably all where insured = null

*/

-- assuming the issue is due to [insured] being blank
select
	*
from JoelBieberNeedles..insurance_Indexed ii
join sma_TRN_Cases cas
	on cas.cassCaseNumber = CONVERT(VARCHAR, case_num)
join IndvOrgContacts_Indexed ioci_insurer
	on ioci_insurer.saga = ii.insurer_id
		and ISNULL(ii.insurer_id, 0) <> 0
		and ioci_insurer.CTG = 2
--where ii.insurance_id = 22980
where ii.insured is null
	-- valid insurance company
	and ii.insurer_id <> 0
order by case_num


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
is it possible that party is NOT the same as insured?

*/

select
	ins.insurance_id,
	ins.party_id,
	ins.insured,
	ioci.CID,
	ioci.Name
from JoelBieberNeedles..insurance_Indexed ins
join sma_TRN_Cases cas
	on cas.cassCaseNumber = CONVERT(VARCHAR, ins.case_num)
left join IndvOrgContacts_Indexed ioci
	on ioci.saga = ins.party_id
where ioci.Name <> ins.insured

-- insurance_id		22723	
-- party_id			65162
-- insured			Lanethia Ruggles	
-- CID				43823	
-- name 			Nathan Sawyer

-- yes

/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
Rebuild helper
*/


if OBJECT_ID('conversion.insurance_contacts_helper', 'U') is not null
begin
	drop table conversion.insurance_contacts_helper
end

create table conversion.insurance_contacts_helper (
	tableIndex			 INT identity (1, 1) not null,
	insurance_id		 INT,					-- table id
	insurer_id			 INT,					-- insurance company
	adjuster_id			 INT,					-- adjuster
	insured				 VARCHAR(100),			-- a person or organization covered by insurance
	incnInsContactID	 INT,
	incnInsAddressID	 INT,
	incnAdjContactId	 INT,
	incnAdjAddressID	 INT,
	incnInsured			 INT,
	pord				 VARCHAR(1),
	caseID				 INT,
	PlaintiffDefendantID INT 
	constraint IX_Insurance_Contacts_Helper primary key clustered
	(
	tableIndex
	) with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, fillfactor = 80) on [PRIMARY]
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_insurance_id on conversion.insurance_contacts_helper (insurance_id);
create nonclustered index IX_NonClustered_Index_insurer_id on conversion.insurance_contacts_helper (insurer_id);
create nonclustered index IX_NonClustered_Index_adjuster_id on conversion.insurance_contacts_helper (adjuster_id);
go


insert into conversion.insurance_contacts_helper
	(
	insurance_id, insurer_id, adjuster_id, insured, incnInsContactID, incnInsAddressID, incnAdjContactId, incnAdjAddressID, incnInsured, pord, caseID, PlaintiffDefendantID
	)
	select distinct
		ins.insurance_id								 as insurance_id,
		ins.insurer_id									 as insurer_id,
		ins.adjuster_id									 as adjuster_id,
		ins.insured										 as insured,
		ioci_insurer.CID								 as incninscontactid,
		ioci_insurer.AID								 as incninsaddressid,
		ioci_adjuster.CID								 as incnadjcontactid,
		ioci_adjuster.AID								 as incnadjaddressid,
		COALESCE(ioci_insured.unqcid, ioci_party.unqcid) as incninsured,  -- Use insured when available, otherwise party_id
		null											 as pord,
		cas.casnCaseID									 as caseid,
		null											 as plaintiffdefendantid
	--select *
	from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, ins.case_num)
	-- ioci_insurer
	-- left join because some insurance records for the same case use the same insurer
	join IndvOrgContacts_Indexed ioci_insurer
		on ioci_insurer.saga = ins.insurer_id
			and ISNULL(ins.insurer_id, 0) <> 0
			and ioci_insurer.CTG = 2
	--where case_num = 216299
	-- ioci_adjuster
	left join IndvOrgContacts_Indexed ioci_adjuster
		on ioci_adjuster.saga = ins.adjuster_id
			and ISNULL(ins.adjuster_id, 0) <> 0
	-- ioci_insured (join when `insured` is NOT NULL)
	left join [sma_MST_IndvContacts] ind
		on ind.cinsLastName = ins.insured
			and ind.source_id = ins.insured
			and ind.source_ref = 'insured'
	left join IndvOrgContacts_Indexed ioci_insured
		on ioci_insured.cid = ind.cinnContactID
	-- ioci_party (join when [insured] IS NULL, using [party_id] instead)
	left join IndvOrgContacts_Indexed ioci_party
		on ioci_party.saga = ins.party_id
			and ins.insured is null
	--where ins.insurer_id <> 0
	left join sma_TRN_InsuranceCoverage ic
		on ic.saga = ins.insurance_id
	where ic.incnInsCovgID is null
		and ins.insurer_id <> 0
		and ins.insured is null

dbcc dbreindex ('conversion.insurance_contacts_helper', ' ', 90) with no_infomsgs
go

-------------------------------------------------------------------------------
-- Build conversion.multi_party_helper
-------------------------------------------------------------------------------
if OBJECT_ID('conversion.multi_party_helper') is not null
begin
	drop table conversion.multi_party_helper
end
go

-- Seed multi_party_helper with plaintiff id's
select
	ins.insurance_id as ins_id,
	t.plnnPlaintiffID
into conversion.multi_party_helper
--select *
from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = ins.case_num
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = ins.party_id
join [sma_TRN_Plaintiff] t
	on t.plnnContactID = ioc.CID
		and t.plnnContactCtg = ioc.CTG
		and t.plnnCaseID = cas.casnCaseID
go

-- 26689

-- party_id is never null or 0
--select
--	*
--from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
--where ins.party_id = 0

--select
--	*
--from conversion.multi_party_helper
--where ins_id in (57355,
--	57353,
--	57355,
--	57353,
--	57356)

-- update insurance_contacts_helper.pord = P using multi_party_helper
update conversion.insurance_contacts_helper
set pord = 'P',
	PlaintiffDefendantID = A.plnnPlaintiffID
from conversion.multi_party_helper a
where a.ins_id = insurance_id
go
-- 26512
-- 26689 - 26512 = 177
-- insurance_id is not matching



select
	mph.ins_id
from conversion.multi_party_helper mph
left join conversion.insurance_contacts_helper ich
	on mph.ins_id = ich.insurance_id
where ich.insurance_id is null
order by ich.insurance_id

--ins_id not present in insurance_contacts_helper. why?
--25808
--21002
--62164
--46976

select
	*
from JoelBieberNeedles..insurance_Indexed ii
where ii.insurance_id = 25808

-- because insurer_id = 0

select
	*
from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = ins.case_num
where ins.insurer_id = 0
-- 174 applicable records with insurer_id = 0

select
	ins.*
from conversion.multi_party_helper mph
left join conversion.insurance_contacts_helper ich
	on mph.ins_id = ich.insurance_id
join JoelBieberNeedles.[dbo].[insurance_Indexed] ins
	on mph.ins_id = ins.insurance_id
where ich.insurance_id is null
	and ins.insurer_id <> 0;


-- drop multi_party_helper
if OBJECT_ID('conversion.multi_party_helper') is not null
begin
	drop table conversion.multi_party_helper
end
go

-- Seed multi_party_helper with defendant id's
select
	ins.insurance_id as ins_id,
	d.defnDefendentID
into conversion.multi_party_helper
from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
join [sma_TRN_cases] cas
	on cas.cassCaseNumber = ins.case_num
join [IndvOrgContacts_Indexed] ioc
	on ioc.SAGA = ins.party_id
join [sma_TRN_Defendants] d
	on d.defnContactID = ioc.CID
		and d.defnContactCtgID = ioc.CTG
		and d.defnCaseID = cas.casnCaseID
go
-- 13689


select
	*
from conversion.multi_party_helper
where ins_id in (57355,
	57353,
	57355,
	57353,
	57356)


-- update insurance_contacts_helper.pord = D using multi_party_helper
update conversion.insurance_contacts_helper
set pord = 'D',
	PlaintiffDefendantID = A.defnDefendentID
from conversion.multi_party_helper a
where a.ins_id = insurance_id
go

select
	mph.ins_id
from conversion.multi_party_helper mph
left join conversion.insurance_contacts_helper ich
	on mph.ins_id = ich.insurance_id
where ich.insurance_id is null
order by ich.insurance_id

select
	*
from JoelBieberNeedles..insurance_Indexed ii
where ii.insurance_id = 53027

select
	*
from conversion.insurance_contacts_helper
where caseid = 23242


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
Check: Insert missing plaintiff insurance
*/

alter table [sma_TRN_InsuranceCoverage] disable trigger all
go

insert into [sma_TRN_InsuranceCoverage]
	(
	[incnCaseID], [incnInsContactID], [incnInsAddressID], [incbCarrierHasLienYN], [incnInsType], [incnAdjContactId], [incnAdjAddressID], [incsPolicyNo], [incsClaimNo], [incnStackedTimes], [incsComments], [incnInsured], [incnCovgAmt], [incnDeductible], [incnUnInsPolicyLimit], [incnUnderPolicyLimit], [incbPolicyTerm], [incbTotCovg], [incsPlaintiffOrDef], [incnPlaintiffIDOrDefendantID], [incnTPAdminOrgID], [incnTPAdminAddID], [incnTPAdjContactID], [incnTPAdjAddID], [incsTPAClaimNo], [incnRecUserID], [incdDtCreated], [incnModifyUserID], [incdDtModified], [incnLevelNo], [incnUnInsPolicyLimitAcc], [incnUnderPolicyLimitAcc], [incb100Per], [incnMVLeased], [incnPriority], [incbDelete], [incnauthtodefcoun], [incnauthtodefcounDt], [incbPrimary], [saga], source_id, source_db, source_ref
	)
	select
		map.caseID				 as [incncaseid],
		map.incninscontactid	 as [incninscontactid],
		map.incninsaddressid	 as [incninsaddressid],
		null					 as [incbcarrierhaslienyn],
		(
			select
				intnInsuranceTypeID
			from [sma_MST_InsuranceType]
			where intsDscrptn = case
					when ISNULL(ins.policy_type, '') <> ''
						then ins.policy_type
					else 'Unspecified'
				end
		)						 as [incninstype],
		map.incnadjcontactid	 as [incnadjcontactid],
		map.incnadjaddressid	 as [incnadjaddressid],
		ins.policy				 as [incspolicyno],
		ins.claim				 as [incsclaimno],
		null					 as [incnstackedtimes],
		''						 as [incscomments],
		map.incninsured			 as [incninsured],
		ins.actual				 as [incncovgamt],
		null					 as [incndeductible],
		0						 as [incnuninspolicylimit],
		0						 as [incnunderpolicylimit],
		0						 as [incbpolicyterm],
		0						 as [incbtotcovg],
		'P'						 as [incsplaintiffordef],
		--    ( select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=MAP.caseID and plnbIsPrimary=1 )  
		map.PlaintiffDefendantID as [incnplaintiffidordefendantid],
		null					 as [incntpadminorgid],
		null					 as [incntpadminaddid],
		null					 as [incntpadjcontactid],
		null					 as [incntpadjaddid],
		null					 as [incstpaclaimno],
		368						 as [incnrecuserid],
		GETDATE()				 as [incddtcreated],
		null					 as [incnmodifyuserid],
		null					 as [incddtmodified],
		null					 as [incnlevelno],
		null					 as [incnuninspolicylimitacc],
		null					 as [incnunderpolicylimitacc],
		0						 as [incb100per],
		null					 as [incnmvleased],
		null					 as [incnpriority],
		0						 as [incbdelete],
		0						 as [incnauthtodefcoun],
		null					 as [incnauthtodefcoundt],
		0						 as [incbprimary],
		ins.insurance_id		 as [saga],
		null					 as source_id,
		'needles'				 as source_db,
		'post live fix'			 as source_ref
	--select *
	from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
	left join JoelBieberNeedles.[dbo].[user_insurance_data] ud
		on ins.insurance_id = ud.insurance_id
	join conversion.insurance_contacts_helper map
		on ins.insurance_id = map.insurance_id
			and map.pord = 'P'
	left join sma_TRN_InsuranceCoverage ic
		on ic.saga = ins.insurance_id
	where ic.incnInsCovgID is null
go

/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
Check: Insert missing defendant insurance
*/

insert into [sma_TRN_InsuranceCoverage]
	(
	[incnCaseID], [incnInsContactID], [incnInsAddressID], [incbCarrierHasLienYN], [incnInsType], [incnAdjContactId], [incnAdjAddressID], [incsPolicyNo], [incsClaimNo], [incnStackedTimes], [incsComments], [incnInsured], [incnCovgAmt], [incnDeductible], [incnUnInsPolicyLimit], [incnUnderPolicyLimit], [incbPolicyTerm], [incbTotCovg], [incsPlaintiffOrDef], [incnPlaintiffIDOrDefendantID], [incnTPAdminOrgID], [incnTPAdminAddID], [incnTPAdjContactID], [incnTPAdjAddID], [incsTPAClaimNo], [incnRecUserID], [incdDtCreated], [incnModifyUserID], [incdDtModified], [incnLevelNo], [incnUnInsPolicyLimitAcc], [incnUnderPolicyLimitAcc], [incb100Per], [incnMVLeased], [incnPriority], [incbDelete], [incnauthtodefcoun], [incnauthtodefcounDt], [incbPrimary], [saga], source_id, source_db, source_ref
	)
	select
		map.caseID				 as [incncaseid],
		map.incninscontactid	 as [incninscontactid],
		map.incninsaddressid	 as [incninsaddressid],
		null					 as [incbcarrierhaslienyn],
		(
			select
				intnInsuranceTypeID
			from [sma_MST_InsuranceType]
			where intsDscrptn = case
					when ISNULL(ins.policy_type, '') <> ''
						then ins.policy_type
					else 'Unspecified'
				end
		)						 as [incninstype],
		map.incnadjcontactid	 as [incnadjcontactid],
		map.incnadjaddressid	 as [incnadjaddressid],
		ins.policy				 as [incspolicyno],
		ins.claim				 as [incsclaimno],
		null					 as [incnstackedtimes],
		''						 as [incscomments],
		map.incninsured			 as [incninsured],
		ins.actual				 as [incncovgamt],
		null					 as [incndeductible],
		0						 as [incnuninspolicylimit],
		0						 as [incnunderpolicylimit],
		0						 as [incbpolicyterm],
		0						 as [incbtotcovg],
		'D'						 as [incsplaintiffordef],
		map.PlaintiffDefendantID as [incnplaintiffidordefendantid],
		null					 as [incntpadminorgid],
		null					 as [incntpadminaddid],
		null					 as [incntpadjcontactid],
		null					 as [incntpadjaddid],
		null					 as [incstpaclaimno],
		368						 as [incnrecuserid],
		GETDATE()				 as [incddtcreated],
		null					 as [incnmodifyuserid],
		null					 as [incddtmodified],
		null					 as [incnlevelno],
		null					 as [incnuninspolicylimitacc],
		null					 as [incnunderpolicylimitacc],
		0						 as [incb100per],
		null					 as [incnmvleased],
		null					 as [incnpriority],
		0						 as [incbdelete],
		0						 as [incnauthtodefcoun],
		null					 as [incnauthtodefcoundt],
		0						 as [incbprimary],
		ins.insurance_id		 as [saga],
		null					 as source_id,
		'needles'				 as source_db,
		'post live fix'			 as source_ref
	from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
	left join JoelBieberNeedles.[dbo].[user_insurance_data] ud
		on ins.insurance_id = ud.insurance_id
	join conversion.insurance_contacts_helper map
		on ins.insurance_id = map.insurance_id
			and map.pord = 'D'
	left join sma_TRN_InsuranceCoverage ic
		on ic.saga = ins.insurance_id
	where ic.incnInsCovgID is null


alter table [sma_TRN_InsuranceCoverage] enable trigger all
go

/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
why are the record counts different?

*/

-- how many are valid to convert?

select
	ii.insurance_id
from JoelBieberNeedles..insurance_Indexed ii
join sma_TRN_Cases cas
	on cas.cassCaseNumber = CONVERT(VARCHAR, case_num)
join IndvOrgContacts_Indexed ioci_insurer
	on ioci_insurer.saga = ii.insurer_id
		and ISNULL(ii.insurer_id, 0) <> 0
		and ioci_insurer.CTG = 2
where ii.insured is null
	and ii.insurer_id <> 0

except

select
	ins.insurance_id
from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
left join JoelBieberNeedles.[dbo].[user_insurance_data] ud
	on ins.insurance_id = ud.insurance_id
join conversion.insurance_contacts_helper map
	on ins.insurance_id = map.insurance_id
left join sma_TRN_InsuranceCoverage ic
	on ic.saga = ins.insurance_id
where ic.incnInsCovgID is null
order by ii.insurance_id

--insurance_id
--32908
--41118
--45096
--53027
--53330
--55737
--57356

select
	*
from conversion.insurance_contacts_helper ich
where insurance_id = 57356

select
	*
from JoelBieberNeedles..insurance_Indexed ii
where ii.insurance_id in ('32908',
	'41118',
	'45096',
	'53027',
	'53330',
	'55737',
	'57356')

select
	*
from sma_TRN_Cases stc
where stc.cassCaseNumber = '218568'

-- why is insurance_id 32908 not in helper?


-- side by side comparison
select
	q1.insurance_id as PotentialInsert,
	q2.insurance_id as SourceData
from (
	select
		ins.insurance_id
	from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
	left join JoelBieberNeedles.[dbo].[user_insurance_data] ud
		on ins.insurance_id = ud.insurance_id
	join conversion.insurance_contacts_helper map
		on ins.insurance_id = map.insurance_id
	left join sma_TRN_InsuranceCoverage ic
		on ic.saga = ins.insurance_id
	where ic.incnInsCovgID is null
) q1
full outer join (
	select
		ii.insurance_id
	from JoelBieberNeedles..insurance_Indexed ii
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, case_num)
	where ii.insured is null
) q2
	on q1.insurance_id = q2.insurance_id
order by q1.insurance_id, q2.insurance_id;

-- example: insurance_id = 7476

select
	*
from conversion.insurance_contacts_helper ich
where ich.insurance_id = 7476
-- missing insurance_id = 57356

select
	*
from JoelBieberNeedles..insurance_Indexed ii
where ii.insurance_id = 7476


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------
why is insurance_id = 7476 not in potential insert?

*/

select
	*
from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
left join JoelBieberNeedles.[dbo].[user_insurance_data] ud
	on ins.insurance_id = ud.insurance_id
join conversion.insurance_contacts_helper map
	on ins.insurance_id = map.insurance_id
		and map.pord = 'P'
left join sma_TRN_InsuranceCoverage ic
	on ic.saga = ins.insurance_id
where ic.incnInsCovgID is null
order by ins.insurance_id

-- because this is only plaintiff insurance
-- P + D insurance should equal:

-- How many missing records are we expecting?

select
	COUNT(*)
from JoelBieberNeedles..insurance_Indexed ii
join sma_TRN_Cases cas
	on cas.cassCaseNumber = CONVERT(VARCHAR, case_num)
where ii.insured is null

-- 3479

select
	(
		select
			COUNT(*)
		from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
		left join JoelBieberNeedles.[dbo].[user_insurance_data] ud
			on ins.insurance_id = ud.insurance_id
		join conversion.insurance_contacts_helper map
			on ins.insurance_id = map.insurance_id
			and map.pord = 'P'
		left join sma_TRN_InsuranceCoverage ic
			on ic.saga = ins.insurance_id
		where ic.incnInsCovgID is null
	-- 2900
	) + (
		select
			COUNT(*)
		from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
		left join JoelBieberNeedles.[dbo].[user_insurance_data] ud
			on ins.insurance_id = ud.insurance_id
		join conversion.insurance_contacts_helper map
			on ins.insurance_id = map.insurance_id
			and map.pord = 'D'
		left join sma_TRN_InsuranceCoverage ic
			on ic.saga = ins.insurance_id
		where ic.incnInsCovgID is null
	-- 761
	) as total_count;

-- 3661
-- 3661 - 3479 = 182 difference
-- 182 more records in potential insert

select
	COUNT(*)
from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
left join JoelBieberNeedles.[dbo].[user_insurance_data] ud
	on ins.insurance_id = ud.insurance_id
join conversion.insurance_contacts_helper map
	on ins.insurance_id = map.insurance_id
left join sma_TRN_InsuranceCoverage ic
	on ic.saga = ins.insurance_id
where ic.incnInsCovgID is null

-- 3681
-- 3681 = 3661 = 20
-- 20 records with pord = null

select
	*
from conversion.insurance_contacts_helper
where pord is null




select
	ii.insurance_id
from JoelBieberNeedles..insurance_Indexed ii
join sma_TRN_Cases cas
	on cas.cassCaseNumber = CONVERT(VARCHAR, case_num)
where ii.insured is null

except

select
	ins.insurance_id
from JoelBieberNeedles.[dbo].[insurance_Indexed] ins
left join JoelBieberNeedles.[dbo].[user_insurance_data] ud
	on ins.insurance_id = ud.insurance_id
join conversion.insurance_contacts_helper map
	on ins.insurance_id = map.insurance_id
left join sma_TRN_InsuranceCoverage ic
	on ic.saga = ins.insurance_id
where ic.incnInsCovgID is null
order by ii.insurance_id

-- 164 diff
-- why is insurance_id 17573 not in conversion.insurance_contacts_helper?

select
	*
from JoelBieberNeedles..insurance_Indexed ii
where ii.insurance_id = 17573

select
	*
from conversion.insurance_contacts_helper
where insurance_id = 17573

select
	*
from IndvOrgContacts_Indexed ioci
where saga = 52631

-- because insurer_id = 0

select
	ii.insurance_id
from JoelBieberNeedles..insurance_Indexed ii
join sma_TRN_Cases cas
	on cas.cassCaseNumber = CONVERT(VARCHAR, case_num)
where ii.insurer_id = 0

-- 174 where insurer_id = 0

select
	ii.insurance_id
from JoelBieberNeedles..insurance_Indexed ii
join sma_TRN_Cases cas
	on cas.cassCaseNumber = CONVERT(VARCHAR, case_num)
where ii.party_id = 0