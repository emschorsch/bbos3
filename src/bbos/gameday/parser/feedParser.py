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
        
        #for item in jsonHash['items']:
            #print item
            #print "\n\n"
        #for item in jsonHash['items'][46]:
        #    print item
        #    print jsonHash['items'][46][item]
            
        if not 'items' in jsonHash: return
        
        #plays = [item['data'] for item in jsonHash['items'] if 'data' in item and 'scoring' in item['data'] and ' mph' in item['data']['description']]
        items = [item for item in jsonHash['items'] if 'data' in item and 'description_tracking' in item['data']]
        for item in items:
            #print play['description_tracking']
            
            play = item['data'] 
                
            if 'description' in play:
                item['description'] = play['description']
                
            if 'result' in play:
                item['result'] = play['result']
                
            if 'player_id' in play:
                item['player_id'] = play['player_id']
                
            if ' mph' in play['description_tracking']:
                item['mph'] = pattern.capture("""(\d\d+)\smph""", play['description_tracking'])
                
            if ' feet' in play['description_tracking']:
                item['distance'] = pattern.capture("""(\d\d+)\sfeet""", play['description_tracking']) 
                
            if ' degrees' in play['description_tracking']:
                item['launch_angle'] = pattern.capture("""(\d\d+)\sdegrees""", play['description_tracking'])      
        
        filteredPlays = self.mapJsonList(items, GamedayConfig.parser_feed_plays)
                            
        self.game.setFeedPlays(filteredPlays)
            
