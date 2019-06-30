
--------------------------------------------------------------------------------
--# Linking button clicks to a user-written function
--------------------------------------------------------------------------------

include GtkEngine.e

constant -- create the widgets;
    win = create(GtkWindow,"border=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,"markup=<b><u>Linking</u></b>\n\tThe OK button is linked\n\tto a user-written function"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"), -- links to built-in Quit function;
    btn2 = create(GtkButton,"gtk-ok","Moo") -- links to user-written function Moo();

-- pack widgets into containers;
    add(win,panel) 
    add(panel,lbl)
    add(box,{btn1,btn2})
    pack_end(panel,box)

show_all(win)
main()

------------------------
global function Moo() -- see notes below;
------------------------
return Info(
     win,                               --[1]
    "Moo!",                             --[2]
    "You are here\n",                   --[3]                  
    "Wasn't that <i><u>easy?</u></i>?", --[4] 
     GTK_BUTTONS_CLOSE,                 --[5]			
    "thumbnails/cowbell2a.gif",         --[6] 
     ) 
end function
       
/*
   -- See dialogs.html in the documentation folder for details on the prebuilt dialogs.

    1 = parent (the main window, may be left empty)
    2 = title for dialog titlebar (defaults to Info if left empty)
    3 = primary text (will be bold if not marked up)
    4 = secondary text (may be marked up)
    5 = buttons (uses defaults if left empty; for NO buttons, enter a zero)
    6 = dialog image (uses default if left empty)
    7 = titlebar icon  (uses icon from main window if left empty)
    8 = background color (color name or hex value) 
    9 = MODAL = 1 / NON-MODAL = 0 
   10 = addon widget  (See custom dialog for details)
   11 = X position (where to pop up the dialog)
   12 = Y position 
   13 = assign a unique dialog name for special uses  
   
   -- Items 1,2, and 5..13 are often not needed, and can be omitted.
   -- Also, named dialog fields can be used instead of positional fields;
   -- see test227.ex for an example.
*/

