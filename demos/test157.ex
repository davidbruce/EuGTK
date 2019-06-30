
-------------------------------------------------------------------
--# CSS Radial Gradient
-------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"name=mainwin,border=10,size=400x300,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    css = create(GtkCssProvider,locate_file("resources/mystyle2.css")),
    lbl0 =  create(GtkLabel,"markup=<b><u>Radial Gradient</u></b>\n\t\tspecified in mystyle2.css"),
    lbl1 = create(GtkLabel,"text=Moo?,angle=23"),
    cow = create(GtkImage,"thumbnails/cowbell2a.gif"),
    btnbox = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit")
    
    set(lbl1,"font","Purisa, Comic Sans MS bold 48")
    add(win,panel)
    add(panel,{lbl0,lbl1,cow})
    add(btnbox,btn1)
    pack_end(panel,btnbox)

show_all(win)
main()



