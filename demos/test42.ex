
-----------------------------------------------------------------------------
--# GtkNotebook; shows how to create various tabs and pages
-----------------------------------------------------------------------------

include GtkEngine.e

atom a = 0 -- angle of rotation;

constant 
    win = create(GtkWindow,"size=400x300,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    top = create(GtkBox,"orientation=horizontal"),
    img = create(GtkImage,"thumbnails/notebook.png"),
    lbl1 = create(GtkLabel,"markup=<b><u>GtkNotebook</u></b>\n\tTab 1 is default ~ 2 and 3 are custom"),
    sep = create(GtkSeparator),
    notebook = create(GtkNotebook)

    add(win,panel)
    pack(panel,top)
    add(top,{img,lbl1})
    add(panel,{sep,notebook})

-- first page is the normal style, using the default tab style;
constant pg1 = create(GtkBox,"orientation=VERTICAL,border=10") --[1]
    set(notebook,"append page",pg1)
    add(pg1,create(GtkImage,"thumbnails/mongoose.png"))
    add(pg1,create(GtkImage,"thumbnails/eugtk.png"))
    add(pg1,create(GtkLabel,
    "The GtkNotebook widget is a GtkContainer whose children \n" &
    "are pages that can be switched between using tab labels \n" &
    "along one edge."))

-- second page has a custom tab;
constant pg2 = create(GtkBox,"orientation=VERTICAL,border=10"),
    tab2 = create(GtkLabel,"markup=<i><b>LGPL</b></i>") --[2]
    set(tab2,"tooltip text","Lesser General Public License")
    set(notebook,"append page",pg2,tab2) 
    add(pg2,create(GtkLabel,LGPL))

-- third page adds an image to the tab
constant pg3 = create(GtkBox,"orientation=VERTICAL,border=10"),
    tabpix = create(GtkImage,"thumbnails/4_rhombuses.gif"), --[3]
    input = create(GtkEntry,"text=Just some random text here ...")
    set(tabpix,"tooltip text","Page of animations")
    set(notebook,"append page",pg3,tabpix) 
    add(pg3,create(GtkImage,"thumbnails/dino_slo.gif"))
    add(pg3,input)
    add(pg3,create(GtkCheckButton,"_Click me to stop the insanity",_("Stop")))

constant lbl3 = create(GtkLabel,
 "text='Put anything you \n  want in a tab!',font=bold 10")
    add(pg3,lbl3)
    
constant btnbox = create(GtkButtonBox)
    add(btnbox,create(GtkButton,"gtk-quit","Quit"))
    pack(pg3,-btnbox)

constant tick = create(GTimeout,5,_("Rotate"))
boolean rotation = TRUE

show_all(win)
main()

-----------------
function Rotate()
-----------------
set(lbl3,"angle",a)
a -= rotation
return 1
end function

-----------------------
function Stop(atom ctl)
-----------------------
rotation = not get(ctl,"active")
return 1  
end function

-- Notes:

-- [1] Each page must start with some kind of container;  
--     GtkBox or a GtkFrame are the usual choices.

-- [2] If no tab label is set, then 'Page n' will be shown on the tab,
--     where n is the pg number.

-- [3] If a tab object is supplied, that will be shown on the tab, instead of 'Page n'
--     Tab object can be almost any kind of Gtk widget, including animated gifs.
