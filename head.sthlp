{smcl}
{* 29jan2016}{...}
{cmd:help head} {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:head} {hline 2} Prints the head observations (first observations in data set)

{title:Syntax}

{p 8 11 2}
    {cmd:head} [{varlist}] {ifin} [{cmd:,} {it:options}]{break}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Income concepts}
{synopt :{opth n(real)}}Number of observations to display (default is 10){p_end}
{synopt :{opt l:abel}}Display value labels rather than values{p_end}
{synopt :{opt u:nique}}Only display unique values{p_end}
{synopt :{opt s:orted}}Sort in ascending order of {varlist}{p_end}
{synopt :{opt [no]h:eader}}Display or do not display header (i.e., variable names); default is to display unless only one variable specified{p_end}

{title:Description}

{pstd} 
{cmd:head} displays the first {it:n} observations in the data set, where {it:n} is specified by 
{opth n(real)} and has a default of 10. It was designed to mimic the head function in R.
For variables with value labels, the {opt l:abel} option 
can be used to list value labels rather than values. To only display unique values, specify 
{opt u:nique} (e.g. if the first three values are 9, 9, 10 and {cmd:n(2)} and {opt u:nique} are 
specified, the values displayed will be 9, 10 instead of 9, 9). Specifying {opt s:orted} will
display the head observations of the data set after sorting it by {varlist}. 
To not display the variable name header, specify {opt noh:eader}; the default is to display 
the variable names unless {varlist} only contains one variable (to display the header if {varlist}
contains one variable, specify {opt h:eader}).

{title:Examples}

{phang} {cmd:. sysuse auto}{p_end}
{phang} {cmd:. head price}{p_end}
{phang} {cmd:. head price, n(2) header}{p_end}
{phang} {cmd:. head price make, unique}{p_end}
{phang} {cmd:. head price foreign, unique sorted label}{p_end}
{phang} {cmd:. head price foreign, unique sorted noheader}{p_end}

{title:Author}

{p 4 4 2}Sean Higgins, Tulane University, shiggins@tulane.edu

