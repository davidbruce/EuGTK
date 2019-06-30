
-----------------------------------------------------------------
--# GtkComboBox with images
-----------------------------------------------------------------

include GtkEngine.e

constant docs = 
"<u><b>GtkComboBox</b></u>\n" &
"with a little work, you can add images" & 
"to a combo!\n" &
"Click on the dotted line to 'tear-off' a menu!"

-- We have to use the GtkComboBox, rather than the simpler
-- GtkComboBoxText, because we're adding an image to each

enum NAME,PIX

constant items = {
	{"Fish",create(GdkPixbuf,"thumbnails/fish.png",30,30)},
	{"Fox",create(GdkPixbuf,"thumbnails/fox.png",30,30)},
	{"Mouse",create(GdkPixbuf,"thumbnails/mouse.png",30,30)}
}

constant 
	win = create(GtkWindow,"size=200x100,border_width=10,position=1,$destroy=Quit"),
	panel = create(GtkBox,"orientation=VERTICAL"),
	lbl = create(GtkLabel),

	mdl = create(GtkListStore,{gSTR,gPIX}),
	renderer1 = create(GtkCellRendererText),
	renderer2 = create(GtkCellRendererPixbuf),

	combo = create(GtkComboBox,{
	{"model",mdl},
	{"pack start",renderer1,TRUE},
	{"add attribute",renderer1,"text",1},
	{"pack start",renderer2,TRUE},
	{"add attribute",renderer2,"pixbuf",2},
	{"active",1},
	{"connect","changed","UpdateTitleBar"}})
	
	set(lbl,"markup",docs)
	set(mdl,"data",items)
	set(combo,"active",1)
	add(win,panel)
	add(panel,lbl)

-- try this, but note that tearoffs are deprecated as of GTK3.10
    set(combo,"add tearoffs",TRUE)
    set(combo,"title","Animals")

-- or this:
-- set(combo,"wrap width",2) 

    add(panel,combo)

show_all(win)
main()

-----------------------------------------
global function UpdateTitleBar(atom ctl)
-----------------------------------------
integer x = get(ctl,"active") 
    set(win,"title",items[x][NAME])
    set(win,"icon",items[x][PIX])
return 1
end function
