from bbos.test.fTest import FTest
from bbos.gameday.www.gameXMLProvider import GamedayXMLProvider
import xml.dom.minidom

class GameXMLProviderFTest(FTest):
    
    def setUp(self):
        url = "http://gd2.mlb.com/components/game/mlb/year_2008/month_09/day_24/gid_2008_09_24_pitmlb_milmlb_1/"
        
        self.xmlProvider = GamedayXMLProvider(url)
            
    def testGetHitXML(self):
        hitXML = self.xmlProvider.getHitXML()

        doc = xml.dom.minidom.parseString(hitXML)
        
        elements = doc.getElementsByTagName('hip')
        
        self.assertEqual(41, len(elements))      
              
    def testGetInningXMLs(self):
        inningXMLs = self.xmlProvider.getInningXMLs()
        
        self.assertEqual(9, len(inningXMLs))

        firstInning = inningXMLs[0]
        
        doc = xml.dom.minidom.parseString(firstInning)
        
        top = doc.getElementsByTagName('top')
        firstAndOnlyTop = top[0]
        atbats = firstAndOnlyTop.getElementsByTagName('atbat')
        
        self.assertEqual(6, len(atbats)) 
               
    def testGetInningXMLs_ExtraInnings(self):
        url = "http://gd2.mlb.com/components/game/mlb/year_2011/month_04/day_23/gid_2011_04_23_houmlb_milmlb_1/"
        
        self.xmlProvider = GamedayXMLProvider(url)
        
        inningXMLs = self.xmlProvider.getInningXMLs()
        
        self.assertEqual(10, len(inningXMLs))

        _10thInningXML = inningXMLs[9]
        
        found = str(_10thInningXML).find('inning num="10"')
        self.assertTrue(found > 0)
               
    def testGetGameXML(self):
        xmlContent = self.xmlProvider.getGameXML()

        doc = xml.dom.minidom.parseString(xmlContent)
        
        elements = doc.getElementsByTagName('team')
        
        self.assertEqual(2, len(elements)) 
               
    def testGetPlayerXML(self):
        xmlContent = self.xmlProvider.getPlayerXML()

        doc = xml.dom.minidom.parseString(xmlContent)
        
        elements = doc.getElementsByTagName('team')
        
        self.assertEqual(2, len(elements))   
                     
    def testPlayerBIOXMLs(self):
        playerXMLs = self.xmlProvider.getPlayerBIOXMLs()
        
        self.assertEqual(83+42, len(playerXMLs))

        firstBIO = playerXMLs[0]
        
        doc = xml.dom.minidom.parseString(firstBIO)
        
        top = doc.getElementsByTagName('Player')
        firstAndOnlyPlayer = top[0]
        name = firstAndOnlyPlayer.getAttribute('first_name')
        
        self.assertEqual("Mike", name) 
               
    def testGetGameName(self):
        gameName = self.xmlProvider.getGameName()

        self.assertEqual("gid_2008_09_24_pitmlb_milmlb_1", gameName) 
        
        