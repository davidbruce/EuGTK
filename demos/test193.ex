
-------------------------------------------------------------------
--# GtkMenuButton
-------------------------------------------------------------------

include GtkEngine.e

requires("3.6","GtkMenuButton")

constant docs = `<u><b>MenuButton</b></u>

Pops up (or down, right or left)

Click the arrow button.
`

constant win = create(GtkWindow,{
    {"default size",200,100},
    {"border width",5},
    {"position",GTK_WIN_POS_CENTER},
    {"signal","destroy","Quit"}})

constant group = create(GtkAccelGroup)
    add(win,group)
    
constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant lbl = create(GtkLabel,{{"markup",docs}})
    add(panel,lbl)

constant 
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	mbtn = create(GtkMenuButton),
	box = create(GtkButtonBox)
	add(box,btn1)
	pack_end(box,mbtn) 
	set(box,"child non_homogeneous",mbtn)
	pack(panel,-box)
	
constant menu = create(GtkMenu),
	fopen = create(GtkMenuItem,"gtk-open"),
	fclose = create(GtkMenuItem,"gtk-close"),
	fsep = create(GtkSeparatorMenuItem),
	fexit = create(GtkMenuItem,"gtk-quit","Quit",0,{group,"<Ctl>Q"}),
	fhelp = create(GtkMenuItem,"gtk-about","Help")
	
	set(fopen,"sensitive",FALSE)
	set(fclose,"sensitive",FALSE)
	
	set(menu,"append",{fopen,fclose,fhelp,fsep,fexit})
	set(menu,"title","Popup menu")
	show_all(menu)
	
	set(mbtn,{
		{"tooltip text","Menu Button"},
		{"direction",GTK_ARROW_RIGHT},
		{"size request",30,30},
		{"relief",GTK_RELIEF_NONE}, -- try other GTK_RELIEF_ enums
		{"popup",menu}})
	
show_all(win)
main()

-----------------------
global function Help()
-----------------------
Info(,"About",    
"The GtkMenuButton\n",
`A widget used to display a popup when clicked on. 
 This popup can be provided either as a GtkMenu, 
 a GtkPopover or an abstract GMenuModel.

 The GtkMenuButton widget can hold any valid child 
 widget. That is, it can hold almost any other 
 standard GtkWidget. The most commonly used child 
 is GtkImage. If no widget is explicitely added 
 to the GtkMenuButton, a GtkImage is automatically 
 created, using an arrow image oriented according 
 to "direction" or the generic "view-context-menu" 
 icon if the direction is not set.

 The positioning of the popup is determined by the
  "direction" property of the menu button.`,,"thumbnails/gtk-logo-rgb.gif")
  
 return 1
end function
