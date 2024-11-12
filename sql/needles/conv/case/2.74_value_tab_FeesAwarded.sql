/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-11-07
Description: Create settlement records for Fees Awarded

SELECT * FROM JoelBieberNeedles..value v WHERE code = 'ver'
SELECT * FROM JoelBieberSA_Needles..sma_TRN_Settlements sts WHERE sts.stlnCaseID = 10667
SELECT * FROM JoelBieberSA_Needles..sma_MST_SettlementType smst

##########################################################################################################################
*/

USE JoelBieberSA_Needles

ALTER TABLE [sma_TRN_Settlements] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_Settlements]
	(
	stlnCaseID
   ,stlnSetAmt
   ,stlnNet
   ,stlnNetToClientAmt
   ,stlnPlaintiffID
   ,stlnStaffID
   ,stlnLessDisbursement
   ,stlnGrossAttorneyFee
   ,stlnForwarder
   ,  --referrer
	stlnOther
   ,InterestOnDisbursement
   ,stlsComments
   ,stlTypeID
   ,stldSettlementDate
   ,saga
	)
	SELECT
		cas.casnCaseID		AS stlnCaseID
	   ,V.total_value		AS stlnSetAmt
	   ,NULL				AS stlnNet
	   ,NULL				AS stlnNetToClientAmt
	   ,pln.plnnPlaintiffID AS stlnPlaintiffID
	   ,NULL				AS stlnStaffID
	   ,NULL				AS stlnLessDisbursement
	   ,NULL				AS stlnGrossAttorneyFee
	   ,NULL				AS stlnForwarder    --Referrer
	   ,NULL				AS stlnOther
	   ,NULL				AS InterestOnDisbursement
	   ,ISNULL('memo:' + NULLIF(V.memo, '') + CHAR(13), '')
		+ ISNULL('code:' + NULLIF(V.code, '') + CHAR(13), '')
		+ ''				AS [stlsComments]
	   ,(
			SELECT
				ID
			FROM [sma_MST_SettlementType]
			WHERE SettlTypeName = 'Verdict'
		)					
		AS stlTypeID
	   ,CASE
			WHEN V.[start_date] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN V.[start_date]
			ELSE NULL
		END					AS stldSettlementDate
	   ,V.value_id			AS saga
	--select *
	FROM JoelBieberNeedles.[dbo].[value_Indexed] V
	JOIN sma_TRN_Cases cas
		ON cas.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
	JOIN sma_TRN_Plaintiff pln
		ON pln.plnnCaseID = cas.casnCaseID
		AND pln.plnbIsPrimary = 1
	WHERE V.code = 'VER'


GO

ALTER TABLE [sma_TRN_Settlements] ENABLE TRIGGER ALL
GO