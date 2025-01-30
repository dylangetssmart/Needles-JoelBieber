use SA
go

----------------------------
--PIVOT TABLE CONSTRUCTION
----------------------------
/*
select m.*
--distinct m.field_Title, column_name, 'convert(varchar(max), ['+ column_Name + '] ) as ['+ m.field_title +'], ', '['+m.field_title+'],'
FROM [NeedlesGMA].[dbo].[user_case_matter] M 
inner join [NeedlesGMA].[dbo].[user_case_fields] F on F.field_title=M.field_title
where m.field_Type <> 'label'
*/


if exists (
		select
			*
		from sys.tables
		where name = 'CaseUDF_Incident'
			and type = 'U'
	)
begin
	drop table CaseUDF_Incident
end
----------------------
--PIVOT TABLE
----------------------
select
	casncaseid,
	casnorgcasetypeID,
	fieldTitle,
	FieldVal
into CaseUDF_Incident
from (
	select
		cas.casnCaseID,
		cas.CasnOrgCaseTypeID,
		CONVERT(VARCHAR(MAX), [county]) as county,
		CONVERT(VARCHAR(MAX), [state]) as state,
		CONVERT(VARCHAR(MAX), [time]) as time,
		CONVERT(VARCHAR(MAX), [fr_10]) as fr_10,
		CONVERT(VARCHAR(MAX), [type_of_col]) as type_of_col,
		CONVERT(VARCHAR(MAX), [witnesses]) as witnesses,
		CONVERT(VARCHAR(MAX), [photos_tkn]) as photos_tkn,
		CONVERT(VARCHAR(MAX), [no_of_veh]) as no_of_veh,
		CONVERT(VARCHAR(MAX), [punitives]) as punitives,
		CONVERT(VARCHAR(MAX), [prop_dmg_$]) as prop_dmg_$,
		CONVERT(VARCHAR(MAX), [client_neg]) as client_neg,
		CONVERT(VARCHAR(MAX), [body_part]) as body_part,
		CONVERT(VARCHAR(MAX), [scarring]) as scarring,
		CONVERT(VARCHAR(MAX), [rating]) as rating,
		CONVERT(VARCHAR(MAX), [tttp_paid]) as tttp_paid,
		CONVERT(VARCHAR(MAX), [coverage]) as coverage,
		CONVERT(VARCHAR(MAX), [comp_rate]) as comp_rate,
		CONVERT(VARCHAR(MAX), [accepted]) as accepted,
		CONVERT(VARCHAR(MAX), [reported]) as reported,
		CONVERT(VARCHAR(MAX), [initials]) as initials,
		CONVERT(VARCHAR(MAX), [police_rpt]) as police_rpt,
		CONVERT(VARCHAR(MAX), [photos]) as photos,
		CONVERT(VARCHAR(MAX), [prop_damg_$]) as prop_damg_$,
		CONVERT(VARCHAR(MAX), [alcohol]) as alcohol,
		CONVERT(VARCHAR(MAX), [commercial]) as commercial,
		CONVERT(VARCHAR(MAX), [prior_notice]) as prior_notice,
		CONVERT(VARCHAR(MAX), [police_rep]) as police_rep,
		CONVERT(VARCHAR(MAX), [etoh]) as etoh,
		CONVERT(VARCHAR(MAX), [type_of_coll]) as type_of_coll,
		CONVERT(VARCHAR(MAX), [num_of_veh]) as num_of_veh,
		CONVERT(VARCHAR(MAX), [illuminatn]) as illuminatn,
		CONVERT(VARCHAR(MAX), [pr_attacks]) as pr_attacks,
		CONVERT(VARCHAR(MAX), [destroyed]) as destroyed,
		CONVERT(VARCHAR(MAX), [type]) as type,
		CONVERT(VARCHAR(MAX), [experts]) as experts,
		CONVERT(VARCHAR(MAX), [style_of_case]) as style_of_case,
		CONVERT(VARCHAR(MAX), [type_of_service]) as type_of_service,
		CONVERT(VARCHAR(MAX), [type_of_accident]) as type_of_accident,
		CONVERT(VARCHAR(MAX), [type_of_weather]) as type_of_weather,
		CONVERT(VARCHAR(MAX), [citation_issue]) as citation_issue,
		CONVERT(VARCHAR(MAX), [jurisdiction]) as jurisdiction,
		CONVERT(VARCHAR(MAX), [location]) as location,
		CONVERT(VARCHAR(MAX), [citation_issued]) as citation_issued,
		CONVERT(VARCHAR(MAX), [citations]) as citations,
		CONVERT(VARCHAR(MAX), [photo_description]) as photo_description,
		CONVERT(VARCHAR(MAX), [alcohol_involved]) as alcohol_involved,
		CONVERT(VARCHAR(MAX), [alcohol_comments]) as alcohol_comments,
		CONVERT(VARCHAR(MAX), [relationship]) as relationship,
		CONVERT(VARCHAR(MAX), [prior_claims]) as prior_claims,
		CONVERT(VARCHAR(MAX), [type_of_dog]) as type_of_dog,
		CONVERT(VARCHAR(MAX), [rcvd_form_20]) as rcvd_form_20
	from JoelBieberNeedles..user_Case_Data ud
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, ud.casenum)
) pv
unpivot (
FieldVal for FieldTitle in (
county, state, time, Fr_10, Type_Of_Col, witnesses, Photos_Tkn, No_Of_Veh, punitives, Prop_Dmg_$,
Client_Neg, Body_Part, scarring, rating, TtTp_Paid, coverage, Comp_Rate, accepted, reported, initials,
Police_Rpt, photos, Prop_Damg_$, alcohol, commercial, Prior_Notice, Police_Rep, etoh, Type_Of_Coll,
Num_Of_Veh, illuminatn, Pr_Attacks, destroyed, type, experts, Style_Of_Case, Type_Of_Service,
Type_of_Accident, Type_of_Weather, Citation_Issue, jurisdiction, location, Citation_Issued, citations,
Photo_Description, Alcohol_Involved, Alcohol_Comments, relationship, Prior_Claims, Type_of_Dog,
Rcvd_Form_20
)
) as unpvt;


----------------------------
--UDF DEFINITION
----------------------------
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
		'Case Wizard'							   as [udfsscreenname],
		ucf.UDFType								   as [udfstype],
		ucf.field_len							   as [udfslength],
		1										   as [udfbisactive],
		'user_Case_Data' + ucf.column_name		   as [udfshortname],
		ucf.DropDownValues						   as [udfsnewvalues],
		DENSE_RANK() over (order by m.field_title) as udfnsortorder
	from [sma_MST_CaseType] cst
	join CaseTypeMixture mix
		on mix.[SmartAdvocate Case Type] = cst.cstsType
	join [NeedlesGMA].[dbo].[user_case_matter] m
		on m.mattercode = mix.matcode
			and m.field_type <> 'label'
	join (
		select distinct
			fieldTitle
		from CaseUDF_Incident
	) vd
		on vd.FieldTitle = m.field_title
	--JOIN [NeedlesGMA].[dbo].[user_Case_Fields] ucf on m.ref_num = ucf.field_num
	join NeedlesUserFields ucf
		on ucf.field_num = m.ref_num
	left join (
		select distinct
			table_name,
			column_name
		from [NeedlesGMA].[dbo].[document_merge_params]
		where table_name = 'user_Case_Data'
	) dmp
		on dmp.column_name = ucf.field_Title
	left join [sma_MST_UDFDefinition] def
		on def.[udfnrelatedpk] = cst.cstnCaseTypeID
			and def.[udfsudfname] = m.field_title
			and def.[udfsscreenname] = 'Case Wizard'
			and udfstype = ucf.UDFType
	where m.Field_Title <> 'Location'
		and def.udfnUDFID is null
		and mix.matcode in ('CLW')
	order by m.field_title

--select * From [NeedlesGMA]..[user_case_matter]

--------------------------------------
--UDF VALUES
--------------------------------------
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
	select --fieldtitle, udf.casnOrgCaseTypeID,
		def.udfnUDFID as [udvnudfid],
		'Case Wizard' as [udvsscreenname],
		'C'			  as [udvsudfctg],
		casnCaseID	  as [udvnrelatedid],
		0			  as [udvnsubrelatedid],
		udf.FieldVal  as [udvsudfvalue],
		368			  as [udvnrecuserid],
		GETDATE()	  as [udvddtcreated],
		null		  as [udvnmodifyuserid],
		null		  as [udvddtmodified],
		null		  as [udvnlevelno]
	--select *
	from CaseUDF_Incident udf
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = udf.casnOrgCaseTypeID
			and def.udfsUDFName = FieldTitle
			and def.udfsScreenName = 'Case Wizard'

alter table sma_trn_udfvalues enable trigger all
go
