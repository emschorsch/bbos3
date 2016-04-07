from www.page import Page
import re
from datetime import date
from datetime import timedelta
from regularExpressions import pattern 

class GamedayDirectoryStructure:
    def __init__(self, rootURL, league):
        self.rootURL = rootURL + league
        
    def getGameURLsForGame(self, gameName):
        """gid_2008_09_24_pitmlb_milmlb_1"""
        """http://gd2.mlb.com/components/game/mlb/year_2007/month_08/day_17/"""
        
        year = gameName[4:8]
        month = gameName[9:11]
        day = gameName[12:14]
        
        gameURL = self.__buildDayURL__(year, month, day) + gameName + "/"
            
        return [gameURL]
    
    def __buildDayURL__(self, year, month, day):
        dayURL = self.rootURL + "/year_" + year + "/month_" + month + "/day_" + \
            day + "/"
        
        return dayURL
         
    def getGameURLsForDay(self, dateTuple):
        (year, month, day) = dateTuple
        
        dayURL = self.__buildDayURL__(year, month, day) + "/"
        
        gameURLs = self.__getGameURLsForDay__(dayURL)
        
        return gameURLs        
          
    def getGameURLsForYear(self, year):
        yearURLs = self.__getGameURLsForYear__(year)
            
        return yearURLs        
          
    def getGameURLsForLastNumberOfDays(self, daysBack):
        gameURLs = []
        
        oneday = timedelta(days=1)
        
        yesterday = date.today() - oneday
        
        for days in range(0,daysBack):
            dayToLoad = yesterday - (days * oneday)
            
            year = str(dayToLoad.year)
            month = str(dayToLoad.month)
            day = str(dayToLoad.day)
            if len(month) < 2: month = '0%s' % month
            if len(day) < 2: day = '0%s' % day
        
            dayURL = self.__buildDayURL__(year, month, day) + "/"
        
            daysURLs = self.__getGameURLsForDay__(dayURL)
            
            gameURLs.extend(daysURLs)
            
        return gameURLs        
    
    def getGameURLsForMonth(self, monthURL):
        dayURLsForMonth = self.__getDayURLsForMonth__(monthURL)
            
        gameURLs = []
        
        for dayURL in dayURLsForMonth:
            gameURLsForDay = self.__getGameURLsForDay__(dayURL)
            
            gameURLs.extend(gameURLsForDay)
            
        return gameURLs
    
    def __getGameURLsForYear__(self, year):
        yearURL = self.__getYearURL__(year)
        
        monthURLs = self.__getMonthURLsForYear__(yearURL)
        
        dayURLs = []
        
        for monthURL in monthURLs:
            dayURLsForMonth = self.__getDayURLsForMonth__(monthURL)
            
            dayURLs.extend(dayURLsForMonth)
            
        gameURLs = []
        
        for dayURL in dayURLs:
            gameURLsForDay = self.__getGameURLsForDay__(dayURL)
            
            gameURLs.extend(gameURLsForDay)
            
        return gameURLs
            
    def __getGameURLsForDay__(self, dayURL):
        gameURLs = []
        
        if (self.__dateInFuture__(dayURL)): return []
            
        gameIDs = self.__parseGameIDs__(dayURL)
        
        for gameID in gameIDs:
            gameURL = dayURL + '/' + gameID
            
            gameURLs.append(gameURL)
            
        gameURLs = self.__filterGameURLsForFullGames__(gameURLs)
        
        return gameURLs 
    
    def __dateInFuture__(self, dayURL):
        #"hlb/year_2008/month_09/day_24/
        
        year = int(pattern.capture("year_(\d\d\d\d)", dayURL))
        month = int(pattern.capture("month_(\d\d)", dayURL))
        day = int(pattern.capture("day_(\d\d)", dayURL))
        
        today = date.today()
        
        yearNow = today.year
        monthNow = today.month
        dayNow = today.day

        yearGreaterThanCurrentYear = (year > yearNow)
        yearEqualToCurrentYearButMonthGreaterThanCurrentMonth = (year == yearNow and month > monthNow)
        yearEqualAndMonthEqualButDayGreaterThanCurrentDay = (year == yearNow and month == monthNow and day > dayNow)
        
        return yearGreaterThanCurrentYear or yearEqualToCurrentYearButMonthGreaterThanCurrentMonth \
            or yearEqualAndMonthEqualButDayGreaterThanCurrentDay
        
    def __filterGameURLsForFullGames__(self, gameURLs):
        filteredURLs = []
        
        for url in gameURLs:
            hitURL = url + "/inning/inning_hit.xml"

            hitXML = Page(hitURL).getContent()
            
            if hitXML.find("404 Not Found") == -1:
                filteredURLs.append(url)   
        
        return filteredURLs     
            
    def __parseGameIDs__(self, dayURL):
        dayURLContent = Page(dayURL).getContent()
        
        #<li><a href="gid_2007_08_17_kcamlb_oakmlb_1/"> gid_2007_08_17_kcamlb_oakmlb_1/</a></li>

        pattern = re.compile('gid_.*\/\">')
        
        gameIDs = pattern.findall(dayURLContent)
        
        gameIDs = [id[0:-3] for id in gameIDs]
        
        return gameIDs

       
    def __getDayURLsForMonth__(self, monthURL):
        dayURLs = []
        
        days = ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', \
                '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', \
                '25', '26', '27', '28', '29', '30', '31')
        
        for day in days:
            dayURL = monthURL + '/day_' + day
            
            dayURLs.append(dayURL)
            
        return dayURLs
        
    def __getMonthURLsForYear__(self, yearURL):
        monthURLs = []
        
        months = ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')
        
        for month in months:
            monthURL = yearURL + '/month_' + month
            
            monthURLs.append(monthURL)
            
        return monthURLs
        
    def __getYearURL__(self, year):
        yearURL = self.rootURL + '/year_' + str(year)
        
        return yearURL
        
    