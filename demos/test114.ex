
--------------------------------------------------------
--# 'Trapping' the delete event
--------------------------------------------------------
-- note: here we trap the delete-event first.
-- event signals occur *before* the action takes place,
-- while the other signals (clicked, destroy, etc) occur *after* 
-- the action is finished.

include GtkEngine.e

constant -- in win below, we catch the delete-event before the destroy signal:
    win = create(GtkWindow,"size=300x100,border=10,position=1,$delete-event=Bar,$destroy=Quit") ,
    panel = create(GtkBox,VERTICAL),
    lbl = create(GtkLabel,"markup=<u><b>Trapping delete event</b></u>\n" &
	"Try closing the window with the titlebar <b>[X]</b>"),
    box = create(GtkButtonBox),
    btn = create(GtkButton,"gtk-quit","Quit")

    add(win,panel)
    add(panel,lbl)
    add(box,btn)
    pack(panel,-box)
    
show_all(win)
main()

------------------------------------------------------------------------
global function Bar()
------------------------------------------------------------------------
-- here you could save your work, clean up temp files, etc. before closing!
-- return value (1 or 0) determines whether further signals will be 
-- processed.
    if Question(win,"Close?","Are you sure?") = MB_YES then
	return 0 -- next connection will be activated (quit)
    else
	return 1 -- following connections will be ignored
    end if
end function

