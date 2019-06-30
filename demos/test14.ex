
--------------------------------------------------------------------------------
--# GTK Radio Buttons
--------------------------------------------------------------------------------

include GtkEngine.e

constant 
    fmt = "<span size='x-large' weight='heavy' underline='double' underline_color='red' >%s</span>",
    bob = create(GdkPixbuf,"thumbnails/user_icon.gif") 

constant 
    win = create(GtkWindow,"title=`Bob's Diner`,size=250x-1,border=10,position=1,icon=face-raspberry,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    hr = create(GtkSeparator),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok",_("ShowBeverageChoice")),
    lbl = create(GtkLabel,"markup=<b><u>RadioButtons</u></b>\nChoose a beverage\n(Only 1 to a customer)")

sequence rb = {0} -- each radio button in a group is parented to the previous button,
    rb &= create(GtkRadioButton,0,"_Coke") -- except for the first, where parent = null;
    rb &= create(GtkRadioButton,rb,"_Pepsi") 
    rb &= create(GtkRadioButton,rb,"_Mountain Dew")
    rb &= create(GtkRadioButton,rb,"_Iced _Tea")

    set(btn2,"can default",TRUE) -- set up btn2 to be activated on <enter>
    set(win,"default",btn2)

    add(win,panel)
    add(panel,{lbl,hr})
    add(panel,rb)
    add(box,{btn1,btn2})
    pack_end(panel,box)

show_all(win)
main()

--------------------------------------------------------------
function ShowBeverageChoice()
--------------------------------------------------------------
object drink
    
    for i = 1 to length(rb) do
        if get(rb[i],"active") then --(1)
            drink = remove_all('_',get(rb[i],"label")) --(2)
            exit  --(3)
        end if
    end for
    
    Info(win,"Bob's Diner","Your Beverage Choice",
        sprintf(fmt,{drink}),,bob,"face-raspberry") 
return 1
end function

--[1] check for selected button, 
--[2] remove leading underscore for neat display,
--[3] since there can only be one active, we're done!




 

