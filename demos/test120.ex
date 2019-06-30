
-----------------------------------------------------------------
--# GtkFileChooserButton
-----------------------------------------------------------------

include GtkEngine.e

constant docs = `markup=
<b><u>GtkFileChooserButton</u></b>
a widget which can be added to 
any container to pop up a 
file-chooser dialog.
`
constant 
    win = create(GtkWindow,"size=250x125,border=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,docs),
    box = create(GtkBox,"orientation=HORIZONTAL, spacing=5"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    fcb = create(GtkFileChooserButton,"Select a file",GTK_FILE_CHOOSER_ACTION_OPEN),
    btn2 = create(GtkButton,"gtk-ok","Foo")
	
    set(fcb,"tooltip text","Click to open a file chooser dialog")
    set(btn2,"tooltip text","Click to try to open the selected file")

    add(win,panel)
    add(panel,lbl)
    pack(box,fcb,TRUE,TRUE)
    add(box,btn2)
    pack(panel,-box)
	
show_all(win)
main()

------------------------------------------------------------------------
global function Foo() --calls show_uri which handles most files
------------------------------------------------------------------------
object selected = get(fcb,"filename")

    if atom(selected) then -- directory was clicked, not a file
	return 1 
    end if
    
    if Question(win,"File Chooser",
	"Open \n" & selected,
	"with default handler?") = MB_YES then
	ifdef WINDOWS then
		system("explorer " & selected,0)
		return 1
	end ifdef
	show_uri("file://" & selected)  -- this line is all that's needed for UNIX
    end if
    
return 1
end function

