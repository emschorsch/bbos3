import unittest
from bbos.config import loggingSetup
loggingSetup.initializeLogging('bbosFTest.py')

class FTest(unittest.TestCase):
    pass