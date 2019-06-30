
----------------------------------------------------------------------------------
--# GtkRevealer
----------------------------------------------------------------------------------

include GtkEngine.e

requires("3.10","GtkRevealer")

constant 
    win = create(GtkWindow,"border=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkToggleButton,"thumbnails/euphoria-linux.svg#_Euphoria",_("ToggleEu")),
    box2 = create(GtkButtonBox),
    lbl = create(GtkLabel,"line wrap=TRUE"),
    img = create(GtkImage,"~/demos/thumbnails/euphoria.gif"),
    revealer = create(GtkRevealer,{
        {"transition type",GTK_REVEALER_TRANSITION_TYPE_SLIDE_UP},
        {"transition duration",2000}})

    set(lbl,"markup",docs())
    
    add(win,panel)
    add(revealer,img)
    add(panel,{revealer,lbl})
    add(box2,{btn1,btn2})
    pack(panel,-box2)
    
show_all(win)
main()

----------------------------------
function ToggleEu(atom ctl)
----------------------------------
    set(revealer,"reveal child",get(ctl,"active"))
return 1
end function

----------------------------------
function docs()
----------------------------------
object hdr = "<span font='bold 16'>GtkRevealer</span>\n\n"
object txt = 
`The GtkRevealer widget is a container which animates the transition of its child from invisible to visible.

The style of transition can be controlled with gtk_revealer_set_transition_type().

These animations respect the "gtk-enable-animations" setting. 

<i>Click the Euphoria toggle button, or hit &lt;alt&gt;e.</i>
`
return hdr & txt
end function

