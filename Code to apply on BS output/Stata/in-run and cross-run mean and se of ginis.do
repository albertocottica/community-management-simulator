insheet using "/Users/albertocottica/github/local/community-management-simulator/Data/Experiment_3/dataByTurtle_v4_experiment_3.csv"

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

* Create a qualitative variable for intimacy strength for prettier chart legends
gen is = "xxxx"
replace is = "low" if intimacystrength == float(0.1)
replace is = "mid" if intimacystrength == float(3.3)
replace is = "high" if intimacystrength == float(10)


save "/Users/albertocottica/github/local/community-management-simulator/Data/Experiment_3/data-w-gini-experiment-3.dta", replace
outsheet using "/Users/albertocottica/github/local/community-management-simulator/Data/Experiment_3/data-w-gini-experiment-3.csv", comma replace

