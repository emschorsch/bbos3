class GamedayConfig:
    mlbGamedayApplicationURL = 'http://mlb.mlb.com'
    
    leagues = ('MLB','AAA','AAX','AFA','AFX','ASX','ROK','WIN')
    
    parser_inning_pitch = ['des', 'id', 'type', 'tfs', 'tfs_zulu', 'x', 'y', 'on_1b', 'on_2b', 'on_3b', 'sv_id', 'start_speed', 'end_speed', 'sz_top', 'sz_bot', 'pfx_x', 'pfx_z', 'px', 'pz', 'x0', 'y0', 'z0', 'vx0', 'vy0', 'vz0', 'ax', 'ay', 'az', 'break_y', 'break_z','break_x','break_angle', 'break_length', 'pitch_type', 'type_confidence', 'zone', 'nasty', 'spin_dir', 'spin_rate', 'cc', 'mt', 'play_guid'];
    parser_inning_action = ['b', 's', 'o', 'score', 'des', 'event', 'event2', 'event3', 'tfs', 'player', 'pitch', 'tfs_zulu', 'home_team_runs', 'away_team_runs'];
    parser_inning_atbat = ['num', 'b', 's', 'o', 'start_tfs', 'start_tfs_zulu', 'batter', 'stand', 'b_height', 'pitcher', 'p_throws', 'des', 'event', 'event2', 'event3', 'event4', 'score', 'home_team_runs', 'away_team_runs'];
    parser_inning_runner = ['id', 'start', 'end', 'event', 'score', 'rbi', 'earned'];
    
    parser_player_ump = ['position', 'name', 'id'];
    parser_player_player = ['id', 'first', 'last', 'num', 'boxname', 'rl', 'position', 'current_position', 'status', 'avg', 'hr', 'rbi', 'wins', 'losses', 'era', 'game_position', 'bat_order'];
    parser_player_coach = ['position', 'first', 'last', 'id', 'num'];
    
    parser_playerbio_player = ['first_name', 'last_name', 'weight', 'dob', 'pos', 'current_position', 'jersey_number', 'team', 'id', 'height', 'bats', 'throws', 'type'];
    
    parser_hit_hit = ['des', 'x', 'y', 'batter', 'pitcher', 'type', 'team', 'inning'];

    parser_game_gameinfo = ['type', 'home', 'away', 'local_game_time', 'game_pk', 'game_time_et', 'gameday_sw', 'stadiumID', 'reason', 'away_games_back_wildcard', 'home_games_back_wildcard'];
    parser_game_team = ['type', 'code', 'file', 'file_code', 'abbrev', 'id', 'name', 'name_full', 'name_brief', 'w', 'l', 'division_id', 'league_id', 'league'];
    parser_game_stadium = ['id', 'name', 'venue_w_chan_loc', 'location'];

    parser_boxscore_batter = ['id', 'pb', 'name', 'pos', 'bo', 'ab', 'po', 'r', 'bb', 'sac', 'a', 't', 'sf', 'h', 'e', 'd', 'hbp', 'so', 'hr', 'rbi', 'lob', 'fldg', 'sb', 's_hr', 's_rbi', 's_h', 's_bb', 's_r', 's_so', 'go', 'ao', 'avg', 'name_display_first_last', 'note'];
    parser_boxscore_pitcher = ['id', 'name', 'pos', 'out', 'bf', 'er', 'r', 'h', 'so', 'hr', 'bb', 'w', 'l', 'sv', 'bs', 'hld', 'era', 'note', 'name_display_first_last', 'hold', 'blownhold', 'win', 'loss', 'save', 'blownsave'];

    parser_linescore_game = ['id', 'venue', 'game_pk', 'time', 'time_zone', 'ampm', 'away_time', 'away_time_zone', 'away_ampm', 'home_time', 'home_time_zone', 'home_ampm', 'game_type', 'tiebreaker_sw', 'original_date', 'time_zone_aw_lg', 'time_zone_hm_lg', 'time_aw_lg', 'aw_lg_ampm', 'tz_aw_lg_gen', 'time_hm_lg', 'hm_lg_ampm', 'tz_hm_lg_gen', 'venue_id', 'scheduled_innings', 'description', 'away_name_abbrev', 'home_name_abbrev', 'away_code', 'away_file_code', 'away_team_id', 'away_team_city', 'away_team_name', 'away_division', 'away_league_id', 'away_sport_code', 'home_code', 'home_file_code', 'home_team_id', 'home_team_city', 'home_team_name', 'home_division', 'home_league_id', 'home_sport_code', 'day', 'gameday_sw', 'double_header_sw', 'away_games_back', 'home_games_back', 'away_games_back_wildcard', 'venue_w_chan_loc', 'gameday_link', 'away_win', 'away_loss', 'home_win', 'home_loss', 'game_data_directory', 'game_data_directory', 'away_win', 'away_loss', 'home_win', 'home_loss', 'league', 'top_inning', 'inning_state', 'status', 'ind', 'inning', 'outs', 'away_team_runs', 'home_team_runs', 'away_team_hits', 'home_team_hits', 'away_team_errors', 'home_team_errors', 'wrapup_link', 'home_preview_link', 'away_preview_link', 'preview', 'tv_station', 'home_recap_link', 'away_recap_link', 'photos_link'];

    parser_pregumbo_hit = ['angle', 'direction', 'distance', 'play_guid', 'speed'];
    
    parser_feed_plays = ['description', 'player_id', 'mph', 'distance', 'launch_angle', 'result', 'time_tfs']
