
------------------------------------------------------------------------------
--# Display size, mouse location within window, etc.
------------------------------------------------------------------------------

include GtkEngine.e

constant 
    disp = create(GdkDisplay),
    scrn = get(disp,"default screen"),
    win = create(GtkWindow,"size=200x100,border_width=10,position=1,icon=gnome-run,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL,10),
    top = create(GtkBox,HORIZONTAL,10),
    pix = create(GdkPixbuf,"thumbnails/gnome-run.png",100,100,1),
    img = create(GtkImage,pix),
    lbl = create(GtkLabel,"markup='Show info about computer display\nMove window, click OK button'"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","ShowStats"),
    box = create(GtkButtonBox),
    tick = create(GTimeout,250,_("ShowStats"))
    
    add(win,panel)
    add(panel,top)
    add(top,{img,lbl})
    add(box,{btn1,btn2})
    pack(panel,-box)

show_all(win)
main()

---------------------------------------------------
global function ShowStats()
---------------------------------------------------
object 
    pointer_loc = get(win,"pointer"),
    cursor_size = get(disp,"maximal cursor size"),
    shapes = get(disp,"supports shapes"),
    composite = get(disp,"supports composite"), 
    scrn_dim = {get(scrn,"width"),get(scrn,"height")},
    size = get(win,"size"),
    pos = get(win,"position")
    
 set(lbl,"markup",format(`
    Pointer location:<b>[]x[]</b>
    Cursor size:<b>[]x[]</b>
    Supports shapes:<b>[]</b>
    Supports composite:<b>[]</b>
    Screen dimensions:<b>[]x[]</b>
    Window size:<b> []x[]</b>
    Window position:<b> []x[]</b>`,
    flatten(pointer_loc & cursor_size & shapes & composite & scrn_dim & size & pos)))

return 1
end function
