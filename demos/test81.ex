
-------------------------------------------------------------------------------
--# GtkFixed (deprecated)

-- This results in uncooperative, unfriendly and un-maintainable layouts.
-- Looks simple here, but quickly gets out of control - IOW, just like Windows. 
-- Please do NOT learn to use this widget!
-------------------------------------------------------------------------------

include GtkEngine.e	

constant 
    win = create(GtkWindow,"size=200x100,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkFixed),
    lbl = create(GtkLabel,"markup=<b><u>GtkFixed</u></b> (deprecated - do not use!)"),
    img = create(GtkImage,"thumbnails/tiphat1.gif"),
    btn1 = create(GtkButton,"gtk-quit","Quit")
    
    add(win,panel)
    
    set(panel,"put",lbl,2,2)
    set(panel,"put",img,25,60)
    set(panel,"put",btn1,160,80)
    
show_all(win)
main()
