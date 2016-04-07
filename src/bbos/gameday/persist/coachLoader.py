from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class CoachLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".coaches"
    
    def getDataObjects(self, game):
        return game.getCoaches()  
    
    def getFieldsToIgnore(self):
        return ()  
    