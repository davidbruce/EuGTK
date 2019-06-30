
------------------------------------------------------------------------------------------------
--# AppChooserDialog

-- This shows associations.
-- It would normally be used within your program to
-- choose your preferred helper app(s).
------------------------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>AppChooserDialog</b></u>

Show available apps to handle a given file or
a given file type e.g. "text/plain"
`
constant 
    win = create(GtkWindow,"size=300x100,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    img = create(GtkImage),
    lbl = create(GtkLabel)
    
    set(lbl,"markup",docs)
    add(win,panel)
    add(panel,lbl)

sequence ck = {0}
    ck &= create(GtkRadioButton,0,"image/png")
    ck &= create(GtkRadioButton,ck,"text/plain")
    ck &= create(GtkRadioButton,ck,"text/html")
    ck &= create(GtkRadioButton,ck,"text/bogus")
    add(panel,ck)

constant btnbox = create(GtkButtonBox,"margin-top=10")
    pack(panel,-btnbox)

constant
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok",_("ShowHandler"))
    add(btnbox,{btn1,btn2})

show_all(win)
main()

------------------------------------------------------------------------
function ShowHandler()
------------------------------------------------------------------------
atom info, icon
object name

for i = 1 to length(ck) do
	if get(ck[i],"active") then
		name = get(ck[i],"label")
	end if
end for

object descr
atom appdlg = create(GtkAppChooserDialog,win,GTK_DIALOG_MODAL,name)
    set(appdlg,"heading","Choose an App!")

 -- some options can be set by retrieving the underlying appwidget;
    atom appwid = get(appdlg,"widget")

  --here are some others you might try;
    --set(appwid,"show default",FALSE)
    --set(appwid,"show recommended",FALSE)
    --set(appwid,"show fallback",TRUE)
    --set(appwid,"show other",FALSE)
    
  --line below replaces default "no apps available" error text;
    --set(appwid,"default text"," You are SOL!"

    if get(appdlg,"run") = MB_OK then
	info = get(appdlg,"app info")
	icon = get(info,"icon")
	name = get(info,"display name")
	descr = get(info,"description")
	set(img,"from gicon",icon,GTK_ICON_SIZE_DIALOG)
	set(lbl,"markup",sprintf("<b>%s</b>\n%s\n",{name,descr}))
    end if

    set(appdlg,"destroy")

return 1
end function
-->
