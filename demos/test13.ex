
--------------------------------------------------------------------------------
--# GTK Check buttons                                                           
--------------------------------------------------------------------------------

include GtkEngine.e

constant 
    docs = "<b><u>CheckButtons</u></b>\nSelect your favorite item(s)",
    menu = {"_Burgers","_Hotdogs","_Potato chips","_French fries"},
    bob = "./thumbnails/user_icon.gif"

-- underscores in above names implement 'hot keys' e.g. alt-h gets you a hot dog                                               

constant 
    win = create(GtkWindow,"size=150x-1,border=10,$destroy=Quit,title=`Bob's Drive Inn`"),
    panel = add(win,create(GtkBox,"orientation=vertical")),
    lbl = add(panel,create(GtkLabel,"margin bottom=5")),
    box = pack_end(panel,create(GtkButtonBox)),
    btn1 = add(box,create(GtkButton,"gtk-quit","Quit")),
    btn2 = add(box,create(GtkButton,"face-raspberry#Let's _Eat!",_("PlaceOrder")))
        
    set(win,"icon",bob)
    set(lbl,"markup",docs)
    
sequence items = {}
    for i = 1 to length(menu) do
	items &= add(panel,create(GtkCheckButton,menu[i]))
    end for

show_all(win)
main()

----------------------------------------------------
function PlaceOrder()                                       
----------------------------------------------------
object menu = {}, item
    for i = 1 to length(items) do
	if get(items[i],"active") then	--(1)
	    item = get(items[i],"label")
	    item = remove_all('_',item) --(2)
	    menu &= item & '\n'         --(3)
	end if
    end for
    Info(win,"Bob's Drive Thru","Your Order",menu,,bob,bob) --(4)
return 1
end function

-- (1) We check each button to see if it is 'active' - i.e. checked.
-- (2) if so, remove the underscore and                             
-- (3) append it to the order list                                  
-- (4) see dialogs.html in the documentation folder for params      
