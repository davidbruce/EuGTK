
---------------------------------------------------------------------------
--# GtkAppChooserWidget
---------------------------------------------------------------------------

include GtkEngine.e	

sequence docs = `markup=<b><u>App Chooser Widget</u></b>

Displays default app, recommended apps, and 
others, if requested, for files of a given type.
Choose types below.

`
ifdef WINDOWS then
    Warn(,"Notice","Windows Users",
		"Windows doesn't handle mime types correctly.\nDon't expect this to work!")

end ifdef

constant ctypes = {
    "text/plain",
    "text/html",
    "image/gif",
    "inode/directory",
    "application/pdf",
    "application/x-compressed-tar",
$}

object content_type = ctypes[1]

constant 
    win = create(GtkWindow,"size=200x100,border=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL,spacing=5"),    
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btnbox = create(GtkButtonBox),
    combo = create(GtkComboBoxText,
	"tooltip text=Drop down list of content types,$changed=UpdateContentType")
	
    add(combo,ctypes)

object chooser = create(GtkAppChooserWidget,content_type) -- can't be a constant

    add(win,panel)
    add(panel,chooser)
    pack_end(panel,btnbox)
    add(btnbox,{btn1,combo})

show_all(win)
    
set(combo,"active",1) -- must delay setting combo until chooser is instantiated;
    
UpdateContentType() 

-- Line above is a hack to remove the shadowy "no applications found" 
-- overlay which appears when using GTK3.14, even if apps are found.
-- That is probably a bug in the GTK3.14 version of the app chooser,
-- doesn't show up in GTK3.16+
	
main()

------------------------------------
global function UpdateContentType()
------------------------------------
content_type = get(combo,"active text")
    set(chooser,"destroy") -- get rid of the old one;
    chooser = create(GtkAppChooserWidget,content_type) -- create new with new content-type;
    set(chooser,"show other",TRUE)
    set(chooser,"default text",sprintf("Sorry, can't find an app for %s",{content_type}))
    show(chooser)
    add(panel,chooser)
return 1
end function








