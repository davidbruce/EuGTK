
------------------------------------------------------------------------
--# GTK Spin Button for numeric input
------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=100x80,border=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL,spacing=10"),
    lbl = create(GtkLabel,"markup=<u><b>GtkSpinButton</b></u>\n\tfor getting numeric input from the user"),
    spin = create(GtkSpinButton,0,10,0.01), -- params: min, max, step [default = 0->100 by 1)
    box = create(GtkButtonBox,"margin_top=20"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok",_("DisplayValue"))
    
    set(spin,"margin-left=80,margin-right=80")

    add(win,panel)
    add(panel,lbl)
    add(panel,spin)
    add(box,{btn1,btn2})
    pack_end(panel,box)

show_all(win)
--set(win,"interactive debugging",1) -- try this!
main()

---------------------------------------------------------------------------
function DisplayValue() 
---------------------------------------------------------------------------
object increments = get(spin,"increments")
object range = get(spin,"range")
atom val = get(spin,"value")
    Info(win,"Spin Button",
        format("Value is [.2]",val), 
        format("Range: [] to []\n",range) & 
        format("Increments: [.2], [.2]",increments))
return 1
end function

