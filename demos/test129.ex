
--------------------------------------------------------------------------------
--# Notebook with custom tabs
--------------------------------------------------------------------------------
-- This is demo which uses custom-designed tabs.
-- Don't think you have to do all this just to use a normal notebook widget
--------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `markup=
<u><b>Notebook with custom tabs</b></u>

In this demo the notebook tabs have a custom "delete"
button added.

Clicking on the tab title changes the notebook page
but clicking on the red stop icon calls your Eu function
which removes the page.

`
constant 
	win = create(GtkWindow,"border=10,size=300x300,position=1,$destroy=Quit"),
	pan = create(GtkBox,"orientation=VERTICAL"),
	lbl = create(GtkLabel,docs),
	sep = create(GtkSeparator,"margin=10"),
	notebook = create(GtkNotebook,"background=lightyellow,popup enable=TRUE")
	
-------------------------------
-- Build custom notebook tabs;
-------------------------------

-- read and size image for buttons;
constant stop = create(GdkPixbuf,"thumbnails/icon-stop.png",15,15)

-- create format for page contents;
constant fmt = `
This text is on page
<span font='48' color='red'>%d</span>
`
object pg = repeat(0,5), tab = pg, lab = pg, btn = pg

for i = 1 to length(pg) do
	-- create a page and add it to the notebook;
	-- notebook pages must have content (a container or other widget)
	-- or the page won't show at all!
	
	pg[i] = create(GtkBox,"orientation=vertical") -- container for page content;
	lab[i] = create(GtkLabel) -- label to hold "Page #" text
		set(lab[i],"markup",sprintf(fmt,i)) -- "This text is on page ..."
		set(lab[i],"justify",GTK_JUSTIFY_CENTER)
		add(pg[i],lab[i]) -- add to container

-- create a custom tab for the page;
	tab[i] = create(GtkBox) -- container for tab content;
	lab[i] = create(GtkLabel,sprintf("Page %d",i)) -- tab label

	-- add the stop image to a button so it's clickable;
	-- btn click is connected to RemovePage function;
		btn[i] = create(GtkToolButton,create(GtkImage,stop))
		set(btn[i],"tooltip text","Click here to remove this tab")
		connect(btn[i],"clicked","RemovePage",pg[i])

		add(tab[i],{lab[i],btn[i]}) -- add label and button to tab
		show_all(tab[i]) -- must show contents, won't show custom tabs automatically

		set(notebook,"append page",pg[i],tab[i]) -- add a page with this tab

end for

	add(win,pan)
	add(pan,{lbl,sep,notebook})
	
show_all(win)
main()

------------------------------------------------
global function RemovePage(atom ctl, object pg)
------------------------------------------------
-- we have to get the CURRENT page number assigned to pg,
-- since it changes as pages are removed (or added, reordered, etc)
pg = get(notebook,"page num",pg)
 -- current # of page, NOT the number shown on the tab!
set(notebook,"remove page",pg) -- get rid of it 
return 1
end function
