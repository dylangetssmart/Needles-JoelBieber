/*
update party roles to fix Employer mapping

*/

use SA
go

select * from partyroles

update PartyRoles
set [SA Party] = 'DEFENDANT',
	[SA Roles] = '(D)-EMPLOYER'
where [Needles Roles] = 'EMPLOYER'

select * from partyroles