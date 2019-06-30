
----------------------------------------------------------------------------------
--# A simple file browser/runner <i>(this program)</i>
----------------------------------------------------------------------------------

constant preferred_editor = "eui ~/WEE-master/wee.exw"

include GtkEngine.e
include GtkPrinter.e
include std/io.e
include std/sort.e
include std/datetime.e 


chdir(prog_dir)

constant 
	win = create(GtkWindow,"size=750x550,border=10,resizable=1,$destroy=Quit"),
	panel = create(GtkBox,"orientation=VERTICAL"),
	lbl = create(GtkLabel),
	store = create(GtkListStore,{gSTR,gSTR,gINT,gSTR,gINT,gSTR,gSTR}),
	tv = create(GtkTreeView,{
		{"model",store},    
		{"reorderable",TRUE},
		{"headers clickable",TRUE},
		{"set grid lines",GTK_TREE_VIEW_GRID_LINES_BOTH},
		{"rules hint",TRUE}}),
	cols = { 
		create(GtkColumn,"title=Name,type=text,text=1,sort_column_id=2,background=7"), --[1]
		create(GtkColumn,"title=Size,name=size_col,type=text,text=3,sort_column_id=3,xalign=1"),
		create(GtkColumn,"title=Date,type=text,text=4,sort_column_id=5"), --[2]
		create(GtkColumn,"title=Description,type=text,markup=6,sort_column_id=6"),
		create(GtkColumn,"type=text,text=7,sort_column_id=7,visible=FALSE")},

	selection = gtk:get(tv,"selection"),
	scroller = create(GtkScrolledWindow),
	box = create(GtkButtonBox),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-edit","Edit"),
	btn3 = create(GtkButton,"gtk-print","Print"),
	btn4 = create(GtkButton,"gtk-help","Help")

object input = 0
 if string(uses("grep")) then  
  input = create(GtkEntry,"placeholder text=Search term")
  set(input,"tooltip markup","Enter a search term here, then hit &lt;enter&gt;")
  connect(input,"activate","Search")
 end if

LoadFiles()

-- set up some things;
set(tv,"rules hint",TRUE)
set(tv,"columns autosize")
set(tv,"search column",6)
set(tv,"search equal func",_("find_func"))
gtk:add(tv,cols)
set("size_col","format func","cell_fmt",3,"[b,,.0]") -- format the size column;
set(selection,"mode",GTK_SELECTION_MULTIPLE)
  
connect(tv,"row-activated","show_choice")

set(store,"sort column id",2,GTK_SORT_ASCENDING) -- default startup sort;
set(win,"title","EuGTK Browser - " & prog_dir)
gtk:add(win,panel)
gtk:add(panel,lbl)
pack(panel,-box)
pack(panel,scroller,TRUE,TRUE,10)
gtk:add(scroller,tv)
gtk:add(box,{btn1,btn2,input,btn3,btn4})
set(btn3,"tooltip text","Print the selected file with syntax color coding")
set(btn4,"tooltip text","Click for help with searching")
  
set(lbl,"markup","<b>Instructions:</b>\n" &
"Use <i>alt-f</i> to search in description column, up/dn arrows to find prev/next, " &
"then <i>enter</i> or double-click to run!")
  
show_all(win)
main()

--------------------------
procedure LoadFiles() -- Load and massage the file list:
--------------------------

object files = dir("*.ex") -- load files;

-- convert file dates to a usable format;
files = apply(files,routine_id("convert_date"))
files = apply(files,routine_id("convert_filename"))
for i = 1 to length(files) do
  files[i][7] = "white" -- for searches;
end for

integer x = find("browser.ex",vslice(files,1))
if x then files = remove(files,x) end if -- don't show this program in the list;

-- load files into the listview;
gtk:set(store,"clear")
gtk:set(store,"data",files)

end procedure

---------------------------------------------------
function convert_filename(object f, object junk) -- 
---------------------------------------------------
-- obtain a description of the program from the --# line;
object tmp = io:read_lines(f[1]) 
for i = 1 to length(tmp) do
  if match("--#",tmp[i]) =1 then 
   f[6] = tmp[i][5..$] -- use this as the description;
  end if
 end for
 
-- build index of #s (fix sorting problem)
object x = filter(f[1],"out",{'0','9'},"[]")
object n = filter(f[1],"in",{'0','9'},"[]")
f[2] = x & pad_head(n,10,'0')

return f
end function

--------------------------------------------
function convert_date(object a, object b) -- convert dates to unix for sorting;
--------------------------------------------
-- convert eu dir() date to datetime;
object dt = datetime:new(a[4],a[5],a[6])   
           
-- store human-readable version for display in col 4; 
 a[4] = datetime:format(dt,"%b %d, %Y") 
 
-- store as UNIX timestamp for sorting purposes in col 5;
 a[5] = to_unix(dt)  
  
return a
end function

--------------------------------------------------------------------------------
function find_func(atom mdl, integer col, object key, atom iter, object data) --
------------------------------------------------------------------- ------------
key = lower(peek_string(key)) -- key is passed as pointer to string
data = get(mdl,"value",iter,6) -- value from col 6 of liststore (description)
return not match(key,lower(data)) -- find word anywhere in description, 0 = found
end function

--------------------------------
global function show_choice() --
--------------------------------
integer row = gtk:get(selection,"selected row") 
object f = gtk:get(store,"col data",row,1)

ifdef LINUX then
 system_exec(sprintf("eui %s &",{f}),0)
end ifdef
ifdef WINDOWS then
 system_exec(sprintf(`euiw "%s"`,{f}),0)
end ifdef
return 1
end function

--------------------------
global function Print() --
--------------------------
integer row = gtk:get(selection,"selected row") 
if row < 1 then -- nothing to print!
 return Error(,"Oops!","No file selected",,GTK_BUTTONS_OK)
end if
object f = gtk:get(store,"col data",row,1)
printer:PrintFile(f)
return 1
end function

-------------------------
global function Edit() --
-------------------------
integer row = gtk:get(selection,"selected row") 
if row = 0 then 
 return Warn(,,"Nothing selected","click a row first") 
end if
object f = gtk:get(store,"col data",row,1) 
system_exec(preferred_editor & " " & f & " & ",0)
return 1
end function

---------------------------
global function Search() --
---------------------------
object search_term = get(input,"text")

if length(search_term) < 1 then return 1 end if

system(sprintf("grep -l %s *.ex | uniq > browser_search_results.txt",{search_term}),0)

object results = read_lines("browser_search_results.txt")

if length(results) < 1 then 
 Info(win,"Sorry","No results found for",search_term) 
 return 1
end if

object data = get(store,"data")
object list = vslice(data,1) 

integer x

for i = 1 to length(data) do data[i][7] = "white" end for

for i = 1 to length(results) do -- highlight matching programs;
   x = find(results[i],list)
    if x > 0 then
       data[x][7] = "lightgreen"
    end if
end for

set(store,"clear")
set(store,"data",data)
set(store,"sort column id",7,1) -- move matching programs to top of list;

delete_file("browser_search_results.txt")

return 1
end function

-------------------------
global function Help() --
-------------------------
return Info(,prg_name,"Usage",`

<u><b>Running</b></u>

   Double-click or hit &lt;enter&gt; on a selected line to run 
   that program
   
<u><b>Searching</b></u> 

   A. Use &lt;ctl&gt;f to search for words in the Description column.
       Use the up/down arrows to choose the previous or next match.

   B. If you have grep available, type in the search term box and 
       hit &lt;enter&gt; to grep for any word contained in the listed 
       programs source code.

       For example, entering GtkComboBox will highlight in green 
       all programs using that widget.
 
<u><b>Editing</b></u>

   Click the Edit button to open the selected program with WEE.
   
`)
end function


