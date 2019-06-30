
--------------------------------------------------
--# Display dimensions
--------------------------------------------------

include GtkEngine.e

constant 
    disp = create(GdkDisplay),
    scrn = get(disp,"default screen"),
    icon = valid_icon_name({"video-display","computer","screen","cs-screen"})

constant 
    win = create(GtkWindow,"size=200x100,border_width=5,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    img = create(GtkImage,icon,GTK_ICON_SIZE_DIALOG),
    lbl = create(GtkLabel,sprintf("Screen Dimensions:\n %d x %d",
	{get(scrn,"width"),get(scrn,"height")})),
    box = create(GtkButtonBox),
    btn = create(GtkButton,"gtk-quit","Quit")

    add(win,panel)
    add(panel,{img,lbl})
    add(box,btn)
    pack(panel,-box)
    
show_all(win)
main()


