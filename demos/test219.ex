------------------------------
--# Holiday Calendar
------------------------------
constant holidays = 
{"12/25/2017 = Christmas Day",
 "12/26/2017 = Boxing Day CA",
 "12/31/2017 = New Years Eve",
 "01/01/2018 = New Years Day",
 "01/15/2018 = M.L.King Jr. Day US",
 "02/02/2018 = Groundhog Day US",
 "02/12/2018 = Lincoln's Birthday",
 "02/14/2018 = Valentine Day Ash Wed.",
 "02/19/2018 = Presidents Day US Family Day CA",
 "02/22/2018 = Washington's Birthday US",
 "03/11/2018 = Daylight Savings Time begins",
 "03/17/2018 = St. Patrick's Day",
 "03/20/2018 = Spring Begins",
 "03/25/2018 = Palm Sunday",
 "03/30/2018 = Good Friday",
 "03/31/2018 = Passover begins",
 "04/01/2018 = Easter Sunday All Fools Day",
 "04/02/2018 = Easter Monday Canada",
 "04/22/2018 = Earth Day",
 "05/13/2018 = Mother's Day",
 "05/19/2018 = Armed Forces Day US",
 "05/20/2018 = Shavuot",
 "05/21/2018 = Victoria Day CA",
 "05/28/2018 = Memorial Day US",
 "06/14/2018 = Flag Day US",
 "06/17/2018 = Fathers' Day",
 "06/21/2018 = Summer Begins",
 "07/01/2018 = Canada Day",
 "07/04/2018 = Independence Day US",
 "08/06/2018 = Civic Holiday CA",
 "09/03/2018 = Labor Day",
 "09/10/2018 = Rosh Hashanah",
 "09/11/2018 = Patriot Day US",
 "09/19/2018 = Yom Kipppur",
 "09/22/2018 = Autumn begins",
 "09/24/2018 = Sukkot",
 "10/08/2018 = Columbus Day US Thanksgiving CA",
 "10/31/2018 = Halloween",
 "11/01/2018 = All Saints Day",
 "11/04/2018 = US Daylight Savings End",
 "11/06/2018 = Election Day US",
 "11/11/2018 = Veterans Day US Rememberance Day CA",
 "11/22/2018 = Thanksgiving Day US",
 "12/01/2018 = Chanukah begins",
 "12/07/2018 = Pearl Harbor Day",
 "12/21/2018 = Winter begins",
 "12/25/2018 = Christmas Day",
 "12/26/2018 = Boxing Day CA",
 "12/31/2018 = New Years Eve",
 "01/01/2019 = New Years Day",
 "01/21/2019 = Martin Luther King Day",
 "02/02/2019 = Ground Hog Day",
 "02/05/2019 = Chinese New Year",
 "02/12/2019 = Lincoln's Birthday",
 "02/14/2019 = Valentine's Day",
 "02/18/2019 = Presidents' Day",
 "03/05/2019 = Mardi Gras",
 "03/06/2019 = Lent",
 "03/10/2019 = Daylight Saving Time",
 "03/17/2019 = St. Patrick's Day",
 "03/20/2019 = March equinox",
 "04/20,2019 = Passover begins",
 "04/21/2019 = Easter",
 "05/05/2019 = Cinco de Mayo",
 "05/12/2019 = Mothers' Day",
 "05/27/2019 = Memorial Day",
 "06/16/2019 = Fathers' Day",
 "07/04/2019 = Independence Day US",
 "09/02/2019 = Labor Day",
 "10/09/2019 = Yom Kippur",
 "10/14/2019 = Columbus Day",
 "10/31/2019 = Halloween",
 "11/11/2019 = Veterans Day",
 "12/22/2019 = Winter Solstice",
 "12/25/2019 = Christmas Day",
 "12/31/2019 = New Years Eve",
 "01/01/2020 = New Years Day",
 $
} 

include GtkEngine.e

constant 
 detail_func = call_back(routine_id("Details")),
 win = create(GtkWindow,"size=100x80,border=5,$destroy=Quit"),
 pan = create(GtkBox,"orientation=vertical,spacing=5"),
 cal = create(GtkCalendar),
 box = create(GtkButtonBox),
 btn1 = create(GtkButton,"gtk-quit","Quit"),
 btn2 = create(GtkCheckButton,"Show Holidays","toggleDetails")
 
 add(win,pan)
 add(pan,cal)
 add(box,{btn1,btn2})
 pack(pan,-box)

 set(cal,"detail height rows",4)
 set(cal,"detail width chars",10)
 set(cal,"display options",GTK_CALENDAR_SHOW_ALL)
 
object now = date()
 set(cal,"select day",now[3])
 set(btn1,"tooltip text","Click to exit")
 set(btn2,"tooltip text","Toggle Holiday Listing")

show_all(win)
ifdef WINDOWS then Info(,,"Sorry","Broken in Windows!") end ifdef
main()

------------------------------------------
global function toggleDetails(atom ctl) --
------------------------------------------
gtk_proc("gtk_calendar_set_detail_func",{P,P,P,P},{cal,detail_func,0,0})
set(cal,"property","show-details",get(ctl,"active"))
set(win,"restore")
return 0
end function

-----------------------------------------------------------------------
function Details(atom cal, integer y, integer m, integer d, atom data)
-----------------------------------------------------------------------
object testdate = sprintf("%02d/%02d/%d",{m+1,d,y}) -- note month offset!
return allocate_string(GetDetail(testdate))
end function

------------------------------------
function GetDetail(object testdate)
------------------------------------
object d = 0
integer curr_mo = get(cal,"month")
for i = 1 to length(holidays) do
  d = split(holidays[i],"=") 
  d[1] = trim(d[1]) 
  d[2] = trim(d[2]) 
  if equal(testdate,d[1]) then
     return sprintf("<span color='red'>%s</span>",{d[2]})
  end if
end for
return ""
end function


