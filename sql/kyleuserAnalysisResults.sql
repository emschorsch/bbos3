  drop table if exists ssfbl.fBattedBall;
create table ssfbl.fBattedBall
SELECT p.last,
       p.first,
       rbb.pitcherID,
       rbb.1stGroundP, rbb.2ndGroundP, rbb.groundPDiff,
       rbb.1stFlyP, rbb.2ndFlyP, rbb.flyPDiff,
       rbb.1stInPlay, rbb.2ndInPlay
  FROM mlb.players p, ssfbl.rBattedBall rbb, ssfbl.ssfblplayers sp
 WHERE p.eliasID = rbb.pitcherID AND sp.eliasID = p.eliasID;


  drop table if exists ssfbl.fPitchEfficiency;
create table ssfbl.fPitchEfficiency
SELECT p.last,
       p.first,
       rpe.pitcherID,
       rpe.`1stIP`, rpe.`2ndIP`,
       rpe.1stKsPer100, rpe.2ndKsPer100, rpe.KsPer100Diff,
       rpe.1stBBPer100, rpe.2ndBBPer100, rpe.BBPer100Diff,
       rpe.1stK2BB, rpe.2ndK2BB, rpe.K2BBDiff,
       rpe.1stHRPer100, rpe.2ndHRPer100, rpe.HRPer100Diff,
       rpe.1stOutsPer100, rpe.2ndOutsPer100, rpe.OutsPer100Diff
  FROM mlb.players p, ssfbl.rPitchEfficiency rpe, 
       ssfbl.ssfblplayers sp
 WHERE p.eliasID = rpe.pitcherID AND sp.eliasID = p.eliasID;


  drop table if exists ssfbl.fSSFBLPitcherAnalysis;
create table ssfbl.fSSFBLPitcherAnalysis
select p.eliasID, p.last, p.first, p.throws, 
       pe.`1stIP`, pe.`2ndIP`,
       pr.eraDiff, pr.FIPDiff, pr.lobPDiff, pr.ipPerStartDiff,
       ps.babipDiff,
       bb.groundPDiff, bb.flyPDiff,
       i.2ndInnPerStart, i.IDiff,
       pe.OutsPer100Diff, pe.K2BBDiff, pe.KsPer100Diff, pe.BBPer100Diff
  from mlb.players p, 
       (ssfbl.rbattedball bb
       left join ssfbl.rinningsperstart i on i.pitcherID = bb.pitcherID),
       ssfbl.rpitchefficiency pe,
       ssfbl.rpitcherresults pr,
       ssfbl.rpitchingstats ps,
       ssfbl.ssfblplayers ssfblp
 where p.eliasID = bb.pitcherID
   and pe.pitcherID = p.eliasID
   and pr.eliasID = p.eliasID
   and ps.pitcherID = p.eliasID
   AND pe.`1stIP` > 15 AND pe.`2ndIP` > 15
   and ssfblp.eliasID = p.eliasID;
   

  drop table if exists ssfbl.fPitchQualityDifference;
create table ssfbl.fPitchQualityDifference
SELECT p.last,
       p.first,
       rp.pitcherID,
       rp.`1stPitches`,
       rp.`2ndPitches`,
       rp.`1ststrikeOrFoulP`,
       rp.`2ndstrikeOrFoulP`,
       rp.strikeOrFoulPDiff,
       rp.`1stballP`,
       rp.`2ndballP`,
       rp.ballPDiff,
       rp.`1stTheoreticalStrikeP`,
       rp.`2ndTheoreticalStrikeP`,
       rp.TheoreticalStrikePDiff,
       rp.`1stTheoreticalBallP`,
       rp.`2ndTheoreticalBallP`,
       rp.TheoreticalBallPDiff,
       rp.`1stqualityStrikeP`,
       rp.`2ndqualityStrikeP`,
       rp.qualityStrikePDiff,
       rp.`1stpHighAndInsideP`,
       rp.`2ndpHighAndInsideP`,
       rp.pHighAndInsidePDiff,
       rp.`1stpHighAndInsideStrikeP`,
       rp.`2ndpHighAndInsideStrikeP`,
       rp.pHighAndInsideStrikePDiff,
       rp.`1stpHighAndMiddleP`,
       rp.`2ndpHighAndMiddleP`,
       rp.pHighAndMiddlePDiff,
       rp.`1stpHighAndMiddleStrikeP`,
       rp.`2ndpHighAndMiddleStrikeP`,
       rp.pHighAndMiddleStrikePDiff,
       rp.`1stpHighAndOutsideP`,
       rp.`2ndpHighAndOutsideP`,
       rp.pHighAndOutsidePDiff,
       rp.`1stpHighAndOutsideStrikeP`,
       rp.`2ndpHighAndOutsideStrikeP`,
       rp.pHighAndOutsideStrikePDiff,
       rp.`1stpLowAndInsideP`,
       rp.`2ndpLowAndInsideP`,
       rp.pLowAndInsidePDiff,
       rp.`1stpLowAndInsideStrikeP`,
       rp.`2ndpLowAndInsideStrikeP`,
       rp.pLowAndInsideStrikePDiff,
       rp.`1stpLowAndMiddleP`,
       rp.`2ndpLowAndMiddleP`,
       rp.pLowAndMiddlePDiff,
       rp.`1stpLowAndMiddleStrikeP`,
       rp.`2ndpLowAndMiddleStrikeP`,
       rp.pLowAndMiddleStrikePDiff,
       rp.`1stpLowAndOutsideP`,
       rp.`2ndpLowAndOutsideP`,
       rp.pLowAndOutsidePDiff,
       rp.`1stpLowAndOutsideStrikeP`,
       rp.`2ndpLowAndOutsideStrikeP`,
       rp.pLowAndOutsideStrikePDiff,
       rp.`1stpMiddleAndInsideP`,
       rp.`2ndpMiddleAndInsideP`,
       rp.pMiddleAndInsidePDiff,
       rp.`1stpMiddleAndInsideStrikeP`,
       rp.`2ndpMiddleAndInsideStrikeP`,
       rp.pMiddleAndInsideStrikePDiff,
       rp.`1stpMiddleAndMiddleP`,
       rp.`2ndpMiddleAndMiddleP`,
       rp.pMiddleAndMiddlePDiff,
       rp.`1stpMiddleAndMiddleStrikeP`,
       rp.`2ndpMiddleAndMiddleStrikeP`,
       rp.pMiddleAndMiddleStrikePDiff,
       rp.`1stpMiddleAndOutsideP`,
       rp.`2ndpMiddleAndOutsideP`,
       rp.pMiddleAndOutsidePDiff,
       rp.`1stpMiddleAndOutsideStrikeP`,
       rp.`2ndpMiddleAndOutsideStrikeP`,
       rp.pMiddleAndOutsideStrikePDiff,
       rp.`1stcalledStrikeP`,
       rp.`2ndcalledStrikeP`,
       rp.calledStrikePDiff,
       rp.`1stfoulP`,
       rp.`2ndfoulP`,
       rp.foulPDiff,
       rp.`1stinPlayP`,
       rp.`2ndinPlayP`,
       rp.inPlayPDiff,
       rp.`1stwhiffP`,
       rp.`2ndwhiffP`,
       rp.whiffPDiff
  FROM mlb.players p, ssfbl.rpitchpercentages rp, ssfbl.ssfblplayers sp
 WHERE p.eliasID = rp.pitcherID AND sp.eliasID = p.eliasID;
 
 
  drop table if exists ssfbl.fPitchPercentageChange;
create table ssfbl.fPitchPercentageChange
SELECT p.last,
       p.first,
       rp.pitcherID,
       rp.1stScrewballP, rp.2ndScrewballP, rp.ScrewballPDiff,
			 rp.1stEphuusP, rp.2ndEphuusP, rp.EphuusPDiff,
			 rp.1stKnuckleCurveP, rp.2ndKnuckleCurveP, rp.KnuckleCurvePDiff,
			 rp.1stForkballP, rp.2ndForkballP, rp.ForkballPDiff,
			 rp.1stTwoSeamFastballP, rp.2ndTwoSeamFastballP, rp.TwoSeamFastballPDiff,
			 rp.1stSplitterP, rp.2ndSplitterP, rp.SplitterPDiff,
       rp.1stSliderP, rp.2ndSliderP, rp.SliderPDiff,
       rp.1stFourSeamFastBallP, rp.2ndFourSeamFastBallP, rp.FourSeamFastBallPDiff,
       rp.1stSinkerP, rp.2ndSinkerP, rp.SinkerPDiff,
       rp.1stChangeUpP, rp.2ndChangeUpP, rp.ChangeUpPDiff,
       rp.1stFastBallP, rp.2ndFastBallP, rp.FastBallPDiff,
       rp.1stCurveP, rp.2ndCurveP, rp.CurvePDiff,
       rp.1stCutterP, rp.2ndCutterP, rp.CutterPDiff,
			 rp.1stKnuckleP, rp.2ndKnuckleP, rp.KnucklePDiff,
			 rp.1stUnknownP, rp.2ndUnknownP, rp.UnknownPDiff
  FROM mlb.players p, ssfbl.rpitchpercentages rp, ssfbl.ssfblplayers sp
 WHERE p.eliasID = rp.pitcherID AND sp.eliasID = p.eliasID;


  drop table if exists ssfbl.fSSFBLPitchers;
create table ssfbl.fSSFBLPitchers
select concat(p.last, ', ', p.first, ' ', p.eliasID) as "concat",
       p.eliasID, p.last, p.first
  from ssfbl.ssfblplayers sp, mlb.players p, ssfbl.fpitchefficiency fpp
 where p.eliasID = sp.eliasID
   and fpp.pitcherID = p.eliasID
	 and (fpp.1stIP > 15 or fpp.2ndIP > 15)
	 and (fpp.1stIP > 1 and fpp.2ndIP > 1);