
---------------------------------------------------------------------------------------
--# Demonstrates how to connect and process changes to listviews.

-- When you use CellRendererToggles as a set of radio buttons,
-- you have to handle the action yourself, this function is not
-- built into GTK. See RadioToggled function below.

-- However, I can't think of many reasons you might want to have
-- radio buttons in a list. You'd usually just set the list to 
-- select mode single, and click on one to select.
----------------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>GtkListView</b></u>
First column is editable,
second and third clickable.
Run from x-term to see changes.
`
constant win = create(GtkWindow,"position=1,border_width=10,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
    add(win,panel)

constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)

sequence distros = {
    {"Debian",		FALSE,	FALSE,	"debian.org", "debian-swirl"},
    {"OpenSuse",	TRUE,	FALSE,	"suse.de", "xfce-system"},
    {"Fedora",		FALSE,	FALSE,	"redhat.com", "xfce-system"},
    {"Ubuntu",		TRUE,	FALSE,	"ubuntu.org","ubuntu-logo"},
    {"Mint",		TRUE,	TRUE,	"linuxmint.org","cs-linuxmint"}
}

for i = 1 to length(distros) do
    distros[i][5] = create(GdkPixbuf,distros[i][5],20,20,1)
end for
display(distros)

constant liststore = create(GtkListStore,{gSTR,gBOOL,gBOOL,gSTR,gPIX})
    set(liststore,"data",distros)

constant treeview = create(GtkTreeView,{
    {"model",liststore},
    {"tooltip column",4}})

constant selection = get(treeview,"selection")

constant rend0 = create(GtkCellRendererPixbuf) ?rend0
constant col0 = create(GtkTreeViewColumn) ? col0 
  set(col0,"pack start",rend0)
  set(col0,"add attribute",rend0,"pixbuf",5)
  set(treeview,"append column",col0)

constant rend1 = create(GtkCellRendererText)
    set(rend1,"editable",TRUE)

constant col1 = create(GtkTreeViewColumn,{
    {"title","Linux Distro"},
    {"pack start",rend1},
    {"fixed width",90},
    {"add attribute",rend1,"text",1}})
    set(treeview,"append column",col1)
    connect(rend1,"edited",_("NameEdited"))

constant rend2 = create(GtkCellRendererToggle)
    set(rend2,"activatable",TRUE)

constant col2 = create(GtkTreeViewColumn,{
    {"title","Tried"},
    {"pack start",rend2},
    {"fixed width",40},
    {"add attribute",rend2,"active",2}})
    set(treeview,"append column",col2)
    connect(rend2,"toggled",_("CheckToggled"),rend2)

constant rend3 = create(GtkCellRendererToggle,{
    {"radio",TRUE},
    {"activatable",TRUE},
    {"cell-background","skyblue"}})
    connect(rend3,"toggled",_("RadioToggled"))

constant col3 = create(GtkTreeViewColumn,{
    {"title","Fave"},
    {"pack start",rend3},
    {"fixed width",40},
    {"add attribute",rend3,"active",3}})
    set(treeview,"append column",col3)

add(panel,treeview)

constant box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok",_("ShowList"))
    add(box,{btn1,btn2})
    pack_end(panel,box)
  
show_all(win)
main()

------------------------------------------------------------------------
function NameEdited(atom rend, object path, object newtext)
------------------------------------------------------------------------
-- the newtext param contains the updated text
integer row = get(selection,"selected row")  
    set(liststore,"col data",row,1,peek_string(newtext))
return 1
end function

-----------------------------------------------------------
function CheckToggled(atom ctl, atom rend)
-----------------------------------------------------------
-- there's no new value param provided for this function,
-- so we have to get the value from the store, flip it, 
-- and put it back;
integer row = get(selection,"selected row") 
distros[row][2] = not get(ctl,"active")
set(liststore,"clear")
set(liststore,"data",distros)
return 1
end function

-----------------------------------------------------------------
function RadioToggled()
-----------------------------------------------------------------
integer row = get(selection,"selected row")
-- toggle all buttons;
    distros = get(liststore,"data")
    for i = 1 to length(distros) do
	    distros[i][3] = (i=row)
    end for
    set(liststore,"clear")
    set(liststore,"data",distros)
return 1
end function 

-----------------------------------------------------------------
function ShowList()
-----------------------------------------------------------------
object data = get(liststore,"data")
display(repeat('-',80))
for i = 1 to length(data) do
    display("Distro: [:9] Tried: []  Favorite: [] URL: []",data[i])
end for
return 1
end function



