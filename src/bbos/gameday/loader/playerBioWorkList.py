from bbos.gameday.loader.gameLoaderWorkList import GameLoaderWorkList

from bbos.gameday.parser.playerBioParser import PlayerBioParser
from bbos.gameday.persist.playerBioLoader import PlayerBioLoader


class PlayerBioWorkList(GameLoaderWorkList):
    def getParsers(self, game):
        parsers = []
        
        parsers.append(PlayerBioParser(game))
        
        return parsers
            
    def getLoaders(self, db, gameName):
        loaders = []
        
        loaders.append(PlayerBioLoader(db, gameName))
        
        return loaders
            
    def getAlreadyLoadedSQL(self, alreadyLoadedIdentifier):
        statement = "select distinct(gameName) from %s where gameName = '%s';"

        statement = statement % ("gameday.playerBios", alreadyLoadedIdentifier)

        return statement