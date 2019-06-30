#! /usr/local/bin/eui

----------------------------------------------------------------------------
--# Demo of a simple highlighting text editor using GtkSourceView
-- This is able to detect over 100 different languages.
----------------------------------------------------------------------------

include GtkEngine.e
include GtkCairo.e
include GtkAboutDialog.e
include GtkSourceView.plugin -- 'plugins' allow extending EuGTK on the fly

include GtkSettings.e -- for saving editor last file and window size, pos.
include GtkFileSelector.e

include std/io.e

constant eddie = create(GdkPixbuf,"thumbnails/text-editor.png",100,100)

object working_file = 0
boolean dirty = FALSE

constant 
     inifile = canonical_path("~/.test201.ini"), -- in home directory
     win = create(GtkWindow,"name=Main Window,size=900x600,border=10,$delete-event=Bail"),	
     panel = create(GtkBox,"orientation=vertical"),
     btn1 = create(GtkButton,"gtk-quit","Bail"),
     btn2 = create(GtkButton,"gtk-open","OpenFile"),
     btn3 = create(GtkButton,"gtk-save","SaveFile"),
     btn4 = create(GtkButton,"gtk-execute","RunFile"),
     btn5 = create(GtkFontButton,,"SetFont"),
     btn6 = create(GtkComboBoxText,"name=stylebtn"),
     btn7 = create(GtkButton,"gtk-about","About"),
     box = create(GtkButtonBox,"margin top=10"),
     scroller = create(GtkScrolledWindow),
     sv = create(GtkSourceView,{
	  {"show line numbers",TRUE},
	  {"tab width",4},
	  {"indent width",4},
	  {"indent on tab",TRUE},
	  {"auto indent",TRUE},
	  {"font","Ubuntu mono bold, Consolas 12"}, -- overridden by ini
	  {"show right margin",TRUE},
	  {"show line marks",TRUE},
	  {"draw spaces",FALSE},
	  {"insert spaces instead of tabs",FALSE},    
	  {"right margin position",90},
	  {"highlight current line",TRUE},
	  {"wrap mode",GTK_WRAP_WORD_CHAR},
	  $})
	  add(scroller,sv)

constant buf = get(sv,"buffer")

constant 
     mgr = create(GtkSourceStyleSchemeManager),
     ids = get(mgr,"scheme ids"),
     lm = create(GtkSourceLanguageManager) 

     for i = 1 to length(ids) do
	  set(btn6,"append text",ids[i])
     end for
     set(btn6,"active",length(ids))
     connect(btn6,"changed","ChangeStyleScheme")
	
     set(btn5,"name","Font Button")
     set(btn5,"filter func",_("FontFilter"))

     set(btn2,"tooltip markup","Select any sourcecode file to edit")
     set(btn4,"tooltip markup","Run a Euphoria program")

-- on startup:
   settings:Load(inifile)
   object style_scheme = settings:Get("Main Window","scheme")
   set(btn6,"active",find(style_scheme,ids)) 
--
     add(win,panel)
     pack(panel,scroller,TRUE,TRUE)

	 ifdef WINDOWS then add(box,{btn1,btn2,btn3,btn4,btn5,btn7})
	 elsedef
     add(box,{btn1,btn2,btn3,btn4,btn5,btn6,btn7})
	 end ifdef
	 
     pack(panel,-box)

show_all(win)

object f = text:format("[{CMD3}]",info) -- open file on command line if supplied,

if file_exists(f) then working_file = f 
else working_file = settings:Get("Main Window","title")
end if

if file_exists(working_file) then
	OpenFile(working_file)
else
	if string(working_file) then
		Warn(win,,"Cannot open file",working_file)
	end if
end if

connect(buf,"changed",_("SetDirty"))

main()

---------------------------------------
global function ChangeStyleScheme(object x) --
---------------------------------------
   if atom(x) and x > 0 then
	x = get(x,"active text")
   end if	
   style_scheme = x
   x = get(mgr,"scheme",x)
   set(buf,"style scheme",x)
   set(mgr,"force rescan")
return 1
end function

------------------------------------------
global function OpenFile(object name=0) --
------------------------------------------
   if atom(name) then
	fileselector:filters= {"euphoria","html","text"}
	name = fileselector:Open()
	if not string(name) then return 0
	end if
   end if

   set(sv,"font",get("Font Button","font name"))

   set(buf,"text",read_file(name))
   set(win,"title",name)
   
   object lang = get(lm,"guess language",filename(name)) 
   if equal("plugin",fileext(name)) then
	lang = get(lm,"guess language","*.ex")
   end if

sequence mimetypes = {}
 
	object se = gtk_func("gtk_source_encoding_get_current")
	se = gtk_str_func("gtk_source_encoding_to_string",{P},{se})
	
   if lang > 0 then
	set(buf,"language",lang) 
	mimetypes = get(lang,"mime types")

	Info(win,"File Properties",
		text:format("</b>File:<b> []",{filename(name)}),
		text:format("Language: <b>[]</b>\nSection: <b>[]</b>\nMime types: <b>[]</b>\nStyle <b>[]</b>\nFont <b>[]</b>\nEncoding <b>[]</b>",
		{get(lang,"name"),get(lang,"section"),mimetypes,style_scheme,get(btn5,"font"),se}),,eddie)
   
   else
   
	Info(win,"File Properties",
		text:format("</b>File:<b> []",{filename(name)}),
		text:format("\nFont <b>[]</b>\nEncoding <b>[]</b>",
		{get(btn5,"font"),se}),,eddie)
   
   end if
   
   working_file = name
   dirty = FALSE

set(btn4,"sensitive", equal("ex",fileext(working_file)))

return 1
end function

------------------------------------
global function SetFont(atom ctl) -- set view font as selected by font button;
------------------------------------
set(sv,"font",get(ctl,"font"))
return 1
end function

----------------------
function SetDirty() -- source text has changd;
----------------------
   dirty = TRUE
return 1
end function

-----------------------------
global function SaveFile() -- save the [updated] text;
-----------------------------
   if write_file(working_file,get(buf,"text")) then
	dirty=FALSE
   else
	Warn(win,"Write Error",sprintf("Cannot save %s",{working_file}))
   end if
return 1
end function

-----------------------------
global function RunFile() -- execute current file;
-----------------------------
   if dirty then
	if Question(win,"Dirty","Save changes?") = MB_YES then
		SaveFile()
		dirty = FALSE
	end if
   end if 
   if string(working_file) then
	system(sprintf("eui %s",{working_file}),0)
   end if
return 1
end function

--------------------------
global function About()
--------------------------
atom dlg = about:Dialog
	set(dlg,"add credit section","Special Thanks to",{"Bob's Burgers","Duff's Beer"})
	run(dlg)
	hide(dlg)
return 1
end function

-------------------------
global function Bail() -- save current settings and quit;
-------------------------
if dirty then
  if Question(win,"Dirty","Save changes?") = MB_YES then
     SaveFile()
     dirty = FALSE
  end if
end if
settings:Save(inifile,{win,btn5,btn6},1) -- save window dimensions and current font;
settings:Set(inifile,"Main Window","scheme",style_scheme) -- scheme is not a GTK property;
settings:Set(inifile,"Main Window","title", working_file) -- saving properties other than defaults;
Quit()
return 1
end function

--------------------------------------------------------
function FontFilter(FontFamily family, atom face)
--------------------------------------------------------
integer result = 0

-- filter to include mono;
	result = get(family,"is monospace") -- show all monospace;

-- here's how to filter "out" unwanted fonts;
	object name = get(family,"name")
	 if match(name,"Japanese") then result = 0 end if 
	 if match(name,"Webdings") then result = 0 end if

-- here's how to filter "in" some font;
	if match("URW Palladio L",name) then result = 1 end if

return result
end function



