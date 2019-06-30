
--------------------------------------------------------------------------------
--# GtkSpinButton for getting numeric input 
--------------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=100x100,position=1,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL,spacing=10"),
    lbl = create(GtkLabel,"markup=<b><u>GtkSpinButton</u></b>\nfor getting numeric values from the user"),
    spinbtn = create(GtkSpinButton,0,100,0.010),
    box = create(GtkButtonBox,"spacing=10,layout=4"), -- 4 = GTK_BUTTONBOX_END
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"_Value","ShowValue"),
    btn3 = create(GtkButton,"_Adjustment","ShowAdjustment")
        
    set(spinbtn,"margin_left=100,margin_right=100")

    add(win,panel)
    add(panel,{lbl,spinbtn})
    add(box,{btn1,btn2,btn3})
    pack(panel,-box)

show_all(win)
main()

----------------------------------------
global function ShowValue()
----------------------------------------
return Info(win,"Spin","Value of spin button",
        sprintf("<span font='18'>%2.2f</span>",get(spinbtn,"value")))
end function

-- You can get more details by accessing the spin button's adjustment;
-----------------------------------
global function ShowAdjustment()
-----------------------------------
atom adj = get(spinbtn,"adjustment")
Info(win,"Adjustment",
    format("Value [.2]",get(spinbtn,"value")),
    format("Lower limit: [], Upper limit: []\nAs integer: []\nStep increment: [.2]",
        {get(adj,"lower"),
         get(adj,"upper"),
         get(spinbtn,"value as int"),
         get(adj,"step increment")}))
--etc. see GtkAdjustment
return 1
end function
