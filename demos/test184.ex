
---------------------------------------------------------------------------------------
--# This demos 'manual' namespacing,
-- i.e. namespacing without using Glade to design
-- the interface. Widgets to be addressed via string names must be named upon creation.
-- Refer to the two includes, a.e and b.e to see how this must be done.
-- By naming widgets, you can make them globally accessible WITHOUT declaring them 
-- export or global. There may possibly be some valid reason for doing this :)
---------------------------------------------------------------------------------------

include GtkEngine.e

include resources/a.e
include resources/b.e

constant docs = `<b><u>Namespacing</u></b>

Click the OK button to change colors
of both child windows...
`
constant win = create(GtkWindow,
    "title=Test Window,size=300x100,border=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)
    
constant lbl = create(GtkLabel,{{"markup",docs}})
    add(panel,lbl)
    
constant
    box = create(GtkButtonBox),
    btns = { -- an array of 3 buttons;
    create(GtkButton,"gtk-quit","Quit"),
    create(GtkButton,"Clear",call_back(routine_id("UnDo"))),
    create(GtkButton,"gtk-ok",call_back(routine_id("DoIt")))
    }
    add(box,btns)
    pack_end(panel,box)
    
show_all(win)
main()

----------------------
function DoIt()
----------------------
-- Neither a:window nor b:window were exported from the includes, 
-- but since they were named, they can be referenced by name (in string form).
-- Colors *were* exported, so can be referenced in the normal way;
    set("a:window","background",a:color)
    set("b:window","background",b:color)
return 1
end function

----------------------
function UnDo()
----------------------
-- clear functions *were* exported by the includes, so can be referenced directly.
    a:clear()
    b:clear()
return 1
end function
