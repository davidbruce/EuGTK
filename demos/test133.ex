
---------------------------------------------------------
--# Different way to markup and display text;
---------------------------------------------------------

include GtkEngine.e

constant win = create(GtkWindow,"size=300x100,border=20,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
	add(win,panel)

constant lbl = create(GtkLabel)
	add(panel,lbl)

	set(lbl,"markup",
	"<span face='Purisa' weight='bold' size='48000'" &
	"foreground='goldenrod' background='sea green'>" &
	"Hello<i>!</i></span>")

show_all(win)
main()

-- Note: font size is in 1024ths of a point 
