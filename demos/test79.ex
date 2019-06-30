
---------------------------------------------------------------------------------
--# Label with mnemonic (hot key) which is displayed when alt is depressed.
---------------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=200x100,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    lbl = create(GtkLabel,"markup with mnemonic=Try alt-t to _test"), 
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","Foo"),
    box = create(GtkButtonBox)

    add(win,panel)
    add(panel,lbl)
    add(box,{btn1,btn2})
    pack(panel,-box)
    
show_all(win) -- everything but inv1 button, created below;

constant inv1 = create(GtkButton) -- button with no caption, button is hidden!
    connect(inv1,"clicked","Foo")
    set(lbl,"mnemonic widget",inv1)
    add(panel,inv1)

main()

------------------------------------
global function Foo(atom ctl)
------------------------------------
if ctl = btn2 then
    Info(win,,"OK button pressed")
else
    Info(win,,"Alt-t pressed")
end if
return 1
end function
