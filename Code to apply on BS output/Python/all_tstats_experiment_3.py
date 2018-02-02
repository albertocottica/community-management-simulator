# Computes the t-statistics on the whole experiment 1 dataset 

import math
import csv
from scipy import stats
import numpy

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

def tstats_gini_by_is(dataset):
    '''
    (list of dicts) => list of dicts
    Accepts the output of readFile as an input. Computes t-statistics by priority, for each value of the parameter vector
    found in dataset.
    Returns a synthetic table.
    '''
    # the output table! 
    resultTable = []
    chattiness_values = [".05", ".4"]
    intimacy_values = ["low", "mid", "high"]
    for rand in ['false', 'true']:
        for c in chattiness_values:
            for iv in intimacy_values:
                row = {} # the row of the output table
                # counternewer = 0
                # counterma = 0
                for ob in dataset:
                    if ob['randomisedchattiness'] == rand and ob['globalchattiness'] == c and ob['is'] == iv and ob['priority'] == 'newer':
                        # counternewer += 1
                        ms_mean_newer = float(ob['ms_inblockmean'])
                        ms_se_newer = float(ob['ms_inblockse'])
                        nc_mean_newer = float(ob['nc_inblockmean'])
                        nc_se_newer = float(ob['nc_inblockse'])
                    elif ob['randomisedchattiness'] == rand and ob['globalchattiness'] == c and ob['is'] == iv and ob['priority'] == 'more active':
                        # counterma += 1
                        ms_mean_more_active = float(ob['ms_inblockmean'])
                        ms_se_more_active = float(ob['ms_inblockse'])
                        nc_mean_more_active = float(ob['nc_inblockmean'])
                        nc_se_more_active = float(ob['nc_inblockse'])
                ms_tstat_newer_vs_more_active = tstat(ms_mean_newer, ms_mean_more_active, ms_se_newer, ms_se_more_active, 24)
                nc_tstat_newer_vs_more_active = tstat(nc_mean_newer, nc_mean_more_active, nc_se_newer, nc_se_more_active, 24)
                # add the record to the output table
                # parameters
                row['globalchattiness'] = c
                row['intimacystrength'] = iv
                row ['randomisedchattiness'] = rand
                row['ms_t_newer_vs_more_active'] = ms_tstat_newer_vs_more_active
                row['nc_t_newer_vs_more_active'] = nc_tstat_newer_vs_more_active
                resultTable.append(row)
                        
    return resultTable
                    
def tstats_others_by_is(dataset, resultTable):
    '''
    (list of dicts, list of dicts) => list of dicts
    Accepts the output of readFile as an input. Computes t-statistics by priority, for each value of the parameter vector
    found in dataset.
    The computed values are added to outputTable.
    '''
    chattiness_values = [".05", ".4"]
    intimacy_values = ["low", "mid", "high"]
    targets = ['dropouts', 'totalcomments', 'mgmteffort', 'totalmembershipstrength']
    for rand in ['false', 'true']:
        for c in chattiness_values:
            for i in intimacy_values:
                row = {}
                for target in targets:
                    array_more_active = [] # values when policy == 'none'
                    array_newer = [] # values when policy == 'engage'
                    for ob in dataset:
                        if ob['randomisedchattiness'] == rand and ob['globalchattiness'] == c and ob['is'] == i and ob['priority'] == 'newer':
                            # store the value of target contained in ob into the first array
                            array_newer.append(float(ob[target]))
                        elif ob['randomisedchattiness'] == rand and ob['globalchattiness'] == c and ob['is'] == i and ob['priority'] == 'more active':
                            # store the value of target contained in ob into the second array
                            array_more_active.append(float(ob[target]))
                        tstat_newer_vs_more_active = numpy.asscalar(stats.ttest_ind(array_newer, array_more_active, equal_var = False)[0])
                        # tstat = float(stats.ttest_ind(array_engage, array_both, equal_var = False)[0]) 
                        # add the value to the result table is a pain, because I need to iterate and dig out the right row.
                        for result in resultTable:
                            if result['randomisedchattiness'] == rand and result['globalchattiness'] == c and result['intimacystrength'] == i:
                                # no condition for policy! 
                                result[target + '_newer_vs_more_active'] = tstat_newer_vs_more_active                               
    return resultTable                        
    
def check(dataset):
    c = 0
    for ob in dataset:
        if ob['globalchattiness'] == '.05' and ob['is'] == 'low' and ob['policy'] == 'none':
            c += 1
    return c
                               
def writeFile(listOfDicts, filename):
    '''
    (listOfDicts, str) => noneType
    write the file to csv
    '''
    fieldnames = []
    for key in listOfDicts[0]:
        fieldnames.append(key)
    for key in listOfDicts[-1]:
        if key not in fieldnames:
            fieldnames.append(key)
    with open(filename, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for run in listOfDicts:
            writer.writerow(run)
    

if __name__ == '__main__':
    dirPath = '/Users/albertocottica/github/local/community-management-simulator/Data/Experiment_3/'
    data = readFile(dirPath + 'data-w-gini-experiment-3.csv')
    stage1 = tstats_gini_by_is(data)
    stage2 = tstats_others_by_is(data, stage1)
    print stage2[0]
    print len(stage2)
    success = writeFile(stage2, dirPath + 'results_experiment_3.csv')
    
