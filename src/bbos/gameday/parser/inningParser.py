from bbos.gameday.parser.parser import Parser
from bbos.config.gamedayConfig import GamedayConfig

import unicodedata
            
class InningParser(Parser):
    
    def parse(self, xmlProvider):
        self.eventNumber = 0
        
        inningXMLs = xmlProvider.getInningXMLs()
        
        self.atbats = []
        self.actions = []
        self.pitches = []
        self.runners = []
        
        for xml in inningXMLs:
            self.__parse__(xml) 
            
        self.game.setAtbats(self.atbats)
        self.game.setActions(self.actions)
        self.game.setPitches(self.pitches)
        self.game.setRunners(self.runners)
    
    def __parse__(self, inningXML):
        doc = self.createDocument(inningXML)
        if doc == None: return
        
        self.__parseHalfInning__(doc, 'top')
        
        self.__parseHalfInning__(doc, 'bottom')
        
    def __parseHalfInning__(self, doc, halfInning):
        halfInningTags = doc.getElementsByTagName(halfInning)
        
        if not len(halfInningTags): return
        
        halfInningTag = halfInningTags[0]
        
        self.__parseHalfInningTag__(halfInningTag)
           
    def __parseHalfInningTag__(self, halfInningTag):
        childTags = halfInningTag.childNodes
        
        for actionOrAtBat in childTags:
            if actionOrAtBat.tagName == 'action':
                self.__parseActionTag__(actionOrAtBat, childTags)
            elif actionOrAtBat.tagName == 'atbat':
                self.__parseAtbatTag__(actionOrAtBat)
    
    def __parseActionTag__(self, tag, allTags):
        action = self.mapTagWithList(tag, GamedayConfig.parser_inning_action)
        
        atBatID = self.__getAtbatNumFollowingAction__(tag, allTags)
        action['atbatNum'] = atBatID
        
        halfInning = tag.parentNode.tagName
        action['halfInning'] = halfInning
        
        inning = tag.parentNode.parentNode.getAttribute("num")
        action['inning'] = inning
        
        eventNumber = self.getEventNumber()
        action['eventNumber'] = eventNumber

        if 's' in action:
            action['s'] = action['s'][-1]

        self.actions.append(action)
    
    def __getAtbatNumFollowingAction__(self, tag, allTags):
        spotOfTag = allTags.index(tag)
        
        associatedAtbatTag = self.__getFirstAtBatTag__(allTags[spotOfTag:])
        
        if not (associatedAtbatTag):
            associatedAtbatTag = self.__getLastAtbatTag__(allTags[:spotOfTag])
        
        if (associatedAtbatTag):
            return associatedAtbatTag.getAttribute('num')
        
        return "0"
    
    def __getLastAtbatTag__(self, allTags):
        reversedTagList = list(allTags)
        reversedTagList.reverse(
                                )
        for actionOrAtBat in reversedTagList:
            if actionOrAtBat.tagName == 'atbat':
                return actionOrAtBat        
    
    def __getFirstAtBatTag__(self, allTags):
        for actionOrAtBat in allTags:
            if actionOrAtBat.tagName == 'atbat':
                return actionOrAtBat
              
    def __parseAtbatTag__(self, tag):
        self.__storeAtbatTag__(tag)
        
        pitchTags = self.__getPitchTagsForAtbatTag__(tag)
        
        for pitchTag in pitchTags:
            self.__storePitchTag__(pitchTag)
            
        runnerTags = self.__getRunnerTagsForAtbatTag__(tag)
            
        for runnerTag in runnerTags:
            self.__storeRunnerTag__(runnerTag)
        
    def getEventNumber(self):
        self.eventNumber += 1
        
        return str(self.eventNumber)
    
    def __storeAtbatTag__(self, tag):
        atbat = self.mapTagWithList(tag, GamedayConfig.parser_inning_atbat)
        
        """<atbat num="54" b="4" s="0" o="0" 
        batter="112736" stand="L" b_height="6-0" pitcher="429714" 
        p_throws="R" des="Craig Counsell walks.  " event="Walk">"""
        
        halfInning = tag.parentNode.tagName
        atbat['halfInning'] = halfInning
        
        inning = tag.parentNode.parentNode.getAttribute("num")
        atbat['inning'] = inning
        
        if 's' in atbat:
            atbat['s'] = atbat['s'][-1]

        eventNumber = self.getEventNumber()
        atbat['eventNumber'] = eventNumber

        if 'pitcher' in atbat and atbat['pitcher'] == 'null':
            del(atbat['pitcher'])

        if 'batter' in atbat and atbat['batter'] == 'null':
            del(atbat['batter'])
        
        if 'des' in atbat:
            atbat['des'] = unicodedata.normalize('NFKD', atbat['des']).encode('ascii', 'ignore')
        if 'des_es' in atbat: 
            atbat['des_es'] = unicodedata.normalize('NFKD', atbat['des_es']).encode('ascii', 'ignore')
                
        self.atbats.append(atbat)   
    
    def __getPitchTagsForAtbatTag__(self, atbatTag):
        pitchTags = atbatTag.getElementsByTagName('pitch')
        
        return pitchTags
    
    def __storePitchTag__(self, tag):
        pitch = self.mapTagWithList(tag, GamedayConfig.parser_inning_pitch)
        
        """<pitch des="Ball" id="421" type="B" x="140.77" y="150.24" 
        sv_id="080924_210844" start_speed="95.1" end_speed="87.0" 
        sz_top="3.27" sz_bot="1.589" pfx_x="-4.645" pfx_z="10.308" 
        px="-1.183" pz="2.574" x0="-1.707" y0="50.0" z0="6.016" 
        vx0="3.089" vy0="-139.2" vz0="-7.242" ax="-9.052" 
        ay="33.248" az="-12.012" break_y="23.8" break_angle="31.3" 
        break_length="3.3" pitch_type="FA" 
        type_confidence="1.3222562289736057"/>"""
        
        atbatID = tag.parentNode.getAttribute('num')
        pitch['gameAtBatID'] = atbatID
        pitchTime = tag.getAttribute('sv_id')
        if pitchTime:
            pitch['sv_id'] = self.__getPitchTime__(pitchTime)

        if 'pitch_type' in pitch:
            pitch['pitch_type'] = pitch['pitch_type'].strip()
        
        if 'x' in pitch and pitch['x'] == "":
            del(pitch['x'])

        if 'y' in pitch and pitch['y'] == "":
            del(pitch['y'])

        if 'cc' in pitch:
            pitch['cc'] = unicodedata.normalize('NFKD', pitch['cc']).encode('ascii', 'ignore')
            
        if 'mt' in pitch:
            pitch['mt'] = unicodedata.normalize('NFKD', pitch['mt']).encode('ascii', 'ignore')
            
        self.pitches.append(pitch)
    
    def __getPitchTime__(self, pitchTime):
        #sv_id="080710_203923"
        
        if len(pitchTime) < 13:
            return '0:0:0'
        
        hour = pitchTime[7:9]
        min = pitchTime[9:11]
        sec = pitchTime[11:13]
        
        pitchTime = "%s:%s:%s" % (hour, min, sec)
        
        return pitchTime
        
    def __getRunnerTagsForAtbatTag__(self, atbatTag):
        runnerTags = atbatTag.getElementsByTagName('runner')
            
        return runnerTags
        
    def __storeRunnerTag__(self, tag):
        runner = self.mapTagWithList(tag, GamedayConfig.parser_inning_runner)

        """<runner id="407833" start="" end="1B" 
        event="Hit By Pitch"/>"""

        atbatID = tag.parentNode.getAttribute('num')
        runner['gameAtBatID'] = atbatID
            
        self.runners.append(runner)    