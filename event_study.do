/**************************************************************
** EVENT STUDY WITH PURE CONTROL GROUP: EXAMPLE CODE
**  Sean Higgins, seanhiggins@berkeley.edu
**  07dec2017
***************************************************************/

**********************
** CREATE FAKE DATA **
**********************
// With N individuals (change below), T periods (change below)
// Half of sample is treated in a particular period 
//  between t=3 and t=7
// (This part is just to make the do file self contained and so 
//  it's easy to see what each variable is. If you have real data,
//  you can skip to the code in the DO THE EVENT STUDY section.)

// Preliminaries
clear
local N = 1000
local T = 10
set seed 20171207

// First create a data set with one obs per ID, then expand later
set obs `N'
gen id = _n 
gen byte treated = (runiform()>0.5) // about half treated at some point during study
list, clean noobs

// Period of treatment (can be 3, 4, 5, 6, or 7 for treated)
gen time_treated = round(runiform(3,7)) if treated // between 3 and 7
** hist time_treated

// Some cluster variable like village
gen clustvar = ceil(id/20) // 20 individuals per cluster

// Now expand it so the data set has 10 time periods per ID
count
expand `T' // now the data set is at the individual by time level
sort id 
by id : gen t = _n // time period (1,...,10 within each id)

// Time since treatment ("relative" event study time)
gen time_since_treated = t - time_treated if treated
	// otherwise missing
	
// Outcome variable with autocorrelation
//  suppose there is a treatment effect: 
//  shift of 10 plus a slope of 5 per period
gen outcome = rnormal(100,50) if t==1 // mean for the ID
by id : replace outcome = outcome[1] + rnormal(0,10) 
	// random period to period noise around that observation's mean
//  Add the treatment effect
replace outcome = outcome + ///
	rnormal(10,5) + /// shift of 10 (with noise)
	rnormal(5,3)*time_since_treated /// slope of 5 per period (w/ noise)
	if treated & (t >= time_treated)

************************
** DO THE EVENT STUDY **
************************
summ time_since_treated
	// since time_since_treated ranges from -6 to 7,
	//  add T=10 to it so they are all positive
	//  (since factor variables don't accept negatives)
local increment = `T' // 10 in this case
replace time_since_treated = time_since_treated + `increment'
	// now time_since_treated = 10 refers to the period of treatment
	//  (kind of annoying to have to do this; will need to 
	//   convert back when graphing)
	
// Because 'i.' notation doesn't accept negatives, create our 
//  treated interacted with time since treatment dummies 
//  manually the old-fashioned way using -xi-
xi i.treated*i.time_since_treated, noomit
describe _I* // look at the interaction variables created with xi

// Note the important vars are the _ItreXtim_1_* which are the
//  relative "event time" dummies interacted with treatment.
// (The name _ItreXtim_1_* is because -xi- cuts each variable
//  to three letters; see -help xi-)
// (The _1 indicates that treated==1, the * will be values for 
//  each time_since_treated. These go from 4 to 17 which correspond
//  to -6 to 7, since we had to add 10 to avoid negative factor vars)

// But since time_since_treated is missing for control, 
//  the _ItreXtim* dummies also missing for control; we want them 
//  to be 0
recode _ItreXtim* (. = 0) if treated==0

// To omit the period just before treatment:
summ time_since_treated if treated
local lo = r(min)
local hi = r(max)
//  And note that since k=0 is now =`increment', 
//   k=-1 is `=`increment'-1', etc., which I use below
	
// EVENT STUDY REGRESSION
// As recommended by Borusyak and Jaravel (2016), but 
//  unlike McCrary (2007) and most event study papers,
//  include all relative time dummies in the regression rather 
//  than "binning" periods below a or above b.
// Then we can just graph the periods from a to b if we want. 
// But binning can cause bias if the trend isn't flat for periods
//  less than a or greater than b (Borusyak and Jaravel, 2016)
// Note that when there is no pure control group, binning periods
//  less than a or greater than b (i.e. imposing flat trend for
//  those periods) is needed to pin down calendar time fixed effects,
//  which is why Borusyak and Jaravel (2016) recommend having
//  a pure control, which pin down the calendar time fixed effects
//  without having to make these additional assumptions.
xtset id t
#delimit ;
xtreg outcome 
	i.t /* calendar time fixed effects */
	_ItreXtim_1_`lo'-_ItreXtim_1_`=`increment'-2' 
		/* event study relative time dummies up to k=-2 */
	_ItreXtim_1_`increment'-_ItreXtim_1_`hi'
		/* event study relative time dummies starting at k=0 */
		/* (note k=-1 is omitted) */
	, 
	fe /* individual fixed effects */
	vce(cluster clustvar) /* clustered standard errors */
;
#delimit cr
// Note the coefficients we want from the regression are 
//  the coefficients on _ItreXtim_1_*. As expected there is a 
//  treatment effect of about 10 plus an additional 5 per period.
// Note that _ItreXtim_1_9 is missing since that corresponds
//  to k=-1, the omitted period

// Degrees of freedom for p-values and confidence intervals:
local df = e(df_r)

// PUT RESULTS IN A MATRIX
local rows = `hi' - `lo' + 1
matrix results = J(`rows', 4, .) // empty matrix for results
//  4 cols are: (1) time period, (2) beta, (3) std error, (4) pvalue
local row = 0
forval p = `lo'/`hi' {
	local ++row
	local k = `p' - `increment' // original relative period (-6 to 7)
	matrix results[`row',1] = `k'
	if `p'==`=`increment'-1' /// the omitted period
		continue // break this iteration of loop; 
			// and leave remaining columns as missing
	// Beta (event study coefficient)
	matrix results[`row',2] = _b[_ItreXtim_1_`p']
	// Standard error
	matrix results[`row',3] = _se[_ItreXtim_1_`p']
	// P-value
	matrix results[`row',4] = 2*ttail(`df', ///
		abs(_b[_ItreXtim_1_`p']/_se[_ItreXtim_1_`p']) ///
	)
}
matrix colnames results = "k" "beta" "se" "p"
matlist results

***************************
** GRAPH THE EVENT STUDY **
***************************
// First, replace data in memory with results
clear
svmat results, names(col) 

// Replace values for omitted period to graph a hollow circle there:
replace beta = 0 if k==-1 
replace se = 0 if k==-1
replace p = 1 if k==-1 // just need to set p>.1 so it will be hollow
	// based on the different types of points I use for significant 
	// vs insignificant results

// GRAPH FORMATTING
// For graphs:
local labsize medlarge
local bigger_labsize large
local ylabel_options nogrid notick labsize(`labsize') angle(horizontal)
local xlabel_options nogrid notick labsize(`labsize')
local xtitle_options size(`labsize') margin(top)
local title_options size(`bigger_labsize') margin(bottom) color(black)
local manual_axis lwidth(thin) lcolor(black) lpattern(solid)
local plotregion plotregion(margin(sides) fcolor(white) lstyle(none) lcolor(white)) 
local graphregion graphregion(fcolor(white) lstyle(none) lcolor(white)) 
// To put a line right before treatment
local T_line_options lwidth(thin) lcolor(gray) lpattern(dash)
// To show significance: hollow gray (gs7) will be insignificant from 0,
//  filled-in gray significant at 10%
//  filled-in black significant at 5%
local estimate_options_0  mcolor(gs7)   msymbol(Oh) msize(medlarge)
local estimate_options_90 mcolor(gs7)   msymbol(O)  msize(medlarge)
local estimate_options_95 mcolor(black) msymbol(O)  msize(medlarge)
local rcap_options_0  lcolor(gs7)   lwidth(thin)
local rcap_options_90 lcolor(gs7)   lwidth(thin)
local rcap_options_95 lcolor(black) lwidth(thin)

// We have from k=-6 to 7, but smaller sample at the ends
//  since less observations were treated early/late enough to have
//  k=-6 or k=7 for the full sample, for example.
// Suppose we just want to graph from k=-5 to k=5. (This is 
//  better than binning at k<=-5 and k>=5 in the regression itself;
//  see discussion above.)
local lo_graph = -5
local hi_graph = 5
keep if k >= `lo_graph' & k <= `hi_graph'

// Confidence intervals (95%)
local alpha = .05 // for 95% confidence intervals
gen rcap_lo = beta - invttail(`df',`=`alpha'/2')*se
gen rcap_hi = beta + invttail(`df',`=`alpha'/2')*se

// GRAPH
#delimit ;
graph twoway 
	(scatter beta k if p<0.05,           `estimate_options_95') 
	(scatter beta k if p>=0.05 & p<0.10, `estimate_options_90') 
	(scatter beta k if p>=0.10,          `estimate_options_0' ) 
	(rcap rcap_hi rcap_lo k if p<0.05,           `rcap_options_95')
	(rcap rcap_hi rcap_lo k if p>=0.05 & p<0.10, `rcap_options_90')
	(rcap rcap_hi rcap_lo k if p>=0.10,          `rcap_options_0' )
	, 
	title("Treatment effects from event study with pure control group", `title_options')
	ylabel(, `ylabel_options') 
	yline(0, `manual_axis')
	xtitle("Period relative to treatment", `xtitle_options')
	xlabel(`lo_graph'(1)`hi_graph', `xlabel_options') 
	xscale(range(`min_xaxis' `max_xaxis'))
	xline(-0.5, `T_line_options')
	xscale(noline) /* because manual axis at 0 with yline above) */
	`plotregion' `graphregion'
	legend(off) 
;
#delimit cr

