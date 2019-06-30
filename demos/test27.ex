
--# SVG vs. other image formats;

include GtkEngine.e

constant 
    win = create(GtkWindow,"border_width=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl1 = create(GtkLabel,"markup=<u><b>SVG images</b></u> can be resized without losing any resolution\n\n" &
        "<b>Left:</b> png at natural size (90 x 90 px)   " & 
        "<b>Center:</b> png sized to 400 x 400 px. is blurry     " &
        "<b>Right:</b> svg sized to 400 x 400 px. is sharp and clear     "),
    panel2 = create(GtkBox,"orientation=horizontal"),

    -- creating image directly from file results in a 'natural' size image;
    img1 = create(GtkImage,"thumbnails/clown.png"),
    
    -- creating image from pixbuf allows choosing desired size, but resizing png isn't a good idea!
    pb1 = create(GdkPixbuf,"thumbnails/clown.png",400,400),
    img2 = create(GtkImage,pb1),
    
    -- below, we enlarge an svg image to the same 400px size, with no loss.
    pb2 = create(GdkPixbuf,"thumbnails/clown.svg",400,400,1),
    img3 = create(GtkImage,pb2)

    add(win,panel)
    add(panel,{lbl1,panel2})
    add(panel2,{img1,img2,img3})
    
show_all(win)
main()
