#!/usr/bin/env python
import urllib
import urllib2
import os
import subprocess
import threading
import Queue
import glob
from osandio.fileCompression import Unzipper
from bbos.config.bbosConfig import BBOSConfig
import tempfile
import re
import time
import sqlalchemy
import csv
import logging
from bbos.config import loggingSetup
from bbos.retrosheet.options import commandLineOptionsParser
loggingSetup.initializeLogging("bbosRetrosheet.py")
    
logging.info("Starting bbosRetrosheet!")

THREADS = 20
RETROSHEET_URL = BBOSConfig.retrosheetURL
CHADWICK = os.path.abspath(BBOSConfig.pathToChadwick)
ENGINE = BBOSConfig.sqlAlchemyEngine
HOST = BBOSConfig.sqlAlchemyHost
DATABASE = BBOSConfig.sqlAlchemyDatabase   
USER = None if not BBOSConfig.sqlAlchemyUser else BBOSConfig.sqlAlchemyUser
SCHEMA = None if not BBOSConfig.sqlAlchemySchema else BBOSConfig.sqlAlchemySchema
PASSWORD = None if not BBOSConfig.sqlAlchemyPassword else BBOSConfig.sqlAlchemyPassword

if USER and PASSWORD: string = '%s://%s:%s@%s/%s' % (ENGINE, USER, PASSWORD, HOST, DATABASE)
else:  string = '%s://%s/%s' % (ENGINE, HOST, DATABASE)

try:
    logging.info("connecting:"+string)
    db = sqlalchemy.create_engine(string)
    conn = db.connect()
except:
    import StringIO
    output = StringIO.StringIO()
    import traceback
    traceback.print_exc(file=output)
    logging.info(output.getvalue())
    raise


if SCHEMA: conn.execute('SET search_path TO %s' % SCHEMA)


class Parser(threading.Thread):
    def __init__(self, queue):
        threading.Thread.__init__(self)
        self.queue = queue

    def run(self):
        while 1:
            try: year = self.queue.get_nowait()
            except Queue.Empty: break;

            fill = "%s"+os.sep+"cwevent -q -n -f 0-96 -x 0-62 -y %d %d*.EV* > events-%d.csv"
            cmd = fill % (CHADWICK, year, year, year)
            logging.info("running:"+cmd)
            subprocess.call(cmd, shell=True)
            fill = "%s"+os.sep+"cwgame -q -n -f 0-83 -y %d %d*.EV* > games-%d.csv"
            cmd = fill % (CHADWICK, year, year, year)
            logging.info("running:"+cmd)
            subprocess.call(cmd, shell=True)
            fill = "%s"+os.sep+"cwcomment -q -f 0-2 -y %d %d*.EV* > comment-%d.csv"
            cmd = fill % (CHADWICK, year, year, year)
            logging.info("running:"+cmd)
            subprocess.call(cmd, shell=True)

            #for fileName in glob.glob("%d*" % year): os.remove(fileName)


class Fetcher(threading.Thread):
    def __init__(self, queue, path):
        threading.Thread.__init__(self)
        self.queue = queue
        self.path = path

    def run(self):
        while 1:
            try: url = self.queue.get_nowait()
            except Queue.Empty: break;

            fill = "%s"+os.sep+"%s"
            f = fill % (self.path, os.path.basename(url))
            logging.info("retrieving:"+url+" to:"+f)
            
            try:
                urllib2.urlopen(url)
            except urllib2.HTTPError:
                logging.info("did not exist:"+url)
                continue
            
            urllib.urlretrieve(url, f)
            
            if (f[-3:] == "zip"):
                logging.info("unzipping:"+f+" to:"+self.path)
            
                unzipper = Unzipper(BBOSConfig.unzipController)
                unzipper.unzip(f, self.path)
                #zip = zipfile.ZipFile(f, "r")
                #zip.extractall(self.path)

            #os.remove(f)

def findFiles(pattern):
    logging.info("finding:"+pattern)
    results = glob.glob(pattern)
    return results
    
start = time.time()
path = tempfile.mkdtemp()
os.chdir(path)
logging.info("using temp dir:" + path)





options = commandLineOptionsParser.parseOptions()

logging.info("fetching retrosheet files...")
queue = Queue.Queue()
pattern = r'(\d{4}?)eve\.zip'

if (options.year):
    url = 'http://www.retrosheet.org/events/%seve.zip' % options.year
    queue.put(url)
else:
    endScriptMessage = "You must specify a year to use the retrosheet load script.  Run retrosheet.py -h for usage."
    logging.fatal(endScriptMessage)
    raise Exception(endScriptMessage)

threads = []
for i in range(THREADS):
    t = Fetcher(queue, path)
    t.start()
    threads.append(t)

# finish fetching before processing events into CSV
for thread in threads: thread.join()

logging.info("processing game files...")
queue = Queue.Queue()

years = []
threads = []
eventFiles = findFiles("*.EV*")
for fileName in eventFiles:
    logging.info("processing event file:"+fileName)
    year = re.search(r"^\d{4}", os.path.basename(fileName)).group(0)
    if year not in years:
        queue.put(int(year))
        years.append(year)

for i in range(THREADS):
    t = Parser(queue)
    t.start()
    threads.append(t)

# finishing processing games before processing rosters
for thread in threads: thread.join()

logging.info("processing rosters...")
rosterFiles = findFiles("*.ros*")
if "MASTDEB.ROS" in rosterFiles: rosterFiles.remove("MASTDEB.ROS")
for fileName in rosterFiles:
    fullFileName = os.path.basename(fileName)
    logging.info("roster:"+fullFileName)
    f = open(fileName, "r")

    team, year = re.findall(r"(^\w{3})(\d{4}).+?$", fullFileName)[0]
    for line in f.readlines():

        if line.strip() == "": continue

        info = line.strip().replace('"', '').split(",")

        info.insert(0, team)
        info.insert(0, year)

        # wacky '\x1a' ASCII characters, probably some better way of handling this
        if len(info) == 3: continue

        # ROSTERS table has nine columns, let's fill it out
        if len(info) < 9:
            for i in range (9 - len(info)): info.append(None)

        sql = "INSERT INTO rosters VALUES (%s)" % ", ".join(["%s"] * len(info))
        logging.debug(sql)
        logging.debug(info)
        conn.execute(sql, info)

logging.info("processing teams...")
teamFiles = findFiles("TEAM*")
for fileName in teamFiles:
    f = open(fileName, "r")

    try: year = re.findall(r"^TEAM(\d{4})$", os.path.basename(fileName))[0]
    except: continue

    for line in f.readlines():

        if line.strip() == "": continue

        info = line.strip().replace('"', '').split(",")
        info.insert(0, year)

        if len(info) < 5: continue

        sql = "INSERT INTO teams VALUES (%s)" % ", ".join(["%s"] * len(info))
        logging.debug(sql)
        logging.debug(info)
        conn.execute(sql, info)


eventCSVFiles = findFiles("events-*.csv")
for fileName in eventCSVFiles:
    logging.info("processing %s" % fileName)
    reader = csv.reader(open(fileName))
    headers = reader.next()
    for row in reader:
        sql = 'INSERT INTO events(%s) VALUES(%s)' % (','.join(headers), ','.join(['%s'] * len(headers)))
        logging.debug(sql)
        logging.debug(row)
        conn.execute(sql, row)

gameCSVFiles = findFiles("games-*.csv")
for fileName in gameCSVFiles:
    logging.info("processing %s" % fileName)
    reader = csv.reader(open(fileName))
    headers = reader.next()
    for row in reader:
        sql = 'INSERT INTO games(%s) VALUES(%s)' % (','.join(headers), ','.join(['%s'] * len(headers)))
        logging.debug(sql)
        logging.debug(row)
        conn.execute(sql, row)

commentCSVFiles = findFiles("comment-*.csv")
for fileName in commentCSVFiles:
    logging.info("processing %s" % fileName)
    reader = csv.reader(open(fileName))
    headers = ["GAME_ID", "EVENT_ID", "COMMENT_TEXT"]
    for row in reader:
        sql = 'INSERT INTO comments(%s) VALUES(%s)' % (','.join(headers), ','.join(['%s'] * len(headers)))
        logging.debug(sql)
        logging.debug(row)
        conn.execute(sql, row)

# cleanup!
#for fileName in glob.glob("*"): os.remove(fileName)
#os.rmdir(path)
conn.close()

elapsed = (time.time() - start)
logging.info("%d seconds!" % elapsed)