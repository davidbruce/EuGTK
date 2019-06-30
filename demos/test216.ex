
--# Transparent window contents;

include GtkEngine.e

atom opa = 0.5

constant 
    win = create(GtkWindow,"title=Transparent Background,size=300x300,border=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    slider = create(GtkScale,HORIZONTAL,0,1,0.01),
    lbl = create(GtkLabel,"color=yellow,font=24,markup=Here is a label!"),
    img = create(GtkImage,"~/demos/thumbnails/BabyTux.png"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit")
    
    set(win,"background",sprintf("rgba(0,0,80,%g)",opa))
    set(win,"opacity",opa)

    set(slider,"value",opa)
    set(slider,"tooltip text","Slide to change background and button transparency")
    connect(slider,"value-changed","UpdateOpacity")

    atom scrn = get(win,"screen") 
    atom vis = get(scrn,"rgba visual") 
    set(win,"visual",vis)

    add(win,panel)
    add(panel,{lbl,img,slider})
    add(box,btn1)
    pack(panel,-box)

show_all(win)
main()

---------------------------------------
global function UpdateOpacity(atom ctl)
---------------------------------------
    opa = get(ctl,"value") 
    set(win,"background",sprintf("rgba(0,0,80,%d)",opa*255))
    set(win,"opacity",opa)
    if opa = 0 then
        Info(win,,"Note",
        "The window frame and titlebar are still visible,\nCompare to test217")
    end if
    return 1
end function
