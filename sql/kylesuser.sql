################################# create the mlb/pitchfx database
DROP DATABASE IF EXISTS `ssfbl`;
 CREATE DATABASE `ssfbl` /*!40100 DEFAULT CHARACTER SET latin1 */;
set @gameYear:=2015;

### change year!  at bottom too!  Spring stats

################################# game subsets
drop table if exists ssfbl.gameSubset;

create table ssfbl.gameSubset
select gameID, gameType as setName, "gameType" as subset, g.gameYear
  from mlb.games g
 where g.gameType <> ''
   and g.gameYear = @gameYear;
 
ALTER TABLE ssfbl.gamesubset
 CHANGE subset subset VARCHAR(20) NOT NULL;
ALTER TABLE ssfbl.gameSubset
 ADD PRIMARY KEY (gameID, setName, subset, gameYear);
 
create index iGameID on ssfbl.gameSubset (gameID);


################################# game subsets halfSeasons, midSeason
create table ssfbl.tGamesInSeason
select count(g.gameID) as gamesInSeason, g.gameYear
  from mlb.games g
 where g.gameType = 'regular'
 group by g.gameYear;

create table ssfbl.tOrderedGames
select g.gameID, g.gameYear
  from mlb.games g
 where g.gameType = 'regular'
 order by g.gameYear, g.gameDate, g.gameTime;

set @gameNumber:=0;
set @previousSeason:=1901;
create table ssfbl.tSeasonGameNumber
select @gameNumber:=if(@previousSeason=tog.gameYear, 
                       @gameNumber+1, 
		       0) as gameNumber,
       @previousSeason:=tog.gameYear,
       tog.gameID,
			 tog.gameYear
  from ssfbl.tOrderedGames tog;

			 
insert into ssfbl.gameSubset
select tsgn.gameID,
       if((tsgn.gameNumber < tgis.gamesInSeason / 2), 'firstHalf', 'secondHalf') as setName, 
       'half' as subset,
			 tsgn.gameYear
  from ssfbl.tSeasonGameNumber tsgn, ssfbl.tGamesInSeason tgis
 where tsgn.gameYear = tgis.gameYear
   and tsgn.gameYear = @gameYear;

			 
insert into ssfbl.gameSubset
select tsgn.gameID,
       if((tsgn.gameNumber < tgis.gamesInSeason / 4) or (tsgn.gameNumber >= tgis.gamesInSeason / 4 * 3),
			 if((tsgn.gameNumber < tgis.gamesInSeason / 4), 'start', 'end'), 
			 'middle') as setName, 
       'startMiddleEnd' as subset,
			 tsgn.gameYear
  from ssfbl.tSeasonGameNumber tsgn, ssfbl.tGamesInSeason tgis
 where tsgn.gameYear = tgis.gameYear
   and tsgn.gameYear = @gameYear;
 
 
drop table ssfbl.tGamesInSeason;
drop table ssfbl.tOrderedGames;
drop table ssfbl.tSeasonGameNumber; 


################################# game subsets all
insert into ssfbl.gameSubset
select g.gameID, "all" as setName, "all" as subset, g.gameYear
  from mlb.games g
 group by g.gameYear, g.gameID
   and g.gameYear = @gameYear;
 
 
################################# atbat subset
drop table if exists ssfbl.atbatSubset;

create table ssfbl.atbatSubset 
select a.atbatID, "all" as setName, "all" as subset
  from mlb.atbats a, mlb.games g
 where a.gameID = g.gameID
   and g.gameYear = @gameYear
union
select a.atbatID, a.pitcherHand as setName, "pitcherHand" as subset
  from mlb.atbats a, mlb.games g
 where a.gameID = g.gameID
   and g.gameYear = @gameYear
   and a.pitcherHand <> ''
union
select a.atbatID, a.batterHand as setName, "batterHand" as subset
  from mlb.atbats a, mlb.games g
 where a.gameID = g.gameID
   and g.gameYear = @gameYear
   and a.batterHand <> '';
 
ALTER TABLE ssfbl.atbatSubset
 ADD PRIMARY KEY (atbatID, setName, subset);
 
create index iAtBatID on ssfbl.atbatSubset (atbatID);


################################# combined subsets
drop table if exists ssfbl.subsets;

create table ssfbl.subsets
select asub.atbatID, 
       gs.gameYear,
       gs.setName   as gameSetName, 
       gs.subset    as gameSubset,
       asub.setName as atbatSetName, 
       asub.subset  as atbatSubset
  from ssfbl.atbatsubset asub, ssfbl.gamesubset gs, mlb.atbats a
 where gs.gameID = a.gameID
   and a.atbatID = asub.atbatID;
 
ALTER TABLE ssfbl.subsets
 ADD PRIMARY KEY (atbatID, gameYear, gameSetName, gameSubset, atbatSetName, atbatSubset);
 
create index iAtBatID on ssfbl.subsets (atbatID);


################################# ssfbl players
drop table if exists ssfbl.SSFBLPlayers;

create table ssfbl.SSFBLPlayers
select r.eliasID
  from mlb.rosters r, mlb.teams t, mlb.games g
 where r.teamID = t.teamID
   and r.gameID = g.gameID
	 # and (t.league = 'NL' or t.code = 'min' or t.code = 'det')
	 and (t.league = 'NL' or t.code = 'min')
   and g.gameType = 'regular'
   and g.gameYear = @gameYear
 group by r.eliasID;
 


############################ atbat level stats
drop table if exists ssfbl.pPitchingStats;
create table ssfbl.pPitchingStats
select ab.pitcherID, 
       s.gameSubset, s.gameSetName, s.atbatSubset, s.atbatSetName, s.gameYear,
			 count(abr.out_) as atbats,
			 sum(abr.hit) / sum(abr.inPlay) as babip,
			 sum(abr.inPlay) as inplay,
			 sum(abr.hit) as h,
			 sum(abr.out_) as outs,
			 sum(abr.walk) as walks,
			 sum(abr.strikeout) as ks, 
			 sum(abr.hr) as hrs
  from mlb.atbats ab, mlb.atbatresults abr, ssfbl.subsets s
 where ab.atbatID = abr.atbatID
   and ab.atbatID = s.atbatID
 group by ab.pitcherID, s.gameSubset, s.gameSetName, s.atbatSubset, s.atbatSetName, s.gameYear; 


################################# pitch results
drop table if exists ssfbl.pPitcherResults;
 create table ssfbl.pPitcherResults 
 select pit.eliasID, gs.gameYear, gs.subset, gs.setName, 
        (sum(pit.er) * 9) / (sum(pit.outs) / 3) as ERA,
				((sum(pit.hr) * 13) + (sum(pit.bb) * 3) - (sum(pit.so) * 2)) / (sum(pit.outs) / 3) + 3.2 as FIP,
        1 - sum(pit.er) / (sum(pit.hits) + sum(pit.bb)) as lobP,
        sum(pit.outs) as outs,
				sum(pit.outs) / 3 as ip,
				sum(pit.win) as w,
				sum(pit.loss) as l,
				sum(pit.save) as s,
				sum(pit.hits) as h,
				sum(pit.hr) as hr,
				sum(pit.bb) as bb,
				sum(pit.so) as k,
				sum(pit.er) as er,
        sum(pit.hits) + sum(pit.bb) - sum(pit.er) as lob,
				sum(pit.battersFaced) as battersFaced,
				sum(if(pit.pitcherOrder = 1,1,0)) as gamesStarted,
				sum(if(pit.pitcherOrder = 1, pit.outs, 0)) / 3 as ipInGamesStarted
   from mlb.pitchers pit, ssfbl.gamesubset gs
	where pit.gameID = gs.gameID
  group by pit.eliasID, gs.gameYear, gs.subset, gs.setName;



################################# pitch info by subset
drop table if exists ssfbl.pBySetPitchInfo;

create table ssfbl.pBySetPitchInfo
select a.pitcherID, gameYear, gameSubset, gameSetName, atbatSubset, atbatSetName,
          p.pitchID,
	        p.y, 
          p.x, 
          p.vMiddle, 
          p.vLow, 
          p.vHigh, 
          p.VertPlateCrosss, 
          p.VertMovement, 
          p.type, 
          p.TheoreticalStrike, 
          p.TheoreticalBall, 
          p.strikeOrFoul,
          p.Speed, 
          p.releasePointVert, 
          p.releasePointVelocityVert, 
          p.releasePointVelocityHorz, 
          p.releasePointVelocityDistance, 
          p.releasePointHorz, 
          p.releasePointDistance, 
          p.releasePointAccelerationVert, 
          p.releasePointAccelerationHorz, 
          p.releasePointAccelerationDistance, 
          p.Position, 
          p.pitchSequence, 
          p.KZTop, 
          p.KZBottom, 					
          p.Screwball, 
          p.Ephuus, 
          p.KnuckleCurve, 
          p.Forkball,  
          p.TwoSeamFastball, 
          p.Splitter, 
          p.Slider, 
          p.FourSeamFastBall, 
          p.Sinker, 
          p.ChangeUp, 
          p.FastBall, 
          p.Curve,  
          p.Cutter, 
          p.Knuckle, 
          p.Unknown, 
					
          p.hOutside, 
          p.HorzMovement, 
          p.HorizPlateCross, 
          p.hMiddle, 
          p.hInside, 
          p.gamePitchID,
          p.DistanceBreakOccurs, 
          p.description, 
          p.Confidence, 
          p.BreakLength, 
          p.BreakAngle, 
          p.ball, 
          p.atbatID, 
          pl.qualityStrike, 
          pl.pHighAndInside, 
          pl.pHighAndInsideStrike, 
          pl.pMiddleAndInside, 
          pl.pMiddleAndInsideStrike, 
          pl.pLowAndInside, 
          pl.pLowAndInsideStrike, 
          pl.pHighAndMiddle, 
          pl.pHighAndMiddleStrike, 
          pl.pMiddleAndMiddle, 
          pl.pMiddleAndMiddleStrike, 
          pl.pLowAndMiddle, 
          pl.pLowAndMiddleStrike, 
          pl.pHighAndOutside, 
          pl.pHighAndOutsideStrike, 
          pl.pMiddleAndOutside, 
          pl.pMiddleAndOutsideStrike, 
          pl.pLowAndOutside, 
          pl.pLowAndOutsideStrike, 
          pr.whiff, 
          pr.unknownStrike, 
          pr.swung, 
          pr.swingingStrikeBlocked, 
          pr.pitchout, 
          pr.pickoff3rd, 
          pr.pickoff2nd, 
          pr.pickoff1st, 
          pr.pickoff, 
          pr.out, 
          pr.missedOrFoulBuntAttempt, 
          pr.intentionalBall, 
          pr.inPlay, 
          pr.hitByPitch, 
          pr.foul, 
          pr.calledStrike, 
          pr.blockedBallInDirt, 
          pr.ballInDirt, 
          pr.automaticBall
  from ssfbl.subsets s, mlb.atbats a, mlb.pitches p, mlb.pitchlocation pl, mlb.pitchresult pr
 where s.atbatID = a.atbatID
   and a.atbatID = p.atbatID
	 and p.pitchID = pl.pitchID
	 and p.pitchID = pr.pitchID;

ALTER TABLE ssfbl.pBySetPitchInfo
 ADD PRIMARY KEY (pitchID, pitcherID, gameYear, gameSubset, gameSetName, atbatSubset, atbatSetName);
 
 
################################# pitch summary
drop table if exists ssfbl.pPitchSummary;

create table ssfbl.pPitchSummary
select p.pitcherID, p.gameYear, p.gameSubset, p.gameSetName, p.atbatSubset, p.atbatSetName,
     count(p.pitchID) as pitches,
     sum(p.vMiddle) as vMiddle, 
     sum(p.vLow) as vLow, 
     sum(p.vHigh) as vHigh, 
     sum(p.TheoreticalStrike) as TheoreticalStrike, 
     sum(p.TheoreticalBall) as TheoreticalBall, 
     sum(p.strikeOrFoul) as strikeOrFoul,  
     sum(p.Screwball) as Screwball, 
     sum(p.Ephuus) as Ephuus, 
     sum(p.KnuckleCurve) as KnuckleCurve, 
     sum(p.Forkball) as Forkball, 
     sum(p.TwoSeamFastball) as TwoSeamFastball, 
     sum(p.Splitter) as Splitter, 
     sum(p.Slider) as Slider, 
     sum(p.FourSeamFastBall) as FourSeamFastBall,
     sum(p.Sinker) as Sinker, 
     sum(p.ChangeUp) as ChangeUp, 
     sum(p.FastBall) as FastBall, 
     sum(p.Curve) as Curve, 
     sum(p.Cutter) as Cutter, 
     sum(p.Knuckle) as Knuckle,
     sum(p.Unknown) as Unknown, 
     sum(p.hOutside) as hOutside, 
     sum(p.hMiddle) as hMiddle, 
     sum(p.hInside) as hInside,  
     sum(p.ball) as ball, 
     sum(p.qualityStrike) as qualityStrike, 
     sum(p.pHighAndInside) as pHighAndInside, 
     sum(p.pHighAndInsideStrike) as pHighAndInsideStrike, 
     sum(p.pMiddleAndInside) as pMiddleAndInside, 
     sum(p.pMiddleAndInsideStrike) as pMiddleAndInsideStrike, 
     sum(p.pLowAndInside) as pLowAndInside, 
     sum(p.pLowAndInsideStrike) as pLowAndInsideStrike, 
     sum(p.pHighAndMiddle) as pHighAndMiddle, 
     sum(p.pHighAndMiddleStrike) as pHighAndMiddleStrike, 
     sum(p.pMiddleAndMiddle) as pMiddleAndMiddle, 
     sum(p.pMiddleAndMiddleStrike) as pMiddleAndMiddleStrike, 
     sum(p.pLowAndMiddle) as pLowAndMiddle, 
     sum(p.pLowAndMiddleStrike) as pLowAndMiddleStrike, 
     sum(p.pHighAndOutside) as pHighAndOutside, 
     sum(p.pHighAndOutsideStrike) as pHighAndOutsideStrike, 
     sum(p.pMiddleAndOutside) as pMiddleAndOutside, 
     sum(p.pMiddleAndOutsideStrike) as pMiddleAndOutsideStrike, 
     sum(p.pLowAndOutside) as pLowAndOutside, 
     sum(p.pLowAndOutsideStrike) as pLowAndOutsideStrike, 
     sum(p.whiff) as whiff, 
     sum(p.unknownStrike) as unknownStrike, 
     sum(p.swung) as swung, 
     sum(p.swingingStrikeBlocked) as swingingStrikeBlocked, 
     sum(p.pitchout) as pitchout, 
     sum(p.pickoff3rd) as pickoff3rd, 
     sum(p.pickoff2nd) as pickoff2nd, 
     sum(p.pickoff1st) as pickoff1st, 
     sum(p.pickoff) as pickoff, 
     sum(p.out) as outs, 
     sum(p.out) / 3 as innings, 
     sum(p.missedOrFoulBuntAttempt) as missedOrFoulBuntAttempt, 
     sum(p.intentionalBall) as intentionalBall, 
     sum(p.inPlay) as inPlay, 
     sum(p.hitByPitch) as hitByPitch, 
     sum(p.foul) as foul, 
     sum(p.calledStrike) as calledStrike, 
     sum(p.blockedBallInDirt) as blockedBallInDirt, 
     sum(p.ballInDirt) as ballInDirt, 
     sum(p.automaticBall) as automaticBall
  from ssfbl.pBySetPitchInfo p
 group by p.pitcherID, p.gameYear, p.gameSubset, p.gameSetName, p.atbatSubset, p.atbatSetName;

ALTER TABLE ssfbl.pPitchSummary
 ADD PRIMARY KEY (pitcherID, gameYear, gameSubset, gameSetName, atbatSubset, atbatSetName);
 
create index pitcherID on ssfbl.pPitchSummary (pitcherID);


################################# atbat summary
drop table if exists ssfbl.abSummary;
create table ssfbl.abSummary
select a.pitcherID, s.gameYear, s.gameSubset, s.gameSetName, s.atbatSubset, s.atbatSetName,
       sum(ar.out_) outs,
       count(ar.atbatID) battersFaced,
			 sum(ar.walk + ar.intentionalWalk) as BBs,
			 sum(ar.strikeout + ar.strikeoutDoublePlay) as Ks,
			 sum(ar.hit) as hits,
			 sum(ar.hr) as HRs,
			 sum(ar.out_) / 3 as innings
  from ssfbl.subsets s, mlb.atbatresults ar, mlb.atbats a
 where s.atbatID = ar.atbatID
	 and ar.atbatID = a.atbatID
 group by a.pitcherID, s.gameYear, s.gameSubset, s.gameSetName, s.atbatSubset, s.atbatSetName;
 
 
################################# pitch efficiency
drop table if exists ssfbl.pPitchEfficiency;

create table ssfbl.pPitchEfficiency
select ps.pitcherID, ps.gameYear,
       ps.gameSetName, ps.gameSubset, 
			 ps.atbatSetName, ps.atbatSubset, 
			 ab.innings,
       ps.pitches, 
			 ps.pitches / ab.innings as PitchesPerInning, 
			 ab.battersFaced, 
			 ab.battersFaced / ps.pitches * 100 BattersFacedPer100,  
			 ab.battersFaced / ab.innings * 9 BattersFacedPer9,
			 ab.battersFaced / ab.innings BattersFacedPerIP,
			 ab.Ks, 
			 ab.Ks / ps.pitches * 100 KsPer100,  
			 ab.Ks / ab.innings * 9 KsPer9,
			 ab.Ks / ps.pitches KsPerPitch,
			 ab.BBs, 
			 ab.BBs / ps.pitches * 100 BBPer100, 
			 ab.BBs / ps.innings * 9 BBPer9, 
			 ab.BBs / ps.pitches BBPerPitch,
			 ab.Ks / ab.BBs K2BB, 
			 ab.hits, 
			 ab.hits / ps.pitches * 100 HPer100,
			 ab.HRs, 
			 ab.HRs / ps.pitches * 100 HRPer100, 
			 ab.HRs / ab.innings * 9 HRPer9,
			 ab.outs, 
			 ab.outs / ps.pitches * 100 OutsPer100
  from ssfbl.pPitchSummary ps, ssfbl.abSummary ab
 where ab.pitcherID    = ps.pitcherID
   and ab.gameYear     = ps.gameYear
   and ab.gameSetName  = ps.gameSetName
	 and ab.gameSubset   = ps.gameSubset
   and ab.atbatSetName = ps.atbatSetName
	 and ab.atbatSubset  = ps.atbatSubset
 group by ps.pitcherID, ps.gameYear, ps.gameSubset, ps.gameSetName, 
          ps.atbatSubset, ps.atbatSetName;
          
          

################################# gb% ld% fb% pu% pitching
drop table if exists ssfbl.pBattedBallType;

create table ssfbl.pBattedBallType
select a.pitcherID, s.gameYear, s.gameSubset, s.gameSetName, s.atbatSubset, s.atbatSetName,
			 sum(ar.inPlay) as inPlay,
       sum(ar.groundBall) as groundBalls,
			 sum(ar.groundBall) / sum(ar.inPlay) as groundBallP,
			 sum(ar.lineDrive) as lineDrives,
			 sum(ar.lineDrive) / sum(ar.inPlay) as lineDriveP,
			 sum(ar.flyBall) as flyBalls,
			 sum(ar.flyBall) / sum(ar.inPlay) as flyBallP,
			 sum(ar.popUp) as popUps,
       sum(ar.popUp) / sum(ar.inPlay) as popUpP
  from mlb.atbats a, ssfbl.subsets s, mlb.atbatresults ar
 where a.atbatID = s.atbatID
	 and a.atbatID = ar.atbatID
	 and ar.inPlay = 1
 group by a.pitcherID, s.gameYear, s.gameSubset, s.gameSetName, s.atbatSubset, s.atbatSetName;
 
 
################################# innings per start
drop table if exists ssfbl.pInningsPerStart;

create table ssfbl.pInningsPerStart
select p.eliasID as pitcherID, g.gameYear, 
       g.setName as gameSetName, g.subset as gameSubset,
       count(p.pitcherOrder) as starts,
       sum(p.outs / 3) / count(p.pitcherOrder) as inningsPerStart
  from ssfbl.gamesubset g, mlb.pitchers p
 where g.gameID = p.gameID
   and p.pitcherOrder = 1
 group by p.eliasID, g.setName, g.subset;
	 

################################# pitch percentages
create table ssfbl.pPitchPercentages
select ps.pitcherID, ps.gameYear, ps.gameSubset, ps.gameSetName, 
       ps.atbatSubset, ps.atbatSetName,
       pitches, 
       strikeOrFoul / pitches as strikeOrFoulP, ball / pitches as ballP, 
			 TheoreticalStrike / pitches as TheoreticalStrikeP, TheoreticalBall / pitches as TheoreticalBallP, 
			 qualityStrike / pitches as qualityStrikeP, 
			 pHighAndInside / pitches as pHighAndInsideP, 
			 pHighAndInsideStrike / pitches as pHighAndInsideStrikeP, 
			 pHighAndMiddle / pitches as pHighAndMiddleP, 
			 pHighAndMiddleStrike / pitches as pHighAndMiddleStrikeP, 
			 pHighAndOutside / pitches as pHighAndOutsideP, 
			 pHighAndOutsideStrike / pitches as pHighAndOutsideStrikeP, 
			 pLowAndInside / pitches as pLowAndInsideP, 
			 pLowAndInsideStrike / pitches as pLowAndInsideStrikeP, 
			 pLowAndMiddle / pitches as pLowAndMiddleP, 
			 pLowAndMiddleStrike / pitches as pLowAndMiddleStrikeP, 
			 pLowAndOutside / pitches as pLowAndOutsideP, 
			 pLowAndOutsideStrike / pitches as pLowAndOutsideStrikeP, 
			 pMiddleAndInside / pitches as pMiddleAndInsideP, 
			 pMiddleAndInsideStrike / pitches as pMiddleAndInsideStrikeP, 
			 pMiddleAndMiddle / pitches as pMiddleAndMiddleP, 
			 pMiddleAndMiddleStrike / pitches as pMiddleAndMiddleStrikeP, 
			 pMiddleAndOutside / pitches as pMiddleAndOutsideP, 
			 pMiddleAndOutsideStrike / pitches as pMiddleAndOutsideStrikeP, 
			 calledStrike / pitches as calledStrikeP, 
			 foul / pitches as foulP, 
			 inPlay / pitches as inPlayP, 
			 whiff / pitches as whiffP, 
			 Screwball / pitches as ScrewballP, 
			 Ephuus / pitches as EphuusP, 
			 KnuckleCurve / pitches as KnuckleCurveP, 
			 Forkball / pitches as ForkballP, 
			 TwoSeamFastball / pitches as TwoSeamFastballP, 
			 Splitter / pitches as SplitterP,
			 Slider / pitches as SliderP, 
			 FourSeamFastBall / pitches as FourSeamFastBallP, 
			 Sinker / pitches as SinkerP, 
			 ChangeUp / pitches as ChangeUpP,
			 FastBall / pitches as FastBallP, 
			 Curve / pitches as CurveP, 
			 Cutter / pitches as CutterP,    
			 Knuckle / pitches as KnuckleP,
			 Unknown / pitches as UnknownP
	from ssfbl.pPitchSummary ps
 group by ps.pitcherID, ps.gameYear, ps.gameSubset, ps.gameSetName, 
          ps.atbatSubset, ps.atbatSetName;
          
          
 
################################# pitch attributes
drop table if exists ssfbl.pPitchAttributes;

create table ssfbl.pPitchAttributes
select p.pitcherID, p.gameYear, p.gameSubset, p.gameSetName, 
       p.atbatSubset, p.atbatSetName,
     p.type,
     avg(p.Speed) as Speed,
     count(p.pitchID) as pitches,
     sum(p.vMiddle) as vMiddle, 
     sum(p.vLow) as vLow, 
     sum(p.vHigh) as vHigh,
     sum(p.TheoreticalStrike) as TheoreticalStrike, 
     sum(p.TheoreticalBall) as TheoreticalBall, 
     sum(p.strikeOrFoul) as strikeOrFoul, 
     sum(p.hOutside) as hOutside, 
     sum(p.hMiddle) as hMiddle, 
     sum(p.hInside) as hInside,  
     sum(p.ball) as ball,  
     sum(p.qualityStrike) as qualityStrike, 
     sum(p.pHighAndInside) as pHighAndInside, 
     sum(p.pHighAndInsideStrike) as pHighAndInsideStrike, 
     sum(p.pMiddleAndInside) as pMiddleAndInside, 
     sum(p.pMiddleAndInsideStrike) as pMiddleAndInsideStrike, 
     sum(p.pLowAndInside) as pLowAndInside, 
     sum(p.pLowAndInsideStrike) as pLowAndInsideStrike, 
     sum(p.pHighAndMiddle) as pHighAndMiddle, 
     sum(p.pHighAndMiddleStrike) as pHighAndMiddleStrike, 
     sum(p.pMiddleAndMiddle) as pMiddleAndMiddle, 
     sum(p.pMiddleAndMiddleStrike) as pMiddleAndMiddleStrike, 
     sum(p.pLowAndMiddle) as pLowAndMiddle, 
     sum(p.pLowAndMiddleStrike) as pLowAndMiddleStrike, 
     sum(p.pHighAndOutside) as pHighAndOutside, 
     sum(p.pHighAndOutsideStrike) as pHighAndOutsideStrike, 
     sum(p.pMiddleAndOutside) as pMiddleAndOutside, 
     sum(p.pMiddleAndOutsideStrike) as pMiddleAndOutsideStrike, 
     sum(p.pLowAndOutside) as pLowAndOutside, 
     sum(p.pLowAndOutsideStrike) as pLowAndOutsideStrike, 
     sum(p.whiff) as whiff, 
     sum(p.unknownStrike) as unknownStrike, 
     sum(p.swung) as swung, 
     sum(p.swingingStrikeBlocked) as swingingStrikeBlocked, 
     sum(p.pitchout) as pitchout, 
     sum(p.pickoff3rd) as pickoff3rd, 
     sum(p.pickoff2nd) as pickoff2nd, 
     sum(p.pickoff1st) as pickoff1st, 
     sum(p.pickoff) as pickoff, 
     sum(p.out) as outs, 
     sum(p.out) / 3 as innings, 
     sum(p.missedOrFoulBuntAttempt) as missedOrFoulBuntAttempt, 
     sum(p.intentionalBall) as intentionalBall, 
     sum(p.inPlay) as inPlay, 
     sum(p.hitByPitch) as hitByPitch, 
     sum(p.foul) as foul, 
     sum(p.calledStrike) as calledStrike, 
     sum(p.blockedBallInDirt) as blockedBallInDirt, 
     sum(p.ballInDirt) as ballInDirt, 
     sum(p.automaticBall) as automaticBall
  from ssfbl.pBySetPitchInfo p
 group by p.pitcherID, p.gameYear, p.gameSubset, p.gameSetName, 
          p.atbatSubset, p.atbatSetName,
          p.type;

ALTER TABLE ssfbl.pPitchAttributes
 ADD PRIMARY KEY (pitcherID, gameYear, gameSubset, gameSetName, 
                  atbatSubset, atbatSetName, type);
 
create index pPApitcherID on ssfbl.pPitchAttributes (pitcherID);
  
	 
	 
	 


### change year!   Spring stats
create table ssfbl.springPosition
select p.id, last, first, game_position, count(*) as cnt
  from gameday.players p
where gameName like 'gid_2016%' -- change year!
  and game_position is not null
group by last, first, game_position;

create table ssfbl.springBattingOrder
select p.id, last, first, bat_order, count(*) as cnt
  from gameday.players p
where gameName like 'gid_2016%' -- change year!
  and bat_order is not null
group by last, first, bat_order;

create table ssfbl.springRBIBatters
select sbo.*
  from ssfbl.springbattingorder sbo, ssfbl.ssfblplayers p
 where bat_order in (3,4,5)
   and cnt > 3
	 and p.eliasID = sbo.id;



