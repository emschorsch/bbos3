class Unzipper:
    def __init__(self, unzipProgramController):
        self.controller = unzipProgramController
        
    def unzip(self, file, outputDir):
        self.controller.unzip(file, outputDir)
    
class UnzipProgramController:
    def unzip(self, file, outputDir):
        raise NotImplementedError
