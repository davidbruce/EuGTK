
------------------------------------------------------------------
--# Text View/Edit demo
------------------------------------------------------------------

object fnt = "Courier 12"

include GtkEngine.e
include GtkFileSelector.e
include GtkFontSelector.e
include std/net/url.e
include std/io.e

object current_file = current_dir()
boolean dirty = FALSE

enum NORM, INVERSE, GRNBLK

constant win = create(GtkWindow,"title=`Simple Text Viewer`,size=600x500,position=1,$destroy=Quit"),
    group = create(GtkAccelGroup),
    panel = create(GtkBox,VERTICAL),
    menu = create(GtkMenuBar) 

    add(win,group)
    add(win,panel)
    pack(panel,menu)

------------------------------------------------------------------------
-- FILE menu items
------------------------------------------------------------------------
constant menuitem1 = create(GtkMenuItem,"folder#_File"),
 filemenu = create(GtkMenu), 
    fileopen = create(GtkMenuItem,"document-open#_Open",_("FOpen"),0,{group,"<Control>o"}),
    fileclose = create(GtkMenuItem,"window-close#_Close",_("FClose"),0,{group,"<Control>c"}),
    filerun = create(GtkMenuItem,"system-run#_Execute",_("FRun"),0,{group,"F5"}),
    fileexit = create(GtkMenuItem,"application-exit#_Quit",_("Bail"),0,{group,"<Control>q"}),
    sep1 = create(GtkSeparatorMenuItem),
    sep2 = create(GtkSeparatorMenuItem)

    set(filemenu,"append",{fileopen,fileclose,sep1,filerun,sep2,fileexit})
    set(menuitem1,"submenu",filemenu)
    set(menu,"append",menuitem1)
        
    set(fileclose,"sensitive",FALSE)
    set(filerun,"sensitive",FALSE)
  
------------------------------------------------------------------------
-- PREFS menu items (a different way to create a menu)
------------------------------------------------------------------------
sequence item = repeat(0,10)
constant menuitem2 = create(GtkMenuItem,"preferences-system#_Preferences"),
 editmenu = create(GtkMenu)
    item[1] = create(GtkMenuItem,"font#_Font",_("Font"),0,{group,"<Ctl><Alt>f"})
    item[2] = create(GtkSeparatorMenuItem)
    item[3] = create(GtkRadioMenuItem,0,"thumbnails/normal.png#Normal",_("Colors"),NORM,{group,"<ctl><Alt>n"})
    item[4] = create(GtkRadioMenuItem,item[3],"thumbnails/reverse.png#Reverse",_("Colors"),INVERSE,{group,"<ctl><Alt>r"})
    item[5] = create(GtkRadioMenuItem,item[4],"thumbnails/term.png#Green/Black",    	_("Colors"),GRNBLK,{group,"<ctl><Alt>g"})
    item[6] = create(GtkSeparatorMenuItem)
    item[7] = create(GtkCheckMenuItem,"format-text-bold#Bold",_("Bold"),0,{group,"<ctl><alt>b"})
    item[8] = create(GtkCheckMenuItem,"format-text-italic#Italic",_("Italic"),0,{group,"<ctl><alt>i"})
    item[9] = create(GtkSeparatorMenuItem)

    -- following item has 2 accelerators:
    item[10] = create(GtkCheckMenuItem,"view-wrapped-symbolic#Wrap",_("Wrap"),0,{group,"F6"})
    set(item[10],"add accelerator",{group,"<ctl><alt>w"})
	
    set(editmenu,"append",item) -- add all
        
    set(menuitem2,"submenu",editmenu)
    set(menu,"append",menuitem2)

constant tips = { -- a different way to manage tooltips;
    "Open font dialog",
    0,-- no tip for separator lines
    "<span color='black' background='white'> Normal colors </span>",
    "<span color='white' background='black'> Reversed colors </span>",
    "<span color='#0DF517' background='black'> Green text on black </span>",
    0, 
    "<b>bold</b> style",
    "<i>italic</i> style",
    0,
    "Wrap text"
}
    for i = 1 to length(tips)  do
        set(item[i],"tooltip markup",tips[i])
    end for

------------------------------------------------------------------------
-- RECENT CHOOSER needs some filtering of results
------------------------------------------------------------------------
constant eu_filter = create(GtkRecentFilter,{
    {"name","*.ex"},
    {"add pattern","*.e"},
    {"add pattern","*.ex"}})

------------------------------------------------------------------------
-- RECENT CHOOSER menu items;
------------------------------------------------------------------------
constant menuitem3 = create(GtkMenuItem,"document-open-recent#_Recent Docs")
    set(menuitem3,"tooltip text","List recently accessed documents")

constant rc_menu = create(GtkRecentChooserMenu,{
    {"add filter",eu_filter},
    {"sort type",GTK_RECENT_SORT_MRU},
    {"show icons",TRUE},
    {"local only",TRUE},
    {"show numbers",TRUE},
    {"show tips",TRUE},
    {"show not found",FALSE},
    $})
    connect(rc_menu,"selection-done",_("LoadRecent"))
    set(menuitem3,"submenu",rc_menu)
    set(menu,"append",menuitem3)

------------------------------------------------------------------------
-- HELP menu items;
------------------------------------------------------------------------
constant show_about = call_back(routine_id("ShowAboutDialog"))
constant menuitem4 = create(GtkMenuItem,"help-about#_Help"),
  helpmenu = create(GtkMenu),
    helpabout = create(GtkMenuItem,"help-about#_About",show_about,0,{group,"F1"})
    set(helpmenu,"append",helpabout)
    set(menuitem4,"submenu",helpmenu)
    set(menu,"append",menuitem4)
    set(helpabout,"add accelerator",{group,"<ctl>a"})
    
-------------------------------------------------------------------------
-- REST of INTERFACE
------------------------------------------------------------------------

constant scrolwin = create(GtkScrolledWindow)
    pack(panel,scrolwin,TRUE,TRUE)

constant tv = create(GtkTextView,{ 
    {"override color",GTK_STATE_FLAG_SELECTED,"black"},
    {"override background color",GTK_STATE_FLAG_SELECTED,"green"},
    {"editable",TRUE},
    {"monospace",TRUE},
    {"font",fnt},
    {"left margin",10},
    {"right margin",10}})
    add(scrolwin,tv)

constant buffer = get(tv,"buffer")
    connect(buffer,"changed",_("Dirty"))

constant statbox = create(GtkButtonBox)
    set(statbox,"background","black")

constant lc = create(GtkLabel)
    add(statbox,lc)
    pack(panel,statbox)

show_all(win)
main()

------------------------------------------------------------------------
global function FRun()
------------------------------------------------------------------------
  if dirty then
      write_file(current_file,get(buffer,"text"),TEXT_MODE)
      dirty = FALSE
  end if
  ifdef UNIX then
	system(sprintf(`eui "%s" & `,{current_file}),0)
  elsedef
	system(sprintf(`eui "%s"`,{current_file}),0)
  end ifdef
return 1
end function

------------------------------------------------------------------------
function FOpen(atom ctl)
------------------------------------------------------------------------
integer fn,len
object txt
object f = fileselector:Open(current_file)
    if string(f) then
	current_file = f
	set(filerun,"sensitive",TRUE)
    -- read the file;
	    fn = open(f,"r")
	    txt = read_file(f)
	    len = length(txt)
	    set(buffer,"text",txt,len)
    -- update file info shown;
	    set(win,"title",format("[]",{f}))
	    set(fileopen,"sensitive",FALSE)
	    set(fileclose,"sensitive",TRUE)
	    dirty = FALSE
    end if
return 1
end function 

------------------------------------------------------------------------
function FClose()
------------------------------------------------------------------------
    if dirty then
        if Warn(win,,"File Modified","Save?",GTK_BUTTONS_YES_NO) = MB_YES then
            write_file(current_file,get(buffer,"text"),TEXT_MODE)
        end if
    end if
    current_file = {}
    set(buffer,"text"," ",0)
    set(lc,"text"," ")
    set(win,"title"," ")
    set(fileopen,"sensitive",TRUE)
    set(fileclose,"sensitive",FALSE)
    set(filerun,"sensitive",FALSE)
return 1
end function

------------------------------------------------------------------------
function LoadRecent()
------------------------------------------------------------------------
object txt, name = get(rc_menu,"current uri")
integer len, fn 

ifdef UNIX then
    name = name[8..$]
elsedef
    name = name[9..$]
end ifdef

    name = url:decode(name)
    current_file = name 
    set(filerun,"sensitive",TRUE)
    fn = open(name,"r") 
    txt = read_file(name) 
    if not atom(txt) then
	set(buffer,"text",txt)
	set(win,"title",name)
	set(fileopen,"sensitive",FALSE)
	set(fileclose,"sensitive",TRUE)
	set(lc,"text",format("[,,] lines, [,,] chars",
	    {get(buffer,"line count"),
	     get(buffer,"char count")}))
    dirty = FALSE
    else
	Warn(,,name,"file missing or unreadable!")
    end if
return 1
end function

------------------------------------------------------------------------
function Colors(atom ctl, atom x)
------------------------------------------------------------------------
    switch x do
	case NORM then
	    set(tv,"background=white,foreground=black")
	case INVERSE then
	    set(tv,"background=black,foreground=white")
	case GRNBLK then
	    set(tv,"background=black,foreground=#0DF517")
    end switch
return 1
end function

------------------------------------------------------------------------
function Bold(atom ctl)
------------------------------------------------------------------------
    ctl = get(ctl,"active")
    atom fd = create(PangoFontDescription,fnt)
    integer style = get(fd,"style")
    if ctl = 1 then 
		set(fd,"weight",PANGO_WEIGHT_BOLD)
		set(fd,"style",style)
    else
		set(fd,"weight",PANGO_WEIGHT_NORMAL)
		set(fd,"style",style)
    end if
    fnt = get(fd,"to string")
    set(tv,"font",fnt)
return 1
end function

------------------------------------------------------------------------
function Italic(atom ctl)
------------------------------------------------------------------------
    ctl = get(ctl,"active")
    atom fd = create(PangoFontDescription,fnt)
    integer weight = get(fd,"weight")
    if ctl = 1 then
		set(fd,"style",PANGO_STYLE_ITALIC)
		set(fd,"weight",weight)
    else
		set(fd,"style",PANGO_STYLE_NORMAL)
		set(fd,"weight",weight)
    end if
    fnt = get(fd,"to string")
    set(tv,"font",fnt)
return 1
end function

------------------------------------------------------------------------
function Oblique(atom ctl)
------------------------------------------------------------------------
    ctl = get(ctl,"active")
    atom fd = create(PangoFontDescription,fnt)
    integer weight = get(fd,"weight")
    if ctl = 1 then
		set(fd,"style",PANGO_STYLE_OBLIQUE)
		set(fd,"weight",weight)
    else
		set(fd,"style",PANGO_STYLE_NORMAL)
		set(fd,"weight",weight)
    end if
    fnt = get(fd,"to string")
    set(tv,"font",fnt)
return 1
end function

------------------------------------------------------------------------
function Wrap(atom ctl)
------------------------------------------------------------------------
    set(tv,"wrap mode",get(ctl,"active")*4) -- i.e. none or word-char
return 1
end function

------------------------------------------------------------------------
function Font()
------------------------------------------------------------------------
    fnt = fontselector:Select(fnt) 
    if string(fnt) then
	set(tv,"font",fnt)
	set(item[7],"active",match(" bold",lower(fnt)))
	set(item[8],"active",match(" italic",lower(fnt)))
	set(item[9],"active",match(" oblique",lower(fnt)))
    end if
return 1
end function

------------------------------------------------------------------------
function ShowAboutDialog()
------------------------------------------------------------------------
    atom dlg = create(GtkAboutDialog,{
	{"logo","~/demos/thumbnails/eugtk.png"},
	{"copyright",copyright},
	{"license",LGPL}, 
	{"license type",GTK_LICENSE_CUSTOM},
	{"wrap license",0},
	{"website","http://OpenEuphoria.org"}, 
	{"website label","OpenEuphoria.org"}, 
	{"authors",{"Irv Mullins"}},
	{"version","A simple text editor\nwritten in Euphoria"}})
	run(dlg)
	destroy(dlg)
return 1
end function
constant show_about_dialog = call_back(routine_id("ShowAboutDialog"))

------------------------------------------------------------------------
function Dirty()
------------------------------------------------------------------------
    dirty = TRUE -- when contents changed, also update stats;
    set(lc,"text",format("[,,] lines, [,,] chars",
         {get(buffer,"line count"),
          get(buffer,"char count")}))
return 1
end function

------------------------------------------------------------------------
function Bail()
------------------------------------------------------------------------
    if dirty then
	if Warn(win,,"File Modified","Save?",GTK_BUTTONS_YES_NO) = MB_YES then
	    write_file(current_file,get(buffer,"text"),TEXT_MODE)
	end if
    end if
return Quit()
end function


