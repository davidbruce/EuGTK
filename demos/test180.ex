
--# GtkPaned test


include GtkEngine.e
include GtkSettings.e

create_directory(canonical_path("~/tmp"))
    
constant ini = canonical_path("~/tmp/test180.ini"), 
    win = create(GtkWindow,"name=Window,size=300x200,border=10,position=CENTER,$destroy=Bail"),
    ebox = create(GtkEventBox,"above child=TRUE"),
    panel = create(GtkBox,"orientation=vertical,spacing=10"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Bail"),
    paned = create(GtkPaned,"name=Paned,wide handle=TRUE,position=137"),
    img1 = create(GtkImage,"thumbnails/mongoose.png"),
    img2 = create(GtkImage,"thumbnails/cowbell.png"),
    lbl = create(GtkLabel,"Position"),
    left = get(paned,"child1"),
    right = get(paned,"child2")
    
    set(paned,"add1",img1)
    set(paned,"add2",img2)
    
    connect(ebox,"button-release-event","ShowPos")
    
    add(win,panel)
    add(panel,ebox)
    add(ebox,paned)
    add(panel,lbl)
    pack(panel,-box)
    add(box,btn1)
  
    settings:Load(ini)
    ShowPos()
    
show_all(win)
main()

---------------------------------
global function ShowPos()
---------------------------------k
set(lbl,"text",sprintf("Position %d",get(paned,"position")))
return 1
end function

-----------------------
global function Bail()
-----------------------
Info(win,"Saving pane position","File:",ini)
settings:Save(ini,{win,paned})
return Quit()
end function

    
