from bbos.test.fTest import FTest
from bbos.db.db import DB
import logging

class DBFTest(FTest):
    
    def setUp(self):
        self.db = DB();
        
    def testConnection(self):
        logging.info( "connected!" )
        
    def testSelect(self):
        sql = "select * from information_schema.character_sets"
        
        results = self.db.select(sql)
            
        self.assertTrue(len(results) > 0)      
    
        logging.info( "selected!" )
        
        