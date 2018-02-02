# Computes the t-statistics on Gini. Not very elegant, but faster.

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

def tstats_gini_by_policy(dataset):
    '''
    (list of dicts) => list of dicts
    Accepts the output of readFile as an input. Computes t-statistics by policy, for each value of the parameter vector
    found in dataset.
    Returns a synthetic table.
    '''
    # the output table! 
    resultTable = []
    chattiness_values = [".1", ".2", ".4"]
    intimacy_values = ["1", "5", "11"]
    policies = ['engage', 'both']
    priorities = ['newer', 'more active']
    randomisedchattiness =['true', 'false']
    listOfTests = []
    nc_neg_significant = 0
    nc_pos_significant = 0
    ms_neg_significant = 0
    ms_pos_significant = 0
    for c in chattiness_values:
        for i in intimacy_values:
            for rand in randomisedchattiness:
                for pri in priorities:
                    row = {} # the row of the output table
                    to_compare = []
                    checkpoint = 0
                    for ob in dataset:
                        if (ob['globalchattiness'] == c and ob['intimacystrength'] == i and ob['randomisedchattiness'] == rand and 
                            ob['priority'] == pri and ob['nc_inblockmean'] != checkpoint):
                            # I do not have this particular unique value of nc_inblockmean, so I append the ob and replace the value
                            to_compare.append(ob)
                            checkpoint = ob['nc_inblockmean']
                            # print checkpoint
                    # print 'Global chattiness = ' + c
                    # print 'Intimacystrength = ' + i
                    # print 'Randomised chattiness = ' + rand
                    # print 'Priority = ' + pri
                    # now the T-stats proper.
                    # print 'T-stat of H0: nc(' + to_compare[0]['policy'] + ' vs. ' + to_compare[1]['policy'] + ')'
                    nc_tstat = tstat(float(to_compare[0]['nc_inblockmean']), float(to_compare[1]['nc_inblockmean']), 
                        float(to_compare[0]['nc_inblockse']), float(to_compare[1]['nc_inblockse']), 46) 
                    if nc_tstat > 2:
                        nc_pos_significant += 1
                    elif nc_tstat < -2:
                        nc_neg_significant += 1                            
                    # print nc_tstat
                    # print 'T-stat of H0: ms(' + to_compare[0]['policy'] + ' vs. ' + to_compare[1]['policy'] + ')'
                    ms_tstat = tstat(float(to_compare[0]['ms_inblockmean']), float(to_compare[1]['ms_inblockmean']), 
                        float(to_compare[0]['ms_inblockse']), float(to_compare[1]['ms_inblockse']), 46) 
                    if ms_tstat > 2:
                        ms_pos_significant += 1
                    elif ms_tstat < -2:
                        ms_neg_significant += 1

                    # print ms_tstat
                    # print '\n'
                    # add the record to the output table
                    # parameters
                    row['globalchattiness'] = c
                    row['intimacystrength'] = i
                    row['randomisedchattiness'] = rand
                    row['priority'] = pri
                    row['ms_t_engage_vs_both'] = ms_tstat
                    row['nc_t_engage_vs_both'] = nc_tstat
                    resultTable.append(row)
                    
    print 'Policies: engage vs. both'
    print 'nc, positive and significant: ' + str (nc_pos_significant)
    print 'nc, negative and significant: ' + str (nc_neg_significant)
    print 'nc, nonsignificant:' + str (36 - nc_pos_significant - nc_neg_significant)
    print 'ms, positive and significant: ' + str (ms_pos_significant)
    print 'ms, negative and significant: ' + str (ms_neg_significant)
    print 'ms, nonsignificant:' + str (36 - ms_pos_significant - ms_neg_significant)
    
    return resultTable
                    
def tstats_gini_by_priority(dataset, resultTable):
    '''
    (list of dicts, list of dicts) => list of dicts
    Accepts the output of readFile as an input. Computes t-statistics by priority, for each value of the parameter vector
    found in dataset.
    The computed values are added to outputTable.
    '''
    chattiness_values = [".1", ".2", ".4"]
    intimacy_values = ["1", "5", "11"]
    policies = ['engage', 'both']
    priorities = ['newer', 'more active']
    randomisedchattiness =['true', 'false']
    listOfTests = []
    nc_neg_significant = 0
    nc_pos_significant = 0
    ms_neg_significant = 0
    ms_pos_significant = 0
    for c in chattiness_values:
        for i in intimacy_values:
            for rand in randomisedchattiness:
                for p in policies:
                    row = {}
                    to_compare = []
                    checkpoint = 0
                    for ob in dataset:
                        if (ob['globalchattiness'] == c and ob['intimacystrength'] == i and ob['randomisedchattiness'] == rand and 
                            ob['policy'] == p and ob['nc_inblockmean'] != checkpoint):
                            # I do not have this particular unique value of nc_inblockmean, so I append the ob and replace the value
                            to_compare.append(ob)
                            checkpoint = ob['nc_inblockmean']
                            # print checkpoint
                    # print 'Global chattiness = ' + c
                    # print 'Intimacystrength = ' + i
                    # print 'Randomised chattiness = ' + rand
                    # print 'Policy = ' + p
                    # now the T-stats proper.
                    # print 'T-stat of H0: nc(' + to_compare[0]['priority'] + ' vs. ' + to_compare[1]['priority'] + ')'
                    nc_tstat = tstat(float(to_compare[0]['nc_inblockmean']), float(to_compare[1]['nc_inblockmean']), 
                        float(to_compare[0]['nc_inblockse']), float(to_compare[1]['nc_inblockse']), 46) 
                    if nc_tstat > 2:
                        nc_pos_significant += 1
                    elif nc_tstat < -2:
                        nc_neg_significant += 1                            
                    # print nc_tstat
                    # print 'T-stat of H0: ms(' + to_compare[0]['priority'] + ' vs. ' + to_compare[1]['priority'] + ')'
                    ms_tstat = tstat(float(to_compare[0]['ms_inblockmean']), float(to_compare[1]['ms_inblockmean']), 
                        float(to_compare[0]['ms_inblockse']), float(to_compare[1]['ms_inblockse']), 46) 
                    if ms_tstat > 2:
                        ms_pos_significant += 1
                    elif ms_tstat < -2:
                        ms_neg_significant += 1
                    #print ms_tstat
                    # print '\n'
                    # add the record to the output table
                    # parameters
                    row['globalchattiness'] = c
                    row['intimacystrength'] = i
                    row['randomisedchattiness'] = rand
                    row['policy'] = p
                    row['ms_t_more_active_vs_newer'] = ms_tstat
                    row['nc_t_more_active_vs_newer'] = nc_tstat
                    resultTable.append(row) # I do not initiatilise a resultTable, I append to the one passed as an ergument to the function
                    
    print 'Priorities: more active vs. newer'
    print 'nc, positive and significant: ' + str (nc_pos_significant)
    print 'nc, negative and significant: ' + str (nc_neg_significant)
    print 'nc, nonsignificant:' + str (36 - nc_pos_significant - nc_neg_significant)
    print 'ms, positive and significant: ' + str (ms_pos_significant)
    print 'ms, negative and significant: ' + str (ms_neg_significant)
    print 'ms, nonsignificant:' + str (36 - ms_pos_significant - ms_neg_significant)
    return resultTable
    
def tstats_others_by_policy(dataset, resultTable):
    '''
    (list of dicts, list of dicts) => list of dicts
    Accepts the output of readFile as an input. Computes t-statistics by priority, for each value of the parameter vector
    found in dataset.
    The computed values are added to outputTable.
    '''
    chattiness_values = [".1", ".2", ".4"]
    intimacy_values = ["1", "5", "11"]
    policies = ['engage', 'both']
    priorities = ['newer', 'more active']
    randomisedchattiness =['true', 'false']
    targets = ['mgmteffort', 'dropouts', 'totalmembershipstrength', 'totalcomments']
    listOfTests = []
    for c in chattiness_values:
        for i in intimacy_values:
            for rand in randomisedchattiness:
                for pri in priorities:
                    row = {}
                    for target in targets:
                        array_engage = [] # values when policy == engage
                        array_both = [] # values when policy == both
                        for ob in dataset:
                            if (ob['globalchattiness'] == c and ob['intimacystrength'] == i and ob['randomisedchattiness'] == rand and 
                                ob['priority'] == pri and ob['policy'] == 'engage'):
                                # store the value of target contained in ob into the first array
                                array_engage.append(float(ob[target]))
                            elif (ob['globalchattiness'] == c and ob['intimacystrength'] == i and ob['randomisedchattiness'] == rand and 
                                ob['priority'] == pri and ob['policy'] == 'both'):
                                # store the value of target contained in ob into the second array
                                array_both.append(float(ob[target]))
                                tstat = numpy.asscalar(stats.ttest_ind(array_both, array_engage, equal_var = False)[0])
                                # tstat = float(stats.ttest_ind(array_engage, array_both, equal_var = False)[0]) 
                                # add the value to the result table is a pain, because I need to iterate and dig out the right row.
                                for result in resultTable:
                                    if result['globalchattiness'] == c and result['intimacystrength'] == i and result['randomisedchattiness'] == rand and result['priority'] == pri:
                                        # no condition for policy! 
                                        result[target + '_both_vs_engage'] = tstat
    return resultTable                        
    
def tstats_others_by_priority(dataset, resultTable):
    '''
    (list of dicts, list of dicts) => list of dicts
    Accepts the output of readFile as an input. Computes t-statistics by priority, for each value of the parameter vector
    found in dataset.
    The computed values are added to outputTable.
    '''
    chattiness_values = [".1", ".2", ".4"]
    intimacy_values = ["1", "5", "11"]
    policies = ['engage', 'both']
    priorities = ['newer', 'more active']
    randomisedchattiness =['true', 'false']
    targets = ['mgmteffort', 'dropouts', 'totalmembershipstrength', 'totalcomments']
    listOfTests = []
    for c in chattiness_values:
        for i in intimacy_values:
            for rand in randomisedchattiness:
                for p in policies:
                    row = {}
                    for target in targets:
                        array_more_active = [] # values when policy == engage
                        array_newer = [] # values when policy == both
                        for ob in dataset:
                            if (ob['globalchattiness'] == c and ob['intimacystrength'] == i and ob['randomisedchattiness'] == rand and 
                                ob['policy'] == p and ob['priority'] == 'more active'):
                                # store the value of target contained in ob into the first array
                                array_more_active.append(float(ob[target]))
                            elif (ob['globalchattiness'] == c and ob['intimacystrength'] == i and ob['randomisedchattiness'] == rand and 
                                ob['policy'] == p and ob['priority'] == 'newer'):
                                # store the value of target contained in ob into the second array
                                array_newer.append(float(ob[target]))
                            tstat = float(stats.ttest_ind(array_more_active, array_newer, equal_var = False)[0]) 
                            # add the value to the result table is a pain, because I need to iterate and dig out the right row.
                            for result in resultTable:
                                if (result['globalchattiness'] == c and result['intimacystrength'] == i and result['randomisedchattiness'] == rand and 
                                    result['policy'] == p): 
                                    # no condition for priority! 
                                    result[target + '_more_active_vs_newer'] = tstat
    return resultTable                        
    
def normalize_rows(table):
    '''
    (list of dicts) => list of dicts
    All rows of the table need to have the same fields. If not, the function adds them.
    '''
    check = [] 
    for key in table[0]:
        check.append(key)
    # first pass: store all keys of all rows into checks
    for row in table:
        for key in row:
            if key not in check:
                check.append(key)
    # second pass: add to each row all keys as needed
    for row in table:
        for key in check:
            if key not in row:
                row[key] = ''
    return table


def probe(table):
    '''
    (list of dicts) => bool
    making sure the table is well formed
    '''
    success = True
    check = len (table[0])
    for row in table:
        if len(row) != check:
            print "This table has a problem"
            quit ()
    return success
                        
def find_value(dataset):
    for ob in dataset:
        if ob['nc_inblockmean'] == '.3548942':
            print ob['runnumber']
                           
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
    dirPath = '/Users/albertocottica/github/local/community-management-simulator/Data/'
    data = readFile(dirPath + 'data-w-gini-retry_replica_merge_batches.csv')
    stage1 = tstats_gini_by_policy(data)
    stage2 = tstats_gini_by_priority(data, stage1)
    stage3 = normalize_rows(stage2)
    formed = probe(stage3)
    stage4 = tstats_others_by_policy(data, stage3)
    final = tstats_others_by_priority(data, stage4)
    print final[0]
    success = writeFile(final, dirPath + 'MOAT_stage2.csv')
    
