
----------------------------------------------------------------
--# Connecting multiple signals
----------------------------------------------------------------

include GtkEngine.e

constant docs = `<b><u>Multiple functions</u></b>
You can have one control call 
multiple user-written functions.
`
constant 
    win = create(GtkWindow,"size=100x100,position=1,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel,{{"markup",docs}}),
    btnbox = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-ok"),
    btn2 = create(GtkButton,"gtk-quit","Quit")

    add(win,panel)
    add(panel,lbl)
    add(btnbox,{btn2,btn1})
    pack(panel,-btnbox)
    
    connect(btn1,"clicked",_("Foo")) -- show foo
    connect(btn1,"clicked",_("Bar")) -- then bar
    connect(btn1,"clicked",_("Baz")) -- finally baz
    connect(btn1,"clicked","Quit")   -- then go away
    
show_all(win)
main()

-- functions below will be executed in the order they are declared 
-- in the 'connect' lines above.
-----------------------------
function Baz(atom ctl)
-----------------------------
    Info(win,,"Baz","This is third") 
return 1
end function

-----------------------------
function Foo(atom ctl)
-----------------------------
    Question(win,,"Foo","This is first") 
return 1
end function

-----------------------------
function Bar(atom ctl)
-----------------------------
    Warn(win,,"Bar","This is second") 
return 1
end function


