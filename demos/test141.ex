
-----------------------------------------------------------------
--# Stock Icons from Theme
-----------------------------------------------------------------

include GtkEngine.e

constant docs = `<b><u>Stock Icons</u></b>

Change window manager icon themes
to see different icon styles.
`
constant 
	win = create(GtkWindow,"border_width=10,keep_above=TRUE,position=1,$destroy=Quit"),
	panel = create(GtkGrid,"row_spacing=10,column_homogeneous=TRUE"),
	sep = create(GtkSeparator),
	lbl = create(GtkLabel)
		
enum IMG, CAP
constant content = {
    {"drive-harddisk","Hard disk"},
    {"dialog-information","Gtk Info"},
    {"document-save","Gtk Document Save"}
}

for i = 1 to length(content) do
    set(panel,"attach",create(GtkImage,content[i][IMG],100),0,i,1,1)
    set(panel,"attach",create(GtkLabel,content[i][CAP]),1,i,1,1)
end for

	add(win,panel)
    set(panel,"attach",sep,0,4,2,1)
    set(lbl,"markup",docs)
    set(panel,"attach",lbl,0,5,2,1)

show_all(win)
main()

