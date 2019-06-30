
------------------------------------------------------------------------------
--# GtkLabels - ellipsize, selectable properties
------------------------------------------------------------------------------

include GtkEngine.e

constant txt = `Now is the time for all good men to come to the aid of the party

Click ellipsize, and make this window smaller.
`
constant win = create(GtkWindow,"size=200x100,border_width=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
	add(win,panel)

constant lbl = create(GtkLabel,{
	{"text",txt},{"line_wrap=TRUE,width_chars=20"}})
	add(panel,lbl)

constant sep = create(GtkSeparator)
	add(panel,sep)

constant ck1 = create(GtkCheckButton,"Selectable",_("SetSelectable"))
	set(ck1,"tooltip text","Allows you to select & copy text")
	pack(panel,-ck1)

constant ck2 = create(GtkCheckButton,"Ellipsize",_("SetEllipsize"))
	pack(panel,-ck2)
	set(ck2,"margin top",5)

show_all(win)
main()

------------------------------------------------------------------------
function SetEllipsize(atom ctl)
------------------------------------------------------------------------
	set(lbl,"ellipsize",PANGO_ELLIPSIZE_END * get(ctl,"active"))
return 1
end function

------------------------------------------------------------------------
function SetSelectable(atom ctl)
------------------------------------------------------------------------
	set(lbl,"selectable",get(ctl,"active"))
return 1
end function
