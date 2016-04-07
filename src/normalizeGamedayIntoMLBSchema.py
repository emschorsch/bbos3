from bbos.db.db import DB
from bbos.config import loggingSetup
loggingSetup.initializeLogging("normalizeBBOS.py")
import logging
    
def runNormalizeSQL(db):
    sqlFile = "..\\sql\\normalizeGamedayToMLB.sql"
    
    db.run(sqlFile)
    
def runUserDefinedSQL(db):
    sqlFile = "..\\sql\\user.sql"
    
    db.run(sqlFile)
    
def create():
    db = DB()
    
    runNormalizeSQL(db)
    runUserDefinedSQL(db)
    
    
def main():
    create()    
    
if __name__ == '__main__':
    try:
        main()
    except Exception, e:
        logging.info(e.message)
        raise Exception(e)
    
