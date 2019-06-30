
-----------------------------------------------------------------------------------------------
--# <span color='red'><b>WARNING!</b></span> do not 'full-screen' this one! May cause seizures!
-----------------------------------------------------------------------------------------------

include GtkEngine.e

integer x = 0

constant 
    colors = {"Red","Green","Blue","Cyan","Yellow","White","Purple","Orange"},
    win = create(GtkWindow,"size=100x100,position=1,$destroy=Quit"),
    lbl = create(GtkLabel,"font=bold"),
    css = create(GtkCssProvider,"GtkLabel {text-shadow: 1px 1px white;}"),
    tick = create(GTimeout,250,_("Rotate_Colors")) --(1,2)
    
    add(win,lbl)
    
show_all(win)
main()

---------------------------------
function Rotate_Colors()
---------------------------------
	x += 1 
	if x > length(colors) then x = 1 end if
	set(win,"background",colors[x])
	set(lbl,"text",colors[x])
return TRUE
end function

-- [1] timeout is set to trigger every 1/4 sec (250ms)
--  and as long as the function it calls returns TRUE, it will, 
--  just like a Timex, 'keep on ticking'
--  When  the function called returns FALSE, the timer will be 
--  shut down & destroyed.

-- [2] timeouts and idles must always be given a call_back to rid,
--  never a function name. 

