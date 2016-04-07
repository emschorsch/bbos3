import urllib
import urllib2
import time
import os

class Page:
    def __init__(self, url):
        self.url = url
        
        self.urlOpener = urllib.FancyURLopener({})
        
    def getContent(self):
        try:
            content = self.__doGetContent__()
        except IOError:
            time.sleep(2)
            
            try:
                content = self.__doGetContent__()
            except IOError:
                time.sleep(15)
                
                content = self.__doGetContent__()
        
        return content
    
    def __doGetContent__(self):
        openURL = self.urlOpener.open(self.url)
        
        return openURL.read()
    
    def download(self, filePath):
        urlFile = urllib2.urlopen(self.url)
        
        output = open(filePath, 'wb')
        
        output.write(urlFile.read())
        
        output.close()

        
        
        