from bbos.test.fTest import FTest
from bbos.gameday.www.gameXMLProvider import GamedayXMLProvider
from bbos.gameday.loader.gameLoader import GamedayGameLoader
from bbos.gameday.loader.gameStatsWorkList import GameStatsWorkList
from bbos.gameday.www.directoryStructure import GamedayDirectoryStructure
from bbos.config.gamedayConfig import GamedayConfig
from bbos.db.db import DB
import logging

class BBOSFTest(FTest):
    
    def setUp(self):
        self.db = DB();
        
    def testLoad_2007_04_12(self):
        gamedayDirectory = GamedayDirectoryStructure(GamedayConfig.mlbGamedayApplicationURL, "mlb")
    
        gamedayGameURLs = gamedayDirectory.getGameURLsForDay(("2007", "04", "12"))
    
        for gameURL in gamedayGameURLs:
            xmlProvider = GamedayXMLProvider(gameURL)
            
            gameStatsWorkList = GameStatsWorkList()
            
            gameLoader = GamedayGameLoader(self.db, xmlProvider, gameStatsWorkList)
            
            if gameLoader.isAlreadyLoaded():
                gameLoader.delete()
            
            logging.info( "loading:" + xmlProvider.getGameName() )
                
            gameLoader.loadGame()
             
            loaded = gameLoader.isAlreadyLoaded();
            
            self.assertTrue(loaded)      
    
        logging.info( "" )
        logging.info( "load complete!" )
        
    def testLoad_2008_04_12(self):
        gamedayDirectory = GamedayDirectoryStructure(GamedayConfig.mlbGamedayApplicationURL, "mlb")
    
        gamedayGameURLs = gamedayDirectory.getGameURLsForDay(("2008", "04", "12"))
    
        for gameURL in gamedayGameURLs:
            xmlProvider = GamedayXMLProvider(gameURL)
            
            gameStatsWorkList = GameStatsWorkList()
            
            gameLoader = GamedayGameLoader(self.db, xmlProvider, gameStatsWorkList)
            
            if gameLoader.isAlreadyLoaded():
                gameLoader.delete()
            
            logging.info( "loading:" + xmlProvider.getGameName() )
                
            gameLoader.loadGame()
             
            loaded = gameLoader.isAlreadyLoaded();
            
            self.assertTrue(loaded)      
    
        logging.info( "" )
        logging.info( "load complete!" )  
        
    def testLoad_2009_04_12(self):
        gamedayDirectory = GamedayDirectoryStructure(GamedayConfig.mlbGamedayApplicationURL, "mlb")
    
        gamedayGameURLs = gamedayDirectory.getGameURLsForDay(("2009", "04", "12"))
    
        for gameURL in gamedayGameURLs:
            xmlProvider = GamedayXMLProvider(gameURL)
            
            gameStatsWorkList = GameStatsWorkList()
            
            gameLoader = GamedayGameLoader(self.db, xmlProvider, gameStatsWorkList)
            
            if gameLoader.isAlreadyLoaded():
                gameLoader.delete()
            
            logging.info( "loading:" + xmlProvider.getGameName() )
                
            gameLoader.loadGame()
             
            loaded = gameLoader.isAlreadyLoaded();
            
            self.assertTrue(loaded)      
    
        logging.info( "" )
        logging.info( "load complete!" ) 
                   
    
           
              

        
        