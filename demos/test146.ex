
----------------------------------------------------------------------------
--# GtkEntry - text selection, selection bounds
----------------------------------------------------------------------------

include GtkEngine.e
include euphoria/info.e

constant docs = `<u><b>Text Selection</b></u>
Highlight some text, then click OK
`
constant win = create(GtkWindow,"position=1,border=10,size=380x160,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL,spacing=10")
	add(win,panel)

constant ed = create(GtkEntry,{
	{"text","Now is the time for all good men..."},
	{"activates default",TRUE}}) -- allow <enter> key to activate OK btn;
	pack(panel,ed,TRUE,TRUE)

constant lbl2 = create(GtkLabel)
	set(lbl2,"markup",docs)
	add(panel,lbl2)

constant clicked = call_back(routine_id("Clicked"))

constant box = create(GtkButtonBox)
constant btn1 = create(GtkButton,"gtk-quit","Quit")
constant btn2 = create(GtkButton,"gtk-ok",clicked)

    set(btn2,"can default",TRUE) -- allow OK btn to be a default btn
    set(win,"default",btn2) -- tell window that OK btn is the default
    add(box,{btn1,btn2})
    pack(panel,-box)

show_all(win)
main()

--------------------
function Clicked()
--------------------
integer start, fini
object tmp = get(ed,"selection bounds")
integer position = get(ed,"position")

if sequence(tmp) then
    start = tmp[1] fini = tmp[2]
    sequence selected_chars = get(ed,"chars",start,fini)
    set(lbl2,"markup",
	sprintf("Position: %d, start %d, fini %d\nSelected text: <span color='blue'>%s</span>",
	    {position,start,fini,selected_chars}))
else
    set(lbl2,"text",sprintf("position: %d, none selected",position))
end if

return 1
end function


