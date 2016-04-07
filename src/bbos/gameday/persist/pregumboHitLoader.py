from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class PregumboHitLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".pregumboHits"
    
    def getDataObjects(self, game):
        return game.getPregumboHits()
    
    def getFieldsToIgnore(self):
        return ()  
    