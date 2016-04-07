class GameLoaderWorkList:
                
    def getParsers(self, game):
        raise NotImplementedError
    
    def getLoaders(self, db, gameName):
        raise NotImplementedError
    
    def getAlreadyLoadedSQL(self, alreadyLoadedIdentifier):
        raise NotImplementedError