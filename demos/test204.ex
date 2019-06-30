
---------------------------------------------------------------------------------------
--# We can add more than one cell renderer to a ListView cell,
-- perhaps not normally a great idea, but it works here,
-- allowing us to use a single colunm to display either an 
-- image, a text caption, or both.
---------------------------------------------------------------------------------------

include GtkEngine.e
include std/io.e
include std/map.e -- requires use of gtk: namespace
include std/filesys.e
include std/console.e
include std/convert.e

constant docs = `<u><b>ListView</b></u>
This one packs both a pixbuf 
and text into a single cell.
Not always very useful, but 
just to prove it can be done...
`
-- create an array of filenames;

sequence animals = {"dragon","fish","fox","mouse"}

object path = pathname(canonical_path(locate_file("~/demos/thumbnails/fox.png")))
path &= "/%s.png"

enum NAME, IMG

for i = 1 to length(animals) do 
	animals[i] = {
		proper(animals[i]),
		create(GdkPixbuf,sprintf(path,{animals[i]}),30,30,1)
		}
end for

constant 
	win = create(GtkWindow,"size=200x300,border=10,position=center,$destroy=Quit"),
	panel = create(GtkBox,VERTICAL),
	lbl = create(GtkLabel,{{"markup",docs}}),
	scroller = create(GtkScrolledWindow)
	
constant store = create(GtkListStore,{gSTR,gPIX})
	
constant rend1a = create(GtkCellRendererText),
	 rend1b = create(GtkCellRendererPixbuf),
	 col1 = create(GtkTreeViewColumn)
	
	set(col1,"pack start",rend1a)
	set(col1,"pack end",rend1b)
	set(col1,{
	    {"title","Animal"},
	    {"add attribute",rend1a,"text",1},
	    {"add attribute",rend1b,"pixbuf",2},
	    {"sort column id",1}})

constant tv  = create(GtkTreeView,{
	{"model",store},
	{"reorderable",TRUE},
	{"headers clickable",TRUE},
	{"rules hint",TRUE},
	{"grid lines",GTK_TREE_VIEW_GRID_LINES_BOTH},
	{"margin bottom",10},
	{"append columns",{col1}}})
	connect(tv,"row-activated","ShowAnimal")
	
	add(scroller,tv)
	set(store,"data",animals)

constant selection = gtk:get(tv,"selection") 
	set(selection,"mode",GTK_SELECTION_SINGLE)
	
	add(win,panel)
	pack(panel,scroller,TRUE,TRUE)
	pack(panel,-lbl)
	
show_all(win)
main()

-----------------------------
global function ShowAnimal()
-----------------------------
object row = gtk:get(selection,"selected row")
object rowdata = gtk:get(store,"row data",row)
set(win,"icon",rowdata[IMG])
Info(win,,rowdata[NAME],,,rowdata[IMG],rowdata[IMG])
return 1
end function


