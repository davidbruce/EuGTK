
----------------------------------------------------------------------------
--# Clipboard paste image
----------------------------------------------------------------------------

include GtkEngine.e	

constant docs = `<b><u>Clipboard</u></b>
Click the Paste button to add 
an image to the clipboard,
or copy one from an image 
program such as the Gimp
`
constant win = create(GtkWindow,"size=300x200,border_width=5,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
    add(win,panel)

constant pix = create(GtkImage,"thumbnails/clipper.png")
    add(panel,pix)

constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)

constant img = create(GdkPixbuf,"thumbnails/mongoose.png")
constant cb = create(GtkClipboard)
object blank = create(GdkPixbuf,"thumbnails/missing-image.png",50,50)

constant box = create(GtkButtonBox)
    add(box,{
        create(GtkButton,"gtk-quit","Quit"),
        create(GtkButton,"gtk-clear",_("Clear")),
        create(GtkButton,"gtk-paste",_("Paste"))})
    pack(panel,-box)

show_all(win)
main()

------------------------
function Paste()
------------------------
    set(cb,"image",img)
return 1
end function

-----------------------
function Clear()
-----------------------
    set(cb,"image",blank)
return 1
end function




