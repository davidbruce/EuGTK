
----------------------------------------------------------------------------
--# GtkAspectFrame - frame which maintains width/height ratio when resized;
----------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<b><u>Aspect Frame</u></b>
Resize the window, and see how the frame 
retains its relative dimensions.

This is useful for images, for example,
which shouldn't be stretched or distorted.
`

constant win = create(GtkWindow,"size=200x100,border_width=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL,spacing=10")
	add(win,panel)

constant lbl1 = create(GtkLabel)
	set(lbl1,"markup",docs)
	add(panel,lbl1)
	
constant lbl2 = create(GtkLabel,"W to H Ratio is 2:1")

constant frame = create(GtkAspectFrame,"Frame Title Here",0.5,0.5,2,FALSE)
	set(frame,"size request",100,100)
	set(frame,"shadow type",GTK_SHADOW_ETCHED_OUT)
	pack(panel,frame,TRUE,TRUE)
	add(frame,lbl2)

constant 
	btn = create(GtkButton,"gtk-quit","Quit"),
	box = create(GtkButtonBox)
	pack(panel,-box)
	add(box,btn)

show_all(win)
main()

