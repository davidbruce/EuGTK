
-----------------------------------------------------------------
--# More CSS styling - this uses a linear gradient background
-----------------------------------------------------------------

include GtkEngine.e

constant 
	css = locate_file("resources/mystyle3.css"),
	csp = create(GtkCssProvider, css),
	docs = `<u><b>Linear Gradient</b></u>
and css styling from 'mystyle3.css'`
    
constant 
	win = create(GtkWindow,"name=mainwin,size=300x200,position=1,$destroy=Quit"),
	panel = create(GtkBox,"orientation=VERTICAL,margin=10"),
	lbl0 = create(GtkLabel,"name=docs,margin=10,font=8"),
	lbl1 = create(GtkLabel,"markup=MOO?"),
	cow = create(GtkImage,"thumbnails/cowbell.png"),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btnbox = create(GtkButtonBox)

	set(lbl0,"markup",docs)
	set(lbl1,"font","Purisa, Comic Sans MS 48")
    add(win,panel)
    add(btnbox,btn1)
    pack(panel,{lbl0,lbl1,cow,-btnbox})
    
show_all(win)
main()



