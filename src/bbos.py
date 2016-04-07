from bbos.config import loggingSetup
loggingSetup.initializeLogging("bbos.py")
import logging

from threadit import threadIt

from bbos.gameday.www.directoryStructure import GamedayDirectoryStructure
from bbos.config.bbosConfig import BBOSConfig
from bbos.gameday.www.gameXMLProvider import GamedayXMLProvider
from bbos.gameday.loader.gameLoader import GamedayGameLoader
from bbos.gameday.loader.gameStatsWorkList import GameStatsWorkList
from bbos.db.db import DB
from bbos.gameday.options import commandLineOptionsParser

        
def main():
    options = commandLineOptionsParser.parseOptions()
    
    logging.info("Starting bbos!")
    
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
        
        logging.info("Distributing " + str(len(gamedayGameURLs)) + " urls to " + str(BBOSConfig.numberOfThreads) + " threads")
        
        threadIt.threadThis(BBOSConfig.numberOfThreads, gamedayGameURLs, LoadGameFactory())
        
        logging.info("")
        logging.info("load complete!")
    except:
        logging.error("Died with Exception: ")
        import StringIO
        output = StringIO.StringIO()
        import traceback
        traceback.print_exc(file=output)
        logging.error(output.getvalue())
        raise
             
class LoadGameFactory(threadIt.WorkerFactory):
    def produce(self):
        return LoadGame(DB())  

class LoadGame(threadIt.Worker):
    def __init__(self, db):
        self.db = db
        
    def consume(self, item):
        gameURL = item
        
        xmlProvider = GamedayXMLProvider(gameURL)
        
        gameStatsWorkList = GameStatsWorkList()
        
        gameLoader = GamedayGameLoader(self.db, xmlProvider, gameStatsWorkList)
        
        if not gameLoader.isAlreadyLoaded():
            logging.info("loading:" + xmlProvider.getGameName())
            
            gameLoader.loadGame()
        else:
            logging.info("skipping previously loaded:" + xmlProvider.getGameName())

if __name__ == '__main__': 
    main()
    
