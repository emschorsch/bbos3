from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class GameConditionsLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".gameConditions"
    
    def getDataObjects(self, game):
        return (game.getGameConditions(), ) 
    
    def getFieldsToIgnore(self):
        return ()  
    