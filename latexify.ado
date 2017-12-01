*** PROGRAM TO TAKE ROWS OF A MATRIX AND PUT THEM IN LATEX
*** (created because programs like -outtable- were not flexible enough)
*! v3.1 20aug2017 Sean Higgins shiggins@tulane.edu

*** CHANGES
**    8-20-2017 Get rid of leading spaces
***   3-xx-2016 Add missingtona option to turn missing values into "N/A" in Latex table
***   7-18-2015 Only display brackets if non-missing entry of matrix

capture program drop latexify 
program define latexify // program to put rows of a matrix into Latex
	#delimit ;
	syntax [anything] using, /* anything is a matrix, using gives a .tex (or other text) file to write the Latex table in */
		[
		brackets(string) /* to specify e.g. "()" around standard errors, "[]" around p-values */
		stars(string) /* another matrix that has the p-values to put stars next to the coefficient */
		starcols(string) /* which columns to produce stars for (default all) */
		midrule /* add \midrule at the end of the latex row */
		starvalues(string) /* default is 0.1 (one star) 0.05 (two stars) 0.01 (three stars); specify as a numlist */
		extracols(integer 0) /* adding extra columns, e.g. for a blank first column when those have titles in other rows */
		title(string) /* title of the row (e.g. the variable name), which will go in the first column */
		titleonly(real 0) /* a row that only contains the title then blank space */
		format(string) /* a format for the numbers, e.g. %4.3f, or a list of formats, one for each column of the matrix */
		rowname /* haven't added this yet--will be to extract matrix rowname as the title of the row */
		replace append /* replace the file specified with using or append to another file */
		doublenegative /* for -- instead of - for negatives; don't use with S columns in latex */
		missingtona
		replacethis(string)
		withthis(string)
		]
	;
	#delimit cr

	** Locals
	local die display as error in smcl
	
	** File to write Latex table to
	tempname myf
	file open `myf' `using', write `replace' `append'
	
	** Brackets
	if !inlist(length("`brackets'"),0,2) {
		`die' "Option {bf:brackets} must have two characters, e.g. () or []"
		error 198
	}
	else {
		local leftb = substr("`brackets'",1,1)
		local rightb = substr("`brackets'",2,1)
	}
	
	** Replace with
	if "`withthis'"!="" & "`replacethis'"=="" {
		`die' "Option {opth withthis(string)} requires you to also specify {opth replacethis(string)}"
		error 198
	}
	if "`replacethis'"!="" & "`withthis'"=="" {
		`die' "Option {opth replacethis(string)} requires you to also specify {opth withthis(string)}"
		error 198
	}
	
	** Matrix
	if "`anything'"!="" {
		cap matlist `anything' 
		if _rc {
			`die' "The command must be followed by a matrix or sub-matrix"
			error 198
		}
	}
	tempname mat 
	if "`anything'"!="" {
		matrix `mat' = `anything' // need this so that they can specify a submatrix
								  // e.g. matrix[2,1...] 
		local cols = colsof(`mat')
		local rows = rowsof(`mat')
		
		if "`starcols'"=="" & "`stars'"!="" {
			forval i=1/`cols' {
				local starcols `starcols' `i'
			}
		} // all columns get stars by default

		** Format for Latex table
		if "`format'"=="" local format "%10.2f"
		if wordcount("`format'")!=1 & wordcount("`format'")!=`cols' {
			`die' "{bf:format} option must include one format, or a format for each column"
			exit
		}
		if wordcount("`format'")==1 {
			forval i=1/`cols' {
				local format`i' `format'
			}
		}
		else {
			tokenize `format'
			forval i=1/`cols' {
				local format`i' ``i''
			}
		}
	}
	
	** Other locals
	if "`starvalues'"=="" local starvalues .1 .05 .01
	if "`midrule'"!="" local _midrule "\midrule"
	
	** Write a row in the Latex table
	if `extracols' forval i=1/`extracols' {
		local initial "`initial' & "
	}
	if "`title'"!="" & !`titleonly' {
		local initial "`initial'`title' & "
	}
	if "`stars'"!="" {
		cap matlist `stars'
		if _rc {
			`die' "Option {bf:stars} should contain a matrix of p-values"
			exit
		}
	}
	if `titleonly' { // e.g. a row of a table that only has a title, then blank space for the rest of the row
		local row "`title'"
		forval i=1/`titleonly' {
			if `i'<`titleonly' local row "`row' & " // not the last element in the Latex table row
			else local row "`row' \\" // for the last element in the Latex table row
		}
	}
	else { // for a row with results from a matrix
		forval i=1/`cols' {
			if `i'<`cols' local a " & " // not the last element in the Latex table row
			else local a " \\" // for the last element in the Latex table row
			local mystars
			if "`stars'"!="" { // significance stars
				tempname starsvector
				matrix `starsvector' = `stars'
				tokenize "`starvalues'"
				local nstars = wordcount("`starvalues'")
				forval s=1/`nstars' {
					if `starsvector'[1,`i'] < ``s'' local mystars "`mystars'*" // to put stars next to the number
				}
				if strpos("`mystars'","*") & strpos("`starcols'","`i'") ///
					local mystars "$^{`mystars'}$" // for better appearance in Latex
			}
			local n_noformat = `mat'[1,`i']
			local n : di `format`i'' `mat'[1,`i'] // format option used to control display
			if `n_noformat'==. & "`missingtona'"=="" local n "" // replace missing values with blank
			else if `n_noformat'==. & "`missingtona'"!="" local n "N/A"
			if "`n'"=="`replacethis'" local n "`withthis'" // replace with
			if strpos("`n'","-") & "`doublenegative'"!="" local n -`n' // to get better negative sign in Latex with -- instead of -
			local n = subinstr("`n'"," ","",.) // added Aug 2017 to remove leading spaces
			if "`n'"!="" local row "`row' `leftb'`n'`rightb'`mystars' `a' "
			else local row "`row' `a' "
		}
	}
	
	file write `myf' `"`initial' `row' `_midrule'"' _n // writes the latex row
	qui di " // this is just to fix Notepad++ syntax highlighting
	file close `myf'
end
