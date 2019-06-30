
---------------------------------------------------------------------------------
--# GtkMessageDialog
---------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `markup=
<u><b>GTK message dialog</b></u>

You'll not often need to do this, 
the EuGtk built-in dialogs are easier and
more complete.
`
constant 
    win = create(GtkWindow,"border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,docs),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","Foo"),
    box = create(GtkButtonBox)

    add(win,pan)
    add(pan,lbl)
    add(box,{btn1,btn2})
    pack(pan,-box)
    
show_all(win)
main()

------------------------
global function Foo()
------------------------
atom dlg = create(GtkMessageDialog,{
    {"transient for",win},
    {"background","yellow"},
    {"message-type",GTK_MESSAGE_INFO},
    {"add button","gtk-ok",1},
    {"add button","gtk-cancel",0},
    {"markup","This is a test"}, -- add formatting if required;
    {"format secondary text","%s","More here..."}})

    run(dlg)
    destroy(dlg)
	
return 1
end function
