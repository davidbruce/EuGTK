
-------------------------------------------------------------------------------
--# GtkCalendar
-- Calendar automatically loads to current date unless told otherwise.
-- Calendar date i/o formats are same as std/datetime.e formats
-------------------------------------------------------------------------------

include GtkEngine.e
include std/datetime.e -- contains an "add" function

constant 
    win = create(GtkWindow,"size=300x300,border_width=10,position=1,$destroy=Quit"),
    pan = create(GtkBox,"orientation=VERTICAL"),
    cal = create(GtkCalendar,"$day selected double click=ShowDate"),
    lbl = create(GtkLabel,"margin_top=10"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","ShowDate")
    
    gtk:add(win,pan) -- namespace to choose gtk:add not datetime:add
    gtk:add(pan,{cal,lbl})
    gtk:add(box,{btn1,btn2})
    pack_end(pan,box)
    
show_all(win)
main()

--------------------------
global function ShowDate()
--------------------------
object clicktime = get(cal,"datetime")
    set(cal,"mark day",get(cal,"day"))
    set(lbl,"markup",  -- some unusual formatting:
    datetime:format(clicktime,`
____________<b>Date selected:</b> %A, %b %d
	     <b>Time clicked:</b> %l:%M %p`))
return 1
end function
