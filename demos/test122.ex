
---------------------------
--# GtkFileChooserWidget
---------------------------

include GtkEngine.e

constant docs = `
<b><u>File Chooser Widget</u></b>
can be added to a window, rather than using a file-open Dialog,
although it's probably not often a good idea.
`
constant 
	win = create(GtkWindow,"size=500x400,border=10,background=lightyellow,$destroy=Quit"),
	panel = create(GtkBox,"orientation=VERTICAL"),
	lbl = create(GtkLabel,{{"markup",docs}}),
	fcw = create(GtkFileChooserWidget),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-ok","Foo",fcw),
	box = create(GtkButtonBox)
	
	add(win,panel)
	add(panel,lbl)
	pack(panel,fcw,TRUE,TRUE,10)
	add(box,{btn1,btn2})
	pack(panel,-box)
	
show_all(win)
main()

------------------------------------------------------------------------
global function Foo(atom ctl, object chooser)
------------------------------------------------------------------------
object fname = get(chooser,"filename")
if not atom(fname) then
	Info(win,"File Chooser Widget","Do something with:",fname)
end if
return 1
end function

