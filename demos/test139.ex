
-------------------------------------------------------------------------
--# GtkSeparator
-------------------------------------------------------------------------

include GtkEngine.e

constant txt = "<b><u>GtkSeparator</u></b>"

constant win = create(GtkWindow,"size=200x100,border=10,position=1,$destroy=Quit")

constant panel = add(win,create(GtkBox,"orientation=VERTICAL,spacing=10"))
	
add(panel,{
	create(GtkLabel,{{"markup",txt}}),
	create(GtkLabel,"This is some text"),
	create(GtkSeparator),
	create(GtkLabel,"Separator is above.")})

pack_end(panel,create(GtkButton,"gtk-quit","Quit"))

show_all(win)
main()

