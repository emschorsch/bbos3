from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class PitcherLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".pitchers"
    
    def getDataObjects(self, game):
        return game.getPitchers()  
    
    def getFieldsToIgnore(self):
        return ('name', 'era')  
    