from bbos.gameday.parser.parser import Parser
from bbos.config.gamedayConfig import GamedayConfig

class LinescoreParser(Parser):
    
    def parse(self, xmlProvider):
        linescoreXML = xmlProvider.getLinescoreXML()
        
        doc = self.createDocument(linescoreXML)
        if not doc: return
        
        self.__parseGameDetail__(doc.documentElement)

    
    def __parseGameDetail__(self, gameTag):
        gameDetail = self.mapTagWithList(gameTag, GamedayConfig.parser_linescore_game)
        
        if 'time' in gameDetail: gameDetail['time'] = gameDetail['time'] + ":00"
        if 'away_time' in gameDetail: gameDetail['away_time'] = gameDetail['away_time'] + ":00"
        if 'home_time' in gameDetail: gameDetail['home_time'] = gameDetail['home_time'] + ":00"
        if 'time_aw_lg' in gameDetail: gameDetail['time_aw_lg'] = gameDetail['time_aw_lg'] + ":00"
        if 'time_hm_lg' in gameDetail: gameDetail['time_hm_lg'] = gameDetail['time_hm_lg'] + ":00"
        
        if 'home_preview_link' in gameDetail: gameDetail['home_preview_link'] = GamedayConfig.mlbGamedayApplicationURL + gameDetail['home_preview_link']
        if 'away_preview_link' in gameDetail: gameDetail['away_preview_link'] = GamedayConfig.mlbGamedayApplicationURL + gameDetail['away_preview_link']
        if 'preview' in gameDetail: gameDetail['preview'] = GamedayConfig.mlbGamedayApplicationURL + gameDetail['preview']
        if 'home_recap_link' in gameDetail: gameDetail['home_recap_link'] = GamedayConfig.mlbGamedayApplicationURL + gameDetail['home_recap_link']
        if 'away_recap_link' in gameDetail: gameDetail['away_recap_link'] = GamedayConfig.mlbGamedayApplicationURL + gameDetail['away_recap_link']
        if 'photos_link' in gameDetail: gameDetail['photos_link'] = GamedayConfig.mlbGamedayApplicationURL + gameDetail['photos_link']
  
        self.game.setGameDetail(gameDetail)


"""
<game id="2011/06/01/flomlb-arimlb-1" venue="Chase Field" game_pk="287736" 
time="7:40" time_zone="ET" ampm="PM" away_time="7:40" away_time_zone="ET" 
away_ampm="PM" home_time="4:40" home_time_zone="MST" home_ampm="PM" game_type="R" 
time_aw_lg="7:40" aw_lg_ampm="PM" tz_aw_lg_gen="ET" time_hm_lg="7:40" 
hm_lg_ampm="PM" tz_hm_lg_gen="ET" venue_id="15" scheduled_innings="9" 
away_name_abbrev="FLA" home_name_abbrev="ARI" away_code="flo" 
away_file_code="fla" away_team_id="146" away_team_city="Florida" 
away_team_name="Marlins" away_division="E" away_league_id="104" 
away_sport_code="mlb" home_code="ari" home_file_code="ari" home_team_id="109" 
home_team_city="Arizona" home_team_name="D-backs" home_division="W" 
home_league_id="104" home_sport_code="mlb" day="WED" gameday_sw="P" 
away_games_back="2.0" home_games_back="-" away_games_back_wildcard="-" 
venue_w_chan_loc="USAZ0166" gameday_link="2011_06_01_flomlb_arimlb_1" 
away_win="31" away_loss="23" home_win="31" home_loss="25" league="NN" 
top_inning="N" inning_state="" status="Final" ind="F" inning="9" outs="2" 
away_team_runs="5" home_team_runs="6" away_team_hits="11" home_team_hits="10" 
away_team_errors="2" home_team_errors="0" 
wrapup_link="/mlb/gameday/index.jsp?gid=2011_06_01_flomlb_arimlb_1&mode=wrap&c_id=mlb" 
home_preview_link="/mlb/gameday/index.jsp?gid=2011_06_01_flomlb_arimlb_1&mode=preview&c_id=mlb" 
away_preview_link="/mlb/gameday/index.jsp?gid=2011_06_01_flomlb_arimlb_1&mode=preview&c_id=mlb" 
preview="/mlb/gameday/index.jsp?gid=2011_06_01_flomlb_arimlb_1&mode=preview&c_id=mlb" 
tv_station="FS-A" 
home_recap_link="/mlb/gameday/index.jsp?gid=2011_06_01_flomlb_arimlb_1&mode=recap&c_id=ari" 
away_recap_link="/mlb/gameday/index.jsp?gid=2011_06_01_flomlb_arimlb_1&mode=recap&c_id=fla" 
photos_link="/mlb/gameday/index.jsp?gid=2011_06_01_flomlb_arimlb_1&mode=photos">
"""