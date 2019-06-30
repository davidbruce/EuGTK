
------------------------------------------------------------------------------
--# GtkAppChooserButton
------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `markup=
<u>App Chooser Button</u>
Click to show apps
for text/plain. This does
not change the associations.
`
constant 
    win = create(GtkWindow,"title=App Chooser Button,size=360x-1,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,docs),
    fil = create(GFile,"thumbnails/mongoose.png"),
    ico = create(GFileIcon,fil),
    btn = create(GtkAppChooserButton,"text/plain")
    
    set(btn,"append custom item","Euphoria","Eu Editor",ico)
    set(btn,"show dialog item",TRUE)
    set(btn,"active custom item","Euphoria")

    add(win,pan)
    add(pan,lbl)
    pack(pan,btn)
    
show_all(win)

connect(btn,"custom-item-activated","FooBar") -- must be done after window is shown.

main()

----------------------------------------------------------
global function FooBar(atom ctl, object name)
----------------------------------------------------------
    Info(win,,peek_string(name),"Custom item selected.")
return 1
end function

