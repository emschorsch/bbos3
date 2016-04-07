from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class GameDetailLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".gameDetail"
    
    def getDataObjects(self, game):
        return (game.getGameDetail(), )  
    
    def getFieldsToIgnore(self):
        return ()  
