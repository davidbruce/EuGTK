
------------------------------------------------------------------------------------------
--# GtkStack
------------------------------------------------------------------------------------------

include GtkEngine.e

requires("3.10","GtkStack")

integer which = 1

constant txt = 
`<span font='bold 16'>GtkStack</span>

The GtkStack widget is a container which only shows one of its children at a time. 
In contrast to GtkNotebook, GtkStack does not provide a means for users to change 
the visible child. Instead, the GtkStackSwitcher widget can be used with GtkStack 
to provide this functionality.

Transitions between pages can be animated as slides or fades. 
This can be controlled with gtk_stack_set_transition_type(). 
These animations respect the "gtk-enable-animations" setting. 
`
constant win = create(GtkWindow,"size=500x100,border=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
    add(win,panel)

constant img1 = create(GtkImage,"thumbnails/mongoose.png")
constant img2 = create(GtkImage,"thumbnails/clown.svg")

constant stk = create(GtkStack,{
	{"transition duration",1000},
	{"transition type",GTK_STACK_TRANSITION_TYPE_SLIDE_RIGHT}, --see enums for options
	{"add named",img1,"Euphoria - Easy to use"},
	{"add named",img2,"C - try it, you won't like it!"}})
	pack(panel,stk)
	
constant lbl2 = create(GtkLabel)
	pack(panel,lbl2,0,0,FALSE)

constant lbl1 = create(GtkLabel,{
    {"markup",txt},
    {"padding",10,0},
    {"line wrap",FALSE}})
    pack(panel,lbl1,0,0,FALSE)

constant 
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"Change Mascots","Change"),
    box = create(GtkButtonBox)
    pack(box,{btn1,btn2})
    pack(panel,-box)

show_all(win)
main()

-------------------------
global function Change()
-------------------------
    if which = 0 then
	set(stk,"visible child",img1)
    else
	set(stk,"visible child",img2)
    end if
    set(lbl2,"text",get(stk,"visible child name"))
    which = not(which)
return 1
end function 

