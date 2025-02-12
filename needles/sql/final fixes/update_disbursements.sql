SELECT d.disnRecoverable, v.code
FROM sma_TRN_Disbursement d
join JoelBieberNeedles..value_Indexed v
on v.value_id = d.saga
where saga is not null
and v.code in ('DTF')


UPDATE d
set d.disnRecoverable = 1
FROM sma_TRN_Disbursement d
join JoelBieberNeedles..value_Indexed v
on v.value_id = d.saga
where saga is not null
and v.code in ('DTF')


SELECT d.disnRecoverable, v.code
FROM sma_TRN_Disbursement d
join JoelBieberNeedles..value_Indexed v
on v.value_id = d.saga
where saga is not null
and v.code in ('DTF')
