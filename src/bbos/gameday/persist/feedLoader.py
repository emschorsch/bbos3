from bbos.gameday.persist.loader import Loader
from bbos.config.bbosConfig import BBOSConfig

class FeedLoader(Loader):

    def getTableName(self):
        return BBOSConfig.dbName+".feedPlays"
    
    def getDataObjects(self, game):
        return game.getFeedPlays()
    
    def getFieldsToIgnore(self):
        return ()  
    