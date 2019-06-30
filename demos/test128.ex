
-----------------------------------------------------------------
--# GtkScale
-----------------------------------------------------------------

include GtkEngine.e

constant docs = `markup=
<u><b>GtkScale</b></u>
Use mouse scroll wheel to select.
Also try left and right mouse buttons on 
the slider bar at various places to see what happens.
`
constant 
	win = create(GtkWindow,"size=250x100,border=10,position=1,$destroy=Quit"),
	pan = create(GtkBox,"orientation=VERTICAL"),
	lbl = create(GtkLabel,docs)

constant scale = create(GtkScale,{
	{"orientation",HORIZONTAL},
	{"range",0,100},
	{"increments",12.5,25}, -- step, page
	{"digits",0},
	{"draw value",TRUE},
	{"value pos",GTK_POS_BOTTOM}})

constant caps = {"Empty","One Quarter","One Half","Three Quarters","Full"}
for i = 0 to length(caps)-1 do
	set(scale,"add mark",i*25,GTK_POS_TOP,caps[i+1])
end for
	
	add(win,pan)
	add(pan,lbl)
	pack(pan,scale,TRUE,TRUE,10)

show_all(win)
main()
