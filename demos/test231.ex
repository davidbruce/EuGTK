
----------------------------------------------------------------------------
--# Animated images, icon theme search path
----------------------------------------------------------------------------
-- note: you must create a eugtk folder inside your hidden .config folder,
-- and add a foxy.png image to that folder, otherwise the button will not 
-- have an icon.
-- By putting images for buttons in that folder, your program will be able to
-- find them no matter where (in your home path) your program is located.
-- This is of limited utility, since IconTheme only looks for .png images.

include GtkEngine.e

constant theme = create(GtkIconTheme)  -- only for icons, not images
    set(theme,"append search path",canonical_path("~/.config/eugtk"))

constant 
    win = create(GtkWindow,"size=160x140,border=10,position=1,$destroy=Quit"),
    pan = add(win,create(GtkBox,"orientation=vertical,spacing=10")),
    lbl = add(pan,create(GtkLabel,"markup=<b><u>Animated</u></b>\nimages are easy to use!")),
    img = add(pan,create(GtkImage,"thumbnails/laurel_and_hardy_dancing.gif")),
    btn = add(pan,create(GtkButton,"foxy#_Quit","Quit"))

-- note: add() returns the handle of the item that was added, 
-- so we can sometimes nest calls to create and add into a one-liner.	

show_all(win)
main()

