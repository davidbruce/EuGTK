
------------------------------------------------------------------------
--# GTK Scale for getting numeric input
------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"border=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical,spacing=5"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok",_("ShowValue")), 
    btnbox = create(GtkButtonBox), 
    lbl = create(GtkLabel,"markup=<b><u>GtkScale</u></b>\n\tfor getting numeric input.\n\t" &
	"Drag the handle or use the mouse wheel to change the value"),
    scale = create(GtkScale,{ 
	{"orientation",HORIZONTAL},
	{"range",0,5}, -- range is min,max
	{"value",0},   -- initial value
	{"digits",2},  -- num of decimals
	{"font","sans 8"},
	{"increments",0.01,0.01}, -- step,page (these control response to mouse wheel, etc)
	{"margin bottom",5},
	{"draw value",TRUE},
	{"has origin",TRUE}})

-- decorate the scale with legends and tick marks;
    for i = 0 to 5 by 0.25 do 
	if integer(i) then -- put numbers at integer positions,
	    set(scale,"add mark",i,3,
		sprintf("<span color='red'><small>%g</small></span>",i))
	end if
	set(scale,"add mark",i,3,"") -- tick marks at every .25 position
    end for
    
    add(win,panel)
    add(panel,{lbl,scale})
    add(btnbox,{btn1,btn2})
    pack_end(panel,btnbox)

    set(btn2,"can default",TRUE) -- ok button defaults when <enter> key pressed;
    set(win,"default",btn2)
    pack(panel,-btnbox)

show_all(win)
main()

--------------------
function ShowValue()
--------------------
atom amt = get(scale,"value")
    Info(win,,sprintf("Value is: <span color='green'>%.2f</span>",amt))
    return 1
end function

