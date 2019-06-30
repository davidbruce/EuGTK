
--------------------------------------------------------------------------------
--# GtkLinkButton
-- a button which opens a web page when clicked. 
--------------------------------------------------------------------------------

include GtkEngine.e
include GtkEvents.e
include std/net/http.e

constant url = "http://openeuphoria.org",

    win = create(GtkWindow,"border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL,spacing=10"),
    lbl = create(GtkLabel,"markup=<b><u>GtkLinkButton</u></b>\n" &
        "Clicking the OpenEuphoria link button should\nopen a browser and load the web page"),
    box = create(GtkButtonBox),
    spin1 = create(GtkSpinner),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton),
    btn3 = create(GtkLinkButton,url,"OpenEu")

    set(btn2,"relief",GTK_RELIEF_NONE)
    set(btn2,"sensitive",FALSE)
    set(btn3,"relief",GTK_RELIEF_NORMAL) 
    connect(btn3,"activate-link","TryToConnect",url)    

    add(win,panel)
    add(panel,lbl)
    add(btn2,spin1)
    add(box,{btn1,btn2,btn3})
    pack(panel,-box)

show_all(win)
set(btn2,"hide")
main()

-----------------------------------------------------------------
global function TryToConnect(object ctl, object data)
-----------------------------------------------------------------
ifdef UNIX then 
object net = "network-offline", web = "www"
end ifdef

ifdef WINDOWS then
object net = "./thumbnails/net0.png", web = "./thumbnails/face-cry.png"
end ifdef

    if not networked() then 
        Warn(win,,"Sorry","This computer is not on a network",
            GTK_BUTTONS_CLOSE,net)       
        return 1 
    end if
    
    show_all(btn2) -- show some activity while checking;
    set(btn2,"sensitive",TRUE)
    set(spin1,"start")
    
    if not inet_connected() then
        Error(win,,"Sorry","Internet not accessible!",GTK_BUTTONS_CLOSE,web)
        set(spin1,"stop")
        set(btn2,"sensitive",FALSE)
        set(btn2,"hide")
        return 1
    end if

    set(spin1,"stop")
    set(btn2,"sensitive",FALSE)
    set(btn2,"hide")
    
return 0 -- returning 0 will allow the link button to complete the connection;
end function
