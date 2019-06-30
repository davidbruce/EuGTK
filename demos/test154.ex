
------------------------------------------------------------
--# Shared Adjustment
------------------------------------------------------------

include GtkEngine.e	

constant 
	docs = "Connecting controls via shared <b><u>Adjustment</u></b> object",
	win = create(GtkWindow,"size=200x100,border=10,position=1,$destroy=Quit"),
	pan = create(GtkBox,"orientation=VERTICAL,spacing=20"),
	lbl = create(GtkLabel,"The two controls share an adjustment"),
	adj = create(GtkAdjustment),
	scale = create(GtkScale,HORIZONTAL,adj),
	range = create(GtkSpinButton,adj,0.01,2),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-ok","Foo"),
	box = create(GtkButtonBox)

	set(adj,"configure",0,0,100,0.01)
	set(box,"margin bottom",10)
	
	add(win,pan)
	add(pan,{lbl,scale,range})
	add(box,{btn1,btn2})
	pack(pan,-box)
	
show_all(win)
main()

global function Foo()
return Info(,,"Value",sprintf("%g",get(range,"value")))
end function









