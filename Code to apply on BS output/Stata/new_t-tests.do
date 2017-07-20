use "/Users/albertocottica/github/local/community-management-simulator/Data/data-w-gini-v4-all.dta"

* divide obs in blocks of 24 obs each. All parameters have within-block identical values.
ge qqq = int(autocode (runnumber, 72, 1, 1728))

* compute in-block mean (inblockmean) and standard error (inblockse)
egen ms_inblockmean = mean(ms_gini), by (qqq)
egen ms_inblockse = mean(ms_se_gini^2), by (qqq)
replace ms_inblockse = sqrt(ms_inblockse)

* compute T and bilateral p-value
ge ms_tstat = ms_inblockmean/ms_inblockse
ge ms_pval = 1 - normal(abs(ms_tstat))
