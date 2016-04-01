################################# create the mlb/pitchfx database
DROP DATABASE IF EXISTS `mlb`;
 CREATE DATABASE `mlb` /*!40100 DEFAULT CHARACTER SET latin1 */;


################################# teams
DROP TABLE IF EXISTS mlb.teams;

create table mlb.teams
select seasonYear, gamedayID, code, abbreviation, location, league, league_id, division_id
from (
  select SUBSTR(gameName, 5, 4) as seasonYear, 
        if (id>0, id, file) as gamedayID, 
        if (id>0,code,id) as code,         
        abbrev as abbreviation, name as location, league, league_ID, division_ID
    from gameday.Teams t
) tmp
group by seasonYear, gamedayID, code;
 
ALTER TABLE mlb.teams
 ADD teamID INT(6) UNSIGNED AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (teamID);
create unique index iGamedayID on mlb.teams (seasonYear, gamedayID);
create index iCode on mlb.teams (seasonYear, code);



################################# team names
create table mlb.tMostUsedTeamNames
select seasonYear, id as gamedayID, name
from (
select seasonYear, max(timesNameUsed), id, name
from (
select count(tn.name) as timesNameUsed, SUBSTR(gameName, 5, 4) as seasonYear,
       tn.id, name
  from gameday.teamNames tn
 where tn.id != ''
 group by SUBSTR(gameName, 5, 4), id, name
) timesUsed
group by seasonYear, id
) maxTimesUsed
order by seasonYear, id;  
  
ALTER TABLE mlb.teams
  ADD name varchar(50);
 
update mlb.teams t, mlb.tMostUsedTeamNames tn
   set t.name = tn.name
 where t.gamedayID = tn.gamedayID;

drop table mlb.tMostUsedTeamNames;


################################# stadiums
DROP TABLE IF EXISTS mlb.stadiums;

create table mlb.stadiums
select id as gamedayID, location, name
from (
select max(timesNameUsed), id, location, name
from (
select count(id) as timesNameUsed, id, location, name
  from gameday.Stadiums s
 where name is not null
 group by id, location, name
) timesUsed
group by id
) maxTimesUsed
order by id;
  
ALTER TABLE mlb.stadiums
 ADD stadiumID INT(6) UNSIGNED AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (stadiumID);
create unique index iGamedayID on mlb.stadiums (gamedayID);  
  
  
################################# players
DROP TABLE IF EXISTS mlb.players;
  
create table mlb.tNameCounts
select id as eliasID, count(id) as timesNameUsed, last, first, rl as throws
          from gameday.players p
        -- where p.id = 453328
        group by eliasID, last, first, rl;
        
create table mlb.tNameCountsMaxes
select eliasID, max(timesNameUsed) as maxTimesNameUsed
  from mlb.tNameCounts
 group by eliasID;
 
create table mlb.players         
select nc.eliasID, last, first, throws
  from mlb.tNameCounts nc, mlb.tNameCountsMaxes ncm
 where nc.eliasID = ncm.eliasID
   and nc.timesNameUsed = ncm.maxTimesNameUsed
 group by nc.eliasID;
        
drop table if exists mlb.tNameCountsMaxes;
drop table if exists mlb.tNameCounts;
  
ALTER TABLE mlb.players
 ADD PRIMARY KEY (eliasID);


################################# games
DROP TABLE IF EXISTS mlb.games;

create table mlb.tGames
select g.gameName, leagueLevel, local_game_time as gameTime, g.stadiumID,
       CASE g.type 
								      WHEN "E" THEN 'exhibition' 
								      WHEN "S" THEN 'spring' 
								      WHEN "R" THEN 'regular' 
								      WHEN "A" THEN 'allStar' 
								      WHEN "D" THEN 'division' 
								      WHEN "L" THEN 'league' 
								      WHEN "W" THEN 'world' 
								      ELSE g.type 
								      END as gameType,
       g.home, 
       g.away,
       DATE(CONCAT(SUBSTR(gameName, 5, 4), '-', SUBSTR(gameName, 10, 2), '-', SUBSTR(gameName, 13, 2))) as gameDate,
       SUBSTR(gameName, 5, 4) as gameYear          
  from gameday.Games g;
ALTER IGNORE TABLE mlb.tGames ADD UNIQUE INDEX idx_temp (gameName);  
  
create table mlb.games
SELECT           g.gameName,
                 g.leagueLevel,
                 g.gameTime,
                 g.gameDate,
                 (select s.stadiumID from mlb.stadiums s 
                   where s.gamedayID = g.stadiumID) as stadiumID,
                 g.gameType,
                 (select th.teamID from mlb.teams th
                   where g.home = th.gamedayID and g.gameYear = th.seasonYear) as home,
                 (select ta.teamID from mlb.teams ta
                   where g.away = ta.gamedayID and g.gameYear = ta.seasonYear) as away,
                 g.gameYear
  FROM mlb.tGames g;

DROP TABLE IF EXISTS mlb.tGames;

ALTER TABLE mlb.games
 ADD gameID INT(6) UNSIGNED AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (gameID);
  
create unique index iGameName on mlb.games (gameName);


################################# game rosters
drop table if exists mlb.rosters;

create table mlb.tPlayers
select p.gameName, p.id as eliasID, p.position as fieldingPosition, 
       p.bat_order as battingOrder, 
			 IF(p.homeAway = 'away', g.away,
                               g.home) as teamID
  from gameday.players p, mlb.games g
 where p.gameName = g.gameName;
 
ALTER TABLE mlb.tPlayers
  ADD tempID INT(6) UNSIGNED AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (tempID);
  
create table mlb.tPlayersNonDups
select max(tempID) as tempID, gameName, eliasID
  from mlb.tPlayers tp
 group by gameName, eliasID;

create table mlb.rosters 
select g.gameID, p.eliasID, 
			 p.teamID,
       p.fieldingPosition, p.battingOrder
  from mlb.tPlayers p, mlb.games g, mlb.tPlayersNonDups pd
 where p.gameName = g.gameName
	 and p.tempID = pd.tempID;
   
create index iGameID on mlb.rosters (gameID);
create index iEliasID on mlb.rosters (eliasID);

ALTER TABLE mlb.rosters
 ADD PRIMARY KEY (gameID, eliasID);

drop table mlb.tPlayers;
drop table mlb.tPlayersNonDups;


################################# per game pitching
drop table if exists mlb.pitchers;

create table mlb.pitchers
select g.gameID, p.id as eliasID,
       outs, bf as battersFaced, hr, bb, so, er, r as runs, h as hits, win, loss, 
			 (hold+hld) as hold, blownhold, 
			 (sv+save) as save, (bs+blownsave) as blownsave
 from gameday.pitchers p, mlb.games g
where p.gameName = g.gameName;

ALTER IGNORE TABLE mlb.pitchers
 ADD PRIMARY KEY (gameID, eliasID);


################################# per game batting
drop table if exists mlb.batters;

create table mlb.batters
select g.gameID, b.id as eliasID,  
       b.ab, b.h, b.bb, b.hbp, b.sf, b.so, 
			 b.hr, b.d as 2B, b.t as 3B, 
			 b.r, b.rbi, b.lob,
			 b.bo as battingOrder
 from gameday.batters b, mlb.games g
where b.gameName = g.gameName
group by g.gameID, b.id;

ALTER TABLE mlb.batters
 ADD PRIMARY KEY (gameID, eliasID);



################################# atbats
create table mlb.tAtBats
select *
  from gameday.atbats;
  
ALTER TABLE mlb.tAtBats
  ADD tempID INT(6) UNSIGNED AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (tempID);
  
create table mlb.tOrderedAtBats
select max(a.tempID) as tempID,
       a.gameName,
			 a.inning,
			 a.halfInning,
			 a.num as gamedayAtBatID
  from mlb.tAtBats a
 group by a.gameName, a.inning, a.halfInning, a.num
 order by a.gameName, a.num;
 
set @inningAtBatID:=1;
set @previousInning:="";
set @previousHalfInning:="";

create table mlb.tAtbatOrder
select a.tempID,
       a.gameName, 
       @inningAtBatID:=if(@previousInning=a.inning and 
                          @previousHalfInning=a.halfInning,
			                    @inningAtBatID+1,1) as halfInningAtBatID,
       @previousInning:=a.inning,
       @previousHalfInning:=a.halfInning,
			 a.inning,
			 a.halfInning,
			 a.gamedayAtBatID
  from mlb.tOrderedAtbats a;
 
drop table if exists mlb.tOrderedAtbats;
drop table if exists mlb.atbats;

create table mlb.atbats
select g.gameID, 
       ao.inning,
			 ao.halfInning,
			 ao.halfInningAtBatID,
			 a.eventNumber, 
       ao.gamedayAtBatID, 
			 a.event as playResult, a.des as description,
			 a.batter as batterID, a.pitcher as pitcherID,
			 a.p_throws as pitcherHand, a.stand as batterHand,
       a.o outs, a.b as balls, a.s strikes, 
			 a.b_height as batterHeight
  from mlb.tAtBats a, mlb.tAtbatOrder ao, mlb.games g
 where a.gameName = g.gameName
   and a.tempID = ao.tempID;

ALTER TABLE mlb.atbats
 ADD atbatID INT(6) UNSIGNED AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (atbatID);

create unique index gameAtBat on mlb.atbats (gameID, atbatID);
create index gamedayAtBat on mlb.atbats (gamedayAtBatID);

drop table if exists mlb.tAtbatOrder;
drop table if exists mlb.tAtBats;



################################# atbat results
drop table if exists mlb.atbatResults;

create table mlb.atbatResults
select a.atbatID,
			 
	 IF(a.playResult REGEXP 'Home Run' or  
	    a.playResult REGEXP 'Single' or 
	    a.playResult REGEXP 'Double' or 
	    a.playResult REGEXP 'Triple', 1, 0) as hit,

	 IF(a.playResult REGEXP 'Ground' or 
	    a.playResult REGEXP 'Home Run' or 
	    a.playResult REGEXP 'Line' or 
	    a.playResult REGEXP 'Double Play' or 
	    a.playResult REGEXP 'Fielders Choice' or 
	    a.playResult REGEXP 'Single' or 
	    a.playResult REGEXP 'Sac' or 
	    a.playResult REGEXP 'Double' or 
	    a.playResult REGEXP 'Fly' or 
	    a.playResult REGEXP 'Force Out' or 
	    a.playResult REGEXP 'Field Error' or 
	    a.playResult REGEXP 'Pop' or 
	    a.playResult REGEXP 'Triple' or  
	    a.playResult REGEXP 'Fan interference' or
	    a.playResult REGEXP 'Triple Play', 1, 0) as inPlay,

	 IF(a.playResult REGEXP 'Out' or 
	    a.playResult REGEXP 'Sac' or 
	    a.playResult REGEXP 'Grounded Into DP' or 
	    a.playResult REGEXP 'Double Play' or 
	    a.playResult REGEXP 'Fielders Choice' or 
	    a.playResult REGEXP 'Batter Interference' or
			a.playResult REGEXP 'Triple Play', 1, 0) as out_,

	 IF(a.description REGEXP 'line drive' or 
	    a.description REGEXP 'lines', 1, 0) as lineDrive,

       IF(a.description REGEXP 'grounds out' or 
          a.description REGEXP 'ground ball' or 
          a.description REGEXP 'grounds into' or 
          a.description REGEXP 'ground bunts' or 
          a.description REGEXP 'sacrifice bunt' or 
          a.description REGEXP 'fielder\'s choice', 1, 0) as groundBall,
					
			 IF(a.description REGEXP 'fly ball' or 
          a.description REGEXP 'fly to' or 
          a.description REGEXP 'sacrifice fly' or 
          a.description REGEXP 'grand slam' or 
          a.description REGEXP 'flies into' or 
          a.description REGEXP 'flies out' or
					a.description REGEXP 'pops' or 
          a.description REGEXP 'pop up' or 
          a.description REGEXP 'bunt pop', 1, 0) as flyBall,
					
			 IF(a.description REGEXP 'pops' or 
          a.description REGEXP 'pop up' or 
          a.description REGEXP 'bunt pop', 1, 0) as popUp,
					
	 IF(a.description REGEXP 'in foul territory', 1, 0) as foulInPlay,
 	 IF(a.playResult = 'Strikeout', 1, 0) as strikeout,
	 IF(a.playResult = 'Ground Out', 1, 0) as groundout,
	 IF(a.playResult = 'Walk', 1, 0) as walk,
	 IF(a.playResult = 'Home Run', 1, 0) as hr,
	 IF(a.playResult = 'Line Out', 1, 0) as lineOut,
	 IF(a.playResult = 'Hit By Pitch', 1, 0) as hitByPitch,
	 IF(a.playResult = 'Single', 1, 0) as single,
	 IF(a.playResult = 'Sac Bunt', 1, 0) as sacrificeBunt,
	 IF(a.playResult = 'Double', 1, 0) as double_,
	 IF(a.playResult = 'Fly Out', 1, 0) as flyOut,
	 IF(a.playResult = 'Pop Out', 1, 0) as popOut,
	 IF(a.playResult = 'Grounded Into DP' 
	 or a.playResult = 'Grounded Into Double Play', 1, 0) as groundedIntoDoublePlay,
	 IF(a.playResult = 'Sac Fly', 1, 0) as sacrificeFly,
	 IF(a.playResult = 'Intent Walk', 1, 0) as intentionalWalk,
	 IF(a.playResult = 'Bunt Ground Out', 1, 0) as buntGroundOut,
	 IF(a.playResult = 'Force Out', 1, 0) as forceOut,
	 IF(a.playResult = 'Field Error', 1, 0) as error,
	 IF(a.playResult = 'Runner Out', 1, 0) as runnerOut,
	 IF(a.playResult = 'Triple', 1, 0) as triple,
	 IF(a.playResult = 'Double Play', 1, 0) as doublePlay,
	 IF(a.playResult = 'Fielders Choice', 1, 0) as fieldersChoice,
	 IF(a.playResult = 'Fielders Choice Out', 1, 0) as fieldersChoiceOut,
	 IF(a.playResult = 'Bunt Pop Out', 1, 0) as buntPopUp,
	 IF(a.playResult = 'Strikeout - DP'
	 or a.playResult = 'Strikeout - Double Play', 1, 0) as strikeoutDoublePlay,
	 IF(a.playResult = 'Fan interference', 1, 0) as fanInterference,
	 IF(a.playResult = 'Sac Fly DP'
	 or a.playResult = 'Sac Fly Double Play', 1, 0) as sacFlyDoublePlay,
	 IF(a.playResult = 'Batter Interference', 1, 0) as batterInterference,
	 IF(a.playResult = 'Triple Play', 1, 0) as triplePlay,
	 IF(a.playResult = 'Catcher Interference', 1, 0) as catcherInterference,
	 IF(a.playResult = 'Strikeout - TP', 1, 0) as strikeoutTriplePlay,
	 IF(a.playResult = 'Sacrifice Bunt DP', 1, 0) as sacrificeBuntDoublePlay
  from mlb.atbats a;

ALTER TABLE mlb.atbatResults
 ADD PRIMARY KEY (atbatID);
    

################################# pitcher order
create table mlb.tPitcherOrder
select a.gameID, r.teamID, a.pitcherID
  from mlb.atbats a, mlb.rosters r
 where a.pitcherID <> '0'
   and a.pitcherID = r.eliasID
	 and a.gameID = r.gameID
 group by gameID, teamID, pitcherID
 order by a.gameID, a.halfInning, a.inning, a.halfInningAtBatID;

create unique index iGameTeamPitcher on mlb.tPitcherOrder (gameID, teamID, pitcherID);

ALTER TABLE mlb.tPitcherOrder
 ADD rowID INT(5) AUTO_INCREMENT NOT NULL,
  ADD PRIMARY KEY (rowID);
	
set @pitcherOrder:=1;
set @previousGame:="";
set @previousTeam:="";
create table mlb.tPitcherOrderMaster
select @pitcherOrder:=if(@previousGame=tpo.gameID and 
                         @previousTeam=tpo.teamID,
			                   @pitcherOrder+1,1) as pitcherOrder,
       @previousGame:=tpo.gameID,
       @previousTeam:=tpo.teamID,
			 tpo.gameID, tpo.pitcherID
  from mlb.tPitcherOrder tpo
 order by tpo.rowID;
	
ALTER TABLE mlb.tPitcherOrderMaster
 ADD PRIMARY KEY (gameID, pitcherID);

drop table mlb.tPitcherOrder;

ALTER TABLE mlb.pitchers
 ADD pitcherOrder SMALLINT(2);

update mlb.pitchers p, mlb.tPitcherOrderMaster m
   set p.pitcherOrder = m.pitcherOrder
 where p.gameID = m.gameID
   and p.eliasID = m.pitcherID;

drop table mlb.tPitcherOrderMaster;
    
    
################################# pitches
drop table if exists mlb.pitches;

create table mlb.pitches
select a.atbatID, p.id as gamePitchID,
       p.des as description, 
	 IF(p.type = "S", 1, 0) as 'strikeOrFoul', 
	 IF(p.type = "B", 1, 0) as 'ball', 
	 IF(p.type = "X", 1, 0) as 'inPlay', 
	 p.x,
	 p.y,
	 start_speed as 'Speed',  
   CASE p.pitch_type 
      WHEN "SC" THEN 'Screwball' 
      WHEN "EP" THEN 'Ephuus' 
      WHEN "KC" THEN 'KnuckleCurve' 
      WHEN "FO" THEN 'Forkball' 
      WHEN "FT" THEN 'TwoSeamFastball' 
      WHEN "FS" THEN 'Splitter' 
      WHEN "SL" THEN 'Slider' 
      WHEN "FF" THEN 'FourSeamFastball' 
      WHEN "SI" THEN 'Sinker' 
      WHEN "CH" THEN 'ChangeUp' 
      WHEN "FA" THEN 'Fastball' 
      WHEN "CU" THEN 'Curve' 
      WHEN "FC" THEN 'Cutter' 
      WHEN "KN" THEN 'Knuckle' 
      WHEN "IN" THEN 'IntentionalBall' 
      WHEN "UN" THEN '' 
      WHEN null THEN '' 
      ELSE p.pitch_type 
      END as type,
   IF(p.pitch_type = "SC", 1, 0) as 'Screwball',
   IF(p.pitch_type = "EP", 1, 0) as 'Ephuus',
   IF(p.pitch_type = "KC", 1, 0) as 'KnuckleCurve',
   IF(p.pitch_type = "FO", 1, 0) as 'Forkball',
   IF(p.pitch_type = "FT", 1, 0) as 'TwoSeamFastball',
   IF(p.pitch_type = "FS", 1, 0) as 'Splitter', 
	 IF(p.pitch_type = "SL", 1, 0) as 'Slider', 
	 IF(p.pitch_type = "FF", 1, 0) as 'FourSeamFastball', 
	 IF(p.pitch_type = "SI", 1, 0) as 'Sinker', 
	 IF(p.pitch_type = "CH", 1, 0) as 'ChangeUp', 
	 IF(p.pitch_type = "FA", 1, 0) as 'Fastball', 
	 IF(p.pitch_type = "CU", 1, 0) as 'Curve', 
	 IF(p.pitch_type = "FC", 1, 0) as 'Cutter', 
	 IF(p.pitch_type = "KN", 1, 0) as 'Knuckle', 
	 IF(p.pitch_type = '', 1, 0) as 'Unknown', 
       p.type_confidence as 'Confidence',
       sz_top as 'KZTop', 
       sz_bot as 'KZBottom',
       px as 'HorizPlateCross', 
       pz as 'VertPlateCrosss',
			 IF(abs(px*12) < 17/2+1.45 AND pz > sz_bot AND pz < sz_top, 1, 0) as 'TheoreticalStrike',
       IF(abs(px*12) >= 17/2+1.45 OR pz <= sz_bot OR pz >= sz_top, 1, 0) as 'TheoreticalBall',   
			 IF(
			    ((px <= 0 AND abs(px*12) >= (17/2+1.45)/2) AND a.batterHand = 'R') OR
					((px >  0 AND abs(px*12) >= (17/2+1.45)/2) AND a.batterHand = 'L'), 1, 0) as hInside,
			 IF(
			    ((px >  0 AND abs(px*12) >= (17/2+1.45)/2) AND a.batterHand = 'R') OR
					((px <= 0 AND abs(px*12) >= (17/2+1.45)/2) AND a.batterHand = 'L'), 1, 0) as hOutside,
			 IF(abs(px*12) < (17/2+1.45)/2, 1, 0) as hMiddle,
			 IF(pz >= sz_top - (sz_top-sz_bot) / 4, 1, 0) as vHigh,
			 IF(pz <= sz_bot + (sz_top-sz_bot) / 4, 1, 0) as vLow,
			 IF(pz < sz_top - (sz_top-sz_bot) / 4 AND pz > sz_bot + (sz_top-sz_bot) / 4, 1, 0) as vMiddle,
       '                      ' as Position,
       pfx_x as 'HorzMovement', 
       pfx_z as 'VertMovement', 
       break_y as 'DistanceBreakOccurs', 
       break_angle as 'BreakAngle', 
       break_length as 'BreakLength',
	 p.x0 as releasePointHorz,
	 p.y0 as releasePointDistance,
	 p.z0 as releasePointVert,
	 p.vx0 as releasePointVelocityHorz,
	 p.vy0 as releasePointVelocityDistance,
	 p.vz0 as releasePointVelocityVert,
	 p.ax as releasePointAccelerationHorz,
	 p.ay as releasePointAccelerationDistance,
	 p.az as releasePointAccelerationVert,
	 p.on_1B as on1B,
	 p.on_2B as on2B,
	 p.on_3B as on3B,
	 p.play_guid
  from gameday.pitches p, mlb.games g, mlb.atbats a
 where p.gameName = g.gameName
   and g.gameID = a.gameID
	 and p.gameAtBatID = a.gamedayAtBatID;
	
ALTER TABLE mlb.pitches
 ADD pitchID INT(6) UNSIGNED AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (pitchID);
	
create unique index atbatPitch on mlb.pitches (atbatID, pitchID);
create index atbat on mlb.pitches (atbatID);

update mlb.pitches p
   set p.Position = CONCAT(IF(p.vHigh = 1, 'High', IF(p.vLow = 1, 'Low', 'Middle')),
	              ' ',
	              IF(p.hInside = 1, 'Inside', IF(p.hOutside = 1, 'Outside', 'Middle')));     

								
############################## pitch sequence
ALTER TABLE mlb.pitches
 ADD pitchSequence SMALLINT(3),
 ADD balls SMALLINT(1),
 ADD strikes SMALLINT(1);
 
create table mlb.tOrderedAtbatPitchSequence 
select a.gameID, a.atbatID, p.pitchID, p.ball, p.strikeOrFoul
  from mlb.pitches p, mlb.atbats a
 where p.atbatID = a.atbatID
 order by a.gameID, a.atbatID, p.gamePitchID;

set @pitchSequence:=1;
set @previousGame:=null;
set @previousAtBatID:="";
set @newballs:=0;
set @newstrikes:=0;
create table mlb.tNumberedAtBats
select @pitchSequence:=if(@previousGame=p.gameID 
                          and @previousAtBatID=p.atbatID,
		       @pitchSequence+1,1) as pitchSequence,
											 
       p.ball,
       if(@previousGame=p.gameID and @previousAtBatID=p.atbatID,
		@newballs,
		0) as balls,
       @newballs:=if(@previousGame=p.gameID and @previousAtBatID=p.atbatID,
			@newballs + p.ball,
			0 + p.ball) as newballs,
									
       p.strikeOrFoul,
       if(@previousGame=p.gameID and @previousAtBatID=p.atbatID and @previousGame is not null,
		@newstrikes,
		0) as strikes,
       @newstrikes:=if(@previousGame=p.gameID and @previousAtBatID=p.atbatID and @previousGame is not null,
			@newstrikes + p.strikeOrFoul,
			0 + p.strikeOrFoul) as newstrikes,
										
       @previousGame:=p.gameID,
       @previousAtBatID:=p.atbatID,
       p.pitchID
  from mlb.tOrderedAtbatPitchSequence p;

ALTER TABLE mlb.tNumberedAtBats
 ADD PRIMARY KEY (pitchID);
	
update mlb.pitches p, mlb.tNumberedAtBats t
   set p.pitchSequence = t.pitchSequence, 
	     p.balls         = t.balls,
			 p.strikes       = t.strikes
 where p.pitchID = t.pitchID;
 
drop table if exists mlb.tOrderedAtbatPitchSequence;
drop table if exists mlb.tNumberedAtBats;


############################## pitch location
drop table if exists mlb.pitchLocation;

create table mlb.pitchLocation
select p.pitchID,
       IF((p.vHigh = 1 OR p.vLow = 1 OR p.hInside = 1 OR p.hOutside = 1)
					 AND (p.TheoreticalStrike = 1), 1, 0) as qualityStrike,
       IF(p.vHigh = 1 AND p.hInside = 1, 1, 0) as pHighAndInside,
       IF(p.vHigh = 1 AND p.hInside = 1 AND p.TheoreticalStrike = 1, 1, 0) as pHighAndInsideStrike,
       IF(p.vMiddle = 1 AND p.hInside = 1, 1, 0) as pMiddleAndInside,
       IF(p.vMiddle = 1 AND p.hInside = 1 AND p.TheoreticalStrike = 1, 1, 0) as pMiddleAndInsideStrike,
       IF(p.vLow = 1 AND p.hInside = 1, 1, 0) as pLowAndInside,
       IF(p.vLow = 1 AND p.hInside = 1 AND p.TheoreticalStrike = 1, 1, 0) as pLowAndInsideStrike,
       IF(p.vHigh = 1 AND p.hMiddle = 1, 1, 0) as pHighAndMiddle,
       IF(p.vHigh = 1 AND p.hMiddle = 1 AND p.TheoreticalStrike = 1, 1, 0) as pHighAndMiddleStrike,
       IF(p.vMiddle = 1 AND p.hMiddle = 1, 1, 0) as pMiddleAndMiddle,
       IF(p.vMiddle = 1 AND p.hMiddle = 1 AND p.TheoreticalStrike = 1, 1, 0) as pMiddleAndMiddleStrike,
       IF(p.vLow = 1 AND p.hMiddle = 1, 1, 0) as pLowAndMiddle,
       IF(p.vLow = 1 AND p.hMiddle = 1 AND p.TheoreticalStrike = 1, 1, 0) as pLowAndMiddleStrike,
       IF(p.vHigh = 1 AND p.hOutside = 1, 1, 0) as pHighAndOutside,
       IF(p.vHigh = 1 AND p.hOutside = 1 AND p.TheoreticalStrike = 1, 1, 0) as pHighAndOutsideStrike,
       IF(p.vMiddle = 1 AND p.hOutside = 1, 1, 0) as pMiddleAndOutside,
       IF(p.vMiddle = 1 AND p.hOutside = 1 AND p.TheoreticalStrike = 1, 1, 0) as pMiddleAndOutsideStrike,
       IF(p.vLow = 1 AND p.hOutside = 1, 1, 0)as pLowAndOutside,
       IF(p.vLow = 1 AND p.hOutside = 1 AND p.TheoreticalStrike = 1, 1, 0) as pLowAndOutsideStrike
  from mlb.pitches p
 where p.Speed > 0;
 
ALTER TABLE mlb.pitchLocation
 ADD PRIMARY KEY (pitchID);


############################## pitch result
drop table if exists mlb.pitchResult;
	
create table mlb.pitchResult
select p.pitchID,
       IF(p.description REGEXP 'Ball', 1, 0) as ball,
       IF(p.description REGEXP 'In play', 1, 0) as inPlay,
       IF(p.description REGEXP 'In play, out', 1, 0) as `out`,
       IF(p.description REGEXP 'In play' or 
	        p.description REGEXP 'Swinging' or 
	        p.description REGEXP 'Foul' or 
	        p.description REGEXP 'Pitchout in play' or 
	        p.description REGEXP 'Missed', 1, 0) as swung,
			 IF(p.description REGEXP 'Foul', 1, 0) as foul,
       IF(p.description REGEXP 'Swinging Strike' or  
	        p.description REGEXP 'Missed', 1, 0) as whiff,
       IF(p.description REGEXP 'Foul Bunt' or  
	        p.description REGEXP 'Missed Bunt', 1, 0) as missedOrFoulBuntAttempt,
       IF(p.description REGEXP 'Called Strike', 1, 0) as calledStrike,
       IF(p.description REGEXP 'Ball In Dirt', 1, 0) as ballInDirt,
       IF(p.description REGEXP 'Blocked Ball in Dirt', 1, 0) as blockedBallInDirt,
       IF(p.description REGEXP 'Swinging Strike (Blocked)', 1, 0) as swingingStrikeBlocked,
       IF(p.description REGEXP 'Unknown Strike', 1, 0) as unknownStrike,
       IF(p.description REGEXP 'Hit By Pitch', 1, 0) as hitByPitch,
       IF(p.description REGEXP 'Intent Ball', 1, 0) as intentionalBall,
       IF(p.description REGEXP 'Automatic Ball', 1, 0) as automaticBall,
       IF(p.description REGEXP 'Pitchout', 1, 0) as pitchout,
       IF(p.description REGEXP 'Pickoff Attempt 1B', 1, 0) as pickoff1st,
       IF(p.description REGEXP 'Pickoff Attempt 2B', 1, 0) as pickoff2nd,
       IF(p.description REGEXP 'Pickoff Attempt 3B', 1, 0) as pickoff3rd,
       IF(p.description REGEXP 'Pickoff Attempt 1B' or 
	        p.description REGEXP 'Pickoff Attempt 2B' or 
	        p.description REGEXP 'Pickoff Attempt 3B', 1, 0) as pickoff
  from mlb.pitches p
 where p.Speed > 0;
 
ALTER TABLE mlb.pitchResult
 ADD PRIMARY KEY (pitchID);



################################# hit chart
create table mlb.tHitChart
select g.gameID, h.*
  from gameday.hits h, mlb.games g
 where h.gameName = g.gameName
   and h.type <> 'E'
 order by g.gameID, h.inning, h.hitID;

set @inningAtBatID:=1;
set @previousGame:="";
set @previousInning:="";
set @previousHitID:="";
create table mlb.tNumberedHitChart
select @inningAtBatID:=if(@previousGame=t.gameID and 
                          @previousInning=t.inning and 
                          @previousHitID<>t.hitID,
			  @inningAtBatID+1,1) as inningAtBat,
       @previousGame:=t.gameID,
       @previousInning:=t.inning,
       @previousHitID:=t.hitID,
       t.*
  from mlb.tHitChart t;
	
drop table mlb.tHitChart;

create table mlb.tOrderedAtBats
select a.gameID, a.inning, a.batterID, a.pitcherID, a.atbatID
  from mlb.atbats a, mlb.atbatresults ar
 where a.atbatID = ar.atbatID
   and ar.inPlay = 1
 order by a.gameID, a.inning, a.atbatID;

set @inningAtBatID:=1;
set @previousGame:="";
set @previousInning:="";
set @previousAtBatID:="";
create table mlb.tNumberedAtBats
select @inningAtBatID:=if(@previousGame=t.gameID 
                          and @previousInning=t.inning
                          and @previousAtBatID<>t.atbatID,
			                 @inningAtBatID+1,1) as inningAtBat,
       @previousGame:=t.gameID,
       @previousInning:=t.inning,
       @previousAtBatID:=t.atbatID,
       t.*
  from mlb.tOrderedAtBats t;

drop table mlb.tOrderedAtBats;

ALTER TABLE mlb.tNumberedHitChart
 ADD PRIMARY KEY (gameID, inning, batter, pitcher, inningAtBat);
ALTER TABLE mlb.tNumberedAtBats
 ADD PRIMARY KEY (gameID, inning, batterID, pitcherID, inningAtBat);
	
	
drop table if exists mlb.tStringHits;
-- 210 is the y of home plate, so 5 is a long long long long home run
-- 125 is the x of home plate
-- the y is turned into a positive value starting from 210
-- the x is turned into a positive/negative left right value with 125 becoming 0
create table mlb.tStringHits
select ta.atbatID,
       t.x - 125 as x, 
			 210 - t.y as y,
       SQRT(POWER((210 - t.y), 2) + POWER(abs(t.x - 125), 2)) as distance,
       t.type as outHitError, 
			 t.des as description
  from mlb.tNumberedHitChart t, mlb.tNumberedAtBats ta
 where t.gameID = ta.gameID
   and t.inning = ta.inning
   and t.batter = ta.batterID
   and t.pitcher = ta.pitcherID
   and t.inningAtBat = ta.inningAtBat;


DROP TABLE IF EXISTS mlb.hits;
create table mlb.hits
select ab.atbatID,
       p.pitchID,
       ph.angle, ph.direction, ph.distance as statcastDistance, ph.speed,
       h.x, h.y, h.distance as stringerDistance, h.outHitError, h.description
  from gameday.pregumbohits ph, 
       mlb.pitches p,
       mlb.atbats ab left join mlb.tStringHits h on h.atbatID = ab.atbatID
 where ph.play_guid = p.play_guid
   and p.atbatID = ab.atbatID;

ALTER TABLE mlb.hits
 ADD PRIMARY KEY (atbatID, pitchID);

drop table mlb.tNumberedAtBats;
drop table mlb.tNumberedHitChart;
drop table mlb.tStringHits;
	
	
############################## umpires
drop table if exists mlb.umpires;

CREATE TABLE mlb.umpires AS
SELECT name, id as gamedayID
  from gameday.umpires
 where id is not null
   and name is not null
	 and name <> '--NO UMP--'
 group by name, id;
 
insert into mlb.umpires
SELECT name, id as gamedayID
  from gameday.umpires u
 where id is null
   and u.name not in (select name from mlb.umpires mu)
   and name is not null
	 and name <> '--NO UMP--'
 group by name, id;

ALTER TABLE mlb.umpires
 ADD umpID INT(6) UNSIGNED AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (umpID);


############################## ump rosters
CREATE TABLE mlb.tFirstUmps
select g.gameID, mu.umpID
  from mlb.umpires mu, gameday.umpires u, mlb.games g
 where u.gameName = g.gameName
   and mu.name = u.name
   and u.position = 'first'
   group by g.gameID;

CREATE TABLE mlb.tSecondUmps
select g.gameID, mu.umpID
  from mlb.umpires mu, gameday.umpires u, mlb.games g
 where u.gameName = g.gameName
   and mu.name = u.name
   and u.position = 'second'
   group by g.gameID;
	 
CREATE TABLE mlb.tThirdUmps
select g.gameID, mu.umpID
  from mlb.umpires mu, gameday.umpires u, mlb.games g
 where u.gameName = g.gameName
   and mu.name = u.name
   and u.position = 'third'
   group by g.gameID;
	 
CREATE TABLE mlb.tHomeUmps
select g.gameID, mu.umpID
  from mlb.umpires mu, gameday.umpires u, mlb.games g
 where u.gameName = g.gameName
   and mu.name = u.name
   and u.position = 'home'
   group by g.gameID;
	 
drop table if exists mlb.umpRosters;

create table mlb.umpRosters
select tf.gameID, tf.umpID as firstUmp, ts.umpID as secondUmp, tt.umpID as thirdUmp, th.umpID as homeUmp
  from mlb.tFirstUmps tf, mlb.tSecondUmps ts, mlb.tThirdUmps tt, mlb.tHomeUmps th
 where tf.gameID = ts.gameID
   and tf.gameID = tt.gameID
	 and tf.gameID = th.gameID;

ALTER TABLE mlb.umpRosters
 ADD PRIMARY KEY (gameID);
	
DROP TABLE mlb.tthirdumps;
DROP TABLE mlb.tsecondumps;
DROP TABLE mlb.tfirstumps;
DROP TABLE mlb.thomeumps;

  
################################# game conditions
drop table if exists mlb.gameConditions;

create table mlb.gameConditions
select g.gameID, gc.attendence, gc.gameLength, 
       gc.forecast, gc.temperature, gc.windDirection, gc.windMPH
  from gameday.gameConditions gc, mlb.games g
 where gc.gameName = g.gameName;

ALTER TABLE mlb.gameConditions
 ADD PRIMARY KEY (gameID);
 
 
################################# coaches
drop table if exists mlb.coaches;

create table mlb.coaches
select c.id as gamedayID, c.first, c.last, c.num as number
  from gameday.coaches c
 group by c.id, c.first, c.last, c.num;
 
ALTER TABLE mlb.coaches
 ADD coachID INT(6) UNSIGNED AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (coachID);
  
  
################################# coachRosters
drop table if exists mlb.coachRosters;

create table mlb.coachRosters
select g.gameID, t.teamID, mc.coachID, c.position
  from mlb.games g, gameday.coaches c, mlb.coaches mc, mlb.teams t
 where g.gameName = c.gameName
   and g.gameYear = t.seasonYear
   and c.id = mc.gamedayID
	 and c.team = t.abbreviation; 
 

################################# actions
drop table if exists mlb.actions;

create table mlb.actions
select g.gameID, a.inning, a.halfInning, a.eventNumber, a.o as outs, a.b as balls, a.s as strikes, 
       p.eliasID, a.pitch, a.event, a.des as description
  from gameday.action a, mlb.games g, mlb.players p
 where a.gameName = g.gameName
   and a.player = p.eliasID;
 
ALTER TABLE mlb.actions
 ADD actionID INT(6) UNSIGNED AUTO_INCREMENT FIRST,
  ADD PRIMARY KEY (actionID);
  
  

################################# batter hand
drop table if exists mlb.batterHand;
create table mlb.batterHand
select gameYear, batterID, 
       IF((leftAtBats / atbats > .05) and (rightAtBats / atbats > .05), 
			    'S', 
					IF(leftAtBats > rightAtBats, 'L', 'R')
				 ) as batterHand
  from (
select g.gameYear, a.batterID, 
       sum(IF(a.batterHand = 'L', 1, 0)) leftAtBats, 
       sum(IF(a.batterHand = 'R', 1, 0)) rightAtBats, 
       count(a.batterHand) atBats
  from mlb.atbats a, mlb.games g
 where a.gameID = g.gameID
   and a.batterID is not null
   and a.gameID is not null
 group by a.batterID, g.gameYear
 ) handCount;

ALTER TABLE mlb.batterHand
 ADD PRIMARY KEY (gameYear, batterID);
 


################################# player demographics
DROP TABLE IF EXISTS mlb.playerBios;

create table mlb.playerBios
select p.eliasID,
       pb.team,
			 SUBSTR(pb.gameName, 5, 4) as playingYear,
			 pb.weight, pb.heightFeet, pb.heightInches,
			 pb.dob, pb.pos, pb.jersey_number as jerseyNumber,
			 pb.bats, pb.throws
  from gameday.playerBios pb, mlb.players p
 where pb.id = p.eliasID
 group by pb.id, pb.team, SUBSTR(pb.gameName, 5, 4);