
---------------------------------------------------------------
--# GtkAppChooserWidget
---------------------------------------------------------------

include GtkEngine.e

-- note: appears to be a bug in Gtk14

constant docs = `markup=
<b><u>App Chooser</u></b>

Below is an app chooser widget for file types 'image/png'.
The <u>I</u>nfo button gives more info about the selected app.

`
constant 
	win = create(GtkWindow,"size=300x100,border_width=10,position=1,$destroy=Quit"),
	pan = create(GtkBox,"orientation=VERTICAL,spacing=5"),
	lbl = create(GtkLabel,docs),
	box = create(GtkButtonBox),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-info",_("GetInfo"))
	
	set(btn2,"tooltip text","Click to see a short description of this program")
	
constant appchooser = create(GtkAppChooserWidget,"image/png")
	set(appchooser,{
	  {"show default",TRUE},
	  {"show recommended",TRUE},
	  {"default text","Sorry, I don't know how to handle that type of file!"},
	  {"connect","application-activated",_("GetInfo")}})

	add(win,pan)
	add(pan,{lbl,appchooser})
	add(box,{btn1,btn2})
	pack(pan,-box)
	
show_all(win)
main()

------------------------------------------------------------------------
function GetInfo()
------------------------------------------------------------------------
object app = get(appchooser,"app info")
object name = get(app,"name")
object icon = get(app,"icon")
object descr = get(app,"description")
if atom(descr) then descr = "No description available for this item" end if
object myimg = create(GtkImage)
	set(myimg,"from gicon",icon,5)
	return Info(win,"You Chose",name,descr,,myimg)
end function


