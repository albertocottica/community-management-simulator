import csv
dirPath = '/Users/albertocottica/github/local/community-management-simulator/Data/'

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

def compute_xrun_ginis(data):
    '''
    (list of dicts) => list of dicts
    compute the cross-run ginis from data
    '''
    results = []
    
    chattiness_values = [".1", ".2", ".4"]
    intimacy_values = ["1", "5", "11"]
    policies = ['engage', 'both']
    priorities = ['newer', 'more active']
    randomisedchattiness =['true', 'false']
    
    # lots of overwriting here
    for c in chattiness_values:
        for i in intimacy_values:
            for p in policies:
                for pri in priorities:
                       for rand in randomisedchattiness:
                           thisCase ={}
                           ms_avg_gini = 0
                           nc_avg_gini = 0
                           ms_sumsquares_se_gini = 0 # power operator is not commutative. I need to sum the squares first, then take the square root
                           nc_sumsquares_se_gini = 0
                           checksum = 0 # just in case
                           for ob in data:
                               if ob["globalchattiness"] == c and ob["intimacystrength"] == i and ob['policy'] == p and pri == ob['priority'] and rand == ob['randomisedchattiness']:
                                   checksum += 1
                                   thisCase["globalchattiness"] = c
                                   thisCase["intimacystrength"] = i
                                   thisCase['policy'] = p
                                   ms_avg_gini += float(ob['ms_gini']) / 24
                                   nc_avg_gini += float(ob['nc_gini']) / 24
                                   ms_sumsquares_se_gini += float(ob['ms_se_gini']) ** 2
                                   nc_sumsquares_se_gini += float(ob['nc_se_gini']) ** 2                   
                           thisCase ['ms_avg_gini'] = ms_avg_gini
                           thisCase ['nc_avg_gini'] = nc_avg_gini                
                           thisCase['ms_xrun_se_gini'] = (ms_sumsquares_se_gini ** .5) / float(36) # compute and write the cross-runs standard errors
                           thisCase['nc_xrun_se_gini'] = (nc_sumsquares_se_gini ** .5) / float(36)
                           results.append(thisCase)
                           if checksum != 24:
                               print ('Error with globalchattiness = ' + str(c) + ', intimacystrength = ' + str(i) + ', policy = ' + p + ', priority = ' + pri + ', rand =' +rand)

    return results
    
def compute_t_ginis(obs):
    '''
    (list of dicts) => list of dicts;
    computes the t statistic relative to the null hypothesis that gini2 == gini1
    gini1 and gini2 are average cross-run ginis under certain conditions.
    we have 18 cases: 3 values for chattiness x 3 for intimacystrength x 2 for randomised chattiness)
    we also have 1 policy test ("onboard"  vs. "both") and 1 priority test ("never" vs. "more active")
    The policy test is computed for both policies and viceversa. This means having 18 x 2 x 2 = 72 tests
    returns a list of dicts containing the data. 
    '''
    
    results = []
    
    chattiness_values = [".1", ".2", ".4"]
    intimacy_values = ["1", "5", "11"]
    policies = ['engage', 'both']
    priorities = ['newer', 'more active']
    randomisedchattiness =['true', 'false']
    
    # start by computing onboard vs. both.
    # we have initially 18 cases
    for c in chattiness_values:
        for i in intimacy_values:
            for rand in randomisedchattiness:
                for pri in priorities:
                    thisCase = {}
                    for ob in obs:
                        if ob["globalchattiness"] == c and ob["intimacystrength"] == i and rob["randomisedchattiness"] == rand and ob["priority"] == pri:
                            thisCase["globalchattiness"] = c
                            thisCase["intimacystrength"] = i
                            thisCase["randomisedchattiness"] = rand
                            thisCase["priority"] = pri
            # now compute the t statistic. Start by onboard vs. none
            ms_x2 = float(thisCase["none_ms_avg_gini"])
            ms_s2 = float(thisCase["none_ms_se_gini"])
            ms_x1 = float(thisCase["onboard_ms_avg_gini"])
            ms_s1 = float(thisCase["onboard_ms_se_gini"])
            ms_t = (ms_x1 - ms_x2) / (((ms_s1 ** 2 + ms_s2 ** 2) /24) ** (0.5))
            thisCase["ms_t_onboard_none"] = ms_t
            
            nc_x2 = float(thisCase["none_nc_avg_gini"])
            nc_s2 = float(thisCase["none_nc_se_gini"])
            nc_x1 = float(thisCase["onboard_nc_avg_gini"])
            nc_s1 = float(thisCase["onboard_nc_se_gini"])
            nc_t = (nc_x1 - nc_x2) / (((nc_s1 ** 2  + nc_s2 ** 2) /24) ** (0.5))
            thisCase["nc_t_onboard_none"] = nc_t
                    
            # engage vs. none 
            ms_x1 = float(thisCase["engage_ms_avg_gini"])
            ms_s1 = float(thisCase["engage_ms_se_gini"])
            ms_t = (ms_x1 - ms_x2) / (((ms_s1 ** 2 + ms_s2 ** 2) /24) ** (0.5))
            thisCase["ms_t_engage_none"] = ms_t
            
            nc_x1 = float(thisCase["engage_nc_avg_gini"])
            nc_s1 = float(thisCase["engage_nc_se_gini"])
            nc_t = (nc_x1 - nc_x2) / (((nc_s1 ** 2 + nc_s2 ** 2) /24) ** (0.5))
            thisCase["nc_t_engage_none"] = nc_t

            # both vs. none
            ms_x1 = float(thisCase["both_ms_avg_gini"])
            ms_s1 = float(thisCase["both_ms_se_gini"])
            ms_t = float((ms_x1 - ms_x2) / (((ms_s1 ** 2 + ms_s2 ** 2) /24)) ** (0.5))
            thisCase["ms_t_both_none"] = ms_t
            
            nc_x1 = float(thisCase["both_nc_avg_gini"])
            nc_s1 = float(thisCase["both_nc_se_gini"])
            nc_t = (nc_x1 - nc_x2) / (((nc_s1 ** 2 + nc_s2 ** 2) /24) ** (0.5))
            thisCase["nc_t_both_none"] = nc_t
            
            results.append(thisCase)
    return results

def writeFiles(listOfDicts1,filename1,listOfDicts2,filename2):
    '''
    (str, str) => noneType
    write the file to csv
    the first one is representative of the runs 
    the second one encodes the t-stats
    '''
    fieldnames = []
    for key in listOfDicts1[0]:
        fieldnames.append(key)
    with open(dirPath + filename1, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for run in listOfDicts1:
            writer.writerow(run)

    fieldnames = []
    for key in listOfDicts2[0]:
        fieldnames.append(key)
            
    with open(dirPath + filename2, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for item in listOfDicts2:
            # # the following is to get rid of the extra fields
            # row = {'chattiness': item['chattiness'], 'intimacystrength': item['intimacystrength'], 'ms_t_onboard_none': item['ms_t_onboard_none'], 'ms_t_engage_none': item['ms_t_engage_none'], 'ms_t_both_none': item['ms_t_both_none'], 'nc_t_onboard_none': item['nc_t_onboard_none'], 'nc_t_engage_none': item['nc_t_engage_none'], 'nc_t_both_none': item['nc_t_both_none']}
            writer.writerow(row)
        
    

if __name__ == '__main__':
    data = readFile(dirPath + 'data-w-gini-retry_replica_merge_batches.csv')
    ginis = compute_xrun_ginis(data)
    print ginis[0]
    # tStats = compute_t_ginis(ginis)
    # print (len(tStats))
    # print tStats[0]
    # writeFiles(ginis, 'data_w_avg_gini_replica.csv', tStats, 'replica_tStats.csv')
    #
    #
