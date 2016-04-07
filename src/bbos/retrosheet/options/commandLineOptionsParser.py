from optparse import OptionParser

def parseOptions():
    usage = createHelpText()
    
    optionParser = OptionParser(usage)
    
    optionParser.add_option('-y', '--year', dest='year', help="""the year to load""", metavar='YEAR')
    
    (options, args) = optionParser.parse_args()
    
    return options

def createHelpText():
    usage = """Welcome to BBOS - Baseball on a Stick for Retrosheet
    
    Usage options are shown below.
    
    example 1: load all 2007 retrosheet data
    bbosRetrosheet.py -y 2007
    
    """
    
    return usage