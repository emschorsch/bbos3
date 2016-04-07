import xml.dom.minidom
from xml.parsers.expat import ExpatError

class Parser:
    def __init__(self, game):
        self.game = game
        
    def __mapTag__(self, tag):
        attributes = tag.attributes.keys()
        
        return self.__doMapTag__(tag, attributes);  
    
    def mapTagWithList(self, tag, predefinedAttributes):
        attributes = []
            
        for tagAttribute in predefinedAttributes:
            if tag.getAttribute(tagAttribute):
                attributes.append(tagAttribute)
        
        return self.__doMapTag__(tag, attributes);     
    
    def __doMapTag__(self, tag, attributes):
        doMap = {}
        
        for attribute in attributes:
            doMap[attribute] = tag.getAttribute(attribute)
            
        return doMap   
    
    def createDocument(self, xmlDoc):
        try:
            doc = xml.dom.minidom.parseString(xmlDoc)
        except ExpatError:
            return None
        
        return doc
            
    def parse(self, xmlProvider):
        raise NotImplementedError
    
    def mapJsonList(self, items, fieldsToKeep):
        filteredItems = []
        
        for item in items:
            filteredItem = self.mapJsonHash(item, fieldsToKeep)
            
            filteredItems.append(filteredItem)
        
        return filteredItems
    
    def mapJsonHash(self, item, fieldsToKeep):
        filteredItem = {}
        
        for key in item:
            if key in fieldsToKeep:
                filteredItem[key] = item[key]
        
        return filteredItem
     
        