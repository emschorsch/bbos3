from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class GameLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".Games"
    
    def getDataObjects(self, game):
        return (game.getGameInfo(), )  
    
    def getFieldsToIgnore(self):
        return ()  
