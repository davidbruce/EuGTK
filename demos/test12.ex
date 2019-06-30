
-----------------------------------------------------------------------------------
--# GtkComboBoxText selects from a limited set of choices.
-- This is fine for most purposes, and easy to set up. See the GTk docs on how to
-- use a GtkComboBox with a model for more complex uses. 
-----------------------------------------------------------------------------------

include GtkEngine.e

constant docs = "<b><u>GtkComboBoxText</u></b>\n\nPick your favorite fruit"

constant fruit = {
    "Apples",
    "Bananas",
    "Cherries",
    "Grapes",
    "Peaches",
    "Pears"
}

constant 
    win = create(GtkWindow,"border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL,spacing=10"),
    lbl = create(GtkLabel),
    cb = create(GtkComboBoxText),
    btnbox = create(GtkButtonBox,"spacing=5"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","ShowFave")
    
    set(lbl,"markup",docs)
    add(cb,fruit)
    set(cb,"active",1)  -- see Note below
    add(win,panel)
    add(panel,lbl)
    add(panel,cb)
    pack_end(panel,btnbox)
    add(btnbox,{btn1,btn2})
    
show_all(win)
main()

-------------------------------------------------------------
global function ShowFave() 
-------------------------------------------------------------
return Info(win,"Fruit","Your favorite is:",get(cb,"active text"))
end function

-- Note: 
--  We set the first item to be 'active', which means it will
--  be the one initially shown. Otherwise, nothing will be shown 
--  until the user clicks to drop down the list of items.


