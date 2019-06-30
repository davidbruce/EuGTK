
------------------------------------------------------------------------
--# GtkListView demo - gaudy, but shows most all functions
--
-- LOOKS COMPLICATED, but not really so bad, since I have used 
-- a lot more features than would normally be used, just for
-- demo purposes. See test3 for a simpler demo.
--
-- Study it, you'll see how to accomplish almost anything with
-- simple functions which should be familiar to Euphorians.
------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>GtkListView</b></u>
    This demos creating and retrieving data from a listview.
    The list can be rearranged by dragging a veggie up or down 
    the list. Double-click a row, or select one or more, then 
    click buttons at bottom.
`
enum NAME,PREP,MG,MDR,COLOR,NOTE

sequence veggies = { -- a totally bogus list of food values; 
    {"Broccoli",			"raw",		43,		64,	"green"},
    {"Cabbage",				"boiled",	103,	16,	"cyan"},
    {"<b>Beet</b> greens",	"boiled",	164,	72,	"red"},
    {"<i>Swiss Chard</i>",	"sauteed",	102,	50,	"green"},
    {"Collards",			"boiled",	266,	10,	"skyblue"},
    {"Asparagus",			"steamed",	23,		18,	"yellow"},
    {"Onions",				"raw",		10,		34,	"white"}
}

constant -- extra non-veggie selections (used later)
    Steak = 	{"Steak",		"Grilled",	2,	3,	"#FEC277"},
    Chicken = 	{"Chicken",		"Grilled",	2,	3,	"#FE4377"},
    Duck =		{"Duck",		"Roasted",	22,	4,	"#FE4342"},
    Pie =		{"Apple Pie",	"Baked",	0,	0,	"pink"},
    Pudding =   {"Possum Pudding","Baked",	155,90,	"limegreen"}
    
------------------------------------------------------------------------
-- Create a model and store the veggies in it;
------------------------------------------------------------------------
object store = create(GtkListStore,{gSTR,gSTR,gINT,gINT,gSTR})
    set(store,"data",veggies)

------------------------------------------------------------
-- Create the view, and set appearance
------------------------------------------------------------
constant tv  = create(GtkTreeView,{ 
    {"model",store},
    {"reorderable",TRUE},
    {"headers clickable",TRUE},
    {"rules hint",TRUE},
    {"grid lines",GTK_TREE_VIEW_GRID_LINES_BOTH},
    {"margin left",10},
    {"margin right",10},
    {"margin bottom",10},
    {"rubber banding",TRUE}})
    
constant -- columns (don't really need to set all these properties, this is gaudy!)
    col1 = create(GtkColumn,"title=Name,name=col1,type=text,markup=1,background=5"),
    col2 = create(GtkColumn,"title=Prep,name=col2,type=text,text=2,editable=1"),
    col3 = create(GtkColumn,"title=Ounces,name=col3,type=text,text=3,xalign=1"),
    col4 = create(GtkColumn,"title=%MDR of a totally bogus food value,name=col4,type=progress,value=4,sort=4")
    set(tv,"append columns",{col1,col2,col3,col4})
    connect("col2.renderer","edited","EditValue")
    set("col3.renderer","background","skyblue")
    
constant selection = get(tv,"selection") 
    set(selection,"mode",GTK_SELECTION_MULTIPLE)

-- to catch a double-click:
   connect(tv,"row-activated",call_back(routine_id("ShowSelected")))

   -- note that double-clicking is not completely compatible with editable rows,
   -- as the same double click can either initiate editing or call the callback,
   -- which can be confusing. A pop-up menu on right button click with an "edit"
   -- option might be better in this case.
  
----------------------------------------------------------
-- Create main window and run the program;
----------------------------------------------------------
constant win = create(GtkWindow,
    "title=`List View`,size=400x460,border_width=8,keep above=1")
    connect(win,"destroy","Quit")

constant panel = add(win,create(GtkBox,VERTICAL))
constant lbl = add(panel,create(GtkLabel,{{"markup",docs}}))

constant scroller = create(GtkScrolledWindow)
    pack(panel,scroller,TRUE,TRUE)
    add(scroller,tv)
    
-- Enable the following if you want a permanently visible search box:
-- Otherwise, ctl-f will pop up a search box
/*
constant srch = create(GtkEntry)
    pack(panel,srch)
*/

---------------------------------
function NewBtn(object params) -- helper function to build a bunch o'buttons
---------------------------------
atom btn = create(GtkButton,params[1],_(params[2]))
    set(btn,"tooltip markup",params[3])
    set(btn,"size request",120,30)
return btn
end function

object btns = { -- button image#caption, function, tooltip;
    {"go-bottom#_Append","AppendRow","Click to append a dessert"},
    {"go-top#_Prepend","PrependRow","Click to prepend a Steak"},
    {"insert-object-symbolic#_Insert","InsertRow","Click to insert a Duck after selected item"},
    {"gtk-delete","DeleteRow","Click to delete the selected row"},
    {"emblem-synchronizing#_Replace","ReplaceRow","Replace the selected row(s) with a tasty treat"},
    {"format-justify-fill#List","ShowAll","Click to show listing on terminal"},
    {"starred#_Selected","ShowSelected","Click to show selected item(s)"},
    {"gtk-info","ShowInfo","Click to show info about model"},
    {"gtk-quit","Quit","Click to exit"},
    {"media-playlist-shuffle#Swap","SwapItems","Click to swap two selected items"},
    {"go-down#After","MoveAfter","Moves first selected item to a position immediately <i>after</i> the second"},
    {"go-up#_Before","MoveBefore","Moves first selected item to a position immediately <i>before</i> the second"}
}
 
for i = 1 to length(btns) do
    btns[i] = NewBtn(btns[i])
    set(btns[i],"size request",140) -- make all same width;
end for     

constant box1 = create(GtkButtonBox) add(box1,btns[1..4]) 
constant box2 = create(GtkButtonBox) add(box2,btns[5..8])
constant box3 = create(GtkButtonBox) add(box3,btns[9..12])

pack(panel,{box1,box2,box3})

show_all(win)
main()

----------------------------------------------------------------
global function EditValue(atom rend, object path, object newtext)
----------------------------------------------------------------
atom row = get(selection,"selected row") ? rend ? path ? newtext
    set(store,"col data",row,2,peek_string(newtext))
return 1
end function

--------------------------
function ShowSelected() -- get one or more selected rows;
--------------------------
object rows = get(selection,"selected rows") 
object results = {}
object names = {}

if length(rows) then
    for i = 1 to length(rows) do 
        results = append(results, get(store,"col data",rows[i],1))
    end for
    results = join(demarkup(results),'\n')
    Info(win,,"You chose",results)
end if

return 1
end function 

---------------------
function ShowAll() -- get data back as a Eu sequence
---------------------
object x = get(store,"data") --update the original list
       x = vslice(x,1) 
       x = demarkup(x)
       display(x) -- and display on the terminal
return 1
end function

--------------------
function AppendRow()
--------------------
set(store,"append row",Pie)
return 1
end function 

---------------------
function PrependRow()
---------------------
set(store,"prepend row",Steak)
return 1
end function

-----------------------------------------------------------------------------------------
-- note: nearly all the following calls implement some testing to be sure
-- the user has selected the correct number of items from the list.
-- e.g: you cannot swap one item, nor is swapping 3 items logical.
------------------------------------------------------------------------------------------

--------------------
function InsertRow()
--------------------
object row = get(selection,"selected row")

    if row > 0 then
		set(store,"insert row",Duck,row+1)
    else
		Warn(,,"No row selected","Select a row first")
    end if
      
return 1
end function

--------------------
function DeleteRow()
--------------------
object rows = get(selection,"selected rows") 

    if equal({},rows) then
		Warn(,,"No row(s) selected to delete")
    else
	for i = length(rows) to 1 by -1 do
	    set(store,"remove row",rows[i])
	end for
    end if
    
return 1
end function 

---------------------
function ReplaceRow()
---------------------
object rows = get(selection,"selected rows") 

    if length(rows) = 0 then
	return Warn(win,"Too Bad",
	    "You didn't select anything!",
	    "Try clicking on one or more rows")
    end if
    for i = 1 to length(rows) do
		set(store,"replace row",Pudding,rows[i])
    end for
    
return 1
end function 

--------------------
function SwapItems()
--------------------
object rows = get(selection,"selected rows") 

    if length(rows) = 2 then
		set(store,"swap rows",rows[1],rows[2])
    else
		Error(win,,"Sorry",
		    "Must select exactly two rows to be swapped!")
    end if
    
return 1
end function

---------------------
function MoveBefore()
---------------------
object rows = get(selection,"selected rows")

    if length(rows) = 2 then
		set(store,"move before",rows[1],rows[2])
    else
		Error(win,,"Sorry","Must select exactly two rows!")
    end if
    
return 1
end function

--------------------
function MoveAfter()
--------------------
object rows = get(selection,"selected rows")

    if length(rows) = 2 then
		set(store,"move after",rows[2],rows[1])
    else
		Error(win,,"Sorry","Must select exactly two rows!")
    end if
    
return 1
end function

----------------------
function ShowInfo() -- statistics;
---------------------- 
integer rows = get(store,"n rows") 
integer cols = get(store,"n cols")  
integer sortord = get(store,"sort order") 
integer sortcol = get(store,"sort column id") 
		
Info(win,,"Model Contains",
    sprintf("%d rows, %d columns\nSort Col: %d Sort Dir: %d",
	   {rows,cols,sortcol,sortord}))

return 1
end function

------------------------------
function demarkup(object x) -- remove markup
------------------------------
integer st,fi

    for i = 1 to length(x) do -- need plain text when displaying on terminal;
	while st > 0 and fi > st with entry do
	    x[i] = remove(x[i],st,fi)
	entry
	    st = find('<',x[i]) fi = find('>',x[i])
	end while
    end for
    
return x
end function
