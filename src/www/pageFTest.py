from bbos.test.fTest import FTest
import www.page

class PageFTest(FTest):
    
    def setUp(self):
        urlString = """http://www.google.com"""
        
        self.page = www.page.Page(urlString)
    
    def testGetContents(self):
        contents = self.page.getContent()

        self.assertTrue(contents)