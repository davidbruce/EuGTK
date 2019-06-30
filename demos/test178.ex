

--# calendar demo (3 months shown, +- 30 days highlighted)

include GtkEngine.e
include std/datetime.e -- requires use of gtk: namespace
include std/search.e
include std/math.e

constant 
    win = create(GtkWindow,"border=10,position=1,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical"),
    panel1 = create(GtkBox,0,10),
    panel2 = create(GtkBox,0,160),
    lbl1 = create(GtkLabel,"30 days prior"),
    lbl2 = create(GtkLabel,"  Current Month"),
    lbl3 = create(GtkLabel,"30 days ahead")

constant cal1 = create(GtkCalendar,{
    {"select day",0},
    {"background","gray90"},
    {"override background color",4,"blue"},
    {"display options",
        GTK_CALENDAR_SHOW_HEADING +
        GTK_CALENDAR_SHOW_DAY_NAMES +
        GTK_CALENDAR_NO_MONTH_CHANGE}})

constant sep1 = create(GtkSeparator,1)

constant cal2 = create(GtkCalendar,{
    {"background","white"},
    {"override background color",4,"red"}})
        
constant sep2 = create(GtkSeparator,1)

constant cal3 = create(GtkCalendar,{
        {"select day",0},
        {"background","gray90"},
	{"override background color",4,"green"},
	{"display options",
	    GTK_CALENDAR_SHOW_HEADING +
	    GTK_CALENDAR_SHOW_DAY_NAMES +
	    GTK_CALENDAR_NO_MONTH_CHANGE}})
 
    gtk:add(win,pan)
    gtk:add(pan,{panel1,panel2})
    gtk:add(panel1,{cal1,sep1,cal2,sep2,cal3})
    gtk:add(panel2,{lbl1,lbl2,lbl3})
    
integer 
    month = get(cal2,"month"), 
    year = get(cal2,"year")
    
object dt = datetime:now()
    set(cal1,"select month",month-1,year)
    set(cal3,"select month",month+1,year)
    
    connect(cal2,"day-selected","Update")
    connect(cal2,"next-month","Update")
    connect(cal2,"prev-month","Update")
    connect(cal2,"next-year","Update")
    connect(cal2,"prev-year","Update")

    set(win,"title",datetime:format(dt,"  Today is %A, %B %d, %Y"))
    set(win,"icon","stock_calendar")
    
show_all(win)
Update(cal2)
main()

--------------------------------
global function Update(atom cal)
--------------------------------
object dt = get(cal,"datetime",0)

set(cal1,"date",datetime:subtract(dt,30,DAYS))
set(cal3,"date",datetime:add(dt,30,DAYS))

set(cal1,"tooltip text","Prior date due:\n" & get(cal1,"date",0))
set(cal3,"tooltip text","Next date due:\n" & get(cal3,"date",0))

return 1
end function



