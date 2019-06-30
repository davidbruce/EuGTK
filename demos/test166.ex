
------------------------------------------------------------------
--# GtkToggleButtons and GtkCheckButtons with icons,
------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>Adding Icons</b></u>
to toggle buttons or check buttons.
Here we use the same stock icon, with 
different labels.

Note that there <i>is</i> a difference 
between FullScreen and Maximized windows.
`
constant win = create(GtkWindow,{
    {"border width",10},
    {"default size",200,100},
    {"hide titlebar when maximized",TRUE},
    {"position",GTK_WIN_POS_CENTER},
    {"connect","destroy","Quit"}})

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)
	
constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)
	
constant btn1 = create(GtkCheckButton,{
    {"label"," _Full Screen"},
    {"always show image",TRUE},
    {"image",create(GtkImage,"view-fullscreen",4)},
    {"tooltip markup","A <b>Check</b> button"},
    {"signal","toggled","toggle_full_screen"}})
	
constant btn2 = create(GtkToggleButton,{
    {"always show image",TRUE},
    {"image",create(GtkImage,"view-fullscreen",4)},
    {"label"," _Maximize"},
    {"tooltip markup","A <b>Toggle</b> button"},
    {"signal","toggled","toggle_maximize"}})

constant btnbox = create(GtkButtonBox,1)
    add(btnbox,{btn1,btn2})
    pack(panel,-btnbox)
	
show_all(win)
main()

---------------------------------------------
global function toggle_full_screen(atom ctl)
---------------------------------------------
    if get(ctl,"active") then
	set(win,"fullscreen")
    else
	set(win,"unfullscreen")
    end if
return 1
end function

-----------------------------------------
global function toggle_maximize(atom ctl)
-----------------------------------------
	if get(ctl,"active") then
	    set(win,"maximize")
	else
	    set(win,"unmaximize")
	end if
return 1
end function
