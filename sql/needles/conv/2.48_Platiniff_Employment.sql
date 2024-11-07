/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-11-07
Description: Create employment records and corresponding lost wage records

1.
2.

select * from JoelBieberNeedles..value v WHERE code = 'lw' AND v.case_id = 209147
-- value_id = 124956
-- party_id = 38608 -> names, party (plaintiff)
-- provider = 39320 -> names (does not go to party)
--select * FROM JoelBieberNeedles..party p WHERE p.party_id = 38608
select * from JoelBieberNeedles..names n WHERE n.names_id = 38608 or n.names_id = 39320
select * from JoelBieberSA_Needles..IndvOrgContacts_Indexed ioci WHERE ioci.SAGA = 39320

##########################################################################################################################
*/

USE JoelBieberSA_Needles
GO
/*
alter table [dbo].[sma_TRN_Employment] disable trigger all
delete from [dbo].[sma_TRN_Employment] 
DBCC CHECKIDENT ('[dbo].[sma_TRN_Employment]', RESEED, 0);
alter table [dbo].[sma_TRN_Employment] enable trigger all
*/

--sp_help [sma_TRN_Employment]

ALTER TABLE sma_TRN_Employment
	ALTER COLUMN [empsJobTitle] varchar(500)
GO


/* ####################################
1.0 -- From value
*/

INSERT INTO [dbo].[sma_TRN_Employment]
           ([empnPlaintiffID]
           ,[empnEmprAddressID]
           ,[empnEmployerID]
           ,[empnContactPersonID]
           ,[empnCPAddressId]
           ,[empsJobTitle]
           ,[empnSalaryFreqID]
           ,[empnSalaryAmt]
           ,[empnCommissionFreqID]
           ,[empnCommissionAmt]
           ,[empnBonusFreqID]
           ,[empnBonusAmt]
           ,[empnOverTimeFreqID]
           ,[empnOverTimeAmt]
           ,[empnOtherFreqID]
           ,[empnOtherCompensationAmt]
           ,[empsComments]
           ,[empbWorksOffBooks]
           ,[empsCompensationComments]
           ,[empbWorksPartiallyOffBooks]
           ,[empbOnTheJob]
           ,[empbWCClaim]
           ,[empbContinuing]
           ,[empdDateHired]
           ,[empnUDF1]
           ,[empnUDF2]
           ,[empnRecUserID]
           ,[empdDtCreated]
           ,[empnModifyUserID]
           ,[empdDtModified]
           ,[empnLevelNo]
           ,[empnauthtodefcoun]
           ,[empnauthtodefcounDt]
           ,[empnTotalDisability]
           ,[empnAverageWeeklyWage]
           ,[empnEmpUnion]
           ,[NotEmploymentReasonID]
           ,[empdDateTo]
           ,[empsDepartment]
           ,[empdSent]
           ,[empdReceived]
           ,[empnStatusId]
           ,[empnWorkSiteId])
SELECT
	(
		select plnnPlaintiffID
		from sma_trn_plaintiff
		where plnnCaseID = cas.casncaseid and plnbIsPrimary = 1
	)										as [empnPlaintiffID]		--Plaintiff ID
	,a.addnAddressID						as [empnEmprAddressID]		--employer org AID
	,ioci.CID								as [empnEmployerID]			--employer org CID
	,null									as [empnContactPersonID]	--indv CID
	,null									as [empnCPAddressId]		--indv AID
    ,null									as [empsJobTitle]
    ,NULL									as [empnSalaryFreqID]
    ,NULL									as [empnSalaryAmt]
    ,null									as [empnCommissionFreqID]	--Commission: (frequency)  sma_mst_frequencies.fqmnFrequencyID
    ,null									as [empnCommissionAmt]		--Commission Amount
	,null									as [empnBonusFreqID]		--Bonus: (frequency)  sma_mst_frequencies.fqmnFrequencyID
	,null									as [empnBonusAmt]			--Bonus Amount
	,null									as [empnOverTimeFreqID]	--Overtime (frequency)  sma_mst_frequencies.fqmnFrequencyID
	,null									as [empnOverTimeAmt]		--Overtime Amoun
	,null									as [empnOtherFreqID]		--Other Compensation (frequency)  sma_mst_frequencies.fqmnFrequencyID
    ,null									as [empnOtherCompensationAmt]	--Other Compensation Amount
	,null 									as [empsComments]
    ,null 									as [empbWorksOffBooks]
	,null									as empsCompensationComments			-- Compensation Comments
	,null									as [empbWorksPartiallyOffBooks]	--bit
	,null									as [empbOnTheJob]				--On the job injury? bit
	,null									as [empbWCClaim]				--W/C Claim?  bit
	,null									as [empbContinuing]			--continuing?  bit
	,null									as [empdDateHired]
	,null									as [empnUDF1]
	,null									as [empnUDF2]
	,368									as [empnRecUserID]
	,getdate()								as [empdDtCreated]
	,null									as [empnModifyUserID]
	,null									as [empdDtModified]
	,null									as [empnLevelNo]
	,null									as [empnauthtodefcoun]		--Auth. to defense cousel:  bit
	,null									as [empnauthtodefcounDt]	--Auth. to defense cousel:  date
	,null									as [empnTotalDisability]	--Temporary Total Disability (TTD)
	,null									as [empnAverageWeeklyWage]		--Average weekly wage (AWW)
	,null									as [empnEmpUnion]			--Unique Contact ID of Union
	,null									as [NotEmploymentReasonID]		--1=Minor; 2=Retired; 3=Unemployed; (MST?)
	,null									as [empdDateTo]
	,null									as [empsDepartment]
	,null									as [empdSent]
	,null									as [empdReceived]
	,null									as [empnStatusId]		--status  sma_MST_EmploymentStatuses.ID
	,null									as [empnWorkSiteId]
FROM JoelBieberNeedles..value v
	JOIN sma_trn_Cases cas
		on cas.cassCaseNumber = convert(varchar,v.case_id)
	join IndvOrgContacts_Indexed ioci
		on ioci.saga = v.provider
		AND ioci.CTG = 2
	--select * FROM 
	JOIN sma_MST_Address a
		on a.addnContactID = ioci.CID
		AND a.addnContactCtgID = 2
WHERE v.code = 'LW'

--FROM NeedlesSLF..user_party_data ud

--	inner join SANeedlesSLF..Employer_Address_Helper help
--		on help.case_id = ud.case_id
--		and help.party_id = ud.party_id


	-- join Employer_Address_Helper help
	-- 	on help.case_id = upd.case_id
	-- 	and help.party_id = upd.party_id

	
	-- Link to SA Contact Card via:
	-- user_tab_data -> user_tab_name -> names -> IndvOrgContacts_Indexed
	-- join NeedlesSLF.dbo.user_tab_name utn
	-- 	on ud.tab_id = utn.tab_id
	-- join NeedlesSLF.dbo.names n
	-- 	on utn.user_name = n.names_id
	

	--join SANeedlesSLF..sma_MST_Address A
	--	on A.addnContactID = org.connContactID
	--	and a.addnContactCtgID = org.connContactCtg


	-- from NeedlesSLF..user_party_data upd
	-- join sma_MST_OrgContacts org
	-- 	on org.saga = upd.case_id
	-- 	and org.saga_ref = 'upd_employer'

	-- -- Indv
	-- left join SANeedlesSLF.dbo.IndvOrgContacts_Indexed ioci
	-- 	on n.names_id = ioci.saga
	-- 	and ioci.CTG = 1

	-- -- Org
	-- left join SANeedlesSLF.dbo.IndvOrgContacts_Indexed ioco
	-- 	on n.names_id = ioco.saga
	-- 	and ioco.CTG = 2

--WHERE isnull(ud.Annual_Income_Plaintiff,'')<>''
GO



/* ####################################
Insert Lost Wages
*/
INSERT INTO [sma_TRN_LostWages]
(
	   [ltwnEmploymentID]
      ,[ltwsType]
      ,[ltwdFrmDt]
      ,[ltwdToDt]
      ,[ltwnAmount]
      ,[ltwnAmtPaid]
      ,[ltwnLoss]
	  ,[Comments]
      ,[ltwdMDConfReqDt]
      ,[ltwdMDConfDt]
      ,[ltwdEmpVerfReqDt]
      ,[ltwdEmpVerfRcvdDt]
      ,[ltwnRecUserID]
      ,[ltwdDtCreated]
      ,[ltwnModifyUserID]
      ,[ltwdDtModified]
      ,[ltwnLevelNo]
)
SELECT DISTINCT
		e.empnEmploymentID		as [ltwnEmploymentID]		--sma_trn_employment ID
		,(
			select wgtnWagesTypeID
			from [sma_MST_WagesTypes]
			where wgtsDscrptn='Salary'
		)						as [ltwsType]   			--[sma_MST_WagesTypes].wgtnWagesTypeID
		 ,case
		 	when v.start_date between '1/1/1900' and '6/6/2079'
		 		then v.start_date
		 	else null 
		 	end					as [ltwdFrmDt]
		 ,case
		 	when v.stop_date between '1/1/1900' and '6/6/2079'
		 		then v.stop_date
		 	else null
		 	end					as [ltwdToDt]
		--,null					as [ltwdFrmDt]
		--,null					as [ltwdToDt]
		,NULL					as [ltwnAmount]
		,null					as [ltwnAmtPaid]
		,v.total_value			as [ltwnLoss]				
		-- ,isnull('Return to work: ' + nullif(convert(Varchar,ud.returntowork),'') + char(13),'') +
		-- ''						as [comments]
		,null 					as [comments]
		,null					as [ltwdMDConfReqDt]
		,null					as [ltwdMDConfDt]
		,null					as [ltwdEmpVerfReqDt]
		,null					as [ltwdEmpVerfRcvdDt]
		,368					as [ltwnRecUserID]
		,getdate()				as [ltwdDtCreated]
		,NULL					as [ltwnModifyUserID]
		,NULL					as [ltwdDtModified]
		,null					as [ltwnLevelNo]
-- employment record id: case > plaintiff > employment (value has caseid)
from JoelBieberNeedles..value_indexed v
JOIN sma_trn_Cases cas
	on cas.cassCaseNumber = v.case_id
JOIN sma_trn_plaintiff p
	on p.plnnCaseID = cas.casnCaseID
	and p.plnbIsPrimary = 1
inner join sma_TRN_Employment e
	on e.empnPlaintiffID = p.plnnPlaintiffID
where v.code = 'LW'

-- FROM NeedlesSLF..user_tab4_data ud
-- JOIN EmployerTemp et on et.employer = ud.employer and et.employer_address = ud.Employer_Address
-- JOIN IndvOrgContacts_Indexed ioc on ioc.SAGA = et.empID and ioc.[Name] = et.employer
-- JOIN [sma_TRN_Employment] e on  e.empnPlaintiffID = p.plnnPlaintiffID and empnEmployerID = ioc.CID


---------------------------------------
-- Update Special Damages
---------------------------------------
ALTER TABLE [sma_TRN_SpDamages] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_SpDamages]
([spdsRefTable],[spdnRecordID],[spdnRecUserID],[spddDtCreated],[spdnLevelNo], spdnBillAmt, spddDateFrom, spddDateTo)
SELECT DISTINCT
    'LostWages'				as spdsRefTable,
    lw.ltwnLostWagesID		as spdnRecordID,
    lw.ltwnRecUserID		as [spdnRecUserID],
	lw.ltwdDtCreated		as spddDtCreated,
	null					as [spdnLevelNo], 
	lw.[ltwnLoss]			as spdnBillAmt,
	lw.ltwdFrmDt			as spddDateFrom,
	lw.ltwdToDt				as spddDateTo
FROM sma_TRN_LostWages LW


ALTER TABLE [sma_TRN_SpDamages] ENABLE TRIGGER ALL
GO
