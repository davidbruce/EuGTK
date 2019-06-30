
--------------------------------------------------------------------------
--# GtkListView using pixbufs, checkboxes, editable fields, etc.
--------------------------------------------------------------------------

include GtkEngine.e
include std/utils.e

sequence names = { -- might be read from a file;
    {"Jerry",		0,	"Jerry.jpg",	"Tampa, FL",		0},
    {"Jamie",		0,	"jls.jpg",      "Hollywood,CA",		1}, 
    {"Justin",		0,	"Justin.jpg",	"Norman,OK",		0}
}

-----------------------------------------
-- replace filenames with actual images;
-----------------------------------------
for i = 1 to length(names) do 
    names[i][3] = create(GdkPixbuf,"thumbnails/" & names[i][3],60,60,1) 
end for

-----------------------------------------------------------------
-- create a list store to hold the data;
-----------------------------------------------------------------
constant store = create(GtkListStore,{gSTR,gINT,gPIX,gSTR})
    set(store,"data",names) 

------------------------------------------
-- create columns to show the data;
------------------------------------------
constant 
    ren1 = create(GtkCellRendererText,"editable=TRUE,$edited=EditMe"),
    col1 = create(GtkTreeViewColumn,"title=Name")
    set(col1,"pack start",ren1)
    set(col1,"add attribute",ren1,"text",1)
    
    if gtk:minor_version = 18 then
	set(col1,"fixed width",100) -- work around bug in 3.18.6 when editing cell text;
    end if

constant 
    ren2 = create(GtkCellRendererToggle,"activatable=TRUE,$toggled=ToggleMe"),
    col2 = create(GtkTreeViewColumn,"title=Present")
    set(col2,"pack start",ren2)
    set(col2,"add attribute",ren2,"active",2)

constant
    ren3 = create(GtkCellRendererPixbuf),
    col3 = create(GtkTreeViewColumn,"title=Photo")
    set(col3,"pack start",ren3)
    set(col3,"add attribute",ren3,"pixbuf",3)
    
-------------------------------------
-- create a view to display the list
-------------------------------------
constant tv  = create(GtkTreeView,{
    {"model",store},
    {"tooltip column",0},
    {"append columns",{col1,col2,col3}}})

constant selection = get(tv,"selection") 
    set(selection,"mode",GTK_SELECTION_SINGLE)

--------------------------------------------
-- create a main window to hold view & ctls
--------------------------------------------
constant 
    win = create(GtkWindow,"title=`Test 35 - List View`,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel,"Double-click name to edit"),
    box = create(GtkButtonBox,"margin_top=5"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","ShowSelectedItem")

    add(win,panel)
    add(panel,{lbl,tv})
    add(box,{btn1,btn2})
    pack_end(panel,box)
    
show_all(win)
main()

--------------------------------------------------------------
global function EditMe(atom rend, object path, object newtext)
--------------------------------------------------------------
-- newtext is ptr to new contents;
integer row = get(selection,"selected row") 
set(store,"col data",row,1,peek_string(newtext)) 
return 1
end function

------------------------------------------------
global function ToggleMe(atom rend)
------------------------------------------------
integer row = get(selection,"selected row") 
 set(store,"col data",row,2,not get(rend,"active"))
return 1
end function

-------------------------------------
global function ShowSelectedItem()
-------------------------------------
object row = get(selection,"selected row") 
object data = get(store,"row data",row) 
    Info(win,"Student",
	format("Name: [1]",data),
	format("City: [4]\nChecked: ",data) &
	iif(data[2],"Yes","No"))
return 1
end function
