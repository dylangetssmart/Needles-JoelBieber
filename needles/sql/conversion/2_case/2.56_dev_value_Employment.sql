/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [JoelBieberSA_Needles]
go



if not exists (
		select
			1
		from [sma_MST_WagesTypes]
		where wgtsCode = 'LOST'
	)
begin
	insert into [sma_MST_WagesTypes]
		(
		wgtsCode,
		wgtsDscrptn,
		wgtnRecUserID,
		wgtdDtCreated,
		wgtnModifyUserID,
		wgtdDtModified,
		wgtnLevelNo
		)
	values (
	'LOST',
	'Lost Wages',
	368,
	GETDATE(),
	null,
	null,
	null
	)
end

select
	*
from [sma_MST_WagesTypes]

/* ####################################
Insert Lost Wages
*/
insert into [sma_TRN_LostWages]
	(
	[ltwnEmploymentID],
	[ltwsType],
	[ltwdFrmDt],
	[ltwdToDt],
	[ltwnAmount],
	[ltwnAmtPaid],
	[ltwnLoss],
	[Comments],
	[ltwdMDConfReqDt],
	[ltwdMDConfDt],
	[ltwdEmpVerfReqDt],
	[ltwdEmpVerfRcvdDt],
	[ltwnRecUserID],
	[ltwdDtCreated],
	[ltwnModifyUserID],
	[ltwdDtModified],
	[ltwnLevelNo]
	)
	select distinct
		e.empnEmploymentID as [ltwnemploymentid]		--sma_trn_employment ID
		,
		(
			select
				wgtnWagesTypeID
			from [sma_MST_WagesTypes]
			where wgtsDscrptn = 'Lost Wages'
		)				   as [ltwstype]   			--[sma_MST_WagesTypes].wgtnWagesTypeID
		-- ,case
		-- 	when ud.Last_Date_Worked between '1/1/1900' and '6/6/2079'
		-- 		then ud.Last_Date_Worked
		-- 	else null 
		-- 	end					as [ltwdFrmDt]
		-- ,case
		-- 	when ud.Returned_to_Work between '1/1/1900' and '6/6/2079'
		-- 		then ud.Returned_to_Work 
		-- 	when isdate(ud.returntowork) = 1 and ud.returntowork between '1/1/1900' and '6/6/2079'
		-- 		then ud.returntowork 
		-- 	else null
		-- 	end					as [ltwdToDt]
		,
		null			   as [ltwdfrmdt],
		null			   as [ltwdtodt],
		null			   as [ltwnamount],
		null			   as [ltwnamtpaid],
		v.total_value	   as [ltwnloss]
		-- ,isnull('Return to work: ' + nullif(convert(Varchar,ud.returntowork),'') + char(13),'') +
		-- ''						as [comments]
		,
		null			   as [comments],
		null			   as [ltwdmdconfreqdt],
		null			   as [ltwdmdconfdt],
		null			   as [ltwdempverfreqdt],
		null			   as [ltwdempverfrcvddt],
		368				   as [ltwnrecuserid],
		GETDATE()		   as [ltwddtcreated],
		null			   as [ltwnmodifyuserid],
		null			   as [ltwddtmodified],
		null			   as [ltwnlevelno]
	-- employment record id: case > plaintiff > employment (value has caseid)
	from JoelBieberNeedles..value_indexed v
	join sma_trn_Cases cas
		on cas.cassCaseNumber = v.case_id
	join sma_trn_plaintiff p
		on p.plnnCaseID = cas.casnCaseID
			and p.plnbIsPrimary = 1
	inner join sma_TRN_Employment e
		on e.empnPlaintiffID = p.plnnPlaintiffID
	where v.code = 'LW'

-- FROM JoelBieberNeedles..user_tab4_data ud
-- JOIN EmployerTemp et on et.employer = ud.employer and et.employer_address = ud.Employer_Address
-- JOIN IndvOrgContacts_Indexed ioc on ioc.SAGA = et.empID and ioc.[Name] = et.employer
-- JOIN [sma_TRN_Employment] e on  e.empnPlaintiffID = p.plnnPlaintiffID and empnEmployerID = ioc.CID


---------------------------------------
-- Update Special Damages
---------------------------------------
alter table [sma_TRN_SpDamages] disable trigger all
go

insert into [sma_TRN_SpDamages]
	(
	[spdsRefTable],
	[spdnRecordID],
	[spdnRecUserID],
	[spddDtCreated],
	[spdnLevelNo],
	spdnBillAmt,
	spddDateFrom,
	spddDateTo
	)
	select distinct
		'LostWages'		   as spdsreftable,
		lw.ltwnLostWagesID as spdnrecordid,
		lw.ltwnRecUserID   as [spdnrecuserid],
		lw.ltwdDtCreated   as spdddtcreated,
		null			   as [spdnlevelno],
		lw.[ltwnLoss]	   as spdnbillamt,
		lw.ltwdFrmDt	   as spdddatefrom,
		lw.ltwdToDt		   as spdddateto
	from sma_TRN_LostWages lw


alter table [sma_TRN_SpDamages] enable trigger all
go
