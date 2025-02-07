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

/*

delete [sma_TRN_Negotiations]
DBCC CHECKIDENT ('[sma_TRN_Negotiations]', RESEED, 1);
alter table [sma_TRN_Negotiations] enable trigger all

alter table [sma_TRN_Settlements] disable trigger all
delete [sma_TRN_Settlements]
DBCC CHECKIDENT ('[sma_TRN_Settlements]', RESEED, 1);

*/

--(0)--

alter table [sma_TRN_Negotiations] disable trigger all

if not exists (
		select
			*
		from sys.columns
		where Name = N'SettlementAmount'
			and object_id = OBJECT_ID(N'sma_TRN_Negotiations')
	)
begin
	alter table sma_TRN_Negotiations
	add SettlementAmount DECIMAL(18, 2) null
end
go

--(1)--
insert into [sma_TRN_Negotiations]
	(
	[negnCaseID], [negsUniquePartyID], [negdDate], [negnStaffID], [negnPlaintiffID], [negbPartiallySettled], [negnClientAuthAmt], [negbOralConsent], [negdOralDtSent], [negdOralDtRcvd], [negnDemand], [negnOffer], [negbConsentType], [negnRecUserID], [negdDtCreated], [negnModifyUserID], [negdDtModified], [negnLevelNo], [negsComments], [SettlementAmount]
	)
	select
		CAS.casnCaseID					   as [negnCaseID],
		('I' + CONVERT(VARCHAR, (
			select top 1
				incnInsCovgID
			from [sma_TRN_InsuranceCoverage] INC
			where INC.incnCaseID = CAS.casnCaseID
				and INC.saga = INS.insurance_id
				and INC.incnInsContactID = (
					select top 1
						connContactID
					from [sma_MST_OrgContacts]
					where saga = INS.insurer_id
				)
		)))								   
		as [negsUniquePartyID],
		case
			when NEG.neg_date between '1900-01-01' and '2079-12-31'
				then NEG.neg_date
			else null
		end								   as [negdDate],
		--  ,(
		--	SELECT
		--		usrnContactiD
		--	FROM sma_MST_Users
		--	WHERE source_id = NEG.staff
		--)			   
		--AS [negnStaffID]
		COALESCE(m.SAUserID, u.usrnUserID) as negnStaffID, -- Use SAUserID if available, otherwise fallback to usrnUserID
		-1								   as [negnPlaintiffID],
		null							   as [negbPartiallySettled],
		case
			when NEG.kind = 'Client Auth.'
				then NEG.amount
			else null
		end								   as [negnClientAuthAmt],
		null							   as [negbOralConsent],
		null							   as [negdOralDtSent],
		null							   as [negdOralDtRcvd],
		case
			when NEG.kind = 'Demand'
				then NEG.amount
			else null
		end								   as [negnDemand],
		case
			when NEG.kind in ('Offer', 'Conditional Ofr')
				then NEG.amount
			else null
		end								   as [negnOffer],
		null							   as [negbConsentType],
		368,
		GETDATE(),
		368,
		GETDATE(),
		0								   as [negnLevelNo],
		ISNULL(NEG.kind + ' : ' + NULLIF(CONVERT(VARCHAR, NEG.amount), '') + CHAR(13) + CHAR(10), '') +
		NEG.notes						   as [negsComments],
		case
			when NEG.kind = 'Settled'
				then NEG.amount
			else null
		end								   as [SettlementAmount]
	from JoelBieberNeedles.[dbo].[negotiation] NEG
	left join JoelBieberNeedles.[dbo].[insurance_Indexed] INS
		on INS.insurance_id = NEG.insurance_id
	join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = NEG.case_id
	left join [JoelBieberSA_Needles].[conversion].[Insurance_Contacts_Helper] MAP
		on INS.insurance_id = MAP.insurance_id
	left join [conversion].[imp_user_map] m
		on m.StaffCode = neg.staff
	left join [sma_MST_Users] u
		on u.source_id = neg.staff

-----------------
/*

INSERT INTO [sma_TRN_Settlements]
(
    stlnSetAmt,
    stlnStaffID,
    stlnPlaintiffID,
    stlsUniquePartyID,
    stlnCaseID,
    stlnNegotID
)
SELECT 
    SettlementAmount    as stlnSetAmt,
    negnStaffID			as stlnStaffID,
	negnPlaintiffID		as stlnPlaintiffID,
    negsUniquePartyID   as stlsUniquePartyID,
    negnCaseID		    as stlnCaseID,
    negnID				as stlnNegotID
FROM [sma_TRN_Negotiations]
WHERE isnull(SettlementAmount ,0) > 0

*/

alter table [sma_TRN_Settlements] enable trigger all