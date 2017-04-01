{smcl}
{* 17jul2016}{...}
{cmd:help randomselect} {right:Sean Higgins}
{hline}

{title:Title}

{p 4 11 2}
{hi:randomselect} {hline 2} Randomly selects observations and marks them with a dummy variable

{title:Syntax}

{p 8 11 2}
    {cmd:randomselect} [{varlist}] {ifin} {cmd:,} {opth gen(newvarname)} [{it:options}]{break}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth gen(newvarname)}}Name of new variable that =1 if selected{p_end}
{synopt :{opth n(real)}}Number of observations or units to select{p_end}
{synopt :{opth prop(real)}}Proportion (between 0 and 1) of observations or units to select{p_end}
{synopt :{opth select(varname)}}Select units of {varname} rather than observations{p_end}
{synopt :{opth seed(real)}}Sets the seed; see {help seed}{p_end}

{title:Description}

{pstd} 
{cmd:randomselect} randomly selects observations and marks them with a dummy variable.
It differs from {cmd:sample} in that it does not drop the non-selected observations from
the data set, and that either individual observations or other units can be randomly
selected. (For example, if each observation in your data set is a household, and each
household lives in a district, you could randomly select some number or portion
 of the districts using 
the {opth select(varname)} option. This would select all households within each
of the randomly selected districts.)

{pstd} 
The user must specify a name for the dummy variable that equals 1 for randomly selected
observations and 0 otherwise using the {opth gen(newvarname)} option. To randomly
select {it:n} observations or other units, 
specify {cmd:n(}{it:n}{cmd:)}; to select a proportion {it:p}
of observations or other units, where 0<{it:p}<1, specify {cmd:prop(}{it:p}{cmd:)}.

{pstd}
To ensure that the randomly selected observations or units are the same during 
subsequent runs of the do file, the seed can be set using the {opth seed(real)} option. 
See {help seed}.

{title:Examples}

{phang} {cmd:. sysuse census}{p_end}

{pstd}Select 10 observations (states){p_end}
{phang} {cmd:. randomselect, gen(selected1) n(10)}{p_end}
{phang} {cmd:. tab selected1}{p_end}

{pstd}Select half of the states in the North-Central region{p_end}
{phang} {cmd:. randomselect if region==2, gen(selected2) prop(0.5)}{p_end}
{phang} {cmd:. tab selected2}{p_end}
{phang} {cmd:. tab selected2 if region==2}{p_end}

{pstd}Select one region (i.e. all states in one region){p_end}
{phang} {cmd:. randomselect, gen(selected3) select(region) n(1)}{p_end}
{phang} {cmd:. tab region selected3}{p_end}

{title:Author}

{p 4 4 2}Sean Higgins, UC Berkeley, seanhiggins@berkeley.edu

