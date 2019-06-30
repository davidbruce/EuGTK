
------------------------------------------------------------------------
--#  Setting background colors - links don't work on Windows.
------------------------------------------------------------------------

include GtkEngine.e
include std/net/url.e

constant helpfile = "file://" & canonical_path("~/demos/documentation/HowItWorks.html#colors")

constant docs = sprintf(`<u><b>Random Colors</b></u>
Click the refresh button to choose
a new color. See <a href='%s'>%s</a> for more info.
`,
{helpfile,"Colors"})

constant 
    win = create(GtkWindow,"title=`Random Colors`,size=250x150,border=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL),
    lbl = create(GtkLabel),
    img = create(GtkImage,"thumbnails/tiphat1.gif"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-refresh",_("RandomColor"))
    
    add(win,panel)
    add(box,{btn1,btn2})
    add(panel,{lbl,img,box})
    
    set(lbl,"markup",docs)
    set(btn2,"tooltip text","Click for random color")

show_all(win)
main()

----------------------------------------------
function RandomColor()
----------------------------------------------
object randy = rand(#ffffff)
    set(win,"background",randy) 
    set(win,"title",sprintf("#%06x",randy))
return 1
end function
 
-- In this demo, we set the color in numeric (hex) form,
-- because rand() can do this for us very easily.
-- then we convert it to string form to display on titlebar


