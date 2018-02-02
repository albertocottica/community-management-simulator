# Starts from data-w-gini-retry_replica_merge_batches.csv, to which I added cross-run Gini means and SEs
# Goal: add t-statistcs, so that I can do all the relevant charting from Stata.

import csv
import math

def tstat(x1, x2, s1, s2, n):
    '''
    (float, float, float, float, int) => float
    Computes the t-statistic for two datasets.
    '''
    t = (x1 - x2) / math.sqrt((s1**2 +s2**2)/n)
    return t


def readFile(filename):
    '''
    (str) => list of dicts
    loads file filename into a list. Each item is a dict encoding one run in the model.
    '''
    with open (filename, 'r') as csvFile:
        csvReader = csv.DictReader (csvFile, delimiter = ',', quotechar = '"')
        runs = []
        for row in csvReader:
            runs.append(row)
        return runs
        
def add_tstats(data):
    '''
    (list of dicts) => list of dicts
    computes the t-stastics on the two Ginis. There are two: policy 1 vs. policy 2 and priority 1 vs. priority 2.
    All other variables fixed.
    '''
    # policies first
    chattiness_values = [".1", ".2", ".4"]
    intimacy_values = ["1", "5", "11"]
    policies = ['engage', 'both']
    priorities = ['newer', 'more active']
    randomisedchattiness =['true', 'false']
    for c in chattiness_values:
        for i in intimacy_values:
            for rand in randomisedchattiness:
                for pri in priorities:
                        for ob in data:
                            if ob['globalchattiness'] == c and ob['intimacystrength'] == i and ob['randomisedchattiness'] == rand and ob['priority'] == pri and ob['policy'] == 'engage':
                                ms_x_engage = float(ob['ms_inblockmean'])
                                ms_s_engage = float(ob['ms_inblockse'])
                                nc_x_engage = float(ob['nc_inblockmean'])
                                nc_s_engage = float(ob['nc_inblockse'])
                            elif ob['policy'] == 'both':
                                ms_x_both = float(ob['ms_inblockmean'])
                                ms_s_both = float(ob['ms_inblockse'])
                                nc_x_both = float(ob['nc_inblockmean'])
                                nc_s_both = float(ob['nc_inblockse'])
                        tstat_ms_engage_vs_both = tstat(ms_x_engage, ms_x_both, ms_s_engage, ms_s_both, 24)
                        tstat_nc_engage_vs_both = tstat(nc_x_engage, nc_x_both, nc_s_engage, nc_s_both, 24)
                        for ob in data:
                            # pass again on the data and replace the stats in the observation withj the same parameter vector 
                            # policy now is indifferent!
                            if ob['globalchattiness'] == c and ob['intimacystrength'] == i and ob['randomisedchattiness'] == rand and ob['priority'] == pri:
                                ob['tstat_ms_engage_vs_both'] = tstat_ms_engage_vs_both
                                ob['tstat_nc_engage_vs_both'] = tstat_nc_engage_vs_both
                                
    # now priorities
    for c in chattiness_values:
        for i in intimacy_values:
            for rand in randomisedchattiness:
                for p in policies:
                        for ob in data:
                            if ob['globalchattiness'] == c and ob['intimacystrength'] == i and ob['randomisedchattiness'] == rand and ob['policy'] == p and ob['priority'] == 'newer':
                                ms_x_newer = float(ob['ms_inblockmean'])
                                ms_s_newer = float(ob['ms_inblockse'])
                                nc_x_newer = float(ob['nc_inblockmean'])
                                nc_s_newer = float(ob['nc_inblockse'])
                            elif ob['priority'] == 'more active':
                                ms_x_more_active = float(ob['ms_inblockmean'])
                                ms_s_more_active = float(ob['ms_inblockse'])
                                nc_x_more_active = float(ob['nc_inblockmean'])
                                nc_s_more_active = float(ob['nc_inblockse'])
                        tstat_ms_newer_vs_more_active = tstat(ms_x_newer, ms_x_more_active, ms_s_newer, ms_s_more_active, 24)
                        tstat_nc_newer_vs_more_active = tstat(nc_x_newer, nc_x_more_active, nc_s_newer, nc_s_more_active, 24)
                        for ob in data:
                            # pass again on the data and replace the stats in the observation withj the same parameter vector 
                            # priority now is indifferent!
                            if ob['globalchattiness'] == c and ob['intimacystrength'] == i and ob['randomisedchattiness'] == rand and ob['policy'] == p:
                                ob['tstat_ms_newer_vs_more_active'] = tstat_ms_newer_vs_more_active
                                ob['tstat_nc_newer_vs_more_active'] = tstat_nc_newer_vs_more_active
        return (data)


def writeFile(listOfDicts, filename):
    '''
    (listOfDicts, str) => noneType
    write the file to csv
    '''
    fieldnames = []
    for key in listOfDicts[0]:
        fieldnames.append(key)
    with open(filename, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for run in listOfDicts:
            writer.writerow(run)



if __name__ == '__main__':
    dirPath = '/Users/albertocottica/github/local/community-management-simulator/Data/Experiment_1/'
    data = readFile(dirPath + 'data-w-gini-experiment-1.csv')
    data_with_t = add_tstats(data)
    success = writeFile(data_with_t, dirPath + 'data-w-gini-retry_replica_merge_batches_t_stats.csv')

