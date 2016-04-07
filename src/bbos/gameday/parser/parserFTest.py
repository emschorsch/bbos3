from bbos.test.fTest import FTest
from bbos.gameday.www.gameXMLProvider import GamedayXMLProvider
import xml.dom.minidom
from bbos.gameday.parser.parser import Parser

class tagMapperFTest(FTest):
    
    def setUp(self):
        url = "http://gd2.mlb.com/components/game/mlb/year_2008/month_09/day_24/gid_2008_09_24_pitmlb_milmlb_1/"
        
        xmlProvider = GamedayXMLProvider(url)
            
        hitXML = xmlProvider.getHitXML()

        doc = xml.dom.minidom.parseString(hitXML)
        
        self.elements = doc.getElementsByTagName('hip')
            
    def testMapTag(self):
        firstHit = self.elements[0]
        
        parser = Parser(None)
        
        firstHitMap = parser.mapTag(firstHit)    
        
        self.assertEqual(firstHit.getAttribute('des'), firstHitMap['des'])
