
----------------------------------------------------------------------------
--# Using theme icons at large sizes;
-- If the size doesn't exist, this should fall back to the closest
-- size that is available.
-- While you can specify an 'odd' size, such as 210px, it's better to 
-- stick to the default sizes: 8, 16, 22, 24, 32, 48, 128, 256, 512 pixels
-- Look for these icon folders in /usr/share/icons/* 
----------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>Theme Icons</b></u>
	Using icons at specified sizes. Path to icon 
	file used will be shown at bottom.
`
constant 
	win = create(GtkWindow,"border=10,$destroy=Quit"),
	panel = create(GtkBox,"orientation=VERTICAL"),
	lbl1 = create(GtkLabel,{{"markup",docs}}),
	lbl2 = create(GtkLabel), -- display the location of the icon image file;

    -- we need to do the following in order to get the icon's file location;
	-- if we didn't need that, we could just: create(GtkImage,"face-glasses",256)
	
	theme = create(GtkIconTheme), -- get current theme;
	icon_info = get(theme,"lookup icon","face-glasses",256), -- get icon details;
	face = get(icon_info,"load icon"), -- load selected icon;
	img = create(GtkImage,face) -- convert into an image;
	
	set(lbl2,"markup",
		format("<b>File location:</b>\n[]",
		{get(icon_info,"filename")}))

add(win,panel)
add(panel,{lbl1,img})
pack(panel,-lbl2) 

show_all(win)
main()
