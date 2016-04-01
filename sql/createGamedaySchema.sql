-- Create the pitchfx database
DROP DATABASE IF EXISTS `gameday`;
 CREATE DATABASE `gameday` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `gameday`;

DROP TABLE IF EXISTS action;
CREATE TABLE  action (
    `gameName`    	VARCHAR(38) DEFAULT NULL,
    `atbatNum`      smallint(3) UNSIGNED DEFAULT NULL,
    `inning`      	TINYINT(2) UNSIGNED DEFAULT NULL,
    `b`           	TINYINT(1) UNSIGNED DEFAULT NULL,
    `s`           	TINYINT(1) UNSIGNED DEFAULT NULL,
    `o`           	TINYINT(3) UNSIGNED DEFAULT NULL,
    score         	VARCHAR(2),
    des           	VARCHAR(512),
    event         	VARCHAR(60),
    `event2`      	varchar(40) DEFAULT NULL,
    `event3`      	varchar(40) DEFAULT NULL,
    player        	MEDIUMINT(6) UNSIGNED DEFAULT NULL,
    pitch         	TINYINT(9) UNSIGNED,
    eventNumber   	SMALLINT(4) UNSIGNED DEFAULT NULL,
    halfInning    	VARCHAR(6),
    tfs		      	varchar(6) DEFAULT NULL, 
    `tfs_zulu`    	varchar(20) DEFAULT NULL,
    home_team_runs  INT(3) UNSIGNED,
    away_team_runs  INT(3) UNSIGNED
);

DROP TABLE IF EXISTS hits;
CREATE TABLE hits (
       hitID     mediumint(8) UNSIGNED DEFAULT NULL AUTO_INCREMENT,
       gameName  varchar(38) DEFAULT NULL,
       des       VARCHAR(60) DEFAULT NULL,
       x         double(5,2) UNSIGNED DEFAULT NULL,
       y         double(5,2) UNSIGNED DEFAULT NULL,
       batter    int(6) UNSIGNED DEFAULT NULL,
       pitcher   int(6) UNSIGNED DEFAULT NULL, 
       type      varchar(1) DEFAULT NULL, 
       inning    smallint(2) UNSIGNED DEFAULT NULL,
  PRIMARY KEY  (hitID) 
);             

DROP TABLE IF EXISTS atbats;
CREATE TABLE atbats (
  gameName      varchar(38) DEFAULT NULL,
  `inning`      smallint(2) UNSIGNED DEFAULT NULL,
  `num`         smallint(3) UNSIGNED DEFAULT NULL,
  `b`           TINYINT(1) UNSIGNED DEFAULT NULL,
  `s`           TINYINT(1) UNSIGNED DEFAULT NULL,
  `o`           TINYINT(3) UNSIGNED DEFAULT NULL,
  `batter`      MEDIUMINT(6) UNSIGNED,
  `pitcher`     MEDIUMINT(6) UNSIGNED,
  `des`         VARCHAR(512) DEFAULT NULL,
  `stand`       CHAR(1) DEFAULT NULL,
  `score`       varchar(2) DEFAULT NULL,
  `away_team_runs` int(3) unsigned DEFAULT NULL,
  `home_team_runs` int(3) unsigned DEFAULT NULL,
  `event`       VARCHAR(40) DEFAULT NULL,
  `event2`      varchar(40) DEFAULT NULL,
  `event3`      varchar(40) DEFAULT NULL,
  `event4`      varchar(40) DEFAULT NULL,
  `b_height`    varchar(40) DEFAULT NULL,
  `p_throws`    varchar(40) DEFAULT NULL,
  `eventNumber` varchar(4) DEFAULT NULL,
  halfInning    VARCHAR(6) DEFAULT NULL,
  start_tfs 	varchar(6) DEFAULT NULL,
  `start_tfs_zulu` varchar(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=368739 DEFAULT CHARSET=latin1 COMMENT='Atbat data';

DROP TABLE IF EXISTS pitches;
CREATE TABLE pitches (
  gameName          varchar(38) DEFAULT NULL,
  `gameAtBatID`     smallint(2) UNSIGNED DEFAULT NULL,
  `id`              mediumint(9) UNSIGNED,
  gamedayPitchID    int(8) UNSIGNED DEFAULT NULL AUTO_INCREMENT,
  `des`             VARCHAR(50) DEFAULT NULL,
  `type`            varchar(1) DEFAULT NULL,
  `x`               VARCHAR(25),
  `y`               VARCHAR(25),
  `start_speed`     DECIMAL(6,3) UNSIGNED DEFAULT NULL,
  `end_speed`       DECIMAL(6,3) UNSIGNED DEFAULT NULL,
  `sz_top`          DECIMAL(6,3) UNSIGNED DEFAULT NULL,
  `sz_bot`          DECIMAL(6,3) DEFAULT NULL,
  `pfx_x`           DECIMAL(6,3) DEFAULT NULL,
  `pfx_z`           DECIMAL(6,3) DEFAULT NULL,
  `px`              DECIMAL(6,3) DEFAULT NULL,
  `pz`              DECIMAL(6,3) DEFAULT NULL,
  `x0`              DECIMAL(6,3) DEFAULT NULL,
  `y0`              decimal(6,3) UNSIGNED DEFAULT NULL,
  `z0`              DECIMAL(6,3) DEFAULT NULL,
  `vx0`             DECIMAL(6,3) DEFAULT NULL,
  `vy0`             DECIMAL(6,3) DEFAULT NULL,
  `vz0`             DECIMAL(6,3) DEFAULT NULL,
  `ax`              DECIMAL(6,3) DEFAULT NULL,
  `ay`              DECIMAL(6,3) UNSIGNED DEFAULT NULL,
  `az`              DECIMAL(6,3) DEFAULT NULL,
  `break_y`         DECIMAL(6,3) DEFAULT NULL,
  `break_z`         DECIMAL(6,3) DEFAULT NULL,
  `break_x`         DECIMAL(6,3) DEFAULT NULL,
  `break_angle`     DECIMAL(6,3) DEFAULT NULL,
  `break_length`    DECIMAL(6,3) UNSIGNED DEFAULT NULL,
  `pitch_type`      varchar(2) DEFAULT NULL,
  `type_confidence` float DEFAULT NULL,
  `spin_dir`        float DEFAULT NULL,
  `spin_rate`       float DEFAULT NULL,
  `sv_id`           time DEFAULT NULL,
  `zone` int(2) unsigned DEFAULT NULL,
  `nasty` int(2) unsigned DEFAULT NULL,
  `cc` varchar(256) DEFAULT NULL,
  `mt` varchar(256) DEFAULT NULL,
  `on_1b` int(6) unsigned DEFAULT NULL,
  `on_2b` int(6) unsigned DEFAULT NULL,
  `on_3b` int(6) unsigned DEFAULT NULL,
  `tfs`             VARCHAR(10) DEFAULT NULL,
  `tfs_zulu`             VARCHAR(25) DEFAULT NULL,
  `play_guid`       VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY  (gamedayPitchID)
) ENGINE=InnoDB AUTO_INCREMENT=1315461 DEFAULT CHARSET=latin1;

create unique index pitchesIndex on pitches (gameName, gameAtBatID, gamedayPitchID);

DROP TABLE IF EXISTS Teams;
CREATE TABLE Teams (
      gameName          varchar(38) DEFAULT NULL,
      code              varchar(3),
      file_code         VARCHAR(5),
      abbrev            VARCHAR(10) DEFAULT NULL,
      name_brief        VARCHAR(40),
      name_full         VARCHAR(60),
      id                VARCHAR(8) DEFAULT NULL,
      file              varchar(8) DEFAULT NULL,
      name              VARCHAR(40) DEFAULT NULL,
      league            VARCHAR(5) DEFAULT NULL,
      league_id         VARCHAR(5),
      division_id       VARCHAR(5),
      type              VARCHAR(5) DEFAULT NULL,
      w                 int(3) DEFAULT NULL,
      l                 int(3) DEFAULT NULL
);

DROP TABLE IF EXISTS Games;
CREATE TABLE Games (
       gameName          varchar(38) DEFAULT NULL,
       leagueLevel       varchar(5),
       stadiumID         int(8) UNSIGNED,
       game_pk			 int(8) UNSIGNED,
	   game_time_et		 VARCHAR(30),
       home              VARCHAR(5),
       away              VARCHAR(5),
       type              VARCHAR(1),
       gameday_sw        VARCHAR(3),
       local_game_time   time DEFAULT NULL,
  PRIMARY KEY  (gameName)
);

DROP TABLE IF EXISTS Stadiums;
CREATE TABLE Stadiums (
       gameName          varchar(38) DEFAULT NULL,
       id                mediumint(9) UNSIGNED DEFAULT NULL,
       name              VARCHAR(60),
       location          VARCHAR(60),
       venue_w_chan_loc  CHAR(60)
);

-- Keep track of the complete daily rosters. This 
-- table will include detailed information about 
-- who played in each game.
DROP TABLE IF EXISTS players;
CREATE TABLE players (
       gameName       varchar(38) DEFAULT NULL,
       team           varchar(15) DEFAULT NULL,
       homeAway       varchar(4) DEFAULT NULL,
       first          VARCHAR(32) DEFAULT NULL,
       last           VARCHAR(32) DEFAULT NULL,
       `position`     varchar(32),
       current_position  varchar(32),
       game_position  varchar(32),
       bat_order      TINYINT(2) UNSIGNED,
       status         VARCHAR(3),
       rl             varchar(4) DEFAULT NULL,
       num            varchar(2),
       id             MEDIUMINT(6) UNSIGNED DEFAULT NULL,
       boxname        varchar(66),
       `avg`          decimal(5,3) DEFAULT NULL,
       hr             int(4) UNSIGNED, -- s_rbi
       rbi            int(4) UNSIGNED, -- s_rbi
       wins           smallint(2) DEFAULT NULL,
       losses         smallint(2) DEFAULT NULL,
       era            decimal(6,2) DEFAULT NULL
);           

DROP TABLE IF EXISTS umpires;
CREATE TABLE umpires (
  gameName         varchar(38) DEFAULT NULL,
  position         varchar(32) DEFAULT NULL,
  name             VARCHAR(50) DEFAULT NULL,
  id               int(6) UNSIGNED DEFAULT NULL
);          

DROP TABLE IF EXISTS coaches;
CREATE TABLE coaches (
  gameName          varchar(38) DEFAULT NULL,
  id                int(6) UNSIGNED DEFAULT NULL,
  num               varchar(4) DEFAULT NULL,
  team              varchar(15) DEFAULT NULL,
  homeAway          varchar(4) DEFAULT NULL,
  first             VARCHAR(50) DEFAULT NULL,
  last              VARCHAR(50) DEFAULT NULL,
  position          VARCHAR(50) DEFAULT NULL
);

DROP TABLE IF EXISTS batters;
CREATE TABLE batters (
       gameName     varchar(38) DEFAULT NULL,
       id           int(6) UNSIGNED DEFAULT NULL,
       `name`       varchar(40) DEFAULT NULL,
       `name_display_first_last` varchar(40) DEFAULT NULL,
       `avg` decimal(5,3) DEFAULT NULL,
       pos          VARCHAR(50) DEFAULT NULL, -- position
       bo           int(4) UNSIGNED, -- batting order
       s_hr         int(4) UNSIGNED, -- s_hr
       s_rbi        int(4) UNSIGNED, -- s_rbi
       s_h          int(4) UNSIGNED, -- 
       s_bb         int(4) UNSIGNED, -- 
       s_r          int(4) UNSIGNED, -- 
       s_so         int(4) UNSIGNED, -- 
       go           smallint(2) UNSIGNED DEFAULT NULL, -- at bats
       ao           smallint(2) UNSIGNED DEFAULT NULL, -- at bats
       ab           smallint(2) UNSIGNED DEFAULT NULL, -- at bats
       h            smallint(2) UNSIGNED DEFAULT NULL, -- hits
       hr           smallint(2) UNSIGNED DEFAULT NULL, -- home runs
       d            smallint(2) UNSIGNED DEFAULT NULL, -- doubles
       t            smallint(2) UNSIGNED DEFAULT NULL, -- triples
       sac          smallint(2) UNSIGNED DEFAULT NULL, -- sacrifice?
       bb           smallint(2) UNSIGNED DEFAULT NULL, -- walks
       rbi          smallint(2) UNSIGNED DEFAULT NULL, -- runs batted in
       so           smallint(2) UNSIGNED DEFAULT NULL, -- strikeouts
       r            smallint(2) UNSIGNED DEFAULT NULL, -- runs scored
       hbp          smallint(2) UNSIGNED, -- hit by pitch
       sf           smallint(2) UNSIGNED, -- sac flies
       sb           smallint(2) UNSIGNED, -- stolen bases
       lob          smallint(2) UNSIGNED DEFAULT NULL, -- left on base
       a            smallint(2) UNSIGNED DEFAULT NULL, -- assists      
       e            smallint(2) UNSIGNED DEFAULT NULL, -- errors
       po           smallint(2) UNSIGNED DEFAULT NULL, -- put outs
       fldg         DECIMAL(4,3) DEFAULT NULL,-- fielding percentage
       note         varchar(10),
       pb           smallint(2) UNSIGNED  -- passed balls
);

DROP TABLE IF EXISTS pitchers;
CREATE TABLE pitchers (
       gameName     varchar(38) DEFAULT NULL,
       id           int(6) UNSIGNED DEFAULT NULL,
       `name` varchar(40) DEFAULT NULL,
       `name_display_first_last` varchar(40) DEFAULT NULL,
       `era` decimal(6,2) DEFAULT NULL,
       pos          VARCHAR(50) DEFAULT NULL,  -- position
       outs         smallint(2) DEFAULT NULL,
       bf           smallint(2) DEFAULT NULL, -- batters faced
       hr           smallint(2) DEFAULT NULL, -- home runs
       bb           smallint(2) DEFAULT NULL, -- walks
       so           smallint(2) DEFAULT NULL, -- strikeouts
       er           smallint(2) DEFAULT NULL, -- earned runs
       r            smallint(2) DEFAULT NULL, -- runs
       h            smallint(2) DEFAULT NULL, -- hits
       w            smallint(2) DEFAULT NULL, -- season wins
       l            smallint(2) DEFAULT NULL, -- season losses
       win          smallint(2), 
       loss         smallint(2), 
       hold         smallint(2), 
       blownhold    smallint(2), 
       save         smallint(2), 
       blownsave    smallint(2), 
       hld 			int(2),
       sv			int(2),
       bs			int(2),
       note         VARCHAR(20)        
);

DROP TABLE IF EXISTS teamNames;
CREATE TABLE teamNames (
  gameName          varchar(38) DEFAULT NULL,
  id                varchar(6)  DEFAULT NULL,
  name              VARCHAR(50) DEFAULT NULL
);

DROP TABLE IF EXISTS gameConditions;
CREATE TABLE gameConditions (
  gameName          varchar(38) DEFAULT NULL,
  temperature       VARCHAR(3),
  forecast          VARCHAR(50),
  windMPH           VARCHAR(3),
  windDirection     VARCHAR(50),
  gameLength        time DEFAULT NULL,
  attendence        VARCHAR(6)
);

DROP TABLE IF EXISTS playerBIOs;
CREATE TABLE playerBIOs (
  gameName          varchar(38) DEFAULT NULL,
  first_name        VARCHAR(25),
  last_name         VARCHAR(25),
  weight            VARCHAR(4),
  dob               CHAR(10),
  pos               CHAR(2),
  current_position  CHAR(2),
  jersey_number     CHAR(4),
  bats              CHAR(4),
  team              CHAR(3),
  id                MEDIUMINT(6) UNSIGNED DEFAULT NULL,
  heightFeet        CHAR(1),
  heightInches      CHAR(2),
  type              VARCHAR(7),
  throws            CHAR(4)
);

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  gameName          VARCHAR(38) NOT NULL,
  `gameAtBatID`     int(2) UNSIGNED NOT NULL,
  `id`              int(6) UNSIGNED,
  gamedayRunnerID    int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  start		    VARCHAR(5),
  end		    VARCHAR(5),
  event		    VARCHAR(40),
  score		    VARCHAR(5),
  rbi		    VARCHAR(5),
  earned	    VARCHAR(5),
  PRIMARY KEY  (gamedayRunnerID)
) ENGINE=InnoDB AUTO_INCREMENT=1315461 DEFAULT CHARSET=latin1;

create unique index runnersIndex on runners (gameName, gameAtBatID, gamedayRunnerID);        
        
        
DROP TABLE IF EXISTS gameDetail;
CREATE TABLE gameDetail (
  gameName          varchar(38) DEFAULT NULL,
  id                varchar(30),
  venue        		VARCHAR(55),
  game_pk        	int(8),
  `time`              VARCHAR(8),
  time_zone            VARCHAR(2),
  ampm               VARCHAR(2),
  away_time               VARCHAR(8),
  away_time_zone               VARCHAR(5),
  away_ampm               VARCHAR(2),
  home_time               VARCHAR(8),
  home_time_zone               VARCHAR(5),
  home_ampm               VARCHAR(2),
  game_type               VARCHAR(2),
  tiebreaker_sw           VARCHAR(2),
  original_date           VARCHAR(12),
  time_zone_aw_lg         VARCHAR(2),
  time_zone_hm_lg         VARCHAR(2),
  time_aw_lg              VARCHAR(8),
  aw_lg_ampm               VARCHAR(2),
  tz_aw_lg_gen               VARCHAR(5),
  time_hm_lg               VARCHAR(8),
  hm_lg_ampm               VARCHAR(2),
  tz_hm_lg_gen               VARCHAR(5),
  venue_id               VARCHAR(4),
  scheduled_innings               VARCHAR(2),
  description               VARCHAR(50),
  away_name_abbrev               VARCHAR(10),
  home_name_abbrev               VARCHAR(10),
  away_code               VARCHAR(5),
  away_file_code               VARCHAR(5),
  away_team_id               VARCHAR(5),
  away_team_city               VARCHAR(30),
  away_team_name               VARCHAR(25),
  away_division               VARCHAR(3),
  away_league_id               VARCHAR(5),
  away_sport_code               VARCHAR(5),
  home_code               VARCHAR(3),
  home_file_code               VARCHAR(5),
  home_team_id               VARCHAR(5),
  home_team_city               VARCHAR(30),
  home_team_name               VARCHAR(25),
  home_division               VARCHAR(2),
  home_league_id               VARCHAR(5),
  home_sport_code               VARCHAR(5),
  `day`               VARCHAR(5),
  gameday_sw               VARCHAR(3),
  double_header_sw               VARCHAR(3),
  away_games_back               VARCHAR(5),
  home_games_back               VARCHAR(5),
  `away_games_back_wildcard`   varchar(5) DEFAULT NULL,
  `home_games_back_wildcard`   varchar(5) DEFAULT NULL,
  venue_w_chan_loc               VARCHAR(15),
  gameday_link               VARCHAR(40),
  away_win               VARCHAR(3),
  away_loss               VARCHAR(3),
  home_win               VARCHAR(3),
  home_loss               VARCHAR(3),
  game_data_directory            VARCHAR(225),
  league               VARCHAR(5),
  top_inning               VARCHAR(2),
  inning_state               VARCHAR(10),
  status               VARCHAR(15),
  `reason`             varchar(50),
  ind               VARCHAR(3),
  inning               VARCHAR(2),
  outs               VARCHAR(2),
  away_team_runs               VARCHAR(3),
  home_team_runs               VARCHAR(3),
  away_team_hits               VARCHAR(4),
  home_team_hits               VARCHAR(4),
  away_team_errors               VARCHAR(3),
  home_team_errors               VARCHAR(3),
  wrapup_link               VARCHAR(225),
  home_preview_link               VARCHAR(225),
  away_preview_link               VARCHAR(225),
  preview               VARCHAR(225),
  tv_station               VARCHAR(60),
  home_recap_link               VARCHAR(225),
  away_recap_link               VARCHAR(225),
  photos_link               VARCHAR(225)
);      
        
        
DROP TABLE IF EXISTS pregumboHits;
CREATE TABLE pregumboHits (
  gameName          VARCHAR(38) NOT NULL,
  angle          DECIMAL(6,3) NOT NULL,
  direction          DECIMAL(6,3) NOT NULL,
  distance          DECIMAL(6,3) NOT NULL,
  play_guid	    VARCHAR(50),
  speed          DECIMAL(6,3) NOT NULL,
  PRIMARY KEY  (play_guid)
) ENGINE=InnoDB AUTO_INCREMENT=1315461 DEFAULT CHARSET=latin1;
        
        
DROP TABLE IF EXISTS gameday.feedPlays;
CREATE TABLE gameday.feedPlays (
  gameName          VARCHAR(38) NOT NULL,
  description	    VARCHAR(450),
  player_id         VARCHAR(6),
  mph               VARCHAR(6),
  distance          VARCHAR(6),
  launch_angle      VARCHAR(6),
  result          VARCHAR(25)
) ENGINE=InnoDB AUTO_INCREMENT=1315461 DEFAULT CHARSET=latin1;

        
        