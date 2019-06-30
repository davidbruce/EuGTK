
--# INI test

include GtkEngine.e
include GtkSettings.e
include std/io.e

object bgcolor 
 
-- Note: we must connect to the main window's 'delete_event', rather than to the 
-- 'destroy' event here, so that the window still exists when the Bailout routine
-- is called (and the window's properties can still be determined)
-- Once the window is destroyed, it's too late!

constant ini = "initest.ini",
    win = create(GtkWindow,"name=Main,size=300x200,border=10,$delete_event=Bailout"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl1 = create(GtkLabel,"font=mono"),
    lbl2 = create(GtkLabel,"color=red"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Bailout"),
    btn2 = create(GtkButton,"preferences-color#_Color","RandomBkgnd")
    
    set(btn1,"tooltip text","Quit")
    set(btn2,"tooltip text","Click for random background color")
    
    add(win,pan)
    add(pan,{lbl1,lbl2})
    add(box,{btn1,btn2})
    pack(pan,-box)
    
    Startup() -- load saved settings;
    
show_all(win)
main()

---------------------
procedure Startup()
---------------------

--[1] Load all default properties for widgets on the Save list;
 settings:Load(ini) -- restores window size and position, background color;
 
--[2] retrieve a non-property key/value;
 object lastrun = settings:Get("Main","last run") 
 set(lbl2,"text",sprintf("Last Run: %s",{lastrun}))
 
--[3] display the ini text on the window for demo purposes only;
 set(lbl1,"text",read_file(ini)) 
 
end procedure

------------------------------
global function RandomBkgnd()
------------------------------
bgcolor = text:format("#[X]",rand(#FFFFFF))
set(win,"background",bgcolor)
return 1
end function

-------------------------
global function Bailout()
-------------------------

--[1] save default size and position for win;
 settings:Save(ini,{win})
 
--[2] save a non-default property (win background color):
 if object(bgcolor) then -- only if a color has been selected;
    settings:Set(ini,"Main","background",bgcolor)
 end if
 
--[3] save a non-property key/value:
 object now = date() now[1] += 1900
 settings:Set(ini,"Main","last run",text:format("[2]/[3]/[1] [4]:[5:02]",now))
 
return Quit()
end function
    
