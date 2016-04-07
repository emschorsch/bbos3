from bbos.test.fTest import FTest
from bbos.gameday.www.directoryStructure import GamedayDirectoryStructure

class GamedayDirectoryStructureFTest(FTest):
    
    def setUp(self):
        url = "http://gd2.mlb.com/components/game/";

        self.gamedayDirectory = GamedayDirectoryStructure(url, "mlb")    
    
    
    def testGet404BadGameURL(self):
        url = "http://gd2.mlb.com/components/game/mlb/year_2006/month_02/day_28/gid_2006_02_28_kiamlb_cinmlb_1/"
        
        gamedayGameURLs = self.gamedayDirectory.__filterGameURLsForFullGames__([url])

        self.assertEqual(0, len(gamedayGameURLs))
            
    def testGetDayURLsForMonth04_2008(self):
        url = "http://gd2.mlb.com/components/game/mlb/year_2008/month_04/"
        
        gamedayGameURLs = self.gamedayDirectory.__getDayURLsForMonth__(url)

        self.assertEqual(31, len(gamedayGameURLs))
        
    def testGetGameURLsForDay04_12_2008(self):
        url = "http://gd2.mlb.com/components/game/mlb/year_2008/month_04/day_12/"
        
        gamedayGameURLs = self.gamedayDirectory.__getGameURLsForDay__(url)

        self.assertEqual(15, len(gamedayGameURLs))
        
    def testParseGameIDs(self):
        url = "http://gd2.mlb.com/components/game/mlb/year_2007/month_08/day_17/"
        
        gameIDs = self.gamedayDirectory.__parseGameIDs__(url)

        self.assertEqual(16, len(gameIDs))
        
    def testGetGameURLsForGame(self):
        gameName = 'gid_2007_03_01_cinmlb_pitmlb_1'
        urls = ["http://gd2.mlb.com/components/game/mlb/year_2007/month_03/day_01/gid_2007_03_01_cinmlb_pitmlb_1/"]
        
        gamedayGameURLs = self.gamedayDirectory.getGameURLsForGame(gameName)

        self.assertEqual(urls, gamedayGameURLs)
            
    def testGetGameURLsForDay(self):
        dayString = """('2008', '09', '24')"""
        day = eval(dayString)
        
        gamedayGameURLs = self.gamedayDirectory.getGameURLsForDay(day)

        self.assertEqual(15, len(gamedayGameURLs))
    
#    def testGetGameURLsForYear(self): 
#        gamedayGameURLs = self.gamedayDirectory.getGameURLsForYear(2005)
#
#        self.assertEqual(2136, len(gamedayGameURLs))
    
    def testGetGameURLsForLastNumberOfDays(self): 
        self.gamedayDirectory.getGameURLsForLastNumberOfDays(5)
            
    def testDateInFuture(self):
        url = "http://gd2.mlb.com/components/game/mlb/year_2099/month_08/day_17/"
        
        inFuture = self.gamedayDirectory.__dateInFuture__(url)

        self.assertTrue(inFuture)
        
        url = "http://gd2.mlb.com/components/game/mlb/year_2008/month_08/day_17/"
        
        inFuture = self.gamedayDirectory.__dateInFuture__(url)

        self.assertFalse(inFuture)
        
        url = "http://gd2.mlb.com/components/game/mlb/year_1999/month_08/day_17/"
        
        inFuture = self.gamedayDirectory.__dateInFuture__(url)

        self.assertFalse(inFuture)
        
        

