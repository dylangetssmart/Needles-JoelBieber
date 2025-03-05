use JoelBieberSA_Needles
go

SELECT * FROM JoelBieberNeedles..matter m


SELECT * FROM JoelBieberNeedles..cases c where c.matcode = 'SAS'
SELECT cas.casnCaseID, cas.cassCaseNumber, cas.casnOrgCaseTypeID FROM sma_TRN_Cases cas where cas.cassCaseNumber in (226176,
226177,
226199,
226200,
226223)
SELECT * FROM sma_MST_CaseType smct where smct.cstnCaseTypeID = 1590


join caseTypeMixture mix
		on mix.matcode = 'SAS'








SELECT distinct cststype, cstnCaseTypeID, ct.*
FROM sma_mst_casetype ct
JOIN sma_trn_Cases cas on cas.casnOrgCaseTypeID = ct.cstnCaseTypeID
where cststype IN ('Auto Accident TT','Auto Accidents TT','Auto Accident SE','Auto Accidents SE')


--keep Auto Accident TT	1536  remove Auto Accidents TT	1633
--keep Auto Accident SE	1579  remove Auto Accidents SE	1632

--drop TABLE #casetypeMap
SELECT DISTINCT ct.cstnCaseTypeID, cststype, smcst.cstnCaseSubTypeID, smcst.cstsDscrptn, NULL AS NewCaseTypeID, NULL AS NewSubTypeID
INTO #casetypeMap
FROM sma_mst_casetype ct
JOIN sma_trn_Cases cas on cas.casnOrgCaseTypeID = ct.cstnCaseTypeID
LEFT JOIN sma_MST_CaseSubType smcst on smcst.cstnCaseSubTypeID = cas.casnCaseTypeID
where cststype IN ('Auto Accidents TT','Auto Accidents SE')


--UPDATE NEW CASETYPE/SUBTYPE VALUES
UPDATE #casetypeMap
SET NewCaseTypeID = ct.cstnCaseTypeID,
	NewSubTypeID = smcst.cstnCaseSubTypeID
--select m.*, ct.cstsType, ct.cstnCaseTypeID, smcst.cstsDscrptn, smcst.cstnCaseSubTypeID
FROM #casetypeMap m
JOIN sma_mst_casetype ct ON ct.cstsType = case WHEN m.cststype = 'Auto Accidents TT' then 'Auto Accident TT' 
												WHEN m.cststype = 'Auto Accidents SE' then 'Auto Accident SE' END
LEFT JOIN [sma_MST_CaseSubTypeCode] cod on cod.stcsDscrptn = m.cstsDscrptn
LEFT JOIN sma_MST_CaseSubType smcst ON smcst.cstnGroupID = ct.cstnCaseTypeID AND smcst.cstnTypeCode = cod.stcnCodeId


--INSERT SUBTYPES IF THEY DO NOT EXIST
INSERT INTO [dbo].[sma_MST_CaseSubTypeCode] ( stcsDscrptn )
SELECT DISTINCT cstsDscrptn from #casetypeMap 
    EXCEPT
SELECT stcsDscrptn from [dbo].[sma_MST_CaseSubTypeCode]
GO

INSERT INTO [sma_MST_CaseSubType] ( [cstsCode], [cstnGroupID], [cstsDscrptn], [cstnRecUserId], [cstdDtCreated], [cstnModifyUserID], 
      [cstdDtModified], [cstnLevelNo], [cstbDefualt], [saga], [cstnTypeCode] )
SELECT  
		null				as [cstsCode],
		NewCaseTypeID		as [cstnGroupID],
		ct.cstsDscrptn        as [cstsDscrptn], 
		368 				as [cstnRecUserId],
		getdate()			as [cstdDtCreated],
		null				as [cstnModifyUserID],
		null				as [cstdDtModified],
		null				as [cstnLevelNo],
		1					as [cstbDefualt],
		null				as [saga],
		(select stcnCodeId from [sma_MST_CaseSubTypeCode] where stcsDscrptn=ct.cstsDscrptn) as [cstnTypeCode] 
from #casetypeMap ct
LEFT JOIN [sma_MST_CaseSubTypeCode] cod on cod.stcsDscrptn = ct.cstsDscrptn
LEFT JOIN [sma_MST_CaseSubType] sub on sub.[cstnGroupID] =ct.NewCaseTypeID and sub.cstnTypeCode = cod.stcnCodeId
WHERE sub.cstnCaseSubTypeID IS NULL


select * from #casetypeMap ct

--------------------------------------------------------------
--plaintiff and defendant roles
--------------------------------------------------------------
INSERT INTO sma_MST_SubRole ( sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode)
SELECT T.sbrnRoleID,T.sbrsDscrptn, 1536, T.sbrnTypeCode
FROM sma_MST_SubRole t
WHERE sbrnCaseTypeID=1633
EXCEPT SELECT sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode FROM sma_MST_SubRole

SELECT T.sbrnRoleID,T.sbrsDscrptn, 1579, T.sbrnTypeCode
FROM sma_MST_SubRole t
WHERE sbrnCaseTypeID=1632
EXCEPT SELECT sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode FROM sma_MST_SubRole



SELECT map.*, cas.casnCaseID, cas.casnOrgCaseTypeID CaseType, CAS.casnCaseTypeID caseSubType
INTO #cases
from #casetypeMap map
JOIN sma_trn_Cases cas on cas.casnOrgCaseTypeID = map.cstnCaseTypeID and isnull(cas.casnCaseTypeID,'') = isnull(map.cstnCaseSubTypeID,'')



select p.plnnPlaintiffID, cas.casncaseid, p.plnnrole, sr.sbrsDscrptn, srnew.sbrnSubRoleId as NEWSubRoleID, srnew.sbrsDscrptn as NEWSubRoleDescr
INTO #PLAINTIFF
from #cases cas
JOIN sma_TRN_Plaintiff p on p.plnnCaseID = cas.casnCaseID
JOIN sma_MST_SubRole sr on p.plnnRole = sr.sbrnSubRoleId
LEFT JOIN sma_MST_SubRole srNEW on srnew.sbrsDscrptn = sr.sbrsDscrptn and srnew.sbrnCaseTypeID = cas.newCaseTypeID

select d.defnDefendentID, cas.casncaseid, d.defnSubRole, sr.sbrsDscrptn, srnew.sbrnSubRoleId as NEWSubRoleID, srnew.sbrsDscrptn as NEWSubRoleDescr
INTO #DEFENDANT
from #CASES cas
JOIN sma_TRN_Defendants d on d.defnCaseID = cas.casnCaseID
JOIN sma_MST_SubRole sr on d.defnSubRole = sr.sbrnSubRoleId
LEFT JOIN sma_MST_SubRole srNEW on srnew.sbrsDscrptn = sr.sbrsDscrptn and srnew.sbrnCaseTypeID = cas.newCaseTypeID

select * FROM #cases
select * from #PLAINTIFF p
select * FROM #DEFENDANT d


update sma_TRN_Defendants
SET defnSubRole = NEWSubRoleID
FROM #DEFENDANT d
JOIN sma_trn_Defendants def on d.defnDefendentID =def.defnDefendentID

update sma_TRN_Plaintiff
SET plnnRole = NEWSubRoleID
--select pl.*
FROM #PLAINTIFF p
JOIN sma_TRN_Plaintiff pl on pl.plnnPlaintiffID = p.plnnPlaintiffID


alter table sma_trn_Cases disable trigger all
GO
update sma_trn_Cases 
SET casnOrgCaseTypeID = newCaseTypeID,
	casnCaseTypeID = NewSubTypeID
--select * 
FROM #Cases c
JOIN sma_trn_cases cas on c.casnCaseID = cas.casnCaseID

alter table sma_trn_Cases enable trigger all
GO




--keep Auto Accident TT	1536  remove Auto Accidents TT	1633
--keep Auto Accident SE	1579  remove Auto Accidents SE	1632


delete from sma_MST_CaseType WHERE cstnCaseTypeID in (1632, 1633)



delete
from sma_MST_CaseSubType  
WHERE cstnGroupID NOT IN (SELECT cstnCaseTypeID FROM sma_MST_CaseType)

alter TABLE sma_MST_SubRole disable trigger all
go
delete from sma_MST_SubRole 
WHERE sbrnCaseTypeID IN (1632, 1633)
go
ALTER TABLE sma_MST_SubRole enable trigger all
go
