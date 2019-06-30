
------------------------------------------------------------------------
--# How to use a custom cursor;
-- This can be either one of the built-in cursor enums,
-- or an image file such as .png, .jpg, etc...
------------------------------------------------------------------------
/*
 *	
 * Comment
 *
*/
include GtkEngine.e
include std/filesys.e

constant 
    win = create(GtkWindow,"title=OpenEuphoria,border=10,position=1,icon=face-smile,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    img = create(GtkImage,"thumbnails/euphoria.gif"),
    box = create(GtkButtonBox),
    btn = create(GtkButton,"gtk-quit","Quit")

add(win,panel)
add(panel,img)	
add(box,btn)
pack_end(panel,box)
show_all(win)

--------------------------------------------------------------
-- custom cursors must be created AFTER the window they are --
-- to be used in has been instantiated (a.k.a. shown), but  --
-- prior to entering the main GTK processing loop.          --
--------------------------------------------------------------

constant goose = locate_file("thumbnails/mongoose.png") -- find image to use for cursor;

constant pix = create(GdkPixbuf,goose,32,32) -- size 32x32px;
  
    set(win,"cursor",pix,1,40) -- numbers set the location of the cursor's 'hot spot';

    -- if you prefer a pre-built cursor, use one of the enums in 
    -- GtkEnums.e:
    -- set(win,"cursor",GDK_WATCH)
    
    -- this can also be used as a 'wait' indication while some long 
    -- process takes place...

main()


