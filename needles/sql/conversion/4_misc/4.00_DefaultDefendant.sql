use [JoelBieberSA_Needles]
go


---(1)---
delete from sma_MST_CaseTypeDefualtDefs

---(2)---
insert into sma_MST_CaseTypeDefualtDefs
	select distinct
		cst.cstnCaseTypeID as cddncasetypeid,
		i.cinnContactID	   as cddndefcontatid,
		i.cinnContactCtg   as cddndefcontactctgid,
		sbrnSubRoleId	   as cddnroleid,
		a.addnAddressID	   as cddndefaddressid
	from sma_mst_casetype cst
	join sma_mst_SubRole s
		on sbrnCaseTypeID = cst.cstnCaseTypeID
	join sma_mst_SubRoleCode stc
		on s.sbrnTypeCode = stc.srcnCodeId
			and stc.srcsDscrptn = '(D)-Defendant'
	cross join sma_MST_IndvContacts i
	join sma_MST_Address a
		on a.addnContactID = i.cinnContactID
			and a.addnContactCtgID = i.cinnContactCtg
			and a.addbPrimary = 1
	where cst.VenderCaseType = 'JoelBieberCaseType'
		and i.cinsFirstName = 'Individual'
		and i.cinsLastName = 'Unidentified'