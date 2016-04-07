from bbos.config.bbosConfig import BBOSConfig
import osandio.log
import logging

def initializeLogging(scriptName):
    osandio.log.init(BBOSConfig.logLocation, scriptName, BBOSConfig.logScreenPrintingLogLevel)
    logging.info("")
    logging.info("Starting bbos!")