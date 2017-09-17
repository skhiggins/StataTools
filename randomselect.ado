*! v1.1 14aug2016 SKH seanhiggins@berkeley.edu
**  08-14-2016 Fixed bug scml -> smcl; replace district with `select'
** v1.0 SKH seanhiggins@berkeley.edu 

capture program drop _uniquevals
program define _uniquevals, byable(recall) rclass sortpreserve
	syntax [varlist] [if] [in] [, Count SEParately Sorted]
	preserve
	if "`if'`in'"!="" {
		qui keep `if' `in'
	}
	if _by()==1 {
		qui drop if `_byindex' != _byindex()
	}
	if "`sorted'"=="" local sort "sort"
	else local sort ""
	tempvar unique
	if "`separately'"!="" foreach var in `varlist' {
		by`sort' `var': gen `unique' = (_n==1)
		qui count if `unique'
		di as result r(N) as text " unique values of " as result "`var'"
		return scalar unique = r(N)
	}
	else {
		by`sort' `varlist': gen `unique' = (_n==1)
		qui count if `unique'
		di as result r(N) as text " unique values of " as result "`varlist'"
		return scalar unique = r(N)
	}
	if "`count'"!="" {
		qui count
		di as result r(N) as text " observations" // already dropped other obs
		return scalar N = r(N)
	}
end

capture program drop randomselect
program define randomselect, sortpreserve
	syntax [if] [in], gen(string) [n(real -1) prop(real -1) select(string) seed(real -1)]
	
	local die "di as error in smcl"

	// Parse options
	foreach opt in n prop {
		if ``opt''==-1 local `opt' = . 
	}
	if missing(`n') & missing(`prop') {
		`die' "Must specify either {opth n(real)} or {opth prop(real)} option"
		exit 198
	}
	else if !missing(`n') & !missing(`prop') {
		`die' "Cannot specify both {opth n(real)} and {opth prop(real)} options"
		exit 198
	}
	else {
		if !missing(`n') {
			local by_n = 1 // i.e. they specified n() rather than prop()
			if !(`n'>0) {
				`die' "{opth n(real)} must be the number to select, greater than 0"
				exit 198
			}
		}
		else {
			if !(`prop'>=0 & `prop'<=1) {
				`die' "{opth prop(real)} must be a proportion between 0 and 1"
				exit 198
			}
			if "`select'"=="" {
				qui count `if' `in'
				local n = `prop'*r(N)
			}
			else {
				qui _uniquevals `select' `if' `in'
				local n = `prop'*r(unique)
			}
		}
	}	

	// Preliminaries
	tempvar random tag pregen touse
	qui gen `touse' = 0
	qui replace `touse' = -1 `if' `in'
		
	// Seed
	if `seed'!=-1 set seed `seed'
	
	// Random
	gen `random' = runiform()
	if "`select'"=="" {
		sort `touse' `random', stable // so touse==1 goes on top 
		qui gen byte `gen' = (_n<=`n')
	}
	else {
		quietly {
			sort `select', stable
			by `select' : gen `tag' = -(_n==1) if `touse' // mark one obs per `varlist' grouping
			sort `tag' `random', stable // -`tag' to get the =1 at the top
			qui gen byte `pregen' = (_n<=`n') if `touse' // `pregen' will = 1 for the randomly selected tagged
			sort `select', stable
			by `select' : egen `gen' = max(`pregen') if `touse' // now tag all the 
		}
	}
end

