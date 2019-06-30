-------------------------------------------------------------------------------
--# BEAR (Browse, Edit And Run)
-------------------------------------------------------------------------------
-- Requires EuGTK version 4.11.10+, GtkSourceView and WebKit2Gtk libraries.
-- You may have to manually change the names of the libraries of the
-- GtkSourceView.plugin and/or GtkWebKit.plugins:

svpath = "/usr/lib/x86_64-linux-gnu/libgtksourceview*" -- note wildcard *
wkpath = "/usr/lib/x86_64-linux-gnu/libwebkit2gtk-4*"  -- note wildcard *
-- * wildcard on end of path names allows the plugins to select the most
--   current version.

object gtk_help_file = "~/gtk3/%s.html" -- put gtk docs in gtk3
-- easiest way is to download the latest GTK3 docs, unzip into your home
-- directory, and edit the folder name to be just gtk3 (remove the versioning)
 
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 */

include GtkEngine.e
include GtkFileSelector.e
include GtkFontSelector.e
include GtkSettings.e
include GtkEvents.e
include GtkWebKit.plugin
include GtkSourceView.plugin
include GtkAboutDialog.e
include GtkPrinter.e

include std/net/url.e
include std/net/http.e
include std/os.e
include std/io.e

include EuKeywords.e 

requires("3.12","GTK Library too old")

------------------------------
-- Globals
------------------------------
constant editables =
 {"e","ex","txt","text","ini","css","xml","glade","c","cpp","h","plugin","py","ino"}
 -- above are the file extensions of files which should by default load
 -- into the source editor, rather than into the webview;

object
 current_web_page = "documentation/README.html",
 current_net_page = "",
 current_edit_file = "",
 current_font = "Ubuntu mono 12",
 current_web_folder = "~/demos",
 current_edit_folder = "~/demos",
 current_style = "classic"

object uri, link, lang, tags = {}
object svbuffer, request, lm, edit_html = 0
constant cb = create(GtkClipboard)
constant ini = canonical_path("~/.bear.ini")

atom sv, menu, m1, m2, m3, m4, sep, context
atom wvsettings, svsettings, controller,sig
integer toggle = 1

------------------------------------------
-- Styling
------------------------------------------
constant css = create(GtkCssProvider,`
 @define-color yellow #F5EEB5;
 @define-color blue #B5F5F4;
GtkFrame,GtkToolbar {border-radius: 10px;
	background-image:
	-gtk-gradient (linear,
		left top, right bottom,
		from(@yellow), to(@blue));
	}
`)

constant mgr = create(GtkSourceStyleSchemeManager)
constant ids = get(mgr,"scheme ids")
sequence sty = repeat(0,length(ids))
	 sty[1] = create(GtkRadioMenuItem,0,ids[1],_("SelectStyle"),ids[1])
	 for i =  2 to length(ids) do
		sty[i] = create(GtkRadioMenuItem,sty[i-1],
		ids[i],_("SelectStyle"),ids[i])
	 end for

----------------------------
-- Interface
----------------------------

constant -- Main Window;
 win = create(GtkWindow,"name=MainWindow,title=The Bear,size=1200x800,border=10,$delete-event=Bail,$destroy=Quit"),
 top = create(GtkBox,"name=top,orientation=VERTICAL"),
 bar = create(GtkButtonBox,"name=bar,layout=2,margin-bottom=5")

add(win,top)
pack(top,bar)

pack(bar,{ -- these frames display current file names, captions, language type;
create(GtkFrame,"name=frame1"),
create(GtkFrame,"name=frame2"),
create(GtkFrame,"name=frame3"),
create(GtkFrame,"name=frame4")})

add("frame1",create(GtkLabel,"name=label1,text=URL,font=8"))
add("frame2",create(GtkLabel,"name=label2,text=TITLE,font=8"))
add("frame3",create(GtkLabel,"name=label3,text=LANG,font=8"))
add("frame4",create(GtkLabel,"name=label4,text=FILE,font=8"))

-- the panes, webview on left, editor on right;
pack(top,create(GtkPaned,"name=paned,orientation=HORIZONTAL"),TRUE,TRUE)
set("paned","pack1",create_webview(),1,1) -- left side contains web view;
set("paned","pack2",create(GtkBox,"name=pane2,orientation=VERTICAL"),TRUE,TRUE)
pack("pane2","srchBar")
pack("pane2",create_sourceview(),1,1) -- right side contains source view;

pack_end(top,create(GtkBox,"name=control_box,orientation=HORIZONTAL,spacing=5"))
pack("control_box",{ -- container for controls at bottom of screen;
	create(GtkFrame,"name=frame5,label=Web Page"),
	create(GtkFrame,"name=frame6,label=Source")},TRUE,TRUE)

 -- Web page toolbar;
add("frame5",create(GtkToolbar,"name=bar1,style=2,icon size=1,font=8"))
add("bar1",{ -- buttons for web page navigation;
	create(GtkToolButton,"name=htmlOpen,stock_id=gtk-open,label=Local",,_("OpenWebPage")),
	create(GtkToolButton,"name=htmlEdit,stock_id=gtk-edit",,_("EditHtml")),
	create(GtkToolButton,"name=htmlBack,stock_id=gtk-go-back",,_("Back")),
	create(GtkToolButton,"name=htmlFwd,stock_id=gtk-go-forward",,_("Fwd")),
	create(GtkToolButton,"name=htmlFind,stock_id=gtk-find",,_("Find")),
	create(GtkToolButton,"name=zoomOut,stock_id=gtk-zoom-out",,_("ZoomOut")),
	create(GtkToolButton,"name=zoomIn,stock_id=gtk-zoom-in",,_("ZoomIn")),
	create(GtkToolButton,"name=htmlPrint,stock_id=gtk-print",,_("WebPrint")),
	create(GtkToolButton,"name=htmlHelp,stock_id=gtk-help",,_("BearHelp"))})
	
	set("htmlFind","tooltip text","Highlight and copy a phrase on the web page,\n" &
	    "click here to search the source code.")
	set("htmlPrint","tooltip markup","Print webpage to PDF")
	set("htmlHelp","tooltip text","Show BEAR facts")
	
   add("frame6",create(GtkToolbar,"name=bar2,style=2,icon size=1,font=8,show_arrow=FALSE"))

-- Source editor toolbar;
   add("bar2",{ -- buttons for source view navigation;
	create(GtkToolButton,"name=srcNew,stock_id=gtk-new",,"fileNew"),
	create(GtkToolButton,"name=srcOpen,stock_id=gtk-open",,"fileOpen"),
	create(GtkToolButton,"name=srcSave,stock_id=gtk-save",,"fileSave"),
	create(GtkToolButton,"name=srcSaveAs,stock_id=gtk-save-as",,"fileSaveAs"),
	create(GtkToolButton,"name=srcRun,stock_id=gtk-execute",,"fileRun"),
	create(GtkSeparatorToolItem,"draw=TRUE,expand=TRUE"),
	create(GtkToolButton,"name=srcPrint,stock_id=gtk-print",,"filePrint"),
	create(GtkToolButton,"name=srcHelp,stock_id=gtk-help,label=Docs",,_("GtkHelp")),
	create(GtkToolButton,"name=srcFont,icon_name=font,label=Fonts",,_("ChooseFont")),
	create(GtkToolButton,"name=srcMenu,stock_id=gtk-preferences"),
	create(GtkToolButton,"name=srcAbout,stock_id=gtk-about",,_("About"))})

	set("srcNew","tooltip text","Create a new, empty file.")
	set("srcSave","tooltip markup","<b>Save</b> the source")
	set("srcRun","tooltip markup","<b>Test run</b> the source")
	set("srcMenu","tooltip text","Select Line Numbers, Syntax Colors, etc.")
	set("srcHelp","tooltip text","Lookup Documentation")

constant
	pop = create(GtkPopover,pointer("srcMenu")),
	popbox = create(GtkBox,"orientation=vertical,border=5")
	add(pop,popbox)
	add(popbox,build_prefs_menu())
	connect("srcMenu","clicked",_("PopupSrcMenu"))

constant about_the_bear = about:Dialog
	set(dlg,"program name","The Bear")
	set(dlg,"version","Version 2.0")
	set(dlg,"logo","thumbnails/mongoose.png")

connect("MainWindow","realize",_("on_startup"))

show_all("MainWindow")
main()

-------------------------
global function fileNew()
-------------------------
fileselector:do_overwrite_confirmation = TRUE
fileselector:filters = {"euphoria","html","css","python","text"}
object f  = fileselector:New()
if not atom(f) then
	create_file(f)
end if
return 1
end function

--------------------------
global function fileOpen()
--------------------------
fileselector:filters = {"euphoria","html","css","text"}
object f = fileselector:Open()
if not atom(f) then
	load_file(f)
	current_edit_folder = pathname(f)
end if
return 1
end function

-----------------------------
global function filePrint()
-----------------------------
if equal("html",fileext(current_edit_file)) then
	printer:use_syntax_color = FALSE
else
	printer:use_syntax_color = TRUE
	printer:use_line_numbers = TRUE
end if
printer:PrintFile(current_edit_file)
return 1
end function

------------------------------------
global function fileSearch()
------------------------------------
Info("pri=Search;sec=Enter a word or term to search for;addon=srchEntry;btns=5")
return 1
end function

---------------------------
global function fileSave()
---------------------------
object f
atom fn

fileselector:do_overwrite_confirmation = FALSE

if match("http://",current_edit_file) = 1 then
	if get(m4,"active") then
		f = fileselector:Save(canonical_path(filename(fix(decode(current_edit_file)))))
	end if
else
	f = canonical_path(get("label4","text"))
	fileselector:filters = {fileext(f)} & {"text"}
	chdir(pathname(f))
	if get(m4,"active") then
		f = fileselector:Save(f)
	end if
end if

if string(f) then
	fn = open(f,"w")
	write_file(fn,get(svbuffer,"text"),TEXT_MODE)
	flush(fn)
	close(fn)

	if match("htm",fileext(f)) = 1 then
		set("WebView","reload bypass cache")
		current_web_folder = pathname(f)
	else
		current_edit_folder = pathname(f)
	end if
end if
return 1
end function

------------------------------
global function fileSaveAs()
------------------------------
fileselector:do_overwrite_confirmation = TRUE

object f = filename(current_edit_file)
fileselector:filters = {fileext(f)} & {"text"}

f = fileselector:SaveAs(f & ".backup")
if string(f) then
	write_file(f,get(svbuffer,"text"),TEXT_MODE)
	if match("htm",fileext(f)) = 1 then
		current_web_folder = pathname(f)
	else
		current_edit_folder = pathname(f)
	end if
end if
return 1
end function

----------------------------
global function fileRun()
----------------------------
object
	f = current_edit_file,
 cmd = command_line(),
 ext,
 err = 0,
 msg = 0,
 config = canonical_path("~/tmp/eu.cfg"),
 currdir = current_dir()

atom fn, iter = 0

if atom(dir("tmp"))  then
   create_directory(canonical_path("~") & "/tmp")
end if

	if equal("py",fileext(f)) then
		fn = open(f,"w")
		write_file(fn,get(svbuffer,"text"),TEXT_MODE)
		flush(fn)
		close(fn)
	  return system_exec(sprintf(`xterm -hold -e python "%s" `,{f}))
 end if

 if equal("c",fileext(f)) then
	fn = open(f,"w")
		write_file(fn,get(svbuffer,"text"),TEXT_MODE)
		flush(fn)
		close(fn)
	  if system_exec(sprintf("gcc %s -o %s/%s",{f,pathname(f),filebase(f)})) = 0 then
	Info(,"Compiled",pathname(f) & '/' & filebase(f),"from " & f)
		  system_exec(sprintf(`xterm -hold -e "%s/%s"`,{pathname(f),filebase(f)}))
		end if
		return 1
 end if

	if not file_exists(config) then
	  fn = open(config,"w")
	  write_file(fn,"~/demos\n")
	  flush(fn)
	  close(fn)
	end if

	cmd = pathname(get("label4","text"))
	f = filebase(f)
	ext = fileext(cmd)

	object tmp = temp_file(canonical_path("~/"),sprintf("tmp/%s_",{f}),"ex",1)
	if not file_exists(canonical_path("~/tmp")) then
		create_directory(canonical_path("~/tmp"),448,1)
	end if

	system("cd ~/tmp",0)
	fn = open(tmp,"w")
	write_file(fn,get(svbuffer,"text"),TEXT_MODE)
	flush(fn)
	close(fn)
	delete_file("ex.err")

	setenv("EUINC",cmd)

	system(text:format("eui -TEST [] ",{tmp}),0) -- test the code;
	if file_exists("ex.err") then -- found an error:
	  err = ParseErrorFile()
	  msg = read_lines("ex.err")
	  msg = msg[1..5]
	  msg = join(msg,'\n')
	  msg = transmute(msg,{'<','>'},{32,32})
	  if sequence(err) then
	 iter = get(svbuffer,"iter at line index",err[1],err[2])
	 set(svbuffer,"place cursor",iter)
	 set(sv,"scroll to iter",iter,0,1,0.5,0.5)
	 Error(,,sprintf("Line %d column %d",err),msg)
	  end if
	else
	system(text:format("eui [] & ",{tmp}),0) -- actually run it (in background)
	end if
	system("cd " & currdir,0)
return 1
end function

----------------------
function WebPrint() --
----------------------
atom print_op = create(WebkitPrintOperation,pointer("WebView"))
    set(print_op,"run dialog",win)
return 1
end function

-------------------------------
function create_file(object f)
-------------------------------
object hdr
	lang = get(lm,"guess language",f)
	set(svbuffer,"language",lang)
	switch get(lang,"name") do
		case "Euphoria" then hdr = euhdr
		case ".ini" then hdr = inihdr
		case "CSS" then hdr = csshdr
		case "HTML" then hdr = htmhdr
		case "Python" then hdr = pyhdr
		case "C" then hdr = chdr

		case else hdr = "-- []\n\n"
	end switch
	set(svbuffer,"text",format(hdr,{f}))
	set("label3","text",get(lang,"name"))
	set("label4","text",f)
	write_file(f,get(svbuffer,"text"))
	current_edit_file = f
	current_edit_folder = pathname(f)
return update_buttons()
end function

--------------------------------------------------
global function load_file(object f, integer web=0)
--------------------------------------------------
object txt

	if match("file://",lower(f)) = 1 then
		f = f[8..$]
	end if

	if file_exists(canonical_path(f)) then
			txt = read_file(canonical_path(f))

	elsif match("http://",lower(f)) then

		if not inet_connected() then
			Warn(,,"Network down")
			return -1
		end if

		txt = http_get(f)

		if atom(txt) then
			Error(,,"Error %d loading %s ",{txt,f})
			return -1
		else
			txt = txt[2]
		end if

	end if

	if not object(txt) then
		Error(,,"Invalid file/web page",f)
		return 0
	end if

	lang = get(lm,"guess language",f)
	if equal("plugin",fileext(f)) then
		lang = get(lm,"guess language","*.ex")
	end if
	if equal("ino",fileext(f)) then
		lang = get(lm,"guess language","*.c")
	end if
	set(svbuffer,"language",lang)
	set(svbuffer,"text",txt)
	set("label3","text",get(lang,"name"))
	set("label4","text",f)
	current_edit_file = f
	current_edit_folder = pathname(f)

return update_buttons()
end function

----------------------
function fix(object x)
----------------------
	if match("#",x) then
		x = split(x,'#')
		x = x[1]
	end if
	if match("file:",x) = 1 then
		return x[8..$]
	end if
	if match("http:",x) = 1 then
		return x[8..$]
	end if
	if match("https:",x) = 1 then
		return x[9..$]
	end if
return x
end function

-----------------------
function Back(atom ctl)
-----------------------
	set("WebView","go back")
return update_buttons()
end function

----------------------
function Fwd(atom ctl)
----------------------
	set("WebView","go forward")
return update_buttons()
end function

---------------
function Undo()
---------------
	set(svbuffer,"undo")
return update_buttons()
end function

---------------
function Redo()
---------------
	set(svbuffer,"redo")
return update_buttons()
end function

------------------
function ZoomIn()
------------------
	set("WebView","zoom level",get("WebView","zoom level") + .1)
return 1
end function

------------------
function ZoomOut()
------------------
	set("WebView","zoom level",get("WebView","zoom level") - .1)
return 1
end function

-------------------------
function update_buttons()
-------------------------
integer x = get(svbuffer,"char count")
	set("srcSave","sensitive",x)
	set("srcSaveAs","sensitive",x)
	set("srcRun","sensitive",FALSE)

	if string(current_edit_file) then
		if equal("ex",fileext(current_edit_file))
	or equal("py",fileext(current_edit_file))
	or equal("c",fileext(current_edit_file)) then
			set("srcRun","sensitive",TRUE)
		end if
	end if

object uri = get("WebView","uri")
	if sequence(uri) then
		set("htmlEdit","tooltip markup","<b>Click to edit</b>\n" & filename(uri))
		if match("htm",fileext(uri)) then
			set("label1","text",decode(uri))
			set("label2","text",get("WebView","title"))
		end if
	end if
return 1
end function

-----------------------
function OpenNetPage()
-----------------------
atom dlg = create(GtkDialog,"name=NetDialog")
	set(dlg,"add button","gtk-cancel",MB_CANCEL)
	set(dlg,"add button","gtk-ok",MB_OK)
	set(dlg,"default response",MB_OK)
atom ca = get(dlg,"content area")
atom lbl = create(GtkLabel,"   Enter a web address beginning with http://   ")
atom input = create(GtkEntry,"name=NetEntry")
	connect(input,"activate",_("LoadNetPage"),dlg)
	add(ca,{lbl,input})
	show_all(dlg)

if match("file://",current_net_page) = 1 then
	set(input,"text","")
elsif match("http",current_net_page) = 1 then
	set(input,"text",current_net_page)
else
	set(input,"text","http://" & current_net_page)
end if

object uri, request
if run(dlg) = MB_OK then
	uri = get(input,"text")
	if length(uri) > 0 then
		request = create(WebkitUriRequest,decode(uri))
		set("WebView","load request",request)
	end if
end if

destroy(dlg)
return 0
end function

--------------------------------------------
function LoadNetPage(object ctl, object dlg)
--------------------------------------------
 request = create(WebkitUriRequest,decode(get("NetEntry","text")))
 set("WebView","load request",request)
 destroy(dlg)
return 1
end function

-----------------------
function OpenWebPage()
-----------------------
fileselector:filters = {"html","css"}
fileselector:select_multiple = FALSE
object f = fileselector:Open()
	if not atom(f) then
		load_html(f)
		current_web_folder = pathname(f)
	end if
return 1
end function

-----------------------------------
global function load_html(object x)
-----------------------------------
	x = canonical_path(locate_file(x)) 
	set(svsettings,"search text",0)
	request = create(WebkitUriRequest,"file://" & x)
	set("WebView","load request",request)
	set("label1","text",x)
return 1
end function

--------------------------------------------------
function on_load_changed(atom view, integer event)
--------------------------------------------------
object uri, ext = "?", x = 0

	set(svsettings,"search text","")

	switch event do

		case WEBKIT_LOAD_STARTED then
			uri = decode(get("WebView","uri"))
			ext = fileext(filename(uri))
			if  find(ext,editables) then
				set("WebView","stop loading")
				load_file(uri,0)
			end if

		case WEBKIT_LOAD_REDIRECTED then

		case WEBKIT_LOAD_COMMITTED then

		case WEBKIT_LOAD_FINISHED then
			uri = decode(get("WebView","uri"))
			if find(ext,editables) = 0 then
				current_web_page = uri
			end if

		current_net_page = uri

	end switch

	edit_html = 0

return update_buttons()
end function

--------------------------
function EditHtml()
--------------------------
object f = url:decode(canonical_path(fix(get("label1","text"))))
if not file_exists(f) then return 1 end if

edit_html = 1

set("WebView","reload")

if file_exists(f) then
	object txt = read_file(f)
	if not atom(txt) then
		load_file(f,1)
	end if
else
	f = get("WebView","uri")
	if match("#",f) then
		f = split(f,'#')
		f = f[1]
	end if

	object content = http_get(f)
	if atom(content) then
		Error(,,"Cannot load web page",f)
	else
		lang = get(lm,"guess language",f)
		set(svbuffer,"language",lang)
		set("label3","text",get(lang,"name"))
		set("label4","text",f)
		set(svbuffer,"text",content[2])
		current_edit_file = f
		update_buttons()
	end if
end if
return 1
end function

--------------------------
function create_webview()
--------------------------
atom webview = create(WebkitWebView,"name=WebView")
atom vset = get(webview,"settings")
	set(vset,{
		{"enable tabs to links",TRUE},
		{"zoom text only",FALSE},
		{"enable developer extras",TRUE},
		{"enable smooth scrolling",TRUE},
		{"enable_caret_browsing",TRUE},
	$})

 connect(webview,"load-changed",_("on_load_changed"))

 wvsettings = get(webview,"settings")
	set(wvsettings,{
		{"enable plugins",1},
	{"zoom text only",1},
	{"enable smooth scrolling",1},
		{"enable tabs to links",1},
		{"draw compositing indicators",0},
		{"enable html5 database",1},
		{"enable html5 local storage",1},
		{"enable hyperlink auditing",1}})

 controller = get(webview,"find controller")

return webview
end function

---------------
function Find()
---------------
atom buffer = get(context,"buffer")
object a = allocate(100)
object b = allocate(100)
object c = allocate(100)
object x, count
integer try = 1
atom fn = define_c_func(LIBSV,"gtk_source_search_context_forward",{P,P,P,P},I)
object txt = get(cb,"wait for text")
label "retry"
c_proc(fnBufStart,{buffer,a})
c_proc(fnBufEnd,{buffer,b})
 if string(txt) then
txt = transmute(txt,
	{{},"<",">","&"},
	{{},"&lt;","&gt;","&amp;"})
txt = join(split(txt),"\\s+")
set(svsettings,"regex enabled",1)
set(svsettings,"search text",txt)

  count = get(context,"occurrences count")
  if count  = -1 then
	try += 1
	if try > 20 then
	return 0
	end if
	goto "retry"
  else
   x = c_func(fn,{context,a,b,c})
   set(sv,"scroll to iter",b,.25,1,0,0)

  end if
end if
return 1
end function

-----------------------------
function create_sourceview()
-----------------------------
 atom scroller = create(GtkScrolledWindow)
 sv = create(GtkSourceView,{
	{"name","SrcView"},
	{"show line numbers",TRUE},
	{"tab width",4},
	{"indent width",4},
	{"indent on tab",TRUE},
	{"auto indent",TRUE},
	{"font","Ubuntu mono bold 12"},
	{"show right margin",TRUE},
	{"show line marks",TRUE},
	{"draw spaces",FALSE},
	{"insert spaces instead of tabs",FALSE},
	{"right margin position",90},
	{"highlight current line",TRUE},
	{"smart backspace",TRUE},
	{"wrap mode",GTK_WRAP_NONE}})
 add(scroller,sv)

 set(sv,"font",current_font)

 svbuffer = get(sv,"buffer") -- see GtkTextBuffer for properties;
 set(svbuffer,"highlight matching brackets",TRUE)
 set(svbuffer,"ensure highlight")

 lm = create(GtkSourceLanguageManager)
 svsettings = create(GtkSourceSearchSettings)
 context = create(GtkSourceSearchContext,svbuffer,svsettings)

 set(svsettings,"at word boundaries",0)
 set(svsettings,"case sensitive",1)

return scroller
end function

------------------------------------
function ToggleLineNumbers(atom ctl)
------------------------------------
 set("SrcView","show line numbers",get(ctl,"active"))
return 1
end function

------------------------------------
function ToggleSpaces(atom ctl)
------------------------------------
  if get(ctl,"active") then
	set("SrcView","draw spaces",GTK_SOURCE_DRAW_SPACES_ALL)
  else
	set("SrcView","draw spaces",FALSE)
  end if
return 1
end function

------------------------------------
function ChooseFont(atom ctl)
------------------------------------
fontselector:mono_filter = TRUE -- comment this out if you want all fonts;
object x = fontselector:Select(current_font)
	if not atom(x) then
		set("SrcView","font",x)
		current_font = x
	end if
return 1
end function

-----------------------------
function build_prefs_menu()
-----------------------------
	menu = create(GtkMenu,"name=prefs_popup")
	m2 = create(GtkCheckMenuItem,"Line numbers",_("ToggleLineNumbers"))
	m3 = create(GtkCheckMenuItem,"Draw spaces+tabs",_("ToggleSpaces"))
	m4 = create(GtkCheckMenuItem,"Confirm on Save")

	atom s1 = create(GtkSeparatorMenuItem,"color=red")
	atom s2 = create(GtkSeparatorMenuItem,"color=blue")

	set(menu,"append",{m2,s1,m3,m4,s2,sty})
	set(m2,"name","ShowLineNumbers")
	set(m2,"active",get("SrcView","show line numbers"))
	set(m3,"name","DrawSpaces")
	set(m3,"active",get("SrcView","draw spaces"))
	set(m4,"name","m4")

	show_all(menu)
return menu
end function

--------------------------------------------
function SelectStyle(atom ctl, object name)
--------------------------------------------
  if atom(name) then name = unpack(name) end if
  atom scheme  = get(mgr,"scheme",name)
  set(svbuffer,"style scheme",scheme)
  set(mgr,"force rescan")
  current_style = name
return 1
end function

-----------------------------
function BearHelp()
-----------------------------
object uri = "file://" & canonical_path("~/demos/documentation/bear.html")
	set("WebView","load uri",uri)
return 1
end function

-----------------------------
function GtkHelp()
-----------------------------
object bounds = {0,0}
object word
if get(svbuffer,"has selection") then
	bounds = get(svbuffer,"selection bounds")
	word = get(svbuffer,"slice",bounds[1],bounds[2])
	if match("Gtk",word) = 1 then
			load_html(sprintf(gtk_help_file,{word}))
		else
			EuphoriaHelp(word)
		end if
else
	Info(,,"For Help","Highlight a GtkWidget name or Euphoria keyword")
end if
return 1
end function

-----------------------------
function About()
-----------------------------
set(about_the_bear,"add credit section","Using:",
		{"Euphoria " & eu_version,
		 "EuGTK " & gtk:version &" GTK " & lib_version,
		  filename(svdll),filename(wkdll)})
run(about_the_bear)
hide(about_the_bear)
return 1
end function

-----------------------------------------
function PopupSrcMenu()
------------------------------------------
set("prefs_popup","popup")
return 1
end function

--------------------------
function ParseErrorFile()
--------------------------
object file_lines
object temp_line
object err_line
object file_name

integer err_col = 0, i = 0

if not file_exists("ex.err") then
	abort(1) -- can't find ex.err!
end if

file_lines = read_lines("ex.err")
if atom(file_lines) then  -- ex.err was empty
	crash("Cannot find ex.err!\n")
end if

object x = split(file_lines[1])

for n = 1 to length(file_lines) do
	if match("^^^ call-back from external source",file_lines[n]) = 1 then
	file_lines = file_lines[1..n-1] -- get rid of non-useful part of ex.err listing;
	exit
	end if
end for

-- trap & process GTK signal 11 errors;
	for n = length(file_lines) to 2 by -1 do
	-- start at end of ex.err, to find last (topmost) error line #;
	if match("... called from /", file_lines[n]) then
		i = find(':', file_lines[n])
		file_name = file_lines[n][17..i-1]
		err_line = file_lines[n][i+1..$]
		i = find(' ',err_line)
		err_line = err_line[1..i-1]
		err_line = to_number(err_line)
		return {err_line,err_col}
	end if
	end for

-- trap & process euphoria error report;
	for n = 1 to length(file_lines) do
	-- start at top of ex.err, to find first syntax error;
	if find('^', file_lines[n]) then
		i = find(':',file_lines[1])
		err_col = match("^",file_lines[n])-1
		file_name = file_lines[1][1..i-1]
		err_line = to_number(file_lines[1][i+1..$])
		return {err_line,err_col}
	end if
	end for
return -1
end function

-------------------------------
function on_startup()
-------------------------------
settings:Load(ini)

object x = settings:Get("MainWindow","edit_file")
if sequence(x) and length(x) > 0 then x = decode(x)
	load_file("file://" & canonical_path(x),0)
end if

current_web_folder = settings:Get("MainWindow","current_web_folder")

x = settings:Get("MainWindow","current_net_page")
if sequence(x) and length(x) > 0 then
	current_net_page = decode(fix(x))
	load_html(current_net_page)
end if

current_edit_folder = settings:Get("MainWindow","current_edit_folder")

current_style = settings:Get("SrcView","current_style")
	x = find(current_style,ids)
	if x > 0 and x <= length(sty) then
		set(sty[x],"active",1)
	end if

set("htmlOpen","tooltip text","Open a local html file")
set("srcOpen","tooltip text","Open a local text file")

current_font = settings:Get("SrcView","font")
if atom(current_font) then
current_font = "Courier 12"
end if
set("SrcView","font",current_font)

object pos = settings:Get("MainWindow","pane_position")
if string(pos) then
	set("paned","position",to_number(pos))
end if

return 1
end function

-------------------------
global function Bail() -- do this before quitting!
-------------------------
	settings:Save(ini,{"MainWindow","ShowLineNumbers","DrawSpaces","FontSelector","m4"})
	settings:Set(ini,"MainWindow","edit_file",decode(fix(current_edit_file)))
	settings:Set(ini,"MainWindow","current_web_folder",decode(current_web_folder))
	settings:Set(ini,"MainWindow","current_net_page",decode(fix(get("label1","text"))))
	settings:Set(ini,"MainWindow","current_edit_folder",decode(pathname(current_edit_file)))
	settings:Set(ini,"MainWindow","pane_position",get("paned","position"))
	settings:Set(ini,"SrcView","current_style",current_style)
	settings:Set(ini,"SrcView","font",get("FontSelector","font"))
return Quit()
end function

-- Boilerplate templates for creating new files:

constant euhdr = `
----------------------------
-- []
----------------------------

`
constant inihdr = `
;---------------------------
; []
;---------------------------

`
constant csshdr = `
/* [] */

`
constant htmhdr = `

<!-- [] -->
<!DOCTYPE html>
<html lang="en">

<head>
  <title></title>
  <link rel="stylesheet" href="style.css" type="text/css">
</head>

<body>

</body>

</html>

`
constant chdr = `

//
// []
//

void main(){

}

`

constant pyhdr = `
#
# []
#

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

class MyWindow(Gtk.Window):

	def __init__(self):
		Gtk.Window.__init__(self, title="Hello World")
		self.button = Gtk.Button(label="Click Here")
		self.button.connect("clicked", self.on_button_clicked)
		self.add(self.button)

	def on_button_clicked(self, widget):
		print("Hello World")

win = MyWindow()
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()

`
--================================= END ===================================--

