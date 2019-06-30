
----------------------------------------------------------------
--# Links in labels

-- can open webpages or local resources. this tests connectivity
-- every 2 sec. and indicates status.
-- Click Network button to get current address.
----------------------------------------------------------------

include GtkEngine.e

constant link1 = "<a href='http://OpenEuphoria.org'>OpenEu</a> download Euphoria ~ get help on the forum!"
	   
constant link2 = "<a href='https://developer.gnome.org/gtk3/'>GTK</a> ~ get the GTK documentation."
	    
constant link3 = sprintf("<a href='file://%s'>Readme</a> ~ view a local file.",
	   {canonical_path(locate_file("documentation/README.html"))})

constant 
    bkgnd = create(GtkImage,"thumbnails/internet_trans.png"),
    win = create(GtkWindow,"name=main,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl0 = create(GtkLabel,"markup=<u><b>Web Links in Labels</b></u>"),
    bar = create(GtkButtonBox,"margin-bottom=10"),
    box = create(GtkButtonBox),
    btn = create(GtkButton,"gtk-quit","Quit"),
    netbtn = create(GtkButton,"thumbnails/network-wired-disconnected.png#Network,sensitive=0,$clicked=ShowIP"),
    webbtn = create(GtkButton,"thumbnails/emblem-web-off.png#Internet,sensitive=0,$clicked=ShowExternalIP"),
    lbl1 = create(GtkLabel,{{"markup",link1}}),
    lbl2 = create(GtkLabel,{{"markup",link2}}),
    lbl3 = create(GtkLabel,{{"markup",link3}})
        
constant -- pixbufs to change appearance of network/internet connect buttons;
    net_img_on = create(GdkPixbuf,"thumbnails/network-wired.png",20,0,1),
    net_img_off = create(GdkPixbuf,"thumbnails/network-wired-disconnected.png",20,0,1),
    web_img_on = create(GdkPixbuf,"thumbnails/emblem-web-on.png",20,0,1),
    web_img_off = create(GdkPixbuf,"thumbnails/emblem-web-off.png",20,0,1)

    add(win,panel)
    add(panel,{lbl0,bkgnd})
    pack_start(panel,bar)
    add(bar,{netbtn,webbtn})
    add(panel,{lbl1,lbl2,lbl3})
    add(box,btn)
    pack(panel,-box)

connect(lbl1,"activate-link","onLinkActivate")
connect(lbl2,"activate-link","onLinkActivate")
connect(lbl3,"activate-link","onLinkActivate")

constant tick = create(GTimeout,2000,_("update_connectivity"))

show_all(win)
main()

-------------------------------------------------------------
global function onLinkActivate(atom lbl, object uri)
-------------------------------------------------------------
uri = peek_string(uri) 
if match("http",uri) = 1 then
    if not inet_connected() then
     Info(win,,"Sorry",
	"I'm not connected to\nthe Internets right now",,
	"face-sad",64)
	return 1 -- returning 1 will do nothing
    else
	show_uri(uri)
    end if
else
	ifdef WINDOWS then
		system("explorer " & uri,0)
		return 1
	end ifdef
    return 0 -- returning 0 will allow UNIX uri handler to do its thing
end if
return 1
end function

------------------------------------------
function update_connectivity()
------------------------------------------    

if networked() then
    set(netbtn,"image",net_img_on)
    set(netbtn,"sensitive",1)
    set(netbtn,"tooltip text",get_network_address())
    set(webbtn,"image",web_img_on)
    set(webbtn,"sensitive",1)
else
    set(netbtn,"image",net_img_off)
    set(netbtn,"sensitive",0)
    set(netbtn,"tooltip text","No network")
    return 1
end if

return 1
end function

--------------------------------------
global function ShowIP()
--------------------------------------
return Info(,"Network Address",get_network_address())
end function

--------------------------------------
global function ShowExternalIP()
--------------------------------------
return Info("External (Web) IP",get_external_address())
end function
