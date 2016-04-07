from bbos.test.fTest import FTest
from bbos.gameday.www.gameXMLProvider import GamedayXMLProvider
from bbos.gameday.loader.gameLoader import GamedayGameLoader
from bbos.gameday.loader.gameStatsWorkList import GameStatsWorkList
from bbos.db.db import DB

class GamedayLoaderFTest(FTest):
    
    def setUp(self):
        self.db = DB();
            
    def testLoad(self):
        url = "http://gd2.mlb.com/components/game/mlb/year_2006/month_06/day_08/gid_2006_06_08_tormlb_balmlb_1/"
        
        xmlProvider = GamedayXMLProvider(url)
        
        gameStatsWorkList = GameStatsWorkList()
        
        gameLoader = GamedayGameLoader(self.db, xmlProvider, gameStatsWorkList)
        
        gameLoader.delete()
        
        gameLoader.loadGame()
        
        loaded = gameLoader.isAlreadyLoaded()
        
        self.assertTrue(loaded)      
                   
    
           
              

        
        