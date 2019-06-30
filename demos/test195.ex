
-----------------------------------------------------------
--# GtkButtonBox - optional properties
-----------------------------------------------------------

include GtkEngine.e

constant docs = `<b><u>GtkButtonBox</u></b>

A button box should be used to provide 
a consistent layout of buttons throughout 
your application. 

The layout/spacing can be altered by the 
programmer, or if allowed, by the user to 
alter the "feel" of a program to a small degree.

Use gtk_button_box_get_layout() and 
gtk_button_box_set_layout() to retrieve and 
alter the method used to spread the buttons 
across the container.
`
enum LEFT, RIGHT, TOP, BOTTOM

constant 
    win = create(GtkWindow,"border=10,size=500x300,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL,spacing=10"),
    grid = create(GtkGrid,"column spacing=10,row homogeneous=FALSE"),
    heading1 = create(GtkLabel)
    
    add(win,panel)
    add(panel,grid)

    set(heading1,"markup","<b>Margins</b>")
    set(grid,"attach",heading1,1,1,2,1)

constant margin = {
    create(GtkSpinButton,0,400,1),
    create(GtkSpinButton,0,400,1),
    create(GtkSpinButton,0,100,1),
    create(GtkSpinButton,0,100,1)
    }
    for i = 1 to length(margin) do
        connect(margin[i],"value-changed","ChangeButtonLayout")
    end for
    
    set(grid,{
	{"attach",create(GtkLabel,"Left - Right"),1,2,2,1},
	{"attach",margin[LEFT],1,3,1,1},
	{"attach",margin[RIGHT],2,3,1,1},
    
	{"attach",create(GtkLabel,"Top - Bottom"),1,4,2,1},
	{"attach",margin[TOP],1,5,1,1},
	{"attach",margin[BOTTOM],2,5,1,1}})
   
constant heading2 = create(GtkLabel)
    set(heading2,"markup","<b>ButtonBox Layout</b>")
    set(grid,"attach",heading2,1,6,2,1)
    
constant opts = create(GtkComboBoxText,"ChangeButtonLayout")
    add(opts,{"Spread","Edge","Start","End","Center"})
    set(opts,"id column",0)
    set(grid,"attach",opts,1,7,2,1)
 
constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    set(grid,"attach",lbl,3,1,1,9)
    
constant hr = create(GtkSeparator,"orientation=HORIZONTAL")
    pack(panel,hr)

constant box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok")
    add(box,{btn1,btn2})
    pack_end(panel,box)

show_all(win)
set(opts,"active",1)
main()

-------------------------------------
global function ChangeButtonLayout()
-------------------------------------
set(box,{
	{"layout",get(opts,"active")},
	{"margin top",get(margin[TOP],"value")},
	{"margin bottom",get(margin[BOTTOM],"value")},
	{"margin left",get(margin[LEFT],"value")},
	{"margin right",get(margin[RIGHT],"value")},
	$})
return 1
end function


