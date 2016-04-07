from www.page import Page
import re
from bbos.config.bbosConfig import BBOSConfig

class GamedayXMLProvider:
    def __init__(self, url):
        self.url = url
        self.setGameName()
        self.setLeagueLevel()
        
    def getGameName(self):
        return self.gameName
    
    def setGameName(self):
        pattern = re.compile('(gid_.*)$')
        
        gameNames = pattern.findall(self.url)
        
        gameName = gameNames[0]
        
        gameName = gameName.replace("/", "")
        
        self.gameName = gameName
        
    def getLeagueLevel(self):
        return self.leagueLevel
           
    def setLeagueLevel(self):
        #http://gd2.mlb.com/components/game/aax/year_2008/month_06/day_10/
        pattern = re.compile('game/(.*)/year')
        
        leagueLevels = pattern.findall(self.url)
        
        leagueLevel = leagueLevels[0]
        
        leagueLevel = leagueLevel.replace("/", "")
        
        self.leagueLevel = leagueLevel
        
    def getHitXML(self):
        hitURL = self.url + "/inning/inning_hit.xml"

        hitXML = Page(hitURL).getContent()
        
        return hitXML
        
    def getInningXMLs(self):
        inningDirectoryURL = self.url + "/inning/"

        inningURLContent = Page(inningDirectoryURL).getContent()
        
        pattern = re.compile('inning_\d+\.xml</a>')
        
        inningURLs = pattern.findall(inningURLContent)
        
        inningURLs = self.__sortByInning__(inningURLs)
        
        inningURLs = [url[0:-4] for url in inningURLs]
        
        inningURLs = [inningDirectoryURL + "/" + url for url in inningURLs]
        
        inningContents = [Page(url).getContent() for url in inningURLs]
        
        return inningContents
   
    def __sortByInning__(self, inningURLs):
        def compareByInning(a, b):
            return cmp(self.__getInningNumber__(a), self.__getInningNumber__(b))

        inningURLs.sort(compareByInning)

        return inningURLs
        
    def __getInningNumber__(self, inningString):    
        #inning_1.xml</a>
        pattern = re.compile('inning_(\d+)\.xml</a>')
        
        inningNumbers = pattern.findall(inningString)
        
        inningNumber = inningNumbers[0]
        
        return int(inningNumber)
        
    def getGameXML(self):
        url = self.url + "/game.xml"

        xml = Page(url).getContent()
        
        return xml  
   
    def getLinescoreXML(self):
        url = self.url + "/linescore.xml"

        xml = Page(url).getContent()
        
        return xml  
   
    def getPlayerXML(self):
        url = self.url + "/players.xml"

        xml = Page(url).getContent()
        
        return xml  
   
    def getPlayerBIOXMLs(self):
        batterBIOURLs = self.__getBatterBIOXMLs__()
        
        pitcherBIOURLs = self.__getPitcherBIOXMLs__()
        
        playerBIOURLs = batterBIOURLs
        playerBIOURLs.extend(pitcherBIOURLs)
        
        return playerBIOURLs
   
    def __getBatterBIOXMLs__(self):
        batterDirectoryURL = self.url + "/batters/"

        batterBIOURLContent = Page(batterDirectoryURL).getContent()
        
        pattern = re.compile('\d+\.xml</a>')
        #batters/111904.xml
        
        batterBIOURLs = pattern.findall(batterBIOURLContent)
        
        batterBIOURLs = [url[0:-4] for url in batterBIOURLs]
        
        batterBIOURLs = [batterDirectoryURL + "/" + url for url in batterBIOURLs]
        
        batterBIOContents = [Page(url).getContent() for url in batterBIOURLs]
        
        return batterBIOContents
   
    def __getPitcherBIOXMLs__(self):
        pitcherDirectoryURL = self.url + "/pitchers/"

        pitcherBIOURLContent = Page(pitcherDirectoryURL).getContent()
        
        pattern = re.compile('\d+\.xml</a>')
        #pitchers/111904.xml
        
        pitcherBIOURLs = pattern.findall(pitcherBIOURLContent)
        
        pitcherBIOURLs = [url[0:-4] for url in pitcherBIOURLs]
        
        pitcherBIOURLs = [pitcherDirectoryURL + "/" + url for url in pitcherBIOURLs]
        
        pitcherBIOContents = [Page(url).getContent() for url in pitcherBIOURLs]
        
        return pitcherBIOContents
   
    def getBoxScoreXML(self):
        url = self.url + "/boxscore.xml"

        xml = Page(url).getContent()
        
        return xml  
    
    def getPregumboJSON(self):
        pregumboJSONURL = self.url + "/pregumbo.json"

        pregumboJSON = Page(pregumboJSONURL).getContent()
        
        return pregumboJSON
    
    def getFeedJSON(self, gameIDNumber):
        #http://statsapi.mlb.com/api/v1/game/413965/feed/color
        jsonURL = BBOSConfig.statsapiURL + str(gameIDNumber) + "/feed/color"

        jsonContent = Page(jsonURL).getContent()
        
        return jsonContent
