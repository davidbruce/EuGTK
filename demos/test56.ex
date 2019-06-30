
------------------------------------------------------------------
--# GtkVolumeButton
------------------------------------------------------------------

include GtkEngine.e

-- Pop-up slider to change sound volume. Shows a speaker icon 
-- which varies its appearance corresponding to the volume setting.
-- This demo is <i>not</i> connected to the computer's sound system,
-- so will not actually change the volume.

constant 
	win = create(GtkWindow,"size=300x100,border_width=10,position=1,keep above=1,$destroy=Quit"),
	panel = create(GtkBox,"orientation=VERTICAL"),
	img = create(GtkImage,"thumbnails/emblem-sound.png"),
	lbl = create(GtkLabel,"markup=<b><u>GtkVolumeButton</u></b>\n(Not connected to sound system)"),
	box = create(GtkButtonBox),
	btn = create(GtkVolumeButton,"size=5,value=.5,$value-changed=Update")
	
	add(win,panel)
	add(panel,{img,lbl})
	add(box,btn)
	pack(panel,-box)
	
show_all(win)
main()

------------------------------------------------
global function Update()
------------------------------------------------
	printf(1,"%2.2f\n",get(btn,"value"))
return 1
end function

