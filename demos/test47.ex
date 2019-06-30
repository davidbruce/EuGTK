
-------------------------------------------------------------------------------
--# GtkScrolledWindow
-- container which holds an object larger than the space allocated, with scroll
-- bars to allow seeing the entire object.
-- Often used for lists, images, etc.
-------------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=300x300,border_width=10,position=1,$destroy=Quit"),
    scrolwin = create(GtkScrolledWindow),
    hadj = get(scrolwin,"hadjustment"),
    scroller = create(GtkViewport),
    panel = create(GtkBox,"orientation=vertical"),
    img1 = create(GtkImage,"thumbnails/giraffe.jpg"),
    lbl = create(GtkLabel,"markup=Various items in a <b><u>GtkScrolledWindow</u></b>"),
    btnbox = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-help","Foo")
  
    add(win,scrolwin)
    add(scrolwin,scroller)
    add(scroller,panel)
    add(panel,{img1,lbl})
    add(btnbox,{btn1,btn2})
    pack(panel,-btnbox)
    
show_all(win)
set(hadj,"value",220) -- scroll to right so giraffe is in view window;
main()

------------------------------------------------------------------
global function Foo()
------------------------------------------------------------------
    Info(win,"Test47","<u>GtkScrolledWindow</u>",
	"You can pack any kind of item into this\n\n" &
	"<small><i>Note: the scrollbars appear only if the\n" &
	"window is too small for the contents</i></small>")
return 1
end function

