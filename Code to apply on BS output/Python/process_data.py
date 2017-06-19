import csv
dirPath = '/Users/albertocottica/github/local/community-management-simulator-2/Data/'

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
    
    chattiness_values = [".1", ".15", ".4"]
    intimacy_values = ["1", "5", "11"]
    policies = ['none', 'onboard', 'engage', 'both']
    
    # lots of overwriting here
    for c in chattiness_values:
        for i in intimacy_values:
            for p in policies:
                thisCase = {}
                ms_avg_gini = 0
                nc_avg_gini = 0
                ms_sumsquares_se_gini = 0 # power operator is not commutative. I need to sum the squares first, then take the square root
                nc_sumsquares_se_gini = 0
                checksum = 0 # just in case
                for ob in data:
                    if ob["chattiness"] == c and ob["intimacystrength"] == i and ob['policy'] == p:
                        checksum += 1
                        thisCase["chattiness"] = c
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
                    print ('Error with chattiness = ' + str(c) + ', intimacystrength = ' + str(i) + ', policy = ' + p)

    return results
    
def compute_t_ginis(obs):
    '''
    (list of dicts) => list of dicts
    computes the t statistic relative to the null hypothesis that gini2 == gini1
    gini1 and gini2 are average cross-run ginis.
    we have 9 cases: 3 valus for chattiness, 3 for intimacystrength
    we also have 3 policy tests for each case: "onboard", "engage" and "both"  vs. "none"
    '''
    
    results = []
    
    chattiness_values = [".1", ".15", ".4"]
    intimacy_values = ["1", "5", "11"]
    
    # lots of overwriting here
    for c in chattiness_values:
        for i in intimacy_values:
            thisCase = {}
            for ob in obs:
                if ob["chattiness"] == c and  ob["intimacystrength"] == i:
                    thisCase["chattiness"] = c
                    thisCase["intimacystrength"] = i
                    thisCase[ob["policy"] + "_ms_avg_gini"] = ob["ms_avg_gini"]
                    thisCase[ob["policy"] + "_nc_avg_gini"] = ob["nc_avg_gini"]
                    thisCase[ob["policy"] + "_ms_se_gini"] = ob["ms_xrun_se_gini"] 
                    thisCase[ob["policy"] + "_nc_se_gini"] = ob["nc_xrun_se_gini"]         
                    
            # now compute the 6 t statistics. Start by onboard vs. none
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
    the first one is representative of the run 
    the second one encodes the t-stats
    '''
    with open(dirPath + filename1, 'w') as csvfile:
        fieldnames = ['runnumber','founders','chattiness','nummembers','intimacystrength','policy','totalmembershipstrength','dropouts','totalcomments','mycommentsofturtle0','ms_gini','ms_se_gini','nc_gini','nc_se_gini', 'ms_avg_gini', 'nc_avg_gini', 'ms_xrun_se_gini','nc_xrun_se_gini' ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for run in listOfDicts1:
            writer.writerow(run)

    with open(dirPath + filename2, 'w') as csvfile:
        fieldnames = ['chattiness', 'intimacystrength', "ms_t_onboard_none",'ms_t_engage_none', 'ms_t_both_none', "nc_t_onboard_none",'nc_t_engage_none', 'nc_t_both_none']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for item in listOfDicts2:
            # the following is to get rid of the extra fields
            row = {'chattiness': item['chattiness'], 'intimacystrength': item['intimacystrength'], 'ms_t_onboard_none': item['ms_t_onboard_none'], 'ms_t_engage_none': item['ms_t_engage_none'], 'ms_t_both_none': item['ms_t_both_none'], 'nc_t_onboard_none': item['nc_t_onboard_none'], 'nc_t_engage_none': item['nc_t_engage_none'], 'nc_t_both_none': item['nc_t_both_none']}
            writer.writerow(row)
        
    

if __name__ == '__main__':
    data = readFile(dirPath + 'data-w-gini-retry.csv')
    ginis = compute_xrun_ginis(data)
    tStats = compute_t_ginis(ginis)
    print (len(tStats))
    print tStats[0]
    writeFiles(ginis, 'data_w_avg_gini_retry.csv', tStats, 'tStats.csv')
    
    
