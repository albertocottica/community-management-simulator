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

def compute_t_ginis_new():
    '''
    (none) => list of dicts
    computes the t statistic relative to the null hypothesis that gini2 == gini1
    gini1 and gini2 are average cross-run ginis.
    we have 18 cases: 3 valus for chattiness, 3 for intimacystrength, 2 for policy
    we also have 1 priority test for each case: "more active" vs. "newer"
    '''
    
    results = []
    
    chattiness_values = [".1", ".2", ".4"]
    intimacy_values = ["1", "5", "11"]
    policy_types = ["engage", "none"]
    random_chat_states = ["true", "false"]
    
    # lots of overwriting here
    for c in chattiness_values:
        for i in intimacy_values:
            for pt in policy_types:
                for rc in random_chat_states:
                    for ob in obs: # each observation (line) in the file is a run of the model
                        thisCase = {} # provisionally stores the t-statistics on this observation
                        if ob["globalchattiness"] == c and  ob["intimacystrength"] == i and ob["policy"] == pt and ob["randomisedchattiness"] == rc:
                            thisCase["globalchattiness"] = c
                            thisCase["intimacystrength"] = i
                            thisCase["policy"] = pt
                            thisCase["randomisedchattiness"] = ob["randomisedchattiness"]
                            thisCase[ob["priority"] + "_ms_avg_gini"] = ob["ms_avg_gini"]
                            # print ('globalchattiness: ' + str(c) + '; intimacy: ' + str(i) + '; policy: ' + pt + ob["priority"] + "_ms_avg_gini")
                            thisCase[ob["priority"] + "_nc_avg_gini"] = ob["nc_avg_gini"]
                            thisCase[ob["priority"] + "_ms_se_gini"] = ob["ms_xrun_se_gini"] 
                            thisCase[ob["priority"] + "_nc_se_gini"] = ob["nc_xrun_se_gini"]  
                            print(thisCase)       

                            results.append(thisCase)
    for case in results:

        # now compute the t statistics
        ms_x2 = float(case["newer_ms_avg_gini"])
        ms_s2 = float(case["newer_ms_se_gini"])
        ms_x1 = float(case["more active_ms_avg_gini"])
        ms_s1 = float(case["more active_ms_se_gini"])
        ms_t = (ms_x1 - ms_x2) / (((ms_s1 ** 2 + ms_s2 ** 2) /24) ** (0.5))
        case["ms_t_more active_newer"] = ms_t

        nc_x2 = float(case["newer_nc_avg_gini"])
        nc_s2 = float(case["newer_nc_se_gini"])
        nc_x1 = float(case["more active_nc_avg_gini"])
        nc_s1 = float(case["more active_nc_se_gini"])
        nc_t = (nc_x1 - nc_x2) / (((nc_s1 ** 2  + nc_s2 ** 2) /24) ** (0.5))
        case["nc_t_more active_newer"] = nc_t
        
    return results

    

if __name__ == "__main__":
    obs = readFile(dirPath + 'data-w-gini-v4-all.csv')
    results = compute_t_ginis_new()
    for item in results:
        print ("globalchattiness: " + str(item["globalchattiness"]) + "; intimacy strength: " + str(item["intimacystrength"]) + "; policy: " + str(item["policy"]) + "; randomised chattiness: " + str(item["randomisedchattiness"]))
        print ("***** inequality in membership strength ********")
        print ("H0: ms_avg_gini(newer) = ms_avg_gini_more active => " + str(item["ms_t_newer_more active"]))
        print ("***** inequality in number of comments ********")
        print ("H0: nc_avg_gini(newer) = nc_avg_gini_more active => " + str(item["nc_t_newer_more active"]))
        print ("******************************************************************")

        

        
    
