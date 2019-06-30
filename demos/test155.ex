
------------------------------------------------------------------------
--# Another notebook style

-- It seemed like a good idea to create the pages from a marked-up 
-- text file, which makes it much simpler and easier to modify than 
-- if it were all hard-coded. See /resources/notebook_pages.txt 
------------------------------------------------------------------------

include GtkEngine.e
include std/io.e

constant content =  locate_file("resources/notebook_pages.txt")

constant win = create(GtkWindow,
    "title=`All About Animals`,size=200x100,border=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
    add(win,panel)

constant book = create(GtkNotebook)
    set(book,"tab pos",GTK_POS_RIGHT)
    add(panel,book)

------------------------------------------------------------------------
-- Load text file and filter out comments and other garbage;
------------------------------------------------------------------------
object pgs = split(read_file(content),"\n\n")

for i = 1 to length(pgs) do 
 -- filter out comments
	if begins("--",pgs[i]) then 
	    pgs[i] = "" 
	else
	    pgs[i] = keyvalues(pgs[i],';','=',"\"","\t")
	    -- filter out random (non-keyed) garbage
	    if sequence(vlookup("p[1]",pgs[i],1,2,0)) then
		pgs[i] = ""
	    end if
	end if
end for
pgs = remove_all("",pgs)

------------------------------------------------------------------------
-- Build and add pages using the filtered text;
------------------------------------------------------------------------
object page = {}, lbl = "", img = 0, tab = "", note = ""

for i = 1 to length(pgs) do

    -- append a new page, starting with a plain box as base;
	page &= create(GtkBox,VERTICAL) 
	
    -- if key Title exists, use it as the tab text;
	tab = create(GtkLabel,vlookup("Title",pgs[i],1,2))
	
    -- if key Text exists, use it on a label, or use -no text found-
	lbl = create(GtkLabel) set(lbl,"font","Serif 10")
	set(lbl,"markup",vlookup("Text",pgs[i],1,2,"- no text found -"))
	
    -- if key Image exists, load and add it!
	img = create(GtkImage,locate_file(vlookup("Image",pgs[i],1,2)))
	add(page[i],{img,lbl})
	
    -- add the page to the notebook;
	set(page[i],"border_width=10,margin_top=20")
	set(book,"append page",page[i],tab)
	
end for 

-- add a 'quit' button to the notebook. note that it is not one of the tabs;
constant btn = create(GtkButton,"gtk-quit","Quit")
    set(book,"action widget",btn,GTK_PACK_END)
    show(btn)

show_all(win)
main()








