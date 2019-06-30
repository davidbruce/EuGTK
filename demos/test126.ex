 
----------------------------------------------------------------
--# Recent Chooser file info
----------------------------------------------------------------

include GtkEngine.e

include std/net/url.e

atom theme = create(GtkIconTheme)

constant docs = `markup=
<b><u>Recent Chooser</u></b>
This shows how to get more info
such as last access and program used.
`
constant 
    fmt = "\n<small><b>uri:</b> %s\n\n<b>mime:</b> %s\n\n<b>last app:</b> %s\n\n<b>days:</b> %d</small>",
    win = create(GtkWindow,"size=300x300,border=10,position=1,$destroy=Quit"),
    pan = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel,docs),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","Foo")

constant rcw = create(GtkRecentChooserWidget,{
    {"local only",TRUE},
    {"show private",TRUE},
    {"show not found",FALSE},
    {"show tips",TRUE},
    {"limit",500},
    {"sort type",GTK_RECENT_SORT_MRU}})

    -- following only seems to work if a filter has been 
    -- installed;
    set(rcw,"show not found",TRUE) 
    
    add(win,pan)
    add(pan,lbl)
    add(box,{btn1,btn2})
    pack(pan,rcw,TRUE,TRUE,10)
    pack(pan,-box)

show_all(win)
main()

----------------------------------------------------------
global function Foo()
----------------------------------------------------------
object info = get(rcw,"current item") -- get the rc_info structure
if info = 0 then return 1 end if
object name = get(info,"display name") 
object uri = decode(get(info,"uri")) -- get rid of escaped chars in the url
object age = get(info,"age")
object mime = get(info,"mime type")
object last = get(info,"last application")
object img = create(GdkPixbuf,uri[8..$],96,96,1)

Info(win,"You Chose",name,sprintf(fmt,{uri,mime,last,age}),,img)

return 1
end function

    
