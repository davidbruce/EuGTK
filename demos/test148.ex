
----------------------------------------------------------------------------
--# GtkCellRendererSpin
----------------------------------------------------------------------------

include GtkEngine.e

include std/convert.e

constant docs = `<u><b>Spin Control</b></u>
  Click twice on a cell in the 
  Qty. column to change the #
`
constant -- images to use in rows;
    bug = create(GdkPixbuf,"thumbnails/bug-buddy.png",25,25),
    fish = create(GdkPixbuf,"thumbnails/fish.png",55,55),
    dragon = create(GdkPixbuf,"thumbnails/dragon.png",85,85)

sequence results = {}

sequence list = { -- name, qty, image
	{"Bugs",5,bug},
	{"Fish",4,fish},
	{"Dragons",2,dragon}
	}

constant win = create(GtkWindow,"border=10,position=1,size=300x350,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
	add(win,panel)

constant lbl = create(GtkLabel)
	set(lbl,"markup",docs)
	pack(panel,lbl)
	
constant scroller = create(GtkScrolledWindow)
	pack(panel,scroller,TRUE,TRUE,10)

constant model = create(GtkListStore,{gSTR,gINT,gPIX})
	set(model,"data",list)

constant view = create(GtkTreeView,{
	{"grid lines",GTK_TREE_VIEW_GRID_LINES_BOTH},
	{"model",model}})
	add(scroller,view)

constant selection = get(view,"selection")

constant renderer1 = create(GtkCellRendererText)
constant column1 = create(GtkTreeViewColumn,{
	{"title","Name"},
	{"pack start",renderer1},
	{"add attribute",renderer1,"text",1},
	{"sort column id",1}})

constant adj = create(GtkAdjustment,0,0,100,1,10,0)

constant renderer2 = create(GtkCellRendererSpin,{
	{"property","editable",TRUE},
	{"property","adjustment",adj}})

constant column2 = create(GtkTreeViewColumn ,{
	{"title","Qty"},
	{"pack start",renderer2},
	{"add attribute",renderer2,"text",2},
	{"min width",100}})
	connect(renderer2,"edited",_("QtyChanged"))
	
constant renderer3 = create(GtkCellRendererPixbuf)
constant column3 = create(GtkTreeViewColumn,{
	{"title","Icon"},
	{"pack start",renderer3},
	{"add attribute",renderer3,"pixbuf",3}})
	set(view,"append columns",{column1,column2,column3})

constant btn1 = create(GtkButton,"gtk-quit","Quit")
constant btn2 = create(GtkButton,"gtk-ok",_("ShowItems"))
constant box = create(GtkButtonBox)
	add(box,{btn1,btn2})
	pack(panel,-box)

show_all(win)
main()

------------------------------------------------------
function QtyChanged(atom ctl, atom path)
------------------------------------------------------
integer row = get(selection,"selected row")
    set(model,"col data",row,2,get(adj,"value"))
return 1
end function

------------------------------------------------------
function ShowItems() 
------------------------------------------------------
results = get(model,"data")

object text = ""
for i = 1 to length(results) do
    text &= format("[] []\n",{results[i][2],results[i][1]})
end for

Info(win,,"Inventory",text)
return 1
end function




