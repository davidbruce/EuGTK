
------------------------------------------------------------------------
--# Tool Palette and buttons

-- To create a button with an icon, attach the icon widget as the 
-- first parameter. Second param can be anything. 

-- Icon can be a widget you create, such as the LeftArrow below, 
-- or the name of a gtk-stock item, themed icon, etc

-- For a text button, send a null as the first parameter.
-- Second param will be the text to use.
-- Third param is the function to call when clicked, 4th is [opt] data.
 
-- Note:
-- If you set tooltip text for the ToolPalette, then you MUST set
-- tooltip text for the buttons, otherwise they display the same 
-- tooltip as the ToolPalette, which can be confusing.
-------------------------------------------------------------------------

include GtkEngine.e
include std/sort.e
include std/math.e

constant WIDTH = 300, HEIGHT = 300

chdir(canonical_path("~/demos"))

object images = 
    dir("screenshots/*.jpg") & dir("screenshots/*.gif") & dir("screenshots/*.png")
    images = sort(vslice(images,D_NAME))
    images = images[3..$]

for i = 1 to length(images) do
    images[i] = locate_file("screenshots/"& images[i])
end for

integer n = 1

constant win = create(GtkWindow,"border=10,size=500x200,position=1,icon=face-smile,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
    add(win,panel)

constant pal = create(GtkToolPalette,{ 
    {"icon size",GTK_ICON_SIZE_SMALL_TOOLBAR},
    {"orientation",VERTICAL},
    {"style",GTK_TOOLBAR_BOTH},
    {"size request",-1,100}}) -- allow room to show icons;
    add(panel,pal)

constant group = create(GtkToolItemGroup,{
    {"header relief",GTK_RELIEF_NORMAL},
    {"label","Tool Palette - click to hide/show toolbuttons"}})
    add(pal,group)
    
constant btn1 = create(GtkToolButton,{
    {"stock_id","gtk-quit"},
    {"label","Exit"},
    {"tooltip text","Click to quit"}})
    connect(btn1,"clicked","Quit")
    set(group,"insert",btn1,-1)

constant btn2 = create(GtkToolButton,
    "stock id=gtk-go-back,label=Back,tooltip_text='Previous Pix'")
    connect(btn2,"clicked",_("Go"))
    set(group,"insert",btn2,-1)

constant btn3 = create(GtkToolButton,{
    {"stock id","gtk-go-forward"},
    {"label","Fwd"},
    {"tooltip text","Next Pix"},
    {"connect","clicked",_("Go")}})
    set(group,"insert",btn3,-1)

constant btn4 = create(GtkMenuToolButton,
   "label=More...,arrow_tooltip_text='Click to open submenu'")
    set(group,"insert",btn4,-1)
    
constant submenu = create(GtkMenu), -- submenu for btn4;
    item1 = create(GtkMenuItem,"gtk-yes#Yes",,TRUE),
    item2 = create(GtkMenuItem,"gtk-no#No",,FALSE),
    item3 = create(GtkMenuItem,"gtk-quit#Quit","Bail") 
    set(submenu,"append",{item1,item2,item3})
    set(item1,"sensitive",FALSE)
    set(item2,"sensitive",FALSE)
    show_all(submenu)
    set(btn4,"menu",submenu)

    
object pix = create(GdkPixbuf,images[n],WIDTH,HEIGHT,TRUE)
object img = create(GtkImage,pix)
    add(panel,img)

constant lbl = create(GtkLabel)
    set(lbl,"text",images[n])
    pack(panel,-lbl)

show_all(win)
main()

-----------------------------------------
function Go(atom ctl, atom data)
-----------------------------------------
    switch ctl do
        case btn2 then n -= 1 
        case btn3 then n += 1 
    end switch
    if n > length(images) then n = 1 end if
    n = ensure_in_range(n,{1,length(images)})
    pix = create(GdkPixbuf,images[n],WIDTH,HEIGHT,TRUE)
    set(img,"from pixbuf",pix)
    set(lbl,"text",images[n])
return 1
end function


--------------------------
global function Bail()
--------------------------
Info(win,"Thanks!",
    "Thank you","Please come again!",,"face-smile")
    return Quit()
end function
