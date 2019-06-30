
------------------------------------------------------------------------
--# GtkLayout; position widgets manually
------------------------------------------------------------------------
-- Not recommended for most programs, since this doesn't
-- follow changes to the window dimensions, but might be useful 
-- for overlaying items as shown here.
------------------------------------------------------------------------

include GtkEngine.e

constant 
	win = create(GtkWindow,"size=380x380,border_width=10,position=1,$destroy=Quit"),
	panel = create(GtkBox,"orientation=VERTICAL"),
	info = create(GtkLabel,"margin-top=10,markup=`This uses the <b><u>GtkLayout</u></b> to position items."),
	layout = create(GtkLayout),
	img1 = create(GtkImage,"thumbnails/jeff.jpg"),
	img2 = create(GtkImage,"thumbnails/icon-start.png"),
	lbl = create(GtkLabel,"markup=Hello, ET?☎,font=Sans Bold 18"),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkToggleButton,"☎ Talk",_("Move")),
	box = create(GtkButtonBox)
    
	add(win,panel)
	add(panel,info)
	pack(panel,layout,TRUE,TRUE,10)
	set(layout,"put",img1,10,10)
	set(layout,"put",img2,200,180)
	set(layout,"put",lbl,20,10)
	add(box,{btn1,btn2})
	pack(panel,-box)

show_all(win)
main()

---------------------------------
function Move(atom ctl)
---------------------------------
if get(ctl,"active") then
	set(layout,"move",img2,140,110)
	set(btn2,"label","☎ Listen")
else
	set(layout,"move",img2,200,180)
	set(btn2,"label","☎ Talk")
end if
return 1
end function

