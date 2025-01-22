
use [ShinerSA]
go

/*
alter table [sma_TRN_Settlements] disable trigger all
delete [sma_TRN_Settlements]
DBCC CHECKIDENT ('[sma_TRN_Settlements]', RESEED, 1);
alter table [sma_TRN_Settlements] enable trigger all
*/

---(0)---
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and Object_ID = OBJECT_ID(N'sma_TRN_Settlements')
	)
begin
	alter table [sma_TRN_Settlements] add [saga_char] VARCHAR(100)
end
go

---(0)---
------------------------------------------------
--INSERT SETTLEMENT TYPES
------------------------------------------------
insert into [sma_MST_SettlementType]
	(
	SettlTypeName
	)
	select
		'Settlement'
	except
	select
		SettlTypeName
	from [sma_MST_SettlementType]
go


----(1)----(  specified items go to settlement rows )
alter table [sma_TRN_Settlements] disable trigger all
go

insert into [sma_TRN_Settlements]
	(
	stlnCaseID,
	stlnSetAmt,
	stlnNet,
	stlnNetToClientAmt,
	stlnPlaintiffID,
	stlnStaffID,
	stlnLessDisbursement,
	stlnGrossAttorneyFee,
	stlnForwarder,  --referrer
	stlnOther,
	InterestOnDisbursement,
	stlsComments,
	stlTypeID,
	stldSettlementDate,
	stldDateOfDisbursement,
	saga_char
	)
	select
		cas.casnCaseID					   as stlncaseid,
		litify_pm__Amount_Due_to_Client__c as stlnsetamt,
		null							   as stlnnet,
		litify_pm__Amount_Due_to_Client__c as stlnnettoclientamt,
		-1								   as stlnplaintiffid,
		ioc.CID							   as stlnstaffid,
		null							   as stlnlessdisbursement,
		litify_pm__Gross_Attorney_Fee__c   as stlngrossattorneyfee,
		null							   as stlnforwarder,    --Referrer
		litify_pm__Fees_Due_to_Others__c   as stlnother,
		null							   as interestondisbursement,
		--  ,ISNULL('Attorney Credited:' + NULLIF(ioc.[name], '') + CHAR(13), '') +
		--ISNULL('Reason:' + NULLIF(r.litify_pm__Reason__c, '') + CHAR(13), '') +
		--ISNULL('Resolution Type:' + NULLIF(r.litify_pm__Resolution_type__c, '') + CHAR(13), '') +
		--ISNULL('Resolved By:' + NULLIF(iocr.[name], '') + CHAR(13), '') +
		--ISNULL('Payor:' + NULLIF(iocp.[name], '') + CHAR(13), '') +
		--ISNULL('Payor Type:' + NULLIF(r.[litify_pm__Payor_Type__c], '') + CHAR(13), '') +
		--ISNULL('Settlement Verdict Amt:' + NULLIF(CONVERT(VARCHAR, r.[litify_pm__Settlement_verdict_amount__c]), '') + CHAR(13), '') +
		--ISNULL('Total Expenses:' + NULLIF(CONVERT(VARCHAR, r.[litify_pm__total_expenses__c]), '') + CHAR(13), '') +
		--ISNULL('Total Damages:' + NULLIF(CONVERT(VARCHAR, r.[litify_pm__total_Damages__c]), '') + CHAR(13), '') +
		--ISNULL('Check Mailed Date:' + NULLIF(CONVERT(VARCHAR, r.[Check_Mailed_Date__c]), '') + CHAR(13), '') +
		--ISNULL('Judge Signed Date:' + NULLIF(CONVERT(VARCHAR, r.[Judge_signed_Date__c]), '') + CHAR(13), '') +
		--ISNULL('Closing Statement Received Date:' + NULLIF(CONVERT(VARCHAR, r.[Closing_Stmt_Received_date__c]), '') + CHAR(13), '') +
		''								   as [stlscomments]
		--ISNULL('Client Signed Date:' + NULLIF(CONVERT(VARCHAR, r.[Client_Signed_Date__c]), '') + CHAR(13), '') +
		--ISNULL('Sent to Attorney Date:' + NULLIF(CONVERT(VARCHAR, r.[Sent_To_Attorney_Date__c]), '') + CHAR(13), '') +
		--ISNULL('Release Dismiss Date:' + NULLIF(CONVERT(VARCHAR, r.[Release_dismiss_date__c]), '') + CHAR(13), '') +
		,
		(
			select
				ID
			from [sma_MST_SettlementType]
			where SettlTypeName = 'Settlement'
		)								   as stltypeid,
		case
			when r.litify_pm__resolution_Date__c between '1900-01-01' and '2079-06-06'
				then r.litify_pm__resolution_Date__c
			else null
		end								   as stldsettlementdate,
		null							   as stlddateofdisbursement
		--  ,CASE
		--	WHEN r.Disbursed_Date__c BETWEEN '1900-01-01' AND '2079-06-06'
		--		THEN r.Disbursed_Date__c
		--	ELSE NULL
		--END AS stldDateOfDisbursement
		,
		r.id							   as saga_char
	--select *
	from [ShinerLitify]..[litify_pm__resolution__c] r
	join sma_trn_Cases cas
		on cas.saga_char = r.litify_pm__Matter__c
	left join IndvOrgContacts_Indexed ioc
		on ioc.saga_char = r.litify_pm__Attorney_Credited__c
	left join IndvOrgContacts_Indexed iocr
		on iocr.saga_char = r.litify_pm__Resolved_by__c
	left join IndvOrgContacts_Indexed iocp
		on iocp.saga_char = r.litify_pm__Payor__c
	where r.litify_pm__Matter__c = 'a0L8Z00000hOJNgUAO'
go

alter table [sma_TRN_Settlements] enable trigger all
go

