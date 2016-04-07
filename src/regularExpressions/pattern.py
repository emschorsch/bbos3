import re


def capture(pattern, textToSearch):
    compiledPattern = re.compile(pattern)
    matched = compiledPattern.search(textToSearch)
    
    if matched == None:
        return ""
    
    group = matched.group(1)
    
    return group

def match(pattern, textToSearch):
    compiledPattern = re.compile(pattern)
    matched = compiledPattern.search(textToSearch)
    
    if matched == None:
        return False
    
    return True