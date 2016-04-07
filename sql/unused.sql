########################removing dups in mysql
-- delete from mlb.games
-- USING mlb.games, mlb.games as vtable
-- WHERE (mlb.games.gameID > vtable.gameID)
--   AND (mlb.games.gameName=vtable.gameName);


################################# retrosheet events
set @retrosheetEventID:=0;
set @previousGame:="";
create table mlb.tRetrosheetEvents
select @retrosheetEventID:=if(@previousGame=gameID,
			 @retrosheetEventID+1,0) as retrosheetEventID,
       @previousGame:=gameID,
       retrosheetEvents.*
  from (
select a.gameID, a.eventNumber, 
       'action' as type, 
       a.actionID as id
  from mlb.actions a
 where a.event REGEXP 'Stolen Base' or
	a.event REGEXP 'Pickoff' OR
	a.event REGEXP 'Wild Pitch' OR
	a.event REGEXP 'Passed Ball' OR
	a.event REGEXP 'Error' OR
	a.event REGEXP 'Caught Stealing' OR
	a.event REGEXP 'Picked off' OR
	a.event REGEXP 'Runner Out' OR
	a.event REGEXP 'Balk' OR
	a.event REGEXP 'Defensive Indiff' OR
	a.event REGEXP 'steals' OR
	a.event REGEXP 'caught stealing' OR
	a.event REGEXP 'picks off' OR
	a.event REGEXP 'out at'
union
select ab.gameID, ab.eventNumber, 'atbat' as type, ab.atbatID as id
  from mlb.atbats ab
order by gameID, eventNumber
) retrosheetEvents;

drop table if exists mlb.retrosheetEvents;

create table mlb.retrosheetEvents
select tre.gameID, tre.eventNumber, type, id
  from mlb.tRetrosheetEvents tre;

ALTER TABLE mlb.retrosheetEvents
 ADD PRIMARY KEY (gameID, eventNumber);
	
drop table if exists mlb.tRetrosheetEvents;









################################# hart 08
select a.atbatID, 'allCoreyHartAtBats', 'hart08'
  from mlb.atbats a, mlb.players p, mlb.games g
 where a.batterID = p.eliasID
   and a.gameID = g.gameID
   and p.last = 'Hart'
	 and p.first = 'Corey'
	 and g.gameType = 'regular'
	 and g.gameYear = 2008;
	 
insert into ssfbl.atbatsubset 
select a.atbatID, 'firstPitchSwingingCoreyHartAtBats', 'hart08'
  from mlb.atbats a, mlb.players p, mlb.games g, mlb.pitches pt, mlb.pitchResult pr
 where a.batterID = p.eliasID
   and a.gameID = g.gameID
   and p.last = 'Hart'
	 and p.first = 'Corey'
	 and g.gameType = 'regular'
	 and g.gameYear = 2008
	 and a.atbatID = pt.atbatID
	 and pt.pitchSequence = 1
	 and pt.pitchID = pr.pitchID
	 and pr.swung = 1;

insert into ssfbl.atbatsubset 
select a.atbatID, 'firstPitchSwingingBrewers', 'hart08'
  from mlb.atbats a, mlb.games g, mlb.pitches pt, mlb.pitchResult pr, mlb.rosters r, mlb.teams t
 where a.gameID = g.gameID
   and a.batterID = r.eliasID
	 and g.gameID = r.gameID
	 and r.teamID = t.teamID
	 and t.name = 'Milwaukee Brewers'
	 and g.gameType = 'regular'
	 and g.gameYear = 2008
	 and a.atbatID = pt.atbatID
	 and pt.pitchSequence = 1
	 and pt.pitchID = pr.pitchID
	 and pr.swung = 1;

insert into ssfbl.atbatsubset 
select a.atbatID, 'allBrewers', 'hart08'
  from mlb.atbats a, mlb.games g, mlb.rosters r, mlb.teams t
 where a.gameID = g.gameID
   and a.batterID = r.eliasID
	 and g.gameID = r.gameID
	 and r.teamID = t.teamID
	 and t.name = 'Milwaukee Brewers'
	 and g.gameType = 'regular'
	 and g.gameYear = 2008;

insert into ssfbl.atbatsubset 
select a.atbatID, 'allNL', 'hart08'
  from mlb.atbats a, mlb.games g
 where a.gameID = g.gameID
   and g.league = 'NL'
	 and g.gameType = 'regular'
	 and g.gameYear = 2008;

insert into ssfbl.atbatsubset 
select a.atbatID, 'firstPitchSwingingAllNL', 'hart08'
  from mlb.atbats a, mlb.games g, mlb.pitches pt, mlb.pitchResult pr
 where a.gameID = g.gameID
   and g.league = 'NL'
	 and g.gameType = 'regular'
	 and g.gameYear = 2008
	 and a.atbatID = pt.atbatID
	 and pt.pitchSequence = 1
	 and pt.pitchID = pr.pitchID
	 and pr.swung = 1;
	 
	 
	 
	 
	 
########## analyse a particular pitcher
select pl.last as pitcher, batter.last as batter, p.pitchSequence, 
       p.type as type, p.Speed, p.TheoreticalStrike strike, p.Position, 
			 p.HorzMovement, p.VertMovement, 
			 p.description pitchResult, ab.description atbatResult
  from mlb.players pl, mlb.atbats ab, mlb.pitches p, mlb.players batter
 where pl.last = 'Parra'
   and pl.first = 'Manny'
	 and ab.pitcherID = pl.eliasID
	 and p.atbatID = ab.atbatID
	 and ab.batterID = batter.eliasID
 order by ab.gameID asc, ab.atbatID asc, p.pitchID asc
 
 
 select pl.last as pitcher,
        p.type as type, 
        g.gameYear,
        avg(p.Speed), 
 			 avg(p.HorzMovement), avg(p.VertMovement)
   from mlb.players pl, mlb.atbats ab, mlb.pitches p, mlb.games g
  where pl.last = 'Maholm'
    -- and pl.first = 'Manny'
 	 and ab.pitcherID = pl.eliasID
 	 and p.atbatID = ab.atbatID
    and ab.gameID = g.gameID
    group by pl.last, p.type, g.gameYear
   order by p.type asc, g.gameYear desc 
   
   
   
   
   
########### Spring pitch speeds
-- drop table mlb.tSpringers;
create table mlb.tSpringers as
select sub.eliasID from (
              select pl.eliasID, count(p.pitchID) as cnt
                        from mlb.players pl, mlb.atbats ab, mlb.games g, mlb.pitches p
                      where 
                        ab.pitcherID = pl.eliasID
                        and ab.gameID = g.gameID
                        and p.atbatID = ab.atbatID
                        and p.Speed is not null
                        and g.gameYear = 2013 
                        and g.gameType = 'spring'
                      group by pl.eliasID
                        ) sub,
                        ssfbl.ssfblplayers sp
                  where sp.eliasID = sub.eliasID
                    
                     
                        
                        -- select count(*) from mlb.tSpringers
                        -- select count(*) from ssfbl.ssfblplayers
                        
                        
           
           
select * from (
select pl.eliasID, pl.last,
       pl.first,
       g.gameYear,
       g.gameType,
       p.type as type, 
			 count(p.speed) as pitches,
       avg(p.Speed), 
			 avg(p.HorzMovement), avg(p.VertMovement)
  from mlb.players pl, mlb.atbats ab, mlb.pitches p, mlb.games g
 where -- pl.last = 'Maholm'
   -- and pl.first = 'Manny'
	 -- and 
   ab.pitcherID = pl.eliasID
	 and p.atbatID = ab.atbatID
   and ab.gameID = g.gameID
   and (
        (g.gameYear = 2014 and g.gameType = 'spring') 
         or 
        (g.gameYear = 2013 and g.gameType = 'regular')
         or 
        (g.gameYear = 2013 and g.gameType = 'spring')
       )
   and p.Speed is not null
   group by pl.eliasID, pl.last, pl.first, g.gameYear, g.gameType, p.type
   order by pl.last, pl.first, p.type asc, g.gameYear desc 
   ) sub, mlb.tSpringers
   where sub.eliasID = tSpringers.eliasID
   
   
   
   
   
---------- spring stats
select p.eliasID, p.last, p.first, 
       sum(abr.out_) / 3 as IP,
       (sum(abr.strikeout) * 9) / (sum(abr.out_) / 3) as Kp9,
       (sum(abr.walk) * 9) / (sum(abr.out_) / 3) as BBp9,
       sum(abr.strikeout) / sum(abr.walk) as k2bb,
       sum(abr.groundBall) / sum(abr.inPlay) as groundP,
       '      ' as spacer,
       count(abr.atbatID) as atbats,
       sum(abr.strikeout) k,
       sum(abr.walk) as bb
  from mlb.atbatresults abr, mlb.atbats ab, mlb.players p, mlb.games g
 where p.eliasID = ab.pitcherID
   and ab.atbatID = abr.atbatID
   and ab.gameID = g.gameID
   and g.gameType = 'spring'
   and g.gameYear = 2013
 group by p.eliasID, p.last, p.first