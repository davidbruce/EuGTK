
--# ListView filter and sort <span color='red'>New in EuGTK 4.14.4</span>

include GtkEngine.e
include std/sort.e
   
enum NAME,CLASS,AGE
    
object students = { --name, class, age
 {"Fred",    "Senior",   18},
 {"Sue",     "Junior",   16},
 {"Kathleen","Freshman", 14},
 {"Arnold",  "Freshman", 14},
 {"Xavier",  "Junior",   18},
 {"Kathy",   "Teacher",	 33},
 {"Thelma",  "Sophomore",15},
 {"Ralph",   "Junior",   17},
 {"Juan",    "Sophomore",16},
 {"Bill",    "Junior",	 17},
 {"Kate",    "Senior",	 18},
 {"Mark",    "Teacher",  45},
 {"Jane",    "Senior",   17},
 {"Mo",	     "Freshman", 13},
 {"Charlie", "Teacher",  40},
 {"Louise",  "Sophomore",16},
 {"Alice",   "Junior",   17},
 {"George",  "Freshman", 13},
 {"Chris",   "Senior",   19},
 {"Frank",   "Freshman", 15},
 $}
 
integer name_sort_dir = 0, class_sort_dir = 0, age_sort_dir = 0
  
constant 
	win = create(GtkWindow,"title=Hard Knox,size=300x300,border=10,$destroy=Quit"),
	pan = create(GtkBox,"orientation=horizontal,spacing=10"),
	scr = create(GtkScrolledWindow),
	view = create(GtkTreeView),
	col1 = create(GtkColumn,"title=Name,type=text,text=1,sort=1"),
	col2 = create(GtkColumn,"title=Class,type=text,text=2,sort=2"),
	col3 = create(GtkColumn,"title=Age,type=text,text=3,sort=3"),
	box  = create(GtkButtonBox,"orientation=vertical"),
	btn1 = create(GtkButton,"Frosh","select","Freshman"),
	btn2 = create(GtkButton,"Soph.","select","Sophomore"),
	btn3 = create(GtkButton,"Juniors","select","Junior"),
	btn4 = create(GtkButton,"Seniors","select","Senior"),
	btn5 = create(GtkButton,"Staff","select","Teacher"),
	btn6 = create(GtkButton,"All","select",0),
	btn7 = create(GtkButton,"gtk-about","Help"),
	btn8 = create(GtkButton,"gtk-quit","Quit")

object selected_class = 0 -- set by btn1..6
	
	add(win,pan)
	pack(pan,scr,1,1) -- expand and fill
	add(scr,view)
	add(view,{col1,col2,col3})
	add(box,{btn1,btn2,btn3,btn4,btn5,btn6,btn7,btn8})
	pack(pan,-box)
    	 
constant stored = create(GtkListStore,{gSTR,gSTR,gINT})
	set(stored,"data",students)
	
constant filtered = create(GtkTreeModelFilter,stored)
    set(filtered,"visible func",_("Filter"))
    -- filtered is a filterable "container" for stored
    
 constant sorted = create(GtkTreeModelSort,filtered)
    -- sorted is a sortable "container" for filtered
    
   	set(view,"model",sorted)
	set(view,"headers clickable",TRUE)
    set(col1,"sort indicator",TRUE) 
    
    -- we have to manually connect sorting functions
    -- to the header clicks here, since we're also 
    -- using a filter (they don't work well together)

	connect(col1,"clicked","SetSortCol",NAME)
	connect(col2,"clicked","SetSortCol",CLASS)
	connect(col3,"clicked","SetSortCol",AGE)
	
show_all(win)
main()

---------------------------------------------------
global function SetSortCol(atom btn, integer col)
---------------------------------------------------
switch col do

	case NAME then
		name_sort_dir = not(name_sort_dir) -- toggle
		set(sorted,"sort column id",col,name_sort_dir+1)
		
	case CLASS then	
		class_sort_dir = not(class_sort_dir)    
		set(sorted,"sort column id",col,class_sort_dir+1)
		
    case AGE then
		age_sort_dir = not(age_sort_dir)
		set(sorted,"sort column id",col,age_sort_dir+1)
		
 end switch
return 1
end function

--------------------------------------------------
global function select(atom ctl, object pattern)
--------------------------------------------------
-- when filter selection changes, must re-filter
 selected_class = unpack(pattern)
 set(filtered,"refilter")
 return 1
end function

-----------------------------------------------
global function Filter(atom model, atom iter)
-----------------------------------------------
 -- if "all" are selected, no need for further work 
 if atom(selected_class) then return 1 end if
 -- otherwise, check each item and decide if it 
 -- should be shown (is "Junior" or "Senior", etc..)
 object path = get(model,"path",iter)
 path = to_number(get(path,"to string"))+1
 return equal(selected_class,students[path][CLASS]) > 0
end function

------------------------
global function Help()
------------------------
return Info(win,"About","Tree Model Fiters",
"""

A tree model filter hides parts of an underlying tree model.
It requires a custom Filter routine which returns 1 if the
row should be shown, 0 otherwise.

You must write a custom filter function, but it's easy, 
usually only 4 lines of code.

Implementing a custom filter also requires manually connecting
a custom sort routine, if you want the filtered results sorted.
This too, is relatively simple. 

Examine the source code for this program.

<i>Hint: try ctl-f to open a search entry, then typing ka, for 
example, to find Kate, Kathleen, etc... Use the up/dn arrow keys
to select prev/next match on list.</i>

""",
,"thumbnails/gtk-logo-rgb.gif")
end function



