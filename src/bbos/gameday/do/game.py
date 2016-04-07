

class Game:
    def __init__(self):
        self.umps = []
        self.gameInfo = {}
        self.teams = []
        self.stadium = {}
        self.batters = []
        self.pitchers = []
        self.teamNames = []
        self.hits = []
        self.pregumboHits = []
        self.feedPlays = []
        self.players = []
        self.playerBios = []
        self.runners = []
        self.coaches = []
        self.gameConditions = {}
        self.gameDetail = {}

    def setGameName(self, gameName):
        self.gameName = gameName   
        
    def getGameName(self):
        return self.gameName
    
    def setGameDetail(self, gameDetail):
        self.gameDetail = gameDetail   
        
    def getGameDetail(self):
        return self.gameDetail
    
    def setTeamNames(self, teamNames):
        self.teamNames = teamNames   
        
    def getTeamNames(self):
        return self.teamNames
    
    def setGameConditions(self, gameConditions):
        self.gameConditions = gameConditions   
        
    def getGameConditions(self):
        return self.gameConditions
    
    def setPitchers(self, pitchers):
        self.pitchers = pitchers  
        
    def getPitchers(self):
        return self.pitchers
    
    def setBatters(self, batters):
        self.batters = batters   
        
    def getBatters(self):
        return self.batters
    
    def setTeams(self, teams):
        self.teams = teams   
        
    def getTeams(self):
        return self.teams
    
    def setStadium(self, stadium):
        self.stadium = stadium   
        
    def getStadium(self):
        return self.stadium
    
    def setGameInfo(self, gameInfo):
        self.gameInfo = gameInfo   
        
    def getGameInfo(self):
        return self.gameInfo
    
    def setHits(self, hits):
        self.hits = hits
    
    def setPregumboHits(self, pregumboHits):
        self.pregumboHits = pregumboHits
    
    def setFeedPlays(self, feedPlays):
        self.feedPlays = feedPlays
    
    def setAtbats(self, atbats):
        self.atbats = atbats
    
    def setPitches(self, pitches):
        self.pitches = pitches
    
    def setActions(self, actions):
        self.actions = actions 
    
    def setPlayers(self, players):
        self.players = players 
    
    def setPlayerBios(self, playerBios):
        self.playerBios = playerBios 
    
    def setUmps(self, umps):
        self.umps = umps 
    
    def setCoaches(self, coaches):
        self.coaches = coaches   
        
    def setRunners(self, runners):
        self.runners = runners
        
    def getHits(self):
        return self.hits
    
    def getPregumboHits(self):
        return self.pregumboHits
    
    def getFeedPlays(self):
        return self.feedPlays
    
    def getAtbats(self):
        return self.atbats
    
    def getPitches(self):
        return self.pitches
    
    def getActions(self):
        return self.actions
    
    def getPlayers(self):
        return self.players
    
    def getPlayerBios(self):
        return self.playerBios
    
    def getUmps(self):
        return self.umps
    
    def getCoaches(self):
        return self.coaches
    
    def getRunners(self):
        return self.runners
    