from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class HitLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".hits"
    
    def getDataObjects(self, game):
        return game.getHits()  
    
    def getFieldsToIgnore(self):
        return ('team',)  
    