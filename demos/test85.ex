
------------------------------------------------------------------------
--# GtkLabel with web link
------------------------------------------------------------------------

include GtkEngine.e
include std/net/dns.e

constant 
    win = create(GtkWindow,"size=200x100,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical,spacing=10"),
    img = create(GtkImage,"thumbnails/mongoose.png"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btnbox = create(GtkButtonBox)

constant lbl1 = create(GtkLabel,{ -- label with a web link;
    {"markup","""Click to visit: <a href="http://openeuphoria.org">OpenEu</a>"""}})
    
    connect(lbl1,"activate-link","OpenLink")

    add(win,panel)
    add(panel,{img,lbl1})
    add(btnbox,{btn1})
    pack(panel,-btnbox)

show_all(win)
main()

----------------------------------------------------
global function OpenLink()
----------------------------------------------------
object uri = get(lbl1,"current uri")
    if not networked() then
	Warn(win,"Error","Cannot connect to Web",uri,,"face-crying")
    else
	show_uri(uri)
    end if
return 1
end function









