** COUNTS UNIQUE VALUES OF A VARIABLE OR LIST OF VARIABLES
** (Runs significantly faster than duplicates report and unique)

** v1.1 21jul2015 Sean Higgins
*! v1.2 30nov2017 Sean Higgins
	** Added `noobs' check if any observations in the data being used
	**  to avoid the -__00001 not found- type of errors from 
	**  by`sort' `var': gen `unique' = (_n==1)
	**  if no data

** Advantages over -unique- (user written by Hills and Brady, 1998)
**  - faster, especially as data set grows, especially if already sorted
**  - works with by: prefix to report unique values separately by values 
**     of a categorical variable (e.g. number of unique districts by state)
**  - option to have the varlist treated jointly (unique values of the 
**     combination of variables) or separately (reports unique values
**     for each variable separately)

capture program drop uniquevals
program define uniquevals, byable(recall) rclass sortpreserve
	syntax [varlist] [if] [in] [, Count SEParately Sorted]
	preserve
	if `"`if'`in'"'!=`""' { // "
		qui keep `if' `in'
	}
	if _by()==1 {
		qui drop if `_byindex' != _byindex()
	}
	if "`sorted'"=="" local sort "sort"
	else local sort ""
	
	qui count 
	if r(N)==0 local noobs = 1
	else       local noobs = 0
	
	if "`separately'"!="" { // report unique values separately for each
		local i=0
		foreach var in `varlist' {
			local ++i
			tempvar unique
			if !(`noobs') {
				by`sort' `var': gen `unique' = (_n==1)
				qui count if `unique'
				local unique_obs = r(N)
			}
			else local unique_obs = 0
			di as result `unique_obs' as text " unique values of " as result "`var'"
			return scalar unique`i' = `unique_obs'
			return local var`i' = "`var'"
		}
	}
	else {
		tempvar unique
		if !(`noobs') {
			by`sort' `varlist': gen `unique' = (_n==1)
			qui count if `unique'
			local unique_obs = r(N)
		}
		else local unique_obs = 0
		di as result `unique_obs' as text " unique values of " as result "`varlist'"
		return scalar unique = `unique_obs'
	}
	if "`count'"!="" {
		qui count
		di as result r(N) as text " observations" // already dropped other obs
		return scalar N = r(N)
	}
end
