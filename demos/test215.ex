
--# FileChooserNative demo <span color='red'>requires GTK 3.20</span>

include GtkEngine.e

requires("3.20","GtkFileChooserNative")

constant docs = `markup=
<b>Native File Chooser</b>

This uses Windows' file chooser rather than
the GTK3 file chooser, when run on Windows.

On Linux, this only uses the native file 
chooser if the GTK version is 3.20 or higher.

`
constant 
    win = create(GtkWindow,"title=Native File Chooser,size=300x200,border=10,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL),
    lbl = create(GtkLabel,docs),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","OpenFile")

    add(win,panel)
    add(panel,lbl)
    add(box,{btn1,btn2})
    pack(panel,-box)
    
show_all(win)
main()

---------------------------
global function OpenFile()
---------------------------
atom fc = create(GtkFileChooserNative,
    "Open File",win,GTK_FILE_CHOOSER_ACTION_OPEN,"OK","Cancel")
	run(fc)
object fname = get(fc,"filename")
	if file_exists(fname) then
		Info(win,,fname)
	end if
return 1
end function
