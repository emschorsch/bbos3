from bbos.config import loggingSetup
loggingSetup.initializeLogging("bbosPlayerBio.py")
import logging

from threadit import threadIt

from bbos.gameday.www.directoryStructure import GamedayDirectoryStructure
from bbos.config.bbosConfig import BBOSConfig
from bbos.gameday.loader.gameLoader import GamedayGameLoader
from bbos.gameday.www.gameXMLProvider import GamedayXMLProvider
from bbos.gameday.loader.playerBioWorkList import PlayerBioWorkList
from bbos.db.db import DB
from bbos.gameday.options import commandLineOptionsParser

        
def main():
    options = commandLineOptionsParser.parseOptions()
    
    logging.info("Starting bbosPlayerBio!")
    
    league = options.league
    
    try:
        gamedayDirectory = GamedayDirectoryStructure(BBOSConfig.gamedayURL, league)
        
        if options.game:
            gamedayGameURLs = gamedayDirectory.getGameURLsForGame(options.game)    
        elif options.day:
            gamedayGameURLs = gamedayDirectory.getGameURLsForDay(eval(options.day))    
        elif options.all != None:
            gamedayGameURLs = gamedayDirectory.getGameURLsForAllAvailable()
        elif options.year:
            gamedayGameURLs = gamedayDirectory.getGameURLsForYear(options.year)
        else:
            gamedayGameURLs = gamedayDirectory.getGameURLsForLastNumberOfDays(BBOSConfig.gamedayDaysBackToLoad)
            
        logging.info("Distributing" + str(len(gamedayGameURLs)) + "urls to" + str(BBOSConfig.numberOfThreads) + "threads")
        
        threadIt.threadThis(BBOSConfig.numberOfThreads, gamedayGameURLs, LoadGameFactory())
        
        logging.info("")
        logging.info("load complete!")
    except Exception, e:
        logging.error("Died with Exception: ")
        logging.error(e)
        raise e

class LoadGameFactory(threadIt.WorkerFactory):
    def produce(self):
        return LoadGame(DB())  

class LoadGame(threadIt.Worker):
    def __init__(self, db):
        self.db = db
        
    def consume(self, item):
        gameURL = item
        
        xmlProvider = GamedayXMLProvider(gameURL)
            
        playerBioWorkList = PlayerBioWorkList()
            
        gameLoader = GamedayGameLoader(self.db, xmlProvider, playerBioWorkList)
            
        if not gameLoader.isAlreadyLoaded():
            logging.info("loading:" + xmlProvider.getGameName())
                
            gameLoader.loadGame()


if __name__ == '__main__': 
    main()
    
