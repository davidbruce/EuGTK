-- 
--# Days Between Dates, date parsing <span color='green'>Kenneth Rhodes</span>
--  by Kenneth Rhodes 
--  requires OpenEuphoria 4.x 

--  Added a couple calendars for ease of use - Irv
--  Dates can be typed in using various formats,
--  or selected from the calendars via mouse.
 
include std/datetime.e 
include GtkEngine.e 
 
constant instructions = { 
"Calculate the number of days between dates",  
""" 
Select start and end dates from the calendars with a mouse, 
then click the OK button, or type a date into the boxes below
the calendars. 

For typed dates, formats include: <u>m/d/yyyy</u>, m/d/yy, yyyy/m/d, etc.
Underlined format is the expected. Others may work too,
such as Jan 4, 2000 or 15 january, 1926, or 4-2-65, 
or Thurs Dec 12, 42 or 42 march 6. Experiment!
 
The program displays the number of days between the  
starting and ending date as well as the week day names 
of the starting and ending dates.

-- Kenneth Rhodes, Irv Mullins 
 
"""} 

constant -- INTERFACE 
    win = create(GtkWindow,"title = Days Between Dates,border=10,$destroy=Quit"), 
    pan = create(GtkBox,"orientation=vertical,spacing=10"), 
    cal1 = create(GtkCalendar,"name=cal1,font=8,$day-selected=Update"),
    StartDate = create(GtkEntry,"placeholder text=Start Date,$activate=Parse,data=cal1"),
    cal2 = create(GtkCalendar,"name=cal2,font=8,$day-selected=Update"), 
    EndDate = create(GtkEntry,"placeholder text=End Date,$activate=Parse,data=cal2"), 
     
    btnbox = create(GtkButtonBox), 
    btn1 = create(GtkButton,"gtk-quit","Quit"), 
    btn2 = create(GtkButton,"gtk-help","Help"), 
    btn3 = create(GtkButton,"gtk-ok","GetDaysBetweenDates") 
     
    set(StartDate,"tooltip text","Enter a date manually in most any standard format") 
    set(EndDate,"tooltip text","Enter a date manually in most any standard format") 

    gtk:add(win,pan) 
    gtk:add(pan,{cal1, StartDate, cal2, EndDate}) 
     
    pack_end(pan,btnbox) 
    gtk:add(btnbox,{btn1,btn2,btn3}) 
    set(btn3,"grab focus") 
     
show_all(win) 
main() 
 
-------------------------------------------------------------------
global function DaysBetweenDates(datetime dt1, datetime dt2)              
-------------------------------------------------------------------
	return floor(diff(dt1,dt2)/86400)  -- 86400 = seconds in a day          
end function                                                                                              --                                                                                               -- 

------------------------- 
global function Help() -- 
-------------------------
    return Info(win,"instructions",
    instructions[1],instructions[2],,
    "thumbnails/cal.png") 
end function 
 
---------------------------
global function Update() -- update date displays whenever either changes;
---------------------------
set(StartDate,"text",get(cal1,"date",0)) 
set(EndDate,"text",get(cal2,"date",0))
return 1
end function

---------------------------------------------- 
global function Parse(atom ctl, object cal) --
----------------------------------------------
object date_in = get(ctl,"text") -- save for error msg;
boolean twodigityear = TRUE
integer month_loc = 0

object x = split_any(date_in," /") 
  x = pad_tail(x,3,"")
  for i = 1 to 12 do 
    for j = 1 to 3 do
     if length(x[j]) > 2 and to_number(x[j]) > 0 then twodigityear = FALSE end if
     if match(month_abbrs[i],proper(x[j])) = 1 then 
	 x[j] = sprintf("%d",i) month_loc = j
	end if
    end for 
  end for

x = join(x,"-")

cal = unpack(cal) -- get target calendar;

object dt
     
  if month_loc <= 1 then dt = datetime:parse(x,"%m %d %Y") end if
  if month_loc = 2 then dt = datetime:parse(x,"%d %m %Y") end if
  if month_loc = 3 then dt = datetime:parse(x,"%Y %d %m") end if

  if atom(dt) then dt = datetime:parse(x,"%d %m %Y") end if
  if atom(dt) then dt = datetime:parse(x,"%Y %m %d") end if
  if atom(dt) then 
     set(ctl,"text",date_in & " <= ERROR") -- show orig input;
     set(ctl,"color=red,overwrite mode=TRUE")
     set(ctl,"select region",1,-1)
     return -1
  else
     if twodigityear then dt[1] += 1900 end if
     set(ctl,"color=black,overwrite mode=FALSE")
     set(cal,"date",dt)
     set(ctl,"text",datetime:format(dt,"%m/%d/%Y"))
  end if

return 1
end function

---------------------------------------------------------- 
global function GetDaysBetweenDates()  -- 
----------------------------------------------------------- 
Update() -- make sure dates are displayed in entry boxes;
atom dbd 
object 
 dt1 = get(cal1,"datetime"), -- dt format to compute with;
 dt2 = get(cal2,"datetime"),
 dd1 = get(cal1,"date",0), -- default format for display;
 dd2 = get(cal2,"date","<b>%A, %B %d</b>,\nwhich is day %j of the year %Y") -- custom fmt;
 
 dbd = DaysBetweenDates(dt1,dt2) 
 
 Info(win, "Days Between Dates", 
	text:format("There are [,,] days",dbd),
	text:format("between <b>[]</b>\nand []", 
	{dd1,dd2}),GTK_BUTTONS_CLOSE,"thumbnails/cal.png",,,-9) 
	 
return 1 
end function 
