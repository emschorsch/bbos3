from bbos.gameday.parser.parser import Parser
from bbos.config.gamedayConfig import GamedayConfig
    
class PlayerBioParser(Parser):
    
    def parse(self, xmlProvider):
        playerBioXMLs = xmlProvider.getPlayerBIOXMLs()
        
        self.playerBios = []
        
        for xml in playerBioXMLs:
            self.__parse__(xml) 
            
        self.game.setPlayerBios(self.playerBios)
    
    def __parse__(self, playerBioXML):
        doc = self.createDocument(playerBioXML)
        if doc == None: return

        playerTags = doc.getElementsByTagName('Player')
        
        if not len(playerTags): return
        
        playerTag = playerTags[0]
        
        self.__parsePlayerTag__(playerTag)
           
    def __parsePlayerTag__(self, playerTag):
        playerBio = self.mapTagWithList(playerTag, GamedayConfig.parser_playerbio_player)
        
        if 'height' in playerBio.keys():
            playerHasHeight = ('height' in playerBio) and (len(playerBio['height']) != 0)
            playerHeightNotNull = "null" != playerBio['height']
        
            if playerHasHeight and playerHeightNotNull:
                (feet, inches) = playerBio['height'].split('-')
                playerBio['heightFeet'] = feet
                playerBio['heightInches'] = inches
            
            del playerBio['height']                
            
        self.playerBios.append(playerBio)
            
            
"""
<Player team="mil" id="122195" pos="P" type="pitcher" first_name="Brian" last_name="Shouse" jersey_number="51" height="5-10" weight="195" bats="L" throws="L" dob="09/26/1968">
<season avg=".236" ab="191" hr="5" bb="14" so="33" w="5" l="1" sv="2"/>
<career avg=".246" ab="1227" hr="26" bb="111" so="216" w="12" l="9" sv="6"/>
<Month des="Sept." avg=".294" ab="17" hr="1" bb="1" so="1"/>
<Team des="Home" avg=".165" ab="97" hr="0" bb="9" so="20"/>
<Empty avg=".220" ab="91" hr="1" bb="4" so="16"/>
<Men_On avg=".250" ab="100" hr="4" bb="10" so="17"/>
<RISP avg=".271" ab="70" hr="3" bb="9" so="12"/>
<Loaded avg=".250" ab="8" hr="0" bb="1" so="0"/>
<vs_LHB avg=".173" ab="98" hr="2" bb="2" so="28"/>
<vs_RHB avg=".301" ab="93" hr="3" bb="12" so="5"/>
<vs_B des="451188" avg=".000" ab="0" hr="0" bb="0" so="0"/>
</Player>"""