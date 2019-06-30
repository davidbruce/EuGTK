
--# Transparent window (frame included)

include GtkEngine.e

atom opa = 1

constant 
    win = create(GtkWindow,"title=Transparent Window,size=300x300,border=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    slider = create(GtkScale,HORIZONTAL,0,1,0.01),
    lbl = create(GtkLabel,"font=24,color=yellow,markup=Here is a label!"),
    img = create(GtkImage,"~/demos/thumbnails/BabyTux.png"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit")
    
    set(win,"background",sprintf("rgba(0,0,80,%g)",opa))
    set(win,"opacity",opa)
    connect(win,"map-event","UpdateOpacity")

    set(slider,"tooltip text","Slide to change entire window opacity")
    connect(slider,"value-changed","UpdateOpacity")
    set(slider,"value",opa)
    
    add(win,panel)
    add(panel,{lbl,img,slider})
    add(box,btn1)
    pack(panel,-box)
    
show_all(win)
main()

--------------------------------
global function UpdateOpacity()
--------------------------------
    opa = get(slider,"value") 
    set(win,"background",sprintf("rgba(0,0,80,%g)",opa))
    set(win,"opacity",opa) 
    if opa = 0 then
        if Question(win,"Restore?","Opacity is zero","Click Yes to restore") = MB_YES then 
            set(slider,"value",1) 
        end if
    end if
    return 1
end function
