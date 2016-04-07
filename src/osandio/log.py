import os
import logging

f = logging.Formatter("%(levelname)s %(asctime)s %(threadName)s %(module)s.%(funcName)s.%(lineno)d %(message)s")
        
def init(logDir, scriptName, screenPrintingLogLevel):
    fileName = logDir + os.sep + scriptName + ".log"
    
    logging.basicConfig(level=logging.DEBUG,
                    format='%(levelname)s %(asctime)s %(threadName)s %(module)s.%(funcName)s.%(lineno)d %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    filename=fileName,
                    filemode='w')
        
    # This handler writes everything above INFO to the screen.
    console = logging.StreamHandler()
    console.setLevel(screenPrintingLogLevel)
    console.setFormatter(f)
    
    
    logging.getLogger('').addHandler(console)
    
    logging.info('\nLogging to ' + fileName)
    
    initErrorLog(logDir, scriptName)

def initErrorLog(logDir, fileName):
    fileName = logDir + os.sep + fileName + ".err.log"
        
    fh = logging.FileHandler(fileName, 'w')
    fh.setLevel(logging.ERROR)
    fh.setFormatter(f)
    
    logging.getLogger('').addHandler(fh)
            