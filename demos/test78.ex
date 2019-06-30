
----------------------------------------------------------------------------
--# Numerable Icons from ancient Rome (<i>really</i> deprecated)
----------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=200x100,border=5,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,"markup=<b><u>Numerable Icons</u></b> (ancient Roman version <i>very</i> deprecated)"),
    top = create(GtkBox,"orientation=HORIZONTAL,spacing=30,border=10"),
    f = create(GFile,"thumbnails/mongoose.png"),
    icn = create(GFileIcon,f),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit")

object img = repeat(0,5)
object ico
object roman = "\xE2\x85\xA0" -- Roman numeral I 

for i = 1 to 5 do 
    ico = create(GtkNumerableIcon,icn)
    img[i] = create(GtkImage)
    set(ico,"label",roman)
    roman += {0,0,1} -- increment the UTF numeral;
    set(img[i],"from gicon",ico,6)
    add(top,img[i])
end for

    add(win,panel)
    add(panel,top)
    add(panel,lbl)
    add(box,btn1)
    pack(panel,-box)

show_all(win)
main()


