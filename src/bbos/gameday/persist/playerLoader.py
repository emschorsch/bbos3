from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class PlayerLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".players"
    
    def getDataObjects(self, game):
        return game.getPlayers()  
    
    def getFieldsToIgnore(self):
        return ('avg','hr','rbi','boxname','wins','losses','era')  
    