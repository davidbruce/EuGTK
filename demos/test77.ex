
----------------------------------------------------------------------------
--# Numerable Icons (deprecated)
----------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=200x100,border_width=5,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,"markup=<u><b>Numerable Icons</b></u> (deprecated)"),
    top = create(GtkBox,"orientation=0,spacing=20,border_width=10"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    
-- create an icon from an image,
-- use whatever image you want, it will be sized to fit:
    f = create(GFile,"thumbnails/mongoose.png"),    
    ic1 = create(GFileIcon,f),

-- alternatively, load one from stock, but be careful that there
-- is actually an icon by that name in the theme currently in use,
-- otherwise, you get a 'missing image' icon.
    ic2 = create(GThemedIcon,"preferences-desktop-locale")

object img = repeat(0,5)
object ico
for i = 1 to 5 do
    ico = create(GtkNumerableIcon,ic1) -- try also ic2
    img[i] = create(GtkImage) 
    set(ico,"count",i) -- this sets the #
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


