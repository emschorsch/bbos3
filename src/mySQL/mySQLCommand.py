import os
import subprocess

class MySQLCommander:
    
    def __init__(self, mySQLlocation, user = None, password = None, host = None, port = None):
        self.locationOfMySQL = "\""+ mySQLlocation + os.sep + """mysql.exe" """ 
        
        if (len(host) > 0):
            self.locationOfMySQL = self.locationOfMySQL + " -h " + host
        if (port > 0):
            self.locationOfMySQL = self.locationOfMySQL + " -P " + str(port)
        if (len(user) > 0):
            self.locationOfMySQL = self.locationOfMySQL + " -u " + user
        if (len(password) > 0):
            # No space after -p per MySQL
            self.locationOfMySQL = self.locationOfMySQL + " -p" + password
        
    def createMySQLCommand(self, sqlFile):
        command = MySQLCommand(self.locationOfMySQL, sqlFile)
        
        return command
    
    def run(self, command):
        subprocess.Popen(command.getCommand())
        

class MySQLCommand:
    def __init__(self, locationOfMySQL, sqlFile):
        self.command = locationOfMySQL + """ -e "source """ + sqlFile + '"'

    def getCommand(self):
        return self.command