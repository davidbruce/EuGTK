
--------------------------------------------------------------
--# Custom (changeable) tooltips
--------------------------------------------------------------

include GtkEngine.e

constant docs = `markup=
<u><b>Custom Tooltip</b></u>
Mouse over the ok button to see it.
Move away
Rinse
Repeat ...
`
integer ct = 99

constant 
	win = create(GtkWindow,"size=300x100,border=10,position=1,$destroy=Quit"),
	pan = create(GtkBox,"orientation=VERTICAL"),
	lbl = create(GtkLabel,docs),
	sep = create(GtkSeparator,"margin=10"),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-ok"),
	box = create(GtkButtonBox)

-- create a custom tooltip:
constant ttwin = create(GtkWindow,GTK_WINDOW_POPUP)
	set(ttwin,{
	  {"decorated",FALSE},
	  {"border width",10},
	  {"background","skyblue"}})

constant ttpanel = create(GtkBox,VERTICAL)
	add(ttwin,ttpanel)

constant ttimage = create(GtkImage,"thumbnails/bar.gif")
	add(ttpanel,ttimage)

constant tip = create(GtkLabel)
	set(tip,"markup","<i><b>Tipsey</b></i> tip")
	add(ttpanel,tip)
	show_all(ttpanel)

set(btn2,"tooltip window",ttwin)
connect(btn2,"query-tooltip","ShowTip")
connect(btn2,"leave-notify-event","Drink")

object fmt = 
"""
<b>%d</b> bottles of beer on the wall,
%d bottles of beer,
Take one down, drink it down, 
now there are
<b>%d</b> bottles of beer on the wall!
"""
	add(win,pan)
	add(pan,{lbl,sep})
	add(box,{btn1,btn2})
	pack(pan,-box)
	
show_all(win)
main()

------------------------
global function Drink()
------------------------
ct -= 1
return ct
end function

----------------------------------------------------------------------------------------------
global function ShowTip(atom ctl, integer x, integer y, integer mode, atom t, atom data)
----------------------------------------------------------------------------------------------
set(tip,"markup",sprintf(fmt,{ct,ct,ct-1}))
return ct > 0 -- stops showing tip when ct = 0
end function

