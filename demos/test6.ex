
------------------------------------------------------------------------
--# GTK can display a variety of image types
------------------------------------------------------------------------

include GtkEngine.e

sequence images = { -- note the various image types being used;
    "DISKS04.ICO",
    "cow2.jpg",
    "BabyTux.bmp",
    "giraffe.xpm",
    "applications-development.svg",
    "bug-buddy.png",
    $
    }

sequence path = canonical_path("~/demos/thumbnails/") -- where to find 'em
    
-- Next we replace each filename in the images sequence 
-- with a pointer to the pixbuf created by loading that file,
-- thus saving space by re-using the same variable.

for i = 1 to length(images) do
    images[i] = create(GtkImage,path & images[i]) 
end for

constant -- build an interface;
    win = create(GtkWindow,"title=Images,border=10,position=1,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"), -- spacing between images;
    lbl = create(GtkLabel,"line wrap=TRUE"),
    top = create(GtkBox,"orientation=horizontal,spacing=10"), -- contains first row of images;
    bot = create(GtkBox,"orientation=horizontal,spacing=10"), -- contains second row of images;
    box = create(GtkButtonBox),
    btn = create(GtkButton,"gtk-quit","Quit")
    
    set(lbl,"markup",docs())
    pack(top,images[1..3],TRUE,TRUE,10) -- use some here
    pack(bot,images[4..$],TRUE,TRUE,10) -- the rest here
    
    add(win,pan)
    add(pan,{lbl,top,bot})
    add(box,btn)
    pack(pan,-box)

show_all(win)
main()

------------------
function docs() --
------------------
return 
`<u><b>GtkImages</b></u> are <i>very</i> easy to use! 
Formats which can be displayed without conversion include:
gif, jpg, png, bmp, svg, tif, tga, ico, pbm, pgm, pcx, xpm, etc...
`
end function
