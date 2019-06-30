
------------------------------------------------------------------------
--# Animated images 
------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=160x140,border=10,position=1,$destroy=Quit"),
    pan = add(win,create(GtkBox,"orientation=vertical,spacing=10")),
    lbl = add(pan,create(GtkLabel,"markup=<b><u>Animated</u></b>\nimages are easy to use!")),
    img = add(pan,create(GtkImage,"thumbnails/laurel_and_hardy_dancing.gif")),
    btn = add(pan,create(GtkButton,"gtk-quit#_Quit","Quit"))

-- note: add() returns the handle of the item that was added, 
-- so we can sometimes nest calls to create and add into a one-liner.
-- sometimes neater, sometimes very confusing!	

show_all(win)
main()

