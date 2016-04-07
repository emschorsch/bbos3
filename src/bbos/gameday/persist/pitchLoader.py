from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class PitchLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".pitches"
    
    def getDataObjects(self, game):
        return game.getPitches() 
    
    def getFieldsToIgnore(self):
        return ()