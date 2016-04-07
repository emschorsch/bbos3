
  drop table if exists ssfbl.rPitcherResults;
create table ssfbl.rPitcherResults
select 2nd.eliasID, 
       1st.era as 1stera, 2nd.era as 2ndera, 1st.era - 2nd.era as eraDiff,
       1st.FIP as 1stFIP, 2nd.FIP as 2ndFIP, 1st.FIP - 2nd.FIP as FIPDiff, 
       1st.ipPerStart as 1stipPerStart, 2nd.ipPerStart as 2ndipPerStart, 1st.ipPerStart - 2nd.ipPerStart as ipPerStartDiff,
       1st.lobP as 1stlobP, 2nd.lobP as 2ndlobP, 1st.lobP - 2nd.lobP as lobPDiff, 
       1st.ip as 1stIP, 2nd.ip as 2ndIP
  from (
select pr.eliasID,
       pr.ip, pr.era, pr.FIP, pr.ipInGamesStarted / pr.gamesStarted as ipPerStart, pr.lobP
  from ssfbl.pPitcherResults pr
 where pr.setName = 'firstHalf'
    -- and pr.eliasID = 425844
       ) 1st, (
select pr.eliasID,
       pr.ip, pr.era, pr.FIP, pr.ipInGamesStarted / pr.gamesStarted as ipPerStart, pr.lobP
  from ssfbl.pPitcherResults pr
 where pr.setName = 'secondHalf'
       ) 2nd
 where 1st.eliasID = 2nd.eliasID
 order by 1st.FIP - 2nd.FIP desc;
 
 
drop table if exists ssfbl.rBattedBall;
create table ssfbl.rBattedBall
select 2nd.pitcherID, 
       1st.groundBallP as 1stGroundP, 2nd.groundBallP as 2ndGroundP, 
       1st.groundBallP - 2nd.groundBallP as groundPDiff,
       1st.flyBallP as 1stFlyP, 2nd.flyBallP as 2ndFlyP, 
       1st.flyBallP - 2nd.flyBallP as flyPDiff,
       1st.inPlay as 1stInPlay, 2nd.inPlay as 2ndInPlay
  from (select t1.pitcherID,
               t1.inPlay, t1.groundBallP, t1.flyBallP
          from ssfbl.pbattedballtype t1 where t1.gameSetName = 'firstHalf' and t1.atbatSetName = 'all') 1st, 
       (select t2.pitcherID,
               t2.inPlay, t2.groundBallP, t2.flyBallP
          from ssfbl.pbattedballtype t2 where t2.gameSetName = 'secondHalf' and t2.atbatSetName = 'all'
   -- and t2.pitcherID = 425844
   ) 2nd
 where 1st.pitcherID = 2nd.pitcherID;
 
 
 drop table if exists ssfbl.rInningsPerStart;
create table ssfbl.rInningsPerStart
select 2nd.pitcherID, 
       1st.starts as 1stStarts, 2nd.starts as 2ndStarts,
       1st.inningsPerStart as 1stInnPerStart, 2nd.inningsPerStart as 2ndInnPerStart, 
       1st.inningsPerStart - 2nd.inningsPerStart as IDiff
  from (
select pr.pitcherID, 
       pr.starts, pr.inningsPerStart
  from ssfbl.pInningsPerStart pr where pr.gameSetName = 'firstHalf') 1st, 
  (select pr.pitcherID, 
          pr.starts, pr.inningsPerStart
     from ssfbl.pInningsPerStart pr where pr.gameSetName = 'secondHalf'
   -- and pr.pitcherID = 425844
       ) 2nd
 where 1st.pitcherID = 2nd.pitcherID;
 
 
  drop table if exists ssfbl.tPitchTotals;
create table ssfbl.tPitchTotals
select t2.pitcherID, t2.gameSetName, t2.atbatSubset, sum(t2.pitches) as pitchesInSubset
  from ssfbl.pPitchAttributes t2 
 group by t2.pitcherID, t2.gameSetName, t2.atbatSubset;
 
 drop table if exists ssfbl.rPitchAttributes;
create table ssfbl.rPitchAttributes
select 2nd.pitcherID,
               2nd.type, 
               1st.perc as 1perc, 2nd.perc as 2perc, 
               1st.pitches as 1pitches, 2nd.pitches as 2pitches, 
               1st.Speed as 1speed, 2nd.Speed as 2speed, 1st.Speed - 2nd.Speed as speedDiff,
               1st.strikeP as 1strikeP, 2nd.strikeP as 2strikeP, 1st.strikeP - 2nd.strikeP as strikePDiff,
               1st.qualityStrikeP as 1qualityStrikeP, 2nd.qualityStrikeP as 2qualityStrikeP, 1st.qualityStrikeP - 2nd.qualityStrikeP as qualityStrikePDiff,
               1st.whiffP as 1whiffP, 2nd.whiffP as 2whiffP, 1st.whiffP - 2nd.whiffP as whiffPDiff,
               1st.poorContactP as 1poorContactP, 2nd.poorContactP as 2poorContactP, 1st.poorContactP - 2nd.poorContactP as poorContactPDiff,
               1st.inPlayP as 1inPlayP, 2nd.inPlayP as 2inPlayP, 1st.inPlayP - 2nd.inPlayP as inPlayPDiff,
               1st.calledStrikeP as 1calledStrikeP, 2nd.calledStrikeP as 2calledStrikeP, 1st.calledStrikeP - 2nd.calledStrikeP as calledStrikePDiff
  from (select t1.pitcherID,
               type, 
               pitches / tpt.pitchesInSubset as perc, pitches,
               TheoreticalStrike / pitches as strikeP,
               qualityStrike / pitches as qualityStrikeP,
               whiff / pitches as whiffP,
               (foul + whiff) / pitches as poorContactP,
               inPlay / pitches as inPlayP,
               calledStrike / pitches as calledStrikeP,
							 t1.Speed
          from ssfbl.pPitchAttributes t1, ssfbl.tPitchTotals tpt 
         where t1.gameSetName = 'firstHalf' and t1.atbatSetName = 'all'
           and t1.pitcherID = tpt.pitcherID
           and t1.gameSetName = tpt.gameSetName
           and t1.atbatSetName = tpt.atbatSubset
   ) 1st, 
       (select t2.pitcherID,
               t2.type, 
               t2.pitches / tpt.pitchesInSubset as perc, t2.pitches, 
               t2.TheoreticalStrike / pitches as strikeP,
               t2.qualityStrike / pitches as qualityStrikeP,
               t2.whiff / pitches as whiffP,
               (t2.foul + t2.whiff) / pitches as poorContactP,
               t2.inPlay / pitches as inPlayP,
               t2.calledStrike / pitches as calledStrikeP,
							 t2.Speed
          from ssfbl.pPitchAttributes t2, ssfbl.tPitchTotals tpt 
         where t2.gameSetName = 'secondHalf' and t2.atbatSetName = 'all'
           and t2.pitcherID = tpt.pitcherID
           and t2.gameSetName = tpt.gameSetName
           and t2.atbatSetName = tpt.atbatSubset
    -- and t2.pitcherID = 425844
   ) 2nd
 where 1st.pitcherID = 2nd.pitcherID
   and 1st.type = 2nd.type;
   
   

 drop table if exists ssfbl.rPitchingStats;
create table ssfbl.rPitchingStats
select 2nd.pitcherID, 
       1st.outs as 1stOuts, 2nd.outs as 2ndOuts,
       1st.babip as 1stbabip, 2nd.babip as 2ndbabip, 1st.babip - 2nd.babip as babipDiff
  from (select pr.pitcherID, pr.outs,
               pr.babip
          from ssfbl.pPitchingStats pr where pr.gameSetName = 'firstHalf' and pr.atbatSetName = 'all') 1st, 
       (select pr.pitcherID, pr.outs,
               pr.babip
          from ssfbl.pPitchingStats pr where pr.gameSetName = 'secondHalf' and pr.atbatSetName = 'all'
    -- and pr.pitcherID = 425844
       ) 2nd
 where 1st.pitcherID = 2nd.pitcherID;
 
 

 drop table if exists ssfbl.rPitchEfficiency;
create table ssfbl.rPitchEfficiency
select 2nd.pitcherID, 
       1st.innings as 1stIP, 2nd.innings as 2ndIP,
       1st.KsPer100 as 1stKsPer100, 2nd.KsPer100 as 2ndKsPer100, 1st.KsPer100 - 2nd.KsPer100 as KsPer100Diff,
       1st.BBPer100 as 1stBBPer100, 2nd.BBPer100 as 2ndBBPer100, 1st.BBPer100 - 2nd.BBPer100 as BBPer100Diff,
       1st.K2BB as 1stK2BB, 2nd.K2BB as 2ndK2BB, 1st.K2BB - 2nd.K2BB as K2BBDiff,
       1st.HRPer100 as 1stHRPer100, 2nd.HRPer100 as 2ndHRPer100, 1st.HRPer100 - 2nd.HRPer100 as HRPer100Diff,
       1st.OutsPer100 as 1stOutsPer100, 2nd.OutsPer100 as 2ndOutsPer100, 1st.OutsPer100 - 2nd.OutsPer100 as OutsPer100Diff
  from (select pr.pitcherID, 
               pr.innings, pr.KsPer100, pr.BBPer100, pr.K2BB, pr.HRPer100, pr.OutsPer100
          from ssfbl.pPitchEfficiency pr where pr.gameSetName = 'firstHalf' and pr.atbatSetName = 'all') 1st, 
       (select pr.pitcherID,
               pr.innings, pr.KsPer100, pr.BBPer100, pr.K2BB, pr.HRPer100, pr.OutsPer100
          from ssfbl.pPitchEfficiency pr where pr.gameSetName = 'secondHalf' and pr.atbatSetName = 'all'
     -- and pr.pitcherID = 425844
       ) 2nd
 where 1st.pitcherID = 2nd.pitcherID;
 


 drop table if exists ssfbl.rPitchPercentages;
create table ssfbl.rPitchPercentages
select 2nd.pitcherID, 
       1st.pitches as 1stPitches, 2nd.pitches as 2ndPitches,
       1st.strikeOrFoulP as 1ststrikeOrFoulP, 2nd.strikeOrFoulP as 2ndstrikeOrFoulP, 1st.strikeOrFoulP - 2nd.strikeOrFoulP as strikeOrFoulPDiff,
       1st.ballP as 1stballP, 2nd.ballP as 2ndballP, 1st.ballP - 2nd.ballP as ballPDiff,
       1st.TheoreticalStrikeP as 1stTheoreticalStrikeP, 2nd.TheoreticalStrikeP as 2ndTheoreticalStrikeP, 1st.TheoreticalStrikeP - 2nd.TheoreticalStrikeP as TheoreticalStrikePDiff,
       1st.TheoreticalBallP as 1stTheoreticalBallP, 2nd.TheoreticalBallP as 2ndTheoreticalBallP, 1st.TheoreticalBallP - 2nd.TheoreticalBallP as TheoreticalBallPDiff,
       1st.qualityStrikeP as 1stqualityStrikeP, 2nd.qualityStrikeP as 2ndqualityStrikeP, 1st.qualityStrikeP - 2nd.qualityStrikeP as qualityStrikePDiff,
       1st.pHighAndInsideP as 1stpHighAndInsideP, 2nd.pHighAndInsideP as 2ndpHighAndInsideP, 1st.pHighAndInsideP - 2nd.pHighAndInsideP as pHighAndInsidePDiff,
       1st.pHighAndInsideStrikeP as 1stpHighAndInsideStrikeP, 2nd.pHighAndInsideStrikeP as 2ndpHighAndInsideStrikeP, 1st.pHighAndInsideStrikeP - 2nd.pHighAndInsideStrikeP as pHighAndInsideStrikePDiff,
       1st.pHighAndMiddleP as 1stpHighAndMiddleP, 2nd.pHighAndMiddleP as 2ndpHighAndMiddleP, 1st.pHighAndMiddleP - 2nd.pHighAndMiddleP as pHighAndMiddlePDiff,
       1st.pHighAndMiddleStrikeP as 1stpHighAndMiddleStrikeP, 2nd.pHighAndMiddleStrikeP as 2ndpHighAndMiddleStrikeP, 1st.pHighAndMiddleStrikeP - 2nd.pHighAndMiddleStrikeP as pHighAndMiddleStrikePDiff,
       1st.pHighAndOutsideP as 1stpHighAndOutsideP, 2nd.pHighAndOutsideP as 2ndpHighAndOutsideP, 1st.pHighAndOutsideP - 2nd.pHighAndOutsideP as pHighAndOutsidePDiff,
       1st.pHighAndOutsideStrikeP as 1stpHighAndOutsideStrikeP, 2nd.pHighAndOutsideStrikeP as 2ndpHighAndOutsideStrikeP, 1st.pHighAndOutsideStrikeP - 2nd.pHighAndOutsideStrikeP as pHighAndOutsideStrikePDiff,
       1st.pLowAndInsideP as 1stpLowAndInsideP, 2nd.pLowAndInsideP as 2ndpLowAndInsideP, 1st.pLowAndInsideP - 2nd.pLowAndInsideP as pLowAndInsidePDiff,
       1st.pLowAndInsideStrikeP as 1stpLowAndInsideStrikeP, 2nd.pLowAndInsideStrikeP as 2ndpLowAndInsideStrikeP, 1st.pLowAndInsideStrikeP - 2nd.pLowAndInsideStrikeP as pLowAndInsideStrikePDiff,
       1st.pLowAndMiddleP as 1stpLowAndMiddleP, 2nd.pLowAndMiddleP as 2ndpLowAndMiddleP, 1st.pLowAndMiddleP - 2nd.pLowAndMiddleP as pLowAndMiddlePDiff,
       1st.pLowAndMiddleStrikeP as 1stpLowAndMiddleStrikeP, 2nd.pLowAndMiddleStrikeP as 2ndpLowAndMiddleStrikeP, 1st.pLowAndMiddleStrikeP - 2nd.pLowAndMiddleStrikeP as pLowAndMiddleStrikePDiff,
       1st.pLowAndOutsideP as 1stpLowAndOutsideP, 2nd.pLowAndOutsideP as 2ndpLowAndOutsideP, 1st.pLowAndOutsideP - 2nd.pLowAndOutsideP as pLowAndOutsidePDiff,
       1st.pLowAndOutsideStrikeP as 1stpLowAndOutsideStrikeP, 2nd.pLowAndOutsideStrikeP as 2ndpLowAndOutsideStrikeP, 1st.pLowAndOutsideStrikeP - 2nd.pLowAndOutsideStrikeP as pLowAndOutsideStrikePDiff,
       1st.pMiddleAndInsideP as 1stpMiddleAndInsideP, 2nd.pMiddleAndInsideP as 2ndpMiddleAndInsideP, 1st.pMiddleAndInsideP - 2nd.pMiddleAndInsideP as pMiddleAndInsidePDiff,
       1st.pMiddleAndInsideStrikeP as 1stpMiddleAndInsideStrikeP, 2nd.pMiddleAndInsideStrikeP as 2ndpMiddleAndInsideStrikeP, 1st.pMiddleAndInsideStrikeP - 2nd.pMiddleAndInsideStrikeP as pMiddleAndInsideStrikePDiff,
       1st.pMiddleAndMiddleP as 1stpMiddleAndMiddleP, 2nd.pMiddleAndMiddleP as 2ndpMiddleAndMiddleP, 1st.pMiddleAndMiddleP - 2nd.pMiddleAndMiddleP as pMiddleAndMiddlePDiff,
       1st.pMiddleAndMiddleStrikeP as 1stpMiddleAndMiddleStrikeP, 2nd.pMiddleAndMiddleStrikeP as 2ndpMiddleAndMiddleStrikeP, 1st.pMiddleAndMiddleStrikeP - 2nd.pMiddleAndMiddleStrikeP as pMiddleAndMiddleStrikePDiff,
       1st.pMiddleAndOutsideP as 1stpMiddleAndOutsideP, 2nd.pMiddleAndOutsideP as 2ndpMiddleAndOutsideP, 1st.pMiddleAndOutsideP - 2nd.pMiddleAndOutsideP as pMiddleAndOutsidePDiff,
       1st.pMiddleAndOutsideStrikeP as 1stpMiddleAndOutsideStrikeP, 2nd.pMiddleAndOutsideStrikeP as 2ndpMiddleAndOutsideStrikeP, 1st.pMiddleAndOutsideStrikeP - 2nd.pMiddleAndOutsideStrikeP as pMiddleAndOutsideStrikePDiff,
       1st.calledStrikeP as 1stcalledStrikeP, 2nd.calledStrikeP as 2ndcalledStrikeP, 1st.calledStrikeP - 2nd.calledStrikeP as calledStrikePDiff,
       1st.foulP as 1stfoulP, 2nd.foulP as 2ndfoulP, 1st.foulP - 2nd.foulP as foulPDiff,
       1st.inPlayP as 1stinPlayP, 2nd.inPlayP as 2ndinPlayP, 1st.inPlayP - 2nd.inPlayP as inPlayPDiff,
       1st.whiffP as 1stwhiffP, 2nd.whiffP as 2ndwhiffP, 1st.whiffP - 2nd.whiffP as whiffPDiff,
       
			 1st.ScrewballP as 1stScrewballP, 2nd.ScrewballP as 2ndScrewballP, 1st.ScrewballP - 2nd.ScrewballP as ScrewballPDiff,
       1st.EphuusP as 1stEphuusP, 2nd.EphuusP as 2ndEphuusP, 1st.EphuusP - 2nd.EphuusP as EphuusPDiff,
       1st.KnuckleCurveP as 1stKnuckleCurveP, 2nd.KnuckleCurveP as 2ndKnuckleCurveP, 1st.KnuckleCurveP - 2nd.KnuckleCurveP as KnuckleCurvePDiff,
       1st.ForkballP as 1stForkballP, 2nd.ForkballP as 2ndForkballP, 1st.ForkballP - 2nd.ForkballP as ForkballPDiff,
       1st.TwoSeamFastballP as 1stTwoSeamFastballP, 2nd.TwoSeamFastballP as 2ndTwoSeamFastballP, 1st.TwoSeamFastballP - 2nd.TwoSeamFastballP as TwoSeamFastballPDiff,
       1st.SplitterP as 1stSplitterP, 2nd.SplitterP as 2ndSplitterP, 1st.SplitterP - 2nd.SplitterP as SplitterPDiff,
			 1st.SliderP as 1stSliderP, 2nd.SliderP as 2ndSliderP, 1st.SliderP - 2nd.SliderP as SliderPDiff,
       1st.FourSeamFastBallP as 1stFourSeamFastBallP, 2nd.FourSeamFastBallP as 2ndFourSeamFastBallP, 1st.FourSeamFastBallP - 2nd.FourSeamFastBallP as FourSeamFastBallPDiff,
       1st.SinkerP as 1stSinkerP, 2nd.SinkerP as 2ndSinkerP, 1st.SinkerP - 2nd.SinkerP as SinkerPDiff,
       1st.ChangeUpP as 1stChangeUpP, 2nd.ChangeUpP as 2ndChangeUpP, 1st.ChangeUpP - 2nd.ChangeUpP as ChangeUpPDiff,
       1st.FastBallP as 1stFastBallP, 2nd.FastBallP as 2ndFastBallP, 1st.FastBallP - 2nd.FastBallP as FastBallPDiff,
       1st.CurveP as 1stCurveP, 2nd.CurveP as 2ndCurveP, 1st.CurveP - 2nd.CurveP as CurvePDiff,
       1st.CutterP as 1stCutterP, 2nd.CutterP as 2ndCutterP, 1st.CutterP - 2nd.CutterP as CutterPDiff,
       1st.KnuckleP as 1stKnuckleP, 2nd.KnuckleP as 2ndKnuckleP, 1st.KnuckleP - 2nd.KnuckleP as KnucklePDiff,
       1st.UnknownP as 1stUnknownP, 2nd.UnknownP as 2ndUnknownP, 1st.UnknownP - 2nd.UnknownP as UnknownPDiff
  from (select pr.pitcherID, 
                       pitches, 
               strikeOrFoulP, ballP, 
			 TheoreticalStrikeP, TheoreticalBallP, 
			 qualityStrikeP, 
			 pHighAndInsideP, 
			 pHighAndInsideStrikeP, 
			 pHighAndMiddleP, 
			 pHighAndMiddleStrikeP, 
			 pHighAndOutsideP, 
			 pHighAndOutsideStrikeP, 
			 pLowAndInsideP, 
			 pLowAndInsideStrikeP, 
			 pLowAndMiddleP, 
			 pLowAndMiddleStrikeP, 
			 pLowAndOutsideP, 
			 pLowAndOutsideStrikeP, 
			 pMiddleAndInsideP, 
			 pMiddleAndInsideStrikeP, 
			 pMiddleAndMiddleP, 
			 pMiddleAndMiddleStrikeP, 
			 pMiddleAndOutsideP, 
			 pMiddleAndOutsideStrikeP, 
			 calledStrikeP, 
			 foulP, 
			 inPlayP, 
			 whiffP, 
			 ScrewballP, 
			 EphuusP, 
			 KnuckleCurveP, 
			 ForkballP, 
			 TwoSeamFastballP, 
			 SplitterP, 
			 SliderP, 
			 FourSeamFastBallP, 
			 SinkerP, 
			 ChangeUpP, 
			 FastBallP, 
			 CurveP, 
			 CutterP, 
			 KnuckleP, 
			 UnknownP
          from ssfbl.pPitchPercentages pr where pr.gameSetName = 'firstHalf' and pr.atbatSetName = 'all') 1st, 
       (select pr.pitcherID,
               pitches, 
               strikeOrFoulP, ballP, 
			 TheoreticalStrikeP, TheoreticalBallP, 
			 qualityStrikeP, 
			 pHighAndInsideP, 
			 pHighAndInsideStrikeP, 
			 pHighAndMiddleP, 
			 pHighAndMiddleStrikeP, 
			 pHighAndOutsideP, 
			 pHighAndOutsideStrikeP, 
			 pLowAndInsideP, 
			 pLowAndInsideStrikeP, 
			 pLowAndMiddleP, 
			 pLowAndMiddleStrikeP, 
			 pLowAndOutsideP, 
			 pLowAndOutsideStrikeP, 
			 pMiddleAndInsideP, 
			 pMiddleAndInsideStrikeP, 
			 pMiddleAndMiddleP, 
			 pMiddleAndMiddleStrikeP, 
			 pMiddleAndOutsideP, 
			 pMiddleAndOutsideStrikeP, 
			 calledStrikeP, 
			 foulP, 
			 inPlayP, 
			 whiffP, 
			 ScrewballP, 
			 EphuusP, 
			 KnuckleCurveP, 
			 ForkballP, 
			 TwoSeamFastballP, 
			 SplitterP, 
			 SliderP, 
			 FourSeamFastBallP, 
			 SinkerP, 
			 ChangeUpP, 
			 FastBallP, 
			 CurveP, 
			 CutterP, 
			 KnuckleP, 
			 UnknownP
          from ssfbl.pPitchPercentages pr where pr.gameSetName = 'secondHalf' and pr.atbatSetName = 'all'
      -- and pr.pitcherID = 425844
       ) 2nd
 where 1st.pitcherID = 2nd.pitcherID;
 
 
  drop table if exists ssfbl.rPitchPercentagesLA;
create table ssfbl.rPitchPercentagesLA
select avg(rp.`2ndstrikeOrFoulP`) as 2ndstrikeOrFoulPavg, 
       std(rp.`2ndstrikeOrFoulP`) as 2ndstrikeOrFoulPstd,
       avg(rp.`2ndqualityStrikeP`) as 2ndqualityStrikePavg, 
       std(rp.`2ndqualityStrikeP`) as 2ndqualityStrikePstd,
       avg(rp.`2ndwhiffP`) as 2ndwhiffPavg, 
       std(rp.`2ndwhiffP`) as 2ndwhiffPstd
  from ssfbl.rpitchpercentages rp, mlb.players p, ssfbl.ssfblplayers sp
 where p.eliasID = rp.pitcherID
   and sp.eliasID = p.eliasID;
  
 
 
