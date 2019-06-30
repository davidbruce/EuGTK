
-----------------------------------------------------------------
--# Mouse coordinates (global)

-- This returns the mouse x/y location on the entire computer
-- screen, with 0x0 being the top left corner.

-- If you only are interested in the mouse pointer location
-- *within* your program's window, use the simpler
-- get(win,"pointer") call. See test76.

------------------------------------------------------------------

include GtkEngine.e	

constant 
    disp = create(GdkDisplay),
    mgr = get(disp,"device manager"),
    pointer = get(mgr,"client pointer") 

constant 
    win = create(GtkWindow,"size=200x100,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    img = create(GtkImage,"thumbnails/input-mouse.png"),
    lbl = create(GtkLabel,"Move the mouse anywhere, hit Alt-M"),
    box = create(GtkButtonBox,"margin top=5"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-help","Help"),
    btn3 = create(GtkButton,"~/demos/thumbnails/input-mouse.png#_Mouse","Foo")

    add(win,panel)
    add(panel,{img,lbl})
    add(box,{btn1,btn2,btn3})
    pack(panel,-box)
    
show_all(win)
main()

------------------------------------------------------------------------
global function Foo()
------------------------------------------------------------------------
object xy = get(pointer,"position") 
    Info(win,"Screen Position:",
	format("Mouse Pointer:\nx=[2], y=[3]",xy),
	"Press &lt;escape&gt; to close this message box",
	GTK_BUTTONS_CLOSE)
return 1
end function

-----------------------
global function Help()
-----------------------
return Info(win,"Help",
"""<u><b>Pointer</b></u> location""",
"""Move the mouse anywhere on the 
display, and press Alt-M
(do not click the mouse buttons)
""")
end function
