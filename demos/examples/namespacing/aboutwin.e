
namespace about

include GtkEngine.e

global constant 
    win = create(GtkWindow,
    "title=About;size=200x100;position=200x350;border=10;$delete-event=hide"),
    lbl = create(GtkLabel,
    "markup=<b>About Window</b>\nThis is a hand-built about window\nUse pre-built if you can!")
    
    add(win,lbl)

-------------------------
global function onAbout()
-------------------------
show_all(about:win)
return 1
end function
