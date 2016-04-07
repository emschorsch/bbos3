select t.NAME_TEAM_TX, g.GAME_DT, g.AWAY_TEAM_ID,
       e.BAT_ID, 
			 e.INN_CT, e.OUTS_CT, 
			 ec.LONGNAME_TX, bbc.LONGNAME_TX
  from retrosheet.events e, retrosheet.games g,
	     retrosheet.teams t, retrosheet.lkup_cd_event ec, retrosheet.lkup_cd_battedball bbc
 where e.GAME_ID = g.GAME_ID
	 and g.HOME_TEAM_ID = t.TEAM_ID
	 and e.EVENT_CD = ec.VALUE_CD
	 and e.BATTEDBALL_CD = bbc.VALUE_CD
	 and e.BAT_ID = 'davik003'