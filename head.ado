* PROGRAM TO DISPLAY HEAD OBSERVATIONS
*! v1.0.0 skh 30jan2016

capture program drop head
program define head
	version 10
	syntax [varlist] [if] [in] [, n(integer 10) NOHeader Header Label Unique Sorted]
	if `n'<1 {
		di as error in scml "{bf n} must be greater than or equal to 1"
		exit
	}
	if "`label'"!="" local nolabel ""
	else local nolabel nolabel
	if "`varlist'"=="" local varlist _all
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
	list `varlist' in 1/`n', clean noobs `nolabel' `header'
end
	
