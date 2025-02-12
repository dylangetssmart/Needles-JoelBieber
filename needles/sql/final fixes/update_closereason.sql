use SA
go

SELECT * FROM sma_TRN_Cases stc where stc.CloseReason = 0 and saga is not null and casdClosingDate is null

UPDATE stc
SET stc.CloseReason = null
FROM sma_TRN_Cases stc
where stc.CloseReason = 0
and casdClosingDate is null

SELECT * FROM sma_TRN_Cases stc where stc.CloseReason = 0 and saga is not null and casdClosingDate is null