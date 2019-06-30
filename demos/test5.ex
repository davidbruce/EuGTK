
-------------------------------------------------------------------------
--# Text markup for labels (also works for tooltips, etc)
-------------------------------------------------------------------------

include GtkEngine.e
include resources/test5.e -- this file contains the marked-up text and docs;

constant 
    win = create(GtkWindow,"border=5,size=500x80,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=1,margin_left=20,margin_right=20"),
    lbl1 = create(GtkLabel),
    sep1 = create(GtkSeparator),
    lbl2 = create(GtkLabel),
    sep2 = create(GtkSeparator,"margin-top=10,margin-bottom=10"),
    lbl3 = create(GtkLabel),
    box  = create(GtkButtonBox,"margin-top=10"),
    btn1 = create(GtkButton,"gtk-quit","Quit")
    
    set(lbl1,"markup",docs)
    set(lbl2,"markup",text)
    set(lbl3,"text","Source:\n" & text)
    
    add(win,panel)
    add(panel,{lbl1,sep1,lbl2,sep2,lbl3})
    add(panel,create(GtkSeparator))
    add(box,btn1)
    pack_end(panel,box)

show_all(win)
main()


