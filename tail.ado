* PROGRAM TO DISPLAY TAIL OBSERVATIONS
*! v1.0.0 skh 30jan2016

capture program drop tail
program define tail
	version 10
	syntax [varlist] [if] [in] [, n(integer 10) NOHeader Header Label Unique Sorted]
	if `n'<1 {
		di as error in scml "{bf n} must be greater than or equal to 1"
		exit
	}
	if "`label'"!="" local nolabel ""
	else local nolabel nolabel
	if "`varlist'"=="" local varlist _all
	if "`noheader'"!="" local header "noheader"
	if wordcount("`varlist'")==1 & "`header'"=="" local header "noheader"
	
	if "`if'`in'`sorted'`unique'"!="" {
		preserve
	}
	if "`if'`in'"!="" {
		qui keep `if' `in'
	}
	if "`sorted'"!="" {
		qui sort `varlist'
	}
	if "`unique'"!="" {
		qui duplicates drop `varlist', force
	}
	local L2 = _N
	local L1 = _N - (`n'-1)
	if `L1'<1 local L1 = 1
	list `varlist' in `L1'/`L2', clean noobs `nolabel' `header'
end
	
