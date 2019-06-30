
----------------------------------------------------------
--# Opacity
----------------------------------------------------------

include GtkEngine.e

constant docs = `<b><u>Opacity</u></b>

    You need to be running a compositing window manager
    to see this demonstrated.
    
    Minimum is set to 20%, so window won't fade away
    completely!
`
constant 
    win = create(GtkWindow,"border_width=10,size=300x-1,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel,{{"markup",docs}}),
    btnbox = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    op_ctl = create(GtkScale,HORIZONTAL,.20,1,0.01) -- values are min, max, step
    
    set(op_ctl,"value",1.00) -- starting value
    connect(op_ctl,"value-changed","UpdateOpacity") 

    add(win,panel)
    add(panel,{lbl,op_ctl})
    add(btnbox,btn1)
    pack(panel,-btnbox)
    
show_all(win)
main()

---------------------------------------
global function UpdateOpacity(atom ctl)
---------------------------------------
    set(win,"opacity",get(ctl,"value"))
return 1
end function

