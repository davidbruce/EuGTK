
----------------------------------------------------------------------------
--# Status Icon in system tray
----------------------------------------------------------------------------
-- The system tray (a.k.a. notification area) is normally used for transient 
-- icons that indicate some special state. For example, a system tray 
-- icon might appear to tell the user that they have new mail, or have 
-- an incoming instant message, or something along those lines. 
-- The basic idea is that creating an icon in the notification area is 
-- less annoying than popping up a dialog. 
-- Since this is useful, it is soon to be deprecated !:<
---------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<b><u>Status Icon</u></b>
This should show a small blue mouse 
on your status bar.

Roll over the mouse with your mouse
to see a message.Click him to see more!

<b>Buggy in GTK 3.14!</b>, ok in later vers.

`
constant 
    mouse = create(GdkPixbuf,"thumbnails/mouse.png",30,30),
    win = create(GtkWindow,"border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    img = create(GtkImage,mouse),
    lbl = create(GtkLabel,{{"markup",docs}}),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    stat = create(GtkStatusIcon,"$activate=Hello")
    
    set(stat,"from pixbuf",mouse)
    set(stat,"tooltip markup",
        "<span color='cornflower blue'><b>Euphoria</b></span>\n a great programming language!")

    add(win,panel)
    add(panel,{img,lbl})
    add(box,btn1)
    pack(panel,-box)
    
constant logo = create(GdkPixbuf,"thumbnails/euphoria.gif",300,500,TRUE)

show_all(win)
main()

-----------------------
global function Hello()
-----------------------
return Info(win,"Hello","Greetings from Euphoria!",
sprintf("""
Here are some links
 <a href='http://openeuphoria.org'>OpenEuphoria</a>
 <a href='http://rapideuphoria.com'>RapidEuphoria</a>
 <a href='file://%s'>ReadMe</a>
 """,
 {canonical_path(locate_file("documentation/README.html"))})
 ,GTK_BUTTONS_CLOSE,logo,mouse)
end function
