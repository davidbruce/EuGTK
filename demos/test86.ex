
-------------------------------------------------------------------------
--# Resizing Images
-- To load images at a different size than normal, load them into a 
-- GdkPixbuf, then create a GtkImage from that pixbuf.
-------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>Resized Image</b></u>
Original size: 525 x 360 pixels
Loaded as GdkPixbuf,
with width of 150 pixels, 
HxW ratio retained.
`
object pix = create(GdkPixbuf,"thumbnails/7300.jpg")
 pix = get(pix,"scale simple",150,100,1)
 
constant 
	win = create(GtkWindow,"size=200x100,border=10,position=1,$destroy=Quit"),
	pan = create(GtkBox,"orientation=vertical"),
	lbl = create(GtkLabel),
	img = create(GtkImage,pix), 
	btn1 = create(GtkButton,"gtk-quit","Quit")

set(lbl,"markup",docs) 
set(img,"margin bottom",5)

add(win,pan)
add(pan,{lbl,img})
pack(pan,-btn1)

show_all(win)
main()








