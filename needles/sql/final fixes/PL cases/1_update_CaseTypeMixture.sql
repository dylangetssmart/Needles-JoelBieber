use JoelBieberSA_Needles
go

select
	*
from casetypemixture

insert into casetypemixture
	(
	matcode, header, description, [SmartAdvocate Case Type], [SmartAdvocate Case Sub Type]
	)
	select
		'PL',
		'PROD/LIA',
		'PRODUCTS LIABILITY CASE',
		'Product Liability - General',
		''
	where not exists (
			select
				1
			from casetypemixture
			where matcode = 'PL'
				and [SmartAdvocate Case Type] = 'Product Liability - General'
		);

select
	*
from casetypemixture