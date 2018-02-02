use "/Users/albertocottica/github/local/community-management-simulator/Data/data-w-gini-retry_replica_merge_batches.dta"

* divide obs in blocks of 24 obs each. All parameters have within-block identical values. 
* Params of autocode() need to be changed according to the experiment
ge qqq = int(autocode (runnumber, 24, 1, 576)) 

* compute in-block mean (inblockmean) and standard error (inblockse)
egen ms_inblockmean = mean(ms_gini), by (qqq)
egen ms_inblockse = mean(ms_se_gini^2), by (qqq)
replace ms_inblockse = sqrt(ms_inblockse)

* compute in-block mean (inblockmean) and standard error (inblockse)
egen nc_inblockmean = mean(nc_gini), by (qqq)
egen nc_inblockse = mean(nc_se_gini^2), by (qqq)
replace nc_inblockse = sqrt(nc_inblockse)

*** not used from here on. I compute t-stats in Python.

* compute T and bilateral p-value. These are t-stats for H0 "ms_gini = 0". Not useful here.
* ge ms_tstat = ms_inblockmean/ms_inblockse
* ge ms_pval = 1 - normal(abs(ms_tstat))


** What follows: t-tests with "normal" SEs, so run from within Stata.
** same order as the "print t-stats.py" program
** for policies, full form

log using "/Users/albertocottica/github/local/community-management-simulator/Data/t-tests--by-policy-with-Stata", replace
set more off
foreach c in float(.1) float(.2) float(.4) {
	foreach i in 1 5 11 {
		foreach rand in "true" "false" {
			foreach pri in "newer" "more active" {
				foreach var in dropouts totalmembershipstrength totalcomments mgmteffort {
					display as text "globalchattiness = " as result `c'
					display as text "intimacystrength = " as result `i'
					display as text "randomisedchattiness = " as result "`rand'"
					display as text "priority = " as result "`pri'"
					display as text "Test for = " as result "`var'"
					ttest `var' if globalchattiness == `c' & intimacystrength == `i' & randomisedchattines == "`rand'" ///
					& priority == "`pri'", by(policy)
					}
				}
			}
		}
	}
set more on
log close
		
** for policies, t-stats only
log using "/Users/albertocottica/github/local/community-management-simulator/Data/t-tests-by-policy-tstats-only", replace
set more off
foreach c in float(.1) float(.2) float(.4) {
	foreach i in 1 5 11 {
		foreach rand in "true" "false" {
			foreach pri in "newer" "more active" {
				foreach var in dropouts totalmembershipstrength totalcomments mgmteffort {
					display as text "globalchattiness = " as result `c'
					display as text "intimacystrength = " as result `i'
					display as text "randomisedchattiness = " as result "`rand'"
					display as text "priority = " as result "`pri'"
					display as text "Test for = " as result "`var'"
					quietly ttest `var' if globalchattiness == `c' & intimacystrength == `i' & randomisedchattines == "`rand'" ///
					& priority == "`pri'", by(policy)
					display as text "T = " as result r(t)
					display " "
					}
				}
			}
		}
	}
log close

** for priorities, full form
log using "/Users/albertocottica/github/local/community-management-simulator/Data/t-tests-by-priority-with-Stata", replace
set more off
foreach c in float(.1) float(.2) float(.4) {
	foreach i in 1 5 11 {
		foreach rand in "true" "false" {
			foreach p in "engage" "both" {
				foreach var in dropouts totalmembershipstrength totalcomments mgmteffort {
					display as text "globalchattiness = " as result `c'
					display as text "intimacystrength = " as result `i'
					display as text "randomisedchattiness = " as result "`rand'"
					display as text "policy = " as result "`p'"
					display as text "Test for = " as result "`var'"
					ttest `var' if globalchattiness == `c' & intimacystrength == `i' & randomisedchattines == "`rand'" ///
					& policy == "`p'", by(priority)
					}
				}
			}
		}
	}
set more on
log close

** for priorities, t-stats only 
log using "/Users/albertocottica/github/local/community-management-simulator/Data/t-tests-by-priority-tstats-only", replace
set more off
foreach c in float(.1) float(.2) float(.4) {
	foreach i in 1 5 11 {
		foreach rand in "true" "false" {
			foreach p in "engage" "both" {
				foreach var in dropouts totalmembershipstrength totalcomments mgmteffort {
					display as text "globalchattiness = " as result `c'
					display as text "intimacystrength = " as result `i'
					display as text "randomisedchattiness = " as result "`rand'"
					display as text "priority = " as result "`p'"
					display as text "Test for = " as result "`var'"
					quietly ttest `var' if globalchattiness == `c' & intimacystrength == `i' & randomisedchattines == "`rand'" ///
					& policy == "`p'", by(priority)
					display as text "T = " as result r(t)
					}
				}
			}
		}
	}
set more on
log close
				
