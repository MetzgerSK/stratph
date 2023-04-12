{smcl}
{* *! version 10may2021}{...}
{viewerjumpto "Syntax" "stratph##syntax"}{...}
{viewerjumpto "Description" "stratph##description"}{...}
{viewerjumpto "Examples" "stratph##examples"}{...}
{viewerjumpto "Stored results" "stratph##results"}{...}
{vieweralsosee "mstphtest" "help mstphtest"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[ST] stcox" "help stcox"}{...}
{vieweralsosee "[ST] stcox PH-assumption tests" "help stcox_diagnostics"}{...}
{title:Title}

{p 4 16 2}
{hi:stratph} {hline 2} A convenience wrapper to run proportional hazard tests after estimating a Cox model with stratified baseline hazards
{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{hi:stratph}{cmd:,} [{it:phtest_opts}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{it:phtest_opts}}any of the test-related options associated with {help stcox_diagnostics##options_estat_phtest:estat phtest}: {bf:log, rank, km, time()}.{p_end}
{synoptline}

{p 4 4 2}
The command requires the {search mstatecox:{bf:mstatecox}} package to run (Metzger and Jones 2018).{p_end}

{p 4 4 2}
Must first run {bf:{help stcox}} before running {cmd:stratph}.  {cmd:stcox} must also have the {bf:strata()} 
option specified, and the strata variable's values must be integers.  If {bf:strata()} is not specified,
{bf:stratph} will run the usual {cmd:estat phtest} with no adjustments.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:stratph} is a wrapper function to correctly run proportional hazard tests from Cox models with stratified baseline hazards.  
See {bf:{help mstphtest}}'s help file for an explanation of why and how the standard proportional hazard test should be modified in
the presence of stratified hazards.{p_end}

{pstd}
{cmd:stratph} automatically reports the equivalent of {bf:estat phtest, detail}; {bf:detail} need not be specified as an option again.


{marker examples}{...}
{title:Example}

{pstd}The slightly modified stratified hazard example from {help stcox}{p_end}
{phang2}{cmd:. webuse stan3}{p_end}
{phang2}{cmd:. generate pgroup = year} {p_end}
{phang2}{cmd:. recode pgroup min/69=1 70/72=2 73/max=3}{p_end}
{phang2}{cmd:. stcox age posttran surg, strata(pgroup)}{p_end}
{phang2}{cmd:. stratph}{p_end}
{phang2}{cmd:. stratph, log}{p_end}
{phang2}{cmd:. stratph, km}{p_end}
{phang2}{cmd:. stratph, rank}{p_end}


{marker results}{...}
{title:Stored Results}

{synoptset 22 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{phang2}The same as {bf:{help mstphtest##results:mstphtest}}.{p_end}


{p 0 0 0}
{bf:Last Updated} - 10MAY2021
{p_end}