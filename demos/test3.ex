
--# Simple ListView - formatting values, sorting, re-ordering, tooltips

include GtkEngine.e

constant fruits = { -- name, qty, price, tooltip;
	{"Apples",		"doz",	3.50,	"Mackintosh"},
	{"Cherries",   "lb",	2.69,	"Bing"},
	{"Dates",		"lb",	6.99,	"Medjool"},
	{"Limes",		"ea",	 .59,	"Key"},
	{"Oranges",		"ea",	 .79,	"Valencia"},
	{"Bananas",		"lb",	 .89,	"Dole"},
	$}
	
constant 
	win = create(GtkWindow,"border=10,size=350x320,$destroy=Quit"),
	pan = create(GtkBox,"orientation=vertical,spacing=10"),
	lbl = create(GtkLabel,"text=Double-click an item\nClick header to sort"),
	scrol = create(GtkScrolledWindow),
	box = create(GtkButtonBox),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-ok",_("ShowChoice")),
	
	store = create(GtkListStore,{gSTR,gSTR,gSTR,gSTR}), -- match with data;
	
	tv = create(GtkTreeView,{-- this is the container for the list
	{"reorderable",TRUE}, 	    -- can rearrange columns;
	{"headers clickable",TRUE},  -- can sort by clicking on header button;
	{"set grid lines",GTK_TREE_VIEW_GRID_LINES_BOTH}, -- appearance;
	{"rules hint",TRUE},  -- 'shaded' alternate rows (if window theme allows)
	{"tooltip column",4}, -- column 4 contains the tips;
	{"connect","row-activated",_("ShowChoice")}}), -- when double-click on row;

	selection = get(tv,"selection"), -- this 'tracks' the current selection;

	col1 = create(GtkColumn,"title=Name,type=text,text=1,sort=1"),
	col2 = create(GtkColumn,"title=Quantity,type=text,text=2"), --no sort
	col3 = create(GtkColumn,"title=Price,type=text,text=3,sort=3")

	set(store,"data",fruits)
	set(tv,"model",store)

	add(tv,{col1,col2,col3})
	add(box,{btn1,btn2})
	add(win,pan)
	pack(pan,lbl)
	add(scrol,tv)
	pack(pan,scrol,1,1)
	pack(pan,-box)
	
show_all(win)
main()

---------------------
function ShowChoice()
---------------------
object choice = get(selection,"selected row data")
 return Info(win,,text:format("[4] [1]",choice),
	format("Price: $[3:,,.2] per [2]",choice))
end function

