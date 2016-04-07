from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class TeamNameLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".teamNames"
    
    def getDataObjects(self, game):
        return game.getTeamNames()  
    
    def getFieldsToIgnore(self):
        return ()  
    