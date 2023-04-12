*! strat(ify)ph(test), v1.2
*! Last update: 10MAY21
/*
	A wrapper function to expedite properly adjusting for the presence of
	strata when computing the Schoenfeld-based PH test.
	
	This command calls mstphtest from the mstatecox package (which itself
	is a wrapper for estat phtest), which automatically adjusts for the
	presence of strata.
	
*/

cap program drop stratph
program define stratph, rclass
qui{
	syntax , [*]	// specify any estat phtest options after the comma
	
	// Make sure stcox's been run
	if("`e(cmd2)'"!="stcox"){
		local extra = ""
		if("`sdur'"==""){
			local extra ="with strata "
		}
		noi di as err "You must estimate {bf:stcox} `extra'before running {bf:stratph}.  Try again."
		exit 198
	}
	
	// Check that model has strata.  If no strata, then just run the usual
	// estat phtest and exit.
	if("`e(strata)'"==""){
		noi di in gr "No strata detected.  No adjustments required."
		noi di in gr "Calling {bf:estat phtest}".
		noi estat phtest, d `options'
		exit
	}
	
	// Check that mstatecox is installed
	cap which mstutil
	if(_rc!=0){
		noi di as error "{bf:mstatecox} package required ({stata findit mstatecox})"
		exit 198
	}
    
	// If mstutil hasn't been called, then quietly set it.
	if("`e(from)'"==""){
		// tempname for model
		tempname origCox
        
		// Make a note that we're setting this; snapshot current results.
		local mstSet = "yes"
		_estimates hold `origCox', restore copy
		
		// If the smallest value of strata isn't 2, make it so => fake toStg var
		tempvar to
		gen `to' = .
		qui sum `e(strata)'
		if(`r(min)'>=2)		replace `to' = `e(strata)'
		else				replace `to' = `e(strata)' + (2 - `r(min)')
		
		// find an integer value that's not in the new toStg var, to serve
		// as the from stage (should be 1, with how you've written the above,
		// but just in case)
		local frm = 1
		while `frm'>-1	{ // (bogus cond--the actual stop cond's inside the loop)
			count if(`to'==`frm')
			** no one has this value--treat as stage ID for from
			if(`r(N)'==0) 	continue, break
			** someone has this value, add 1 to frm
			else			local `frm++'
		}
		
		// Create fake from and to variable
		tempvar from
		gen `from' = `frm'
	
		// mstutil
		cap mstutil, from(`from') to(`to')
		
		// Ensure strata are integers
		if(_rc==125){
			noi di as err "{bf:`e(strata)'} may contain non-integer values; must contain integers only.  Recode and try again."
			exit 125
		}
	}

	// Print conversion for trans ID and strata vals
	noi di _n as gr "*** NOTE: transition ID value = " as ye "`e(strata)'" as gr "'s value"
	
	// Run the PH test
    tempname mstph
	noi mstphtest, `options'
    _return hold `mstph'        // snapshot of everything in r-class memory

	// Run collinearity checks on each stratum, print info message if needed
	* Get list of all strata values
	qui levelsof `e(trans)', local(trNos) 
	
	* Covariate list
	local covars: colnames e(b) 
	local covars: list uniq covars	// in case TVC vars present, toss any duplicates
	
	* Loop over strata vals
	local rnCnt = 0 	// running count of how many trIDs have dropped vars
	foreach tr of local trNos{
		** Do the actual collinearity check
		_rmdcoll _d `covars' if(`e(trans)'==`tr')
		
		** If something's dropped, store its name + trans ID
		if(`r(k_omitted)'>0){
			*** if this is first time in this chunk, print opening info msg
			if(`rnCnt'==0){
				noi di _n _n as red "NOTE: " as gr "the following variables are collinear within the listed stratum"
				noi di ""
			}
			*** trans ID
			noi di as gr "`e(strata)' = `tr'"
			*** names
			getDroppedVars, v("`r(varlist)'") 
			noi di as ye "  `r(dropVars)'"
			*** update ctr
			local `rnCnt++'
		}
	}

	// If you mstset stuff, clear it all
	if("`mstSet'"!="")		_estimates unhold `origCox'	// gets rid of e() entries

	// Restore mstphtest snapshot of r-class memory
	_return res `mstph'
    return add
}
end

**************************************
cap prog drop getDroppedVars
prog define getDroppedVars, rclass
{
	syntax, Varlist(string)
	
	// Initialize
	tempname vars t
	
	// Throw list into Mata
	mata: `t' = tokeninit()
	mata: tokenset(`t',"`varlist'")
	mata: `vars' = tokengetall(`t')'
	
	// Keep rows that start with "o." (= omitted)
	mata: `vars' = select(`vars', regexm(`vars', "^o\."))
	mata: `vars' = sort(subinstr(`vars', "o.", "", .),1)	// sort to alphabetize
	
	// Throw into comma-separated string, throw back to Stata
	mata: `vars' = invtokens(`vars'', ", ")
	mata: st_local("dList", `vars')
	
	// Return as local
	return local dropVars "`dList'"
	
	// Tidy
	cap mata mata drop `vars' `t'
}
end