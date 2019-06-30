#! /usr/bin/eui

include GtkEngine.e

constant theme = create(GtkIconTheme) -- get the current theme, and add 2 search locations:
    set(theme,"append search path",prog_dir & "/thumbnails") -- local thumbs;
    set(theme,"append search path",canonical_path("~/demos/thumbnails")) -- demo thumbs;

constant docs = `markup=
<u><b>Adding Icons</b></u>

 This shows how to add custom icons
 without having to add them to the 
 current or default theme folders

 This means you can neatly package 
 your program along with needed
 icons and the whole folder and
 subfolders can be moved as desired.

 Note: icons must be .png. Hover over
 the buttons to see location info.
`
constant 
    win = create(GtkWindow,"size=300x300,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical"),
    lbl = create(GtkLabel,docs),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"mongoose#_Quit","Quit"),   -- from demos/thumbs;
    btn2 = create(GtkButton,"shapes#_OK"),              -- from local thumbs;
    btn3 = create(GtkButton,"face-cool#Cool!")          -- from theme;
    
    set(btn1,"tooltip text","Button Quits,\n image is from ~/demos/thumbnails folder")
    set(btn2,"tooltip text","Button does nothing,\n image is from local thumbnails folder ")
    set(btn3,"tooltip text","Button does nothing,\n image is from current theme")
    
    add(win,pan)
    add(pan,lbl)
    add(box,{btn1,btn2,btn3})
    pack(pan,-box)
    
show_all(win)
main()
