
----------------------------------------------------------------
--# GtkAppChooseerButton
----------------------------------------------------------------

include GtkEngine.e

constant docs = `markup=
<b><u>App Chooser Buttons</u></b>
Shows associated apps for various file types.

This doesn't <i>change</i> the associations, 
just displays the current setting.
You change the association by changing
properties in your file manager (usually).

`
constant 
	win = create(GtkWindow,"size=300x300,position=1,border_width=10,$destroy=Quit"),
	pan = create(GtkBox,"orientation=vertical"),
	lbl = create(GtkLabel,docs),
	hr = create(GtkSeparator,"margin=10"),
	lbl1 = create(GtkLabel,"Apps for plain text files"),
	appbtn1 = create(GtkAppChooserButton,"text/plain"),
	lbl2 = create(GtkLabel,"Apps for png images:"),
	appbtn2 = create(GtkAppChooserButton,"image/png"),
	lbl3 = create(GtkLabel,"Apps for web pages:"),
	appbtn3 = create(GtkAppChooserButton,"text/html"),
	btn = create(GtkButton,"gtk-quit","Quit"),
	box = create(GtkButtonBox,"margin top=10"),
	myicon = create(GIcon,"face-cool")

	add(win,pan)
	add(pan,{lbl,hr,lbl1,appbtn1,lbl2,appbtn2,lbl3,appbtn3})
	
	set(appbtn3,{
	{"append separator"},
	{"append custom item","Foo"," BEAR - My Own Web Page Editor",myicon},
	{"connect","custom-item-activated",_("ShowDetails"),1}})
	
	pack(pan,-box)
	add(box,btn)

show_all(win)
main()

-----------------------------
function ShowDetails()
-----------------------------
return Info(win,"Foo"," BEAR ","View/Edit html and Euphoria code",,myicon)
end function
