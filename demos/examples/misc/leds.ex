
--# BIG LED's from a single bitmap

include GtkEngine.e

integer x1 = 1, y1 = 1, w = 128, h = 200

constant
    win = create(GtkWindow,"background=black,size=300x240,border=10,$destroy=Quit"),
    src = create(GdkPixbuf,"thumbnails/LEDs.bmp"),
    led = create(GtkImage),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkSpinButton,0,18,1)
    
   connect(btn2,"value changed","Change")
    
   add(win,pan)
   add(pan,led)
   add(box,{btn1,btn2})
   pack(pan,-box)

show_all(win)
Change(btn2)
main()

---------------------------------
global function Change(atom ctl)
---------------------------------
integer v = get(ctl,"value as int")
if v = 0 then
    x1 = 128 * 9
else
    x1 = (v-1)*128
end if
set(led,"from pixbuf",
    gtk_func("gdk_pixbuf_new_subpixbuf",{P,I,I,I,I},{src,x1,y1,w,h}))
return 1
end function

