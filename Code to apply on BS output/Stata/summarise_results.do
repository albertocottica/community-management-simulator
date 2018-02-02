insheet using "/Users/albertocottica/github/local/community-management-simulator/Data/MOAT_stage2.csv"


* Flip the ginis for policy, so that they model "both vs. engage" and not "engage vs. both"
ge ms_t_bve = - ms_t_engage_vs_both
ge nc_t_bve = - nc_t_engage_vs_both

* shorten other variable names. "both_vs_engage" => bve; "more_active_vs_newer" => mvn
rename totalcomments_both_vs_engage totalcomments_bve
rename mgmteffort_both_vs_engage mgmteffort_bve
rename nc_t_more_active_vs_newer nc_t_mvn
rename totalmembershipstrength_both_vs_ totalmembershipstrength_bve
rename dropouts_both_vs_engage dropouts_bve
rename ms_t_more_active_vs_newer ms_t_mvn
rename dropouts_more_active_vs_newer dropouts_mvn
rename totalmembershipstrength_more_act totalmembershipstrength_mvn
rename totalcomments_more_active_vs_new totalcomments_mvn
rename mgmteffort_more_active_vs_newer mgmteffort_mvn

* destring the dropouts 
replace dropouts_mvn = "0" if dropouts_mvn == "nan" 
replace dropouts_bve = "0" if dropouts_bve == "nan" 
destring dropouts_mvn dropouts_bve, replace


* invert the sign of the ts as appropriate
* in some tests, the number of dropouts is zero in both cases. Stata puts a nan, that makes my life difficult. 
* I replace those nans with zeros manually 

foreach var in ms_t_bve ms_t_mvn nc_t_bve nc_t_mvn mgmteffort_mvn mgmteffort_bve dropouts_mvn dropouts_bve {
	gen norm_`var' = - `var'
	}
save "/Users/albertocottica/github/local/community-management-simulator/Data/MOAT_final.dta", replace

foreach rand in "false" "true" {
	display as text "randomisedchattiness: " as result "`rand'"
	display "=============================="
	foreach c in float(.1) float(.2) float(.4) {
		display as text "globalchattiness: " as result float(`c')
		display "======================"
		foreach i in 1 5 11 {
			display as text "; intimacystrength: " as result `i' 
			display "================="
			foreach pri in "more active" "newer" {
				display as text "; priority: " as result "`pri'"
				foreach var in dropouts_bve norm_ms_t_bve norm_nc_t_bve totalcomments_bve totalmembershipstrength_bve norm_mgmteffort_bve {
					quietly count if `var' > 2 &`var' !=.
					display as text "`var': " as result r(N)
					}
				display " "	
				}
			}
		}
	}
			
		
