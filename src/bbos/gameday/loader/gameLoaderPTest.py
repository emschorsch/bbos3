from bbos.test.fTest import FTest
from bbos.config.gamedayConfig import GamedayConfig
from bbos.gameday.www.directoryStructure import GamedayDirectoryStructure
from bbos.gameday.www.gameXMLProvider import GamedayXMLProvider
from bbos.gameday.loader.gameLoader import GamedayGameLoader
from bbos.gameday.loader.gameStatsWorkList import GameStatsWorkList
from bbos.db.db import DB
import time
from osandio import fileUtils

class GamedayLoaderFTest(FTest):
    
    def setUp(self):
        self.db = DB();
        
        league = "mlb"
        
        self.gamedayDirectory = GamedayDirectoryStructure(GamedayConfig.mlbGamedayApplicationURL, league)
        
        self.performanceFileName = "./performance.log"
            
    def testLoad1Month(self):
        monthURL = "http://gd2.mlb.com/components/game/mlb/year_2006/month_06"
        
        gamedayGameURLs = self.gamedayDirectory.getGameURLsForMonth(monthURL)
        
        self.runAndStorePerformanceTest(gamedayGameURLs)            
    
    def testLoad1Game(self):
        gameName = "gid_2009_09_25_balmlb_clemlb_1"
        
        gamedayGameURLs = self.gamedayDirectory.getGameURLsForGame(gameName)
        
        self.runAndStorePerformanceTest(gamedayGameURLs)            
    
    def runAndStorePerformanceTest(self, gamedayGameURLs):
        beforeSeconds = time.time()
        
        for gameURL in gamedayGameURLs:
            xmlProvider = GamedayXMLProvider(gameURL)
        
            gameStatsWorkList = GameStatsWorkList()
        
            gameLoader = GamedayGameLoader(self.db, xmlProvider, gameStatsWorkList)
        
            gameLoader.delete()
        
            gameLoader.loadGame()
        
            gameLoader.delete()
        
        totalSeconds = time.time() - beforeSeconds
        timeHere = time.localtime()
        readableTime = time.asctime(timeHere)
        
        performanceTrackingFileContents = fileUtils.slurp(self.performanceFileName)
        
        performanceResult = "\n" + readableTime + "," + str(totalSeconds) + "," + str(len(gamedayGameURLs))
        
        performanceTrackingFileContents.append(performanceResult)
        
        fileUtils.spit(self.performanceFileName, performanceTrackingFileContents)
              

        
        