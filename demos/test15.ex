
-------------------------------------------------------------------------------------
--# Toggle button, custom check button, Switch
-------------------------------------------------------------------------------------

include GtkEngine.e
include std/utils.e -- for iif()

constant -- strings used to display control states; 
    up = "<span color='blue'>Up</span>",
    down = "<span color='green'>Down</span>",
    on = "<span color='green'>On</span>",
    off = "<span color='blue'>Off</span>",
    checked = "<span color='green'>Checked</span>",
    unchecked = "<span color='blue'>Unchecked</span>"

constant 
    win = create(GtkWindow,"size=100x200,border=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical,spacing=20"),
    lbl = create(GtkLabel,"markup=<u><b>Various Buttons</b></u>"),
    box = create(GtkButtonBox,"orientation=horizontal,margin top=10"),
    
    sizegroup = create(GtkSizeGroup,GTK_SIZE_GROUP_BOTH),
    btn1 = create(GtkToggleButton,"gtk-edit#_Edit"),
    btn2 = create(GtkCheckButton,"face-plain-symbolic#",_("ToggleMe")),
    btn3 = create(GtkSwitch),	

    btn4 = create(GtkButton,"gtk-quit","Quit"),
    btn5 = create(GtkButton,"gtk-ok","ShowStatus")
    
    set(btn1,"tooltip markup","A normal ToggleButton")
    set(btn2,"tooltip markup","A <i>crazy</i> CheckButton!")
    set(btn3,"tooltip markup","A Switch")

    add(win,panel)
    add(panel,{lbl,btn1,btn2,btn3})
    add(box,{btn4,btn5})
    pack_end(panel,box)
    
show_all(win)
main()

-----------------------------------
global function ToggleMe(atom ctl)
-----------------------------------
object img = get(ctl,"image") 

    if get(ctl,"active") then
	    set(img,"from icon name","face-laugh",GTK_ICON_SIZE_LARGE_TOOLBAR)
	    set(ctl,"label"," Happy")
    else
	    set(img,"from icon name","face-plain",GTK_ICON_SIZE_LARGE_TOOLBAR)
	    set(ctl,"label"," Sad")
    end if
    
return 1
end function

--------------------------------------------------
global function ShowStatus(atom ctl)
--------------------------------------------------
Info(win,"Buttons","Active buttons",
    sprintf("Toggle Button is: %s\nCheckButton is: %s\nSwitch is: %s",
        {iif(get(btn1,"active"),down,up), 
         iif(get(btn2,"active"),checked,unchecked),
         iif(get(btn3,"active"),on,off)}))
return 1
end function

