from bbos.config import loggingSetup
loggingSetup.initializeLogging("deleteBBOSGame.py")
import logging
from bbos.gameday.www.directoryStructure import GamedayDirectoryStructure
from bbos.gameday.options import commandLineOptionsParser
from bbos.config.bbosConfig import BBOSConfig
from bbos.gameday.loader.gameLoader import GamedayGameLoader
from bbos.gameday.www.gameXMLProvider import GamedayXMLProvider
from bbos.gameday.loader.gameStatsWorkList import GameStatsWorkList
from bbos.db.db import DB
      
       
def main():
    
    options = commandLineOptionsParser.parseOptions()
    
    logging.info("Starting delete!")
        
    league = options.league
        
    try:
        gamedayDirectory = GamedayDirectoryStructure(BBOSConfig.gamedayURL, league)
        
        if options.game:
            gamedayGameURLs = gamedayDirectory.getGameURLsForGame(options.game)    
        elif options.day:
            gamedayGameURLs = gamedayDirectory.getGameURLsForDay(eval(options.day))    
        elif options.year:
            gamedayGameURLs = gamedayDirectory.getGameURLsForYear(options.year)
        elif options.recent:
            gamedayGameURLs = gamedayDirectory.getGameURLsForLastNumberOfDays(BBOSConfig.gamedayDaysBackToLoad)
        else:
            gamedayGameURLs = gamedayDirectory.getGameURLsForLastNumberOfDays(BBOSConfig.gamedayDaysBackToLoad)
            
        gamedayGameURLs.reverse()
    
        for gameURL in gamedayGameURLs:
            logging.info("deleting:"+gameURL)
            xmlProvider = GamedayXMLProvider(gameURL)
                
            db = DB();
                
            gameStatsWorkList = GameStatsWorkList()
                    
            gameLoader = GamedayGameLoader(db, xmlProvider, gameStatsWorkList)
                
            gameLoader.delete()
        
        logging.info("")
        logging.info("delete complete!")
    except:
        logging.error("Died with Exception: ")
        import StringIO
        output = StringIO.StringIO()
        import traceback
        traceback.print_exc(file=output)
        logging.error(output.getvalue())
        raise

if __name__ == '__main__': main()
    
