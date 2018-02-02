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
            elif oldval in ["newer", "more active", 'engage', 'both', 'high', 'mid', 'low']: 
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
        
def rename_vars(table):
    '''
    Shorter variable names
    '''
    for row in table:
        for key in row:
            newkey0 = key.replace('both_vs_engage', 'bve')
            newkey1 = newkey0.replace('more_active_vs_newer', 'mvn')
            newkey2 = newkey1.replace('onboard_vs_none', 'ovn')
            newkey3 = newkey2.replace('mid_vs_low', 'mvl')
            newkey4 = newkey3.replace('high_vs_mid', 'hvm')
            newkey5 = newkey4.replace('high_vs_low', 'hvl')
            row[newkey5] = row.pop(key)
    return table
    
def normalise(table):
    '''
    Change signs of ts around so that t > 0 is positive for the online community being modeled.
    '''
    to_normalise = ['dropouts_mvl', 'dropouts_hvm', 'dropouts_hvl', 'nc_t_mvl', 'nc_t_hvm', 'nc_t_hvl','ms_t_mvl', 'ms_t_hvm', 'ms_t_hvl', 'mgmteffort_mvl', 'mgmteffort_hvm', 'mgmteffort_hvl']
    for row in table: 
        for key in row:
            if key in to_normalise:
                oldval = row[key]
                if type(oldval) in [float, int]:
                    newval = - oldval
                    row[key] = newval 
                    print key + ', ' + str(oldval) + ', ' + str(newval)
    return table


def lookup(table):
    '''
    A first synthesis of results.
    '''
    # targetvars = ['dropouts_bve', 'dropouts_mvn', 'ms_t_bve', 'ms_t_mvn', 'nc_t_bve', 'nc_t_mvn', 'totalcomments_bve', 'totalcomments_mvn', \
    #     'totalmembershipstrength_bve', 'totalmembershipstrength_mvn', 'mgmteffort_bve', 'mgmteffort_mvn']
    print '=============================================='
    print 'CHOOSING A POLICY: MOVING FROM none TO onboard'
    print '=============================================='    
    counter = 1
    indicator = [0, 0, 0]
    for c in [0.05, 0.4]:
        print '============================================'
        print 'Global chattiness: ' + str(c)
        print '\n'
        for i in ['low', 'mid', 'high']:
            print 'Case ' + str(counter) + ': c = ' + str(c) + ', i = ' + str(i)
            for row in table:
                if row['globalchattiness'] == c and row['intimacystrength'] == i:
                    # count the cases for the t statistic for each variable to be < -2, between -2 and 2, or > 2
                    for var in row:
                        if 'ovn' in var:
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
            

            
def split_dataset(table):
    '''
    Divides the dataset in two, one modeling the policy choice, the other modeling the priority choice.
    Also saves the two files.
    '''
    dirPath = '/Users/albertocottica/github/local/community-management-simulator/Data/' # ok, ok, it's a bad hack to put it here
    print table[0]
    policy_dataset = []
    priority_dataset = []
    for row in table:
        policy_row = {} # the accumulator for this row
        priority_row = {} # ditto, but for the priority choice dataset
        if row['policy'] == None:
            # in this case, collect keys and values and add them to the policy choice dataset
            for key in row:
                if key != 'policy' and 'mvn' not in key:
                    policy_row[key] = row[key]
            policy_dataset.append(policy_row)
        else:
            # in this case, the policy is given. Collect for the priority choice dataset.
            for key in row:
                if key != 'priority' and 'bve' not in key:
                    priority_row[key] = row[key]
            priority_dataset.append(priority_row)

    success = writeFile(policy_dataset, dirPath + 'policy_dataset.csv')
    success = writeFile(priority_dataset, dirPath + 'priority_dataset.csv')


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
    dirPath = '/Users/albertocottica/github/local/community-management-simulator/Data/Experiment_1/'
    data = readFile(dirPath + 'results_experiment_1.csv')
    data0 = destring(data)
    data1 = rename_vars(data0)
    print data1[0]
    data2 = normalise(data1)
    print data2[0]
    print data1[0] == data2[0]
    # lookVal = lookup(data2)
    # normalised_results = writeFile(data2, dirPath + 'norm_results_experiment_1.csv' )
    
    