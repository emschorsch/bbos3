from bbos.gameday.parser.parser import Parser
from bbos.config.gamedayConfig import GamedayConfig
import json

class PregumboParser(Parser):
    
    def parse(self, xmlProvider):
        pregumboJSON = xmlProvider.getPregumboJSON()
        if "404 Not Found" in pregumboJSON: return
        
        hitJSONs = json.loads(pregumboJSON)
        if not hitJSONs: return
        
        #['data']['gumbo']['hit_data']['hit']
        if not 'data' in hitJSONs: return
        if not 'gumbo' in hitJSONs['data']: return
        if not 'hit_data' in hitJSONs['data']['gumbo']: return
        if not 'hit' in hitJSONs['data']['gumbo']['hit_data']: return
        
        hits = hitJSONs['data']['gumbo']['hit_data']['hit']
        
        for hit in hits:
            for key in hit:
                if not hit[key]:
                    hit[key] = "0.0"
        
        filtered = self.mapJsonList(hits, GamedayConfig.parser_pregumbo_hit)
                
        self.game.setPregumboHits(filtered)
            