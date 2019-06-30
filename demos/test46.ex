
-------------------------------------------------------------------------------
--# GtkPaned - split window with adjustable divider
--
-- a widget with two adjustable 'panes' either side-by-side or above/below.
-- each pane is a container which can hold one other widget such as ListView,
-- Image, Box, etc.
-------------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=430x400,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl1 = create(GtkLabel,"markup=<b><u>GtkPaned</u></b> ~ a container with an adjustable divider"),
    paned = create(GtkPaned,"orientation=1,position=220,tooltip markup=Slide the handle below the pix up or down"),
    img1 = create(GtkImage,"thumbnails/jeff.jpg"),
    lbl2 = create(GtkLabel,"font=8,line wrap=TRUE"),
    scrolwin = create(GtkScrolledWindow),
    scroller = create(GtkViewport),
    btnbox = create(GtkButtonBox,"margin top=5"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-help",call_back(routine_id("Foo")))

    set(lbl2,"markup",LGPL)
    
    add(win,panel)
    pack(panel,lbl1)
    add(panel,paned)
    set(paned,"add1",img1)
    set(paned,"add2",scrolwin)
    add(scrolwin,scroller)
    add(scroller,lbl2)
    add(btnbox,{btn1,btn2})
    pack(panel,-btnbox)
    
show_all(win)
main()

------------------------------------------------------------------------
function Foo()
------------------------------------------------------------------------
    Info(win,"OK","<u>GtkPaned</u>",
        "Grab the bar [...] below the photo\nand slide it up/down")
return 1
end function

