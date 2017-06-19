rename mycommentsofturtle0 effort
label variable effort "N. comments of comm manager"
rename totalmembershipstrength totalms
label variable ms "Total membership strength"
gen onboard = 1 if policy == "onboard"
replace onboard = 1 if policy != "onboard"
replace onboard = 1 if policy == "both"
gen engage = 1 if policy == "engage"
replace engage = 0 if policy != "engage"
replace engage = 1 if policy == "both"
gen effort2 = effort * effort
