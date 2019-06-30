
------------------------------------------------------------
--# Decorated property for Windows
------------------------------------------------------------

include GtkEngine.e

constant docs = `
____<b><u>Decorated property</u></b>

    Setting window 'Decorated' to FALSE
    gets rid of the titlebar, which might
    be good for splash windows, etc.
    <span color='red'>
    <b><u>Just remember to leave a way out!</u></b>
    </span>`

constant 
    win = create(GtkWindow,"size=300x300,position=1,border_width=10,decorated=FALSE,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel,{{"markup",docs}}),
    btnbox = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    arrow = create(GtkArrow,GTK_ARROW_DOWN)
    set(arrow,{
        {"color","red"},
        {"size request",100,100}})
        add(panel,arrow)

    add(win,panel)
    add(panel,{lbl,arrow})
    add(btnbox,btn1)
    pack(panel,-btnbox)
    
show_all(win)
main()


