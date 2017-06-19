** manually adds avg ginis to data-w-gini-retry
** I take them from data-w-avg-gini-retry-all.csv

use "/Users/albertocottica/github/local/community-management-simulator-2/Data/data-w-gini-retry-all.dta"


gen ms_avg_gini = 0









** from here on it's based on the version with the four policy scenarios. 
* 1
replace ms_avg_gini = 0.16139221666666664 if chattiness == float(.1) & intimacystrength == float(1) & policy == "none"
replace ms_avg_gini = 0.15577471249999997 if chattiness == float(.1) & intimacystrength == float(1) & policy == "onboard"
replace ms_avg_gini = 0.1462696333333333 if chattiness == float(.1) & intimacystrength == float(1) & policy == "engage"
replace ms_avg_gini = 0.14358343749999997 if chattiness == float(.1) & intimacystrength == float(1) & policy == "both"
* 2
replace ms_avg_gini = 0.20487718333333332 if chattiness == float(.1) & intimacystrength == float(5) & policy == "none"
replace ms_avg_gini = 0.1959980541666667 if chattiness == float(.1) & intimacystrength == float(5) & policy == "onboard"
replace ms_avg_gini = 0.17472209583333334 if chattiness == float(.1) & intimacystrength == float(5) & policy == "engage"
replace ms_avg_gini = 0.171155175 if chattiness == float(.1) & intimacystrength == float(5) & policy == "both"
* 3 
replace ms_avg_gini = 0.3185278999999999 if chattiness == float(.1) & intimacystrength == float(11) & policy == "none"
replace ms_avg_gini = 0.296274125 if chattiness == float(.1) & intimacystrength == float(11) & policy == "onboard"
replace ms_avg_gini = 0.2407405291666666 if chattiness == float(.1) & intimacystrength == float(11) & policy == "engage"
replace ms_avg_gini = 0.23764029166666673 if chattiness == float(.1) & intimacystrength == float(11) & policy == "both"
* 4
replace ms_avg_gini = 0.15626230416666667 if chattiness == float(.15) & intimacystrength == float(1) & policy == "none"
replace ms_avg_gini = 0.15249917083333336 if chattiness == float(.15) & intimacystrength == float(1) & policy == "onboard"
replace ms_avg_gini = 0.14347890416666667 if chattiness == float(.15) & intimacystrength == float(1) & policy == "engage"
replace ms_avg_gini = 0.14117049166666668 if chattiness == float(.15) & intimacystrength == float(1) & policy == "both"
* 5
replace ms_avg_gini = 0.21882846249999993 if chattiness == float(.15) & intimacystrength == float(5) & policy == "none"
replace ms_avg_gini = 0.21387353333333334 if chattiness == float(.15) & intimacystrength == float(5) & policy == "onboard"
replace ms_avg_gini = 0.18949254999999998 if chattiness == float(.15) & intimacystrength == float(5) & policy == "engage"
replace ms_avg_gini = 0.1874928958333333 if chattiness == float(.15) & intimacystrength == float(5) & policy == "both"
* 6 
replace ms_avg_gini = 0.3331320375 if chattiness == float(.15) & intimacystrength == float(11) & policy == "none"
replace ms_avg_gini = 0.31712989999999996 if chattiness == float(.15) & intimacystrength == float(11) & policy == "onboard"
replace ms_avg_gini = 0.2614432166666667 if chattiness == float(.15) & intimacystrength == float(11) & policy == "engage"
replace ms_avg_gini = 0.2572214125 if chattiness == float(.15) & intimacystrength == float(11) & policy == "both"
* 7
replace ms_avg_gini = 0.15663459166666668 if chattiness == float(.4) & intimacystrength == float(1) & policy == "none"
replace ms_avg_gini = 0.15614493333333332 if chattiness == float(.4) & intimacystrength == float(1) & policy == "onboard"
replace ms_avg_gini = 0.14501714999999996 if chattiness == float(.4) & intimacystrength == float(1) & policy == "engage"
replace ms_avg_gini = 0.14344059583333332 if chattiness == float(.4) & intimacystrength == float(1) & policy == "both"
* 8
replace ms_avg_gini = 0.3161781791666667 if chattiness == float(.4) & intimacystrength == float(5) & policy == "none"
replace ms_avg_gini = 0.31497534583333336 if chattiness == float(.4) & intimacystrength == float(5) & policy == "onboard"
replace ms_avg_gini = 0.26228410416666664 if chattiness == float(.4) & intimacystrength == float(5) & policy == "engage"
replace ms_avg_gini = 0.2603407708333333 if chattiness == float(.4) & intimacystrength == float(5) & policy == "both"
* 9 
replace ms_avg_gini = 0.3680332458333333 if chattiness == float(.4) & intimacystrength == float(11) & policy == "none"
replace ms_avg_gini = 0.3608242666666666 if chattiness == float(.4) & intimacystrength == float(11) & policy == "onboard"
replace ms_avg_gini = 0.2950215958333333 if chattiness == float(.4) & intimacystrength == float(11) & policy == "engage"
replace ms_avg_gini = 0.2933346375 if chattiness == float(.4) & intimacystrength == float(11) & policy == "both"

gen nc_avg_gini = 0
* 1
replace nc_avg_gini = 0.33740169583333335 if chattiness == float(.1) & intimacystrength == float(1) & policy == "none"
replace nc_avg_gini = 0.33727507500000004 if chattiness == float(.1) & intimacystrength == float(1) & policy == "onboard"
replace nc_avg_gini = 0.3369387583333333 if chattiness == float(.1) & intimacystrength == float(1) & policy == "engage"
replace nc_avg_gini = 0.33821982083333335 if chattiness == float(.1) & intimacystrength == float(1) & policy == "both"
* 2
replace nc_avg_gini = 0.3795590999999999 if chattiness == float(.1) & intimacystrength == float(5) & policy == "none"
replace nc_avg_gini = 0.3789227000000001 if chattiness == float(.1) & intimacystrength == float(5) & policy == "onboard"
replace nc_avg_gini = 0.3790717208333334 if chattiness == float(.1) & intimacystrength == float(5) & policy == "engage"
replace nc_avg_gini = 0.37801767499999994 if chattiness == float(.1) & intimacystrength == float(5) & policy == "both"
* 3 
replace nc_avg_gini = 0.4531555583333333 if chattiness == float(.1) & intimacystrength == float(11) & policy == "none"
replace nc_avg_gini = 0.45158848333333335 if chattiness == float(.1) & intimacystrength == float(11) & policy == "onboard"
replace nc_avg_gini = 0.4496781666666667 if chattiness == float(.1) & intimacystrength == float(11) & policy == "engage"
replace nc_avg_gini = 0.4503937625 if chattiness == float(.1) & intimacystrength == float(11) & policy == "both"
* 4
replace nc_avg_gini = 0.3374920333333335 if chattiness == float(.15) & intimacystrength == float(1) & policy == "none"
replace nc_avg_gini = 0.3379287833333333 if chattiness == float(.15) & intimacystrength == float(1) & policy == "onboard"
replace nc_avg_gini = 0.3376599124999999 if chattiness == float(.15) & intimacystrength == float(1) & policy == "engage"
replace nc_avg_gini = 0.3383849916666666 if chattiness == float(.15) & intimacystrength == float(1) & policy == "both"
* 5
replace nc_avg_gini = 0.39828168333333336 if chattiness == float(.15) & intimacystrength == float(5) & policy == "none"
replace nc_avg_gini = 0.39957237500000004 if chattiness == float(.15) & intimacystrength == float(5) & policy == "onboard"
replace nc_avg_gini = 0.39834315000000003 if chattiness == float(.15) & intimacystrength == float(5) & policy == "engage"
replace nc_avg_gini = 0.3988189541666665 if chattiness == float(.15) & intimacystrength == float(5) & policy == "both"
* 6 
replace nc_avg_gini = 0.47298030833333327 if chattiness == float(.15) & intimacystrength == float(11) & policy == "none"
replace nc_avg_gini = 0.47213847083333327 if chattiness == float(.15) & intimacystrength == float(11) & policy == "onboard"
replace nc_avg_gini = 0.47139499999999995 if chattiness == float(.15) & intimacystrength == float(11) & policy == "engage"
replace nc_avg_gini = 0.47006408749999995 if chattiness == float(.15) & intimacystrength == float(11) & policy == "both"
* 7
replace nc_avg_gini = 0.34986008749999997 if chattiness == float(.4) & intimacystrength == float(1) & policy == "none"
replace nc_avg_gini = 0.3511506125000001 if chattiness == float(.4) & intimacystrength == float(1) & policy == "onboard"
replace nc_avg_gini = 0.3498754125 if chattiness == float(.4) & intimacystrength == float(1) & policy == "engage"
replace nc_avg_gini = 0.34931557916666667 if chattiness == float(.4) & intimacystrength == float(1) & policy == "both"
* 8
replace nc_avg_gini = 0.4788851916666667 if chattiness == float(.4) & intimacystrength == float(5) & policy == "none"
replace nc_avg_gini = 0.4801358166666667 if chattiness == float(.4) & intimacystrength == float(5) & policy == "onboard"
replace nc_avg_gini = 0.4789364666666666 if chattiness == float(.4) & intimacystrength == float(5) & policy == "engage"
replace nc_avg_gini = 0.47912410416666673 if chattiness == float(.4) & intimacystrength == float(5) & policy == "both"
* 9 
replace nc_avg_gini = 0.5050984083333333 if chattiness == float(.4) & intimacystrength == float(11) & policy == "none"
replace nc_avg_gini = 0.5033633875000001 if chattiness == float(.4) & intimacystrength == float(11) & policy == "onboard"
replace nc_avg_gini = 0.5031228958333334 if chattiness == float(.4) & intimacystrength == float(11) & policy == "engage"
replace nc_avg_gini = 0.5032744416666666 if chattiness == float(.4) & intimacystrength == float(11) & policy == "both"

