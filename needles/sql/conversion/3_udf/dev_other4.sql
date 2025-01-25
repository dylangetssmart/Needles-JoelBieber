use JoelBieberSA_Needles
go


/*
Pivot Table
*/
if exists (
		select
			*
		from sys.tables
		where name = 'Other4UDF'
			and type = 'U'
	)
begin
	drop table Other4UDF
end

select
	casncaseid,
	casnorgcasetypeID,
	fieldTitle,
	FieldVal
into Other4UDF
from (
	select
		cas.casnCaseID,
		cas.CasnOrgCaseTypeID,
		CONVERT(VARCHAR(MAX), ud.name) as [name],
		CONVERT(VARCHAR(MAX), ud.Type_of_Witness) as [type of witness],
		CONVERT(VARCHAR(MAX), ud.Depo_Date) as [depo date],
		CONVERT(VARCHAR(MAX), ud.Depo_Time) as [depo time],
		CONVERT(VARCHAR(MAX), ud.Depo_Location) as [depo location],
		CONVERT(VARCHAR(MAX), ud.testimony) as [testimony],
		CONVERT(VARCHAR(MAX), ud.Court_Reporter) as [court reporter],
		CONVERT(VARCHAR(MAX), ud.If_Expert_Fee) as [if expert fee],
		CONVERT(VARCHAR(MAX), ud.Witness_Sequence) as [witness sequence]
	from JoelBieberNeedles..user_tab4_data ud
	join JoelBieberNeedles..cases_Indexed c
		on c.casenum = ud.case_id
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
) pv
unpivot (FieldVal for FieldTitle in (
[Name], [Type of Witness], [Depo Date], [Depo Time], [Depo Location], [Testimony], [Court Reporter], [If Expert Fee], [Witness Sequence]
)) as unpvt;


----------------------------
--UDF DEFINITION
----------------------------
alter table [sma_MST_UDFDefinition] disable trigger all
go

-- ds 07-10-2024 // update udfsNewValues max length to support data
--alter table sma_mst_udfdefinition
--alter column udfsNewValues VARCHAR(2500)
--go

insert into [sma_MST_UDFDefinition]
	(
	[udfsUDFCtg],
	[udfnRelatedPK],
	[udfsUDFName],
	[udfsScreenName],
	[udfsType],
	[udfsLength],
	[udfbIsActive],
	[udfshortName],
	[udfsNewValues],
	[udfnSortOrder]
	)
	select distinct
		'C'										   as [udfsudfctg],
		cst.cstnCaseTypeID						   as [udfnrelatedpk],
		m.field_title							   as [udfsudfname],
		'Other2'								   as [udfsscreenname],
		ucf.UDFType								   as [udfstype],
		ucf.field_len							   as [udfslength],
		1										   as [udfbisactive],
		'user_tab4_' + ucf.column_name			   as [udfshortname],
		ucf.DropDownValues						   as [udfsnewvalues],
		DENSE_RANK() over (order by m.field_title) as udfnsortorder
	from [sma_MST_CaseType] cst
	join CaseTypeMixture mix
		on mix.[SmartAdvocate Case Type] = cst.cstsType
	join JoelBieberNeedles.[dbo].[user_tab4_matter] m
		on m.mattercode = mix.matcode
			and m.field_type <> 'label'
	join (
		select distinct
			fieldTitle
		from Other4UDF
	) vd
		on vd.FieldTitle = m.field_title
	join [JoelBieberSA_Needles].[dbo].[NeedlesUserFields] ucf
		on ucf.field_num = m.ref_num
	left join (
		select distinct
			table_name,
			column_name
		from [JoelBieberNeedles].[dbo].[document_merge_params]
		where table_Name = 'user_tab4_data'
	) dmp
		on dmp.column_name = ucf.field_Title
	left join [sma_MST_UDFDefinition] def
		on def.[udfnrelatedpk] = cst.cstnCaseTypeID
			and def.[udfsudfname] = m.field_title
			and def.[udfsscreenname] = 'Other4'
			and def.[udfstype] = ucf.UDFType
			-- WHERE M.Field_Title <> 'Location'
			and def.udfnUDFID is null
	--AND mix.matcode IN ('MVA','PRE')
	order by m.field_title

alter table sma_trn_udfvalues disable trigger all
go

insert into [sma_TRN_UDFValues]
	(
	[udvnUDFID],
	[udvsScreenName],
	[udvsUDFCtg],
	[udvnRelatedID],
	[udvnSubRelatedID],
	[udvsUDFValue],
	[udvnRecUserID],
	[udvdDtCreated],
	[udvnModifyUserID],
	[udvdDtModified],
	[udvnLevelNo]
	)
	select
		def.udfnUDFID as [udvnudfid],
		'Other4'	  as [udvsscreenname],
		'C'			  as [udvsudfctg],
		casnCaseID	  as [udvnrelatedid],
		0			  as [udvnsubrelatedid],
		udf.FieldVal  as [udvsudfvalue],
		368			  as [udvnrecuserid],
		GETDATE()	  as [udvddtcreated],
		null		  as [udvnmodifyuserid],
		null		  as [udvddtmodified],
		null		  as [udvnlevelno]
	from Other4UDF udf
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = udf.casnOrgCaseTypeID
			and def.udfsUDFName = fieldTitle
			and def.udfsScreenName = 'Other4'

alter table sma_trn_udfvalues enable trigger all
go
