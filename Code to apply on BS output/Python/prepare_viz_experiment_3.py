import csv

def readFile(filename):
    '''
    (str) => list of dicts
    loads file filename into a list. Each item is a dict encoding one run in the model.
    '''
    with open (filename, 'r') as csvFile:
        csvReader = csv.DictReader (csvFile, delimiter = ',', quotechar = '"')
        table = []
        for row in csvReader:
            table.append(row)
        return table
        
def destring(table):
    '''
    convert all values to proper Python objects, mostly floats
    ''' 
    for row in table:
        for key in row:
            oldval = row[key]
            if oldval == '':
                newval = None
            elif oldval == 'nan':
                newval = 0
            elif oldval == 'true':
                newval = True
            elif oldval == 'false':
                newval = False
            elif oldval in ["newer", "more active", 'engage', 'both', 'low', 'mid', 'high']: 
                continue
            else:
                newval = float(row[key])
            row[key] = newval
    return table

def invert_sign_in_table(table, key):
    '''
    (list of dicts, str) => None
    flips the sign of the value corresponding to key.
    Remember to check that the value is a float or int
    >>> table = [{'foo': 3}, {'foo': -1.42}]
    >>> success = invert_sign_in_table(table, 'foo')
    >>> table
    [{'foo': -3}, {'foo': 1.42}]
    '''
    for row in table:
        if key in row: 
            a = row[key]
            if type(a) in [int, float]:
                b = - a
                row[key] = b

    
def flipGinis(table):
    '''
    Invert the signs ot the ts on ginis for policy, so that they model "both vs. engage" and not "engage vs. both"
    '''
    for row in table:
        # change the name of the keys
        row ['ms_t_both_vs_engage'] = row.pop('ms_t_engage_vs_both')
        row ['nc_t_both_vs_engage'] = row.pop('nc_t_engage_vs_both')
        # invert the signs of the values
    invert_sign_in_table(table, 'ms_t_both_vs_engage')
    invert_sign_in_table(table, 'nc_t_both_vs_engage')

    return table

        
def rename_vars(table):
    '''
    Shorter variable names
    '''
    for row in table:
        for key in row:
            newkey = key.replace('newer_vs_more_active', 'nvm')
            row[newkey] = row.pop(key)
    return table
    
def normalise(table):
    '''
    Change signs of ts around so that t > 0 is positive for the online community being modeled.
    '''
    to_normalise = ['dropouts_nvm', 'nc_t_nvm', 'ms_t_nvm', 'mgmteffort_nvm']
    for row in table: 
        for key in row:
            if key in to_normalise:
                oldval = row[key]
                if type(oldval) in [float, int]:
                    newval = - oldval
                    row[key] = newval 
    return table


def lookup(table):
    '''
    A first synthesis of results.
    '''
    # targetvars = ['dropouts_bve', 'dropouts_mvn', 'ms_t_bve', 'ms_t_mvn', 'nc_t_bve', 'nc_t_mvn', 'totalcomments_bve', 'totalcomments_mvn', \
    #     'totalmembershipstrength_bve', 'totalmembershipstrength_mvn', 'mgmteffort_bve', 'mgmteffort_mvn']
    print '============================================='
    print 'CHOOSING A POLICY: MOVING FROM engage TO both'
    print '============================================='    
    counter = 1
    indicator = [0, 0, 0]
    for rand in [False, True]:
        print '==========================================='
        print 'Randomised chattiness: ' + str(rand)
        print '\n'
        for c in [.1, .2, .4]:
            for i in [1, 5, 11]:
                for pri in ['newer', 'more active']:
                    print 'Case ' + str(counter) + ': c = ' + str(c) + ', i = ' + str(i) + ', pri =' + str(pri)
                    for row in table:
                        if (row['randomisedchattiness'] == rand and (row['globalchattiness']) == c  
                            and row['intimacystrength'] == i and row['priority'] == pri):
                            # count the cases for the t statistic for each variable to be < -2, between -2 and 2, or > 2
                            for var in row:
                                if 'bve' in var:
                                    tvalue = row[var]
                                    print var + ': ' + str(tvalue)
                                    if tvalue < -2:
                                        indicator [0] += 1
                                    elif tvalue > -2 and tvalue < 2:
                                        indicator[1] += 1
                                    else: 
                                        indicator[2] += 1
                            print '\n'
                    counter += 1
    print 'POLICY CHOICE SYNTHESIS. Positive effects: ' + str(indicator[2]) + '; nonsignificant: ' + str(indicator[1]) + '; negative: '  + str(indicator[0])
            
    print '======================================================'
    print 'CHOOSING A PRIORITY: MOVING FROM newer TO more active'
    print '======================================================'    
    counter = 1
    indicator = [0, 0, 0]
    for rand in [False, True]:
        print '==========================================='
        print 'Randomised chattiness: ' + str(rand)
        print '\n'
        for c in [.1, .2, .4]:
            for i in [1, 5, 11]:
                for p in ['engage', 'both']:
                    print 'Case ' + str(counter) + ': c = ' + str(c) + ', i = ' + str(i) + ', policy =' + str(p)
                    for row in table:
                        if (row['randomisedchattiness'] == rand and (row['globalchattiness']) == c  
                            and row['intimacystrength'] == i and row['policy'] == p):
                            # count the cases for the t statistic for each variable to be < -2, between -2 and 2, or > 2
                            for var in row:
                                if 'mvn' in var:
                                    tvalue = row[var]
                                    print var + ': ' + str(tvalue)
                                    if tvalue < -2:
                                        indicator [0] += 1
                                    elif tvalue > -2 and tvalue < 2:
                                        indicator[1] += 1
                                    else: 
                                        indicator[2] += 1
                                        print 'here!'
                            print '\n'
                    counter += 1
    print 'PRIORITY CHOICE SYNTHESIS. Positive effects: ' + str(indicator[2]) + '; nonsignificant: ' + str(indicator[1]) + '; negative: '  + str(indicator[0])
    print '\n'
            

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
    data = readFile(dirPath + 'results_experiment_3.csv')
    data1 = destring(data)
    data2 = rename_vars(data1)
    print data2[0]
    data3 = normalise(data2)
    print data3[0]
    success = writeFile(data3, dirPath + 'norm_results_experiment_3.csv')
    
    