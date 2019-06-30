
-----------------------------------------------------------------
--# GtkToolBar
-----------------------------------------------------------------

include GtkEngine.e

constant docs = `markup=
<u><b>GtkToolBar</b></u>
This demo uses stock buttons,
with tooltips
`
constant 
    cap = {"application-exit","gtk-apply","gtk-find"},
    
    items = {
    create(GtkToolButton,cap[1],0,"Quit"),
    create(GtkToolButton,cap[2],0,_("Foo"),2),
    create(GtkToolButton,cap[3],0,_("Foo"),3)
    },

    tips = {
    "Stock <b><i>gtk-quit</i></b> button\nClick to exit",
    "Stock <b><i>gtk-apply</i></b> button",
    "Stock <b><i>gtk-find</i></b> button"
    },

    win = create(GtkWindow,"size=300x100,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    toolbar = create(GtkToolbar,{{"icon size",GTK_ICON_SIZE_LARGE_TOOLBAR}}),
    lbl = create(GtkLabel,docs)
 
    for i = 1 to length(items) do
        set(toolbar,"insert",items[i],-1)
        set(items[i],"tooltip markup",tips[i])
    end for

    add(win,panel)
    add(panel,{toolbar,lbl})
    
show_all(win)
main()

----------------------------------------------
function Foo(atom ctl, integer i)
----------------------------------------------
    Info(win,,"You clicked",cap[i],,cap[i])
return 1
end function
