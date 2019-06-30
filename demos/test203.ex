
---------------------------------------------------------------------------------
--# GtkActionBar -  new
---------------------------------------------------------------------------------

include GtkEngine.e

requires("3.12","GtkActionBar")

constant docs = `<b><u>GtkActionBar</u></b>

GtkActionBar is designed to present contextual actions. It is expected to be 
displayed below the content and expand horizontally to fill the area.

It allows placing children at the start or the end. In addition, it contains 
an internal centered box which is centered with respect to the full width of 
the box, even if the children at either side take up different amounts of space.

`
constant 
     win = create(GtkWindow,"title=ActionBar,border=10,position=center,size=300x250,$destroy=Quit"),
     panel = create(GtkBox,"orientation=vertical"),
     lbl = create(GtkLabel,{{"markup",docs}}),
     
     ab = create(GtkActionBar),
     tb1 = create(GtkToolButton,"$clicked=Quit"),
     img1 = create(GdkPixbuf,"gtk-quit",25,25),
     tb2 = create(GtkToggleToolButton),
     img2 = create(GdkPixbuf,"~/demos/thumbnails/dragon.png",25,25),
     tb3 = create(GtkRadioToolButton),
     img3 = create(GdkPixbuf,"thumbnails/fish.png",25,25),
     tb4 = create(GtkRadioToolButton,tb3),
     img4 = create(GdkPixbuf,"thumbnails/fish.png",40,40),
     tb5 = create(GtkRadioToolButton,tb4),
     img5 = create(GdkPixbuf,"thumbnails/fish.png",60,60)	
	
     set(tb1,"icon widget",create(GtkImage,img1))
     set(tb1,"tooltip markup","<b>Quit</b>")
     set(ab,"pack start",tb1)
	
     set(tb2,"icon widget",create(GtkImage,img2))
     set(tb2,"tooltip text","Toggle Button")
     set(ab,"center widget",tb2)
	
     set(tb3,"icon widget",create(GtkImage,img3))
     set(tb3,"tooltip markup","<small>Goldfish</small>")
     set(ab,"pack end",tb3)
	
     set(tb4,"icon widget",create(GtkImage,img4))
     set(tb4,"tooltip text","Porpoise")
     set(ab,"pack end",tb4)
	
     set(tb5,"icon widget",create(GtkImage,img5))
     set(tb5,"tooltip markup","<big>Whale</big>")
     set(ab,"pack end",tb5)

     add(win,panel)
     add(panel,lbl)
     pack(panel,-ab)
     
show_all(win)
main()

