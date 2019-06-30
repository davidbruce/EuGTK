
--# GtkSpinner demo

include GtkEngine.e

constant docs = `markup=
----------------------------------------------------------------
<u><b>GtkSpinner</b></u>

The spinner won't spin while a lengthy
Euphoria call is processed, such as reading
a large file.

For that, you must use tasks to keep
the spinner going. 

See ~/demos/examples/task.ex
-----------------------------------------------------------------`
constant 
    win = create(GtkWindow,"size=100x100,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,docs),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkSwitch,"Toggle"),
    spin = create(GtkSpinner,{
	{"size request",50,50},
	{"vexpand",TRUE},
	{"hexpand",TRUE}})
 
    add(win,pan)
    add(pan,{lbl,spin})
    add(box,{btn1,btn2})
    pack(pan,-box)
    
show_all(win)
main()

--------------------------------------------
global function Toggle(atom ctl)
--------------------------------------------
    if get(ctl,"active") then
	set(spin,"start")
    else 
	set(spin,"stop")
    end if
return 1
end function

