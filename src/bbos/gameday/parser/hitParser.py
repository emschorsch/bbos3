from bbos.gameday.parser.parser import Parser
from bbos.config.gamedayConfig import GamedayConfig

class HitParser(Parser):
    
    def parse(self, xmlProvider):
        hitXML = xmlProvider.getHitXML()
        
        doc = self.createDocument(hitXML)
        if not doc: return
        
        hitTags = doc.getElementsByTagName('hip')
        
        hits = []
        
        for tag in hitTags:
            hit = self.mapTagWithList(tag, GamedayConfig.parser_hit_hit)
            
            if not 'y' in hit: hit['y'] = '0'
            if not 'x' in hit: hit['x'] = '0'
            
            hits.append(hit)
            
        self.game.setHits(hits)
            