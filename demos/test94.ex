
----------------------------------------------------------------------------------
--# GtkSizeGroup (one size fits all!)
----------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>GtkSizeGroup</b></u>
Forces all items contained in the group to
be displayed at the same size`

constant win = create(GtkWindow,"size=300x300,border_width=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
    add(win,panel)

constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)

constant bottom = create(GtkBox,"orientation=HORIZONTAL")
    add(panel,bottom)

constant 
    left = create(GtkBox,VERTICAL),
    sep = create(GtkSeparator,VERTICAL),
    right = create(GtkBox,VERTICAL)
    pack(bottom,{left,sep,right},TRUE,TRUE,10)

-- items on left side are just added to the panel;
constant img1 = create(GtkImage,"thumbnails/user_icon.gif")
constant lbl1 = create(GtkLabel,"Hello World!")
constant btn1 = create(GtkButton,"gtk-ok")
    add(left,{img1,lbl1,btn1})

-- items on right side are added to a sizegroup, then added to the panel;
constant img2 = create(GtkImage,"thumbnails/user_icon.gif")
constant lbl2 = create(GtkLabel,"Hello World!")
constant btn2 = create(GtkButton,"gtk-ok")
constant sizegroup = create(GtkSizeGroup,GTK_SIZE_GROUP_BOTH)
    add(sizegroup,{img2,lbl2,btn2})
    add(right,{img2,lbl2,btn2})

constant lbl3 = create(GtkLabel)
    set(lbl3,"margin top",20)
    set(lbl3,"markup","<i>Items on right are added to a size group</i>")
    add(panel,lbl3)

show_all(win)
main()
