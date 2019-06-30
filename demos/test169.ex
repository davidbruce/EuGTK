
----------------------------------------------------------------------------------------------
--# GtkColorChooserWidget with editor
----------------------------------------------------------------------------------------------

include GtkEngine.e

requires("3.04","GtkColorChooserWidget")

constant docs = `markup=<u><b>Color Chooser Widget</b></u>
Select a color, hit the Select-Color button.
`
constant 
    win = create(GtkWindow,"border=10,size=500x400,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL,spacing=10"),
    lbl = create(GtkLabel),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkCheckButton,"Editor",_("ToggleEditor")),
    btn3 = create(GtkButton,"gtk-select-color",_("ShowSelectedColor")),
    box = create(GtkButtonBox),
    ccw = create(GtkColorChooserWidget,"rgba=LightGreen,show_editor=FALSE")
    
    connect(ccw,"color-activated",_("ShowSelectedColor"))
    
    add(win,panel)
    add(panel,lbl)
    pack(panel,ccw)
    add(box,{btn1,btn2,btn3})
    pack(panel,-box)

show_all(win)
main()

---------------------------------------
function ToggleEditor(atom ctl)
---------------------------------------
    set(ccw,"show-editor",get(ctl,"active"))
return 1
end function

------------------------------------
function ShowSelectedColor()
------------------------------------
object x = get(ccw,"rgba") 
    set(lbl,"markup",
    sprintf("<b><u>Color Chooser Widget</u></b>\nColor selected: <b>%s</b>",{x}))
return 1
end function
