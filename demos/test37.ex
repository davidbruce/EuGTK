
--------------------------------------------------------------------------------------
--# GtkGrid; overlaying items
--------------------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=100x100,border_width=10,position=1,$destroy=Quit"),
    lbl  = create(GtkLabel,"markup=<b><u>GtkGrid</u></b>\nposition items manually"),
    img1 = create(GtkImage,"thumbnails/dino_slo.gif"),
    img2 = create(GtkImage,"thumbnails/BabyTux.png"),
    img3 = create(GtkImage,"thumbnails/clown.png"),
    grid = add(win,create(GtkGrid))
        
    set(grid,{
        {"row spacing",2},
        {"column spacing",2},
        {"attach",lbl,2,1,4,5},
        {"attach",img2,1,1,1,1},
        {"attach",img1,4,4,1,4},
        {"attach",img3,2,5,4,3}})
        
show_all(win)
main()
