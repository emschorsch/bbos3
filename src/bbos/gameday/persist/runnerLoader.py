from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class RunnerLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".runners"
    
    def getDataObjects(self, game):
        return game.getRunners() 
    
    def getFieldsToIgnore(self):
        return ()
