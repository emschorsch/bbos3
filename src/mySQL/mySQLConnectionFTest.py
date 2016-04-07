from bbos.test.fTest import FTest
from bbos.db.db import DB
from bbos.db.db import SQLException
            

class mySQLConnectionFTest(FTest):
    
    def setUp(self):
        self.db = DB();
        
    def testLoad_SQLError(self):
        statement = """INSERT blah blah blah into gameday.atbats (gameName , inning, b, eventNumber, des, pitcher, o, s, num, batter, stand, event, halfInning) VALUES ("gid_2007_04_12_anamlb_clemlb_1", "2", "0", "7", "Garret Anderson grounds out, first baseman Casey Blake to pitcher Jeremy Sowers.  ", "460265", "1", "2", "7", "110236", "L", "Ground Out", "top");"""
        
        try:
            self.db.execute(statement)
            
            self.fail("bad SQL should throw")
        except SQLException:
            pass
        
              
                   
    def testLoad_SQLWarning(self):
        statement = """INSERT into gameday.gameConditions (gameName , windMPH, temperature, attendence, gameLength, forecast, windDirection) VALUES ("gid_2007_04_12_seamlb_bosmlb_1", "299999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999996", "38", "", "", "rain", "Out to LF");"""
    
        try: 
            self.db.execute(statement)
            
            self.fail("bad SQL should throw truncate column size warning")
        except SQLException:
            pass   
              

        
        