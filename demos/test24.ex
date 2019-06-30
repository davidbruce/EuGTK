
--------------------------------------------------------------------------------
-- There's no real purpose for this silly program - 
--# You can show pix upside down or reversed l/r if you wish.
-- Some GTK themes have a bug which adds space around images.
-- The Mint-X themes display properly without extra space,
-- others add space;
-- To prevent the spaces from showing, you can link to a css file which
-- sets GtkImage:padding to 0;
--------------------------------------------------------------------------------

include GtkEngine.e

constant cssp = create(GtkCssProvider,"GtkImage {padding: 0;}")

object img = repeat(0,4)
object pix = create(GdkPixbuf,"thumbnails/giraffe.xpm")

    img[1] = create(GtkImage)
    set(img[1],"from pixbuf",pix)

    img[2] = create(GtkImage)
    set(img[2],"from pixbuf",get(pix,"flip",1)) 

    img[3] = create(GtkImage)
    set(img[3],"from pixbuf",get(get(pix,"rotate simple",180),"flip",1))
    
    img[4] = create(GtkImage)
    set(img[4],"from pixbuf",get(pix,"rotate simple",180))

constant win = create(GtkWindow,
    "border_width=10,resizable=FALSE,position=1,$destroy=Quit")

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)
    
constant grid = create(GtkGrid)
    add(panel,grid)
    set(grid,{
	{"attach",img[1],1,1,1,1},
	{"attach",img[2],2,1,1,1},
	{"attach",img[3],1,2,1,1},
	{"attach",img[4],2,2,1,1}})

constant btn1 = create(GtkButton,"gtk-quit","Quit")

constant box = create(GtkButtonBox)
    add(box,{btn1})
    pack(panel,-box)

show_all(win)
main()




