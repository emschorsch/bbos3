from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class PlayerBioLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".playerBios"
    
    def getDataObjects(self, game):
        return game.getPlayerBios()  
    
    def getFieldsToIgnore(self):
        return ()  
    