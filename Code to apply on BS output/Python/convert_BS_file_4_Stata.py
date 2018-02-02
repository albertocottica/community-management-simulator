import csv

def stringToList(longString):
    '''
    (string) => list
    transforms longString into a Python list
    '''
    lS1 = longString.strip('[]').split()
    return lS1

def convert (runRow):
    '''
    (dict) => dict
    re-arranges the observations contained in one runRow (which represent one run with many turtles)
    as cross-sectional data (each row is one turtle).
    All non-turtle-specific data are repeated in each row. New-type rows are returned as dictionaries.
    '''
    conv = {} # initialize the dictionary to be returned
    ## start by copying the turtle-invariant (run-specific) values
    conv ["[run number]"] = runRow ["[run number]"]
    conv ["founders"] = runRow ["founders"]
    conv ["global-chattiness"] = runRow ["global-chattiness"]
    conv ["randomised-chattiness"] = runRow["randomised-chattiness"]
    conv ["num-members"] = runRow ["num-members"]
    conv ["intimacy-strength"] = runRow ["intimacy-strength"]
    conv ["total-membership-strength"] = runRow ["total-membership-strength"]
    conv ["total-comments"] = runRow ["total-comments"]
    conv ["dropouts"] = runRow ["dropouts"]
    conv ["priority"] = runRow ["priority"]
    conv ["mgmt-effort"] = runRow ["mgmt-effort"]
    if runRow["onboard"] == "false" and runRow["engage"] == "false":
        conv ["policy"] = "none"
    elif runRow["onboard"] == "true" and runRow["engage"] == "false":
        conv ["policy"] = "onboard"
    elif runRow["onboard"] == "false" and runRow["engage"] == "true":
        conv ["policy"] = "engage"
    elif runRow["onboard"] == "true" and runRow["engage"] == "true":
        conv ["policy"] = "both"

    
    ## now add turtle-specific information
    ## start by creating lists from all the NetLogo reporters of the type "[my-variable] of turtles"
    idList = stringToList(runRow["map idlist sort members"])
    msList = stringToList(runRow["map mslist sort members"])
    ncList = stringToList(runRow["map nclist sort members"])  
    mychList = stringToList(runRow["map mychlist sort members"])      
    listOfTurtleDicts = [] ## create the list to be returned
    for i in range (len(msList)):
        turtleRow = conv.copy() # make a copy of conv
        turtleRow['id'] = idList[i]
        turtleRow['ms'] = msList[i]
        turtleRow['nc'] = ncList[i]
        turtleRow['mych'] = mychList[i]
        listOfTurtleDicts.append(turtleRow)
    return listOfTurtleDicts

dirPath = '/Users/albertocottica/github/local/community-management-simulator/Data/Experiment_3/'
converted = []
with open (dirPath + 'Online_communities_v4 capacity_allocation_3_1-table.csv', 'r') as csvFile:
    for i in range (6):
        csvFile.readline()
    csvReader = csv.DictReader (csvFile, delimiter = ',', quotechar = '"')
    for row in csvReader:
        listOfDicts = convert(row)
        for item in listOfDicts:
            converted.append(item)
        
with open (dirPath + 'dataByTurtle_v4_experiment_3.csv', 'w') as outFile:
    fieldnames = ["[run number]","founders","global-chattiness", "randomised-chattiness","num-members", "intimacy-strength","policy", "priority","total-membership-strength","dropouts","total-comments",  "mgmt-effort","id", "ms","nc", "mych"]
    ## paste the column title row of the table.csv file coming out of NetLogo
    writer = csv.DictWriter (outFile, fieldnames = fieldnames)
    
    writer.writeheader()
    for row in converted:
        writer.writerow(row)
    
        
