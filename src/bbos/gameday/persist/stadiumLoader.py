from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class StadiumLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".Stadiums"
    
    def getDataObjects(self, game):
        return (game.getStadium(),)
    
    def getFieldsToIgnore(self):
        return ()  
