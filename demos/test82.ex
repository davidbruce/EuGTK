
------------------------------------------------------------------------
--# GtkScale with options
------------------------------------------------------------------------

include GtkEngine.e 

constant -- primary window:
    win = create(GtkWindow,"size=200x100,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    lbl = create(GtkLabel,"markup=<b><u>GtkScale</u></b> using an adjustment"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    scale = create(GtkScale,{
        {"orientation",HORIZONTAL},
        {"range",0,100},
        {"increments",0.01,1},
        {"fill level",75},
        {"show fill level",TRUE}, -- note: some themes do not colorize the fill level bar!
        {"restrict to fill level",FALSE}})    

-- secondary window:

constant vwin = create(GtkWindow,{ -- window to show current value;
    {"title","Test 82 Value"},
    {"keep above",TRUE},
    {"default size",100,100},
    {"transient for",win}, 
    {"deletable",FALSE},
    {"type hint",GDK_WINDOW_TYPE_HINT_DIALOG},
    {"position",GTK_WIN_POS_MOUSE}})

constant vlbl = create(GtkLabel,"font='Courier bold 18',text='0'") -- for value;

    add(win,panel)
    add(panel,{lbl,scale})
    add(vwin,vlbl)
    show_all(vwin)

show_all(win)

constant sigid = connect(scale,"value-changed","DisplayValue")

main()  

------------------------------------------------------------
global function DisplayValue(atom ctl)
------------------------------------------------------------
atom val = get(ctl,"value")

    set(vlbl,"markup",sprintf("Value\n%2.1f",val))
    
    if val > 75 then
        set(vwin,"background=black")
        set(vlbl,"markup",sprintf("OVER!\nValue\n%2.1f",val))
        set(vlbl,"background=red,foreground=white")
        
    elsif val > 0 then
        set(vwin,"title=Test 82 Value,background=lightgreen")
        set(vlbl,"background=green,foreground=yellow")
        
    else set(vlbl,"background=gray80,foreground=black")
    
    end if
return 1
end function









