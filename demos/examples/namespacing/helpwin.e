
namespace help

include GtkEngine.e

global constant 
    win = create(GtkWindow,
    "title=Help;size=200x50,position=1x1;border=10;$delete-event=hide"),
    lbl = create(GtkLabel,"markup=<b>Help Window</b>\nNot going to be very much help!")
    
    add(win,lbl)
 
-------------------------
global function onHelp()
-------------------------
show_all(help:win)
return 1
end function
