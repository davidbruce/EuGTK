
--------------------------------------------------------------
--# GtkAboutDialog -- a handy way to display your program info
--------------------------------------------------------------

include GtkEngine.e

constant dlg = create(GtkAboutDialog,{ -- built 'from scratch' 
	{"title","About..."},
	{"icon","thumbnails/mongoose.png"},
	{"logo","thumbnails/eugtk.png"},
	{"comments","This is a test of the GtkAboutDialog\nwritten in Euphoria"},
	{"program name","A wrapper for GTK3"},
	{"version","Version "& version},
	{"copyright",copyright},
	{"authors",{
		"Irv Mullins <irvmull@gmail.com>",
		"With the help of the",
		"OpenEuphoria community http://openeuphoria.org"}
		},
	--{"artists",{"Vinnie Van Go","P. Kasso","R.E.M Brandt"}},
	{"website","http://OpenEuphoria.org"},
	{"website label","OpenEuphoria"},
	{"license",LGPL & "http://www.gnu.org/licenses/lgpl.html\n"},
	{"add credit section","Inspiration",{"Dave Cuny"}},
	{"add credit section","Testers",
		{"Pete Eberlein, Greg Haberek, Ron Tarrant, Jeremy Cowgar,",
		 "Don Cahela, Mike Sabal, Jerry Story, Derek Parnell, C.K.Lester"}}})

constant 
	win = create(GtkWindow,"size=200x80,border_width=10,position=1,$destroy=Quit"),
	panel = create(GtkBox,"orientation=vertical,spacing=10"),
	lbl1 = create(GtkLabel,"markup=<b><u>About Dialog</u></b>\nClick the About button"),
	box = create(GtkButtonBox),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-about","ShowAboutDialog")
	
	add(win,panel)
	add(panel,lbl1)
	add(box,{btn1,btn2})
	pack_end(panel,box)
	
	set(dlg,"transient for",win)
	
show_all(win)
main()

----------------------------------
global function ShowAboutDialog()
----------------------------------
run(dlg)
hide(dlg)
return 1
end function
