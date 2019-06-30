
--------------------------------------------------------------------------
--# GtkStack with visible stack switcher
--------------------------------------------------------------------------

include GtkEngine.e

requires("3.10","GtkStack")

integer which = 1

constant txt = 
`<span font='bold 16'>GtkStack</span>

 The GtkStack widget is a container which only shows one of its children at a time. 
 In contrast to GtkNotebook, GtkStack does not provide a means for users to change 
 the visible child. Instead, the GtkStackSwitcher widget can be used with GtkStack 
 to provide this functionality.

 Transitions between pages can be animated as slides or fades. This can be controlled 
 with gtk_stack_set_transition_type(). These animations respect the 
 "gtk-enable-animations" setting. 
`

constant css = create(GtkCssProvider,"GtkStackSwitcher .button:checked {background-image: linear-gradient(45deg, yellow, skyblue);}")

constant win = create(GtkWindow,"border=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,VERTICAL)
add(win,panel)

constant grid = create(GtkGrid)
    add(panel,grid)

constant 
    img1 = create(GtkImage,"thumbnails/mongoose.png"),
    img2 = create(GtkImage,"thumbnails/c.png"),
    img3 = create(GtkImage,"thumbnails/c++.png"),
    img4 = create(GtkImage,"thumbnails/python.png"),
    lgpl = create(GtkLabel,LGPL),
    stk = create(GtkStack,{
	{"tooltip text","This is the Stack"},
	{"transition duration",1000},
	{"transition type",GTK_STACK_TRANSITION_TYPE_SLIDE_UP_DOWN},
	{"add titled",img1,"Eu","Euphoria"},
	{"add titled",img2,"C","C"},
	{"add titled",img3,"C++","C++"},
	{"add titled",img4,"Py","Python"}})
    set(grid,"attach",stk,1,1,4,1)

constant switcher = create(GtkStackSwitcher,"tooltip text=This is the StackSwitcher")
    set(switcher,"stack",stk)
    set(switcher,"margin-top",10)
    set(switcher,"margin-bottom",10)
    set(grid,"attach",switcher,3,2,1,1)
    
constant lbl = create(GtkLabel,{
    {"markup",txt},
    {"font","8"},
    {"line wrap",FALSE}})
    set(grid,"attach",lbl,1,3,4,1)
    
constant box = create(GtkButtonBox)
   add(box,{
	create(GtkButton,"gtk-quit","Quit"),
	create(GtkButton,"label=Change Mascots,$clicked=Change,tooltip text=Triggers Change function")})
    pack_end(panel,box)
    
show_all(win)
main()

-------------------------
global function Change()
-------------------------
object current = get(stk,"visible child name")
object next
switch current do
    case "Eu" then next = "C"
    case "C" then next = "C++"
    case "C++" then next= "Py"
    case "Py" then next = "Eu"
    case else next = "Eu"
end switch
set(stk,"visible child name",next)
return 1
end function 

