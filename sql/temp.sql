drop table if exists mlb.tempFielders;

create table mlb.tempFielders 
select a.atbatID, pr.fieldingPosition, pr.eliasID
  from mlb.games g, mlb.rosters pr, mlb.atbats a, mlb.rosters br
 where g.gameID = pr.gameID
	 and pr.battingOrder is not null
	 and g.gameID = a.gameID
	 and g.gameID = br.gameID
	 and a.batterID = br.eliasID
	 and br.teamID != pr.teamID-- ;
	 and a.atbatID = 1646;
	 
create index iAtBatID on mlb.tempFielders (atbatID, fieldingPosition);


drop table if exists mlb.fielders;

create table mlb.fielders 
select f.atbatID, f.eliasID as 'C'-- , 
       -- (select fp.eliasID from mlb.tempFielders fp where fp.atbatID = f.atbatID and fp.fieldingPosition = '1B') as 1B -- , 
       -- (select fp.eliasID from mlb.tempFielders fp where fp.atbatID = f.atbatID and fp.fieldingPosition = '2B') as 2B, 
       -- (select fp.eliasID from mlb.tempFielders fp where fp.atbatID = f.atbatID and fp.fieldingPosition = 'SS') as SS, 
       -- (select fp.eliasID from mlb.tempFielders fp where fp.atbatID = f.atbatID and fp.fieldingPosition = '3B') as 3B, 
       -- (select fp.eliasID from mlb.tempFielders fp where fp.atbatID = f.atbatID and fp.fieldingPosition = 'CF') as CF, 
       -- (select fp.eliasID from mlb.tempFielders fp where fp.atbatID = f.atbatID and fp.fieldingPosition = 'LF') as LF, 
       -- (select fp.eliasID from mlb.tempFielders fp where fp.atbatID = f.atbatID and fp.fieldingPosition = 'RF') as RF, 
       -- (select fp.eliasID from mlb.tempFielders fp where fp.atbatID = f.atbatID and fp.fieldingPosition = 'P') as P
  from mlb.tempFielders f
 where f.fieldingPosition = 'C';
	 
	 select * from (
select f.atbatID, count(f.atbatID) as cnt
 from mlb.tempFielders f
 where f.fieldingPosition = 'C'
 group by f.atbatID) tmp where tmp.cnt > 1;
	 
	 select fp.atbatID, fp.eliasID, fp.fieldingPosition from mlb.tempFielders fp where fp.atbatID = 1646 and fp.fieldingPosition = 'C'
	 
drop table if exists mlb.tempFielders;




################################# fielders
drop table if exists mlb.tempFielders;

create table mlb.tempFielders 
select a.atbatID, pr.fieldingPosition, pr.eliasID
  from mlb.games g, mlb.rosters pr, mlb.atbats a, mlb.rosters br
 where g.gameID = pr.gameID
	 and pr.battingOrder is not null
	 and g.gameID = a.gameID
	 and g.gameID = br.gameID
	 and a.batterID = br.eliasID
	 and br.teamID != pr.teamID;
	 

drop table if exists mlb.fielders;

create table mlb.fielders 
select f.atbatID, 
       (select fp.eliasID from mlb.tempFielders fp where fp.atbatID = f.atbatID and fp.fieldingPosition = 'C') as C
  from mlb.tempFielders f;
	 
	 
drop table if exists mlb.tempFielders;




########### pitch speeds by year
select p.first, g.gameYear, pt.type, avg(pt.Speed), count(pt.type)
  from mlb.players p, mlb.atbats ab, mlb.games g, mlb.pitches pt
 -- where p.last = 'Vogelsong'
 where p.last in ( 'Vogelsong', 'Nicasio', 'Pavano', 'Bailey')
   and ab.pitcherID = p.eliasID
   and ab.gameID = g.gameID
   and pt.atbatID = ab.atbatID
   -- and (type like '%FastBall' or type = 'Slider' or type like 'Sinker')
 group by p.last, p.first, g.gameYear, pt.type
 order by p.first, pt.type, g.gameYear
 
 
select pa.Speed, pa.type, pa.pitches
  from ssfbl.ppitchattributes pa, mlb.players p
 where p.last = 'Vogelsong'
   and pa.gameSetName = 'regular'
   and atbatSetName = 'all'
   and pa.pitcherID = p.eliasID