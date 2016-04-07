import pymysql

class MySQLConnection:
    def __init__(self, user, password, host, port, database):
        self.conn = pymysql.connect(host=host, port=port, user=user, passwd=password, db=database)
        self.cursor = None
        
    def __del__(self):
        self.conn.close()
        
    def getcursor(self):
        self.cursor = self.conn.cursor();
        return self.cursor
    
    def closecursor(self):
        if self.cursor: self.cursor.close()
        del(self.cursor)
        
    def commit(self):
        self.closecursor()
        self.conn.commit()
    
    def execute(self, statement):
        self.getcursor().execute(statement)
        
        self.commit()
    
    def select(self, statement):
        cursor = self.getcursor()
        
        cursor.execute(statement)
        
        rows = cursor.fetchall()
        
        cursor.close()
        
        return rows    