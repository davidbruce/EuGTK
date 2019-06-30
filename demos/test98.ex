
-------------------------------------------------------
--# Mnemonic Labels
-------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>Mnemonic Label</b></u>
Use alt-E to activate this one.`

constant 
    win = create(GtkWindow,"size=300x100,border_width=5,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl1 = create(GtkLabel,"markup=<u><b>Mnemonic Label</b></u> Use alt-E to activate this one"),
    lbl2 = create(GtkLabel,{{"markup with mnemonic","Fred &amp; _Ethel"}}), -- [1]
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok",_("Foo")),
    btnbox = create(GtkButtonBox)
        
    set(lbl2,"mnemonic widget",btn2) -- [2]

    add(win,panel)
    add(panel,{lbl1,lbl2})
    add(btnbox,{btn1,btn2})
    pack(panel,-btnbox)
    
show_all(win)
main()

-- [1] When using special chars in markup (such as ampersand), must use older-style to set property.
-- [2] Connect the mnemonic (alt-E) to trigger the OK button.

------------------------
function Foo()
------------------------
    set(lbl2,"markup","Fred &amp; Ethel,\n<b><i>The Mertzes</i></b>")
return 1
end function
