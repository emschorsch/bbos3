from bbos.test.fTest import FTest
from bbos.gameday.www.gameXMLProvider import GamedayXMLProvider
from bbos.gameday.loader.gameLoader import GamedayGameLoader
from bbos.gameday.loader.gameStatsWorkList import GameStatsWorkList
from bbos.gameday.www.directoryStructure import GamedayDirectoryStructure
from bbos.config.bbosConfig import BBOSConfig
from bbos.db.db import DB
import logging

class BBOSFTest(FTest):
    
    def setUp(self):
        self.db = DB();
        
    def test1Game(self):
        gamedayDirectory = GamedayDirectoryStructure(BBOSConfig.gamedayURL, "mlb")
    
        #gameName = "gid_2015_04_02_lanmlb_anamlb_1"
        gameName = "gid_2015_05_04_texmlb_houmlb_1"
        #gameName = "gid_2007_03_01_cinmlb_pitmlb_1"
        
        gamedayGameURLs = gamedayDirectory.getGameURLsForGame(gameName)
        
        for gameURL in gamedayGameURLs:
            logging.info( "gameURL:" + gameURL )
            xmlProvider = GamedayXMLProvider(gameURL)
            
            gameStatsWorkList = GameStatsWorkList()
            
            gameLoader = GamedayGameLoader(self.db, xmlProvider, gameStatsWorkList)
            
            if gameLoader.isAlreadyLoaded():
                gameLoader.delete()
            
            logging.info( "deleting:" + xmlProvider.getGameName() )
                
            gameLoader.delete()
            
            logging.info( "loading:" + xmlProvider.getGameName() )
                
            gameLoader.loadGame()
             
            loaded = gameLoader.isAlreadyLoaded();
            
            self.assertTrue(loaded)      
    
        logging.info( "" )
        logging.info( "load complete!" ) 
                   
    
           
              

        
        