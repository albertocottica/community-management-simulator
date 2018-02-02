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
    Accepts the output of readFile as an input. Computes t-statistics by policy, for each value of the parameter vector
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
                counternone = 0
                counterengage = 0
                for ob in dataset:
                    if ob['randomisedchattiness'] == rand and ob['globalchattiness'] == c and ob['is'] == iv and ob['policy'] == 'none':
                        counternone += 1
                        ms_mean_none = float(ob['ms_inblockmean'])
                        ms_se_none = float(ob['ms_inblockse'])
                        nc_mean_none = float(ob['nc_inblockmean'])
                        nc_se_none = float(ob['nc_inblockse'])
                    elif ob['randomisedchattiness'] == rand and ob['globalchattiness'] == c and ob['is'] == iv and ob['policy'] == 'engage':
                        counterengage += 1
                        ms_mean_engage = float(ob['ms_inblockmean'])
                        ms_se_engage = float(ob['ms_inblockse'])
                        nc_mean_engage = float(ob['nc_inblockmean'])
                        nc_se_engage = float(ob['nc_inblockse'])
                ms_tstat_engage_vs_none = tstat(ms_mean_engage, ms_mean_none, ms_se_engage, ms_se_none, 24)
                nc_tstat_engage_vs_none = tstat(nc_mean_engage, nc_mean_none, nc_se_engage, nc_se_none, 24)
                # add the record to the output table
                # parameters
                row['globalchattiness'] = c
                row['intimacystrength'] = iv
                row ['randomisedchattiness'] = rand
                row['ms_t_engage_vs_none'] = ms_tstat_engage_vs_none
                row['nc_t_engage_vs_none'] = nc_tstat_engage_vs_none
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
    listOfTests = []
    for rand in ['false', 'true']:
        for c in chattiness_values:
            for i in intimacy_values:
                row = {}
                for target in targets:
                    array_none = [] # values when policy == 'none'
                    array_engage = [] # values when policy == 'engage'
                    for ob in dataset:
                        if ob['randomisedchattiness'] == rand and ob['globalchattiness'] == c and ob['is'] == i and ob['policy'] == 'none':
                            # store the value of target contained in ob into the first array
                            array_none.append(float(ob[target]))
                        elif ob['randomisedchattiness'] == rand and ob['globalchattiness'] == c and ob['is'] == i and ob['policy'] == 'engage':
                            # store the value of target contained in ob into the second array
                            array_engage.append(float(ob[target]))
                        tstat_engage_vs_none = numpy.asscalar(stats.ttest_ind(array_engage, array_none, equal_var = False)[0])
                        # tstat = float(stats.ttest_ind(array_engage, array_both, equal_var = False)[0]) 
                        # add the value to the result table is a pain, because I need to iterate and dig out the right row.
                        for result in resultTable:
                            if result['globalchattiness'] == c and result['intimacystrength'] == i:
                                # no condition for policy! 
                                result[target + '_engage_vs_none'] = tstat_engage_vs_none                               
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
    dirPath = '/Users/albertocottica/github/local/community-management-simulator/Data/Experiment_2/'
    data = readFile(dirPath + 'data-w-gini-experiment-2_2.csv')
    stage1 = tstats_gini_by_is(data)
    stage2 = tstats_others_by_is(data, stage1)
    success = writeFile(stage2, dirPath + 'results_experiment_2_2.csv')
    
