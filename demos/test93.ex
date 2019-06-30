
----------------------------------------------------------------------------------------
--# Arrows;

-- Note: there is also a shadow param which can be 
-- sent for GtkArrows, but I am unable to see any shadows.

-- Perhaps this is because the GtkArrow is soon to be deprecated in 
-- favor of using images, or it may be due to the particular themes
-- I have tried.
-----------------------------------------------------------------------------------------

include GtkEngine.e 

constant docs = `<b><u>Arrows</u></b>
when you need a pointy object.
Color, direction and size are adjustable.`

constant win = create(GtkWindow,"size=300x200,border_width=5,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
    add(win,panel)
    
constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)
    
constant 
    a1 = create(GtkArrow,GTK_ARROW_UP), 
    a2 = create(GtkArrow,GTK_ARROW_DOWN), 
    a3 = create(GtkArrow,GTK_ARROW_LEFT),
    a4 = create(GtkArrow,GTK_ARROW_RIGHT)
        
    set(a1,"color=forestgreen")
    set(a2,"color=red")
    set(a3,"size request",40,40)
    add(panel,{a1,a2,a3,a4})
    
show_all(win)
main()






