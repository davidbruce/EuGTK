
------------------------------------------------------------------------
--# displays the x-color names and samples;
------------------------------------------------------------------------

include GtkEngine.e
include std/io.e

constant xcolors = canonical_path("~/demos/resources/xcolors.txt")

constant win = create(GtkWindow,{
    {"icon","~/demos/thumbnails/preferences-color.svg"},
    {"default size",300,800},
    {"position",GTK_WIN_POS_CENTER}})
    connect(win,"destroy","Quit")

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant scroller = create(GtkScrolledWindow)
    pack(panel,scroller,TRUE,TRUE)

constant rend1 = create(GtkCellRendererText),
    col1 = create(GtkTreeViewColumn,{
    {"pack start",rend1},
    {"title","Name"},
    {"sort column id",1},
    {"add attribute",rend1,"text",1}})

constant rend2 = create(GtkCellRendererText),
    col2 = create(GtkTreeViewColumn,{
    {"pack start",rend2},
    {"title","Color (HEX)"},
    {"sort column id",2},
    {"add attribute",rend2,"text",2},
    {"add attribute",rend2,"background",1}})
    
constant rend3 = create(GtkCellRendererText)
    set(col2,"pack end",rend3)
    set(rend3,"foreground","white")
    set(col2,"add attribute",rend3,"background",1)
    set(col2,"add attribute",rend3,"text",3)

constant store = create(GtkListStore,{gSTR,gSTR,gSTR})

sequence names = read_lines(xcolors)
object x,  hexcolor
for i = 1 to length(names)  do
    x = to_rgba(names[i])
    hexcolor = from_rgba(x,1)
    names[i] = {names[i], hexcolor,hexcolor}
end for
    set(store,"data",names)

constant tv = add(scroller,create(GtkTreeView,{
    {"model",store},
    {"headers clickable",TRUE},
    {"grid lines",GTK_TREE_VIEW_GRID_LINES_BOTH},
    {"append columns",{col1,col2} }}))

constant 
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-refresh","Restore")
    set(btn2,"tooltip text","Restore original (unsorted) order")

constant box = add(panel,create(GtkButtonBox,{
    {"layout",GTK_BUTTONBOX_SPREAD},
    {"margin top",10},
    {"margin bottom",10}}))
    add(box,{btn1,btn2})

show_all(win)
main()

-------------------------
global function Restore() -- returns list to original order
-------------------------
	set(store,"clear")
	set(store,"sort column id",UNSORTED)
	set(store,"data",names)
return 1
end function

