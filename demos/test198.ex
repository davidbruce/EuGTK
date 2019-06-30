
-----------------------------------------------------------------------------------------------------------------------
--# GtkPlacesSidebar 
-----------------------------------------------------------------------------------------------------------------------

include GtkEngine.e
include GtkFileSelector.e
include resources/places_sidebar.txt

requires("3.10","GtkPlacesSidebar")

constant 
    win = create(GtkWindow,"size=400x600,$destroy=Quit"),
    panel = create(GtkBox,"orientation=horizontal"),
    rightside = create(GtkBox,"orientation=vertical,margin top=10"),
    lbl = create(GtkLabel,"padding=10,line wrap=FALSE"),
    box = create(GtkButtonBox,"orientation=horizontal,margin bottom=10,layout=1"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-add","AddShortcut"),
    sidebar = create(GtkPlacesSidebar,{
	{"add shortcut",create(GFile,"~/demos")},
	{"show connect to server",TRUE}})
    
    connect(sidebar,"open-location","ShowSelected")

    set(lbl,"markup",places_sidebar:txt)	
    
    add(win,panel)
    add(panel,{sidebar,rightside})
    add(box,{btn1,btn2})
    pack(rightside,{lbl,-box})
    
show_all(win)
main()

------------------------------
global function ShowSelected()
------------------------------
    object loc = get(sidebar,"location")
    object name = gtk_str_func("g_file_get_parse_name",{P},{loc})
    fileselector:filters = {"euphoria","all"}
    fileselector:Open(name) 
return 1
end function

------------------------------
global function AddShortcut()
------------------------------
fileselector:filters = {"dir"}
object folder = fileselector:SelectFolder(0) 
    if string(folder) then
	set(sidebar,"add shortcut",create(GFile,folder))
    end if
return 1
end function
