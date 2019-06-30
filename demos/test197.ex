
-----------------------------------------------------------------------------
--# Saving a pixbuf in various formats:
-----------------------------------------------------------------------------
-- this depends on which image formats your GTK library knows how to handle.
-- don't worry too much if it fails on some. 
-- You won't often use this feature, and there are always other ways to
-- accomplish the same thing using external programs (Gimp, for instance).
------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `
<u><b>Saving Pixbufs</b></u>

This loads an image of the mongoose, and
saves it in various formats, reporting 
success or failure.
`
constant 
	win = create(GtkWindow,"border=10,$destroy=Quit"),
	pb = create(GdkPixbuf,"~/demos/thumbnails/mongoose.png"),
	panel = create(GtkBox,"orientation=vertical"),
	lbl = create(GtkLabel,{{"markup",docs}}),
	img = create(GtkImage,pb),
	box = create(GtkButtonBox),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"insert-image#_Convert","SaveEm")

constant filetype = {
	"jpeg","png","tiff","ico","bmp","gif"
	}

	add(win,panel)
	add(panel,{lbl,img})
	add(box,{btn1,btn2})
	pack(panel,-box)
	
show_all(win)
ifdef WINDOWS then Info(,,"Sorry","Doesn't work in Windows!") end ifdef
main()

---------------------------------------------------------------------
function SaveFmt(atom img, sequence fname, sequence fmt, object opt=0)
-----------------------------------------------------------------------
    if get(img,"save",canonical_path(fname),fmt,opt) then
	    return sprintf("\t%s\n",{fmt})
    else
	    return sprintf("<span color='red'>\t%s failed\n</span>",{fmt})
    end if
end function

-----------------------------------
global function SaveEm()
-----------------------------------
object list = "Saved in home directory:\n"
    & SaveFmt(pb,"~/Goose.png","png","compression=5")
    & SaveFmt(pb,"~/Goose.jpg","jpeg","quality=100")
    & SaveFmt(pb,"~/Goose.ico","ico","depth=24")
    & SaveFmt(pb,"~/Goose.bmp","bmp")
    & SaveFmt(pb,"~/Goose.xpm","xpm")
    & SaveFmt(pb,"~/Goose.gif","gif")
    & SaveFmt(pb,"~/Goose.tif","tiff")
    & SaveFmt(pb,"~/Goose.cgm","cgm")
    & SaveFmt(pb,"~/Goose.svg","svg")

-- compression, quality, depth are optional, and only work on 
-- the indicated formats

Info(win,"OK","Images converted",list,,,pb)

return 1
end function


