from bbos.db.db import SQLException
import logging
from regularExpressions import pattern

class Loader:
    def __init__(self, db, gameName):
        self.db = db
        self.gameName = gameName

    def getTableName(self):
        raise NotImplementedError
    
    def getDataObjects(self):
        raise NotImplementedError
    
    def getFieldsToIgnore(self):
        raise NotImplementedError
    
    def load(self, game):
        dataObjects = self.getDataObjects(game)
        
        for do in dataObjects:
            self.__loadDO__(do)
            
    def __loadDO__(self, do):
        statement = self.__createInsertStatement__(do)
        
        try:
            self.db.execute(statement)
        except SQLException, e:
            self.__logException__(e, statement)
    
    def __logException__(self, e, statement):
        if pattern.match("Duplicate", str(e)):
            logging.debug("Duplicate row cause by sql: " + statement)
        else:
            logging.info("unable to execute: " + statement)
            import StringIO
            output = StringIO.StringIO()
            import traceback
            traceback.print_exc(file=output)
            logging.info("due to: " + str(e))
            logging.info(output.getvalue())
            logging.info("resuming")
            logging.error(self.gameName)
            
    def __createInsertStatement__(self, do):
        #print do
        statement = "INSERT into " + self.getTableName() + " (gameName """
        
        self.__removeFieldsToIgnore__(do)
        
        for field in do.keys():
            statement = statement + ', ' + field
             
        statement = statement + ') VALUES ("' + self.gameName + '"'
        
        for field in do.keys():
            statement = statement + ', "' + str(do[field]) + '"'
        
        statement = statement + ');'
        
        return statement
    
    def __removeFieldsToIgnore__(self, do):
        for fieldToIgnore in self.getFieldsToIgnore():
            if do.has_key(fieldToIgnore):
                del do[fieldToIgnore]
                
        return do
        
    def delete(self, gameName):
        statement = "delete from %s where gameName = '%s';"
        
        statement = statement % (self.getTableName(), self.gameName)
        
        self.db.execute(statement)