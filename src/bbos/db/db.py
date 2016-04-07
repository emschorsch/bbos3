#proxy for current DB implementation and provides logging
from bbos.config.bbosConfig import BBOSConfig
from mySQL.mySQLCommand import MySQLCommander
from mySQL.mySQLConnection import MySQLConnection
import logging
from exceptions import Warning, Exception

class DB:
    def __init__(self):
        self.mySQLCommander = MySQLCommander(BBOSConfig.mySQLLocation, BBOSConfig.dbUser, BBOSConfig.dbPass, BBOSConfig.dbHost, BBOSConfig.dbPort)
        self.db = MySQLConnection(BBOSConfig.dbUser, BBOSConfig.dbPass, BBOSConfig.dbHost, BBOSConfig.dbPort, '');
    
    def run(self, sqlFile):
        command = self.mySQLCommander.createMySQLCommand(sqlFile)
        logging.info("running:" + command.getCommand())
        
        self.mySQLCommander.run(command)
        logging.info("complete")
        
    def execute(self, sql):
        self.logStatement(sql)
        
        try:
            self.db.execute(sql)
        except Warning, w:
            raise SQLException(w)
        except Exception, e:
            raise SQLException(e)
        
    def logStatement(self, sql):
        logging.debug("BEGIN mySQL Statement:\n  %s\nEND Statement" % (sql))
    
    def select(self, sql):
        self.logStatement(sql)
        
        return self.db.select(sql)


class SQLException(Exception):
    def __init__(self, value):
        self.value = value
    
    def __str__(self):
        return repr(self.value)