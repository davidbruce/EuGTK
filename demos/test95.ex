
-------------------------------------------------------------------------------
--# GtkLabels with links to other resources
-------------------------------------------------------------------------------

include GtkEngine.e

constant win = create(GtkWindow,"size=300x100,border_width=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
    add(win,panel)

constant lbl = create(GtkLabel)
    set(lbl,"markup",
    sprintf(`
_____<b><u>Label with link</u></b>
     For valuable advice,<a href='FILE://%s'> click here</a>
     `,
	{canonical_path(locate_file("thumbnails/cow2.jpg"))}))
    add(panel,lbl)

ifdef WINDOWS then
	add(panel,create(GtkLabel,"color='red',text=`Sorry, doesn't work on Windows!`"))
end ifdef
	
constant btn1 = create(GtkButton,"gtk-quit","Quit")

constant btnbox = create(GtkButtonBox)
    pack(panel,-btnbox)
    add(btnbox,btn1)
	
show_all(win)
main()




