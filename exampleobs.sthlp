{smcl}
{* 29jan2016}{...}
{cmd:help exampleobs} {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:exampleobs} {hline 2} Prints example observations and optionally stores them in local macro

{title:Syntax}

{p 8 11 2}
    {cmd:exampleobs} [{varlist}] {ifin} [{cmd:,} {it:options}]{break}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Income concepts}
{synopt :{opth n(real)}}Number of observations to display (default is 10){p_end}
{synopt :{opt l:abel}}Display value labels rather than values{p_end}
{synopt :{opt [no]h:eader}}Display or do not display header (i.e., variable names); default is to display unless only one variable specified{p_end}
{synopt :{opt lo:cal(macname)}}Insert the list of values in the local macro {it:macname}{p_end}

{title:Description}

{pstd} 
{cmd:exampleobs} displays {it:n} (randomly selected) example variables from the data set, 
where {it:n} is specified by 
{opth n(real)} and has a default of 10. For variables with value labels, the {opt l:abel} option 
can be used to list value labels rather than values. Specifying {opt s:orted} will
display the example observations of the data set after sorting it by {varlist}. 
To not display the variable name header, specify {opt noh:eader}; the default is to display 
the variable names unless {varlist} only contains one variable (to display the header if {varlist}
contains one variable, specify {opt h:eader}). To save the values printed by {cmd:exampleobs} in 
the local macro {it:macname}, specify {opt lo:cal(macname)}.

{title:Examples}

{phang} {cmd:. sysuse auto}{p_end}
{phang} {cmd:. exampleobs price}{p_end}
{phang} {cmd:. exampleobs price, local("example_prices")}{p_end}
{phang} {cmd:. di "`example_prices'"}{p_end}

{phang} {cmd:. exampleobs price, header}{p_end}
{phang} {cmd:. exampleobs price foreign, label}{p_end}
{phang} {cmd:. exampleobs price make, noheader}{p_end}

{title:Author}

{p 4 4 2}Sean Higgins, Tulane University, shiggins@tulane.edu

