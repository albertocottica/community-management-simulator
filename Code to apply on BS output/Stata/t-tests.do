
* now the t-tests. the t-statistics for the two Gini coefficients are computed in Python. :-(
* remember to do this for all cases: chattiness high-low, intimacy strength hi-low

* totalcomments:
** 0
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "engage"), by (policy)
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "both"), by (policy)
** 1
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.15) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.15) & (policy == "none" | policy == "engage"), by (policy)
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.15) & (policy == "none" | policy == "both"), by (policy)
** 2 
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.4) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.4) & (policy == "none" | policy == "engage"), by (policy)
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.4) & (policy == "none" | policy == "both"), by (policy)
** 3 
ttest totalcomments if intimacystrength == float(1) & chattiness == float(.1) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalcomments if intimacystrength == float(1) & chattiness == float(.1) & (policy == "none" | policy == "engage"), by (policy)
ttest totalcomments if intimacystrength == float(1) & chattiness == float(.1) & (policy == "none" | policy == "both"), by (policy)
** 4 
ttest totalcomments if intimacystrength == float(1) & chattiness == float(.15) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalcomments if intimacystrength == float(1) & chattiness == float(.15) & (policy == "none" | policy == "engage"), by (policy)
ttest totalcomments if intimacystrength == float(1) & chattiness == float(.15) & (policy == "none" | policy == "both"), by (policy)
** 5
ttest totalcomments if intimacystrength == float(1) & chattiness == float(.4) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalcomments if intimacystrength == float(1) & chattiness == float(.4) & (policy == "none" | policy == "engage"), by (policy)
ttest totalcomments if intimacystrength == float(1) & chattiness == float(.4) & (policy == "none" | policy == "both"), by (policy)
** 6
ttest totalcomments if intimacystrength == float(5) & chattiness == float(.1) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalcomments if intimacystrength == float(5) & chattiness == float(.1) & (policy == "none" | policy == "engage"), by (policy)
ttest totalcomments if intimacystrength == float(5) & chattiness == float(.1) & (policy == "none" | policy == "both"), by (policy)
** 7
ttest totalcomments if intimacystrength == float(5) & chattiness == float(.15) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalcomments if intimacystrength == float(5) & chattiness == float(.15) & (policy == "none" | policy == "engage"), by (policy)
ttest totalcomments if intimacystrength == float(5) & chattiness == float(.15) & (policy == "none" | policy == "both"), by (policy)
** 8
ttest totalcomments if intimacystrength == float(5) & chattiness == float(.4) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalcomments if intimacystrength == float(5) & chattiness == float(.4) & (policy == "none" | policy == "engage"), by (policy)
ttest totalcomments if intimacystrength == float(5) & chattiness == float(.4) & (policy == "none" | policy == "both"), by (policy)

* totalmembershipstrength:
** 0
ttest totalmembershipstrength if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "engage"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "both"), by (policy)
** 1
ttest totalmembershipstrength if intimacystrength == float(11) & chattiness == float(.15) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(11) & chattiness == float(.15) & (policy == "none" | policy == "engage"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(11) & chattiness == float(.15) & (policy == "none" | policy == "both"), by (policy)
** 2 
ttest totalmembershipstrength if intimacystrength == float(11) & chattiness == float(.4) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(11) & chattiness == float(.4) & (policy == "none" | policy == "engage"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(11) & chattiness == float(.4) & (policy == "none" | policy == "both"), by (policy)
** 3 
ttest totalmembershipstrength if intimacystrength == float(1) & chattiness == float(.1) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(1) & chattiness == float(.1) & (policy == "none" | policy == "engage"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(1) & chattiness == float(.1) & (policy == "none" | policy == "both"), by (policy)
** 4 
ttest totalmembershipstrength if intimacystrength == float(1) & chattiness == float(.15) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(1) & chattiness == float(.15) & (policy == "none" | policy == "engage"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(1) & chattiness == float(.15) & (policy == "none" | policy == "both"), by (policy)
** 5
ttest totalmembershipstrength if intimacystrength == float(1) & chattiness == float(.4) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(1) & chattiness == float(.4) & (policy == "none" | policy == "engage"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(1) & chattiness == float(.4) & (policy == "none" | policy == "both"), by (policy)
** 6
ttest totalmembershipstrength if intimacystrength == float(5) & chattiness == float(.1) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(5) & chattiness == float(.1) & (policy == "none" | policy == "engage"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(5) & chattiness == float(.1) & (policy == "none" | policy == "both"), by (policy)
** 7
ttest totalmembershipstrength if intimacystrength == float(5) & chattiness == float(.15) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(5) & chattiness == float(.15) & (policy == "none" | policy == "engage"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(5) & chattiness == float(.15) & (policy == "none" | policy == "both"), by (policy)
** 8
ttest totalmembershipstrength if intimacystrength == float(5) & chattiness == float(.4) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(5) & chattiness == float(.4) & (policy == "none" | policy == "engage"), by (policy)
ttest totalmembershipstrength if intimacystrength == float(5) & chattiness == float(.4) & (policy == "none" | policy == "both"), by (policy)

* dropouts:
** 0
ttest dropouts if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "onboard"), by (policy)
ttest dropouts if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "engage"), by (policy)
ttest dropouts if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "both"), by (policy)
** 1
ttest dropouts if intimacystrength == float(11) & chattiness == float(.15) & (policy == "none" | policy == "onboard"), by (policy)
ttest dropouts if intimacystrength == float(11) & chattiness == float(.15) & (policy == "none" | policy == "engage"), by (policy)
ttest dropouts if intimacystrength == float(11) & chattiness == float(.15) & (policy == "none" | policy == "both"), by (policy)
** 2 
ttest dropouts if intimacystrength == float(11) & chattiness == float(.4) & (policy == "none" | policy == "onboard"), by (policy)
ttest dropouts if intimacystrength == float(11) & chattiness == float(.4) & (policy == "none" | policy == "engage"), by (policy)
ttest dropouts if intimacystrength == float(11) & chattiness == float(.4) & (policy == "none" | policy == "both"), by (policy)
** 3 
ttest dropouts if intimacystrength == float(1) & chattiness == float(.1) & (policy == "none" | policy == "onboard"), by (policy)
ttest dropouts if intimacystrength == float(1) & chattiness == float(.1) & (policy == "none" | policy == "engage"), by (policy)
ttest dropouts if intimacystrength == float(1) & chattiness == float(.1) & (policy == "none" | policy == "both"), by (policy)
** 4 
ttest dropouts if intimacystrength == float(1) & chattiness == float(.15) & (policy == "none" | policy == "onboard"), by (policy)
ttest dropouts if intimacystrength == float(1) & chattiness == float(.15) & (policy == "none" | policy == "engage"), by (policy)
ttest dropouts if intimacystrength == float(1) & chattiness == float(.15) & (policy == "none" | policy == "both"), by (policy)
** 5
ttest dropouts if intimacystrength == float(1) & chattiness == float(.4) & (policy == "none" | policy == "onboard"), by (policy)
ttest dropouts if intimacystrength == float(1) & chattiness == float(.4) & (policy == "none" | policy == "engage"), by (policy)
ttest dropouts if intimacystrength == float(1) & chattiness == float(.4) & (policy == "none" | policy == "both"), by (policy)
** 6
ttest dropouts if intimacystrength == float(5) & chattiness == float(.1) & (policy == "none" | policy == "onboard"), by (policy)
ttest dropouts if intimacystrength == float(5) & chattiness == float(.1) & (policy == "none" | policy == "engage"), by (policy)
ttest dropouts if intimacystrength == float(5) & chattiness == float(.1) & (policy == "none" | policy == "both"), by (policy)
** 7
ttest dropouts if intimacystrength == float(5) & chattiness == float(.15) & (policy == "none" | policy == "onboard"), by (policy)
ttest dropouts if intimacystrength == float(5) & chattiness == float(.15) & (policy == "none" | policy == "engage"), by (policy)
ttest dropouts if intimacystrength == float(5) & chattiness == float(.15) & (policy == "none" | policy == "both"), by (policy)
** 8
ttest dropouts if intimacystrength == float(5) & chattiness == float(.4) & (policy == "none" | policy == "onboard"), by (policy)
ttest dropouts if intimacystrength == float(5) & chattiness == float(.4) & (policy == "none" | policy == "engage"), by (policy)
ttest dropouts if intimacystrength == float(5) & chattiness == float(.4) & (policy == "none" | policy == "both"), by (policy)

* mycommentsofturtle0
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "onboard"), by (policy)
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "engage"), by (policy)
ttest totalcomments if intimacystrength == float(11) & chattiness == float(.1) & (policy == "none" | policy == "both"), by (policy)


* plot some stuff
scatter totalcomments mycommentsofturtle0, msize tiny 
