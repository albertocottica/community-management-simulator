# runs t-tests over the null hypothesis 
# avg_gini if (priority == "newer") == avg_gini if (priority == "more active")

import csv
import numpy as np
from scipy.stats import ttest_ind
from scipy.special import stdtr



def readCsvFile(fileName):
    '''
    (string) => list of dicts
    Read the file called fileName and put its content in computer memory
    '''
    allData = [] # data go here as list of dicts
    with open(fileName) as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            allData.append(row)
    return allData
    
def computeTtests (data):
    '''
    (list of dicts) => list of dicts
    Execute t-tests on data. Return results in an easy-to-read form, i.e.:
    [
        {
            'globalchattiness': value, 'intimacystrength': value, 'randomisedchattiness': value, 'policy': value,
            'dropouts': value, 'totalmembershipstrength': value, 'totalcomments': value, 'managementeffort':value',
            'ms_gini': value, 'nc_gini': value
        },
        ...
    ]
    '''
    
    results = [] 
    
    # assign the parameter space in which we operate
    for globChat in [.1, .2, .4]:
        for intStren in [1, 5, 11]:
            for randChat in ["true", "false"]:
                for pol in ["engage", "both"]:
                    # keep track of parameters' values
                    result ={}
                    result['globalchattiness'] = globChat
                    result['intimacystrength'] = intStren
                    result['randomisedchattiness'] = randChat
                    result['policy'] = pol
                    
                    # take care of non-Gini variables first
                    for nonGiniVar in ['dropouts', 'totalmembershipstrength', 'totalcomments', 'mgmteffort']:
                        # accumulate in two lists the values, separated by priority
                        moreActiveArray = []
                        newerArray = []
                        
                        # read the data.                     
                        for row in data:
                            
                            if ( float(row['globalchattiness']) == globChat and 
                            int(row['intimacystrength']) == intStren and 
                            row['randomisedchattiness'] == randChat and 
                            row['policy'] == pol):    
                                if row['priority'] == 'newer':
                                    newerArray.append(float(row[nonGiniVar]))
                                elif row['priority'] == 'more active':
                                    moreActiveArray.append(float(row[nonGiniVar]))
                        
                        # save the means relative to the moreActive and newer cases
                        result[nonGiniVar + '_n_mean'] = float(sum(newerArray))/len(newerArray)
                        result[nonGiniVar + '_ma_mean'] = float(sum(moreActiveArray))/len(moreActiveArray)
                                
                        # compute the t-tests. When T is positive, moreActive > newer 
                        thisTest = ttest_ind(moreActiveArray, newerArray, equal_var = 'False') 
                        result[nonGiniVar + '_t'] = float(thisTest[0])
                        result[nonGiniVar + '_pVal'] = float(thisTest[1])
                    
                    # now the two Ginis
                    for giniVar in ['ms', 'nc']:
                        
                        # no need for lists, I have already calculated means and SEs
                       # read the data.                     
                        for row in data:
                            
                            if ( float(row['globalchattiness']) == globChat and 
                            int(row['intimacystrength']) == intStren and 
                            row['randomisedchattiness'] == randChat and 
                            row['policy'] == pol):    
                                if row['priority'] == 'newer':
                                    newerMean = float(row[giniVar + '_avg_gini'])
                                    newerSE = float(row[giniVar + '_inblockse'])
                                elif row['priority'] == 'more active':
                                    moreActiveMean = float(row[giniVar + '_avg_gini'])
                                    moreActiveSE = float(row[giniVar + '_inblockse'])
                        
                        # save mean values 
                        
                        result[giniVar + '_gini_n_mean'] = newerMean
                        result[giniVar + '_gini_ma_mean'] = moreActiveMean
                        
                        # compute the t-tests. When T is positive, moreActive > newer
                        tStat = (moreActiveMean - newerMean) / np.sqrt((moreActiveSE**2 + newerSE**2)/24) 
                        result[giniVar + '_gini_t'] = tStat
                        dof = (moreActiveSE/24 + newerSE/24)**2 / (moreActiveSE**2/(24**2*23) + newerSE**2/(24**2*23))
                        result[giniVar + '_gini_pVal'] = 2*stdtr(dof, -np.abs(tStat))
                    
                    results.append(result)
                        
    return results
    
def saveCsvFile(data, filename):
    '''
    (list of dicts. str) => NoneType
    saves list of dicts into a CSV file called filename
    '''
    # get the fieldnames from the data:
    with open (filename, 'w') as csvfile:
        fieldnames = sorted(data[0].keys())
        writer = csv.DictWriter(csvfile, fieldnames = fieldnames)
        writer.writeheader()
        for row in data:
            writer.writerow(row)
    
def findTrends(data):
    '''
    (list of dicts) => NoneType
    prints some info to screen
    '''
    moreActiveMoreInclusivity1 = 0
    moreActiveMoreInclusivity2 = 0
    moreActiveMoreActivity = 0
    moreActiveMoreDiversity = 0
    moreActiveMoreLoyalty = 0
    for row in data:
        if row['dropouts_t'] < 0 and row['dropouts_pVal'] < .01:
            moreActiveMoreInclusivity1 += 1
        if row['ms_gini_t'] < 0 and row['ms_gini_pVal'] < .01:
            moreActiveMoreInclusivity2 += 1
        if row['totalcomments_t'] > 0 and row['totalcomments_pVal'] < .01:
            moreActiveMoreActivity += 1
        if row['nc_gini_t'] < 0 and row['nc_gini_pVal'] < 0.1:
            moreActiveMoreDiversity += 1 
        if row['totalmembershipstrength_t'] > 0 and row['totalmembershipstrength_pVal'] < .01:
            moreActiveMoreLoyalty += 1   
            
    print 'Priority "more active" has FEWER dropouts: ' + str(moreActiveMoreInclusivity1)
    print 'Priority "more active" has MORE inclusivity (lower Gini on ms): ' + str(moreActiveMoreInclusivity2)
    print 'Priority "more active" has MORE comments: ' + str(moreActiveMoreActivity)
    print 'Priority "more active" has MORE diversity (lower gini on nc): ' + str(moreActiveMoreDiversity)
    print 'Priority "more active" has MORE loyalty (higher total membership strength): ' + str(moreActiveMoreLoyalty)

    newerMoreInclusivity1 = 0
    newerMoreInclusivity2 = 0
    newerMoreActivity = 0
    newerMoreDiversity = 0
    newerMoreLoyalty = 0
    for row in data:
        if row['dropouts_t'] > 0 and row['dropouts_pVal'] < .01:
            newerMoreInclusivity1 += 1
        if row['ms_gini_t'] > 0 and row['ms_gini_pVal'] < .01:
            newerMoreInclusivity2 += 1
        if row['totalcomments_t'] < 0 and row['totalcomments_pVal'] < .01:
            newerMoreActivity += 1
        if row['nc_gini_t'] > 0 and row['nc_gini_pVal'] < 0.1:
            newerMoreDiversity += 1 
        if row['totalmembershipstrength_t'] < 0 and row['totalmembershipstrength_pVal'] < .01:
            newerMoreLoyalty += 1   
            
    print 'Priority "newer" has FEWER dropouts: ' + str(newerMoreInclusivity1)
    print 'Priority "newer" has MORE inclusivity (lower Gini on ms): ' + str(newerMoreInclusivity2)
    print 'Priority "newer" has MORE comments: ' + str(newerMoreActivity)
    print 'Priority "newer" has MORE diversity (lower gini on nc): ' + str(newerMoreDiversity)
    print 'Priority "newer" has MORE loyalty (higher total membership strength): ' + str(newerMoreLoyalty)
    
    
if __name__ == '__main__':
    dirPath = '/Users/albertocottica/github/local/community-management-simulator/Data/'
    allData = readCsvFile(dirPath + 'ready-4-tTest.csv')
    results = computeTtests(allData)
    saveCsvFile(results, dirPath + 'tTestsResults.csv')
    findTrends(results)
    