
---------------------------------
--# more tinkering with pixbufs;
---------------------------------

include GtkEngine.e

ifdef WINDOWS then 
	constant clown = "thumbnails/clown.png"
elsedef
	constant clown = "thumbnails/clown.svg"
end ifdef

constant 
    win = create(GtkWindow,"background=blue,border=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    pixbox = create(GtkBox,"orientation=HORIZONTAL"),
    pix = create(GdkPixbuf,clown,200,200),
    img1 = create(GtkImage,pix),
    x2 = get(pix,"scale simple",140,240,GDK_INTERP_HYPER),
    img2 = create(GtkImage,x2),
    x3 = create(GdkPixbuf,clown,200,200),
    img3 = create(GtkImage,x3),
    lbl = create(GtkLabel,"color=white,markup=`Original\t\t\t\tScaled 140x240\t\t\tCopy area`")
    
    set(pix,"copy area",50,40,90,45,x3,50,140) -- copy, move and paste 'cutout'

    add(win,panel)
    add(panel,pixbox)
    add(pixbox,{img1,img2,img3})
    pack(panel,-lbl)
    
show_all(win)
main()
