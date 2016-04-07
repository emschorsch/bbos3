from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class BatterLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".batters"
    
    def getDataObjects(self, game):
        return game.getBatters()  
    
    def getFieldsToIgnore(self):
        return ('name', 'avg')  
    