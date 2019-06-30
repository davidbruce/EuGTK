
-------------------------------------------------------------
--# GtkWebKit demo, views, searches, prints web pages as pdf
-------------------------------------------------------------

include GtkEngine.e
include GtkEvents.e
include GtkAboutDialog.e
include std/net/url.e

ifdef WINDOWS then
	Error(,"Sorry","GtkWebKit","Is not available for Windows")
	abort(1)
end ifdef

include GtkWebKit.plugin

constant docs = """

Add a web browser to your EuGTK program!

This demo has the ability to export a webpage to pdf or to your printer!

"""

object uri = "FILE:///"& canonical_path("~/demos/documentation/README.html")


constant css = create(GtkCssProvider,
        "GtkFrame {border-radius: 10px; border-width:3px; border-style: inset; background-color: lightblue;  padding-top: 10px; padding-bottom: 10px}")

constant win = create(GtkWindow,"size=1000x800,position=1,border=10,background=grey90")
    connect(win,"destroy","Quit")

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant view = create(WebkitWebView)
 
    pack(panel,view,TRUE,TRUE)

constant settings = get(view,"settings")
    set(settings,{
        {"enable tabs to links",TRUE},
        {"zoom text only",TRUE},
        {"enable developer extras",TRUE},
        {"enable smooth scrolling",TRUE},
        {"enable_caret_browsing",TRUE},
        {"enable_html5_database",TRUE},
        {"enable_plugins",TRUE},
        {"enable_write_console_messages_to_stdout",TRUE},
        {"enable_hyperlink_auditing",TRUE},
        {"draw_compositing_indicators",TRUE},
        {"enable fullscreen",TRUE}, 
        {"enable_resizable_text_areas",TRUE},
        {"enable_spatial_navigation",TRUE},
    $})

constant find_controller = get(view,"find controller")
connect(find_controller,"counted-matches",_("Match"))

constant -- content for the 'control panel';
    box1 = create(GtkButtonBox), -- first row
    box2 = create(GtkButtonBox), -- second row
    url = create(GtkEntry),
    btn1 = create(GtkButton,"gtk-about",_("About")),
    btn2 = create(GtkButton,"back#_Previous",_("Backward")),
    btn3 = create(GtkButton,"forward#_Next",_("Forward")),
    btn4 = create(GtkButton,"gtk-quit","Quit"),
    slider1 = create(GtkScale,{ -- zoom text 
        {"orientation",HORIZONTAL},
        {"range",50,200},
        {"value",100},
        {"digits",0},
        {"size request",200,20},
        {"tooltip text","Zoom Text"},
        {"connect","change value",_("ScaleView")}}),
        
    btn5 = create(GtkButton,"gtk-find",_("Find")),
    lbl1 = create(GtkLabel,"Matches"), -- display # of matches
    btn6 = create(GtkButton,"gtk-print",_("Print")),
    entry1 = create(GtkEntry)
    pack(box1,slider1,1,1)
    pack(box1,{btn6,entry1,btn5})
    add(box1,lbl1)
    add(box2,{btn4,url,btn2,btn3,btn1})
    set(box2,{
        {"layout",GTK_BUTTONBOX_END},
        {"child secondary",btn4,TRUE}})
    pack_start(panel,box1)
    pack_end(panel,box2)
     
    set(btn5,"tooltip text",
        "Type search text into the box on the left, then click Find.\n" &
        "Click again to locate the next instance of the search term.")
    set(entry1,"tooltip text",
		"Type search text here, then click on the Find button")
    set(url,"tooltip text","Enter URL here, hit enter.")
    set(url,"width chars",80)
    set(url,"text",uri)
    connect(url,"activate",_("LoadURI"))
    
show_all(win)

constant img2 = get(btn2,"image")
constant img3 = get(btn3,"image")

set(btn2,"tooltip markup","Go to previous page\n<small>(if available)</small>")
set(btn3,"tooltip markup","Go to next page\n<small>(if available)</small>")

connect(view,"load-changed",_("UpdateState"))
set(view,"load uri",uri)
hide(lbl1)

main()

----------------
function Print()
----------------
atom print_op = create(WebkitPrintOperation,view)
    set(print_op,"run dialog",win)
return 1
end function

----------------
function Find()
----------------
object srch_txt = get(entry1,"text")
    set(find_controller,"search",srch_txt,0,100)
    get(find_controller,"count matches",srch_txt,0,100)
    show(lbl1)
return 1
end function

------------------------------------
function Match(atom ctl, integer ct)
------------------------------------
    set(lbl1,"text",sprintf("%d matches",ct))
return 1
end function

--------------------------
function About()
--------------------------
atom dlg = about:Dialog
    set(dlg,"add credit section","Uses",{wkdll,"Version: " & webkit_version})
    set(dlg,"comments",docs)
    run(dlg)
    hide(dlg)
return 1
end function

--------------------------
function Backward()
--------------------------
  set(view,"go back")
  UpdateState(view,0)
return 1
end function

-------------------------
function Forward()
-------------------------
  set(view,"go forward")
  UpdateState(view,0)
return 1
end function

-----------------------------------
function ScaleView(atom ctl)
-----------------------------------
  set(view,"zoom level", get(ctl,"value") / 100)
return 0
end function

------------------------
function LoadURI(atom x)
-------------------------
object uri = url:decode(get(x,"text"))
    set(view,"load uri",uri)
    UpdateState(view,WEBKIT_LOAD_FINISHED)
 return 1
end function

-----------------------------------------------------
function UpdateState(atom view, integer event)
-----------------------------------------------------
  set(btn2,"sensitive",get(view,"can go back"))
  set(btn3,"sensitive",get(view,"can go forward"))
  object uri
  if event = WEBKIT_LOAD_FINISHED then
    uri = get(view,"uri")
    set(win,"title",get(view,"title"))
    uri = locate_file(url:decode(uri))
    uri = uri[9..$] -- get rid of file:///
    set(url,"text",uri)
    if match("ex",fileext(uri)) then 
        system(sprintf("eui %s & ",{uri}),2) -- run in bkgnd;
    end if
  end if
return 1
end function




