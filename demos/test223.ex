
--# Network address

include GtkEngine.e

constant 
 win = create(GtkWindow,"size=200x-1,border=5,$destroy=Quit"),
 pan = create(GtkBox,"orientation=vertical,spacing=10"),
 lbl = create(GtkLabel,"font=14,text=My IP: " & get_network_address()),
 box = create(GtkButtonBox),
 btn = create(GtkButton,"gtk-quit","Quit")

 add(win,pan)
 add(pan,lbl)
 add(box,btn)
 pack(pan,-box)
 
 show_all(win)
 main()
