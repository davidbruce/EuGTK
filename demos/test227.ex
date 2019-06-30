
--# Named Dialog params with CSS styling <span color='red'>new in EuGTK 4.14.6</span>

include GtkEngine.e

constant 
	docs = `markup=
	Demos named dialog parameters 
	and CSS dialog styling.
	
	Click the OK button!
	
	`,
	win = create(GtkWindow,"size=300x200,border=10,$destroy=Quit"),
	pan = create(GtkBox,"orientation=vertical,spacing=10"),
	lbl = create(GtkLabel,docs),
	box = create(GtkButtonBox),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-ok","OK"),
	css = create(GtkCssProvider, -- inline;
	  "#MyDialog {background-image: linear-gradient(45deg, yellow, skyblue);}")
	
	add(win,pan)
	add(pan,lbl)
	add(box,{btn1,btn2})
	pack(pan,-box)
	
show_all(win)
main()

---------------------
global function OK()
---------------------
Info("pri=Hello;sec=World!;name=MyDialog")  -- must be named for css to work!
return 1
end function
