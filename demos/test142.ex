
--------------------------------------------------------------------------
--# GtkScale with fill level and 'tick' marks
--------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<b><u>Fill Level</u></b>
You can set a fill level, which the scale can or cannot exceed, 
with or without a visual indication.`

constant win = create(GtkWindow,"size=300x100,border=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
	add(win,panel)

constant scale = create(GtkScale,{
	{"orientation",HORIZONTAL},
	{"range",0,100},
	{"show fill level",TRUE}, 
	{"fill level",66}})
	add(panel,scale)

for i = 0 to 100 by 10 do
	set(scale,"add mark",i,GTK_POS_BOTTOM,sprintf("<small>%d</small>",i))
end for

for i = 5 to 100 by 10  do
        set(scale,"add mark",i,GTK_POS_BOTTOM,"")
end for

constant lbl = create(GtkLabel,{
	{"markup",docs},
	{"margin top",5}})
	add(panel,lbl)

show_all(win)
main()

