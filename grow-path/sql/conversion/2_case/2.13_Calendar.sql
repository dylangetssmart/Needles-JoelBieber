use ShinerSA
go

-- Ensure QUOTED_IDENTIFIER is ON
set quoted_identifier on;
go

/*
alter table [sma_TRN_CalendarAppointments] disable trigger all
delete from [sma_TRN_CalendarAppointments]
DBCC CHECKIDENT ('[sma_TRN_CalendarAppointments]', RESEED, 0);
alter table [sma_TRN_CalendarAppointments] disable trigger all

alter table [sma_trn_AppointmentStaff] disable trigger all
delete from [sma_trn_AppointmentStaff]
DBCC CHECKIDENT ('[sma_trn_AppointmentStaff]', RESEED, 0);
alter table [sma_trn_AppointmentStaff] disable trigger all
*/

---(0)---
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_char'
			and object_id = OBJECT_ID(N'sma_TRN_CalendarAppointments')
	)
begin
	alter table [sma_TRN_CalendarAppointments] add [saga_char] [VARCHAR](100) null;
end
go

/*
---(0)---
INSERT INTO [sma_MST_ActivityType] ( attsDscrptn, attnActivityCtg )  
select A.ActivityType, (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Case-Related Appointment')
from
(
select distinct 
    appointment_type as ActivityType 
from [NeedlesSchechter].[dbo].[calendar] CAL where isnull(appointment_type,'') <> ''
except
select 
    attsDscrptn as ActivityType
from sma_MST_ActivityType 
where attnActivityCtg = (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Case-Related Appointment')
and isnull(attsDscrptn,'') <> '' 
) A
GO
*/

alter table [sma_TRN_CalendarAppointments] disable trigger all
go

----(1)-----
insert into [sma_TRN_CalendarAppointments]
	(
	[FromDate],
	[ToDate],
	[AppointmentTypeID],
	[ActivityTypeID],
	[CaseID],
	[LocationContactID],
	[LocationContactGtgID],
	[JudgeID],
	[Comments],
	[StatusID],
	[Address],
	[Subject],
	[ReminderTime],
	[RecurranceParentID],
	[AdjournedID],
	[RecUserID],
	[DtCreated],
	[ModifyUserID],
	[DtModified],
	[DepositionType],
	[Deponants],
	[OriginalAppointmentID],
	[OriginalAdjournedID],
	[RecurrenceId],
	[WorkPlanItemId],
	[AutoUpdateAppId],
	[AutoUpdated],
	[AutoUpdateProviderId],
	[saga_char]
	)
	select
		e.ActivityDateTime																	  as [fromdate],
		DATEADD(minute, CONVERT(INT, DurationInMinutes), CONVERT(DATETIME, ActivityDateTime)) as [todate],
		(
			select
				ID
			from [sma_MST_CalendarAppointmentType]
			where AppointmentType = 'Case-related'
		)																					  as [appointmenttypeid],
		(
			select
				attnActivityTypeID
			from [sma_MST_ActivityType]
			where attnActivityCtg = (
					select
						atcnPKId
					from sma_MST_ActivityCategory
					where atcsDscrptn = 'Case-Related Appointment'
				)
				and attsDscrptn = 'Appointment'
		)																					  as [activitytypeid],
		cas.casnCaseID																		  as [caseid],
		null																				  as [locationcontactid],
		2																					  as [locationcontactgtgid],
		null																				  as [judgeid],
		ISNULL('Description: ' + NULLIF(CONVERT(VARCHAR(MAX), e.[Description]), '') + CHAR(13), '') +
		''																					  as [comments],
		(
			select
				[statusid]
			from [sma_MST_AppointmentStatus]
			where [StatusName] = 'Open'
		)																					  as [statusid],
		e.[Location]																		  as [address],
		LEFT(e.[subject], 120)																  as [subject],
		e.ReminderDateTime																	  as [remindertime],
		null,
		null,
		(
			select
				usrnUserID
			from sma_mst_users
			where saga = e.CreatedById
		)																					  as [recuserid],
		e.CreatedDate																		  as [dtcreated],
		(
			select
				usrnUserID
			from sma_mst_users
			where saga = e.LastModifiedById
		)																					  as [modifyuserid],
		e.LastModifiedDate																	  as [dtmodified],
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		e.id																				  as [saga_char]
	--select * 
	from [ShinerLitify]..[event] e
	join [sma_TRN_Cases] cas
		on cas.saga_char = e.litify_pm__Matter__c
go

alter table [sma_TRN_CalendarAppointments] enable trigger all
go


----(2)-----
insert into [sma_trn_AppointmentStaff]
	(
	[AppointmentId],
	[StaffContactId],
	StaffContactCtg
	)
	select
		app.AppointmentID,
		u.usrnContactID,
		1
	from [sma_TRN_CalendarAppointments] app
	join [ShinerLitify]..[event] cal
		on app.saga_char = cal.id
	join sma_mst_users u
		on u.saga_char = cal.OwnerId

