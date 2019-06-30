
---------------------------------------------------------------------------------------------------
--# GtkToolBar demo
---------------------------------------------------------------------------------------------------

include GtkEngine.e
include std/os.e

constant docs = `markup=
<u><b>GtkToolBar</b></u>
This demos different styles of toolbar.
This uses custom icons. Edit the source to change styles.
`
constant 
    quit = create(GdkPixbuf,"thumbnails/icon-stop.png",30,30),
    fish = create(GdkPixbuf,"thumbnails/fish.png",30,30),
    fox = create(GdkPixbuf,"thumbnails/fox.png",30,30),
    mouse = create(GdkPixbuf,"thumbnails/mouse.png",30,30),
    names = {"Quit","Fish","Fox","Mouse"},
    pix = {quit,fish,fox,mouse},

    win = create(GtkWindow,"size=400x80,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl1 = create(GtkLabel),
    lbl2 = create(GtkLabel,docs),
    toolbar = create(GtkToolbar) -- try one of the following:
 
    set(toolbar,"style",GTK_TOOLBAR_BOTH) -- labels and icons
 -- set(toolbar,"style",GTK_TOOLBAR_TEXT) -- to show text labels only
 -- set(toolbar,"style",GTK_TOOLBAR_ICONS) -- to show icons only, this is the default

    for i = 1 to 4 do
		add(toolbar,create(GtkToolButton,create(GtkImage,pix[i]),names[i],_("Foo"),i))
    end for

    set(lbl1,"font","Purisa, URW Chancery L, Comic Sans 36") -- choose first available.
    add(win,panel)
    pack(panel,toolbar)
    add(panel,{lbl1,lbl2})
    
show_all(win)
main()

---------------------------------------------
function Foo(atom ctl, integer n)
---------------------------------------------
	set(lbl1,"text",names[n])
	if n = 1 then sleep(1) Quit() end if
return 1
end function
