log using "/Users/albertocottica/github/local/community-management-simulator-2/Data/Prepare_data-2.smcl"

insheet using "/Users/albertocottica/github/local/community-management-simulator-2/Data/dataByTurtle_v4_batch2.csv", comma

* Goal: compute in-run Gini coefficients and their SE for ms and nc

svyset _n

quietly separate ms , by (run)
quietly separate nc, by (run)


* create new variables to store the values
generate ms_gini = 0
generate ms_se_gini = 0
generate nc_gini = 0
generate nc_se_gini = 0

* what follows needs to be done in batches  

forval i=1367/1728 {
	quietly svylorenz ms`i' 
	quietly replace ms_gini = e(gini) if runnumber == `i'
	quietly replace ms_se_gini = e(se_gini) if runnumber == `i'
	quietly svylorenz nc`i' 
	quietly replace nc_gini = e(gini) if runnumber == `i'
	quietly replace nc_se_gini = e(se_gini) if runnumber == `i'
	* drop observations, reducing dimensionality
	quietly drop if runnumber == `i' & id != 1 
	* drop already used ms_n and nc_n variables, further reducing dimensionality
	quietly drop ms`i'
	quietly drop nc`i'
	}
save "/Users/albertocottica/github/local/community-management-simulator-2/Data/data-w-gini-batch2.dta", replace

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

foreach ie in 1 5 11 {
	foreach gc in 0.1 0.2 0.4 {
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

* now create the variable relative to ms (membership strength)
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



