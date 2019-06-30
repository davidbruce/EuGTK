
--------------------------------------------------------------------------
--# Auto-Scrolling text
--------------------------------------------------------------------------

include GtkEngine.e

atom pos = 0

constant 
	txt = "<b>LGPL</b>\n" & flatten(LGPL),
	win = create(GtkWindow,"size=680x240,border=10,position=1,$destroy=Quit"),
	pan = create(GtkBox,"orientation=HORIZONTAL"),
	eventbox = create(GtkEventBox),
	pix = create(GdkPixbuf,"thumbnails/euphoria-linux.gif"),
	img = create(GtkImage,get(pix,"scale simple",200,200,1)),
	hadj = create(GtkAdjustment,0,0,1000,.01,.01,.01),
	vadj = create(GtkAdjustment,0,0,1000,.01,.01,.01),
	scrolwin = create(GtkScrolledWindow,hadj,vadj),
	scroller = create(GtkViewport,"background=cornsilk,tooltip text=Scrolls continuously"),
	scrollbl = create(GtkLabel,"margin=10")
	
	set(scrollbl,"markup",txt)
	set(scrolwin,"border width",10)
	
	add(win,pan)
	add(pan,eventbox)
	add(eventbox,img)
	pack(pan,scrolwin,TRUE,TRUE)
	add(scrolwin,scroller)
	add(scroller,scrollbl)

constant timer = create(GTimeout,6,call_back(routine_id("Scroll")))

show_all(win)
main()

--------------------------
global function Scroll()
---------------------------
pos += .1 
if pos > 250 then -- reset and start over;
	pos = 1
	set(vadj,"value",pos)
end if
if pos > 50 then -- wait a few seconds before starting scroll;
	set(vadj,"value",pos-50)
end if
return 1
end function
