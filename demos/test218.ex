-----------------------------------------------------------
--# Context-sensitive tooltip with mouse position and icon
-----------------------------------------------------------

include GtkEngine.e

constant 
	win = create(GtkWindow,"size=100x80,$query-tooltip=Tip,$destroy=Quit"),
	pan = create(GtkBox,"orientation=vertical"),
	lbl = create(GtkLabel,"move mouse over dates"),
	cal = create(GtkCalendar),
	btn = create(GtkButton,"gtk-quit","Quit"),
	icn = create(GdkPixbuf,"thumbnails/mouse.png",24,24)
	
	add(win,pan)
	add(pan,{lbl,cal})
	pack_end(pan,btn)

	set(win,"property","has-tooltip",TRUE)
	
show_all(win)
ifdef WINDOWS then Warn(,"Sorry","Windows","Doesn't know how!") end ifdef
main()

--------------------------------------------------------------------------------------------
global function Tip(atom ctl, integer x, integer y, integer keymode, Tooltip tip, atom data)
--------------------------------------------------------------------------------------------
object z = get(cal,"allocation") -- ensure inside calendar
z[2] += 55 -- ignore the month/year bar and day names bar;
if is_in_rectangle(z,x,y) then
        set(tip,"icon",icn)
	set(tip,"markup",text:format("Mouse at x:[] y:[]",{x,y}))
	return 1
else
	return 0
end if
end function



	
