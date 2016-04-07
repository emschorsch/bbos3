from bbos.gameday.loader.gameLoaderWorkList import GameLoaderWorkList
from bbos.gameday.parser.boxscoreParser import BoxScoreParser
from bbos.gameday.parser.gameParser import GameParser
from bbos.gameday.parser.hitParser import HitParser
from bbos.gameday.parser.pregumboParser import PregumboParser
from bbos.gameday.parser.feedParser import FeedParser
from bbos.gameday.parser.inningParser import InningParser
from bbos.gameday.parser.playerParser import PlayerParser
from bbos.gameday.parser.linescoreParser import LinescoreParser
from bbos.gameday.persist.actionLoader import ActionLoader
from bbos.gameday.persist.atbatLoader import AtbatLoader
from bbos.gameday.persist.batterLoader import BatterLoader
from bbos.gameday.persist.coachLoader import CoachLoader
from bbos.gameday.persist.gameConditionsLoader import GameConditionsLoader
from bbos.gameday.persist.gameLoader import GameLoader
from bbos.gameday.persist.hitLoader import HitLoader
from bbos.gameday.persist.pregumboHitLoader import PregumboHitLoader
from bbos.gameday.persist.feedLoader import FeedLoader
from bbos.gameday.persist.pitchLoader import PitchLoader
from bbos.gameday.persist.runnerLoader import RunnerLoader
from bbos.gameday.persist.pitcherLoader import PitcherLoader
from bbos.gameday.persist.playerLoader import PlayerLoader
from bbos.gameday.persist.stadiumLoader import StadiumLoader
from bbos.gameday.persist.teamLoader import TeamLoader
from bbos.gameday.persist.teamNameLoader import TeamNameLoader
from bbos.gameday.persist.umpLoader import UmpLoader
from bbos.gameday.persist.gameDetailLoader import GameDetailLoader


class GameStatsWorkList(GameLoaderWorkList):
    def getParsers(self, game):
        parsers = []
        
        parsers.append(InningParser(game))
        parsers.append(HitParser(game))
        parsers.append(PregumboParser(game))
        parsers.append(GameParser(game))
        parsers.append(PlayerParser(game))
        parsers.append(BoxScoreParser(game))
        parsers.append(LinescoreParser(game))
        parsers.append(FeedParser(game))
        
        return parsers
            
    def getLoaders(self, db, gameName):
        loaders = []
        
        loaders.append(AtbatLoader(db, gameName))
        loaders.append(ActionLoader(db, gameName))
        loaders.append(HitLoader(db, gameName))
        loaders.append(PregumboHitLoader(db, gameName))
        loaders.append(FeedLoader(db, gameName))
        loaders.append(PitchLoader(db, gameName))
        loaders.append(RunnerLoader(db, gameName))
        loaders.append(GameLoader(db, gameName))
        loaders.append(TeamLoader(db, gameName))
        loaders.append(StadiumLoader(db, gameName))
        loaders.append(PlayerLoader(db, gameName))
        loaders.append(UmpLoader(db, gameName))
        loaders.append(CoachLoader(db, gameName))
        loaders.append(BatterLoader(db, gameName))
        loaders.append(PitcherLoader(db, gameName))
        loaders.append(GameConditionsLoader(db, gameName))
        loaders.append(TeamNameLoader(db, gameName))
        loaders.append(GameDetailLoader(db, gameName))
        
        return loaders
            
    def getAlreadyLoadedSQL(self, alreadyLoadedIdentifier):
        statement = "select distinct(gameName) from %s where gameName = '%s';"

        statement = statement % ("gameday.Games", alreadyLoadedIdentifier)

        return statement