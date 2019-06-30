
------------------------------------------------------------------------
--# CSS styling

-- If you run this from an xterm or from WEE with term, 
-- you can see the css code displayed
------------------------------------------------------------------------

include GtkEngine.e
include std/io.e

constant css = locate_file("resources/mystyle4.css") 
constant provider = create(GtkCssProvider,css)

constant 
    win = create(GtkWindow,"name=mainwin,size=300x300,border=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    lbl1 = create(GtkLabel,"font=Courier bold 12,markup=CSS:\n" & css),
    btn = create(GtkButton,"gtk-quit","Quit"),
    box = create(GtkButtonBox,"margin_left=10,margin_right=10,margin_bottom=10"),
    cow = create(GtkImage,"thumbnails/cowbell2.png"),
    lbl2 = create(GtkLabel,"text=MOO?,name=cowsay")
    -- name required so that css can refer to this label by name

    add(win,panel)
    add(panel,{lbl1,lbl2})
    add(box,btn)
    pack(panel,{-box,-cow})

show_all(win)
main()





