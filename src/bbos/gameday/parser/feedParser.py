from bbos.gameday.parser.parser import Parser
from bbos.config.gamedayConfig import GamedayConfig
from regularExpressions import pattern
import json

class FeedParser(Parser):
    
    def parse(self, xmlProvider):
        gamePK = self.game.getGameInfo()['game_pk']
        
        jsonContent = xmlProvider.getFeedJSON(gamePK)
        if "404 Not Found" in jsonContent: return
        
        jsonHash = json.loads(jsonContent)
        if not jsonHash: return
        
        #for item in jsonHash['items'][46]['data']:
        #print jsonHash['items'][46]['id']
        #for item in jsonHash['items'][46]:
        #    print item
        #    print jsonHash['items'][46][item]
            
        if not 'items' in jsonHash: return
        
        #plays = [item['data'] for item in jsonHash['items'] if 'data' in item and 'scoring' in item['data'] and ' mph' in item['data']['description']]
        plays = [item['data'] for item in jsonHash['items'] if 'data' in item and 'description_tracking' in item['data']]
        for play in plays:
            #print play['description_tracking'] 
                
            if ' mph' in play['description_tracking']:
                play['mph'] = pattern.capture("""(\d\d+)\smph""", play['description_tracking'])
                
            if ' feet' in play['description_tracking']:
                play['distance'] = pattern.capture("""(\d\d+)\sfeet""", play['description_tracking']) 
                
            if ' degrees' in play['description_tracking']:
                play['launch_angle'] = pattern.capture("""(\d\d+)\sdegrees""", play['description_tracking'])      
        
        filteredPlays = self.mapJsonList(plays, GamedayConfig.parser_feed_plays)
                            
        self.game.setFeedPlays(filteredPlays)
            
