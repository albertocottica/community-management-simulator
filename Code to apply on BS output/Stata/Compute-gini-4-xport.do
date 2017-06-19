insheet using "/Users/albertocottica/github/local/community-management-simulator-2/Data/dataByTurtle_v4_batch2.csv", comma
* the "separate" command has a limit of 1,500 groups (I have 1,728 runs). 
* hack: compute the Ginis in two halves of the dataset, then join them again. 
* repeat this with "<path>/dataByTurtle_v4_batch2.csv"

* first save the file into a .dta, so I can use the "replace" option in the rest of the script

save "/Users/albertocottica/github/local/community-management-simulator-2/Data/data-w-gini-retry_batch2.dta"

* Goal: compute in-run Gini coefficients and their SE for ms and nc

svyset _n

quietly separate ms , by (runnumber)
quietly separate nc, by (runnumber)


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
	
* remember to change the name of the output file too. 	
save "/Users/albertocottica/github/local/community-management-simulator-2/Data/data-w-gini-retry_batch2.dta", replace
