
--# valid icon name, fallback for missing icons;


include GtkEngine.e

object image = valid_icon_name({"thumbnails/xviewer.png","face-cool","thumbnails/clip.png"}) -- note invalid icons;
image = create(GdkPixbuf,image,20,20,1)
object caption = "_Quit"

constant 
    win = create(GtkWindow,"name=Win,size=200x100,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,docs()),
    box = create(GtkButtonBox),
    btn = create(GtkButton,,"Quit")

    set(btn,{
      {"image",image},
      {"caption",caption}})
      
    add(win,pan)
    add(pan,lbl)
    add(box,btn)
    pack(pan,-box)
      
show_all(win)
main()

function docs()
return 
`If you aren't sure an icon will be found, 
create a fallback to load as a last resort:
`
end function
