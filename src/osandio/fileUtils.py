import os
import os.path
import glob
import re

def mkdir(path):
    pathComponents = []
    currentPath = path

    (head, tail) = os.path.split(currentPath)
    while tail:
        pathComponents.append(tail)
        
        currentPath = head
        
        (head, tail) = os.path.split(currentPath)
    pathComponents.append(head)

    path = pathComponents.pop()
    pathComponents.reverse()

    for component in pathComponents:
        path = os.path.join(path, component)

        if not os.path.exists(path):
            os.mkdir(path)

def slurp(fileName):
    myFile = open(fileName)
    
    lines = myFile.readlines();
    
    myFile.close()
    
    return lines


def spit(fileName, lines):
    myFile = open(fileName, 'w')
    
    myFile.writelines(lines)
    
    myFile.close()

def remove(path, pattern):
    for name in find(path, pattern):
        try: os.remove(name)
        except:
            remove(name, '')
            os.rmdir(name) 
                
def find(path, pattern):   
    pattern = re.compile(pattern)
    
    matches = []
    for each in os.listdir(path):
        if pattern.search(each):
            name = os.path.join(path, each)
            
            matches.append(name)
            
    return matches  