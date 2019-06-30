
------------------------------------------------------------------------
--# GtkTreeView with a drop-down Combo column

-- lets user select from a limited list of choices.
------------------------------------------------------------------------

include GtkEngine.e

constant docs = `markup=
<u><b>Combo in ListView</b></u>
Click a cell in the <i>Combo</i> column
<i>twice</i> to drop-down a list of manufacturers
`
constant phone = create(GdkPixbuf,"thumbnails/phone.png",40,40,1)
constant dvd = create(GdkPixbuf,"thumbnails/drive-optical.png",40,40,1)
constant tele = create(GdkPixbuf,"thumbnails/video-display.png",40,40,1)

constant categories = {
    {"Television","Samsung",tele},
    {"Mobile Phone","LG",phone},
    {"DVD Player","Sony",dvd}
    }
    
constant manufacturers = {
    {"Sony"}, 
    {"LG"}, 
    {"Panasonic"}, 
    {"Toshiba"}, 
    {"Nokia"}, 
    {"Samsung"}
    }
 
constant 
    win = create(GtkWindow,"size=420x200,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel,docs),
    tv = create(GtkTreeView),
    category_selection = get(tv,"selection"),
    
    model1 = create(GtkListStore,{gSTR,gSTR,gPIX}),

    rend1a = create(GtkCellRendererText),
    rend1b = create(GtkCellRendererPixbuf),
    col1 = create(GtkTreeViewColumn,{
	{"title","Text"},
	{"pack start",rend1b},
	{"pack end",rend1a},
	{"add attribute",rend1a,"text",1},
	{"add attribute",rend1b,"pixbuf",3}}),
	
    model2 = create(GtkListStore,{gSTR}),
	
    rend2 = create(GtkCellRendererCombo,{
	{"property","model",model2},
	{"text column",1},
	{"editable",TRUE}}),
	
    col2 = create(GtkTreeViewColumn,{
	{"title","Combo"},
	{"clickable",TRUE},
	{"sort column id",2},
	{"pack start",rend2},
	--{"fixed width",50},
	{"add attribute",rend2,"text",2}}),

    box = create(GtkButtonBox,"margin_top=10"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","Display")

    set(tv,"model",model1)
    set(model1,"data",categories)
    set(model2,"data",manufacturers)

    set(tv,"append columns",{col1,col2})
    connect(rend2,"edited","Update")
    
    add(win,panel)
    add(panel,{lbl,tv})
    add(box,{btn1,btn2})
    pack(panel,-box)
    
show_all(win)
main()

------------------------------------------------------------------------
global function Update(atom rend, object path, object newtext)
------------------------------------------------------------------------
integer row = get(category_selection,"selected row") 
set(model1,"col data",row,2,peek_string(newtext))
return 0
end function

------------------------------------------------------------------------
global function Display()
------------------------------------------------------------------------
object txt = "", results = get(model1,"data")
 for i = 1 to length(results) do
    txt &= results[i][1] & " = " & results[i][2] & "\n"
 end for
 Info(win,"Your Choices",txt)
return 1
end function
