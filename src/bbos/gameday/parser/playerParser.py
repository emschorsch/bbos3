from bbos.gameday.parser.parser import Parser
from bbos.config.gamedayConfig import GamedayConfig

class PlayerParser(Parser):
    
    def parse(self, xmlProvider):
        playerXML = xmlProvider.getPlayerXML()
        
        doc = self.createDocument(playerXML)
        if not doc: return
        
        self.__parseUmpTags__(doc)
        
        teamTags = doc.getElementsByTagName('team')
        
        self.__parseTeamTags__(teamTags)
        
    def __parseUmpTags__(self, doc):
        umpiresTags = doc.getElementsByTagName('umpires')
        if not umpiresTags: return
        
        umpTags = umpiresTags[0].getElementsByTagName('umpire')
        
        umps = []
        
        for umpTag in umpTags:
            ump = self.mapTagWithList(umpTag, GamedayConfig.parser_player_ump)
            
            if 'id' in ump and ump['id'].strip():
                umps.append(ump)
            
        self.game.setUmps(umps)
        
    def __parseTeamTags__(self, teamTags):
        players = []
        coaches = []
        
        for teamTag in teamTags:
            team = teamTag.getAttribute('id');
            homeAway = teamTag.getAttribute('type');
            
            playerTags = teamTag.getElementsByTagName('player')
            coachTags = teamTag.getElementsByTagName('coach')
            
            self.__parsePlayerTags__(team, homeAway, players, playerTags)
            self.__parseCoachTags__(team, homeAway, coaches, coachTags)
            
        self.game.setPlayers(players)
        self.game.setCoaches(coaches)
        
    def __parsePlayerTags__(self, team, homeAway, players, playerTags):
        for playerTag in playerTags:
            player = self.mapTagWithList(playerTag, GamedayConfig.parser_player_player)
            player['team'] = team
            player['homeAway'] = homeAway
            
            if 'num' in player and player['num'] == 'null':
                del(player['num'])
            
            players.append(player)
        
    def __parseCoachTags__(self, team, homeAway, coaches, coachTags):
        for coachTag in coachTags:
            coach = self.mapTagWithList(coachTag, GamedayConfig.parser_player_coach)
            coach['team'] = team
            coach['homeAway'] = homeAway
            
            coaches.append(coach)
            