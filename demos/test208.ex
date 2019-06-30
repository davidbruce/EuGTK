
------------------------------------------------------------------------------------
--# GtkHeaderBar -- a 'new look' for windows
------------------------------------------------------------------------------------

include GtkEngine.e

requires("3.10","GtkHeaderBar")

-- inline css;
constant css = create(GtkCssProvider,"""
/***************
 * Header Bars *
 ***************/
 
.header-bar {
    padding: 2px;
    border-style: solid;
    border-width: 2px 2px 2px 2px;
    border-radius: 6px 6px 0 0;
    border-color: gray90;
    background-color: transparent;
    background-image: 
	linear-gradient(to bottom,
	    cornsilk,
	    cornflowerblue);                       
    box-shadow: 1px 1px alpha(black, 0.5);                            
}
""")

constant 
    img = create(GtkImage,create(GdkPixbuf,"system-run",20,20,1)),
    group = create(GtkAccelGroup),
    hdr = create(GtkHeaderBar,"title=Header Bar,show close button=TRUE"),
    win = create(GtkWindow,"size=400x340,border=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    lbl = create(GtkLabel,"Click the button at top left on the bar"),
    menu = create(GtkMenu),
    fopen = create(GtkMenuItem,"gtk-open"),
    fclose = create(GtkMenuItem,"gtk-close"),
    fabout = create(GtkMenuItem,"gtk-about","About"),
    fsep = create(GtkSeparatorMenuItem),
    fexit = create(GtkMenuItem,"gtk-quit","Quit"),
    mb = create(GtkMenuButton,{
	{"popup",menu},
	{"add",img}})
        
    set(hdr,"pack start",mb)
    set(hdr,"has subtitle",FALSE)
    set(win,"titlebar",hdr)
    set(win,"add accel group",group)
    
    set(fopen,"sensitive",FALSE)
    set(fclose,"sensitive",FALSE)
    set(menu,{
	{"append",{fopen,fclose,fabout,fsep,fexit}},
	{"title","Popup menu"},
	{"show all",menu}})

    add(win,panel)
    add(panel,lbl)
    
show_all(win)
main()

------------------------
global function About()
------------------------
return Info(,,
"GtkHeaderBar\n",
`This is similar to a horizontal GtkBox. 
 It allows children to be placed at the start 
 or the end. In addition, it allows a title and 
 subtitle to be displayed. The title will be 
 centered with respect to the width of the box, 
 even if the children at either side take up different 
 amounts of space. The height of the titlebar will be 
 set to provide sufficient space for the subtitle, even 
 if none is currently set. If a subtitle is not needed, 
 the space reservation can be turned off by setting
 has_subtitle to FALSE.

 GtkHeaderBar can add typical window frame controls, 
 such as minimize, maximize and close buttons, or the 
 window icon.`,,"~/demos/thumbnails/gtk-logo-rgb.gif")
 end function
 
