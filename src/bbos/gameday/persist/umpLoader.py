from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class UmpLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".umpires"
    
    def getDataObjects(self, game):
        return game.getUmps()  
    
    def getFieldsToIgnore(self):
        return ()  
    