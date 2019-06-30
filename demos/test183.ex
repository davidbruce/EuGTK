
---------------------------------------------------------------------------------------------
--# GtkFontChooserWidget <span color='red'>DEPRECATED</span>
---------------------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>Font Chooser Widget</b></u>
Add to your own window or custom dialog.
Most often, however, you'll use a pop-up FontChooserDialog instead.
`
constant win = create(GtkWindow,
	"size=300x300,border=10,background=CornSilk,position=1,$destroy=Quit")

constant panel = create(GtkBox,VERTICAL)
	add(win,panel)

constant fcw = create(GtkFontChooserWidget,"margin_right=100,margin_bottom=100")
	pack(panel,fcw)

constant lbl = create(GtkLabel)
	add(panel,lbl)
	set(lbl,"markup",docs)

constant btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-ok","GetFont"),
	box = create(GtkButtonBox)
	add(box,{btn1,btn2})
	pack(panel,-box)

show_all(win)
main()

---------------------------
global function GetFont()
---------------------------
return Info(win,"Font Chooser","You selected font",get(fcw,"font"))
end function
