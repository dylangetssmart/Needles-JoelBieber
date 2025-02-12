/*
update party roles to fix Employer mapping

*/

use JoelBieberSA_Needles

select * from joelbiebersa_needles..partyroles

update PartyRoles
set [SA Party] = 'DEFENDANT',
	[SA Roles] = '(D)-EMPLOYER'
where [Needles Roles] = 'EMPLOYER'

select * from joelbiebersa_needles..partyroles