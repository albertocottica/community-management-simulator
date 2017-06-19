** average ms_ nd nc_ Gini coefficients with quadratic trendlines and jitter ves. chattiness
graph twoway (qfit ms_avg_gini chattiness) (qfit nc_avg_gini chattiness) (scatter ms_avg_gini /// 
nc_avg_gini chattiness, msize(tiny tiny) jitter(5 5)), by (policy)

** scatter of average ms_ and nc_ Ginis + dropouts vs. chattiness
graph twoway (qfit dropouts chattiness, yaxis(1) lcolor(blue) ) ///
(qfit ms_avg_gini chattiness, yaxis(2) lcolor(emerald)) ///
(qfit nc_avg_gini chattiness, yaxis(2) lcolor(red)) ///
(scatter dropouts chattiness, msize(tiny) mcolor(blue) jitter(15) yaxis(1) ylabel(39)) ///
(scatter ms_avg_gini chattiness, msize(tiny) jitter(15) yaxis(2) mcolor(emerald)) ///
(scatter nc_avg_gini chattiness, msize(tiny) jitter(15) yaxis(2) mcolor(red)), by (policy)

** scatter of average ms_ and nc_ Ginis + dropouts vs. intimacystrength
graph twoway (qfit dropouts intimacystrength, yaxis(1) lcolor(blue) ) (qfit ms_avg_gini intimacystrength, /// 
yaxis(2) lcolor(emerald)) (qfit nc_avg_gini intimacystrength, yaxis(2) lcolor(red)) ///
(scatter dropouts intimacystrength, msize(tiny) mcolor(blue) jitter(10) yaxis(1) ylabel(39)) ///
(scatter ms_avg_gini intimacystrength, msize(tiny) jitter(10) yaxis(2) mcolor(emerald)) ///
(scatter nc_avg_gini intimacystrength, msize(tiny) jitter(10) yaxis(2) mcolor(red)), by (policy)

** create a numeric variable corresponding to policy for the purpose of genrating plots

gen policy_num = 0
replace policy_num=1 if policy == "onboard"
replace policy_num = 2 if policy == "engage"
replace policy_num = 3 if policy == "both" 

** we have 9 situations for each group of variables. Start with inequalities.
graph twoway (qfit dropouts policy_num, yaxis(2) lcolor(blue) ) ///
(qfit ms_avg_gini policy_num, yaxis(1) lcolor(emerald)) ///
(qfit nc_avg_gini policy_num, yaxis(1) lcolor(red)) ///
(scatter dropouts policy_num, msize(tiny) mcolor(blue) jitter(5) yaxis(2) ylabel(39, axis(2))) ///
(scatter ms_avg_gini policy_num, msize(tiny) jitter(5) yaxis(1) ylabel(1, axis(1)) mcolor(emerald)) ///
(scatter nc_avg_gini policy_num, msize(tiny) jitter(5) yaxis(1) mcolor(red)), by (intimacystrength chattiness) legend (size(tiny)) 



** Now we look at activity values

graph twoway (scatter totalmembershipstrength policy_num, msize(tiny) mcolor(orange) jitter(5) yaxis(1)  ) ///
(scatter totalcomments policy_num, msize(tiny) jitter(5) yaxis(2) ylabel(100000, axis (2)) ylabel(1.50e+07, axis(1)) mcolor(purple) ) ///
(qfit totalmembershipstrength policy_num, yaxis(1) ylabel(1.50e+07) lcolor(orange) ) ///
(qfit totalcomments policy_num, yaxis(2) lcolor(purple)), by (intimacystrength chattiness) legend(size(small)) 

** Results vs. costs
* dropouts
graph twoway (scatter dropouts policy_num, msize(tiny) mcolor(blue) jitter(1) yaxis(1) ylabel(40, axis(1))) ///
(scatter mycommentsofturtle0 policy_num, msize(tiny) mcolor(gray) jitter(1) yaxis(2) ) ///
(qfit dropouts policy_num, lcolor(blue) yaxis(1)) ///
(qfit mycommentsofturtle0 policy_num, lcolor(gray) yaxis(2)) 

*ms_avg_gini
graph twoway (scatter ms_avg_gini policy_num, msize(tiny) mcolor(emerald) jitter(1) yaxis(1) ylabel(.5, axis(1))) ///
(scatter mycommentsofturtle0 policy_num, msize(tiny) mcolor(gray) jitter(1) yaxis(2) ) ///
(qfit ms_avg_gini policy_num, lcolor(emerald) yaxis(1)) ///
(qfit mycommentsofturtle0 policy_num, lcolor(gray) yaxis(2)) 

*totalmembershipstrength
graph twoway (scatter totalmembershipstrength policy_num, msize(tiny) mcolor(orange) jitter(1) yaxis(1) ylabel(1.50e+07, axis(1))) ///
(scatter mycommentsofturtle0 policy_num, msize(tiny) mcolor(gray) jitter(1) yaxis(2) ) ///
(qfit totalmembershipstrength policy_num, lcolor(orange) yaxis(1)) ///
(qfit mycommentsofturtle0 policy_num, lcolor(gray) yaxis(2)) 
