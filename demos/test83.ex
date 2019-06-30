
---------------------------------------------------------------------------
--# GtkScale and GtkEntry as progressbar
---------------------------------------------------------------------------

include GtkEngine.e	

-- this is the main window which contains a scrollbar and a quit button;
constant 
    win = create(GtkWindow,"title=Test83,size=200x100,border_width=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=VERTICAL,spacing=5"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"), 
    btn2 = create(GtkButton,"gtk-about","About"),  
    lbl = create(GtkLabel,"markup=<b><u>GtkScrollbar</u></b>\n" &
     "using an adjustment\nand a level display\nin a separate window"),
-- this adjustment links scrollbar changes to the value displayed in the second window;
    adj = create(GtkAdjustment),
    sb = create(GtkScrollbar,0,adj)

    set(adj,"configure",25,0,100,1) -- initial value, min, max, step;
    add(win,pan)
    add(pan,{lbl,sb})
    add(box,{btn1,btn2})
    pack(pan,-box)
    
atom sigid = connect(sb,"value-changed","DisplayValue") -- trigger update to secondary window;
   
-- the second window is borderless, and contains a GtkEntry which displays
-- the value set by the scrollbar both as text and as a progressbar;

constant vwin = create(GtkWindow,{
    {"title","Value"},
    {"default size",200,50},
    {"background","black"},
    {"border width",10},
    {"position",GTK_WIN_POS_CENTER},
    {"keep above",TRUE},
    {"decorated",FALSE},
    {"move",300,250},
    {"connect","hide",_("DisconnectSignal"),sigid}}) -- disconnect to prevent crash if window is closed!

constant lbl1 = create(GtkLabel,"font=8,color=yellow,markup=" &
    "<u><b>test83.ex : </b></u>\nBelow is a GtkEntry with a progress bar\n")
 
constant vpanel = create(GtkBox,VERTICAL)
    add(vwin,vpanel)
    add(vpanel,lbl1)

constant vlbl = create(GtkEntry,{
    {"font","Courier Bold 12"},
    {"color","red"},
    {"alignment",.5},
    {"text","25 percent"},
    {"progress fraction",0.25}})

    add(vpanel,vlbl)
    show_all(vwin)
	
show_all(win)


main()

------------------------------------------------------------
global function DisplayValue(atom ctl)
------------------------------------------------------------
atom v = get(ctl,"value") 
    set(vlbl,"text",sprintf("%2.0f percent",v))
    set(vlbl,"progress fraction",v/100)
    if v = 100 then
        set(vwin,"background","red")
    else
	set(vwin,"background","black")
    end if
return 1
end function

-----------------------------------------------------------
function DisconnectSignal(atom ctl, integer sigid)
-----------------------------------------------------------
    disconnect(sb,sigid)
return 1
end function

---------------------------------------------
global function About()
---------------------------------------------
return Info(win,"About","Nothing to see here, move along...")
end function




