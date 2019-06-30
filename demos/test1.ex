
----------------------------------------------------------------------------
--# Yet Another <b>Hello World!</b> program
----------------------------------------------------------------------------

include GtkEngine.e

constant --[1] create the widgets;
    
    win = create(GtkWindow,"border width=10,icon=face-laugh,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical"), 
    box = create(GtkButtonBox),
    btn = create(GtkButton,"gtk-quit", "Quit"),
    lbl = create(GtkLabel,"color=blue")

    --[2] set some properties;
    
    set(lbl,"markup", -- style the text using basic html;
    "<b><u><span color='red'><big>Hello World!</big></span></u></b>\n\n" &
    "This demos a simple window with\na label and a quit button.\n")

    --[3] add widgets to containers;
    
    add(win,pan)
    add(pan,lbl)
    add(box,btn)
    pack(pan,-box)
 
show_all(win) --[4] instantiate widgets;
main()        --[5] enter main processing loop;
