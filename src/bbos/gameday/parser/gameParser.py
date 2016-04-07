from bbos.gameday.parser.parser import Parser
from bbos.config.gamedayConfig import GamedayConfig

class GameParser(Parser):

    def parse(self, xmlProvider):
        gameXML = xmlProvider.getGameXML()
        
        self.__setLeagueLevel__(xmlProvider.getLeagueLevel());
            
        doc = self.createDocument(gameXML)
        if not doc: 
            return
        
        gameInfo = self.mapTagWithList(doc.documentElement, GamedayConfig.parser_game_gameinfo)
        
        gameInfo['leagueLevel'] = self.game.getGameInfo()['leagueLevel']   
        gameInfo['local_game_time'] = doc.documentElement.getAttribute('local_game_time') + ":00"
        
        teamTags = doc.getElementsByTagName('team')
        
        self.__parseTeams__(teamTags, gameInfo)
            
        stadiumTags = doc.getElementsByTagName('stadium')
        stadiumTag = stadiumTags[0]
        
        gameInfo['stadiumID'] = stadiumTag.getAttribute('id')
        
        self.__parseStadium__(stadiumTag)
            
        self.game.setGameInfo(gameInfo)
    
    def __setLeagueLevel__(self, leagueLevel):
        gameInfo = {}
        gameInfo['leagueLevel'] = leagueLevel
        self.game.setGameInfo(gameInfo)
            
    def __parseTeams__(self, teamTags, gameInfo):
        teams = []
        
        for teamTag in teamTags:
            team = self.mapTagWithList(teamTag, GamedayConfig.parser_game_team)
            
            homeAway = teamTag.getAttribute('type')
            teamID = teamTag.getAttribute('id')
            
            gameInfo[homeAway] = teamID
                                
            teams.append(team)
        
        self.game.setTeams(teams)    
                
    def __parseStadium__(self, stadiumTag):
        stadium = self.mapTagWithList(stadiumTag, GamedayConfig.parser_game_stadium)
        
        self.game.setStadium(stadium)
                
 
    
    """<game type="R" local_game_time="19:05" gameday_sw="E">
            <team type="home" code="mil" file_code="mil" abbrev="MIL" id="158" name="Milwaukee" w="87" l="71" league="NL"/>
            <team type="away" code="pit" file_code="pit" abbrev="PIT" id="134" name="Pittsburgh" w="65" l="93" league="NL"/>
            <stadium id="32" name="Miller Park" venue_w_chan_loc="USWI0455" location="Milwaukee, WI"/>
       </game>"""       
        
