from bbos.gameday.parser.parser import Parser
from regularExpressions import pattern
from bbos.config.gamedayConfig import GamedayConfig

class BoxScoreParser(Parser):
    
    def parse(self, xmlProvider):
        boxXML = xmlProvider.getBoxScoreXML()
        
        doc = self.createDocument(boxXML)
        if not doc: return
        
        self.__parseTeamNames__(doc.documentElement)
        
        pitchingTags = doc.getElementsByTagName('pitching')
        self.__parsePitchingTags__(pitchingTags)
        
        battingTags = doc.getElementsByTagName('batting')
        self.__parseBattingTags__(battingTags)
        
        gameInfoTags = doc.getElementsByTagName('game_info')
        gameInfoTag = gameInfoTags[0]
        self.__parseGameInfo__(gameInfoTag)
    
    def __parseGameInfo__(self, gameInfoTag):
        gameConditions = {}
        
        gameInfoText = gameInfoTag.firstChild.data
        
        temperature = pattern.capture("""<b>Weather<\/b>\:\s(\d\d+)\s""", gameInfoText)
        forecast = pattern.capture("""<b>Weather<\/b>\:\s\d\d+\sdegrees\, (.*?)\.""", gameInfoText)
        windMPH = pattern.capture("""<b>Wind<\/b>\:\s(\d+)\smph""", gameInfoText)
        windDirection = pattern.capture("""<b>Wind<\/b>\:\s\d+\smph\, (.*?)\.""", gameInfoText)
        gameLength = pattern.capture("""<b>T<\/b>\:\s(\d\:\d+)""", gameInfoText)
        attendence = pattern.capture("""<b>Att<\/b>\:\s(\d+\,\d+)""", gameInfoText)
        
        #<b>Weather</b>: 60 degrees, partly cloudy.<br/><b>Wind</b>: 6 mph, Out to RF.<br/>
        #<b>T</b>: 2:37.<br/><b>Att</b>: 34,404.<br/>
        if not gameLength: gameLength = '0:00'
        if not windMPH: windMPH = '0'
        
        gameConditions['temperature'] = temperature
        gameConditions['forecast'] = forecast
        gameConditions['windMPH'] = windMPH
        gameConditions['windDirection'] = windDirection
        gameConditions['gameLength'] = gameLength
        gameConditions['attendence'] = attendence.replace(",", "")
        
        self.game.setGameConditions(gameConditions)
        
        """Cabrera pitched to 5 batters in the 7th.<br/><br/>
        <b>HBP</b>: Byrd (by Cabrera).<br/>
        <b>Ground outs-fly outs</b>: Sabathia 4-7, Cabrera 0-0, 
        Betancourt 0-0, Karsay 0-1, Ortiz 12-2, Eischen 1-1, 
        Bray 2-1, Cordero 0-2.<br/>
        <b>Batters faced</b>: Sabathia 26, Cabrera 5, Betancourt 3, 
        Karsay 5, Ortiz 25, Eischen 5, Bray 3, Cordero 3.<br/>
        <b>Inherited runners-scored</b>: Betancourt 3-0, Eischen 2-0.<br/>
        <b>Umpires</b>: HP: Lance Barksdale. 1B: Kevin Causey. 
        2B: Sam Holbrook. 3B: Jeff Nelson.<br/>
        <b>Weather</b>: 71 degrees, clear.<br/>
        <b>Wind</b>: 14 mph, L to R.<br/>
        <b>T</b>: 2:51.<br/>
        <b>Att</b>: 5,885.<br/>"""
                
    def __parseBattingTags__(self, battingTags):
        batters = []
        
        for battingTag in battingTags:
            batterTags = battingTag.getElementsByTagName('batter')
            
            battersForTag = self.__parseBatterTags__(batterTags)
            
            batters.extend(battersForTag)
        
        self.game.setBatters(batters)
        
    def __parseBatterTags__(self, batterTags):
        batters = []
        
        for batterTag in batterTags:
            batter = self.mapTagWithList(batterTag, GamedayConfig.parser_boxscore_batter)
       
            batters.append(batter)
        
        return batters
            
    def __parsePitchingTags__(self, pitchingTags):
        pitchers = []
        
        for pitchingTag in pitchingTags:
            pitcherTags = pitchingTag.getElementsByTagName('pitcher')
            
            pitchersForTag = self.__parsePitcherTags__(pitcherTags)
            
            pitchers.extend(pitchersForTag)
        
        self.game.setPitchers(pitchers)
        
    def __parsePitcherTags__(self, pitcherTags):
        pitchers = []
        
        for pitcherTag in pitcherTags:
            pitcher = self.mapTagWithList(pitcherTag, GamedayConfig.parser_boxscore_pitcher)
            
            pitcher['outs'] = pitcher['out']
            del pitcher['out']
        
            note = pitcherTag.getAttribute('note')
            if pattern.match('\(W', note): pitcher['win'] = '1'
            if pattern.match('\(L', note): pitcher['loss'] = '1'
            if pattern.match('\(S', note): pitcher['save'] = '1'
            if pattern.match('\(BS', note): pitcher['blownsave'] = '1'
            if pattern.match('\(H', note): pitcher['hold'] = '1'
            if pattern.match('\(BH', note): pitcher['blownhold'] = '1'
        
            pitchers.append(pitcher)
        
        return pitchers
    
    def __parseTeamNames__(self, boxScoreTag):
        teamNameHome = {}
        teamNameHome['id'] = boxScoreTag.getAttribute('home_id')
        teamNameHome['name'] = boxScoreTag.getAttribute('home_fname')
        
        teamNameAway = {}
        teamNameAway['id'] = boxScoreTag.getAttribute('away_id')
        teamNameAway['name'] = boxScoreTag.getAttribute('away_fname')
        
        teamNames = [teamNameHome, teamNameAway]
        
        self.game.setTeamNames(teamNames)
        
        
        
        
        
        
        
        """<boxscore game_id="2007/10/12/clemlb-bosmlb-1" game_pk="224010" 
            home_sport_code="mlb" away_team_code="cle" home_team_code="bos" 
            away_id="114" home_id="111" away_fname="Cleveland Indians" 
            home_fname="Boston Red Sox" away_sname="Cleveland" 
            home_sname="Boston" date="October 12, 2007" away_wins="0" 
            away_loss="1" home_wins="1" home_loss="0" status_ind="F">"""
        