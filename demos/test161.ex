
------------------------------------------------------------------------
--# GtkAspectFrames
------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>Aspect Frames</b></u>
Frames can auto-adjust to fit the dimensions of object(s) contained.`

constant win1 = create(GtkWindow,"position=1,border=10,$destroy=Quit")

constant panel1 = create(GtkBox,"orientation=VERTICAL")
    add(win1,panel1)

constant panel2 = create(GtkBox,"orientation=HORIZONTAL,spacing=10")
    add(panel1,panel2)

constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel1,lbl)

constant 
    frm1 = create(GtkAspectFrame,"Cow",0,0,0,TRUE),
    frm2 = create(GtkAspectFrame,"Boy",0,0,0,TRUE),
    frm3 = create(GtkAspectFrame,"Mouse",0,0,0,TRUE)

    add(panel2,{frm1,frm2,frm3})

constant 
    pix1 = create(GtkImage,"thumbnails/cow2.jpg"),
    pix2 = create(GtkImage,"thumbnails/Jacob.jpg"),
    pix3 = create(GtkImage,"thumbnails/mouse.png")
    set(pix2,"padding",10,10)
	
    add(frm1,pix1)
    add(frm2,pix2)
    add(frm3,pix3)

show_all(win1)
main()


