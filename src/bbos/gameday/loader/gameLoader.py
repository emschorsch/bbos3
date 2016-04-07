from bbos.gameday.do.game import Game


class GamedayGameLoader:
    def __init__(self, db, xmlProvider, gameLoaderWorkList):
        self.db = db
        self.xmlProvider = xmlProvider
        self.gameName = xmlProvider.getGameName()
        self.gameLoaderWorkList = gameLoaderWorkList
    
    def loadGame(self):
        game = self.__parseGame__()
        
        self.__load__(game)
    
    def __parseGame__(self):
        game = Game()
        game.setGameName(self.gameName)
        
        parsers = self.__getParsers__(game)
        
        for parser in parsers:
            parser.parse(self.xmlProvider)
        
        return game
    
    def __getParsers__(self, game):
        parsers = self.gameLoaderWorkList.getParsers(game)
        
        return parsers
            
    def __load__(self, game):
        loaders = self.__getLoaders__()
        
        for loader in loaders:
            loader.load(game)
        
    def __getLoaders__(self):
        loaders = self.gameLoaderWorkList.getLoaders(self.db, self.gameName)
        
        return loaders
    
    def delete(self):
        loaders = self.__getLoaders__()
        
        for loader in loaders:
            loader.delete(self.gameName)
            
    def isAlreadyLoaded(self):
        statement = self.gameLoaderWorkList.getAlreadyLoadedSQL(self.gameName)

        results = self.db.select(statement)
        
        isEmpty = results != None and len(results) > 0
        
        return isEmpty