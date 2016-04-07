from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class ActionLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".action"
    
    def getDataObjects(self, game):
        return game.getActions() 
    
    def getFieldsToIgnore(self):
        return () 