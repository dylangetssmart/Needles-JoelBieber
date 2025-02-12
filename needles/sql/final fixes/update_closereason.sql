UPDATE stc
SET stc.CloseReason = null
FROM sma_TRN_Cases stc
where stc.CloseReason = 0