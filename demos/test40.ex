
---------------------------------------------------------------------
--# GtkDrawingArea - draws pie chart of disk usage
---------------------------------------------------------------------

include GtkEngine.e 
include GtkCairo.e
include std/math.e

enum TOTAL, FREE, USED, NAME

ifdef WINDOWS then
constant diskinfo = disk_size("C:")
elsedef
constant diskinfo = disk_size("/")
end ifdef

-- note: no two disk size programs report the same values,
-- so there's no way to know if Euphoria's disk info is more - or less -
-- accurate than any of the others. Eu and df -H reports match the most closely.

constant 
    win = create(GtkWindow,"size=300x300,border_width=10,resizable=FALSE,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL,spacing=10"),
    screen = create(GtkDrawingArea,"size=280x200"), 
    frame = create(GtkFrame),
    evb = create(GtkEventBox),
    lbl = create(GtkLabel,"font=10,color=blue"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit")

    set(lbl,"markup",
	format(`  <b><u>[]</u></b>
	<b>Size:  </b> []
	<span color='red'><b>Used:</b></span> []
	<span color='green'><b>Free: </b></span> []`,
	    {diskinfo[NAME],
	    -- note: g_format_size auto manages size description;
	    gtk_str_func("g_format_size",{P},{diskinfo[TOTAL]}),
	    gtk_str_func("g_format_size",{P},{diskinfo[USED]}),
	    gtk_str_func("g_format_size",{P},{diskinfo[FREE]})}))
	    
    set(screen,"size request",280,200)

    add(win,panel)
    add(panel,screen)
    add(panel,frame)
    add(frame,evb)
    add(evb,lbl)
    add(box,btn1)
    pack(panel,-box)

-- following line redraws the pie chart on program start and
-- whenever the program window is obscured/moved/restored. 
    connect(panel,"draw",_("DrawPieChart")) 

show_all(win)
main()

-------------------------------
function DrawPieChart()
-------------------------------
atom dwin = get(screen,"window")
atom cr = create(GdkCairo_t,dwin) 

set(cr,{
    {"source rgba",255,255,255,255},
    {"operator",CAIRO_OPERATOR_SOURCE},
    {"paint"}})

atom xc = 140.0
atom yc = 95.0
atom radius = 50.0

atom percent_used = (diskinfo[USED]/diskinfo[TOTAL])
atom percent_free = (diskinfo[FREE]/diskinfo[TOTAL])
atom degrees_used = 360 * percent_used
atom degrees_free = 360 * percent_free

-- angles are specified in radians; the zero radial is at 3 o'clock.
-- to get a more natural display, we rotate it to start at high noon.
atom offset = 90 * DEGREES_TO_RADIANS 
atom radians_used = (degrees_used * DEGREES_TO_RADIANS)-offset
atom radians_free = (degrees_free - (90 * DEGREES_TO_RADIANS))-offset

set(cr,{ -- fill free space;
    {"color","green"},
    {"arc",xc, yc, 90.0, -offset, radians_free},
    {"fill"}})

set(cr,{ -- draw border;
    {"color","blue"},
    {"line width",3},
    {"arc",xc, yc, 90.0, 0, math:TWOPI},
    {"stroke"}})

set(cr,{ -- fill used space;
    {"color","red"},
    {"move to",xc,yc},
    {"arc", xc, yc,88, -offset, radians_used},
    {"fill"}})

set(cr,{-- draw center dot;
    {"color","yellow"},
    {"arc",xc, yc, 4.0, 0, math:TWOPI},
    {"fill"}})

set(cr,"destroy")

return 0 -- important to return 0 here!
end function




