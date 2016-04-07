from optparse import OptionParser

def parseOptions():
    usage = createHelpText()
    
    optionParser = OptionParser(usage)
    
    optionParser.add_option('-g', '--game', dest='game', help='the gameday game name to load', metavar='GAME')
    optionParser.add_option('-d', '--day', dest='day', help="""the day to load in the format ('2008','09','24')""", metavar='DAY')
    optionParser.add_option('-y', '--year', dest='year', help="""the year to load""", metavar='YEAR')
    optionParser.add_option('-r', '--recent', action="store_false", help="""loads recent games (days back defined in gamedayConfig.py)""")
    
    (options, args) = optionParser.parse_args()
    
    setLeagueIfPassedIn(options, args)
    
    return options

def createHelpText():
    usage = """Welcome to BBOS - Baseball on a Stick
    
    Usage options are shown below.  The most typical use of BBOS is to load
    data from MLB's Gameday system into a MySQL database.  To do this we use
    the bbos.py main script and supply the league to load and the time frame
    of games to load.
    
    example 1: load recent major league games
    bbos.py mlb -r
    
    example 2: load all 2008 mlb games
    bbos.py mlb -y 2008
    
    example 3: load all 2009 triple A games
    bbos.py aaa -y 2009
    
    example 4: load all 2011 mlb games on 9/23
    bbos.py mlb -d ('2011','09','23')
    
    gameday leagues are available at the root directory of
    gameday XML files at;
    http://gd2.mlb.com/components/game/
    
    
    Player Biographical information is still game and league based
    but is loaded by a separate script, bbosPlayerBio.py.  The biographical
    script accepts the same range of date options as the game script above.
    
    example 1: load recent major league game player biographical information
    bbosPlayerBio.py mlb -r
    """
    
    return usage
    
def setLeagueIfPassedIn(options, args):
    if len(args) > 0:
        options.league = args[0]
    else:
        options.league = "mlb"