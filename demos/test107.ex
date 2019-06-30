
--# Passing formatting data attached to buttons

include GtkEngine.e

constant n = 12.345

constant x = _("X")

constant docs = `<b><u>Sending Formatting data</u></b>
We can attach formatting data to controls and 
it will be sent to our user-written routine.`

constant 
    win = create(GtkWindow,"size=300x100,position=1,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl1 = create(GtkLabel,{{"markup",docs}}),
    sep = add(panel,create(GtkSeparator,"margin_top=5,margin_bottom=5")),
    lbl2 = create(GtkLabel,sprintf("%g",n)),
    box = create(GtkButtonBox)
    add(box,
	{create(GtkButton,"Dollar",x,"$%2.2f"),
	 create(GtkButton,"Integer",x,"%d"),
	 create(GtkButton,"Hex",x,"#%06x"),
	 create(GtkButton,"gtk-revert-to-saved",x,"%g")})

    add(win,panel)
    add(panel,{lbl1,sep,lbl2})
    pack(panel,-box)
    
show_all(win)
main()

------------------------------------------------------------------------
function X(atom ctl, object fmt)
------------------------------------------------------------------------
    fmt = unpack(fmt)
    set(lbl2,"markup",sprintf(fmt,{n}))
return 1
end function
