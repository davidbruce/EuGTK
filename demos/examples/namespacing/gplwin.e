namespace gpl

include GtkEngine.e

global constant 
    win = create(GtkWindow,
    "title=License;size=200x150,position=400x300;border=10;$delete-event=hide"),
    lbl = create(GtkLabel,LGPL)
    
    add(win,lbl)
 
-------------------------
global function onGPL()
-------------------------
show_all(win)
return 1
end function