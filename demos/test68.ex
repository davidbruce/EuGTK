
---------------------------------------------------------------
--# Locale (problematical)
---------------------------------------------------------------

include GtkEngine.e

-- following only works if you have spanish language selected;
 
include std/locale.e 
object lang = "es_ES.iso885915@euro"

if locale:set(lang) = 0 then
    Warn(0,,"Sorry, unable to load",lang) 
end if

constant 
    win = create(GtkWindow,"size=300x100,position=1,$destroy=Quit"),
    panel = create(GtkBox,"border_width=10,spacing=10,orientation=vertical"),
    lbl = create(GtkLabel,"markup=<b><u>Locale</u></b> \n" &
	"The button captions should change to Spanish \n" &
	"if you have the proper language support installed.\n\n" &
	"If not see ~/demos/examples/misc/initest2.ex\n" &
	"for another way.\n"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok")

    add(win,panel)
    add(panel,lbl)
    add(box,{btn1,btn2})
    pack(panel,-box)
    
show_all(win)
main()




