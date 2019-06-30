
----------------------------------------------------------------------
--# GtkFrame
----------------------------------------------------------------------

include GtkEngine.e

constant txt = "This is some text\nin a frame"

constant win = create(GtkWindow,"size=200x200,border=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
	add(win,panel)

constant frame1 = create(GtkFrame)
	add(panel,frame1)

constant lbl1 = create(GtkLabel,txt)
	add(frame1,lbl1)

constant frame2 = create(GtkFrame,"Frame 2")
	add(panel,frame2)

constant lbl2 = create(GtkLabel,txt & "\nwith a title")
	add(frame2,lbl2)

constant frame3 = create(GtkFrame)

constant lbl3 = create(GtkLabel,txt & "\nwith marked-up title")
	add(frame3,lbl3)
	
constant title = create(GtkLabel)	
	set(title,"markup","<span color='red'><i>Frame 3</i></span>")
	set(frame3,"label widget",title)
	add(panel,frame3)

constant frame4 = create(GtkFrame)
constant fpanel = create(GtkBox,VERTICAL,10)
	add(frame4,fpanel)
	
constant lbl4a = create(GtkLabel,"This frame has a gif for a title")
constant lbl4b = create(GtkLabel,"and the text angles set to +/-5°")
	set(lbl4a,"angle",-5)
	set(lbl4b,"angle",5)
	add(fpanel,{lbl4a,lbl4b})
	
constant img = create(GtkImage,"thumbnails/bar.gif")
	set(frame4,"label widget",img)
	add(panel,frame4)

constant 
	btn = create(GtkButton,"gtk-quit","Quit"),
	box = create(GtkButtonBox)
	add(box,btn)
	pack(panel,-box,TRUE,TRUE,10)

show_all(win)
main()

