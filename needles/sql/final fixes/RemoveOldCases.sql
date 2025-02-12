

select cas.casnCaseID
INTO #caseDel
--select cas.*
from sma_trn_incidents i
JOIN sma_trn_Cases cas on cas.casncaseid = i.CaseId
where IncidentDate < '1/1/2010'


delete from sma_TRN_Incidents WHERE caseid IN (Select casncaseid from #caseDel)
delete from sma_TRN_CaseStaff WHERE cssnCaseID IN (Select casncaseid from #caseDel)
delete from sma_TRN_CaseStatus WHERE cssnCaseID IN (Select casncaseid from #caseDel)
delete from sma_TRN_lawfirms WHERE [lwfnContactID] in (select defnDefendentID from sma_TRN_Defendants where defnCaseID IN (Select casncaseid from #caseDel) )
delete from [sma_TRN_Employment] WHERE [empnPlaintiffID] IN (select plnnplaintiffID from sma_TRN_Plaintiff WHERE plnncaseid IN (Select casncaseid from #caseDel))
delete from sma_TRN_Plaintiff WHERE plnncaseid IN (Select casncaseid from #caseDel)
delete from sma_TRN_Defendants WHERE defnCaseID IN (Select casncaseid from #caseDel)

delete from sma_TRN_MedicalProviderRequest where medprvcaseid IN (Select casncaseid from #caseDel) 

delete From [sma_TRN_SpDamages] where spdsRefTable = 'Hospitals' and spdnRecordID IN (select hosnHospitalID from sma_TRN_Hospitals WHERE hosnCaseID IN (Select casncaseid from #caseDel) )
delete from sma_TRN_Hospitals WHERE hosnCaseID IN (Select casncaseid from #caseDel)
delete from sma_TRN_InsuranceCoverage where incnCaseID IN (Select casncaseid from #caseDel)
delete from sma_TRN_Injury WHERE injncaseid IN (Select casncaseid from #caseDel)

delete from sma_TRN_TaskNew WHERE tskcaseid IN (Select casncaseid from #caseDel)
delete from sma_TRN_lienors WHERE lnrncaseid IN (Select casncaseid from #caseDel)
delete from sma_TRN_LitigationHearing WHERE hrgnCaseID IN (Select casncaseid from #caseDel)
delete from sma_TRN_CalendarAppointments WHERE CaseID IN (Select casncaseid from #caseDel)
delete from [sma_TRN_CaseUserTime] WHERE [cutnCaseID] IN (Select casncaseid from #caseDel)
delete from sma_TRN_othcases WHERE otcnRelCaseID IN (Select casncaseid from #caseDel)
delete from sma_TRN_othcases WHERE otcnOrgCaseID IN (Select casncaseid from #caseDel)
delete from [sma_TRN_PoliceReports] WHERE pornCaseID IN (Select casncaseid from #caseDel)
delete from [sma_TRN_Vehicles] WHERE vehnCaseID IN (Select casncaseid from #caseDel)
delete from sma_trn_pdadvt WHERE advnCaseid IN (Select casncaseid from #caseDel)
delete from [sma_TRN_OtherReferral] WHERE [otrnCaseID] IN (Select casncaseid from #caseDel)
Delete from [sma_trn_caseJudgeorClerk] where crtDocketID IN (select [crdnCourtDocketID] from [sma_TRN_CourtDocket] WHERE crdnCourtsid IN (select crtnPKCourtsID from [sma_TRN_Courts] WHERE crtnCaseID IN (Select casncaseid from #caseDel) ) )
delete from [sma_TRN_CourtDocket] WHERE crdnCourtsid IN (select crtnPKCourtsID from [sma_TRN_Courts] WHERE crtnCaseID IN (Select casncaseid from #caseDel) )
delete from [sma_TRN_Courts] WHERE crtnCaseID IN (Select casncaseid from #caseDel)

alter table sma_trn_Documents disable trigger all
go
delete from sma_TRN_Documents WHERE docnCaseID IN (Select casncaseid from #caseDel)
go
alter table sma_trn_Documents enable trigger all
go

delete From sma_trn_lawyerreferral where lwrnCaseID IN (Select casncaseid from #caseDel)
delete from sma_TRN_PdAdvt where advnCaseID IN (Select casncaseid from #caseDel)
delete From sma_TRN_sols where solnCaseID IN (Select casncaseid from #caseDel)
delete From sma_trn_disbursement where disncaseid IN (Select casncaseid from #caseDel)
delete from sma_TRN_Negotiations where negnCaseID IN (Select casncaseid from #caseDel)
delete From sma_TRN_Settlements where stlncaseid IN (Select casncaseid from #caseDel)
delete From sma_TRN_emails where emlnCaseID IN (Select casncaseid from #caseDel)
delete from sma_TRN_UDFValues where udvnRelatedID IN (Select casncaseid from #caseDel)

delete from sma_MST_OtherCasesContact where othercasesid in (select casncaseid from #caseDel)
delete from sma_trn_Cases where casncaseid IN (Select casncaseid from #caseDel)
