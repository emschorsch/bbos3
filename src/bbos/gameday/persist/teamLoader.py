from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class TeamLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".Teams"
    
    def getDataObjects(self, game):
        return game.getTeams()  
    
    def getFieldsToIgnore(self):
        return ()  
    