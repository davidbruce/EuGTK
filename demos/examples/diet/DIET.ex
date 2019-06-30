----------------------------------------------------------------------
--# Diet Tracker - demos ListViews
----------------------------------------------------------------------
include GtkEngine.e
include GtkSettings.e
include GtkEvents.e
include GtkPrinter.e
include GtkFileSelector.e
include std/datetime.e
include std/math.e

object datafile = "~/demos/examples/diet/sample.data"
object inifile = "~/demos/examples/diet/diet.ini"

constant today = datetime:format(datetime:now(),"%A, %d %b, %Y")
object working_date = datetime:now()

sequence data = { -- here's some sample data to use on first run;
	{"Breakfast",0,0,0,0,0,0,"lightblue1"},
	{"w/w bread", "3 slices",  2.2, 24.3, 55, 200},
	{"butter","2 pats",50,30,0,49},
	{"OJ","6 oz.",0,0,0,4},
	{"Lunch",0,20,20,5.30,12345.30,234,"lightblue1"},
	{"Snack"},
	{"Dinner",0,0,0,0,0,0,"lightblue1"}, 
	$} -- above test data is used if diet.data file not found

---------================ MAIN WINDOW ==============----------

constant -- create the main window;
	win = create(GtkWindow,"name=MainWindow,font=8,title=Diet Record,border=10,$destroy=Bail"),
	panel = create(GtkBox,"orientation=vertical,spacing=10"),
	box = create(GtkButtonBox),
	btn1 = create(GtkButton,"gtk-quit","Bail"),
	btn2 = create(GtkButton,"gtk-edit","EditRow"),  
	btn3 = create(GtkButton,"gtk-add","AddRow"), 
	btn4 = create(GtkButton,"gtk-open","Open"),
	btn5 = create(GtkButton,"gtk-save-as","Save",1),
	btn6 = create(GtkButton,"gtk-print","Print"),
	btn7 = create(GtkButton,"gtk-delete","DelRow"),

	scroller = create(GtkScrolledWindow),
	
	store = create(GtkListStore,{gSTR,gSTR,gFLT,gFLT,gFLT,gFLT,gSTR,gSTR}),
      
	tv = create(GtkTreeView,{ -- a "spreadsheet" style list;
	{"model",store},    
	{"autosize",FALSE},
	{"reorderable",TRUE},
	{"headers clickable",TRUE},
	{"set grid lines",GTK_TREE_VIEW_GRID_LINES_BOTH},
	{"rules hint",TRUE}, -- shade alt rows, if window theme allows;
	{"connect","row-activated","EditRow"}}), -- double click;
	
	selection = get(tv,"selection") -- this tracks the current selection;

-- for fun, let's add some buttons with images!
   NewImageButton("<b><i><u>Calories</u></i></b>","thumbnails/pie.png","pie")
   NewImageButton("Date","stock_calendar","dt") -- dt is the name used in 'widget=' below
   
-------------------------------------------------------------------------------------------

sequence col = repeat(0,8) -- spreadsheet columns;
  col[1] = create(GtkColumn,"title=Item,name=cName,type=text,markup=1,background=8")
  col[2] = create(GtkColumn,"title=Amt,name=cAmt,type=text,text=2,min-width=80,max-width=240,resizable=TRUE")
  col[3] = create(GtkColumn,"title=Sodium (mg),name=cSod,type=text,markup=3,min-width=100,xalign=1,bkgnd=mint cream")
  col[4] = create(GtkColumn,"title=Fat (g),name=cFat,type=text,text=4,min-width=100,xalign=1,bkgnd=ivory")
  col[5] = create(GtkColumn,"title=Carbs (g),name=cCarb,type=text,text=5,xalign=1,bkgnd=thistle1")
  col[6] = create(GtkColumn,"title=Calories,name=cCal,type=text,text=6,xalign=1,bkgnd=azure,widget=pie")
  col[7] = create(GtkColumn,"title=Date,name=cDate,clickable=TRUE,type=text,text=7,widget=dt,background=8")
  col[8] = create(GtkColumn,"title=stat,name=cStat,type=text,text=8,visible=FALSE")
    
  set(col[2],"format func","cell_fmt",2,"<i>[]</i>")-- special EuGTK formatting functions:
  set(col[3],"format func","cell_fmt",3,"[b,,.0]")  -- last # is col of source data, it does
  set(col[4],"format func","cell_fmt",4,"[b,,.1]")  -- not have to be the same as col being
  set(col[5],"format func","cell_fmt",5,"[b,,.1]")  -- set, so 2 or more columns can show the same
  set(col[6],"format func","cell_fmt",6,"[b,,.0]")  -- data in different formats. the usual 
  set(col[7],"format func","cell_fmt",7,"[]")       -- format string follows col number.
  
------------------------------------------------------------------------------------------------------

sequence tot = repeat(0,9) -- places to display totals at bottom of screen;
	tot[1] = create(GtkLabel,"markup=<b><i>Totals:</i></b>")
	tot[2] = create(GtkLabel,"label=Sodium,background=mint cream,width-chars=8")
	tot[3] = create(GtkEntry,"name=tSod,width-chars=10,placeholder-text=mg")
	tot[4] = create(GtkLabel,"label=Fat,background=ivory,width-chars=8")
	tot[5] = create(GtkEntry,"name=tFat,width-chars=10,placeholder-text=grams")
	tot[6] = create(GtkLabel,"label=Carbs,background=thistle1,width-chars=8")
	tot[7] = create(GtkEntry,"name=tCarb,width-chars=10,placeholder-text=grams")
	tot[8] = create(GtkLabel,"label=Calories,width-chars=10,background=azure")
	tot[9] = create(GtkEntry,"name=tCal,width-chars=10,placeholder-text=cal")
	
constant -- holder for the totals;
	tbox = create(GtkBox,"orientation=horizontal,spacing=10")
	gtk:add(tbox,tot) 
	
	gtk:add(win,panel) -- put it all together;
	gtk:add(tv,col) 
	gtk:add(scroller,tv)
	gtk:add(box,{btn1,btn2,btn3,btn4,btn5,btn6,btn7})
	pack(panel,scroller,1,1) -- 1,1 means expand and fill all available space;
	pack(panel,-box) -- neg sign means pack at end/bottom;
	pack(panel,-tbox)

--------------------------------------------------------------------	
-- ready to run!
--------------------------------------------------------------------
datafile = canonical_path(datafile)
inifile = canonical_path(inifile)

if file_exists(datafile) then
  data = load(datafile)
  data = data[2]
  set("MainWindow","title","Diet Tracker ~ " & datafile)
else
  set("MainWindow","title","Diet Tracker ~ Sample Data")  
end if -- otherwise, sample data will be shown;
 
set(store,"data",cleanup(data)) -- see cleanup function below;


settings:Load(inifile,0) -- 1 means show in terminal;
show_all(win)

set(selection,"mode",GTK_SELECTION_MULTIPLE)
set(selection,"unselect all") 
-- in case someone hits the delete button; an easy
-- mistake to make, so don't automatically highlight any.

doSums() -- compute totals for data before showing;

main() -- start

-------------------------------
global function SelectDate() --
-------------------------------
-- create date selection dialog;
atom datedlg = create(GtkDialog,{
    {"name","datedlg"},
    {"title","Date Dialog"},
    {"transient for",win},
    {"add button","gtk-cancel",GTK_RESPONSE_CANCEL},
    {"add button","gtk-ok",GTK_RESPONSE_OK}})

atom cal = create(GtkCalendar) -- add to dialog;
atom cad = gtk:get(datedlg,"content area") -- (top part)
gtk:add(cad,cal) show_all(cad)

set(cal,"date",datetime:format(working_date,"%m/%d/%Y"))

object result = run(datedlg) 
if result = MB_OK then
  working_date = get(cal,"datetime",0) -- get this in a standard format;
  set("iDate","text",get(cal,"date",0)) -- show this in more readable format;
end if

destroy(datedlg) --! important   

return 1
end function

---------------------------
global function AddRow() --
---------------------------

integer row = get(selection,"selected row")

atom inputdlg = create(GtkDialog,{-- create input dialog;
	{"name","inputdlg"},
	{"title","Input Dialog ~ Add a row"},
	{"transient for",win},
	{"border width",10},
	{"hover expand",1},
	{"add button","gtk-cancel",GTK_RESPONSE_CANCEL},
	{"add button","gtk-ok",GTK_RESPONSE_OK}})
	
atom pan = create(GtkBox,"name=pan,orientation=vertical,spacing=10") -- container for inputs;

sequence field = repeat(0,7)
  field[1] = create(GtkEntry,"name=iDate,placeholder text=Date,tip=Date")
  field[2] = create(GtkEntry,"name=iName,placeholder text=Name,tip=Item")
  field[3] = create(GtkEntry,"name=iAmt,placeholder text=Amount,tip=Amount")
  field[4] = create(GtkEntry,"name=iSod,placeholder text=Sodium")
  field[5] = create(GtkEntry,"name=iFat,placeholder text=Fat")
  field[6] = create(GtkEntry,"name=iCarb,placeholder text=Carbs")
  field[7] = create(GtkEntry,"name=iCal,placeholder text=Calories")

set(field[1],"text",datetime:format(working_date,"%A, %b %d, %Y")) 
set(field[1],"icon from icon name",1,"vcalendar")
connect(field[1],"icon press","SelectDate")

for i = 1 to 6 do -- special handling to make program more intuitive (for Windows freaks)
   connect(field[i],"activate","trap_enter_key") 
end for -- move to next field as expected;

atom bolder = create(GtkCheckButton,"gtk-bold#_Heading Row")

gtk:add(pan,field) -- put input fields
gtk:add(pan,bolder) -- and Bold button into container;

atom cai = gtk:get(inputdlg,"content area") -- 'upper' part of dialog;
gtk:add(cai,pan) show_all(cai) -- must implicitly show objects added to content area;

integer result = run(inputdlg) 

if result != MB_OK then destroy(inputdlg) return 1 end if -- don't bother...

object new_data = { -- retrieve contents of fields. note some are text, others values;
  get("iName","text"), -- getting them in the correct order is important
  get("iAmt","text"),  -- the order is the same as the column names, left to right
  get("iSod","value"), -- unless we have made other (re-) arrangements.
  get("iFat","value"),
  get("iCarb","value"),
  get("iCal","value"),
  get("iDate","text"),
  "white" -- no background color;
  }
  
if get(bolder,"active") then 
  new_data[1] = sprintf("<b>%s</b>",{new_data[1]}) -- format bold
  new_data[8] = "lightblue1" -- with color background, and save in column 8;
else
  new_data[7] = ""
end if  

if row = 0 then
   data = set(store,"append row",new_data) -- if no selection, add new row at end;
else 
   data = set(store,"insert row",new_data,row+1) -- else insert it below selected row;
end if

set(store,"clear")
set(store,"data",data)

doSums() -- update totals;

destroy(inputdlg) --! if you don't do this, you'll waste memory.

return 1
end function

----------------------------
global function EditRow() --
----------------------------
integer row = get(selection,"selected row")

if row = 0 then Warn(,,"Edit","Please select a row to edit") return 1 end if

atom inputdlg = create(GtkDialog,{-- create input dialog;
	{"name","inputdlg"},
	{"title","Input Dialog ~ Edit row"},
	{"transient for",win},
	{"border width",10},
	{"hover expand",1},
	{"add button","gtk-cancel",GTK_RESPONSE_CANCEL},
	{"add button","gtk-ok",GTK_RESPONSE_OK}})
	
atom pan = create(GtkBox,"name=pan,orientation=vertical,spacing=10") -- container for inputs;

sequence field = repeat(0,7)
  field[1] = create(GtkEntry,"name=iDate,placeholder text=Date")
  field[2] = create(GtkEntry,"name=iName,placeholder text=Name")
  field[3] = create(GtkEntry,"name=iAmt,placeholder text=Amount")
  field[4] = create(GtkEntry,"name=iSod,placeholder text=Sodium")
  field[5] = create(GtkEntry,"name=iFat,placeholder text=Fat")
  field[6] = create(GtkEntry,"name=iCarb,placeholder text=Carbs")
  field[7] = create(GtkEntry,"name=iCal,placeholder text=Calories")

 set("iDate","text",data[row][7])
 set("iName","text",data[row][1])
 set("iAmt","text",data[row][2])
 set("iSod","text",data[row][3])
 set("iFat","text",data[row][4])
 set("iCarb","text",data[row][5])
 set("iCal","text",data[row][6])
 
set(field[1],"text",datetime:format(working_date,"%A, %b %d, %Y")) 
set(field[1],"icon from icon name",1,"vcalendar")
connect(field[1],"icon press","SelectDate")

for i = 1 to 6 do -- special handling to make program more intuitive (for Windows freaks)
   connect(field[i],"activate","trap_enter_key") 
end for -- move to next field as expected;

atom bolder = create(GtkCheckButton,"gtk-bold#_Heading")
set(bolder,"active",match("<b>",get("iName","text")))
 
gtk:add(pan,field) -- put input fields
gtk:add(pan,bolder) -- and Bold button into container;

atom cai = gtk:get(inputdlg,"content area") -- 'upper' part of dialog;
gtk:add(cai,pan) show_all(cai) -- must implicitly show objects added to content area;

integer result = run(inputdlg) 

if result != MB_OK then destroy(inputdlg) return 1 end if -- bail out...

object new_data = { -- retrieve contents of input fields. note some are text, others values;
  get("iName","text"), -- getting them in the correct order is important
  get("iAmt","text"),  -- the order is the same as the column names, left to right
  get("iSod","value"), -- unless we have made other (re-) arrangements.
  get("iFat","value"),
  get("iCarb","value"),
  get("iCal","value"),
  get("iDate","text"),
  "white" -- no background color;
  }
if get(bolder,"active") then 
  while match("<",new_data[1]) > 0 do
    display(new_data[1])
    new_data[1] = new_data[1][4..$-4]
  end while
  new_data[1] = sprintf("<b>%s</b>",{new_data[1]}) -- format bold
  new_data[8] = "lightblue1" -- with color background, and save in column 8;
else 
  new_data[7] = ""
end if  

if row > 0 then 
   data = set(store,"replace row",new_data,row)
   set(store,"clear")
   set(store,"data",data)
end if

doSums() -- update totals;

destroy(inputdlg) --! if you don't do this, you'll waste memory.

return 1
end function

--------------------
function doSums() --
--------------------
object data = get(store,"data") -- make sure it's up to date;
set("tSod","text", text:format("[,,.0] mg",sum(vslice(data,3)))) -- total the vertical columns;
set("tFat","text", text:format("[,,.0] grams",sum(vslice(data,4))))
set("tCarb","text",text:format("[,,.0] grams",sum(vslice(data,5))))
set("tCal","text", text:format("[,,.0] cal",sum(vslice(data,6))))
return 1
end function

constant HEAD =  "<span background='gray90'>[:60]  [7] </span>\n"
constant LINE = "[:20] <span background='#FBFBFB'>[b:25]</span> [b:6]<span background='#FBFBFB'>[b:6] </span>  [b:6]  <span background='#FBFBFB'>[b:6] </span> []\n"

--------------------------
global function Print() --
--------------------------
data = get(store,"data")
object output = repeat(0,length(data))
for i = 1 to length(data) do
  if match("<",data[i][1]) > 0 then display("Matched at []",i)
  output[i] = text:format(HEAD,data[i])
  else
  output[i] = text:format(LINE,data[i])
  end if
end for
-- add title;
output = prepend(output,"\t\t     Description \t\tSodium \tFat   Carbs  Calories\n")
-- add totals;
output = append(output,"<u>" & repeat(" ",78) & "</u>\n") -- horizontal line;
output = append(output,text:format("<u>[]  Sodium []   Fat []   Carbs []   Calories []  </u>\n",
  {"<b>Totals:</b>",get("tSod","text"),get("tFat","text"),get("tCarb","text"),get("tCal","text")})) 

printer:sourcecode=FALSE -- don't try to color-code this
printer:use_line_numbers=FALSE -- no need for those, either
printer:use_syntax_color=FALSE
printer:PrintText("Diet Tracker",flatten(output))

return 1
end function

---------------------------
global function DelRow() --
---------------------------
object rows = get(selection,"selected rows") -- returns a sequence of row numbers;

    if equal({},rows) then -- list is empty;
	Warn(,,"No row(s) selected to delete")
    else
	for i = length(rows) to 1 by -1 do -- looks better bottom to top;
	  data = set(store,"remove row",rows[i]) -- delete every highlighted row;
	end for
    end if
    set(store,"clear")
    set(store,"data",data)
    doSums() -- update totals;
return 1
end function

---------------------------------------------------------------------
function NewImageButton(object text, object filename, object name) --
---------------------------------------------------------------------
atom img = create(GtkImage,create(GdkPixbuf,filename,15,15)), -- create from pixbuf so can size;
     pan = create(GtkBox), -- a container for the image and label;
     lbl = create(GtkLabel,"margin-start=10") -- bit of space btween
     set(lbl,"markup",text)
     gtk:add(pan,{img,lbl}) show_all(pan) -- must show 'em!
     set(pan,"name",name) -- so we can pass the name in column create line;
return pan
end function

--------------------------------
function cleanup(object data) --
--------------------------------
for i = 1 to length(data) do -- make sure all data has same # of rows,
  data[i] = pad_tail(head(data[i],8),8,0) -- and set any which have no color
  if atom(data[i][8]) then data[i][8] = "white" end if -- set col1 backgroud flags
end for
return data
end function

-------------------------
global function Open() --
-------------------------
fileselector:filters = {"data","text"}
object openname = fileselector:Open(canonical_path("~/demos/examples/diet/*"))
object tmp
if string(openname) then
   datafile = openname
   data = load(datafile)
   data = data[2]
   set(store,"clear")
   set(store,"data",data)
   tmp = datetime:parse(filebase(datafile),"%d_%m_%Y")
   if not atom(tmp) then working_date = tmp end if
   set("MainWindow","title","Diet Tracker ~ " & filename(datafile))
   doSums()
end if
return 1
end function

--------------------------------------------------
global function Save(atom ctl,integer mode = 0) --
--------------------------------------------------
fileselector:filters = {"data","text"}
if mode = 1 then
object filedate = datetime:format(working_date,"%a_%d_%m_%Y")
object savename = fileselector:SaveAs(text:format("[].data",{filedate}))
if string(savename) then 
  datafile = savename
end if  
end if
data = get(store,"data")
dump(data,datafile)
settings:Save(inifile,{"MainWindow","cAmt"},0) -- win size, amt col width;
return 1
end function

-------------------------
global function Bail() --
-------------------------
Save(0,0)
return Quit() -- time to go, bye bye!
end function

---------------------------------------------------
-- © 2018 by Irv Mullins
---------------------------------------------------
