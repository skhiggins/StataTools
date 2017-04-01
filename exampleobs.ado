* PROGRAM TO DISPLAY EXAMPLE OBSERVATIONS
*! v1.0.1 skh 11oct2015
* v1.0.0 skh date unknown

* CHANGES
*   10-11-2015 Made faster using random number generator instead of preserve and sample

capture program drop exampleobs
program define exampleobs
	version 10
	syntax [varlist] [if] [in] [, n(integer 10) NOHeader Header Label LOcal(string)]
	if `n'<1 {
		di as error in scml "{bf n} must be greater than or equal to 1"
		exit
	}
	if wordcount("`varlist'")==1 & "`header'"=="" {
		local noheader noheader
	}
	if wordcount("`varlist'")>1 & "`local'"!="" {
		di as error in smcl "{varlist} must contain only one variable if {bf local()} is specified"
		exit
	}
	if strpos("`local'"," ") {
		di as error in smcl "{bf local()} must not contain spaces"
		exit	
	}
	if "`label'"!="" local nolabel ""
	else local nolabel nolabel
	if "`varlist'"=="" local varlist _all
	
	if "`if'`in'"!="" {
		preserve
		qui keep `if' `in'
	}
	
	if _N==0 {
		exit
	}
	else if _N<`n' {
		list `varlist', clean noobs `nolabel' `noheader'
		exit
	}
	else {
		// old way (slow)
		* preserve
		* if wordcount("`if' `in'")>0 qui keep `if' `in'
		* qui sample `n', count
		* list `varlist', clean noobs `nolabel' `noheader'
		
		// a faster way without the memory requirements of preserve (unless `if' `in', then preserve still needed)
		local c=0
		local randoms ""
		forval i=1/`n' {
			local ++c
			if `c'>1 {
				local comma ","
			}
			else local comma ""
			cap set_rc // not a real command; sets _rc>0
			while _rc {
				local random = round(1+(_N-1)*runiform(),1)
				if "`randoms'"!="" cap assert !inlist(`random',`randoms')
				else cap assert 1==1 // to set _rc==0
			}
			local randoms `randoms'`comma'`random'
		}
		list `varlist' if inlist(_n,`randoms'), clean noobs `nolabel' `noheader'

		// save as a local
		if "`local'"!="" {
			local values ""
			local randoms_no_comma = subinstr("`randoms'",","," ",.)
			local c=0
			foreach random of local randoms_no_comma {
				local ++c
				if `c'>1 local space " "
				else local space ""
				local values `"`values'`space'`: di `varlist'[`random']'"'
				qui di " // for syntax highlighting in Notepad++
			}
			// undocumented way to create a local in ado file (found in levelsof.ado):
			c_local `local' `"`values'"'
			qui di "
		}
	}
end
	
