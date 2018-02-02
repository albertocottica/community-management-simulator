log using "/Users/albertocottica/github/local/community-management-simulator/Data/Prepare_data-2.smcl"

insheet using "/Volumes/Free for now/community-management-simulator/Data/dataByTurtle_v4_replica_batch1_2.csv"
* Goal: compute in-run Gini coefficients and their SE for ms and nc

quietly separate ms, by(run)
quietly separate nc, by(run)
save "/Users/albertocottica/github/local/community-management-simulator/Data/Experiment_3/data-w-gini-experiment-3.dta", replace



* create new variables to store the values
generate ms_gini = 0
generate ms_se_gini = 0
generate nc_gini = 0
generate nc_se_gini = 0

* what follows needs to be done in batches for large files

* variant: fastgini
forval i=1/576 {
	quietly fastgini ms`i', jk 
	quietly replace ms_gini = r(gini_jk) if runnumber == `i'
	quietly replace ms_se_gini = r(se) if runnumber == `i'
	quietly fastgini nc`i', jk 
	quietly replace nc_gini = r(gini_jk) if runnumber == `i'
	quietly replace nc_se_gini = r(se) if runnumber == `i'
	* drop observations, reducing dimensionality
	quietly drop if runnumber == `i' & id != 1 
	* drop already used ms_n and nc_n variables, further reducing dimensionality
	quietly drop ms`i'
	quietly drop nc`i'
	}
save "/Users/albertocottica/github/local/community-management-simulator/Data/Experiment_3/data-w-gini-experiment-3.dta", replace

* now create variables with in-run average ginis and their SE. Start with ms_gini.
* each average is computed on 24 runs with all other variables fixed.

* notice: ms_gini => the in-run Gini coefficient on ms 
* total_ms_gini => the sum of ms_gini across runs with the same parameter vector
* avg_ms_gini => the average ms_gini across runs with the same parameter vector
* ms_se_gini => the in-run standard error of the Gini coefficient on ms
* total_ms_gini => the sum the Gini coefficient on ms across runs with the same parameter vector

* now create variables with in-run average ginis and their SE. Start with nc_gini.
* each average is computed on 24 runs with all other variables fixed.

* notice: ms_gini => the in-run Gini coefficient on ms 
* total_ms_gini => the sum of ms_gini across runs with the same parameter vector
* avg_ms_gini => the average ms_gini across runs with the same parameter vector
* ms_se_gini => the in-run standard error of the Gini coefficient on ms
* total_ms_gini => the sum the Gini coefficient on ms across runs with the same parameter vector

gen ms_avg_gini = 0
gen total_ms_gini = 0
gen nc_avg_gini = 0
gen total_nc_gini = 0

gen is = "xxxx"
replace is = "low" if intimacystrength == float(0.1)
replace is = "mid" if intimacystrength == float(3.3)
replace is = "high" if intimacystrength == float(10)


* variant for experiment 1
* compute the sum of the ms_ginis, total_ms_gini, and nc_ginis, total_nc_gini by parameter vector value
foreach gc in 0.05 0.4 {
	foreach rand in "false" "true" {
		foreach str in "low" "mid" "high" {
			egen total_ms_gini_2 = total(ms_gini) if globalchattiness == float(`gc') & randomisedchattiness == "`rand'" & is == "`str'", by(policy)
			replace total_ms_gini = total_ms_gini_2 if globalchattiness == float(`gc') & randomisedchattiness == "`rand'" & is == "`str'"
			drop total_ms_gini_2
			egen total_nc_gini_2 = total(nc_gini) if globalchattiness == float(`gc') & randomisedchattiness == "`rand'" & is == "`str'", by(policy)
			replace total_nc_gini = total_nc_gini_2 if globalchattiness == float(`gc') & randomisedchattiness == "`rand'" & is == "`str'"
			drop total_nc_gini_2
			}
		}
	}


* qualitative variable for intimacystrength (for tidier graphs)
gen is = "xxxx"
replace is = "low" if intimacystrength == float(0.1)
replace is = "mid" if intimacystrength == float(3.3)
replace is = "high" if intimacystrength == float(10)

* variant for experiment 2_1
* compute the sum of the ms_ginis, total_ms_gini, by parameter vector value
foreach gc in 0.05 0.4 {
	foreach ie in "low" "mid" "high" {
		egen total_ms_gini_2 = total(ms_gini) if globalchattiness == float(`gc') & is == "`ie'", by (policy)
		replace total_ms_gini = total_ms_gini_2 if globalchattiness == float(`gc') & is == "`ie'"
		drop total_ms_gini_2
		}
	}
* compute the sum of the nc_ginis, total_nc_gini, by parameter vector value
foreach gc in 0.05 0.4 {
	foreach ie in "low" "mid" "high" {
		egen total_nc_gini_2 = total(nc_gini) if globalchattiness == float(`gc') & is == "`ie'", by (policy)
		replace total_nc_gini = total_nc_gini_2 if globalchattiness == float(`gc') & is == "`ie'"
		drop total_nc_gini_2
		}
	}
	
* variant for experiment 2_2

foreach rand in "false" "true" {
	foreach gc in 0.05 0.4 {
		foreach ie in "low" "mid" "high" {
			egen total_ms_gini_2 = total(ms_gini) if randomisedchattiness == "`rand'" & globalchattiness == float(`gc') & is == "`ie'", by (policy)
			replace total_ms_gini = total_ms_gini_2 if randomisedchattiness == "`rand'" & globalchattiness == float(`gc') & is == "`ie'"	
			drop total_ms_gini_2
			egen total_nc_gini_2 = total(nc_gini) if randomisedchattiness == "`rand'" & globalchattiness == float(`gc') & is == "`ie'", by (policy)
			replace total_nc_gini = total_nc_gini_2 if randomisedchattiness == "`rand'" & globalchattiness == float(`gc') & is == "`ie'"	
			drop total_nc_gini_2
			}
		}
	}	
				
replace ms_avg_gini = (1/24) * total_ms_gini
drop total_ms_gini
replace nc_avg_gini = (1/24) * total_nc_gini
drop total_nc_gini




* variant for main experiment

foreach ie in 0.1 3.3 10 {
	foreach gc in 0.05 0.4 {
		foreach pl in engage both {
			foreach rc in "false" "true" {
			egen total_ms_gini_2 = total(ms_gini) if intimacystrength == `ie' & globalchattiness == float(`gc') & policy == "`pl'" & randomisedchattiness == "`rc'", by (priority)
			replace total_ms_gini = total_ms_gini_2 if intimacystrength == `ie' & globalchattiness == float(`gc') & policy == "`pl'" & randomisedchattiness == "`rc'" 
			drop total_ms_gini_2
			}
		}
	}
}




replace ms_avg_gini = (1/24) * total_ms_gini
drop total_ms_gini
gen nc_avg_gini = 0
gen total_nc_gini = 0

foreach ie in 1 5 11 {
	foreach gc in 0.1 0.2 0.4 {
		foreach pl in engage both {
			foreach rc in "false" "true" {
			egen total_nc_gini_2 = total(nc_gini) if intimacystrength == `ie' & globalchattiness == float(`gc') & policy == "`pl'" & randomisedchattiness == "`rc'", by (priority)
			replace total_nc_gini = total_nc_gini_2 if intimacystrength == `ie' & globalchattiness == float(`gc') & policy == "`pl'" & randomisedchattiness == "`rc'" 
			drop total_nc_gini_2
			}
		}
	}
}

replace nc_avg_gini = (1/24) * total_nc_gini
drop total_nc_gini

* standard error  

* create the variable relative to ms (membership strength)
gen ms_xrun_se_gini = 0
* square all within-runs ses
gen ms_se_gini_2 = ms_se_gini^2
* sum them. Here I need to distinguish the different parameter vectors

* variant for experiment 1

foreach gc in 0.05 0.4 {
	foreach rc in "false" "true" {
		egen total_ms_se_gini_2 = total(ms_se_gini_2) if globalchattiness == float(`gc') & randomisedchattiness == "`rc'", by (is)
		replace ms_xrun_se_gini = sqrt(total_ms_se_gini_2)/24 if globalchattiness == float(`gc') & randomisedchattiness == "`rc'" 
		drop total_ms_se_gini_2
		}
	}


* variant for main experiment

foreach ie in 1 5 11 {
	foreach gc in 0.1 0.2 0.4 {
		foreach pl in engage both {
			foreach rc in "false" "true" {
			egen total_ms_se_gini_2 = total(ms_se_gini_2) if intimacystrength == `ie' & globalchattiness == float(`gc') & policy == "`pl'" & randomisedchattiness == "`rc'", by (priority)
			replace ms_xrun_se_gini = sqrt(total_ms_se_gini_2)/24 if intimacystrength == `ie' & globalchattiness == float(`gc') & policy == "`pl'" & randomisedchattiness == "`rc'" 
			drop total_ms_se_gini_2
			}
		}
	}
}

* now create the variable relative to nc (number of comments)
gen nc_xrun_se_gini = 0
* square all within-runs ses
gen nc_se_gini_2 = nc_se_gini^2
* sum them. Here I need to distinguish the different parameter vectors

foreach ie in 1 5 11 {
	foreach gc in 0.1 0.2 0.4 {
		foreach pl in engage both {
			foreach rc in "false" "true" {
			egen total_nc_se_gini_2 = total(nc_se_gini_2) if intimacystrength == `ie' & globalchattiness == float(`gc') & policy == "`pl'" & randomisedchattiness == "`rc'", by (priority)
			replace nc_xrun_se_gini = sqrt(total_nc_se_gini_2)/24 if intimacystrength == `ie' & globalchattiness == float(`gc') & policy == "`pl'" & randomisedchattiness == "`rc'" 
			drop total_nc_se_gini_2
			}
		}
	}
}



