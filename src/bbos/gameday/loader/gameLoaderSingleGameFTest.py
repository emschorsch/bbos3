import unittest
from bbos.gameday.www.gameXMLProvider import GamedayXMLProvider
from bbos.gameday.loader.gameLoader import GamedayGameLoader
from bbos.db.db import DB

class GamedayLoaderFTest(unittest.TestCase):
    
    def setUp(self):
        self.db = DB();
            
    def testLoad(self):
        url = "http://gd2.mlb.com/components/game/mlb/year_2008/month_09/day_24/gid_2008_09_24_pitmlb_milmlb_1/"
        
        xmlProvider = GamedayXMLProvider(url)
        
        gameLoader = GamedayGameLoader(self.db, xmlProvider)
        
        gameLoader.delete()
        
        gameLoader.loadGame()
        
        loaded = gameLoader.isAlreadyLoaded()
        
        self.assertTrue(loaded)  
    
    def testLoad04_02_2008(self):
        url = "http://gd2.mlb.com/components/game/mlb//year_2008/month_04/day_02/gid_2008_04_02_milmlb_chnmlb_1/"
        
        xmlProvider = GamedayXMLProvider(url)
        
        gameLoader = GamedayGameLoader(self.db, xmlProvider)
        
        gameLoader.delete()
        
        gameLoader.loadGame()
        
        loaded = gameLoader.isAlreadyLoaded()
        
        self.assertTrue(loaded)      
                   
    def testLoad10_16_2006(self):
        url = "http://gd2.mlb.com/components/game/mlb/year_2008/month_09/day_24/gid_2006_10_16_nynmlb_slnmlb_1/"
        
        xmlProvider = GamedayXMLProvider(url)
        
        gameLoader = GamedayGameLoader(self.db, xmlProvider)
        
        gameLoader.delete()
        
        gameLoader.loadGame()
        
        loaded = gameLoader.isAlreadyLoaded()
        
        self.assertTrue(loaded)          
            
    def testLoad2006(self):
        url = "http://gd2.mlb.com/components/game/mlb//year_2006/month_02/day_28/gid_2006_02_28_falbbc_slnmlb_1/"
        
        xmlProvider = GamedayXMLProvider(url)
        
        gameLoader = GamedayGameLoader(self.db, xmlProvider)
        
        gameLoader.delete()
        
        gameLoader.loadGame()
        
        loaded = gameLoader.isAlreadyLoaded()
        
        self.assertTrue(loaded)           
            
    def testLoad2006_03_30(self):
        url = "http://gd2.mlb.com/components/game/mlb//year_2006/month_03/day_30/gid_2006_03_30_anamlb_sfnmlb_1/"
        
        xmlProvider = GamedayXMLProvider(url)
        
        gameLoader = GamedayGameLoader(self.db, xmlProvider)
        
        gameLoader.delete()
        
        gameLoader.loadGame()
        
        loaded = gameLoader.isAlreadyLoaded()
        
        self.assertTrue(loaded)
                      
    def testLoad2006_03_30sea(self):
        url = "http://gd2.mlb.com/components/game/mlb//year_2006/month_03/day_30/gid_2006_03_30_seamlb_sdnmlb_1/"
        
        xmlProvider = GamedayXMLProvider(url)
        
        gameLoader = GamedayGameLoader(self.db, xmlProvider)
        
        gameLoader.delete()
        
        gameLoader.loadGame()
        
        loaded = gameLoader.isAlreadyLoaded()
        
        self.assertTrue(loaded) 
                               
    def testLoad2006_10_16(self):
        url = "http://gd2.mlb.com/components/game/mlb//year_2006/month_10/day_16/gid_2006_10_16_nynmlb_slnmlb_1/"
        
        xmlProvider = GamedayXMLProvider(url)
        
        gameLoader = GamedayGameLoader(self.db, xmlProvider)
        
        gameLoader.delete()
        
        gameLoader.loadGame()
        
        loaded = gameLoader.isAlreadyLoaded()
        
        self.assertTrue(loaded)  
                               
    def testLoad2008_02_27(self):
        url = "http://gd2.mlb.com/components/game/mlb//year_2008/month_02/day_27/gid_2008_02_27_slbbbc_slnmlb_1/"
        
        xmlProvider = GamedayXMLProvider(url)
        
        gameLoader = GamedayGameLoader(self.db, xmlProvider)
        
        gameLoader.delete()
        
        gameLoader.loadGame()
        
        loaded = gameLoader.isAlreadyLoaded()
        
        self.assertTrue(loaded) 
           
              

        
        