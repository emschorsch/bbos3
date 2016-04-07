from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class AtbatLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".atbats"
    
    def getDataObjects(self, game):
        return game.getAtbats()  
    
    def getFieldsToIgnore(self):
        return ()