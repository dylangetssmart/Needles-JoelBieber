USE [ShinerSA]
GO

--SELECT
--	lpic.litify_pm__Retainer_Agreement_Signed__c
--   ,lpic.litify_pm__Matter__c
--FROM ShinerLitify..litify_pm__Intake__c lpic
--WHERE isnull(lpic.litify_pm__Retainer_Agreement_Signed__c,'')<>''

--rtndRcvdDt

INSERT INTO [dbo].[sma_TRN_Retainer]
	(
	[rtnnCaseID]
   ,[rtnnPlaintiffID]
   ,[rtndSentDt]
   ,[rtndRcvdDt]
   ,[rtndRetainerDt]
   ,[rtnbCopyRefAttFee]
   ,[rtnnFeeStru]
   ,[rtnbMultiFeeStru]
   ,[rtnnBeforeTrial]
   ,[rtnnAfterTrial]
   ,[rtnnAtAppeal]
   ,[rtnnUDF1]
   ,[rtnnUDF2]
   ,[rtnnUDF3]
   ,[rtnbComplexStru]
   ,[rtnbWrittenAgree]
   ,[rtnnStaffID]
   ,[rtnsComments]
   ,[rtnnUserID]
   ,[rtndDtCreated]
   ,[rtnnModifyUserID]
   ,[rtndDtModified]
   ,[rtnnLevelNo]
   ,[rtnnPlntfAdv]
   ,[rtnnFeeAmt]
   ,[rtnsRetNo]
   ,[rtndRetStmtSent]
   ,[rtndRetStmtRcvd]
   ,[rtndClosingStmtRcvd]
   ,[rtndClosingStmtSent]
   ,[rtnsClosingRetNo]
   ,[rtndSignDt]
   ,[rtnsDocuments]
   ,[rtndExecDt]
   ,[rtnsGrossNet]
   ,[rtnnFeeStruAlter]
   ,[rtnsGrossNetAlter]
   ,[rtnnFeeAlterAmt]
   ,[rtnbFeeConditionMet]
   ,[rtnsFeeCondition]
	)
	SELECT
		stc.casnCaseID AS rtnnCaseID
	   ,(
			SELECT TOP 1
				plnnPlaintiffID
			FROM [sma_TRN_Plaintiff]
			WHERE plnnCaseID = casnCaseID
				AND plnbIsPrimary = 1
		)			   
		AS hosnPlaintiffID
	   ,NULL		   AS rtndSentDt
	   ,CASE
			WHEN (lpic.litify_pm__Retainer_Agreement_Signed__c NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE lpic.litify_pm__Retainer_Agreement_Signed__c
		END			   
		AS [rtndRcvdDt]
	   ,NULL		   AS rtndRetainerDt
	   ,NULL		   AS rtnbCopyRefAttFee
	   ,NULL		   AS rtnnFeeStru
	   ,NULL		   AS rtnbMultiFeeStru
	   ,NULL		   AS rtnnBeforeTrial
	   ,NULL		   AS rtnnAfterTrial
	   ,NULL		   AS rtnnAtAppeal
	   ,NULL		   AS rtnnUDF1
	   ,NULL		   AS rtnnUDF2
	   ,NULL		   AS rtnnUDF3
	   ,NULL		   AS rtnbComplexStru
	   ,NULL		   AS rtnbWrittenAgree
	   ,NULL		   AS rtnnStaffID
	   ,NULL		   AS rtnsComments
	   ,NULL		   AS rtnnUserID
	   ,NULL		   AS rtndDtCreated
	   ,NULL		   AS rtnnModifyUserID
	   ,NULL		   AS rtndDtModified
	   ,NULL		   AS rtnnLevelNo
	   ,NULL		   AS rtnnPlntfAdv
	   ,NULL		   AS rtnnFeeAmt
	   ,NULL		   AS rtnsRetNo
	   ,NULL		   AS rtndRetStmtSent
	   ,NULL		   AS rtndRetStmtRcvd
	   ,NULL		   AS rtndClosingStmtRcvd
	   ,NULL		   AS rtndClosingStmtSent
	   ,NULL		   AS rtnsClosingRetNo
	   ,NULL		   AS rtndSignDt
	   ,NULL		   AS rtnsDocuments
	   ,NULL		   AS rtndExecDt
	   ,NULL		   AS rtnsGrossNet
	   ,NULL		   AS rtnnFeeStruAlter
	   ,NULL		   AS rtnsGrossNetAlter
	   ,NULL		   AS rtnnFeeAlterAmt
	   ,NULL		   AS rtnbFeeConditionMet
	   ,NULL		   AS rtnsFeeCondition
	FROM ShinerLitify..litify_pm__Intake__c lpic
	JOIN sma_TRN_Cases stc
		ON stc.saga_char = lpic.litify_pm__Matter__c
	WHERE ISNULL(lpic.litify_pm__Retainer_Agreement_Signed__c, '') <> ''
