
--------------------------------------------------------------------------
--# Accelerators a.k.a. 'hot keys' and CSS styling;
--------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<b><u>Keyboard Accelerators</u></b>,
Try alt-o, alt-c, or ctl-alt-x
or use the File menu.
`
constant css = create(GtkCssProvider,
 """
 .menuitem {background-image: linear-gradient(45deg, yellow, skyblue);}
 .menuitem:hover {color: red;}
 .separator {color: green2;}
 
 """)

constant 
	win = create(GtkWindow,"size=200x-1,$destroy=Quit"),
	group = create(GtkAccelGroup),
	panel = create(GtkBox,"orientation=vertical,spacing=10"),
	menu = create(GtkMenuBar),
	menuitem1 = create(GtkMenuItem,"_File"),
	filemenu = create(GtkMenu),
	fileopen = create(GtkMenuItem,"_Open","FOpen",0,{group,"<Alt>o"}),
	fileclose = create(GtkMenuItem,"_Close","FClose",0,{group,"<alt>c"}),
	filesep = create(GtkSeparatorMenuItem),
	filequit = create(GtkMenuItem,"_Quit","QuitOK",0,{group,"<ctl><alt>x"}),
	img = create(GtkImage,"thumbnails/keybindings.png"),
	lbl = create(GtkLabel,{{"markup",docs}})
	
	set(filemenu,"append",{fileopen,fileclose,filesep,filequit})
	set(menuitem1,"submenu",filemenu)
	set(menu,"append",menuitem1)

	add(win,group)
	add(win,panel)
	add(panel,menu)
	add(panel,{img,lbl})

show_all(win)
main()

------------------------------------------------------------------------
global function FOpen()
------------------------------------------------------------------------
return Info(win,"FOpen","Open a file")
end function

------------------------------------------------------------------------
global function FClose()
------------------------------------------------------------------------
return Info(win,"FClose","Close the file")
end function

------------------------------------------------------------------------
global function QuitOK()
------------------------------------------------------------------------
if Question(win,"Quit","Are you sure?") = MB_YES then Quit()
end if
return 1
end function

